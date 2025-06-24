# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Setup

This is a Rails 8.0.1 ecommerce application running Ruby 3.3.4, using Docker with devcontainers for development.

### Prerequisites
- Docker
- Devcontainers CLI (`npm install -g @devcontainers/cli`)

### Development Commands

- **Initial setup**: `bin/build_container` - Builds the devcontainer and sets up the database
- **Start development server**: `bin/dev` - Starts Rails server (port 3000) and Tailwind CSS watcher
- **Database seeds**: `bin/rails db:seed`
- **Run tests**: `bin/rails test`
- **Linting**: `bin/rubocop` (Ruby code style)
- **Security scan**: `bin/brakeman` (security vulnerability scanner)

### Individual Commands
- Rails server only: `bin/rails server`
- Tailwind watcher only: `bin/rails tailwindcss:watch`
- Database operations: `bin/rails db:create db:migrate db:seed`

## Architecture Overview

### Core Models
- **Admin**: User authentication via Devise
- **Category**: Product categories with image support
- **Product**: Main products with Active Storage images and stock management
- **Stock**: Inventory tracking for products
- **Order & OrderProduct**: E-commerce order system
- **Coins**: Price tracking for coins/precious metals

### Key Controllers
- **AdminController**: Dashboard and admin authentication
- **Admin namespace**: CRUD operations for categories, products, orders, stocks
- **CartController**: Shopping cart functionality
- **CheckoutController**: Payment processing with MercadoPago integration
- **HomeController**: Main landing page
- **PricesController**: Coin price display (precios route)

### Frontend Stack
- **Stimulus**: JavaScript framework for interactive components
- **Turbo**: SPA-like navigation
- **Tailwind CSS**: Utility-first CSS framework
- **Importmap**: ES6 module management

### Key Services
- **MercadoPagoSdk**: Payment processing integration
- **BbvaScrapper**: External price data scraping
- **UpdateCoinPricesJob**: Background job for price updates

### Authentication
- Admin authentication using Devise
- Separate admin namespace with protected routes
- Admin registration handled via custom controller

### Current Branch Context
Working on `cart-logic` branch with recent changes to:
- Cart controller JavaScript functionality
- Checkout controller implementation
- MercadoPago SDK integration
- Menu controller for navigation

### Test Structure
- Standard Rails test structure with fixtures
- System tests for admin interfaces
- Controller and model tests
- Job tests for background processing