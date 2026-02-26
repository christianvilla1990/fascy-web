# ...existing code...
require "net/ftp"
require "image_processing/vips"
require "tempfile"

class FtpImageImporter
  FORMATS  = %w[jpg jpeg png JPG JPEG PNG].freeze
  QUALITY  = 82

  def initialize(host:, user:, pass:, base_dir:)
    @host     = host
    @user     = user
    @pass     = pass
    @base_dir = base_dir
  end

  # Importa todas las carpetas (cada carpeta = SKU)
  def call
    Net::FTP.open(@host, @user, @pass) do |ftp|
      ftp.passive = true
      ftp.chdir(@base_dir)

      skus = sku_dirs(ftp)
      Rails.logger.info "[FTP] Encontrados #{skus.size} SKUs en #{@base_dir}"

      limit = Integer(ENV.fetch("LIMIT", skus.size.to_s))
      skus.first(limit).each_with_index do |sku, idx|
        Rails.logger.info "[FTP] (#{idx + 1}/#{[limit, skus.size].min}) Importando #{sku}"
        begin
          # Reutiliza el flujo probado
          import_sku(sku)
        rescue => e
          Rails.logger.error "[FTP] Falló #{sku}: #{e.class}: #{e.message}"
        end
      end
    end
  end

  # Importa solo un SKU
  def import_sku(sku)
    Net::FTP.open(@host, @user, @pass) do |ftp|
      ftp.passive = true
      ftp.chdir(@base_dir)
      begin
        ftp.chdir(sku)
      rescue => e
        Rails.logger.info "[FTP] Carpeta #{sku} no existe en FTP: #{e.message}"
        return
      end
      producto = Producto.find_by(sku: sku)
      unless producto
        Rails.logger.info "[FTP] SKU #{sku} sin producto"
        return
      end
      image_files(ftp).each { |f| attach_as_webp(ftp, producto, f) }
    end
  end

  private

  def list_names(ftp)
    names =
      begin
        ftp.nlst(".")
      rescue Net::FTPPermError
        ftp.list(".").map { |l| l.split.last }
      end

    names
      .map { |n| n.to_s.strip.sub(/\A\.\//, "") } # quita prefijo "./"
      .reject { |n| n.empty? || n == "." || n == ".." }
  end

  def sku_dirs(ftp)
    list_names(ftp)
      .reject { |n| n.nil? || n.empty? || %w[. ..].include?(n) || n.start_with?(".") }
      .select do |name|
        begin
          pwd = ftp.pwd
          ftp.chdir(name)
          ftp.chdir(pwd)
          true
        rescue
          false
        end
      end
  end

  def image_files(ftp)
    list_names(ftp)
      .reject { |n| n.nil? || n.empty? || %w[. ..].include?(n) || n.start_with?(".") }
      .select { |name| FORMATS.include?(File.extname(name).delete(".")) }
  end

  def attach_as_webp(ftp, producto, remote_file)
    base      = File.basename(remote_file, ".*")
    webp_name = "#{base}.webp"
    return if producto.imagenes.any? { |att| att.filename.to_s == webp_name }

    Tempfile.create([base, File.extname(remote_file)]) do |tmp|
      ftp.getbinaryfile(remote_file, tmp.path)

      begin
        webp_tmp = ImageProcessing::Vips
                     .source(tmp.path)
                     .loader(autorotate: true)      # respeta orientación EXIF al leer
                     .convert("webp")
                     .saver(q: QUALITY, strip: true) # elimina EXIF para evitar warnings
                     .call
      rescue => e
        Rails.logger.warn "[FTP][VIPS] #{producto.sku}/#{remote_file}: #{e.class}: #{e.message}"
        return
      end

      File.open(webp_tmp, "rb") do |io|
        producto.imagenes.attach(
          io: io,
          filename: webp_name,
          content_type: "image/webp"
        )
      end
      File.delete(webp_tmp) if File.exist?(webp_tmp)
    end
  end
end
# ...existing code...