export function getElement() {
  let dt = new Date(this.el.textContent);
  this.el.textContent =
    dt.toLocaleString() +
    " " +
    Intl.DateTimeFormat().resolvedOptions().timeZone;
}

export function getAttribute(element, name) {
  return element.getAttribute(name);
}

export function setTextContent(element, content) {
  element.textContent = content;
}
