import { Application } from "@hotwired/stimulus";
import HelloController from "../../../app/javascript/controllers/hello_controller";

describe("HelloController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div data-controller="hello">
        Original Text
      </div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("hello", HelloController);
    
    element = document.querySelector('[data-controller="hello"]');
    controller = application.getControllerForElementAndIdentifier(element, "hello");
  });

  afterEach(() => {
    application.stop();
  });

  describe("connect", () => {
    it("changes element text to 'Hello World!'", () => {
      expect(element.textContent).toBe("Original Text");
      
      controller.connect();
      
      expect(element.textContent).toBe("Hello World!");
    });

    it("overwrites existing text content", () => {
      element.innerHTML = "<span>Complex HTML Content</span>";
      
      controller.connect();
      
      expect(element.textContent).toBe("Hello World!");
      expect(element.innerHTML).toBe("Hello World!");
    });

    it("works with empty element", () => {
      element.textContent = "";
      
      controller.connect();
      
      expect(element.textContent).toBe("Hello World!");
    });

    it("works when called multiple times", () => {
      controller.connect();
      expect(element.textContent).toBe("Hello World!");
      
      controller.connect();
      expect(element.textContent).toBe("Hello World!");
    });
  });
});