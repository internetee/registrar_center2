Rails.application.routes.draw do
  post 'auth/sessions/create', to: 'auth/sessions#create'
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'dashboard#index'

    get 'login', to: 'auth/sessions#new'
    get 'logout', to: 'auth/sessions#destroy'

    match '/auth/tara/callback', via: %i[get post], to: 'auth/tara#callback'
    match '/auth/tara/cancel', via: %i[get post delete], to: 'auth/tara#cancel',
                               as: :tara_cancel

    # Failure mechanism for OmniAuth: if a strategy fails for
    # any reason this endpoint will be invoked. The default behavior
    # is to redirect to `/auth/failure` except in the case of
    # a development `RACK_ENV`, in which case an exception will
    # be raised.
    get '/auth/failure', to: 'auth/tara#cancel'

    get 'dashboard', to: 'dashboard#index', as: :dashboard

    post 'domains/update', to: 'domains#update', as: :update_domain
    get 'domains/delete', to: 'domains#delete', as: :delete_domain
    get 'domain', to: 'domains#show', as: :domain
    get 'domain/edit', to: 'domains#edit', as: :edit_domain
    get 'domain_transfers/new', to: 'domains#new_transfer', as: :new_domain_transfer
    get 'domains/new_renewal', to: 'domains#new_renewal', as: :new_domain_renewal
    get 'domains/new_bulk_change', to: 'domains#new_bulk_change', as: :new_domain_bulk_change
    post 'domains/transfer', to: 'domains#transfer', as: :domain_transfer
    post 'domains/renew', to: 'domains#renew', as: :domain_renew
    delete 'domains/destroy', to: 'domains#destroy', as: :destroy_domain
    resources :domains, except: %i[destroy update show edit]

    resources :bulk_change, only: %i[show update], controller: 'steps_controllers/bulk_change'
    get 'steps_controllers/bulk_change/cancel', to: 'steps_controllers/bulk_change#cancel',
                                                as: :cancel_wizard
    post 'bulk_actions/contact_replace', to: 'bulk_actions#contact_replace',
                                         as: :contact_bulk_replace
    post 'bulk_actions/admin_contact_replace', to: 'bulk_actions#admin_contact_replace',
                                               as: :admin_contact_bulk_replace
    post 'bulk_actions/nameserver_change', to: 'bulk_actions#nameserver_change',
                                           as: :nameserver_bulk_change
    post 'bulk_actions/domain_renew', to: 'bulk_actions#domain_renew',
                                      as: :domain_bulk_renew

    get 'contacts/search(/:id)', to: 'contacts#search'
    get 'contact', to: 'contacts#show', as: :contact
    get 'contact/edit', to: 'contacts#edit', as: :edit_contact
    post 'contacts/update', to: 'contacts#update', as: :update_contact
    get 'contact/delete', to: 'contacts#delete', as: :delete_contact
    delete 'contacts/destroy', to: 'contacts#destroy', as: :destroy_contact
    resources :contacts, except: %i[destroy update show edit]

    get 'invoices/:id/download', to: 'invoices#download', as: :download_invoice
    post 'invoices/cancel', to: 'invoices#cancel', as: :cancel_invoice
    post 'invoices/add_credit', to: 'invoices#add_credit', as: :add_credit
    post 'invoices/pay', to: 'invoices#pay', as: :pay
    get 'invoices/callback', to: 'invoices#callback', as: :callback
    post 'invoices/send_to_recipient', to: 'invoices#send_to_recipient', as: :send_invoice
    resources :invoices, only: %i[index show]

    get 'account/activities', to: 'account#index', as: :account_activities
    post 'account/update_balance_auto_reload', to: 'account#update_balance_auto_reload',
                                               as: :update_balance_auto_reload
    get 'account/disable_balance_auto_reload', to: 'account#disable_balance_auto_reload',
                                               as: :disable_balance_auto_reload
    post 'account/switch_user', to: 'account#switch_user', as: :switch_user
    resource :account, controller: :account, only: %i[show update]

    get 'notifications/:id/mark_as_read', to: 'notifications#mark_as_read',
                                          as: :mark_as_read_notification
  end
end
