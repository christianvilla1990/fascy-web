class Dashboard::BannersController < Dashboard::BaseController
  before_action :set_banner, only: [:edit, :update, :destroy]

  def index
    @banners = Banner.all.where(tipo: ['principal']).order(:created_at)
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to dashboard_banners_path, notice: "Banner creado exitosamente."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @banner.update(banner_params)
      redirect_to dashboard_banners_path, notice: "Banner actualizado."
    else
      render :edit
    end
  end

  def destroy
    @banner.destroy
    redirect_to dashboard_banners_path, notice: "Banner eliminado."
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(:titulo, :descripcion, :tipo, :link, :imagen)
  end
end
