MnoEnterprise::Engine.routes.draw do
  # Generic routes
  get '/launch/:id', to: 'pages#launch', constraints: {id: /[\w\-\.:]+/}
  get '/loading/:id', to: 'pages#loading', constraints: {id: /[\w\-\.]+/}
  get '/app_access_unauthorized', to: 'pages#app_access_unauthorized'
  get '/billing_details_required', to: 'pages#billing_details_required'
  get '/app_logout', to: 'pages#app_logout'

  # Health Status
  get '/ping', to: 'status#ping'
  get '/version', to: 'status#version'
  get 'health_check(/:checks)(.:format)', to: '/health_check/health_check#index'

  # App Provisioning
  resources :provision, only: [:new, :create]

  # Organization Invites
  resources :org_invites, only: [:show]

  resources :deletion_requests, only: [:show] do
    member do
      patch :freeze_account
      patch :checkout
      put :terminate_account
    end
  end


  get "/impersonate/user/:user_id", to: "impersonate#create", as: :impersonate_user
  get "/impersonate/revert", to: "impersonate#destroy", as: :revert_impersonate_user


  #============================================================
  # Devise/User Configuration
  #============================================================
  # Main devise configuration
  devise_for :users, {
      class_name: "MnoEnterprise::User",
      module: :devise,
      path_prefix: 'auth',
      controllers: {
          confirmations: "mno_enterprise/auth/confirmations",
          #omniauth_callbacks: "auth/omniauth_callbacks",
          passwords: "mno_enterprise/auth/passwords",
          registrations: "mno_enterprise/auth/registrations",
          sessions: "mno_enterprise/auth/sessions",
          unlocks: "mno_enterprise/auth/unlocks"
      }
  }

  # Additional devise routes
  # TODO: routing specs
  devise_scope :user do
    get "/auth/users/confirmation/lounge", to: "auth/confirmations#lounge", as: :user_confirmation_lounge
    patch "/auth/users/confirmation/finalize", to: "auth/confirmations#finalize", as: :user_confirmation_finalize
    patch "/auth/users/confirmation", to: "auth/confirmations#update"
  end

  #============================================================
  # Webhooks
  #============================================================
  namespace :webhook do
    # OAuth Management
    resources :oauth, only: [], constraints: {id: /[\w\-\.:]+/}, controller: "o_auth" do
      member do
        get :authorize
        get :callback
        get :disconnect
        get :sync
      end
    end
  end

  #============================================================
  # JPI V1
  #============================================================
  namespace :jpi do
    namespace :v1 do
      resources :marketplace, only: [:index, :show]
      resource :current_user, only: [:show, :update] do
        put :update_password
        #post :deletion_request, action: :create_deletion_request
        #delete :deletion_request, action: :cancel_deletion_request
      end

      resources :organizations, only: [:index, :show, :create, :update, :destroy] do
        member do
          put :update_billing
          put :invite_members
          put :update_member
          put :remove_member
        end

        # AppInstances
        resources :app_instances, only: [:index, :destroy], shallow: true

        # Teams
        resources :teams, only: [:index, :show, :create, :update, :destroy], shallow: true do
          member do
            put :add_users
            put :remove_users
          end
        end

        resources :app_instances_sync, only: [:create, :index]
      end

      resources :deletion_requests, only: [:show, :create, :destroy] do
        member do
          put :resend
        end
      end

      namespace :impac do
        resources :dashboards, only: [:index, :show, :create, :update, :destroy] do
          resources :widgets, shallow: true, only: [:create, :destroy, :update]
          resources :kpis, shallow: true, only: [:create, :destroy, :update]
        end
      end


      #============================================================
      # Admin
      #============================================================
      namespace :admin, defaults: {format: 'json'} do
        resources :audit_events, only: [:index]
        resources :users, only: [:index, :show, :destroy, :update, :create]
        resources :organizations, only: [:index, :show] do
          collection do
            get :in_arrears
          end
        end
        resources :tenant_invoices, only: [:index, :show]
        resources :invoices, only: [:index, :show] do
          collection do
            get :current_billing_amount
            get :last_invoicing_amount
            get :outstanding_amount
            get :last_commission_amount
            get :last_portfolio_amount
          end
        end
        resources :cloud_apps, only: [:index, :update] do
          member do
            put :regenerate_api_key
            put :refresh_metadata
          end
        end

        # Theme Previewer
        post 'theme/save'
        post 'theme/reset'
        put 'theme/logo'
      end
    end
  end
end
