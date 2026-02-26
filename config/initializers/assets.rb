# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor")
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor", "bootstrap", "css")
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor", "bootstrap", "js")
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor", "jquery")
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor", "fontawesome", "css")
# Rails.application.config.assets.paths << Rails.root.join("vendor", "vendor", "fontawesome", "webfonts")



# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
	bootstrap.min.css bootstrap.css
	bootstrap.bundle.min.js bootstrap.min.js
	jquery.min.js
	fontawesome.css all.css all.min.css
	*.woff *.woff2 *.ttf *.eot
]
