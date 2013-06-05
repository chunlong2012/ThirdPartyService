class CreateMessageQueues < ActiveRecord::Migration
  def change
    create_table :message_queues do |t|
      t.integer :command_type
      t.string :token
      t.string :message
      t.string :app

      t.timestamps
    end
  end
end
