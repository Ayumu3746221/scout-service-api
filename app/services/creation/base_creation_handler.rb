module Creation
  class BaseCreationHandler
    def set_next(handler)
      @next_handler = handler
      handler
    end

    def handle(context)
      execute(context)
      @next_handler&.handle(context)
      rescue ActiveRecord::Rollback => e
        raise e
      rescue StandardError => e
        handle_exception(e)
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
