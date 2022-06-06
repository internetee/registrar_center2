import flatpickr from "flatpickr";
import "flatpickr/dist/l10n/et.js"

flatpickr.l10ns.en.firstDayOfWeek = 1;

export default class Datepicker {
    constructor(selector, options = {}) {
        this.target = selector;
        this.options = options;
        this.init();
    }
    
    init() {
        const that = this;
        var f = flatpickr(that.target, {
            allowInput: true,
            altInput: true,
            altFormat: that.options.dateFormat || 'Y-m-d',
            dateFormat: that.options.dateFormat || 'Y-m-d',
            ...that.options
        });
        if (f._input !== undefined){
            f._input.onkeypress = () => false;
        }
    }
}
