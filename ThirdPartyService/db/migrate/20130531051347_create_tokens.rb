class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :token
      t.string :device
      t.binary :vida
      t.binary :vimi

      t.timestamps
    end
  end
end
