# frozen_string_literal: true

# Lista Firme API Configuration Validator
# This initializer checks if the API key is properly configured

Rails.application.configure do
  # Check API key configuration on startup (except in test environment)
  unless Rails.env.test?
    api_key = Rails.application.credentials.lista_firme&.api_key || ENV["LISTA_FIRME_API_KEY"]

    if api_key.blank?
      Rails.logger.warn <<~WARNING
        ⚠️  Lista Firme API key not configured!

        The application will use mock data for demonstration purposes.

        To configure your API key:

        Method 1 (Recommended): Rails Encrypted Credentials
        Run: EDITOR="code --wait" bin/rails credentials:edit
        Add:
          lista_firme:
            api_key: "your_api_key_here"

        Method 2: Environment Variable
        Add to .env file:
          LISTA_FIRME_API_KEY=your_api_key_here

        Get your API key from: https://membri.listafirme.ro/

        See SECURITY_SETUP.md for detailed instructions.
      WARNING
    else
      Rails.logger.info "✅ Lista Firme API key configured successfully"

      # Validate API key format (basic check)
      if api_key.length < 10
        Rails.logger.warn "⚠️  Lista Firme API key seems too short. Please verify it's correct."
      end
    end
  end
end

# Configuration constants
module ListaFirme
  API_BASE_URL = ENV["LISTA_FIRME_BASE_URL"] || "https://www.listafirme.ro/api"
  API_TIMEOUT = 30
  API_OPEN_TIMEOUT = 10

  # Test CUI for demonstration
  TEST_CUI = "14837428"

  class << self
    def api_key
      Rails.application.credentials.lista_firme&.api_key || ENV["LISTA_FIRME_API_KEY"]
    end

    def configured?
      api_key.present?
    end

    def test_mode?
      !configured?
    end
  end
end
