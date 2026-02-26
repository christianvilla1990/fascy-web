require "net/ftp"

namespace :ftp do
  desc "Probar conexión y listar contenido remoto"
  task debug: :environment do
    host = ENV.fetch("FTP_HOST"); user = ENV.fetch("FTP_USER"); pass = ENV.fetch("FTP_PASS"); base = ENV.fetch("FTP_BASE_DIR")
    Net::FTP.open(host, user, pass) do |ftp|
      ftp.passive = true
      ftp.chdir(base)
      puts "Contenido de #{base}:"
      ftp.nlst(".").each { |e| puts " - #{e}" }
    end
  end

  desc "Importar todas las carpetas SKU y convertir a WebP"
  task importar_webp: :environment do
    host = ENV.fetch("FTP_HOST"); user = ENV.fetch("FTP_USER"); pass = ENV.fetch("FTP_PASS"); base = ENV.fetch("FTP_BASE_DIR")
    before = ActiveStorage::Attachment.where(record_type: "Producto").count
    puts "[INFO] Attachments antes: #{before}"
    importer = FtpImageImporter.new(host: host, user: user, pass: pass, base_dir: base)
    importer.call
    after = ActiveStorage::Attachment.where(record_type: "Producto").count
    puts "[INFO] Attachments después: #{after} (dif=#{after - before})"
    puts "Importación completa."
  end

  desc "Importar solo un SKU (ONLY_SKU=SKU123)"
  task importar_sku: :environment do
    sku  = ENV["ONLY_SKU"] or abort "Falta ONLY_SKU"
    host = ENV.fetch("FTP_HOST"); user = ENV.fetch("FTP_USER"); pass = ENV.fetch("FTP_PASS"); base = ENV.fetch("FTP_BASE_DIR")
    FtpImageImporter.new(host: host, user: user, pass: pass, base_dir: base).import_sku(sku)
    puts "Importado #{sku}."
  end
end