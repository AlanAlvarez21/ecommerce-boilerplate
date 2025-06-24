import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static values = { size: String, product: Object }
  static targets = ["addButton"]
  
  connect() {
    console.log("Products controller connected");
    console.log("Product value:", this.productValue);
  }
  
  addToCart() {
    console.log("=== AddToCart method called ===");
    console.log("Size value:", this.sizeValue);
    console.log("Product value:", this.productValue);
    
    // Validar que haya un tamaño seleccionado
    if (!this.sizeValue || this.sizeValue.trim() === "") {
      console.log("No size selected, returning");
      return;
    }

    console.log("Adding to cart with size:", this.sizeValue);

    const cart = localStorage.getItem("cart");
    console.log("Current cart:", cart);
    
    if(cart) {
      const cartArray = JSON.parse(cart);
      console.log("Parsed cart array:", cartArray);
      
      const foundIndex = cartArray.findIndex(item => item.id === this.productValue.id && item.size === this.sizeValue);
      console.log("Found index:", foundIndex);
      
      if(foundIndex >= 0){
        cartArray[foundIndex].quantity = parseInt(cartArray[foundIndex].quantity) + 1;
        console.log("Updated existing item quantity");
      } else {
        const newItem = {
          id: this.productValue.id,
          name: this.productValue.name,
          price: this.productValue.price,
          size: this.sizeValue,
          quantity: 1
        };
        console.log("Adding new item:", newItem);
        cartArray.push(newItem);
      }
      console.log("Final cart array:", cartArray);
      localStorage.setItem("cart", JSON.stringify(cartArray));
    } else {
      console.log("Creating new cart");
      const cartArray = [];
      const newItem = {
        id: this.productValue.id,
        name: this.productValue.name,
        price: this.productValue.price,
        size: this.sizeValue,
        quantity: 1
      };
      console.log("New item for new cart:", newItem);
      cartArray.push(newItem);
      console.log("New cart array:", cartArray);
      localStorage.setItem("cart", JSON.stringify(cartArray));
    }
    
    // Verificar que se guardó correctamente
    const savedCart = localStorage.getItem("cart");
    console.log("Saved cart:", savedCart);
    
    // Disparar evento para actualizar el contador del header
    window.dispatchEvent(new CustomEvent('cartUpdated'));
    
    // Mostrar feedback visual temporal
    this.showSuccessMessage();
  }

  selectSize(event) {
    console.log("=== SelectSize method called ===");
    console.log("Selected size:", event.target.value);
    
    // Remover selección anterior
    this.element.querySelectorAll('[data-action*="selectSize"]').forEach(btn => {
      btn.classList.remove('ring-2', 'ring-emerald-400', 'ring-offset-2');
    });
    
    // Agregar selección al botón actual
    event.target.classList.add('ring-2', 'ring-emerald-400', 'ring-offset-2');
    
    this.sizeValue = event.target.value;
    console.log("Size value set to:", this.sizeValue);
    
    const selectedSizeEl = document.getElementById("selected-size");
    if (selectedSizeEl) {
      selectedSizeEl.innerText = `Tamaño seleccionado: ${this.sizeValue}`;
      console.log("Updated selected size display");
    } else {
      console.log("Selected size element not found");
    }
    
    // Habilitar el botón de agregar al carrito
    this.enableAddButton();
  }

  enableAddButton() {
    console.log("=== EnableAddButton method called ===");
    
    if (this.hasAddButtonTarget) {
      const addButton = this.addButtonTarget;
      addButton.disabled = false;
      addButton.classList.remove('opacity-50', 'cursor-not-allowed', 'bg-slate-400');
      addButton.classList.add('bg-emerald-600', 'hover:bg-emerald-700', 'focus:outline-none', 'focus:ring-2', 'focus:ring-offset-2', 'focus:ring-emerald-500');
      addButton.textContent = 'Añadir al Carrito';
      console.log("Add button enabled");
    } else {
      console.log("Add button target not found");
    }
  }

  showSuccessMessage() {
    console.log("=== ShowSuccessMessage method called ===");
    
    if (this.hasAddButtonTarget) {
      const addButton = this.addButtonTarget;
      const originalText = addButton.textContent;
      
      addButton.textContent = '¡Agregado!';
      addButton.classList.remove('bg-emerald-600', 'hover:bg-emerald-700');
      addButton.classList.add('bg-green-600');
      
      console.log("Success message displayed");
      
      setTimeout(() => {
        addButton.textContent = originalText;
        addButton.classList.remove('bg-green-600');
        addButton.classList.add('bg-emerald-600', 'hover:bg-emerald-700');
        console.log("Success message cleared");
      }, 2000);
    } else {
      console.log("Add button target not found for success message");
    }
  }
}