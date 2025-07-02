import { Application } from "@hotwired/stimulus";
import ProductsController from "../../../app/javascript/controllers/products_controller";

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Mock window methods
global.CustomEvent = jest.fn();
global.dispatchEvent = jest.fn();

describe("ProductsController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div data-controller="products" 
           data-products-product-value='{"id":"1","name":"Test Product","price":100,"image_url":"test.jpg"}'
           data-products-size-value="">
        <button value="M" data-action="click->products#selectSize">M</button>
        <button value="L" data-action="click->products#selectSize">L</button>
        <button data-products-target="addButton" data-action="click->products#addToCart" disabled>
          Selecciona un tamaño
        </button>
        <div id="selected-size"></div>
      </div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("products", ProductsController);
    
    element = document.querySelector('[data-controller="products"]');
    controller = application.getControllerForElementAndIdentifier(element, "products");
    
    // Clear mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    application.stop();
  });

  describe("connect", () => {
    it("logs connection and product value", () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
      
      controller.connect();
      
      expect(consoleSpy).toHaveBeenCalledWith("Products controller connected");
      expect(consoleSpy).toHaveBeenCalledWith("Product value:", controller.productValue);
      
      consoleSpy.mockRestore();
    });
  });

  describe("selectSize", () => {
    it("sets size value and updates UI", () => {
      const button = document.querySelector('[value="M"]');
      const mockEvent = { target: button };
      
      controller.selectSize(mockEvent);
      
      expect(controller.sizeValue).toBe("M");
      expect(button.classList.contains('ring-2')).toBe(true);
      expect(button.classList.contains('ring-emerald-400')).toBe(true);
      
      const selectedSizeEl = document.getElementById("selected-size");
      expect(selectedSizeEl.innerText).toBe("Tamaño seleccionado: M");
    });

    it("removes previous selection when selecting new size", () => {
      const buttonM = document.querySelector('[value="M"]');
      const buttonL = document.querySelector('[value="L"]');
      
      // Select M first
      controller.selectSize({ target: buttonM });
      expect(buttonM.classList.contains('ring-2')).toBe(true);
      
      // Select L
      controller.selectSize({ target: buttonL });
      expect(buttonM.classList.contains('ring-2')).toBe(false);
      expect(buttonL.classList.contains('ring-2')).toBe(true);
    });

    it("enables add button after size selection", () => {
      const button = document.querySelector('[value="M"]');
      const addButton = controller.addButtonTarget;
      
      controller.selectSize({ target: button });
      
      expect(addButton.disabled).toBe(false);
      expect(addButton.classList.contains('bg-emerald-600')).toBe(true);
      expect(addButton.textContent).toBe('Añadir al Carrito');
    });
  });

  describe("addToCart", () => {
    beforeEach(() => {
      controller.sizeValue = "M";
    });

    it("returns early if no size is selected", () => {
      controller.sizeValue = "";
      
      controller.addToCart();
      
      expect(localStorageMock.getItem).not.toHaveBeenCalled();
    });

    it("adds new item to empty cart", () => {
      localStorageMock.getItem.mockReturnValue(null);
      
      controller.addToCart();
      
      const expectedItem = {
        id: "1",
        name: "Test Product",
        price: 100,
        size: "M",
        quantity: 1
      };
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart",
        JSON.stringify([expectedItem])
      );
    });

    it("adds new item to existing cart", () => {
      const existingCart = [
        { id: "2", name: "Other Product", price: 50, size: "L", quantity: 1 }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(existingCart));
      
      controller.addToCart();
      
      const expectedCart = [
        ...existingCart,
        {
          id: "1",
          name: "Test Product",
          price: 100,
          size: "M",
          quantity: 1,
          image_url: "test.jpg"
        }
      ];
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart",
        JSON.stringify(expectedCart)
      );
    });

    it("increments quantity for existing item with same id and size", () => {
      const existingCart = [
        { id: "1", name: "Test Product", price: 100, size: "M", quantity: 2 }
      ];
      localStorageMock.getItem.mockReturnValue(JSON.stringify(existingCart));
      
      controller.addToCart();
      
      const expectedCart = [
        { id: "1", name: "Test Product", price: 100, size: "M", quantity: 3 }
      ];
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        "cart",
        JSON.stringify(expectedCart)
      );
    });

    it("dispatches cartUpdated event", () => {
      localStorageMock.getItem.mockReturnValue(null);
      
      controller.addToCart();
      
      expect(global.CustomEvent).toHaveBeenCalledWith('cartUpdated');
    });
  });

  describe("showSuccessMessage", () => {
    it("shows success message and resets button", (done) => {
      const addButton = controller.addButtonTarget;
      const originalText = addButton.textContent;
      
      controller.showSuccessMessage();
      
      expect(addButton.textContent).toBe('¡Agregado!');
      expect(addButton.classList.contains('bg-green-600')).toBe(true);
      
      // Test that it resets after timeout
      setTimeout(() => {
        expect(addButton.textContent).toBe(originalText);
        expect(addButton.classList.contains('bg-emerald-600')).toBe(true);
        done();
      }, 2100); // Slightly more than the 2000ms timeout
    });
  });

  describe("enableAddButton", () => {
    it("enables and styles the add button", () => {
      const addButton = controller.addButtonTarget;
      addButton.disabled = true;
      addButton.classList.add('opacity-50', 'cursor-not-allowed', 'bg-slate-400');
      
      controller.enableAddButton();
      
      expect(addButton.disabled).toBe(false);
      expect(addButton.classList.contains('opacity-50')).toBe(false);
      expect(addButton.classList.contains('bg-emerald-600')).toBe(true);
      expect(addButton.textContent).toBe('Añadir al Carrito');
    });
  });
});