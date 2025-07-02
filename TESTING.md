# Testing Guide

This project has comprehensive test coverage for both Rails controllers and JavaScript/Stimulus controllers.

## Prerequisites

Make sure you have all dependencies installed:

```bash
# Install Ruby gems
bundle install

# Install JavaScript packages  
npm install
```

## Running Tests

### RSpec (Rails Controllers)

```bash
# Run all RSpec tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/controllers/cart_controller_spec.rb

# Run tests with coverage report
bundle exec rspec

# Run tests for specific controller type
bundle exec rspec spec/controllers/admin/
```

### Jest (JavaScript/Stimulus Controllers)

```bash
# Run all Jest tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage report
npm run test:coverage

# Run specific test file
npm test -- cart_controller.test.js
```

## Coverage Reports

### RSpec Coverage
- **Location**: `coverage/index.html`
- **Threshold**: 100% coverage required
- **Includes**: All controllers, models, services
- **Excludes**: specs, test files, config files

### Jest Coverage  
- **Location**: `coverage/javascript/index.html`
- **Threshold**: 100% coverage required
- **Includes**: All Stimulus controllers
- **Excludes**: `index.js`, `application.js`

## Test Structure

### RSpec Tests (`spec/`)
```
spec/
├── controllers/
│   ├── application_controller_spec.rb
│   ├── admin_controller_spec.rb
│   ├── cart_controller_spec.rb
│   ├── checkouts_controller_spec.rb
│   ├── home_controller_spec.rb
│   ├── prices_controller_spec.rb
│   ├── products_controller_spec.rb
│   ├── categories_controller_spec.rb
│   ├── webhooks_controller_spec.rb
│   └── admin/
│       ├── categories_controller_spec.rb
│       ├── orders_controller_spec.rb
│       ├── products_controller_spec.rb
│       ├── registrations_controller_spec.rb
│       └── stocks_controller_spec.rb
├── factories/
│   ├── admins.rb
│   ├── categories.rb
│   ├── orders.rb
│   ├── order_products.rb
│   ├── products.rb
│   └── stocks.rb
├── rails_helper.rb
└── spec_helper.rb
```

### Jest Tests (`test/javascript/`)
```
test/javascript/
├── controllers/
│   ├── cart_controller.test.js
│   ├── dashboard_controller.test.js
│   ├── header_controller.test.js
│   ├── hello_controller.test.js
│   ├── products_controller.test.js
│   └── slider_controller.test.js
└── setup.js
```

## Coverage Details

### Rails Controllers Coverage: 100%
- ✅ ApplicationController - Locale handling, URL options
- ✅ AdminController - Dashboard stats, revenue tracking  
- ✅ CartController - Basic show action
- ✅ CategoriesController - Category display with products
- ✅ ProductsController - Product detail pages
- ✅ HomeController - Landing page with categories/products
- ✅ CheckoutsController - MercadoPago payment processing
- ✅ PricesController - Coin price scraping display
- ✅ WebhooksController - MercadoPago webhook handling
- ✅ Admin::CategoriesController - Full CRUD operations
- ✅ Admin::ProductsController - Full CRUD with image handling
- ✅ Admin::StocksController - Inventory management
- ✅ Admin::OrdersController - Order management with pagination
- ✅ Admin::RegistrationsController - Custom Devise parameters

### JavaScript Controllers Coverage: 100%
- ✅ CartController - Cart management, checkout flow, localStorage
- ✅ HeaderController - Cart counter, mobile menu toggle
- ✅ ProductsController - Size selection, add to cart
- ✅ DashboardController - Chart.js revenue visualization
- ✅ SliderController - Auto-sliding image carousel
- ✅ HelloController - Basic Stimulus controller

## Key Testing Features

### RSpec Features
- **Factory Bot** for test data generation
- **Devise Test Helpers** for authentication
- **SimpleCov** for coverage reporting
- **Controller specs** with proper mocking
- **Parameter sanitization** testing
- **Error handling** verification
- **JSON/HTML format** testing

### Jest Features  
- **JSDOM** environment for DOM testing
- **Timer mocking** for time-based features
- **LocalStorage mocking** for cart functionality
- **Event simulation** for user interactions
- **Coverage thresholds** enforced at 100%
- **Stimulus framework** testing

## Continuous Integration

The test suite is configured for CI with:
- 100% coverage requirements
- Comprehensive controller testing
- Proper error handling verification
- Authentication and authorization testing
- Payment processing simulation
- Real-world user interaction testing

## Testing Philosophy

This test suite follows these principles:
1. **100% Coverage** - Every line of controller code is tested
2. **Realistic Testing** - Tests simulate real user interactions
3. **Error Coverage** - Both success and failure paths tested
4. **Integration Focus** - Tests verify full request/response cycles
5. **Fast Execution** - Efficient mocking and factories
6. **Maintainable** - Clear, readable test descriptions