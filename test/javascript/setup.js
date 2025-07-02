import '@testing-library/jest-dom';

// Mock Stimulus application
global.Application = {
  register: jest.fn(),
  getControllerForElementAndIdentifier: jest.fn(),
  start: jest.fn()
};

// Mock Turbo
global.Turbo = {
  visit: jest.fn(),
  cache: {
    clear: jest.fn()
  }
};