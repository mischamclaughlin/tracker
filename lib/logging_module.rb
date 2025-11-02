module LoggingModule
  def log_error(message)
    Rails.logger.error("ERROR: #{message}")
    puts "ERROR: #{message}"
  end

  def log_info(message)
    Rails.logger.info("INFO: #{message}")
    puts "INFO: #{message}"
  end

  def log_debug(message)
    Rails.logger.debug("DEBUG: #{message}")
    puts "DEBUG: #{message}"
  end
end
