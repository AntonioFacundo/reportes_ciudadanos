Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  root "home#index"
  resource :session
  resources :passwords, param: :token

  resources :reports, only: %i[index new create show] do
    member do
      patch :mark_read
      patch :assign
      patch :resolve
      patch :reject_resolution
      patch :accept_resolution
      patch :force_transition
    end
  end
  get "inbox", to: "inbox#index", as: :inbox

  resources :alcaldias, only: [] do
    member do
      get :boundary
      get :categories
    end
  end

  namespace :admin do
    get "/", to: "dashboard#index", as: :root
    resources :states, except: %i[show]
    resources :alcaldias, except: %i[show], path: "alcaldias" do
      collection do
        get :by_state
      end
    end
    resources :categories, except: %i[show]
    resources :users, only: %i[index new create edit update], path: "users" do
      member do
        patch :deactivate
        post :impersonate
      end
    end
    delete "impersonate", to: "users#stop_impersonating", as: :stop_impersonating
    resources :citizens, only: %i[index show edit update], path: "citizens" do
      member do
        patch :deactivate
        patch :reactivate
      end
    end
    resources :audit_logs, only: %i[index], path: "audit"
    get "analytics", to: "analytics#index", as: :analytics
    get "exports/reportes.pdf", to: "exports#reportes_pdf", as: :export_reportes_pdf
    get "exports/reportes.xlsx", to: "exports#reportes_xlsx", as: :export_reportes_xlsx
    get "exports/analytics.pdf", to: "exports#analytics_pdf", as: :export_analytics_pdf
    get "exports/ejecutivo.pdf", to: "exports#ejecutivo_pdf", as: :export_ejecutivo_pdf
    get "exports/rendicion_cuentas.pdf", to: "exports#rendicion_cuentas_pdf", as: :export_rendicion_cuentas_pdf
    resources :snapshots, only: %i[index], path: "snapshots" do
      collection do
        post :capture
      end
    end
  end

  resources :notifications, only: %i[index], path: "notifications" do
    member do
      patch :mark_read
    end
  end

  resource :push_subscriptions, only: %i[create destroy], path: "push_subscriptions" do
    get :vapid_public_key, on: :member, path: "vapid_public_key"
  end

  namespace :api do
    get  "whatsapp/verify",  to: "whatsapp#verify"
    post "whatsapp/receive",  to: "whatsapp#receive"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    get "dev/broadcast_report/:id", to: "dev/broadcasts#report", as: :dev_broadcast_report
  end
end
