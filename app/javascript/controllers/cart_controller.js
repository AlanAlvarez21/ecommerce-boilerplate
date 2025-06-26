import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {

  static targets = ["streetName", "streetNumber", "email", "zipCode"]

  connect(){
    console.log("Cart controller connected - Template based");
    this.loadCart();
  }
  
  loadCart() {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const cartItems = document.getElementById("cart-items");
    
    if (!cart || cart.length === 0) {
      this.showEmptyCart();
      return;
    }

    let total = 0;
    cartItems.innerHTML = '';
    
    cart.forEach((item, index) => {
      total += item.price * item.quantity;
      const itemElement = this.createCartItem(item, index);
      cartItems.appendChild(itemElement);
    });
    
    this.updateTotal(total);
  }
  
  createCartItem(item, index) {
    const template = document.getElementById('cart-item-template');
    const itemElement = template.content.cloneNode(true);
    
    // Populate data fields
    itemElement.querySelector('[data-field="name"]').textContent = item.name;
    itemElement.querySelector('[data-field="size"]').textContent = item.size;
    itemElement.querySelector('[data-field="price"]').textContent = `${item.price.toLocaleString()}`;
    
    // Set quantity in input
    const quantityInput = itemElement.querySelector('[data-field="quantity-input"]');
    quantityInput.value = item.quantity;
    
    // Set product image
    const imageElement = itemElement.querySelector('[data-field="image"]');
    if (item.image_url) {
      imageElement.src = item.image_url;
      imageElement.alt = item.name;
      console.log('Setting image URL:', item.image_url); // Debug
    } else {
      console.log('No image URL found for item:', item); // Debug
      // If no image URL, show fallback icon
      imageElement.style.display = 'none';
      imageElement.nextElementSibling.style.display = 'flex';
    }
    
    // Show total price if quantity > 1
    const totalPriceElement = itemElement.querySelector('[data-field="total-price"]');
    if (item.quantity > 1) {
      totalPriceElement.textContent = `(${(item.price * item.quantity).toLocaleString()} total)`;
    } else {
      totalPriceElement.style.display = 'none';
    }
    
    // Set up data attributes for all quantity controls
    const quantityControls = itemElement.querySelectorAll('[data-action*="quantity"], [data-action*="Quantity"]');
    quantityControls.forEach(control => {
      control.dataset.itemId = item.id;
      control.dataset.itemSize = item.size;
      control.dataset.itemIndex = index;
    });
    
    // Set up remove button
    const removeButton = itemElement.querySelector('[data-action="click->cart#removeItem"]');
    removeButton.dataset.itemId = item.id;
    removeButton.dataset.itemSize = item.size;
    removeButton.dataset.itemIndex = index;
    
    return itemElement;
  }
  
  showEmptyCart() {
    const cartItems = document.getElementById("cart-items");
    const template = document.getElementById('empty-cart-template');
    cartItems.innerHTML = '';
    cartItems.appendChild(template.content.cloneNode(true));
    
    // Clear total
    document.getElementById("total").innerHTML = '';
  }
  
  updateTotal(total) {
    const totalContainer = document.getElementById("total");
    const template = document.getElementById('total-template');
    const totalElement = template.content.cloneNode(true);
    
    totalElement.querySelector('[data-field="subtotal"]').textContent = `$${total.toLocaleString()}`;
    totalElement.querySelector('[data-field="total"]').textContent = `$${total.toLocaleString()}`;
    
    totalContainer.innerHTML = '';
    totalContainer.appendChild(totalElement);
  }

  removeItem(event) {
    const button = event.currentTarget;
    const itemId = button.dataset.itemId;
    const itemSize = button.dataset.itemSize;
    
    const cart = JSON.parse(localStorage.getItem("cart"));
    const itemIndex = cart.findIndex(item => item.id === itemId && item.size === itemSize);
    
    if (itemIndex >= 0) {
      cart.splice(itemIndex, 1);
      localStorage.setItem("cart", JSON.stringify(cart));
      window.dispatchEvent(new CustomEvent('cartUpdated'));
      this.loadCart();
    }
  }

  increaseQuantity(event) {
    const button = event.currentTarget;
    const itemId = button.dataset.itemId;
    const itemSize = button.dataset.itemSize;
    
    this.updateItemQuantity(itemId, itemSize, 1);
  }

  decreaseQuantity(event) {
    const button = event.currentTarget;
    const itemId = button.dataset.itemId;
    const itemSize = button.dataset.itemSize;
    
    this.updateItemQuantity(itemId, itemSize, -1);
  }

  updateQuantity(event) {
    const input = event.currentTarget;
    const itemId = input.dataset.itemId;
    const itemSize = input.dataset.itemSize;
    const newQuantity = parseInt(input.value);
    
    if (newQuantity < 1) {
      input.value = 1;
      return;
    }
    
    if (newQuantity > 99) {
      input.value = 99;
      return;
    }
    
    this.setItemQuantity(itemId, itemSize, newQuantity);
  }

  updateItemQuantity(itemId, itemSize, change) {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const itemIndex = cart.findIndex(item => item.id === itemId && item.size === itemSize);
    
    if (itemIndex >= 0) {
      const newQuantity = cart[itemIndex].quantity + change;
      
      if (newQuantity < 1) {
        // If quantity would be 0 or less, remove item
        cart.splice(itemIndex, 1);
      } else if (newQuantity > 99) {
        // Max quantity limit
        cart[itemIndex].quantity = 99;
      } else {
        cart[itemIndex].quantity = newQuantity;
      }
      
      localStorage.setItem("cart", JSON.stringify(cart));
      window.dispatchEvent(new CustomEvent('cartUpdated'));
      this.loadCart();
    }
  }

  setItemQuantity(itemId, itemSize, quantity) {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const itemIndex = cart.findIndex(item => item.id === itemId && item.size === itemSize);
    
    if (itemIndex >= 0) {
      cart[itemIndex].quantity = quantity;
      localStorage.setItem("cart", JSON.stringify(cart));
      window.dispatchEvent(new CustomEvent('cartUpdated'));
      this.loadCart();
    }
  }

  clear() {
    if (confirm("Are you sure you want to clear your cart?")) {
      localStorage.removeItem("cart");
      window.dispatchEvent(new CustomEvent('cartUpdated'));
      this.loadCart();
    }
  }

  checkout() {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const streetName = this.streetNameTarget.value.trim();
    const streetNumber = this.streetNumberTarget.value.trim();
    const email = this.emailTarget.value.trim();
    const zipCode = this.zipCodeTarget.value.trim();
    
    if (!cart || cart.length === 0) {
      alert("Your cart is empty");
      return;
    }
    
    // Basic validation
    if (!streetName || !streetNumber || !email || !zipCode) {
      alert("Please fill in all required fields");
      return;
    }
    
    if (!this.isValidEmail(email)) {
      alert("Please enter a valid email address");
      return;
    }
    
    // Create form
    const form = this.createCheckoutForm(cart, {
      street_name: streetName,
      street_number: streetNumber,
      email: email,
      zip_code: zipCode
    });
    
    // Update button state
    this.updateCheckoutButton(true);
    
    // Submit form
    document.body.appendChild(form);
    form.submit();
  }
  
  createCheckoutForm(cart, shippingDetails) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/checkout';
    
    // CSRF Token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    this.addHiddenInput(form, 'authenticity_token', csrfToken);

    // Add cart data
    cart.forEach((item, index) => {
      Object.keys(item).forEach(key => {
        this.addHiddenInput(form, `cart[${index}][${key}]`, item[key]);
      });
    });
    
    // Add shipping details
    Object.keys(shippingDetails).forEach(key => {
      this.addHiddenInput(form, key, shippingDetails[key]);
    });
    
    return form;
  }
  
  addHiddenInput(form, name, value) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    form.appendChild(input);
  }
  
  updateCheckoutButton(loading) {
    const button = document.querySelector('[data-action="click->cart#checkout"]');
    
    if (loading) {
      button.disabled = true;
      button.innerHTML = `
        <svg class="inline w-5 h-5 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
        </svg>
        Redirecting to MercadoPago...
      `;
      
      // Reset after timeout
      setTimeout(() => {
        button.disabled = false;
        button.textContent = 'Proceed to Checkout';
      }, 5000);
    }
  }
  
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}