class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :list, index: true, foreign_key: true
      t.string :status
      t.string :text

      t.timestamps null: false
    end
  end
end
