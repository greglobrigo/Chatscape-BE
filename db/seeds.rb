# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create users

def generateRandomMaleAvatar()
    return rand(1..3)
end

def generateRandomFemaleAvatar()
    return rand(4..6)
end

user1 = User.create!(
    id: SecureRandom.uuid,
    email: "johnsmith@gmail.com",
    password: Base64.encode64("password" + ENV["SALT"]),
    name: "John S",
    handle: "@johnsmith",
    auth_token: "xyz123",
    status: "active",
    avatar: 1,
    created_at: Time.now,
    updated_at: Time.now
)

user2 = User.create!(
    id: SecureRandom.uuid,
    email: "brianmolina@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Brian M",
    handle: "@brianmolina",
    auth_token: "xyz123",
    status: "active",
    avatar: generateRandomMaleAvatar(),
    created_at: Time.now,
    updated_at: Time.now
)