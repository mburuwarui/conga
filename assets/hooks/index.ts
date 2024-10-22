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
    const searchBarContainer = (this as any).el as HTMLDivElement;
    document.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowUp" && event.key !== "ArrowDown") {
        return;
      }

      const focusElemnt = document.querySelector(":focus") as HTMLElement;

      if (!focusElemnt) {
        return;
      }

      if (!searchBarContainer.contains(focusElemnt)) {
        return;
      }

      event.preventDefault();

      const tabElements = document.querySelectorAll(
        "#search-input, #searchbox__results_list a",
      ) as NodeListOf<HTMLElement>;
      const focusIndex = Array.from(tabElements).indexOf(focusElemnt);
      const tabElementsCount = tabElements.length - 1;

      if (event.key === "ArrowUp") {
        tabElements[focusIndex > 0 ? focusIndex - 1 : tabElementsCount].focus();
      }

      if (event.key === "ArrowDown") {
        tabElements[focusIndex < tabElementsCount ? focusIndex + 1 : 0].focus();
      }
    });
  },
};

TableOfContents = {
  navbarHeight: 60, // Adjust this value to match your navbar height

  mounted() {
    this.updated();
  },

  updated() {
    this.generateTOC();
    this.setupScrollSpy();
  },

  generateTOC() {
    const headers = document.querySelectorAll(
      ".prose h1, .prose h2, .prose h3, .prose h4, .prose h5, .prose h6",
    );
    const tocList = this.el;
    headers.forEach((header, index) => {
      const level = parseInt(header.tagName.charAt(1));
      const id = header.id || `toc-${index}`;
      header.id = id;
      const listItem = document.createElement("li");
      listItem.style.marginLeft = `${(level - 1) * 20}px`;
      const link = document.createElement("a");
      link.href = `#${id}`;
      link.textContent = header.textContent;
      link.classList.add(
        "text-zinc-600",
        "hover:text-zinc-900",
        "transition-colors",
        "duration-50",
      );
      listItem.appendChild(link);
      tocList.appendChild(listItem);

      // Make TOC links clickable with smooth scroll
      link.addEventListener("click", (e) => {
        e.preventDefault();
        const targetId = e.target.getAttribute("href").slice(1);
        const targetElement = document.getElementById(targetId);
        const offsetPosition = targetElement.offsetTop - this.navbarHeight;
        window.scrollTo({
          top: offsetPosition,
          behavior: "smooth",
        });
      });

      // Make headers clickable
      header.style.cursor = "pointer";
      header.addEventListener("click", (e) => {
        e.preventDefault();
        const targetId = e.target.id;
        const targetElement = document.getElementById(targetId);
        const offsetPosition = targetElement.offsetTop - this.navbarHeight;
        window.scrollTo({
          top: offsetPosition,
          behavior: "smooth",
        });
      });
    });
  },

  setupScrollSpy() {
    const tocLinks = this.el.querySelectorAll("a");
    const sections = document.querySelectorAll(
      ".prose h1, .prose h2, .prose h3, .prose h4, .prose h5, .prose h6",
    );
    window.addEventListener("scroll", () => {
      let current = "";
      sections.forEach((section) => {
        const sectionTop = section.offsetTop;
        if (pageYOffset >= sectionTop - this.navbarHeight - 10) {
          // Added extra 10px buffer
          current = section.getAttribute("id");
        }
      });
      tocLinks.forEach((link) => {
        link.classList.remove("font-bold", "text-zinc-900");
        if (link.getAttribute("href") === `#${current}`) {
          link.classList.add("font-bold", "text-zinc-900");
        }
      });
    });
  },
};

Copy = {
  mounted() {
    this.updated();
  },
  updated() {
    let { to } = this.el.dataset;
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(to).value;
      navigator.clipboard.writeText(text).then(() => {
        console.log("All done again!");
      });
    });
  },
};

export default {
  Hello,
  LocalTime,
  SearchBar,
  TableOfContents,
  Copy,
};
