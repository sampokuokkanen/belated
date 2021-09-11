# frozen_string_literal: true

Belated::Engine.routes.draw do
  match '/', to: 'belated#index', via: [:get, :post]
end
