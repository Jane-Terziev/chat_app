import { Controller } from "@hotwired/stimulus"
import * as SlimSelect from 'slim-select';

export default class extends Controller {
    static values = {
        selector: String,
        placeholderText: String
    }
    connect() {
        let element = this.element;
        new SlimSelect.default({
            select: this.selectorValue,
            settings: {
                placeholderText: this.placeholderTextValue
            },
            events: {
                afterChange: (value) => {
                    element.parentElement.classList.remove('invalid');
                    const error = element.parentElement.querySelector('.selectError');
                    error.style.display = 'none';
                }
            }
        })
    }
}
