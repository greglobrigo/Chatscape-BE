class CreateSchema < ActiveRecord::Migration[7.0]
    def change
        execute "CREATE SCHEMA IF NOT EXISTS chatscape;"
    end
end