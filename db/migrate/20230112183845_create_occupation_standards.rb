class CreateOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    create_table :occupation_standards, id: :uuid do |t|
      t.references :occupation, null: true, foreign_key: true, type: :uuid
      t.string :url
      t.references :registration_agency, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
