export default class Toggle {
    constructor(target) {
        this.target = target;
        this.init();
    }
    init() {
        const that = this;
        that.target.addEventListener('click', e => {
            e.preventDefault();
            const toggleTarget = that.target.dataset.toggle;
            document.querySelector('#' + toggleTarget).classList.toggle('open');
            that.target.classList.toggle('open');
        });
    }
}
