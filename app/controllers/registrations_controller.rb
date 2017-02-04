class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:token, :name, :lastname, :email, :password, :password_confirmation, :market)
  end

  def account_update_params
    params.require(:user).permit(:token, :name, :lastname, :email, :password, :password_confirmation, :current_password, :market)
  end

end