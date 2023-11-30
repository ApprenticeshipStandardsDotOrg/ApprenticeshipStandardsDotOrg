class AddCourtesyNotificationToSourceFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :source_files, :courtesy_notification, :integer, default: 0
  end
end
