import * as Hello from "./build/dev/javascript/hooks/hello.mjs";
// import * as LocalTime from "./build/dev/javascript/hooks/local_time.mjs";

LocalTime = {
  mounted() {
    this.updated();
  },
  updated() {
    let dt = new Date(this.el.textContent);
    this.el.textContent =
      dt.toLocaleString() +
      " " +
      Intl.DateTimeFormat().resolvedOptions().timeZone;
    this.el.classList.remove("invisible");
  },
};

export default {
  Hello,
  LocalTime,
};
