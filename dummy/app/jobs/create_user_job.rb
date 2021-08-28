class CreateUserJob < ApplicationJob
  def perform(name:)
    User.create!(name: name)
  end
end