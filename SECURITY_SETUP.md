# 🔐 Secure API Key Setup Guide

This guide explains how to securely configure your Lista Firme API key following Rails 8 best practices and the API documentation requirements.

## 🚨 Security Requirements from Lista Firme API

Based on the [official documentation](https://membri.listafirme.ro/specificatii/api-info-v2.asp):

1. **Server-side only**: Never expose API keys in client-side code or browser
2. **Use POST method**: Prevents API key exposure in server logs and traffic statistics
3. **IP restrictions**: Configure allowed IP addresses in your Lista Firme account
4. **Secure storage**: Store API keys encrypted, never in plain text

## 🔑 Method 1: Rails Encrypted Credentials (Recommended)

### Step 1: Edit Encrypted Credentials

```bash
# This opens the encrypted credentials file
EDITOR="code --wait" bin/rails credentials:edit

# Or use your preferred editor:
EDITOR="nano" bin/rails credentials:edit
EDITOR="vim" bin/rails credentials:edit
```

### Step 2: Add Your API Configuration

Add this structure to your credentials file:

```yaml
# config/credentials.yml.enc (encrypted)
lista_firme:
  api_key: "your_actual_api_key_here"
  base_url: "https://www.listafirme.ro/api"
  timeout: 30
  
# Optional: Different keys for different environments
development:
  lista_firme:
    api_key: "development_api_key"

production:
  lista_firme:
    api_key: "production_api_key"
```

### Step 3: Access in Your Application

The application is already configured to use:

```ruby
# In app/services/company_service.rb
api_key = Rails.application.credentials.lista_firme&.api_key
```

### Step 4: Verify Security

```bash
# Check that credentials are encrypted
cat config/credentials.yml.enc
# Should show encrypted content, not plain text

# Verify master key exists and is in .gitignore
ls -la config/master.key
grep "master.key" .gitignore
```

## 🔑 Method 2: Environment Variables (Alternative)

### Step 1: Update .env.example

```bash
# Add to .env.example
LISTA_FIRME_API_KEY=your_api_key_here
LISTA_FIRME_BASE_URL=https://www.listafirme.ro/api
```

### Step 2: Create .env File

```bash
# Copy example and add real values
cp .env.example .env
# Edit .env with your actual API key (never commit this file)
```

### Step 3: Install dotenv-rails (if using this method)

```ruby
# Add to Gemfile
gem 'dotenv-rails', groups: [:development, :test]
```

### Step 4: Update Service to Use ENV

```ruby
# In app/services/company_service.rb
api_key = ENV['LISTA_FIRME_API_KEY'] || Rails.application.credentials.lista_firme&.api_key
```

## 🛡️ Production Security Checklist

### 1. Server Configuration

- [ ] Configure IP restrictions in Lista Firme account
- [ ] Use HTTPS only in production
- [ ] Set up proper firewall rules
- [ ] Enable request rate limiting

### 2. Rails Application Security

- [ ] Ensure `config/master.key` is secure and backed up
- [ ] Verify `.env` files are in `.gitignore`
- [ ] Use strong secrets for Rails application
- [ ] Enable CSRF protection
- [ ] Configure secure headers

### 3. Monitoring and Logging

- [ ] Monitor API usage and costs
- [ ] Set up error tracking (Sentry, Bugsnag, etc.)
- [ ] Log API failures without exposing keys
- [ ] Set up alerts for unusual API usage

## 🔧 Testing Your Setup

### 1. Verify API Key Access

```bash
# In Rails console
bin/rails console

# Test credentials access
Rails.application.credentials.lista_firme&.api_key
# Should return your API key (or nil if not set)

# Test environment variable (if using)
ENV['LISTA_FIRME_API_KEY']
```

### 2. Test API Connection

```bash
# In Rails console
CompanyService.fetch_company_info("14837428")
# Should return company data or appropriate error
```

### 3. Verify Security

```bash
# Check that sensitive files are ignored
git status
# Should not show .env, config/master.key, or other sensitive files

# Verify encrypted credentials
bin/rails credentials:show
# Should show decrypted content with your API key
```

## 🚨 Security Best Practices

### DO ✅

- Store API keys in encrypted Rails credentials
- Use POST method for API requests
- Configure IP restrictions in Lista Firme account
- Monitor API usage and costs
- Use HTTPS in production
- Rotate API keys periodically
- Set up proper error handling without exposing keys

### DON'T ❌

- Commit API keys to version control
- Use GET method for API requests (exposes keys in logs)
- Store keys in plain text files
- Expose keys in client-side JavaScript
- Share API keys via email or chat
- Use production keys in development
- Log API keys in application logs

## 🔄 Key Rotation

When rotating your API key:

1. Generate new key in Lista Firme account
2. Update encrypted credentials: `bin/rails credentials:edit`
3. Test with new key in staging environment
4. Deploy to production
5. Revoke old key in Lista Firme account

## 📞 Support

If you encounter issues:

1. Check Lista Firme API documentation
2. Verify your account status and remaining credits
3. Test with the provided test CUI: `14837428`
4. Check application logs for detailed error messages
5. Contact Lista Firme support if API issues persist
