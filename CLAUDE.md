# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Rails 8.0.2.1** application called **EuFunding** - currently a fresh Rails installation with minimal customization. The project follows modern Rails conventions and includes Rails 8's new solid queue/cache/cable defaults.

## Common Development Commands

### Development Server
```bash
bin/rails server
```

### Testing
```bash
bin/rails test                    # Run all tests
bin/rails test:system            # Run system tests only
bin/rails test path/to/test.rb   # Run specific test file
```

### Database Operations
```bash
bin/rails db:create              # Create databases
bin/rails db:migrate             # Run pending migrations
bin/rails db:rollback            # Rollback last migration
bin/rails db:seed                # Load seed data
bin/rails db:reset               # Drop, create, migrate, and seed
```

### Code Quality
```bash
bundle exec rubocop              # Check code style (required before commits)
bundle exec rubocop -a           # Auto-fix style issues
bundle exec brakeman             # Security vulnerability scan
```

### Asset Management
```bash
bin/rails assets:precompile      # Compile assets for production
bin/rails assets:clobber         # Remove compiled assets
```

### Console and Debugging
```bash
bin/rails console               # Interactive Rails console
bin/rails dbconsole            # Direct database console
```

## Application Architecture

### Current State
- **Fresh Rails 8 installation** with default structure
- Uses **SQLite** databases (development.sqlite3, test.sqlite3)
- No custom models, controllers, or routes yet (beyond defaults)
- No existing migrations (schema version: 0)

### Rails 8 Features Enabled
- **Solid Queue** - Background job processing (replaces Redis for most cases)
- **Solid Cache** - Application caching
- **Solid Cable** - WebSocket connections
- **Hotwire (Turbo + Stimulus)** - Frontend interactivity without heavy JavaScript
- **Importmap** - JavaScript module management
- **Propshaft** - Modern asset pipeline

### Key Configuration
- Application class: `EuFunding::Application`
- Modern browser requirement enforced (`allow_browser versions: :modern`)
- Health check endpoint available at `/up`
- PWA support ready (commented out in routes)

### Development Guidelines
The project includes comprehensive development rules in `AGENTS.md` covering:
- **Ruby 3.4** specific features (including `it` parameter syntax)
- **Rails 8 MVC** architecture patterns
- **Strong Parameters** enforcement
- **Hotwire/Turbo** best practices
- **Testing** with Minitest
- **Security** guidelines
- **Performance** considerations

### Testing Framework
- Uses **Minitest** (Rails default)
- System tests configured with **Capybara** and **Selenium WebDriver**
- Test files should follow Rails conventions: `test/models/`, `test/controllers/`, etc.

### Code Style
- **RuboCop Rails Omakase** configuration enforced
- **Always run `bundle exec rubocop`** before committing
- Brakeman security scanning enabled

### Git Workflow
- **IMPORTANT: Commit frequently after small batches of work**
- Run `bundle exec rubocop` before every commit
- Use descriptive commit messages following conventional commits format
- Each commit should represent a complete, working change

### Dependencies Management
- Use **Bundler** for gem management
- Run `bundle install` after Gemfile changes
- Avoid conflicting gems that solve the same problem

This is a clean slate Rails 8 application ready for feature development following modern Rails patterns and conventions.