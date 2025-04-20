# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Industry.create!([
  { id: 1, name: "IT" },
  { id: 2, name: "Finance" },
  { id: 3, name: "Healthcare" },
  { id: 4, name: "Education" },
  { id: 5, name: "Food & Beverage" }
])

Skill.create!([
  { id: 1, name: "Ruby" },
  { id: 2, name: "JavaScript" },
  { id: 3, name: "Python" },
  { id: 4, name: "Java" },
  { id: 5, name: "C++" }
])
