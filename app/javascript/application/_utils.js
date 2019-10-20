// Create Turbolinks unload event
const dispatchUnloadEvent = function() {
  const event = document.createEvent("Events")
  event.initEvent("turbolinks:unload", true, false)
  document.dispatchEvent(event)
}
addEventListener("beforeunload", dispatchUnloadEvent)
addEventListener("turbolinks:before-render", dispatchUnloadEvent)

document.addEventListener("turbolinks:load", () => {
  // Restore scroll position
  const scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition && !!localStorage.getItem(scrollPosition)) {
    $(window).scrollTop(localStorage.getItem(scrollPosition));
    localStorage.removeItem(scrollPosition);
  }
});

document.addEventListener("turbolinks:unload", () => {
  // Store scroll position for pages with data-scroll-position
  const scrollPosition = $("[data-scroll-position]").data("scrollPosition")
  if (!!scrollPosition) {
    localStorage.setItem(scrollPosition, $(window).scrollTop())
  }
})
