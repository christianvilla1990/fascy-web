module ApplicationHelper
    include Pagy::Frontend

    def site_logo_tag(variant: :desktop, **html_options)
      setting = SiteSetting.current
      attachment = (variant == :mobile && setting.logo_mobile.attached?) ? setting.logo_mobile : setting.logo
      alt = setting.nombre_sitio.presence || "Fascy"

      if attachment.attached?
        image_tag attachment, alt: alt, **html_options
      else
        image_tag asset_path("slides/marca.jpg"), alt: alt, **html_options
      end
    rescue => e
      Rails.logger.warn("[site_logo_tag] #{e.message}")
      image_tag asset_path("slides/marca.jpg"), alt: "Fascy", **html_options
    end

    # Renderiza un texto largo (descripción / especificaciones técnicas).
    # - Si parece tener formato "clave: valor" (la mayoría de las líneas),
    #   lo muestra como tabla prolija.
    # - Si tiene HTML, lo sanitiza.
    # - Si es texto plano sin estructura, usa simple_format.
    def render_rich_text(text, table_threshold: 0.6)
      return content_tag(:p, "Sin información disponible.", class: "pd-tabs__empty") if text.blank?

      plain_lines = strip_tags(text).split(/\r?\n/).map(&:strip).reject(&:blank?)
      kv_lines = plain_lines.select { |l| l =~ /\A[^:]{1,60}:\s*.+\z/ }

      if plain_lines.size >= 2 && kv_lines.size.to_f / plain_lines.size >= table_threshold
        rows = kv_lines.map do |line|
          key, val = line.split(":", 2)
          [key.strip, val.strip]
        end
        render_specs_table(rows)
      elsif text =~ /<[^>]+>/
        sanitize(text)
      else
        simple_format(text)
      end
    end

    def render_specs_table(rows)
      content_tag(:table, class: "specs-table") do
        rows.map do |key, val|
          content_tag(:tr) do
            concat content_tag(:th, key)
            concat content_tag(:td, val)
          end
        end.join.html_safe
      end
    end
end
