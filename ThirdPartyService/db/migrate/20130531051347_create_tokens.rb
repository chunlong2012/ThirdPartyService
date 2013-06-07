class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :token
      t.integer :device
      t.string :app

      t.timestamps
    end
  end
end
