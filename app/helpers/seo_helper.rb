module SeoHelper
  SITE_NAME        = "Fascy"
  DEFAULT_TITLE    = "Fascy — Herramientas, productos y soluciones de calidad"
  DEFAULT_DESC     = "En Fascy ofrecemos una amplia variedad de productos de calidad con envíos a todo el país. Conocé nuestras marcas, categorías y sucursales."
  DEFAULT_KEYWORDS = "fascy, herramientas, productos, tienda online, Paraguay, Asunción"
  TWITTER_HANDLE   = "@fascy"
  DEFAULT_IMAGE    = "/icon.png".freeze

  def page_title(raw = nil)
    raw ||= content_for?(:title) ? content_for(:title) : nil
    raw = raw.to_s.strip
    return DEFAULT_TITLE if raw.blank?
    raw.include?(SITE_NAME) ? raw : "#{raw} — #{SITE_NAME}"
  end

  def page_description(raw = nil)
    raw ||= content_for?(:meta_description) ? content_for(:meta_description) : nil
    text = strip_tags(raw.to_s).squish
    text = DEFAULT_DESC if text.blank?
    truncate(text, length: 160, separator: " ")
  end

  def page_image_url(raw = nil)
    raw ||= content_for?(:meta_image) ? content_for(:meta_image) : nil
    raw = raw.to_s.strip
    path = raw.presence || DEFAULT_IMAGE
    return path if path.start_with?("http://", "https://")
    begin
      URI.join(request.base_url, path).to_s
    rescue URI::InvalidURIError
      path
    end
  end

  def canonical_url
    return request.original_url.split("?").first if request.respond_to?(:original_url)
    nil
  end

  def seo_tags
    safe_join([
      tag.meta(charset: "utf-8"),
      tag.meta(name: "description", content: page_description),
      tag.meta(name: "keywords", content: DEFAULT_KEYWORDS),
      tag.meta(name: "robots", content: "index, follow"),
      tag.meta(name: "theme-color", content: "#ffb828"),

      # Open Graph (Facebook, WhatsApp, LinkedIn)
      tag.meta(property: "og:site_name", content: SITE_NAME),
      tag.meta(property: "og:type",      content: "website"),
      tag.meta(property: "og:title",     content: page_title),
      tag.meta(property: "og:description", content: page_description),
      tag.meta(property: "og:url",       content: canonical_url),
      tag.meta(property: "og:image",     content: page_image_url),
      tag.meta(property: "og:locale",    content: "es_PY"),

      # Twitter Cards
      tag.meta(name: "twitter:card",        content: "summary_large_image"),
      tag.meta(name: "twitter:site",        content: TWITTER_HANDLE),
      tag.meta(name: "twitter:title",       content: page_title),
      tag.meta(name: "twitter:description", content: page_description),
      tag.meta(name: "twitter:image",       content: page_image_url),

      tag.link(rel: "canonical", href: canonical_url)
    ], "\n")
  end

  # ============================================
  # JSON-LD structured data helpers
  # ============================================

  # Organization schema — incluir en el home
  def json_ld_organization
    data = {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => SITE_NAME,
      "url" => request.base_url,
      "logo" => page_image_url,
      "description" => DEFAULT_DESC,
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => "Av. Mariscal López 1234",
        "addressLocality" => "Asunción",
        "addressCountry" => "PY"
      },
      "contactPoint" => [{
        "@type" => "ContactPoint",
        "telephone" => "+595-21-209-123",
        "contactType" => "customer service",
        "availableLanguage" => ["Spanish"]
      }],
      "sameAs" => [
        "https://facebook.com/fascy",
        "https://instagram.com/fascy",
        "https://wa.me/595981123456",
        "https://tiktok.com/@fascy",
        "https://youtube.com/@fascy"
      ]
    }
    render_json_ld(data)
  end

  # Product schema — para páginas de detalle de producto
  def json_ld_product(producto)
    return "" unless producto

    images = []
    if producto.respond_to?(:imagenes) && producto.imagenes.attached?
      images = producto.imagenes.map { |img| url_for(img) }
    end
    images = [page_image_url] if images.empty?

    price_num = normalize_price(producto.price)

    data = {
      "@context" => "https://schema.org",
      "@type" => "Product",
      "name" => producto.caracteristica,
      "description" => clean_description(producto.descripcion.presence || producto.datos_tecnicos.presence || producto.caracteristica),
      "image" => images,
      "sku" => producto.sku.presence,
      "mpn" => producto.external_id.presence,
      "brand" => producto.marca ? { "@type" => "Brand", "name" => producto.marca.try(:nombre) || producto.marca.to_s } : nil,
      "category" => producto.categoria&.nombre
    }.compact

    if price_num
      data["offers"] = {
        "@type" => "Offer",
        "priceCurrency" => "PYG",
        "price" => price_num.to_s,
        "availability" => "https://schema.org/InStock",
        "url" => canonical_url,
        "seller" => { "@type" => "Organization", "name" => SITE_NAME }
      }
    end

    render_json_ld(data)
  end

  # BreadcrumbList schema — items es [[nombre, url], ...]
  def json_ld_breadcrumbs(items)
    return "" if items.blank?

    data = {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map { |(name, url), i|
        {
          "@type" => "ListItem",
          "position" => i + 1,
          "name" => name,
          "item" => url
        }
      }
    }
    render_json_ld(data)
  end

  private

  def render_json_ld(data)
    content_tag(:script, raw(data.to_json), type: "application/ld+json")
  end

  def normalize_price(raw)
    return nil if raw.blank?
    str = raw.to_s.strip.gsub(",", ".")
    num = str.to_f
    num.positive? ? num.round(2) : nil
  end

  def clean_description(text)
    return nil if text.blank?
    stripped = strip_tags(text.to_s).squish
    truncate(stripped, length: 500, separator: " ")
  end
end
