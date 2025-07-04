module ApiResponses
  extend ActiveSupport::Concern
  
  def render_success(data = {}, status = :ok)
    render json: { 
      success: true, 
      data: data,
      timestamp: Time.current.iso8601
    }, status: status
  end
  
  def render_error(message, status = :unprocessable_entity, details = {})
    render json: { 
      success: false, 
      error: message,
      details: details,
      timestamp: Time.current.iso8601
    }, status: status
  end
  
  def render_validation_errors(model)
    render_error("Validation failed", :unprocessable_entity, model.errors.full_messages)
  end
end