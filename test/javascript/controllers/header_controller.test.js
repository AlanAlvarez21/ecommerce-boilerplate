import { Application } from "@hotwired/stimulus";
import HeaderController from "../../../app/javascript/controllers/header_controller";

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Mock window methods
global.addEventListener = jest.fn();
global.removeEventListener = jest.fn();

describe("HeaderController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div data-controller="header">
        <span data-header-target="cartCount" class="cart-count">0</span>
        <div data-header-target="mobileMenu" class="mobile-menu hidden">
          <nav>Mobile Menu</nav>
        </div>
        <button data-action="click->header#toggleMobileMenu">Menu</button>
      </div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("header", HeaderController);
    
    element = document.querySelector('[data-controller="header"]');
    controller = application.getControllerForElementAndIdentifier(element, "header");
    
    // Clear mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    application.stop();
  });

  describe("connect", () => {
    it("sets up event listeners and updates cart count", () => {
      controller.connect();
      
      expect(global.addEventListener).toHaveBeenCalledWith('storage', expect.any(Function));
      expect(global.addEventListener).toHaveBeenCalledWith('cartUpdated', expect.any(Function));
    });
  });

  describe("disconnect", () => {
    it("removes event listeners", () => {
      controller.disconnect();
      
      expect(global.removeEventListener).toHaveBeenCalledWith('storage', expect.any(Function));
      expect(global.removeEventListener).toHaveBeenCalledWith('cartUpdated', expect.any(Function));
    });
  });

  describe("updateCartCount", () => {
    it("shows cart count when cart has items", () => {
      const mockCart = [
        { id: "1", quantity: 2 },
        { id: "2", quantity: 3 }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.updateCartCount();
      
      const cartCountElement = controller.cartCountTarget;
      expect(cartCountElement.textContent).toBe("5"); // 2 + 3
      expect(cartCountElement.style.display).toBe("flex");
    });

    it("hides cart count when cart is empty", () => {
      localStorageMock.getItem.mockReturnValue(JSON.stringify([]));
      
      controller.updateCartCount();
      
      const cartCountElement = controller.cartCountTarget;
      expect(cartCountElement.style.display).toBe("none");
    });

    it("handles null cart gracefully", () => {
      localStorageMock.getItem.mockReturnValue(null);
      
      controller.updateCartCount();
      
      const cartCountElement = controller.cartCountTarget;
      expect(cartCountElement.style.display).toBe("none");
    });

    it("calculates total quantity correctly", () => {
      const mockCart = [
        { id: "1", quantity: "2" }, // String quantities should be parsed
        { id: "2", quantity: 1 },
        { id: "3", quantity: "5" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.updateCartCount();
      
      const cartCountElement = controller.cartCountTarget;
      expect(cartCountElement.textContent).toBe("8"); // 2 + 1 + 5
    });
  });

  describe("toggleMobileMenu", () => {
    it("toggles hidden class on mobile menu", () => {
      const mobileMenu = controller.mobileMenuTarget;
      
      expect(mobileMenu.classList.contains('hidden')).toBe(true);
      
      controller.toggleMobileMenu();
      expect(mobileMenu.classList.contains('hidden')).toBe(false);
      
      controller.toggleMobileMenu();
      expect(mobileMenu.classList.contains('hidden')).toBe(true);
    });

    it("handles missing mobile menu target gracefully", () => {
      // Remove the mobile menu element
      controller.mobileMenuTarget.remove();
      
      // This should not throw an error
      expect(() => controller.toggleMobileMenu()).not.toThrow();
    });
  });
});