# == Schema Information
#
# Table name: import_request_files
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ImportRequestFile < ActiveRecord::Base
  attr_accessible :file

  mount_uploader :file, ImportFileUploader
  validates_presence_of :file
end
