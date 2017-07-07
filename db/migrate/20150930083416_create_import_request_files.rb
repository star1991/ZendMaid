class CreateImportRequestFiles < ActiveRecord::Migration
  def change
    create_table :import_request_files do |t|
      t.string :file

      t.timestamps
    end
  end
end
