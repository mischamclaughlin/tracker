module LoggingModule
  def log_error(message)
    Rails.logger.error("ERROR: #{message}")
  end

  def log_info(message)
    Rails.logger.info("INFO: #{message}")
  end

  def log_debug(message)
    Rails.logger.debug("DEBUG: #{message}")
  end
end
