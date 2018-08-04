class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def after_sign_in_path_for(resource)
    users_path
  end
  def after_sign_up_path_for(resource)
    user_path(current_user.id)
  end
end
