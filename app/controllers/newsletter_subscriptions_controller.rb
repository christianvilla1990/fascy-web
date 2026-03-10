class NewsletterSubscriptionsController < ApplicationController
  def create
    @subscription = NewsletterSubscription.new(subscription_params)
    if @subscription.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Gracias por suscribirte al boletín." }
        format.turbo_stream { render partial: "home/newsletter_success", locals: { subscription: @subscription } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: @subscription.errors.full_messages.to_sentence }
        format.turbo_stream { render partial: "home/newsletter_form", locals: { subscription: @subscription } }
      end
    end
  end

  private

  def subscription_params
    params.require(:newsletter_subscription).permit(:email)
  end
end
