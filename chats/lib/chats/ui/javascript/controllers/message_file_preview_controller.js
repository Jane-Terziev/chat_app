import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.attachmentsInput = document.getElementById('message_attachments_');
        this.attachmentsRow = document.querySelector('.attachmentsRow');
    }

    readURL() {
        let attachmentsRow = this.attachmentsRow;
        let attachmentsInput = this.attachmentsInput;
        attachmentsRow.innerHTML = '';
        if (attachmentsInput.files && (attachmentsInput.files.length > 0)) {
            Array.from(attachmentsInput.files).forEach(attachment => {
                let reader = new FileReader();
                reader.onload = function (e) {
                    let container = document.createElement('div');
                    container.setAttribute('id', attachment.name);
                    let badge = document.createElement('span');
                    badge.classList.add('badge');
                    badge.classList.add('circle');
                    badge.classList.add('secondary');
                    let icon = document.createElement('i');
                    icon.innerHTML = 'close';
                    icon.style.fontSize = '1rem';
                    icon.setAttribute('data-action', `click->message-file-preview#removeFile`);
                    icon.setAttribute('data-file-name', attachment.name);
                    icon.style.cursor = 'pointer';
                    badge.append(icon);
                    let image = document.createElement('img');
                    image.width = 40;
                    image.height = 40;
                    image.src = e.target.result;

                    container.append(badge);
                    container.append(image)

                    container.classList.add('small-margin')
                    attachmentsRow.append(container);
                };
                reader.readAsDataURL(attachment);
            });
        }
    }

    removeFile(event) {
        let fileName = event.currentTarget.dataset.fileName;
        let attachmentsInput = this.attachmentsInput;
        let updatedFiles = Array.from(attachmentsInput.files).filter(file => file.name !== fileName);
        let newFileList = new DataTransfer();
        updatedFiles.forEach(file => {
            newFileList.items.add(file);
        });

        attachmentsInput.files = newFileList.files;
        document.getElementById(fileName).remove();
    }
}
