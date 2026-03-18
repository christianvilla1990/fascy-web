class Dashboard::BaseController < ApplicationController
  layout "dashboard"
  include Pagy::Backend
  before_action :authenticate_admin_user!
end