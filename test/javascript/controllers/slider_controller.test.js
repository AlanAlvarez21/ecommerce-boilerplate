import { Application } from "@hotwired/stimulus";
import SliderController from "../../../app/javascript/controllers/slider_controller";

// Mock timers
jest.useFakeTimers();

describe("SliderController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM with slider
    document.body.innerHTML = `
      <div data-controller="slider">
        <div data-slider-target="slider" style="display: flex;">
          <div class="slide">Slide 1</div>
          <div class="slide">Slide 2</div>
          <div class="slide">Slide 3</div>
        </div>
        <button data-action="click->slider#previousSlide">Previous</button>
        <button data-action="click->slider#nextSlide">Next</button>
      </div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("slider", SliderController);
    
    element = document.querySelector('[data-controller="slider"]');
    controller = application.getControllerForElementAndIdentifier(element, "slider");
    
    // Clear timers
    jest.clearAllTimers();
  });

  afterEach(() => {
    application.stop();
    jest.clearAllTimers();
  });

  describe("connect", () => {
    it("initializes currentSlide to 0", () => {
      controller.connect();
      expect(controller.currentSlide).toBe(0);
    });

    it("sets totalSlides based on slider children", () => {
      controller.connect();
      expect(controller.totalSlides).toBe(3);
    });

    it("starts auto slide", () => {
      controller.connect();
      expect(controller.autoSlideInterval).toBeDefined();
    });

    it("auto advances slides every 5 seconds", () => {
      controller.connect();
      expect(controller.currentSlide).toBe(0);
      
      jest.advanceTimersByTime(5000);
      expect(controller.currentSlide).toBe(1);
      
      jest.advanceTimersByTime(5000);
      expect(controller.currentSlide).toBe(2);
      
      jest.advanceTimersByTime(5000);
      expect(controller.currentSlide).toBe(0); // Should wrap around
    });
  });

  describe("disconnect", () => {
    it("stops auto slide", () => {
      controller.connect();
      const intervalId = controller.autoSlideInterval;
      
      controller.disconnect();
      
      expect(controller.autoSlideInterval).toBeNull();
    });
  });

  describe("showSlide", () => {
    beforeEach(() => {
      controller.connect();
    });

    it("updates currentSlide", () => {
      controller.showSlide(1);
      expect(controller.currentSlide).toBe(1);
    });

    it("wraps around when index is negative", () => {
      controller.showSlide(-1);
      expect(controller.currentSlide).toBe(2); // Last slide
    });

    it "wraps around when index exceeds total slides", () => {
      controller.showSlide(3);
      expect(controller.currentSlide).toBe(0); // First slide
    });

    it("applies transform to slider element", () => {
      controller.showSlide(1);
      expect(controller.sliderTarget.style.transform).toBe("translateX(-100%)");
      
      controller.showSlide(2);
      expect(controller.sliderTarget.style.transform).toBe("translateX(-200%)");
    });
  });

  describe("previousSlide", () => {
    beforeEach(() => {
      controller.connect();
      controller.showSlide(1); // Start at slide 1
    });

    it("moves to previous slide", () => {
      controller.previousSlide();
      expect(controller.currentSlide).toBe(0);
    });

    it("wraps to last slide when at first slide", () => {
      controller.showSlide(0);
      controller.previousSlide();
      expect(controller.currentSlide).toBe(2);
    });

    it("pauses and restarts auto slide", () => {
      controller.previousSlide();
      
      // Auto slide should be paused
      expect(controller.autoSlideInterval).toBeNull();
      
      // After 10 seconds, auto slide should restart
      jest.advanceTimersByTime(10000);
      expect(controller.autoSlideInterval).toBeDefined();
    });
  });

  describe("nextSlide", () => {
    beforeEach(() => {
      controller.connect();
    });

    it("moves to next slide", () => {
      controller.nextSlide();
      expect(controller.currentSlide).toBe(1);
    });

    it("wraps to first slide when at last slide", () => {
      controller.showSlide(2);
      controller.nextSlide();
      expect(controller.currentSlide).toBe(0);
    });

    it("pauses and restarts auto slide", () => {
      controller.nextSlide();
      
      // Auto slide should be paused
      expect(controller.autoSlideInterval).toBeNull();
      
      // After 10 seconds, auto slide should restart
      jest.advanceTimersByTime(10000);
      expect(controller.autoSlideInterval).toBeDefined();
    });
  });

  describe("startAutoSlide", () => {
    beforeEach(() => {
      controller.connect();
    });

    it("creates an interval", () => {
      controller.stopAutoSlide();
      controller.startAutoSlide();
      expect(controller.autoSlideInterval).toBeDefined();
    });

    it("advances slide every 5 seconds", () => {
      controller.stopAutoSlide();
      controller.currentSlide = 0;
      controller.startAutoSlide();
      
      jest.advanceTimersByTime(5000);
      expect(controller.currentSlide).toBe(1);
    });
  });

  describe("stopAutoSlide", () => {
    beforeEach(() => {
      controller.connect();
    });

    it("clears the interval", () => {
      controller.stopAutoSlide();
      expect(controller.autoSlideInterval).toBeNull();
    });

    it("handles case when interval is already null", () => {
      controller.stopAutoSlide();
      expect(() => controller.stopAutoSlide()).not.toThrow();
    });
  });

  describe("pauseAutoSlide", () => {
    beforeEach(() => {
      controller.connect();
    });

    it("stops auto slide immediately", () => {
      controller.pauseAutoSlide();
      expect(controller.autoSlideInterval).toBeNull();
    });

    it("restarts auto slide after 10 seconds if element is connected", () => {
      // Mock element.isConnected
      Object.defineProperty(controller.element, 'isConnected', {
        value: true,
        writable: true
      });
      
      controller.pauseAutoSlide();
      expect(controller.autoSlideInterval).toBeNull();
      
      jest.advanceTimersByTime(10000);
      expect(controller.autoSlideInterval).toBeDefined();
    });

    it("does not restart auto slide if element is disconnected", () => {
      // Mock element.isConnected as false
      Object.defineProperty(controller.element, 'isConnected', {
        value: false,
        writable: true
      });
      
      controller.pauseAutoSlide();
      expect(controller.autoSlideInterval).toBeNull();
      
      jest.advanceTimersByTime(10000);
      expect(controller.autoSlideInterval).toBeNull();
    });
  });

  describe("with no slides", () => {
    beforeEach(() => {
      // Create slider with no children
      document.body.innerHTML = `
        <div data-controller="slider">
          <div data-slider-target="slider" style="display: flex;">
          </div>
        </div>
      `;
      
      element = document.querySelector('[data-controller="slider"]');
      controller = application.getControllerForElementAndIdentifier(element, "slider");
    });

    it("handles empty slider gracefully", () => {
      controller.connect();
      expect(controller.totalSlides).toBe(0);
      expect(controller.currentSlide).toBe(0);
      
      // These should not cause errors
      controller.showSlide(1);
      controller.nextSlide();
      controller.previousSlide();
    });
  });
});