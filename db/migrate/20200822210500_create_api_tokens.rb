class CreateApiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens do |t|
      t.string :name
      t.string :token
      t.timestamps
    end
    add_index :api_tokens, :token, unique: true
  end
end
