class ApplicationController < ActionController::Base
  include Import.inject[validator: 'contract_validator']end
