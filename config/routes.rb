# frozen_string_literal: true

Belated::Engine.routes.draw do
  match '/', to: 'admin#index', via: %i[get post]
end
