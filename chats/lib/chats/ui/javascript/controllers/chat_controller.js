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
                    let childrenSize = container.children.length;
                    let scrollPosition = 10;
                    if((childrenSize % 10) !== 0) {
                        scrollPosition = childrenSize % 10;
                    }
                    if(container.children[scrollPosition]) {
                        container.parentElement.scrollTop = container.children[scrollPosition].offsetTop;
                    }
                }
            }
        })
    }
}
