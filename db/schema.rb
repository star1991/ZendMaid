# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160427112558) do

  create_table "addresses", :force => true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.string   "state",            :limit => 2
    t.string   "postal_code"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.boolean  "billing",                       :default => false
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "appointment_fields", :force => true do |t|
    t.string   "field_name"
    t.string   "input_type"
    t.decimal  "price",            :precision => 8, :scale => 2
    t.integer  "max_field_value"
    t.integer  "min_field_value",                                :default => 1
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "order",                                          :default => 1,     :null => false
    t.boolean  "active",                                         :default => true
    t.boolean  "extra",                                          :default => true
    t.text     "value_names"
    t.integer  "pricing_table_id"
    t.boolean  "display_label",                                  :default => true
    t.integer  "service_type_id"
    t.boolean  "show_in_table",                                  :default => false
    t.integer  "user_id"
    t.boolean  "unique",                                         :default => false
    t.boolean  "show_in_preview",                                :default => false
  end

  add_index "appointment_fields", ["service_type_id"], :name => "index_appointment_fields_on_service_type_id"
  add_index "appointment_fields", ["show_in_preview"], :name => "index_appointment_fields_on_show_in_preview"
  add_index "appointment_fields", ["show_in_table"], :name => "index_appointment_fields_on_show_in_table"
  add_index "appointment_fields", ["user_id"], :name => "index_appointment_fields_on_user_id"

  create_table "appointment_items", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "appointment_field_id"
    t.text     "value_name"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "appointment_items", ["appointment_field_id"], :name => "index_appointment_items_on_appointment_field_id"
  add_index "appointment_items", ["appointment_id"], :name => "index_appointment_items_on_appointment_id"

  create_table "appointment_service_items", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "instruction_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "value_name"
    t.string   "field_name"
  end

  add_index "appointment_service_items", ["appointment_id"], :name => "index_appointment_service_items_on_appointment_id"
  add_index "appointment_service_items", ["instruction_id"], :name => "index_appointment_service_items_on_instruction_id"

  create_table "appointments", :force => true do |t|
    t.integer  "subscription_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "paid",                                            :default => false
    t.boolean  "cancelled",                                       :default => false
    t.boolean  "assigned",                                        :default => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.text     "requests"
    t.boolean  "confirmed",                                       :default => false
    t.decimal  "price",             :precision => 8, :scale => 2
    t.text     "notes"
    t.integer  "service_type_id"
    t.boolean  "use_as_prototype",                                :default => false
    t.integer  "status_id"
    t.integer  "assignments_count",                               :default => 0
    t.integer  "team_id"
    t.text     "sent_on"
    t.integer  "payroll_id"
  end

  add_index "appointments", ["payroll_id"], :name => "index_appointments_on_payroll_id"
  add_index "appointments", ["service_type_id"], :name => "index_appointments_on_service_type_id"
  add_index "appointments", ["start_time"], :name => "index_appointments_on_start_time"
  add_index "appointments", ["status_id"], :name => "index_appointments_on_status_id"
  add_index "appointments", ["subscription_id"], :name => "index_appointments_on_subscription_id"
  add_index "appointments", ["team_id"], :name => "index_appointments_on_team_id"

  create_table "assignments", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "employee_id"
    t.string   "role"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.datetime "work_order_sent_on"
    t.datetime "time_in"
    t.datetime "time_out"
    t.boolean  "set_manually",                                     :default => false
    t.integer  "payroll_entry_id"
    t.decimal  "job_wage",           :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "extras",             :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "total",              :precision => 8, :scale => 2, :default => 0.0
    t.string   "pay_type"
    t.decimal  "pay_rate"
  end

  add_index "assignments", ["appointment_id"], :name => "index_assignments_on_appointment_id"
  add_index "assignments", ["employee_id", "appointment_id"], :name => "index_assignments_on_associations", :unique => true
  add_index "assignments", ["employee_id"], :name => "index_assignments_on_employee_id"
  add_index "assignments", ["payroll_entry_id"], :name => "index_assignments_on_payroll_entry_id"

  create_table "attached_notes", :force => true do |t|
    t.text     "body"
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "attached_notes", ["noteable_id", "noteable_type"], :name => "index_attached_notes_on_noteable_id_and_noteable_type"

  create_table "auths", :force => true do |t|
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.integer  "user_id"
    t.string   "provider"
    t.string   "dc"
    t.string   "list_id"
    t.string   "name"
    t.string   "provider_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "auths", ["user_id"], :name => "index_auths_on_user_id"

  create_table "credit_cards", :force => true do |t|
    t.integer  "customer_id"
    t.string   "masked_card_number"
    t.integer  "expiry_month"
    t.integer  "expiry_year"
    t.text     "token"
    t.string   "card_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "credit_cards", ["customer_id"], :name => "index_credit_cards_on_customer_id"

  create_table "custom_fields", :force => true do |t|
    t.integer  "user_id"
    t.string   "field_name"
    t.string   "input_type"
    t.text     "value_names"
    t.integer  "order"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.integer  "min_field_value",                                   :default => 1
    t.integer  "max_field_value"
    t.string   "field_type"
    t.integer  "service_type_id"
    t.decimal  "price",               :precision => 8, :scale => 2
    t.text     "default"
    t.integer  "pricing_table_id"
    t.boolean  "show_in_table",                                     :default => false
    t.boolean  "unique",                                            :default => false
    t.boolean  "show_in_preview",                                   :default => false
    t.boolean  "hide_from_employees",                               :default => false
  end

  add_index "custom_fields", ["field_type"], :name => "index_customer_fields_on_field_type"
  add_index "custom_fields", ["pricing_table_id"], :name => "index_custom_fields_on_pricing_table_id"
  add_index "custom_fields", ["service_type_id"], :name => "index_custom_fields_on_service_type_id"
  add_index "custom_fields", ["user_id"], :name => "index_customer_fields_on_user_id"

  create_table "custom_items", :force => true do |t|
    t.integer  "customizable_id"
    t.integer  "custom_field_id"
    t.text     "value_name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "customizable_type"
  end

  add_index "custom_items", ["custom_field_id"], :name => "index_customer_items_on_custom_field_id"
  add_index "custom_items", ["customizable_type", "customizable_id"], :name => "index_custom_items_on_polymorphic"

  create_table "customers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "user_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.boolean  "active",                                            :default => true
    t.string   "company_name"
    t.string   "title"
    t.text     "sent_on"
    t.text     "notes"
    t.decimal  "balance",            :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "revenue",            :precision => 10, :scale => 2, :default => 0.0
    t.string   "stripe_customer_id"
    t.boolean  "lead",                                              :default => true
    t.integer  "qb_customer_id"
    t.boolean  "imported",                                          :default => false
    t.string   "marketing_source"
  end

  add_index "customers", ["active"], :name => "index_customers_on_active"
  add_index "customers", ["qb_customer_id"], :name => "index_customers_on_qb_customer_id"
  add_index "customers", ["user_id"], :name => "index_customers_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "email_templates", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "body"
    t.string   "template_type"
    t.boolean  "active",            :default => true
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "time_offset"
    t.text     "preferences"
    t.string   "template_resource", :default => "Appointment"
    t.boolean  "marketing_plan",    :default => false
    t.boolean  "mass_email",        :default => false
  end

  add_index "email_templates", ["template_resource"], :name => "index_email_templates_on_template_resource"
  add_index "email_templates", ["template_type"], :name => "index_email_templates_on_template_type"
  add_index "email_templates", ["user_id"], :name => "index_email_templates_on_user_id"

  create_table "emails", :force => true do |t|
    t.string   "address"
    t.string   "email_type"
    t.boolean  "primary"
    t.boolean  "send_automated", :default => true
    t.integer  "emailable_id"
    t.string   "emailable_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "emails", ["emailable_id", "emailable_type"], :name => "index_emails_polymorphic"

  create_table "employees", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.integer  "user_id"
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
    t.text     "notes"
    t.string   "calendar_color",                                                      :default => "#026b9c"
    t.string   "encrypted_password",     :limit => 128,                               :default => "",        :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "allow_sign_in",                                                       :default => false
    t.boolean  "show_in_grid",                                                        :default => true
    t.string   "pay_type"
    t.decimal  "pay_rate",                              :precision => 8, :scale => 2
    t.boolean  "active",                                                              :default => true
    t.datetime "inactivated_on"
    t.boolean  "owner",                                                               :default => false
    t.boolean  "assignable",                                                          :default => true
    t.boolean  "admin",                                                               :default => false
    t.boolean  "allow_enter_time",                                                    :default => false
  end

  add_index "employees", ["user_id"], :name => "index_employees_on_user_id"

  create_table "import_request_files", :force => true do |t|
    t.string   "file"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "instant_booking_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "subdomain"
    t.integer  "advance_booking_days",       :default => 1
    t.integer  "default_appointment_length", :default => 3
    t.boolean  "embed",                      :default => false
    t.text     "custom_css"
    t.text     "about_us"
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
    t.boolean  "show_price",                 :default => true
    t.boolean  "show_about_us",              :default => true
    t.boolean  "compact",                    :default => false
    t.text     "font_urls"
    t.string   "button_color_class"
    t.string   "call_to_action",             :default => "Book your Cleaning Instantly in 3 Easy Steps"
    t.text     "time_options"
    t.text     "skip_days"
  end

  add_index "instant_booking_profiles", ["subdomain"], :name => "index_instant_booking_profiles_on_subdomain", :unique => true
  add_index "instant_booking_profiles", ["user_id"], :name => "index_instant_booking_profiles_on_user_id", :unique => true

  create_table "instant_bookings", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "start_time"
    t.decimal  "price",           :precision => 8, :scale => 2
    t.integer  "service_type_id"
    t.text     "requests"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.boolean  "pending",                                       :default => true
    t.integer  "appointment_id"
  end

  add_index "instant_bookings", ["pending"], :name => "index_instant_bookings_on_pending"
  add_index "instant_bookings", ["service_type_id"], :name => "index_instant_bookings_on_service_type_id"

  create_table "instructions", :force => true do |t|
    t.integer  "user_id"
    t.string   "field_name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "instructions", ["user_id"], :name => "index_instructions_on_user_id"

  create_table "leads", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "company_name"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "stripe_customer_token"
    t.string   "plan_id"
  end

  create_table "log_entries", :force => true do |t|
    t.integer  "appointment_id"
    t.string   "log_type"
    t.text     "entry"
    t.text     "note"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "log_entries", ["appointment_id"], :name => "index_log_entries_on_appointment_id"
  add_index "log_entries", ["created_at"], :name => "index_log_entries_on_created_at"

  create_table "payment_gateways", :force => true do |t|
    t.integer  "user_id"
    t.string   "gateway_name",   :default => "Stripe"
    t.text     "stripe_api_key"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "payment_gateways", ["user_id"], :name => "index_payment_gateways_on_user_id"

  create_table "payroll_assignments", :force => true do |t|
    t.datetime "appointment_start_time"
    t.text     "customer_name"
    t.integer  "payroll_entry_id"
    t.datetime "time_in"
    t.datetime "time_out"
    t.decimal  "job_wage",               :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "extras",                 :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "total",                  :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "appointment_revenue",    :precision => 8, :scale => 2, :default => 0.0
    t.string   "pay_type"
    t.decimal  "pay_rate",               :precision => 8, :scale => 2
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
  end

  add_index "payroll_assignments", ["payroll_entry_id"], :name => "index_payroll_assignments_on_payroll_entry_id"

  create_table "payroll_entries", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "payroll_id"
    t.decimal  "wage",              :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "bonus",             :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "deductions",        :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "total_pay",         :precision => 8, :scale => 2, :default => 0.0
    t.integer  "assignments_count",                               :default => 0
    t.string   "pay_type"
    t.decimal  "pay_rate",          :precision => 8, :scale => 2
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.boolean  "draft",                                           :default => true
    t.string   "full_name"
  end

  add_index "payroll_entries", ["employee_id"], :name => "index_payroll_entries_on_employee_id"
  add_index "payroll_entries", ["payroll_id"], :name => "index_payroll_entries_on_payroll_id"

  create_table "payrolls", :force => true do |t|
    t.integer  "user_id"
    t.integer  "payroll_number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "draft",                                               :default => true
    t.decimal  "total_pay",             :precision => 8, :scale => 2, :default => 0.0
    t.integer  "appointments_count",                                  :default => 0
    t.integer  "payroll_entries_count",                               :default => 0
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "out_of_date",                                         :default => false
  end

  add_index "payrolls", ["user_id"], :name => "index_payrolls_on_user_id"

  create_table "phone_numbers", :force => true do |t|
    t.string   "phone_number"
    t.string   "phone_number_type"
    t.boolean  "primary",               :default => false
    t.integer  "phone_numberable_id"
    t.string   "phone_numberable_type"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "phone_numbers", ["phone_numberable_id", "phone_numberable_type"], :name => "index_phone_numbers_polymorphic"

  create_table "pricing_tables", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "pricing_table"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "custom_field_ids"
  end

  add_index "pricing_tables", ["user_id"], :name => "index_pricing_tables_on_user_id"

  create_table "service_types", :force => true do |t|
    t.integer  "user_id",                                                         :null => false
    t.string   "name"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.decimal  "base_price",      :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "show_in_booking",                               :default => true
  end

  add_index "service_types", ["user_id"], :name => "index_service_types_on_user_id"

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "order"
    t.string   "calendar_color",      :default => "#026b9c"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "show_by_default",     :default => true
    t.boolean  "use_for_conflicts",   :default => true
    t.boolean  "show_in_work_orders", :default => true
    t.boolean  "use_for_payroll",     :default => true
    t.boolean  "use_for_invoice"
  end

  add_index "statuses", ["show_in_work_orders"], :name => "index_statuses_on_show_in_work_orders"
  add_index "statuses", ["use_for_conflicts"], :name => "index_statuses_on_use_for_conflicts"
  add_index "statuses", ["use_for_payroll"], :name => "index_statuses_on_use_for_payroll"
  add_index "statuses", ["user_id"], :name => "index_statuses_on_user_id"

  create_table "subscriptions", :force => true do |t|
    t.datetime "start_time",                              :null => false
    t.datetime "end_time",                                :null => false
    t.boolean  "active",                :default => true
    t.integer  "interval"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "frequency"
    t.datetime "materialized_until"
    t.text     "constraints"
    t.text     "repeat_on"
    t.integer  "subscriptionable_id"
    t.string   "subscriptionable_type"
    t.integer  "parent_id"
    t.string   "title"
  end

  add_index "subscriptions", ["parent_id"], :name => "index_subscriptions_on_parent_id"
  add_index "subscriptions", ["start_time"], :name => "index_subscriptions_on_start_time"
  add_index "subscriptions", ["subscriptionable_type", "subscriptionable_id"], :name => "index_subscriptions_polymorphic_associations"

  create_table "task_recurrences", :force => true do |t|
    t.text     "schedule"
    t.integer  "user_id"
    t.text     "task"
    t.text     "note"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "task_recurrences", ["user_id"], :name => "index_task_recurrences_on_user_id"

  create_table "tasks", :force => true do |t|
    t.integer  "user_id"
    t.text     "task"
    t.text     "note"
    t.date     "due_date"
    t.date     "completed_on"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "task_recurrence_id"
  end

  add_index "tasks", ["task_recurrence_id"], :name => "index_tasks_on_task_recurrence_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "teams", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "calendar_color", :default => "#026b9c"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "teams", ["user_id"], :name => "index_teams_on_user_id"

  create_table "teams_employees", :force => true do |t|
    t.integer  "team_id"
    t.integer  "employee_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "teams_employees", ["employee_id"], :name => "index_teams_employees_on_employee_id"
  add_index "teams_employees", ["team_id"], :name => "index_teams_employees_on_team_id"

  create_table "template_jobs", :force => true do |t|
    t.datetime "scheduled_on"
    t.datetime "sent_on"
    t.integer  "sendable_id"
    t.string   "sendable_type"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "template_jobs", ["reportable_id", "reportable_type"], :name => "index_template_jobs_on_reportable_id_and_reportable_type"
  add_index "template_jobs", ["scheduled_on"], :name => "index_template_jobs_on_scheduled_on"
  add_index "template_jobs", ["sendable_id", "sendable_type"], :name => "index_template_jobs_on_sendable_id_and_sendable_type"

  create_table "text_templates", :force => true do |t|
    t.text     "body"
    t.string   "template_type"
    t.integer  "user_id"
    t.integer  "time_offset"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "preferences"
  end

  add_index "text_templates", ["user_id"], :name => "index_text_templates_on_user_id"

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "company_email"
    t.string   "company_phone_number"
    t.string   "company_name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "logo"
    t.text     "website"
    t.text     "facebook_page"
    t.text     "why_sign_up"
    t.text     "current_management"
    t.text     "specific_features"
    t.text     "struggles"
    t.text     "why_leaving"
    t.text     "previous_system"
    t.text     "intented_new_system"
    t.text     "required_specific_feature"
    t.integer  "recommendation"
    t.text     "other_feedback"
    t.text     "where_hear_about_us"
  end

  add_index "user_profiles", ["user_id"], :name => "index_user_profiles_on_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                                   :default => "",    :null => false
    t.string   "encrypted_password",                                      :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.string   "phone_number"
    t.string   "plan_id"
    t.string   "stripe_customer_token"
    t.text     "preferences"
    t.boolean  "marketing_plan",                                          :default => false
    t.string   "company_name"
    t.integer  "last_used_payroll_number",                                :default => 0
    t.boolean  "active",                                                  :default => true
    t.boolean  "completed_onboarding",                                    :default => false
    t.integer  "onboarding_page",                                         :default => 1
    t.boolean  "allow_employee_sign_in",                                  :default => false
    t.string   "default_employee_password"
    t.string   "default_pay_type"
    t.decimal  "default_pay_rate",          :precision => 8, :scale => 2
    t.datetime "free_trial_end"
    t.boolean  "allow_cc_processing",                                     :default => false
    t.boolean  "booking_form_started",                                    :default => false
    t.string   "qb_access_token"
    t.string   "qb_access_secret"
    t.string   "qb_company_id"
    t.datetime "qb_token_expires_at"
    t.datetime "qb_reconnect_token_at"
    t.boolean  "qb_syncing",                                              :default => false
    t.datetime "qb_last_sync"
    t.datetime "converted_at"
    t.datetime "mailchimp_last_sync"
    t.boolean  "mailchimp_syncing",                                       :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
