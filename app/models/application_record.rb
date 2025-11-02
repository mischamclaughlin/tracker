class ApplicationRecord < ActiveRecord::Base
  include LoggingModule
  
  primary_abstract_class
end
