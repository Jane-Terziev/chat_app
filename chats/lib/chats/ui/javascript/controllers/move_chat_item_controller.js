import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { moveToTop: Boolean }

    initialize() {
        if(this.moveToTopValue) {
            this.element.parentElement.prepend(this.element);
        }
    }
}
