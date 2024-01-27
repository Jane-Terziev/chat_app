import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { imageUrl: String }

    connect() {
        this.dialog = document.getElementById('imagePreviewDialog');
        this.imageElement = document.getElementById('imagePreviewContent');
    }

    preview() {
        this.imageElement.src = this.imageUrlValue;
        this.dialog.show();
    }

    close() {
        this.dialog.close();
    }
}
