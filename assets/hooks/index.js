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


 SearchBar = {
  mounted() {
    const searchBarContainer = (this as any).el as HTMLDivElement
    document.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') {
        return
      }

      const focusElemnt = document.querySelector(':focus') as HTMLElement

      if (!focusElemnt) {
        return
      }

      if (!searchBarContainer.contains(focusElemnt)) {
        return
      }

      event.preventDefault()

      const tabElements = document.querySelectorAll(
        '#search-input, #searchbox__results_list a',
      ) as NodeListOf<HTMLElement>
      const focusIndex = Array.from(tabElements).indexOf(focusElemnt)
      const tabElementsCount = tabElements.length - 1

      if (event.key === 'ArrowUp') {
        tabElements[focusIndex > 0 ? focusIndex - 1 : tabElementsCount].focus()
      }

      if (event.key === 'ArrowDown') {
        tabElements[focusIndex < tabElementsCount ? focusIndex + 1 : 0].focus()
      }
    })
  },
}

export default {
  Hello,
  LocalTime,
  SearchBar,
};
