export default class FileUpload {
    constructor(target) {
        this.target = target;
        this.input = target.querySelector('input[type=file]');
        this.files = [];
        this.init();
    }
    
    generateFileList() {
        const that = this;
        const fileList = that.target.parentElement.querySelector('.file--list');
        [...fileList.children].forEach(file => {
            file.parentNode.removeChild(file);
        });
        that.files.forEach((file, index) => {
            const fileItem = document.createElement('li');
            const fileRemove = document.createElement('button');
            
            fileItem.classList.add('file--item');
            fileItem.innerHTML = file.name;
            
            fileRemove.classList.add('file--remove');
            fileRemove.addEventListener('click', e => {
                e.preventDefault();
                that.files.splice(index, 1);
                that.generateFileList();
            });
            
            fileItem.appendChild(fileRemove);
            fileList.appendChild(fileItem);
        });
        if (!that.files.length) {
            that.input.value = null;
        }
    }
    
    init() {
        const that = this;
        that.input.addEventListener('change', () => {
            that.files = [...that.input.files];
            that.generateFileList();
        });
    }
};
