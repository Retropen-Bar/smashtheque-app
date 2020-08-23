class UseInets < ActiveRecord::Migration[6.0]
  def change
    change_column :api_requests, :remote_ip, 'inet USING remote_ip::inet'
  end
end
