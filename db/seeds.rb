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
    email: "johns@gmail.com",
    password: Base64.encode64("password" + ENV["SALT"]),
    name: "John S",
    handle: "@smitherines",
    auth_token: "xyz123",
    status: "active",
    avatar: 1,
    created_at: Time.now,
    updated_at: Time.now
)

user2 = User.create!(
    id: SecureRandom.uuid,
    email: "brianm@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Brian M",
    handle: "@beerian",
    auth_token: "xyz123",
    status: "active",
    avatar: 2,
    created_at: Time.now,
    updated_at: Time.now
)

user3 = User.create!(
    id: SecureRandom.uuid,
    email: "tristann@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Tristan N",
    handle: "@insanity",
    auth_token: "xyz123",
    status: "active",
    avatar: 3,
    created_at: Time.now,
    updated_at: Time.now
)

user4 = User.create!(
    id: SecureRandom.uuid,
    email: "paulinemae@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Pauline M",
    handle: "@wazzapau",
    auth_token: "xyz123",
    status: "active",
    avatar: 4,
    created_at: Time.now,
    updated_at: Time.now
)

user5 = User.create!(
    id: SecureRandom.uuid,
    email: "sheilamae@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Sheila P",
    handle: "@shammy",
    auth_token: "xyz123",
    status: "active",
    avatar: 5,
    created_at: Time.now,
    updated_at: Time.now
)

user6 = User.create!(
    id: SecureRandom.uuid,
    email: "lehmara@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Lehmar A",
    handle: "@sing4u",
    auth_token: "xyz123",
    status: "active",
    avatar: 1,
    created_at: Time.now,
    updated_at: Time.now
)

user7 = User.create!(
    id: SecureRandom.uuid,
    email: "Anar@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Ana R",
    handle: "@anabanana",
    auth_token: "xyz123",
    status: "active",
    avatar: 6,
    created_at: Time.now,
    updated_at: Time.now
)

user8 = User.create!(
    id: SecureRandom.uuid,
    email: "justinl@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Justin L",
    handle: "@justincase",
    auth_token: "xyz123",
    status: "active",
    avatar: 2,
    created_at: Time.now,
    updated_at: Time.now
)

user9 = User.create!(
    id: SecureRandom.uuid,
    email: "paulaz@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Paul A",
    handle: "@itsmepaul",
    auth_token: "xyz123",
    status: "active",
    avatar: 2,
    created_at: Time.now,
    updated_at: Time.now
)

user10 = User.create!(
    id: SecureRandom.uuid,
    email: "gregl@gmail.com",
    password: Base64.encode64(SecureRandom.alphanumeric(8) + ENV["SALT"]),
    name: "Greg L",
    handle: "@itsmegreg",
    auth_token: "xyz123",
    status: "active",
    avatar: 3,
    created_at: Time.now,
    updated_at: Time.now
)
