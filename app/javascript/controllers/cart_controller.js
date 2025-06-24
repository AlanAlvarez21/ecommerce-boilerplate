import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {

  connect(){
    console.log("Cart controller connected - UPDATED VERSION");
    this.loadCart();
  }
  
  loadCart() {
    const cart = JSON.parse(localStorage.getItem("cart"));
    if (!cart) {
      return
    }
    let total = 0;
    for(let i=0; i < cart.length; i++) {
      const item = cart[i];
      total += item.price * item.quantity;
      const div = document.createElement("div");
      div.classList.add("mt-2");
      div.innerHTML = `Item: ${item.name} - S/.${item.price} - Size: ${item.size} - Quantity: ${item.quantity}`;
      const deleteButton = document.createElement("button");
      deleteButton.innerHTML = "Remove";
      deleteButton.classList.add("bg-gray-500", "rounded", "text-white", "px-2", "py-1", "ml-2");
      console.log("item_id: ", item.id);
      deleteButton.value = JSON.stringify({id: item.id, size: item.size});
      deleteButton.addEventListener("click", this.removeFromCart);
      div.appendChild(deleteButton);
      this.element.prepend(div);
    }
    const totalEl = document.createElement("div");
    totalEl.innerHTML = `Total: $${total}`;
    let totalContainer = document.getElementById("total");
    totalContainer.appendChild(totalEl);
  }

  clear() {
    localStorage.removeItem("cart");
    // NUEVA LÍNEA: Notificar al header
    window.dispatchEvent(new CustomEvent('cartUpdated'));
    window.location.reload();
  }

  removeFromCart(e) {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const values = JSON.parse(e.target.value);
    const { id, size } = values;
    const index = cart.findIndex(item => item.id === id && item.size === size);
    if (index >= 0) {
      cart.splice(index, 1);
    }
    localStorage.setItem("cart", JSON.stringify(cart));
    
    // NUEVA LÍNEA: Notificar al header
    window.dispatchEvent(new CustomEvent('cartUpdated'));
    window.location.reload();
  }

  checkout() {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const payload = {
      authenticity_token: "",
      cart: cart
    };
    const csrfToken = document.querySelector("[name='csrf-token']").content;
    fetch("/checkout", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(payload)
    }).then(response => {
      if (response.ok) {
        response.json().then(body => {
          window.location.href = body.url;
        })
      } else {
        response.json().then(body => {
          const errorEl = document.createElement("div");
          errorEl.innerText = `There was an error processing your order. ${body.error}`;
          let errorContainer = document.getElementById("errorContainer");
          errorContainer.appendChild(errorEl);
        })
      }
    });
  }
}