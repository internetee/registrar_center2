import { Controller } from "@hotwired/stimulus"
import Select from "../select";

export default class extends Controller {
  static targets = ["contactTarget", "contactTemplate",
                    "contact", "nameserverTarget", "nameserverTemplate",
                    "nameserver", "dnskeyTarget", "dnskeyTemplate",
                    "dnskey"];
  static values = {
      maxNumElements: 10,
      minNumElements: 1,
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
      let numVisibleElements = this.numberOfElements(this[type + 'SelectorWrapperValue'], true);
      let numInvisibleElements = this.numberOfElements(this[type + 'SelectorWrapperValue'], false);
      if (numVisibleElements < this.maxNumElementsValue) {
          let index = numVisibleElements + numInvisibleElements + 1;
          const content = this[type + "TemplateTarget"].innerHTML.replace(/NEW_RECORD/g, index);
          this[type + "TargetTarget"].insertAdjacentHTML("beforebegin", content);
          const last = Array.from(
              document.querySelectorAll(this[type + 'SelectorWrapperValue'])
          ).pop();
          last.querySelectorAll('select:not(.flatpickr-monthDropdown-months)').forEach(elem => {
              new Select(elem, {});
          });
          this.restartCount(type);
      }
  }
  remove(e) {
      e.preventDefault();
      let type = e.target.dataset.value;
      const wrapper = e.target.closest(this[type + 'SelectorWrapperValue']);
      let numVisibleElements = this.numberOfElements(this[type + 'SelectorWrapperValue'], true);
      if (numVisibleElements >= this.minNumElementsValue) {
          if (wrapper.dataset.newRecord === 'true') {
              wrapper.remove();
          } else {
              wrapper.style.display = 'none';
              const input = wrapper.querySelector("input[name*='action']");
              input.value = 'rem';
          }
          if (numVisibleElements < 2) {
              this.add(e);
          }
          this.restartCount(type);
      }
  }
  toggleContactType(e){
      e.preventDefault();
      const label = e.target.closest(this.contactSelectorWrapperValue).querySelector(".form--label");
      label.innerHTML = e.target.dataset.value;
  }
  numberOfElements(elem, visible) {
      var divs = document.querySelectorAll(elem);
      var divsArray = [].slice.call(divs);
      var filtered = divsArray.filter(function(el) {
          let display = getComputedStyle(el).display;
          return visible ? display !== 'none' : display === 'none';
      });
      return filtered.length;
  }
  restartCount(type) {
    let count = 1;
    let elements = document.querySelectorAll(this[type + 'SelectorWrapperValue']);
    elements.forEach((elem) => {
        if (elem.style.display !== 'none') {
            let index = count > 1 ? count : '';
            let html = elem.querySelector("h3").innerHTML;
            let header = /\d+/.test(html) ? html.replace(/\d+/g, index) : html + ' ' + index;
            elem.querySelector("h3").innerHTML = header;
            count += 1;
        }
    });
  }
}
