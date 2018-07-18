class UsersController < ApplicationController
  skip_before_action :authenticate_user
  before_action :ensure_valid_user, only: :account_link
  before_action :set_session_variables, only: :account_link
  before_action :duplicate_account_check, only: :create
  after_action :clear_session, if: -> { account_linking? }, only: :create

  def new
    redirect_to communities_path if current_user
  end

  def create
    current_user.update_from_auth_hash(auth_hash)

    if current_user.save
      session[:user_id] = current_user.id
      redirect_to success_redirect_uri,
                  notice: t('.success', name: current_user.name)
    else
      handle_oauth_failure
    end
  end

  def account_link
    redirect_to '/auth/facebook'
  end

  def failed
    handle_oauth_failure
  end

  # TODO: This is not secure
  # revisit asap
  def login
    user = User.find_by(psid: params[:id])
    session[:user_id] = user.id if user.present?
    redirect_to(session[:target_page] || root_path)
  end

  def logout
    session.clear
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  private

  def ensure_valid_user
    @current_user = User.find_by(psid: params[:psid])
    redirect_to root_path unless current_user.present?
  end

  def set_session_variables
    session[:alt] = params['account_linking_token']
    session[:rdr] = params['redirect_uri']
    session[:user_id] = current_user.id
  end

  def duplicate_account_check
    potential_account = User.find_or_initialize_by(fbid: auth_hash[:uid])

    if current_user.present? && current_user != potential_account
      User.combine_accounts!(potential_account, current_user)
    end

    @current_user = potential_account
  end

  def success_redirect_uri
    if account_linking?
      "#{session[:rdr]}&authorization_code=account-linked-successfully"
    else
      communities_path
    end
  end

  def handle_oauth_failure
    redirect_to failed_redirect_uri, notice: t('users.failed')
  end

  def failed_redirect_uri
    account_linking? ? session[:rdr] : root_path
  end

  def account_linking?
    session[:rdr].present?
  end

  def clear_session
    # session.clear
    %i[alt rdr].each { |key| session.delete(key) }
  end
end
