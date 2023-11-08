# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create users
# Avatar 1,2 and 3 are male avatars
# Avatar 4,5 and 6 are female avatars
user1 = User.create!(
    id: SecureRandom.uuid,
    email: "johnsmith@gmail.com",
    password: "password" + ENV["SALT"],
    name: "John S",
    handle: "@johnsmith",
    auth_token: "xyz123",
    status: "active",
    avatar: 1,
    created_at: Time.now,
    updated_at: Time.now
)