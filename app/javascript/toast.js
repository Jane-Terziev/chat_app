import Toastify from "toastify-js";

export function showToastMessage(key, value) {
    let className = '';
    if(key === 'error' || key === 'alert') {
        className = 'error';
    } else {
        className = 'success';
    }
    Toastify({
        text: value,
        position: "left",
        duration: 3500,
        close: true,
        stopOnFocus: true,
        backgroundColor: 'none',
        className: className,
        style: { width: "100%" },
        offset: { x: '50%' }
    }).showToast();
}

window.showToastMessage = showToastMessage;