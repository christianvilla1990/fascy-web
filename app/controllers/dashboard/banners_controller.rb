class Dashboard::BannersController < Dashboard::BaseController
  before_action :set_banner, only: [:edit, :update, :destroy]

  def index
    @q = params[:q].to_s.strip
    @tipo = params[:tipo].to_s.strip
    scope = Banner.order(created_at: :desc)
    scope = scope.where("LOWER(titulo) LIKE ?", "%#{@q.downcase}%") if @q.present?
    scope = scope.where(tipo: @tipo) if @tipo.present?
    per_page = params[:per_page].to_i
    per_page = 20 if per_page <= 0 || per_page > 100
    @pagy, @banners = pagy(scope, items: per_page)
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
    params.require(:banner).permit(:titulo, :descripcion, :tipo, :link, :imagen, :imagen_mobile)
  end
end
