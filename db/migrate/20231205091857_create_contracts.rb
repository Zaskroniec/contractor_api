class CreateContracts < ActiveRecord::Migration[7.1]
  def change
    create_table :contracts do |t|
      t.string :guid
      t.monetize :wage, null: false
      t.date :start_at, null: false
      t.date :end_at, null: false
      t.float :average_weekly_hours, default: 0, null: false
      t.string :archive_number
      t.datetime :company_signed_at
      t.datetime :user_signed_at
      t.belongs_to :user, foreign_key: {on_delete: :cascade}, index: true, null: false
      t.belongs_to :company, foreign_key: {on_delete: :nullify}, index: true

      t.timestamps
    end

    add_index :contracts, :guid, unique: true, where: "guid IS NOT NULL"
    add_index :contracts, :archive_number, unique: true
  end
end
