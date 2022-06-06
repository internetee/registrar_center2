import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["count", "checkbox", "checkboxAll"];

  connect() {
    this.onChecked();
  }

  toggle(e) {
    e.preventDefault();
    if (e.target.checked) {
      this.checkAll();
    } else {
      this.checkNone();
    }
  }

  checkAll() {
    this.setAllCheckboxes(true);
    this.setCount();
  }

  checkNone() {
    this.setAllCheckboxes(false);
    this.setCount();
  }

  onChecked() {
    this.setCount();
    const count = this.unselectedCheckboxes.length;
    if (count > 0) {
        this.checkboxAllTarget.checked = false;
    }
  }

  setAllCheckboxes(checked) {
    this.checkboxes.forEach((el) => {
      const checkbox = el;
      if (!checkbox.disabled) {
          checkbox.checked = checked;
      }
    });
  }

  setCount() {
    if (this.hasCountTarget) {
      const count = this.selectedCheckboxes.length;
      const selected_text = this.countTarget.dataset.selectedText
      this.countTarget.innerHTML = `| ${selected_text} ${count}`;
    }
  }

  get selectedCheckboxes() {
    return this.checkboxes.filter((c) => c.checked);
  }

  get unselectedCheckboxes() {
    return this.checkboxes.filter((c) => !c.checked);
  }

  get checkboxes() {
    return new Array(...this.checkboxTargets);
  }
}