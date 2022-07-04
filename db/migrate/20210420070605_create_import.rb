class CreateImport < ActiveRecord::Migration[6.1]
  def change
    create_table :support_imports do |t|
      t.text :context
      t.string :state
      t.text :options
      t.string :name
      t.timestamps
    end
  end
end
