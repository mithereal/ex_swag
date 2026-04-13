/**
 * GridStack.js LiveView Hooks
 *
 * Provides LiveView hooks for GridStack.js grid management with resize support
 * Uses GridStack API for programmatic control and event handling
 */

export const GridStackHooks = {
  /**
   * Main GridStack initialization and management hook
   *
   * Usage:
   * <div phx-hook="GridStack" id="my-grid" data-options='{"float": true, "cellHeight": 80}'>
   *   <div class="grid-stack-item">...</div>
   * </div>
   */
  GridStack: {
    mounted() {
      // Initialize GridStack with options from data attribute
      const options = this.el.dataset.options ? JSON.parse(this.el.dataset.options) : {};
      this.grid = GridStack.init(options, this.el);

      // Store reference for event handlers
      this.gridId = this.el.id;

      // Bind all event handlers
      this.setupEventHandlers();
      this.setupResizeHandlers();
      this.setupChangeHandlers();
    },

    /**
     * Handle LiveView updates
     */
    updated() {
      // Sync grid state with any DOM changes from LiveView
      if (this.grid) {
        this.grid.batchUpdate();
        // Re-initialize GridStack to pick up any new items
        const currentOptions = this.grid.opts;
        this.grid.removeAll();
        this.grid = GridStack.init(currentOptions, this.el);
        this.setupEventHandlers();
        this.setupResizeHandlers();
        this.setupChangeHandlers();
        this.grid.commit();
      }
    },

    /**
     * Setup core event handlers for grid changes
     */
    setupEventHandlers() {
      // Handle item added
      this.grid.on('added', (event, items) => {
        items.forEach(item => {
          this.pushEvent('grid:item_added', {
            id: item.el.id || item.id,
            x: item.x,
            y: item.y,
            w: item.w,
            h: item.h
          });
        });
      });

      // Handle item removed
      this.grid.on('removed', (event, items) => {
        items.forEach(item => {
          this.pushEvent('grid:item_removed', {
            id: item.el.id || item.id
          });
        });
      });

      // Handle drag stop
      this.grid.on('dragstop', (event, el) => {
        const item = this.grid.engine.nodes.find(n => n.el === el);
        if (item) {
          this.pushEvent('grid:item_moved', {
            id: el.id,
            x: item.x,
            y: item.y,
            w: item.w,
            h: item.h
          });
        }
      });
    },

    /**
     * Setup resize-specific event handlers
     */
    setupResizeHandlers() {
      // Handle resize start
      this.grid.on('resizestart', (event, el) => {
        this.pushEvent('grid:resize_start', {
          id: el.id
        });
      });

      // Handle resize stop
      this.grid.on('resizestop', (event, el) => {
        const item = this.grid.engine.nodes.find(n => n.el === el);
        if (item) {
          this.pushEvent('grid:item_resized', {
            id: el.id,
            x: item.x,
            y: item.y,
            w: item.w,
            h: item.h
          });
        }
      });
    },

    /**
     * Setup change event handlers for real-time updates
     */
    setupChangeHandlers() {
      // Handle any change event
      this.grid.on('change', (event, items) => {
        const gridData = items.map(item => ({
          id: item.el?.id || item.id,
          x: item.x,
          y: item.y,
          w: item.w,
          h: item.h
        }));

        this.pushEvent('grid:changed', { items: gridData });
      });
    },

    /**
     * Handle LiveView commands
     *
     * Commands:
     * - resize_item: { id, w, h }
     * - move_item: { id, x, y }
     * - add_item: { id, x, y, w, h, content? }
     * - remove_item: { id }
     * - clear_grid: {}
     * - batch_update: { items }
     * - lock_item: { id }
     * - unlock_item: { id }
     */
    handleEvent(event, payload) {
      if (!this.grid) return;

      switch (event) {
        case 'resize_item':
          this.resizeItem(payload);
          break;
        case 'move_item':
          this.moveItem(payload);
          break;
        case 'add_item':
          this.addItem(payload);
          break;
        case 'remove_item':
          this.removeItem(payload);
          break;
        case 'clear_grid':
          this.clearGrid();
          break;
        case 'batch_update':
          this.batchUpdate(payload);
          break;
        case 'lock_item':
          this.lockItem(payload);
          break;
        case 'unlock_item':
          this.unlockItem(payload);
          break;
        case 'get_layout':
          this.getLayout();
          break;
      }
    },

    /**
     * Resize an item to specified dimensions
     * @param {Object} payload - { id, w, h }
     */
    resizeItem({ id, w, h }) {
      const el = document.getElementById(id);
      if (!el) {
        console.warn(`GridStack: Element with id "${id}" not found`);
        return;
      }

      const item = this.grid.getGridItems().find(item => item.id === id);
      if (item) {
        this.grid.resize(el, w, h);
        this.pushEvent('grid:item_resized', {
          id,
          w,
          h,
          x: item.getAttribute('gs-x'),
          y: item.getAttribute('gs-y')
        });
      }
    },

    /**
     * Move an item to specified position
     * @param {Object} payload - { id, x, y }
     */
    moveItem({ id, x, y }) {
      const el = document.getElementById(id);
      if (!el) {
        console.warn(`GridStack: Element with id "${id}" not found`);
        return;
      }

      this.grid.move(el, x, y);
      this.pushEvent('grid:item_moved', {
        id,
        x,
        y,
        w: el.getAttribute('gs-w'),
        h: el.getAttribute('gs-h')
      });
    },

    /**
     * Add a new item to the grid
     * @param {Object} payload - { id, x, y, w, h, content? }
     */
    addItem({ id, x, y, w, h, content }) {
      const newEl = document.createElement('div');
      newEl.id = id;
      newEl.className = 'grid-stack-item';
      newEl.setAttribute('gs-x', x);
      newEl.setAttribute('gs-y', y);
      newEl.setAttribute('gs-w', w);
      newEl.setAttribute('gs-h', h);

      if (content) {
        newEl.innerHTML = `<div class="grid-stack-item-content">${content}</div>`;
      }

      this.el.appendChild(newEl);
      this.grid.addWidget(newEl, { x, y, w, h });

      this.pushEvent('grid:item_added', { id, x, y, w, h });
    },

    /**
     * Remove an item from the grid
     * @param {Object} payload - { id }
     */
    removeItem({ id }) {
      const el = document.getElementById(id);
      if (el) {
        this.grid.removeWidget(el);
        this.pushEvent('grid:item_removed', { id });
      }
    },

    /**
     * Clear all items from the grid
     */
    clearGrid() {
      this.grid.removeAll();
      this.pushEvent('grid:cleared', {});
    },

    /**
     * Batch update multiple items at once
     * @param {Object} payload - { items: [{ id, x, y, w, h }] }
     */
    batchUpdate({ items }) {
      this.grid.batchUpdate();

      items.forEach(({ id, x, y, w, h }) => {
        const el = document.getElementById(id);
        if (el) {
          if (x !== undefined && y !== undefined) {
            this.grid.move(el, x, y);
          }
          if (w !== undefined && h !== undefined) {
            this.grid.resize(el, w, h);
          }
        }
      });

      this.grid.commit();

      this.pushEvent('grid:batch_updated', {
        items: items.map(item => ({ ...item }))
      });
    },

    /**
     * Lock an item to prevent interactions
     * @param {Object} payload - { id }
     */
    lockItem({ id }) {
      const el = document.getElementById(id);
      if (el) {
        this.grid.locked(el, true);
        el.classList.add('grid-stack-item-locked');
        this.pushEvent('grid:item_locked', { id });
      }
    },

    /**
     * Unlock an item to allow interactions
     * @param {Object} payload - { id }
     */
    unlockItem({ id }) {
      const el = document.getElementById(id);
      if (el) {
        this.grid.locked(el, false);
        el.classList.remove('grid-stack-item-locked');
        this.pushEvent('grid:item_unlocked', { id });
      }
    },

    /**
     * Get current grid layout and send to server
     */
    getLayout() {
      const layout = this.grid.getGridItems().map(item => ({
        id: item.id,
        x: item.getAttribute('gs-x'),
        y: item.getAttribute('gs-y'),
        w: item.getAttribute('gs-w'),
        h: item.getAttribute('gs-h')
      }));

      this.pushEvent('grid:layout_requested', { layout });
    },

    destroyed() {
      if (this.grid) {
        this.grid.destroy();
      }
    }
  },

  /**
   * Helper hook for individual grid items
   * Allows per-item configuration and event handling
   *
   * Usage:
   * <div class="grid-stack-item" phx-hook="GridStackItem" id="item-1" data-config='{"minW": 2, "minH": 2}'>
   *   ...
   * </div>
   */
  GridStackItem: {
    mounted() {
      const config = this.el.dataset.config ? JSON.parse(this.el.dataset.config) : {};
      this.itemId = this.el.id;
      this.config = config;

      // Apply item-specific configuration
      if (config.minW) this.el.setAttribute('gs-min-w', config.minW);
      if (config.minH) this.el.setAttribute('gs-min-h', config.minH);
      if (config.maxW) this.el.setAttribute('gs-max-w', config.maxW);
      if (config.maxH) this.el.setAttribute('gs-max-h', config.maxH);

      // Add event listeners for item interactions
      this.el.addEventListener('dblclick', () => this.handleDoubleClick());
    },

    handleDoubleClick() {
      this.pushEvent('grid:item_double_clicked', { id: this.itemId });
    },

    destroyed() {
      // Cleanup if needed
    }
  }
};

// Export for use with LiveView
export default GridStackHooks;
