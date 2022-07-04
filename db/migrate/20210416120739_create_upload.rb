class CreateUpload < ActiveRecord::Migration[6.1]
  def change
    create_table :support_uploads do |t|
      t.string :name
      t.text :description
      t.text :file_data
      t.text :metadata, default: {}
      t.integer :order
      t.boolean :processing
      t.references :uploadable, polymorphic: true
      t.string :type

      t.timestamps
    end
  end
end
