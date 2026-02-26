class Dashboard::BaseController < ApplicationController
  layout "dashboard"
  include Pagy::Backend

  http_basic_authenticate_with(
    name: ENV.fetch("ADMIN_USER", "admin"),
    password: ENV.fetch("ADMIN_PASSWORD", "admin123")
  )
end