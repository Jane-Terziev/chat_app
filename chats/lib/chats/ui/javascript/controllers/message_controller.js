import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { scroll: Boolean, acknowledge: Boolean, acknowledgeUrl: String }
    connect() {
        if(this.scrollValue === true) {
            const messageContainer = document.getElementById('messageContainer');
            messageContainer.parentElement.scrollTop = messageContainer.scrollHeight;
        }

        if(this.acknowledgeValue === true) {
            fetch(this.acknowledgeUrlValue)
                .then(response => response.text())
                .then(stream_message => Turbo.renderStreamMessage(stream_message));
        }
    }
}
