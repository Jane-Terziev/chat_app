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
                    let container = `
                    <div id="${attachment.name}" class="small-margin">
                      <span class="badge circle secondary">
                        <i style="font-size: 1rem; cursor: pointer;" 
                           data-action="click->message-file-preview#removeFile"
                           data-file-name="${attachment.name}"
                        >
                          close
                        </i>
                      </span>`;

                    if(attachment.type === 'application/pdf') {
                        let pdf_div = `
                          <div class="center-align">
                            <i>picture_as_pdf</i>
                            <p class="small-text">${attachment.name}</p>
                          </div>
                        `
                        container += pdf_div
                    } else {
                        let image = `
                         <img src="${e.target.result}" width="40" height="40">
                        `
                        container += image;
                    }
                    container += `</div>`
                    attachmentsRow.innerHTML += container;
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
