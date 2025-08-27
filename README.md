# EuFunding - Company Lookup Application

A modern Rails 8 application for looking up Romanian company information using the Lista Firme API.

## Features

- **Simple Interface**: Single input field for company CUI lookup
- **Comprehensive Data**: Extracts all essential company information
- **Modern UI**: Built with TailwindCSS v4 and DaisyUI components
- **Responsive Design**: Works on desktop and mobile devices
- **Error Handling**: Graceful handling of invalid inputs and API errors

## Company Information Displayed

- CUI (Company Unique Identifier)
- Company Name
- Status (Active/Inactive)
- Fiscal Activity
- Legal Form
- Registration Date
- Number of Employees
- NACE Code (Economic Activity)
- Address, City, County
- Turnover and Profit

## Technology Stack

- **Ruby 3.4.2** with PRISM parser
- **Rails 8.0.2.1** with modern defaults
- **TailwindCSS v4** for styling
- **DaisyUI** for UI components
- **RubyLLM** for AI integration
- **Faraday** for HTTP requests
- **SQLite** for development database
- **Minitest** for testing

## Quick Start

### Prerequisites

- Ruby 3.4.2
- Node.js (for asset compilation)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/emilixs/eufunding-augment.git
cd eufunding-augment
```

2. Install dependencies:
```bash
bundle install
npm install
```

3. Setup the database:
```bash
bin/rails db:create
bin/rails db:migrate
```

4. Start the development server:
```bash
bin/dev
```

5. Visit `http://localhost:3000` in your browser

### Testing

Run the test suite:
```bash
bin/rails test
```

Check code quality:
```bash
bundle exec rubocop
bundle exec brakeman
```

## Usage

1. Enter a Romanian company CUI in the search field
2. Click "Caută Compania" (Search Company)
3. View the comprehensive company information

**Test CUI**: Use `14837428` to see demo data

## API Integration

The application integrates with the [Lista Firme API](https://membri.listafirme.ro/specificatii/api-info-v2.asp) to fetch real-time company data.

### 🔐 Secure API Key Setup

**Method 1: Rails Encrypted Credentials (Recommended)**
```bash
EDITOR="code --wait" bin/rails credentials:edit
```

Add to your credentials file:
```yaml
lista_firme:
  api_key: "your_actual_api_key_here"
```

**Method 2: Environment Variables**
```bash
# Copy and edit .env file
cp .env.example .env
# Add your API key to LISTA_FIRME_API_KEY
```

**📋 See [SECURITY_SETUP.md](SECURITY_SETUP.md) for comprehensive security guidelines**

### Security Features
- ✅ Server-side only API calls (never exposed to client)
- ✅ POST method used (prevents key exposure in logs)
- ✅ Encrypted credentials storage
- ✅ Proper error handling without key exposure
- ✅ IP restriction support
- ✅ Request timeout and retry logic

## Development

### Code Quality

- **RuboCop Rails Omakase**: Enforced code style
- **Brakeman**: Security vulnerability scanning
- **Comprehensive Tests**: Full test coverage

### Project Structure

- `app/controllers/company_controller.rb` - Handles company lookup requests
- `app/services/company_service.rb` - Lista Firme API integration
- `app/views/home/index.html.erb` - Homepage with search form
- `app/views/company/show.html.erb` - Company information display

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and code quality checks
5. Submit a pull request

## License

This project is available as open source under the terms of the MIT License.
