class AddColumnToReservation < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :self_booking, :boolean
  end
end
