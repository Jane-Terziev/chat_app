import "@hotwired/turbo-rails";
import "controllers";
import 'beercss';
import * as luxon from 'luxon';
import { showToastMessage } from "./toast";
import * as picmo from 'picmo';
import * as picmo_popup from 'picmo/popup-picker';

addEventListener("turbo:before-stream-render", (event) => {
    const originalRender = event.detail.render

    event.detail.render = function (streamElement) {
        originalRender(streamElement)
        const afterRenderEvent = new Event("turbo:after-stream-render", event.detail);
        document.dispatchEvent(afterRenderEvent);
    }
})

window.showToastMessage = showToastMessage;
window.luxon = luxon;
window.picmo = picmo;
window.picmo_popup = picmo_popup;