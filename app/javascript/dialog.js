export default class Dialog {
    constructor(target) {
        this.target = target;
        this.init();
    }
    
    open(id, elem) {
        document.querySelector('#' + id).classList.add('open');
        switch (id) {
            case "switch_user":
                this.target.querySelector('.username').innerHTML = elem.dataset.username;
                this.target.querySelector('#account_user_id').value = elem.dataset.userId;
                break;
            case "invoice_send":
                this.target.querySelector('#invoice_recipient').value = elem.dataset.recipient;
                this.target.querySelector('#invoice_id').value = elem.dataset.invoiceId;
                break;
            case "invoice_cancel":
                this.target.querySelector('.number').innerHTML = elem.dataset.invoiceNumber;
                this.target.querySelector('#invoice_id').value = elem.dataset.invoiceId;
                break;
            case "edit_api_user":
                let userData = JSON.parse(elem.dataset.apiUser);
                this.target.querySelector('#api_user_username').value = userData["name"];
                this.target.querySelector('#api_user_password').value = userData["password"];
                this.target.querySelector('#api_user_identity_code').value = userData["identity_code"];
                this.target.querySelector('#api_user_active').checked = userData["active"];
                this.target.querySelector('#api_user_id').value = userData["id"];
                break;
            case "edit_white_ip":
                let ipData = JSON.parse(elem.dataset.whiteIp);
                let interfaces = ipData["interfaces"];
                if (ipData["id"]) {
                    this.target.querySelector("form").action = elem.dataset.action;
                    this.target.querySelector("#_method").value = "patch";
                }
                this.target.querySelector('#white_ip_ipv4').value = ipData["ipv4"] || "";
                this.target.querySelector('#white_ip_ipv6').value = ipData["ipv6"] || "";
                this.target.querySelector('#white_ip_id').value = ipData["id"];
                if (interfaces) {
                    this.target.querySelector('#white_ip_interfaces_api').checked = interfaces.includes("api");
                    this.target.querySelector('#white_ip_interfaces_registrar').checked = interfaces.includes("registrar");
                } else {
                    this.target.querySelector('#white_ip_interfaces_api').checked = false;
                    this.target.querySelector('#white_ip_interfaces_registrar').checked = false;
                }
            case "white_ip_delete":
                this.target.querySelector(".ip").innerHTML = elem.dataset.ip;
                this.target.querySelector("form").action = elem.dataset.action;
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
