import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const textArea = this.element;
        const messageFormButton = document.getElementById('messageFormButton');
        textArea.focus();
        // Add an event listener to the textarea for key presses
        textArea.addEventListener('keydown', function(event) {
            // Check if the pressed key is Enter (key code 13)
            if (event.keyCode === 13) {
                // Prevent the default behavior of Enter key (new line in textarea)
                event.preventDefault();
                messageFormButton.click();
            }
        });
    }
}
