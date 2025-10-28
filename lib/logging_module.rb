module LoggingModule
  def log_error(message)
    Rails.logger.error(message)
  end

  def log_info(message)
    Rails.logger.info(message)
  end

  def log_debug(message)
    Rails.logger.debug(message)
  end
end