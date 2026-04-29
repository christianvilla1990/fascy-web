class Dashboard::SiteSettingsController < Dashboard::BaseController
  def edit
    @site_setting = SiteSetting.current
  end

  def update
    @site_setting = SiteSetting.current
    if @site_setting.update(site_setting_params)
      redirect_to edit_dashboard_site_setting_path, notice: "Configuración actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def site_setting_params
    params.require(:site_setting).permit(:nombre_sitio, :logo, :logo_mobile)
  end
end
