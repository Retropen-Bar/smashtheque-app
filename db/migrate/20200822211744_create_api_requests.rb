class CreateApiRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :api_requests do |t|
      t.belongs_to :api_token
      t.string :remote_ip
      t.string :controller
      t.string :action
      t.datetime :requested_at
    end
  end
end
