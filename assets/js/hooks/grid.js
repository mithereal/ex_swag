import { GridStack } from "gridstack"
import "gridstack/dist/gridstack.min.css"

export default {
  mounted() {
    this.grid = GridStack.init({
      float: true,
      cellHeight: 80
    }, this.el)

    this.grid.on("change", () => {
      const items = this.grid.engine.nodes.map(n => ({
        id: n.el.dataset.id,
        x: n.x,
        y: n.y,
        w: n.w,
        h: n.h
      }))

      this.pushEvent("save_grid", { items })
    })
  }
}