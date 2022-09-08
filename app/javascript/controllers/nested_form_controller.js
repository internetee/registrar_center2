import { Controller } from "@hotwired/stimulus"
import Select from "../select";

export default class extends Controller {
  static targets = ["contactTarget", "contactTemplate",
                    "contact", "nameserverTarget", "nameserverTemplate",
                    "nameserver", "dnskeyTarget", "dnskeyTemplate",
                    "dnskey"];
  static values = {
      contactSelectorWrapper: {
          type: String,
          default: ".contact-nested-form-wrapper"
      },
      nameserverSelectorWrapper: {
          type: String,
          default: ".nameserver-nested-form-wrapper"
      },
      dnskeySelectorWrapper: {
          type: String,
          default: ".dnskey-nested-form-wrapper"
      },
  };
  add(e) {
      e.preventDefault();
      let type = e.target.dataset.value;
      let num_elements = this.numberOfVisibleElements(this[type + 'SelectorWrapperValue']);
      if (num_elements < 10) {
          const content = this[type + "TemplateTarget"].innerHTML.replace(/NEW_RECORD/g, num_elements + 1);
          this[type + "TargetTarget"].insertAdjacentHTML("beforebegin", content);
          const last = Array.from(
              document.querySelectorAll(this[type + 'SelectorWrapperValue'])
          ).pop();
          last.querySelectorAll('select:not(.flatpickr-monthDropdown-months)').forEach(elem => {
              new Select(elem, {});
          });
      }
  }
  remove(e) {
      e.preventDefault();
      let type = e.target.dataset.value;
      const wrapper = e.target.closest(this[type + 'SelectorWrapperValue']);
      let num_elements = this.numberOfVisibleElements(this[type + 'SelectorWrapperValue']);
      if (num_elements > 0) {
          if (wrapper.dataset.newRecord === 'true') {
              wrapper.remove();
          } else {
              wrapper.style.display = 'none';
              const input = wrapper.querySelector("input[name*='action']");
              input.value = 'rem';
          }
          this.restartCount(type);
      }
  }
  toggleContactType(e){
      e.preventDefault();
      const label = e.target.closest(this.contactSelectorWrapperValue).querySelector(".form--label");
      label.innerHTML = e.target.dataset.value;
  }
  numberOfVisibleElements(elem) {
      let count = 0;
      document.querySelectorAll(elem).forEach(elem => {
          if (elem.style.display != 'none') {
              count += 1;
          }
      });
      return count;
  }
  restartCount(type) {
    let count = 1;
    let elements = document.querySelectorAll(this[type + 'SelectorWrapperValue']);
    elements.forEach((elem) => {
        if (elem.style.display != 'none') {
            let header = elem.querySelector("h3").innerHTML.replace(/[0-9]/g, count > 1 ? count : '');
            elem.querySelector("h3").innerHTML = header;
            count += 1;
        }
    });
  }
}
