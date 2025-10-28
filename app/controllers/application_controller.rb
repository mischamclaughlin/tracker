class ApplicationController < ActionController::Base
  include LoggingModule
  
  allow_browser versions: :modern
end
