import "./controllers";

import "core-js/stable";
import "regenerator-runtime/runtime";
import "@hotwired/turbo-rails";

import Toggle from "./toggle";
import Datepicker from "./datepicker";
import Dialog from "./dialog";
import FileUpload from "./fileUpload";
import Select from "./select";
import Tabs from "./tabs";
import Tooltip from "./tooltip";
import Header from './header';


class App {
    constructor() {
        this.bindUiEvents();
    }
    
    bindUiEvents() {
        var locale = document.querySelector('body').dataset.locale;

        document.querySelectorAll('.tooltip').forEach(elem => {
            new Tooltip(elem, 'click');
        });

        document.querySelectorAll('.simple_tooltip').forEach(elem => {
            new Tooltip(elem, 'mouseenter focus');
        });
        
        new Header(document.querySelector('.layout--header-bottom'));
        
        new Datepicker('.datepicker', { locale: locale });
        
        document.querySelectorAll('[data-toggle]').forEach(elem => {
            new Toggle(elem);
        });
        
        document.querySelectorAll('select:not(.flatpickr-monthDropdown-months)').forEach(elem => {
            new Select(elem, { itemSelectText: '' });
        });
        
        document.querySelectorAll('.dialog').forEach(elem => {
            new Dialog(elem);
        });
        
        document.querySelectorAll('.tabs').forEach(elem => {
            new Tabs(elem);
        });
        
        document.querySelectorAll('.file').forEach(elem => {
            new FileUpload(elem);
        });
    }
}

// For browsers that do not support Element.closest(),
// but carry support for element.matches() (or a prefixed equivalent, meaning IE9+)
if (!Element.prototype.matches) {
    Element.prototype.matches =
        Element.prototype.msMatchesSelector ||
        Element.prototype.webkitMatchesSelector;
}
if (!Element.prototype.closest) {
    Element.prototype.closest = function(s) {
        var el = this;
        do {
            if (Element.prototype.matches.call(el, s)) return el;
            el = el.parentElement || el.parentNode;
        } while (el !== null && el.nodeType === 1);
        return null;
    };
}

// To make possible turbo stream links
document.addEventListener("turbo:before-fetch-request", (event) => {
    const { headers } = event.detail.fetchOptions || {}
    if (headers) {
        headers.Accept = ["text/vnd.turbo-stream.html", headers.Accept].join(", ")
    }
});

// Reinitialize javascript elements after turbo stream link
document.addEventListener("turbo:render", function() {
    new App();
})

new App();

