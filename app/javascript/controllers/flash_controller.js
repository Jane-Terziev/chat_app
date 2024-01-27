import { Controller } from "@hotwired/stimulus"
import { showToastMessage } from "../toast";

export default class extends Controller {
    static values = { type: String, message: Array }

    connect() {
        if(this.messageValue.length === 0) { return }
        if(Array.isArray(this.messageValue)){
            this.messageValue.forEach((message) => {
                showToastMessage(this.typeValue, message);
            })
        } else {
            showToastMessage(this.typeValue, this.messageValue);
        }

    }
}