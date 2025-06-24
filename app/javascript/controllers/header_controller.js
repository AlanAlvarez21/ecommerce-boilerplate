// app/javascript/controllers/header_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cartCount", "mobileMenu"]

  connect() {
    this.updateCartCount();
    
    // Actualizar contador cada vez que cambie el localStorage
    window.addEventListener('storage', () => this.updateCartCount());
    
    // Actualizar contador cuando se dispare evento personalizado
    window.addEventListener('cartUpdated', () => this.updateCartCount());
  }

  disconnect() {
    window.removeEventListener('storage', () => this.updateCartCount());
    window.removeEventListener('cartUpdated', () => this.updateCartCount());
  }

  updateCartCount() {
    const cart = JSON.parse(localStorage.getItem("cart")) || [];
    const totalQuantity = cart.reduce((total, item) => total + parseInt(item.quantity), 0);
        
    if (this.hasCartCountTarget) {
      const cartCountElement = this.cartCountTarget;
      
      if (totalQuantity > 0) {
        cartCountElement.textContent = totalQuantity;
        cartCountElement.style.display = 'flex';
      } else {
        cartCountElement.style.display = 'none';
      }
    }
  }

  toggleMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.toggle('hidden');
    }
  }
}