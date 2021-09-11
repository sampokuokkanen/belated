# frozen_string_literal: true

Belated::Engine.routes.draw do
  get '/belated', to: 'belated#index'
  match '/', to: 'belated#index', via: %i[get post]
end
