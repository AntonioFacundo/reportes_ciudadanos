# frozen_string_literal: true

class AddSourceToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :source, :string, default: "web", null: false
  end
end
