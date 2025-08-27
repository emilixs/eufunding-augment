# frozen_string_literal: true

class ApiLog < ApplicationRecord
  validates :cui, presence: true
  validates :request_url, presence: true
  validates :http_method, presence: true
  validates :response_status, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :errors, -> { where.not(error_message: nil) }
  scope :successful, -> { where(error_message: nil, response_status: 200) }
  scope :for_cui, ->(cui) { where(cui: cui) }

  def success?
    response_status == 200 && error_message.blank?
  end

  def error?
    !success?
  end

  def duration_ms
    return nil unless request_duration

    (request_duration * 1000).round(2)
  end

  def formatted_created_at
    created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def self.log_api_request(cui:, request_url:, http_method:, request_headers:, request_body:, 
                          response_status:, response_headers:, response_body:, 
                          request_duration:, error_message: nil, user_ip: nil)
    create!(
      cui: cui,
      request_url: request_url,
      http_method: http_method,
      request_headers: request_headers.to_json,
      request_body: request_body,
      response_status: response_status,
      response_headers: response_headers.to_json,
      response_body: response_body,
      request_duration: request_duration,
      error_message: error_message,
      user_ip: user_ip
    )
  rescue StandardError => e
    Rails.logger.error "Failed to log API request: #{e.message}"
    nil
  end

  def self.cleanup_old_logs(days_to_keep = 30)
    where("created_at < ?", days_to_keep.days.ago).delete_all
  end
end
