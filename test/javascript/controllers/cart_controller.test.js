import { Application } from "@hotwired/stimulus";
import CartController from "../../../app/javascript/controllers/cart_controller";

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Mock window methods
global.alert = jest.fn();
global.confirm = jest.fn();
global.CustomEvent = jest.fn();
global.dispatchEvent = jest.fn();

describe("CartController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div data-controller="cart">
        <div id="cart-items"></div>
        <div id="total"></div>
        <input data-cart-target="streetName" />
        <input data-cart-target="streetNumber" />
        <input data-cart-target="email" />
        <input data-cart-target="zipCode" />
        <button data-action="click->cart#checkout">Checkout</button>
      </div>
      <template id="cart-item-template">
        <div class="cart-item">
          <span data-field="name"></span>
          <span data-field="size"></span>
          <span data-field="price"></span>
          <span data-field="total-price"></span>
          <input data-field="quantity-input" type="number" />
          <img data-field="image" />
          <div class="fallback-icon" style="display: none;"></div>
          <button data-action="click->cart#removeItem">Remove</button>
        </div>
      </template>
      <template id="empty-cart-template">
        <div class="empty-cart">Your cart is empty</div>
      </template>
      <template id="total-template">
        <div class="total">
          <span data-field="subtotal"></span>
          <span data-field="total"></span>
        </div>
      </template>
      <meta name="csrf-token" content="test-token" />
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("cart", CartController);
    
    element = document.querySelector('[data-controller="cart"]');
    controller = application.getControllerForElementAndIdentifier(element, "cart");
    
    // Clear mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    application.stop();
  });

  describe("connect", () => {
    it("loads cart on connect", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 2, size: "M" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.connect();
      
      expect(localStorageMock.getItem).toHaveBeenCalledWith("cart");
    });
  });

  describe("loadCart", () => {
    it("shows empty cart when no items", () => {
      localStorageMock.getItem.mockReturnValue(null);
      
      controller.loadCart();
      
      const cartItems = document.getElementById("cart-items");
      expect(cartItems.innerHTML).toContain("Your cart is empty");
    });

    it("displays cart items and calculates total", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 2, size: "M", image_url: "test.jpg" },
        { id: "2", name: "Product 2", price: 50, quantity: 1, size: "L" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.loadCart();
      
      const cartItems = document.getElementById("cart-items");
      expect(cartItems.children.length).toBe(2);
      
      const totalElement = document.getElementById("total");
      expect(totalElement.innerHTML).toContain("250"); // 100*2 + 50*1 = 250
    });
  });

  describe("removeItem", () => {
    it("removes item from cart and updates localStorage", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 2, size: "M" },
        { id: "2", name: "Product 2", price: 50, quantity: 1, size: "L" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      const mockEvent = {
        currentTarget: {
          dataset: { itemId: "1", itemSize: "M" }
        }
      };
      
      controller.removeItem(mockEvent);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart", 
        JSON.stringify([{ id: "2", name: "Product 2", price: 50, quantity: 1, size: "L" }])
      );
    });
  });

  describe("updateItemQuantity", () => {
    it("increases item quantity", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 2, size: "M" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.updateItemQuantity("1", "M", 1);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart",
        JSON.stringify([{ id: "1", name: "Product 1", price: 100, quantity: 3, size: "M" }])
      );
    });

    it("removes item when quantity becomes 0", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 1, size: "M" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.updateItemQuantity("1", "M", -1);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith("cart", JSON.stringify([]));
    });

    it("limits quantity to maximum of 99", () => {
      const mockCart = [
        { id: "1", name: "Product 1", price: 100, quantity: 98, size: "M" }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      controller.updateItemQuantity("1", "M", 2);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart",
        JSON.stringify([{ id: "1", name: "Product 1", price: 100, quantity: 99, size: "M" }])
      );
    });
  });

  describe("clear", () => {
    it("clears cart when user confirms", () => {
      global.confirm.mockReturnValue(true);
      
      controller.clear();
      
      expect(localStorageMock.removeItem).toHaveBeenCalledWith("cart");
    });

    it("does not clear cart when user cancels", () => {
      global.confirm.mockReturnValue(false);
      
      controller.clear();
      
      expect(localStorageMock.removeItem).not.toHaveBeenCalled();
    });
  });

  describe("checkout", () => {
    beforeEach(() => {
      controller.streetNameTarget = { value: "Main St" };
      controller.streetNumberTarget = { value: "123" };
      controller.emailTarget = { value: "test@example.com" };
      controller.zipCodeTarget = { value: "12345" };
    });

    it("alerts when cart is empty", () => {
      localStorageMock.getItem.mockReturnValue(null);
      
      controller.checkout();
      
      expect(global.alert).toHaveBeenCalledWith("Your cart is empty");
    });

    it("alerts when required fields are missing", () => {
      const mockCart = [{ id: "1", name: "Product 1", price: 100, quantity: 1, size: "M" }];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      controller.streetNameTarget.value = "";
      
      controller.checkout();
      
      expect(global.alert).toHaveBeenCalledWith("Please fill in all required fields");
    });

    it("alerts when email is invalid", () => {
      const mockCart = [{ id: "1", name: "Product 1", price: 100, quantity: 1, size: "M" }];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      controller.emailTarget.value = "invalid-email";
      
      controller.checkout();
      
      expect(global.alert).toHaveBeenCalledWith("Please enter a valid email address");
    });

    it("creates and submits form with valid data", () => {
      const mockCart = [{ id: "1", name: "Product 1", price: 100, quantity: 1, size: "M" }];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(mockCart));
      
      // Mock form submission
      const mockForm = {
        submit: jest.fn(),
        appendChild: jest.fn(),
        method: "",
        action: ""
      };
      const createElementSpy = jest.spyOn(document, 'createElement');
      createElementSpy.mockReturnValue(mockForm);
      
      controller.checkout();
      
      expect(mockForm.method).toBe("POST");
      expect(mockForm.action).toBe("/checkout");
      expect(mockForm.submit).toHaveBeenCalled();
      
      createElementSpy.mockRestore();
    });
  });

  describe("isValidEmail", () => {
    it("validates correct email format", () => {
      expect(controller.isValidEmail("test@example.com")).toBe(true);
      expect(controller.isValidEmail("user.name+tag@domain.co.uk")).toBe(true);
    });

    it("rejects invalid email format", () => {
      expect(controller.isValidEmail("invalid-email")).toBe(false);
      expect(controller.isValidEmail("@domain.com")).toBe(false);
      expect(controller.isValidEmail("user@")).toBe(false);
      expect(controller.isValidEmail("")).toBe(false);
    });
  });
});