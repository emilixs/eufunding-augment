# frozen_string_literal: true

class CompanyService
  class << self
    # Debug method to test API connectivity
    def debug_api_call(cui)
      Rails.logger.level = :debug
      Rails.logger.info "🚀 DEBUG MODE: Testing API call for CUI: #{cui}"
      fetch_company_info(cui)
    end

    def fetch_company_info(cui)
      Rails.logger.info "🔍 Starting company lookup for CUI: #{cui}"

      # For demo purposes, return mock data for the test CUI if no API key configured
      if cui == ListaFirme::TEST_CUI && ListaFirme.test_mode?
        Rails.logger.info "📋 Using mock data for CUI #{cui} (API key not configured)"
        return mock_company_data
      end

      # Validate API key configuration
      unless ListaFirme.configured?
        Rails.logger.error "❌ Lista Firme API key not configured. See SECURITY_SETUP.md for instructions."
        return nil
      end

      Rails.logger.info "✅ API key configured, proceeding with real API call"

      # Fetch real company information from Lista Firme API
      company_data = fetch_basic_info(cui, ListaFirme.api_key)

      if company_data.nil?
        Rails.logger.error "❌ No data returned from API for CUI: #{cui}"
        return nil
      end

      Rails.logger.info "✅ Raw API data received for CUI: #{cui}"
      Rails.logger.debug "📊 Raw API response: #{company_data.inspect}" if Rails.env.development?

      # Extract and format the required information
      formatted_data = format_company_data(company_data)

      if formatted_data
        Rails.logger.info "✅ Successfully formatted company data for CUI: #{cui}"
      else
        Rails.logger.error "❌ Failed to format company data for CUI: #{cui}"
      end

      formatted_data
    end

    private

    def fetch_basic_info(cui, api_key, user_ip = nil)
      url = "#{ListaFirme::API_BASE_URL}/info-v2.asp"

      Rails.logger.info "🌐 Making API request to: #{url}"
      Rails.logger.info "🔑 Using API key: #{api_key[0..5]}...#{api_key[-3..-1]}" # Log partial key for debugging
      Rails.logger.info "📋 Requesting data for CUI: #{cui}"

      # Request all the required fields as per API documentation
      data = {
        "TaxCode" => cui,
        "Name" => "",
        "Status" => "",
        "FiscalActivity" => "",
        "LegalForm" => "",
        "Date" => "",
        "Employees" => "",
        "NACE" => "info",
        "Address" => "",
        "City" => "",
        "County" => "",
        "Turnover" => "",
        "Profit" => ""
      }

      Rails.logger.debug "📤 Request data structure: #{data.to_json}" if Rails.env.development?

      # Use POST method for security (as recommended in API docs)
      # This prevents API key exposure in server logs
      params = {
        key: api_key,
        data: data.to_json
      }

      Rails.logger.info "📡 Sending POST request with #{params.keys.join(', ')} parameters"

      # Log the EXACT request being sent
      Rails.logger.info "🔍 EXACT REQUEST DETAILS:"
      Rails.logger.info "   URL: #{url}"
      Rails.logger.info "   Method: POST"
      Rails.logger.info "   Content-Type: application/x-www-form-urlencoded"
      Rails.logger.info "   API Key: #{api_key[0..5]}...#{api_key[-3..-1]}"
      Rails.logger.info "   Data JSON: #{data.to_json}"
      Rails.logger.info "   Full params: key=#{api_key[0..5]}...&data=#{data.to_json}"

      begin
        # Configure Faraday with security headers and timeout
        connection = Faraday.new do |conn|
          conn.options.timeout = ListaFirme::API_TIMEOUT
          conn.options.open_timeout = ListaFirme::API_OPEN_TIMEOUT
          conn.headers["User-Agent"] = "EuFunding/1.0"
          conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        end

        Rails.logger.info "⏱️ Making HTTP request with #{ListaFirme::API_TIMEOUT}s timeout"

        start_time = Time.current
        response = connection.post(url, params)
        duration = Time.current - start_time

        # Prepare data for database logging
        request_headers = {
          "User-Agent" => "EuFunding/1.0",
          "Content-Type" => "application/x-www-form-urlencoded"
        }

        # Log to database (without exposing full API key)
        log_data = {
          cui: cui,
          request_url: url,
          http_method: "POST",
          request_headers: request_headers,
          request_body: "key=#{api_key[0..5]}...&data=#{data.to_json}",
          response_status: response.status,
          response_headers: response.headers.to_h,
          response_body: response.body,
          request_duration: duration,
          user_ip: user_ip
        }

        Rails.logger.info "📈 API request completed in #{duration.round(2)}s"
        Rails.logger.info "📊 Response status: #{response.status}"
        Rails.logger.info "📏 Response size: #{response.body.length} bytes"

        # Log the EXACT response received
        Rails.logger.info "🔍 EXACT RESPONSE DETAILS:"
        Rails.logger.info "   Status: #{response.status} #{response.reason_phrase}"
        Rails.logger.info "   Headers: #{response.headers.to_h}"
        Rails.logger.info "   Raw Body: #{response.body}"
        Rails.logger.info "   Body Length: #{response.body.length} bytes"

        if response.success?
          Rails.logger.info "✅ Successful API response (#{response.status})"

          begin
            parsed_response = JSON.parse(response.body)

            # Check for API errors in the response
            if parsed_response["error"]
              Rails.logger.error "❌ API returned error: #{parsed_response['error']}"
              Rails.logger.error "📄 Full error response: #{parsed_response.inspect}"

              # Log error to database
              ApiLog.log_api_request(**log_data.merge(error_message: parsed_response["error"]))
              return nil
            end

            # Log successful parsing
            Rails.logger.info "✅ Successfully parsed JSON response"
            Rails.logger.info "💰 API cost: #{parsed_response['cost']} afișări"
            Rails.logger.info "👁️ Remaining views: #{parsed_response['views']}"

            # Log which fields were returned
            returned_fields = parsed_response.keys.reject { |k| %w[cost views error].include?(k) }
            Rails.logger.info "📋 Returned fields: #{returned_fields.join(', ')}"

            # Log successful request to database
            ApiLog.log_api_request(**log_data)

            parsed_response
          rescue JSON::ParserError => e
            Rails.logger.error "❌ Failed to parse JSON response: #{e.message}"
            Rails.logger.error "📄 Raw response that failed to parse: #{response.body}"

            # Log JSON parsing error to database
            ApiLog.log_api_request(**log_data.merge(error_message: "JSON Parse Error: #{e.message}"))
            nil
          end
        else
          Rails.logger.error "❌ API request failed with status: #{response.status}"
          Rails.logger.error "🔍 EXACT ERROR RESPONSE:"
          Rails.logger.error "   Status: #{response.status} #{response.reason_phrase}"
          Rails.logger.error "   Headers: #{response.headers.to_h}"
          Rails.logger.error "   Raw Body: #{response.body}"

          error_message = "HTTP #{response.status}: #{response.reason_phrase}"

          # Try to parse error response
          begin
            error_data = JSON.parse(response.body)
            if error_data["error"]
              Rails.logger.error "🚨 API error message: #{error_data['error']}"
              error_message = error_data["error"]
            end
            Rails.logger.error "🔍 Parsed error data: #{error_data.inspect}"
          rescue JSON::ParserError
            Rails.logger.error "📄 Non-JSON error response (raw): #{response.body}"
            error_message += " - Non-JSON response: #{response.body[0..200]}"
          end

          # Log error to database
          ApiLog.log_api_request(**log_data.merge(error_message: error_message))

          nil
        end
      rescue Faraday::TimeoutError => e
        error_msg = "API request timeout after #{ListaFirme::API_TIMEOUT}s: #{e.message}"
        Rails.logger.error "⏰ #{error_msg}"

        # Log timeout to database
        ApiLog.log_api_request(
          cui: cui,
          request_url: url,
          http_method: "POST",
          request_headers: { "User-Agent" => "EuFunding/1.0" },
          request_body: "key=#{api_key[0..5]}...&data=#{data.to_json}",
          response_status: 0,
          response_headers: {},
          response_body: "",
          request_duration: ListaFirme::API_TIMEOUT,
          error_message: error_msg,
          user_ip: user_ip
        )
        nil
      rescue Faraday::ConnectionFailed => e
        error_msg = "Connection failed to Lista Firme API: #{e.message}"
        Rails.logger.error "🔌 #{error_msg}"

        # Log connection error to database
        ApiLog.log_api_request(
          cui: cui,
          request_url: url,
          http_method: "POST",
          request_headers: { "User-Agent" => "EuFunding/1.0" },
          request_body: "key=#{api_key[0..5]}...&data=#{data.to_json}",
          response_status: 0,
          response_headers: {},
          response_body: "",
          request_duration: 0,
          error_message: error_msg,
          user_ip: user_ip
        )
        nil
      rescue Faraday::Error => e
        error_msg = "Network error connecting to Lista Firme API: #{e.class} - #{e.message}"
        Rails.logger.error "🌐 #{error_msg}"

        # Log network error to database
        ApiLog.log_api_request(
          cui: cui,
          request_url: url,
          http_method: "POST",
          request_headers: { "User-Agent" => "EuFunding/1.0" },
          request_body: "key=#{api_key[0..5]}...&data=#{data.to_json}",
          response_status: 0,
          response_headers: {},
          response_body: "",
          request_duration: 0,
          error_message: error_msg,
          user_ip: user_ip
        )
        nil
      rescue StandardError => e
        error_msg = "Unexpected error in Lista Firme API call: #{e.class} - #{e.message}"
        Rails.logger.error "💥 #{error_msg}"
        Rails.logger.error "📍 Backtrace: #{e.backtrace.first(5).join("\n")}"

        # Log unexpected error to database
        ApiLog.log_api_request(
          cui: cui,
          request_url: url,
          http_method: "POST",
          request_headers: { "User-Agent" => "EuFunding/1.0" },
          request_body: "key=#{api_key[0..5]}...&data=#{data.to_json}",
          response_status: 0,
          response_headers: {},
          response_body: "",
          request_duration: 0,
          error_message: error_msg,
          user_ip: user_ip
        )
        nil
      end
    end

    def format_company_data(raw_data)
      Rails.logger.info "🔄 Starting to format company data"

      return nil if raw_data.nil?

      # Handle the case where we get an error response
      if raw_data["error"]
        Rails.logger.error "❌ API returned error in data: #{raw_data['error']}"
        return nil
      end

      # Check if we have the minimum required data
      unless raw_data["TaxCode"]
        Rails.logger.error "❌ No TaxCode in API response"
        Rails.logger.debug "📄 Available keys: #{raw_data.keys.join(', ')}"
        return nil
      end

      Rails.logger.info "✅ Formatting data for TaxCode: #{raw_data['TaxCode']}"

      formatted_data = {
        cui: raw_data["TaxCode"],
        company_name: raw_data["Name"],
        status: raw_data["Status"],
        fiscal_activity: raw_data["FiscalActivity"],
        legal_form: raw_data["LegalForm"],
        registration_date: format_date(raw_data["Date"]),
        employees: extract_employees(raw_data),
        nace_code: format_nace_code(raw_data["NACE"]),
        address: raw_data["Address"],
        city: raw_data["City"],
        county: raw_data["County"],
        turnover: extract_turnover(raw_data),
        profit: extract_profit(raw_data),
        cost: raw_data["cost"],
        views_remaining: raw_data["views"]
      }

      # Log which fields have data
      filled_fields = formatted_data.select { |k, v| v.present? }.keys
      empty_fields = formatted_data.select { |k, v| v.blank? }.keys

      Rails.logger.info "✅ Filled fields: #{filled_fields.join(', ')}"
      Rails.logger.info "⚪ Empty fields: #{empty_fields.join(', ')}" if empty_fields.any?

      formatted_data
    end

    def format_date(date_string)
      return nil if date_string.blank?

      # API returns dates in format "2002/8/26"
      Date.parse(date_string).strftime("%d.%m.%Y")
    rescue Date::Error
      date_string
    end

    def extract_employees(data)
      # Try to get from Balance data first (most recent)
      if data["Balance"]&.is_a?(Array) && data["Balance"].any?
        latest_balance = data["Balance"].first
        return latest_balance["Employees"] if latest_balance["Employees"]
      end

      # Fallback to direct Employees field
      data["Employees"]
    end

    def format_nace_code(nace_data)
      return nil if nace_data.blank?

      # NACE can be just a code or an object with description
      if nace_data.is_a?(Hash)
        "#{nace_data['code']} - #{nace_data['description']}"
      else
        nace_data
      end
    end

    def extract_turnover(data)
      # Try to get from Balance data first (most recent)
      if data["Balance"]&.is_a?(Array) && data["Balance"].any?
        latest_balance = data["Balance"].first
        return format_currency(latest_balance["Turnover"]) if latest_balance["Turnover"]
      end

      # Fallback to direct Turnover field
      format_currency(data["Turnover"])
    end

    def extract_profit(data)
      # Try to get from Balance data first (most recent)
      if data["Balance"]&.is_a?(Array) && data["Balance"].any?
        latest_balance = data["Balance"].first
        return format_currency(latest_balance["NetProfit"]) if latest_balance["NetProfit"]
      end

      # Fallback to direct Profit field
      format_currency(data["Profit"])
    end

    def format_currency(amount)
      return nil if amount.blank?

      # Convert to integer and format with thousand separators
      amount_int = amount.to_i
      "#{amount_int.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} RON"
    rescue
      amount.to_s
    end

    def mock_company_data
      # Mock data based on the API documentation example
      {
        cui: "14837428",
        company_name: "BORG DESIGN SRL",
        status: "functiune",
        fiscal_activity: "ACTIVA",
        legal_form: "SRL",
        registration_date: "26.08.2002",
        employees: "23",
        nace_code: "6201 - Activități de realizare a soft-ului la comandă",
        address: "STR. ING. STEFAN HEPITES, Nr. 16A, Et. P",
        city: "SECTORUL 5",
        county: "BUCURESTI",
        turnover: "3.708.712 RON",
        profit: "351.060 RON",
        cost: "5",
        views_remaining: "86"
      }
    end
  end
end
