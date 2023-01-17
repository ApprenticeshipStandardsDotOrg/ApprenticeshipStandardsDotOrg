class AddOnetCodeToOccupations < ActiveRecord::Migration[7.0]
  def change
    add_reference :occupations, :onet_code, null: true, foreign_key: true, type: :uuid
  end
end
