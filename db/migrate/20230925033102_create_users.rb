class CreateUsers < ActiveRecord::Migration[7.0]
    def change
        enable_extension 'pgcrypto'

        create_table :users, id: :uuid do |t|
        t.string :email
        t.string :password
        t.string :name
        t.string :handle, unique: true, nullable: true
        t.string :auth_token

        t.timestamps
        end
    end
end