# frozen_string_literal: true

class CompanyService
  class << self
    def fetch_company_info(cui)
      # For demo purposes, return mock data for the test CUI if no API key configured
      if cui == ListaFirme::TEST_CUI && ListaFirme.test_mode?
        Rails.logger.info "Using mock data for CUI #{cui} (API key not configured)"
        return mock_company_data
      end

      # Validate API key configuration
      unless ListaFirme.configured?
        Rails.logger.error "Lista Firme API key not configured. See SECURITY_SETUP.md for instructions."
        return nil
      end

      # Fetch real company information from Lista Firme API
      company_data = fetch_basic_info(cui, ListaFirme.api_key)

      return nil if company_data.nil?

      # Extract and format the required information
      format_company_data(company_data)
    end

    private

    def fetch_basic_info(cui, api_key)
      url = "#{ListaFirme::API_BASE_URL}/info-v2.asp"

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

      # Use POST method for security (as recommended in API docs)
      # This prevents API key exposure in server logs
      params = {
        key: api_key,
        data: data.to_json
      }

      begin
        # Configure Faraday with security headers and timeout
        connection = Faraday.new do |conn|
          conn.options.timeout = ListaFirme::API_TIMEOUT
          conn.options.open_timeout = ListaFirme::API_OPEN_TIMEOUT
          conn.headers["User-Agent"] = "EuFunding/1.0"
          conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        end

        response = connection.post(url, params)

        if response.success?
          JSON.parse(response.body)
        else
          Rails.logger.error "Lista Firme API request failed with status: #{response.status}"
          Rails.logger.error "Response body: #{response.body}" if Rails.env.development?
          nil
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse Lista Firme API response: #{e.message}"
        nil
      rescue Faraday::Error => e
        Rails.logger.error "Network error connecting to Lista Firme API: #{e.message}"
        nil
      rescue StandardError => e
        Rails.logger.error "Unexpected error in Lista Firme API call: #{e.message}"
        nil
      end
    end

    def format_company_data(raw_data)
      return nil if raw_data.nil? || raw_data["error"]

      # Handle the case where we get an error response
      if raw_data["error"]
        Rails.logger.error "API returned error: #{raw_data['error']}"
        return nil
      end

      {
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
