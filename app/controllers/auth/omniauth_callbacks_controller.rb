# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

=begin
  def self.provides_callback_for(provider)
    provider_id = provider.to_s.chomp '_oauth2'

    define_method provider do
      @user = User.find_for_oauth(request.env['omniauth.auth'], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_id.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end

  Devise.omniauth_configs.each_key do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      root_path
    else
      finish_signup_path
    end
  end
=end

  concerning :Qiitadon do
    included do
      include AfterSignInPathLeadable

      # Overload existing callback implementation.
      def qiita
        auth_hash = request.env['omniauth.auth']

        qiita_authorization = QiitaAuthorization.find_or_initialize_by(uid: auth_hash[:uid]) do |qiita_authorization|
          qiita_authorization.token = auth_hash[:credentials][:token]
        end

        if current_user
          if qiita_authorization.new_record?
            associate_qiita_account_with_current_user(qiita_authorization)
          else
            redirect_to after_sign_in_path_for(current_user)
          end
        else
          if qiita_authorization.user
            sign_in_and_redirect qiita_authorization.user, event: :authentication
          else
            store_omniauth_data
            redirect_to new_user_oauth_registration_path
          end
        end
      end

      private

      # @param qiita_authorization [QiitaAuthorization]
      def associate_qiita_account_with_current_user(qiita_authorization)
        fail Mastodon::NotPermittedError if qiita_authorization.user.present? && qiita_authorization.user_id != current_user.id

        qiita_authorization.user = current_user
        if qiita_authorization.save!
          flash[:notice] = I18n.t('qiitadon.omniauth_callbacks.success')
        else
          flash[:alert] = I18n.t('qiitadon.omniauth_callbacks.failure')
        end

        redirect_to after_sign_in_path_for(current_user)
      end

      def store_omniauth_data
        session[:devise_omniauth_auth] = request.env['omniauth.auth']
        session[:devise_omniauth_origin] = request.env['omniauth.origin']
      end

      def location_after_sign_in
        request.env['omniauth.origin'].presence || stored_location_for(:user)
      end
    end
  end
end
