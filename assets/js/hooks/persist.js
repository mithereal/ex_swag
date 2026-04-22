let PersistHooks = {}

PersistHooks.Persist = {
  mounted() {
    let key = this.el.dataset.key

    // load initial value
    let stored = localStorage.getItem(key)
    if (stored !== null) {
      this.pushEvent("persist:load", {key, value: JSON.parse(stored)})
    }

    this.handleEvent("persist:save", ({key, value}) => {
      localStorage.setItem(key, JSON.stringify(value))
    })
  }
}

export default PersistHooks