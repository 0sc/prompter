class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :allow_iframe_for_fb_domains
  before_action :authenticate_user

  helper_method :current_user, :facebook_key, :facebook_page_id

  protected

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def facebook_key
    ENV.fetch('FACEBOOK_KEY')
  end

  def facebook_page_id
    ENV.fetch('FACEBOOK_PAGE_ID')
  end

  private

  def authenticate_user
    session[:target_page] = request.original_url
    redirect_to root_path unless current_user.present?
  end

  def allow_iframe_for_fb_domains
    origin = session[:iframe_origin] =
               params[:fb_iframe_origin] || session[:iframe_origin]
    allowed = origin.present? ? "ALLOW FROM #{origin}" : 'deny'

    response.set_header('X-Frame-Options', allowed)
  end
end
