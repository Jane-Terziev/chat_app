import { Controller } from "@hotwired/stimulus"
import { DateTime } from "luxon";

export default class extends Controller {
    static values = { timestamp: String }
    connect() {
        let time_zone = document.getElementById("time-zone").getAttribute("data-time-zone");
        this.element.innerText = DateTime.fromISO(this.timestampValue, { zone: time_zone }).toFormat('T LLLL d')
    }
}