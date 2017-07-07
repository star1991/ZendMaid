# == Schema Information
#
# Table name: custom_fields
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  field_name          :string(255)
#  input_type          :string(255)
#  value_names         :text
#  order               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  min_field_value     :integer          default(1)
#  max_field_value     :integer
#  field_type          :string(255)
#  service_type_id     :integer
#  price               :decimal(8, 2)
#  default             :text
#  pricing_table_id    :integer
#  show_in_table       :boolean          default(FALSE)
#  unique              :boolean          default(FALSE)
#  show_in_preview     :boolean          default(FALSE)
#  hide_from_employees :boolean          default(FALSE)
#

class CustomField < ActiveRecord::Base
  attr_accessible :field_name, :field_type, :input_type, :order, :user_id, :value_names, :max_field_value, :min_field_value, :service_type_id, 
    :price, :value_names_input, :default_checkbox, :default_select, :default_string, :pricing_table_id, :unique, :show_in_table, :show_in_preview, 
    :hide_from_employees
  
  attr_accessor :value_names_input, :default_checkbox, :default_select, :default_string, :skip_after_create
  
  serialize :value_names, Hash
  
  belongs_to :user
  belongs_to :service_type

  # I don't think this association is actually used anywhere
  belongs_to :pricing_table
  
  has_many :custom_items, :dependent => :delete_all
  
  validates_presence_of :field_name, :input_type
  validate :at_least_two_options, :if => Proc.new { |custom_field| custom_field.input_type == "select" && custom_field.field_type != 'marketing' }
  validate :default_in_value_names, :if => Proc.new { |custom_field| custom_field.input_type == "select" && custom_field.default_select.present? }

  default_scope :order => "custom_fields.order ASC"
  scope :by_service_type, lambda { |service_type| where('service_type_id = ?', service_type.id) }
  scope :for_table, where(:show_in_table => true)
  scope :for_event_preview, where(:show_in_preview => true)

  before_validation do |custom_field|
    if custom_field.input_type.present?
      self.generate_value_names()
    end
  end

  after_create :create_all_missing_custom_items, :unless => :skip_after_create

  def toggle_visibility?
    ['customer', 'appointment'].include? self.field_type
  end

  def at_least_two_options
    if self.value_names.length < 2
      errors.add(:value_names_input, "must have at least two options")
    end
  end
  
  def default_in_value_names
    unless self.value_names.values.include? self.default
      errors.add(:default_select, "value must match one of the options specified above (case sensitive)")
    end
  end  

  # TODO: Change syntax to mass-insert to save time
  def create_all_missing_custom_items
    # Note: appointment items and instructions are currently created in the edit action when calling the appointment.rb model
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    inserts = []
    places = []

    if self.field_type == "customer"
      self.user.customers.each do |customer|
        places.push "(?,?,?,?,?,?)"
        inserts.push(*[customer.id, "Customer", self.id, self.default, timestamp, timestamp])
      end   
    end

    if self.field_type == "employee"
      self.user.employees.each do |employee|
        places.push "(?,?,?,?,?,?)"
        inserts.push(*[employee.id, "Employee", self.id, self.default, timestamp, timestamp])
      end
    end

    if self.field_type == "appointment"
      self.user.appointments.each do |appointment|
        places.push "(?,?,?,?,?,?)"
        inserts.push(*[appointment.id, "Appointment", self.id, self.default, timestamp, timestamp])
      end
    end
    
    if places.length > 0
      sql_arr = ["INSERT INTO custom_items (customizable_id, customizable_type, custom_field_id, value_name, created_at, updated_at) VALUES #{places.join(", ")}"] + inserts
      sql = ActiveRecord::Base.send(:sanitize_sql_array, sql_arr)
      ActiveRecord::Base.connection.execute(sql)
    end    
  end


  # Sets default value names to Yes and No for boolean and string typecast of integers for selects and radios
  # This is pretty dumb, but it has to be done this way because of the way the instant booking is implemented
  # On custom_items, the value_name column is always the value, not the key, of the value_names array here (even with selects)
  def generate_value_names
    if self.input_type == 'select'
      
      if self.field_type == "instant_booking"
        if self.value_names.blank?
          self.value_names = Hash[(self.min_field_value..self.max_field_value).map { |i| [i, i.to_s] }]
          self.value_names[self.max_field_value] += '+'
        end
      elsif self.value_names_input.present?
        values = self.value_names_input.split("\r\n")
        self.min_field_value = 0
        self.max_field_value = values.length - 1
        self.value_names = {}
        (self.min_field_value..self.max_field_value).each do |i|
          self.value_names[i] = values[i]
        end
      end
      self.default = self.default_select
    
    elsif self.input_type == 'boolean'
      self.min_field_value = 0
      self.max_field_value = 1
      self.value_names = {0 => 'No', 1 => 'Yes'}
      self.default = self.default_checkbox

    else
      self.value_names = {}
      self.default = self.default_string
    end

  end
  
  def human_readable_input_type
    case self.input_type
    when 'select'
      'dropdown'
    when 'boolean'
      'checkbox'
    when 'string'
      'text'
    end
  end

  def self.get_marketing_sources(user)
    (user.marketing_field.try(:value_names).try(:invert) || {}).keys + ['Add New']
  end

  def self.add_marketing_source(new_marketing_source, user)
    marketing_field = user.marketing_field
    unless marketing_field.blank? || new_marketing_source.blank?
      begin
        old_sources = marketing_field.value_names
        unless old_sources.values.include?(new_marketing_source)
          key = old_sources.blank? ? 0 : old_sources.keys.last.to_i+1
          marketing_field.value_names = old_sources.merge({ key => new_marketing_source})
          marketing_field.save!
        else
          old_sources.invert[new_marketing_source]
        end
      rescue
      end
    end
  end
  
end
