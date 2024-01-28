import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.scrollTop = this.element.scrollHeight;
        let eventData = null;
        document.addEventListener('turbo:before-stream-render', (event) => {
            eventData = event;
        })

        document.addEventListener('turbo:after-stream-render', (event) => {
            if(eventData) {
                let target = eventData.srcElement.target;
                if(target === 'message_pagination') {
                    let container = document.getElementById('messageContainer');
                    if(container.children[10]) {
                        container.parentElement.scrollTop = container.children[10].offsetTop;
                    }
                }
            }
        })
    }
}
