class CreateApiLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :api_logs do |t|
      t.string :cui, null: false
      t.text :request_url, null: false
      t.string :http_method, null: false
      t.text :request_headers
      t.text :request_body
      t.integer :response_status
      t.text :response_headers
      t.text :response_body
      t.decimal :request_duration, precision: 8, scale: 4
      t.text :error_message
      t.string :user_ip

      t.timestamps
    end

    add_index :api_logs, :cui
    add_index :api_logs, :created_at
    add_index :api_logs, :response_status
  end
end
