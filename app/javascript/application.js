import "@hotwired/turbo-rails";
import "controllers";
import 'beercss';
import * as luxon from 'luxon';
import { showToastMessage } from "./toast";
import * as picmo from 'picmo';
import * as picmo_popup from 'picmo/popup-picker';

window.showToastMessage = showToastMessage;
window.luxon = luxon;
window.picmo = picmo;
window.picmo_popup = picmo_popup;