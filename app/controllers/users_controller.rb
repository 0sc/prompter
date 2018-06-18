class UsersController < ApplicationController
  skip_before_action :authenticate_user

  def new; end

  def create
    user = User.find_or_initialize_by(fbid: auth_hash[:uid])
    user.update_from_auth_hash(auth_hash)

    if user.save
      session[:user_id] = user.id
      redirect_to communities_path, notice: "Welcome #{user.name}"
    else
      redirect_to root_path, notice: 'Error occured setting up your account!!'
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
