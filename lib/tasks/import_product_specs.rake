namespace :import do
  desc "Import product descriptions and technical specs from Excel. Usage: rake import:product_specs[file.xlsx]"
  task :product_specs, [:file] => :environment do |t, args|
    require 'roo'
    file = args[:file]
    unless file && File.exist?(file)
      puts "Usage: rake import:product_specs[path/to/file.xlsx]"
      exit 1
    end

    xlsx = Roo::Spreadsheet.open(file)
    sheet = xlsx.sheet(0)
    header = sheet.row(1).map { |h| h.to_s.strip.downcase }

    log_path = Rails.root.join('tmp', "import_product_specs_#{Time.now.strftime('%Y%m%d_%H%M%S')}.log")
    File.open(log_path, 'w') do |log|
      total = 0
      updated = 0
      missing = 0
      errors = 0

      (2..sheet.last_row).each do |i|
        row = Hash[[header, sheet.row(i)].transpose]
        total += 1

        identifier = (row['sku'] || row['external_id'] || row['id']).to_s.strip
        next if identifier.blank?

        producto = nil
        if row['sku'].present?
          producto = Producto.find_by(sku: row['sku'].to_s.strip)
        end
        producto ||= Producto.find_by(external_id: row['external_id'].to_s.strip)
        producto ||= Producto.find_by(id: row['id'].to_i) if row['id'].present?

        if producto.nil?
          missing += 1
          log.puts "Row #{i}: Product not found (sku: #{row['sku']}, external_id: #{row['external_id']})"
          next
        end

        begin
          attrs = {}
          # Normalize descripcion: if it already contains HTML keep it, otherwise convert newlines to paragraphs/BRs
          if row.key?('descripcion')
            raw_desc = row['descripcion'].to_s
            if raw_desc =~ /<[^>]+>/
              attrs[:descripcion] = raw_desc
            else
              attrs[:descripcion] = ActionController::Base.helpers.simple_format(raw_desc)
            end
          end

          # Normalize especificaciones_tecnicas similarly
          if row.key?('especificaciones_tecnicas')
            raw_specs = row['especificaciones_tecnicas'].to_s
            if raw_specs =~ /<[^>]+>/
              attrs[:especificaciones_tecnicas] = raw_specs
            else
              attrs[:especificaciones_tecnicas] = ActionController::Base.helpers.simple_format(raw_specs)
            end
          end

          if attrs.present?
            producto.assign_attributes(attrs)
            if producto.save
              updated += 1
              log.puts "Row #{i}: Updated product id=#{producto.id}"
            else
              errors += 1
              log.puts "Row #{i}: Failed to save product id=#{producto.id} - #{producto.errors.full_messages.join(', ')}"
            end
          else
            log.puts "Row #{i}: No updatable columns present"
          end
        rescue => e
          errors += 1
          log.puts "Row #{i}: Exception for product id=#{producto&.id} - #{e.class}: #{e.message}"
        end
      end

      log.puts "\nSummary: total=#{total}, updated=#{updated}, missing=#{missing}, errors=#{errors}"
      puts "Import finished. Log: #{log_path}"
    end
  end
end
