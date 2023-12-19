import flatpickr from "flatpickr";
import "flatpickr/dist/l10n/et.js"
import monthSelectPlugin from 'flatpickr/dist/plugins/monthSelect'

flatpickr.l10ns.en.firstDayOfWeek = 1;

export default class Datepicker {
    constructor(selector, options = {}) {
        this.target = selector;
        this.options = options;
        this.init();
    }
    
    init() {
        const that = this;
        let dateFormat = that.target.getAttribute('dateFormat');
        let minDate = that.target.getAttribute('minDate');
        if (dateFormat == "m.y") {
          that.options['plugins'] = [
              new monthSelectPlugin({
                  shorthand: true, //defaults to false
                  dateFormat: dateFormat, //defaults to "F Y"
                  altFormat: "F Y", //defaults to "F Y"
              })
          ];
          that.options['maxDate'] = new Date();
          if (minDate) {
            that.options['minDate'] = new Date(minDate);
          }
        }
        let options = {
            allowInput: true,
            altInput: true,
            altFormat: dateFormat || 'Y-m-d',
            dateFormat: dateFormat || 'Y-m-d',
            ...that.options
        };
        var f = flatpickr(that.target, options);
        if (f._input !== undefined){
            f._input.onkeypress = () => false;
        }
    }
}
