require "app_responder"

class ApplicationController < ActionController::Base
  self.responder = AppResponder
  respond_to :html
  protect_from_forgery
end
