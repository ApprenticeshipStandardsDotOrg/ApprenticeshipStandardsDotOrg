class CreateContactRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_requests, id: :uuid do |t|
      t.string :name, null: false
      t.string :organization
      t.string :email, null: false
      t.text :message, null: false

      t.timestamps
    end
  end
end
