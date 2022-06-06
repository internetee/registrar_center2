export default class Dialog {
    constructor(target) {
        this.target = target;
        this.init();
    }
    
    open(id, elem) {
        document.querySelector('#' + id).classList.add('open');
        switch (id) {
            case "switch_user":
                this.target.querySelector('.username').innerHTML = elem.dataset.userName;
                this.target.querySelector('#session_user_id').value = elem.dataset.userId;
                break;
            case "invoice_send":
                this.target.querySelector('#invoice_recipient').value = elem.dataset.recipient;
                this.target.querySelector('#invoice_id').value = elem.dataset.invoiceId;
                break;
            case "invoice_cancel":
              this.target.querySelector('.number').innerHTML = elem.dataset.invoiceNumber;
              this.target.querySelector('#invoice_id').value = elem.dataset.invoiceId;
              break;
        }
    }
    
    close(id) {
        document.querySelector('#' + id).classList.remove('open');
    }
    
    init() {
        const that = this;
        const { id } = that.target;
        document.querySelectorAll('[data-dialog=' + id + ']').forEach(elem => {
            if (elem !== null) {
                elem.addEventListener('click', e => {
                e.preventDefault();
                that.open(id, elem);
                });
            }
        });
        that.target.querySelector('.button--close').addEventListener('click', e => {
            e.preventDefault();
            that.close(id);
        });
    }
};
