class AddAlcaldiaToUsersAndReports < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :alcaldia, null: true, foreign_key: true
    add_reference :reports, :alcaldia, null: true, foreign_key: true
  end
end
