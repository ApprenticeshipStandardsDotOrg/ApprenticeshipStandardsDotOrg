# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
if Rails.env.development?
  User.where(email: "admin@example.com").first_or_create!(
    role: "admin",
    name: "Admin User",
    password: "passwordpassword"
  )

  ScrapeRapidsCode.new.call
  ScrapeOnetCodes.new.call
end
