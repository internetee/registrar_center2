export default class Tabs {
    constructor(target) {
        this.target = target;
        this.init();
    }
    
    setActive(id) {
        const that = this;
        const activeTabPanel = that.target.querySelector('.tabs--tab.active');
        const tabPanel = that.target.querySelector(id);
    
        that.target.querySelector('.tabs--head--item.active').classList.remove('active');
        that.target.querySelector('.tabs--head--item[href="' + id + '"]').classList.add('active');
    
        activeTabPanel.classList.remove('active');
        activeTabPanel.setAttribute('aria-selected', 'false');
    
        tabPanel.classList.add('active');
        tabPanel.setAttribute('aria-selected', 'true');
    }
    
    init() {
        const that = this;
        that.target.querySelectorAll('.tabs--head--item').forEach(tabLink => {
            tabLink.addEventListener('click', e => {
                e.preventDefault();
                const tabName = tabLink.getAttribute('href');
                that.setActive(tabName);
            });
        });
    }
};
