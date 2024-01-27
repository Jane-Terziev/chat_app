import { Controller } from "@hotwired/stimulus";
import * as picmo_popup from 'picmo/popup-picker';

export default class extends Controller {
    connect() {
        const messageTextArea = document.querySelector('.messageInput');
        this.picker = picmo_popup.createPopup({}, {
            referenceElement: messageTextArea,
            triggerElement: this.element,
            className: 'emoji-popup'
        });

        this.picker.addEventListener('emoji:select', (event) => {
            messageTextArea.value += event.emoji;
            messageTextArea.focus();
        })
    }

    togglePicker() {
        this.picker.toggle();
    }
}