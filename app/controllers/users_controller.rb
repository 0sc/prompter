class UsersController < ApplicationController
  def new; end

  def create
    user = User.find_or_initialize_by(fbid: auth_hash[:uid])
    user.update_from_auth_hash(auth_hash)

    if user.save
      session[:user_id] = user.id
      notice = "Welcome #{user.first_name}"
      redirect_to communities_path
    else
      notice = 'Error occured while setting up your account!!'
      redirect_to root_path
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
