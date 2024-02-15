import "@hotwired/turbo-rails";
import "controllers";
import 'beercss';
import * as luxon from 'luxon';
import * as picmo from 'picmo';
import * as picmo_popup from 'picmo/popup-picker';
import Toastify from "toastify-js";

export function showToastMessage(key, value) {
    let className = '';
    if(key === 'error' || key === 'alert') {
        className = 'error';
    } else {
        className = 'success';
    }
    Toastify({
        text: value,
        position: "left",
        duration: 3500,
        close: true,
        stopOnFocus: true,
        backgroundColor: 'none',
        className: className,
        style: { width: "100%" },
        offset: { x: '50%' }
    }).showToast();
}

addEventListener("turbo:before-stream-render", (event) => {
    const originalRender = event.detail.render

    event.detail.render = function (streamElement) {
        originalRender(streamElement)
        const afterRenderEvent = new Event("turbo:after-stream-render", event.detail);
        document.dispatchEvent(afterRenderEvent);
    }
});

document.addEventListener("direct-upload:error", event => {
    event.preventDefault();
    let allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    let file = event.detail.file;
    let errorMessage = [`Could not send file ${file.name}`];
    if(file.size > 2000000) {
        errorMessage.push('file is above 2mb');
    }
    if(!allowedTypes.includes(file.type)) {
        errorMessage.push(`unsupported file type ${file.type}`);
    }
    errorMessage = errorMessage.join(', ') + '!';
    showToastMessage('error', errorMessage);

    let fileNames = Array.from(
        document.querySelector('input[type="file"]').files
    ).map((file) => { return file.name});
    fetch('/rails/active_storage/direct_uploads', {
        method: 'DELETE',
        headers: {
            "X-CSRF-Token": document.getElementsByName("csrf-token")[0].content,
            "Content-Type": "application/json",
            Accept: "application/json",
        },
        body: JSON.stringify({ file_names: fileNames })
    });
});

window.showToastMessage = showToastMessage;
window.luxon = luxon;
window.picmo = picmo;
window.picmo_popup = picmo_popup;