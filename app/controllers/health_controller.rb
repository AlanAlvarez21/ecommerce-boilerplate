class HealthController < ApplicationController
  include ApiResponses

  skip_before_action :verify_authenticity_token

  def check
    health_status = {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: Rails.application.version || "unknown",
      environment: Rails.env,
      checks: {
        database: database_status,
        cache: cache_status,
        storage: storage_status
      }
    }

    overall_status = health_status[:checks].values.all? { |check| check[:status] == "ok" }

    if overall_status
      render json: health_status, status: :ok
    else
      render json: health_status.merge(status: "error"), status: :service_unavailable
    end
  end

  def liveness
    render json: { status: "ok", timestamp: Time.current.iso8601 }, status: :ok
  end

  def readiness
    ready = database_ready? && cache_ready?

    if ready
      render json: { status: "ready", timestamp: Time.current.iso8601 }, status: :ok
    else
      render json: { status: "not_ready", timestamp: Time.current.iso8601 }, status: :service_unavailable
    end
  end

  private

  def database_status
    start_time = Time.current
    ActiveRecord::Base.connection.execute("SELECT 1")
    response_time = ((Time.current - start_time) * 1000).round(2)

    {
      status: "ok",
      response_time_ms: response_time,
      pool_size: ActiveRecord::Base.connection_pool.size,
      active_connections: ActiveRecord::Base.connection_pool.connections.count
    }
  rescue StandardError => e
    {
      status: "error",
      error: e.message,
      response_time_ms: nil
    }
  end

  def cache_status
    start_time = Time.current
    Rails.cache.write("health_check", Time.current.to_i, expires_in: 30.seconds)
    cached_value = Rails.cache.read("health_check")
    response_time = ((Time.current - start_time) * 1000).round(2)

    if cached_value
      {
        status: "ok",
        response_time_ms: response_time
      }
    else
      {
        status: "error",
        error: "Cache write/read failed",
        response_time_ms: response_time
      }
    end
  rescue StandardError => e
    {
      status: "error",
      error: e.message,
      response_time_ms: nil
    }
  end

  def storage_status
    start_time = Time.current
    # Test if we can access storage
    if Rails.env.production?
      # In production, test actual storage
      test_storage_access
    else
      # In development/test, just return ok
      { status: "ok", response_time_ms: 0 }
    end
  rescue StandardError => e
    {
      status: "error",
      error: e.message,
      response_time_ms: nil
    }
  end

  def test_storage_access
    # This would test your actual storage service (S3, etc.)
    { status: "ok", response_time_ms: 0 }
  end

  def database_ready?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def cache_ready?
    Rails.cache.write("readiness_check", "ok", expires_in: 30.seconds)
    Rails.cache.read("readiness_check") == "ok"
  rescue StandardError
    false
  end
end
