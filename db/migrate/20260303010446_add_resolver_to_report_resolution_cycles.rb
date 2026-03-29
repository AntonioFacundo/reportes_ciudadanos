class AddResolverToReportResolutionCycles < ActiveRecord::Migration[8.1]
  def change
    add_reference :report_resolution_cycles, :resolver, null: true, foreign_key: { to_table: :users }
  end
end
