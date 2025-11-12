class QuickAddController < ApplicationController
  include LoggingModule

  def new
    @transaction = Transaction.new
    @portfolio = Portfolio.new
  end
end
