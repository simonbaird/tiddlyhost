class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @paypal_client_id = Settings.secrets(:paypal, :client_id)
    @standard_plan_id = Settings.secrets(:paypal, :plan_ids, :standard)
  end

end
