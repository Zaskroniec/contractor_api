class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :not_unique

  def unsafe_params
    params.to_unsafe_h.deep_symbolize_keys
  end

  private

  def not_found(exception)
    render json: {code: 404, message: exception.message}, status: :not_found
  end

  def not_unique(exception)
    render json: {code: 422, message: exception.message}, status: :unprocessable_entity
  end
end
