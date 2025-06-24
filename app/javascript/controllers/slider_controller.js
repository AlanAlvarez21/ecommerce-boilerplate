// app/javascript/controllers/slider_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider"]

  connect() {  
    this.currentSlide = 0;
    this.totalSlides = this.sliderTarget.children.length;    
    this.startAutoSlide();
  }

  disconnect() {
    this.stopAutoSlide();
  }

  showSlide(index) {
    this.currentSlide = (index + this.totalSlides) % this.totalSlides;
    this.sliderTarget.style.transform = `translateX(-${this.currentSlide * 100}%)`;
  }

  previousSlide() {
    this.pauseAutoSlide();
    this.showSlide(this.currentSlide - 1);
  }

  nextSlide() {
    this.pauseAutoSlide();
    this.showSlide(this.currentSlide + 1);
  }

  startAutoSlide() {
    this.autoSlideInterval = setInterval(() => {
      this.showSlide(this.currentSlide + 1);
    }, 5000);
  }

  stopAutoSlide() {
    if (this.autoSlideInterval) {
      clearInterval(this.autoSlideInterval);
      this.autoSlideInterval = null;
    }
  }

  pauseAutoSlide() {
    this.stopAutoSlide();
    // Reiniciar después de 10 segundos
    setTimeout(() => {
      if (this.element.isConnected) { // Solo si el elemento sigue en el DOM
        this.startAutoSlide();
      }
    }, 10000);
  }
}