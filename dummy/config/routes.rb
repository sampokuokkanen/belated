# frozen_string_literal: true
require 'belated/engine'
Rails.application.routes.draw do
  root to: 'application#index'
  mount Belated::Engine => '/belated'
end
