class CreateIndustries < ActiveRecord::Migration[7.0]
  def change
    create_table :industries, id: :uuid do |t|
      t.string :name
      t.string :version
      t.string :prefix

      t.timestamps
    end
  end
end
