require "pagy"
require "pagy/extras/bootstrap"
require "pagy/extras/i18n"

Pagy::DEFAULT[:items] = 20
# Ensure Pagy links target the Turbo frame used in the index view
Pagy::DEFAULT[:link_extra] = 'data-turbo-frame="productos"'
Pagy::DEFAULT[:size]  = [1, 2, 2, 1]

