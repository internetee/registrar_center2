import tippy from 'tippy.js';

export default class Tooltip {
    constructor(selector, trigger = null) {
        this.selector = selector;
        this.trigger = trigger;
        this.init();
    }
    
    init() {
        tippy(this.selector, {
            trigger: this.trigger,
        });
    }
}
