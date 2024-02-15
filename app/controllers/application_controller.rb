class ApplicationController < ActionController::Base
  include Import.inject[validator: 'contract_validator', current_user_repository: 'current_user_repository']
  before_action :authenticate_user!, :set_time_zone, :set_current_user

  def set_time_zone
    return unless current_user
    requested_time_zone = request.headers['Time-Zone']

    if current_user.time_zone.present?
      Time.zone = current_user.time_zone
    elsif requested_time_zone
      current_user.update(time_zone: requested_time_zone)
      Time.zone = requested_time_zone
    end
  end

  def set_current_user
    current_user_repository.authenticated_identity = current_user
  end
end
