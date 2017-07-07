MaidDesk::Application.routes.draw do

  constraints(Subdomain) do
    match '/' => 'instant_bookings#new', :via => [:get]
  end

  get '/users/sign_in', :to => redirect('/sign_in')

  # Testing out no cc trial
  get '/sign_up', :to => redirect('/users/sign_up')
  # omniauth callback
  match 'auth/:provider/callback' => 'auth#callback', :via => [:get], :as => :auth_callback
  match 'auth/failure' => 'auth#failure', :via => [:get], :as => :auth_failure
  match 'mailchimp/authenticate' => 'auth#authenticate', :via => [:get], :as => :mailchimp_authenticate
  get '/auth/:action', :to => 'auth#:action'
  match '/auth/create_mailchimp_list', :to => 'auth#create_mailchimp_list', :via => [:post], :as => :create_mailchimp_list

  resources :appointment_service_items

  resources :appointment_fields


  devise_for :employees, :controllers => {:registrations => "employees" }, :skip => [:sessions]
  as :employee do
    get 'sign_in' => 'devise/sessions#new', :as => :new_employee_session
    post 'sign_in' => 'devise/sessions#create', :as => :employee_session
    delete 'sign_out' => 'devise/sessions#destroy', :as => :destroy_employee_session
  end

  devise_scope :employee do
    resources :employees do
      collection { post :route_sheet }
      collection { post :email_work_order }
      collection { post :print_work_order }
      collection { get :dashboard }
      collection { get :edit_my_account }
      member { post :edit_pay_rate }
      member { get :pay_rate }
      member { get :inactivate }
      member { get :reactivate }
    end
    match '/employees/edit_my_account', :to => 'employees#update_my_account', :via => :post
    match '/get_assigned_appts/', to: 'employees#get_assigned_appts', via: :get
    match '/get_predefined_ob/', to: 'employees#get_predefined_ob', via: :get
    root to: 'users#show'
  end

  devise_for :users, :controllers => {:registrations => "users"} 
  
  devise_scope :user do
    resources :users, :only => [:create] do
      collection do
        get :qb_authenticate
        get :qb_oauth_callback
        get :qb_disconnect
        get :quickbooks
      end
    end

    match '/dashboard', to: 'users#show', as: 'user_root'
    match '/billing', to: 'users#billing', via: :get
    match '/mailchimp_setting', to: 'users#mailchimp_setting', via: :get
    match '/billing', to: 'users#create_plan', via: :post
    match '/subscribe_plan', to: 'users#subscribe_plan', via: :post, as: :subscribe_plan
    match '/credit_card_processing', to: 'users#credit_card_processing', as: 'credit_card_processing'
    match '/customized_fields', to: 'users#edit_customized_fields', as: 'customized_fields'
    match '/customer_custom_fields', to: 'users#customer_custom_fields', as: 'customer_custom_fields'
    match '/appointment_custom_fields', to: 'users#appointment_custom_fields', as: 'appointment_custom_fields'
    match '/employee_custom_fields', to: 'users#employee_custom_fields', as: 'employee_custom_fields'
    match '/edit_statuses', to: 'users#edit_statuses', as: 'edit_statuses'
    match '/instruction_custom_fields', to: 'users#instruction_custom_fields', as: 'instruction_custom_fields'
    match '/calendar_options', to: 'users#edit_calendar_options', as: 'calendar_options'
    match '/import_customers', to: 'users#import_customers', as: 'import_customers_page'
    match '/export_customers', to: 'users#export_customers', as: 'export_customers_page'
    match '/teams', to: 'users#edit_teams', as: 'edit_teams'
    match '/instant_booking_fields', to: 'users#instant_booking', as: 'edit_instant_booking_fields'
    match '/revenue_panel', to: 'users#revenue_panel', as: 'revenue_panel'
    match '/systems_week_signup', to: 'users#systems_week_signup', as: 'systems_week_signup', via: :get
    match '/systems_week_signup', to: 'users#systems_week_signup_create', via: :post
    #match '/sign_up', to: 'users#sign_up', via: :get, as: 'flexible_plan_sign_up'
    #match '/sign_up', to: 'users#sign_up_create', via: :post
    root to: 'users#show'
  end


  resources :subscriptions do
    member do
      post :inactivate
      post :adjust
      post :edit_status
    end
  end

  match 'text_work_order' => 'work_orders#text_work_order', :via => :post, :as => :text_work_order

  resources :attached_notes

  resources :customers do
    collection do
      post :import
      post :import_attached_notes
      post :import_appointments
      get :quickbooks_sync
      post :undo_recent_imported_customers
      post :sync_contacts
      post :mailchimp_lists
    end
    
    member do 
      get :recent_activity
      get :manage_credit_cards
      get :inactivate
      get :reactivate
    end
    

  end

  match 'customer_names_and_ids' => 'customers#customer_names_and_ids', :via => :get

  resources :instant_bookings
  match '/instant_bookings/:id/preview' => 'instant_bookings#preview', :via => :get, :as => :preview_instant_booking

  match 'get_started' => 'leads#new', :via => [:get], :as => :new_lead
  match 'get_started' => 'leads#create', :via => [:post], :as => :leads
  match 'launch_landing' => 'leads#launch', :via => [:get], :as => :lead_landing
  match 'leads/sign_up' => 'leads#sign_up', :via => [:post], :as => :sign_up_lead
  match 'launch_thank_you' => 'leads#thank_you'
  match 'launch_sales_letter' => 'leads#sales_letter'

  resources :appointments do
    member { post :update_assignments }
    member { get :edit_time_in_time_out }
    member { get :edit_prototype }
    member { put :update_prototype }
    collection { get :grid }
    collection { get :list }
    collection { post :set_status }
    collection { post :set_paid }
    collection { post :delete_all }
  end

  match '/quality_driven_software_export', to: 'appointments#quality_driven_software_export'
  match '/quality_driven_software_export_process', to: 'appointments#quality_driven_software_export_process'
  
  resources :assignments do 
    member { get :unlink_from_payroll }
    member { get :edit_fixed_rate }
    member { post :update_fixed_rate }
    member { get :edit_revenue_share }
    member { post :update_revenue_share }
    member { get :edit_hourly }
    member { post :update_hourly }
  end

  resources :tasks
  match '/get_tasks', :to => 'tasks#get_tasks', :via => [:get, :post], :as => :get_tasks
  match '/tasks/preview_panel/:id' => 'tasks#preview_panel', :via => :get
  match '/tasks/create_task_panel/:day' => 'tasks#create_task_panel', :via => :get
  match '/update_task_from_calendar/:id' => 'tasks#update_task_from_calendar', :via => [:put], :as => :update_task_from_calendar

  match '/get_appts', :to => 'appointments#get_appts', :via => [:get, :post], :as => :get_appts
  match '/get_appts_grid/', :to => 'appointments#get_appts_grid', :via => [:get, :post], :as => :get_appts_grid
  match '/update_from_calendar/:id' => 'appointments#update_from_calendar', :via => [:put], :as => :update_from_calendar
  match '/edit_location_and_contact_info/:customer_id' => 'appointments#edit_location_and_contact_info', :via => [:put, :post], :as => :edit_location_and_contact_info
  match '/appointments/preview_panel/:id' => 'appointments#preview_panel', :via => :get


  resources :instant_booking_profiles, :only => [:edit, :update]
  match '/embedded_assets/:id' => 'instant_booking_profiles#embedded_assets', :as => :embedded_assets

  resources :email_templates do
    collection { get :new_admin }
  end
  match '/email_templates/:id/preview/', :to => "email_templates#preview", :via => [:get, :post], :as => :preview_email_template
  match '/email_templates/:id/generate', :to => "email_templates#generate", :via => :get, :as => :generate_email
  match '/email_templates/send_generated' => "email_templates#send_generated", :via => :post, :as => :send_generated_email
  match '/email_templates/send_email' => "email_templates#send_email", :via => [:get, :post], :as => :send_email
  match '/email_templates/confirmation_email/:id' => "email_templates#confirmation_email"
  match '/email_templates/prep_mass_email', :to => 'email_templates#prep_mass_email', :via => [:post], :as => :prep_mass_email
  match '/email_templates/send_mass_email', :to => 'email_templates#send_mass_email', :via => [:post], :as => :send_mass_email
  #match '/email_templates/new_admin' => "email_templates#new_admin"

  resources :text_templates, :only => [:edit, :update]
  match '/text_templates/:id/preview/', :to => "text_templates#preview", :via => [:get, :post], :as => :preview_text_template
  match '/text_templates/:id/generate', :to => "text_templates#generate", :via => :get, :as => :generate_text
  match '/text_templates/send_generated', :to => "text_templates#send_generated", :via => :post, :as => :send_generated_text


  devise_for :admins, :skip => [:registrations]
  devise_scope :admin do
    match '/admins/show', to: 'admins#show', as: 'admin_root'
    match '/admins/user_sign_in/:id', to: 'admins#user_sign_in', as: 'admin_user_sign_in'
    match '/admins/user_summary/:user_id', to: 'admins#user_summary', as: 'admin_user_summary'
    match '/admins/manage_user_account/:user_id', to: 'admins#manage_user_account', as: 'manage_user_account'
  end

  resources :addresses, :only => [:new, :create, :show, :destroy]

  resources :payrolls do
    member { get :approve }
    member { get :recalculate }
    member { get :report }
  end

  resources :payroll_entries
  resources :user_profiles
  resources :custom_fields

  resources :credit_cards do
    collection do
      post :process_card
    end
  end

  resources :quickbooks_integrations do

  end

  # OnboardingControllere
  match '/onboarding/user_info', to: 'onboarding#user_info', via: :get, as: :user_info_onboarding
  match '/onboarding/user_info', to: 'onboarding#save_user_info', via: :post
  match '/onboarding/customer_templates', to: 'onboarding#customer_templates', via: :get, as: :customer_templates_onboarding
  match '/onboarding/customer_templates', to: 'onboarding#save_customer_templates', via: :post
  match '/onboarding/custom_fields', to: 'onboarding#custom_fields', via: :get, as: :custom_fields_onboarding
  match '/onboarding/custom_fields', to: 'onboarding#save_custom_fields', via: :post
  match '/onboarding/employee_management', to: 'onboarding#employee_management', via: :get, as: :employee_management_onboarding
  match '/onboarding/employee_management', to: 'onboarding#save_employee_management', via: :post
  match '/onboarding/entrance_survey', to: 'onboarding#entrance_survey', via: :get, as: :entrance_survey
  match '/onboarding/entrance_survey', to: 'onboarding#save_entrance_survey', via: :post
  match '/onboarding/instant_booking', to: 'onboarding#instant_booking_pitch', via: :get, as: :instant_booking_pitch
  match '/exit_survey', to: 'onboarding#exit_survey', via: :get, as: :exit_survey
  match '/exit_survey', to: 'onboarding#save_exit_survey', via: :post

  # StaticPagesController
  match '/help', to: 'static_pages#help'
  match '/about', to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/terms', to: 'static_pages#terms'
  match '/thank_you', to: 'static_pages#thank_you'
  match '/blog', to: redirect("http://zenmaid.wordpress.com/")
  match '/47keywords/', to: redirect("http://zenmaid.wordpress.com/2013/08/06/47-keywords-every-maid-service-must-know-for-google/")

  match '/iframe_test' => 'user_profiles#iframe_test'



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
