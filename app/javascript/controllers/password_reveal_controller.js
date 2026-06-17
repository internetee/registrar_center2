import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value", "toggle"];

  connect() {
    this.revealed = false;
    this.render();
  }

  toggle(event) {
    event.preventDefault();
    this.revealed = !this.revealed;
    this.render();
  }

  render() {
    const password = this.valueTarget.dataset.password || "";
    this.valueTarget.textContent = this.revealed ? password : this.maskFor(password);

    if (this.hasToggleTarget) {
      this.toggleTarget.textContent = this.revealed
        ? this.toggleTarget.dataset.hideLabel
        : this.toggleTarget.dataset.showLabel;
    }
  }

  maskFor(password) {
    const length = Math.max(password.length, 8);
    return "•".repeat(Math.min(length, 24));
  }
}
