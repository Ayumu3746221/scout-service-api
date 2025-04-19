module Creation
  class BaseCreationHandler
    def set_next(handler)
      @next_handler = handler
      handler
    end

    def handle(context)
      result = execute(context)

      if result != false
        @next_handler ? @next_handler.handle(context) : true
      else
        raise ActiveRecord::Rollback, "Failed to create record"
      end
    rescue CreationError => e
      Rails.logger.error("CreationError: #{e.message}")
      raise ActiveRecord::Rollback, e.message
    rescue StandardError => e
      handle_exception(e)
      false
    end

    def execute(context)
      raise NotImplementedError, "#{self.class} must implement the execute method"
    end

    private

    def handle_exception(e)
      Rails.logger.error("Error in #{self.class}: #{e.message}")
      raise CreationError, e.message
    end

    protected

    def fail_with!(model)
      raise CreationError, model.errors.full_messages.join(", ")
    end
  end
end
