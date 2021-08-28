class CreateUserJob < ApplicationJob
  def perform
    User.create!(name: "John Doe")
  end
end