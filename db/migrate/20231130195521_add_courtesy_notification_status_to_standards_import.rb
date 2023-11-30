class AddCourtesyNotificationStatusToStandardsImport < ActiveRecord::Migration[7.1]
  def change
    add_column :standards_imports, :courtesy_notification, :integer, default: 0
  end
end
