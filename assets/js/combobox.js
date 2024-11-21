export const Combobox = {
    mounted() {
      const wrapperEl = this.el.closest('div')
      const toggleButton = wrapperEl.querySelector('button[phx-click="toggle-options"]')
      const myself = this.el.getAttribute('phx-target')
  
      this.el.addEventListener('keydown', event => {
        if (['ArrowUp', 'ArrowDown'].includes(event.key)) {
          // Prevent cursor-move from first to last character
          event.preventDefault()
        }
  
        if (event.key === 'Enter' && document.activeElement === this.el) {
          // Prevent Submit when combobox is focused
          event.preventDefault()
  
          const listEl = wrapperEl.querySelector('ul')
          const value = listEl && listEl.dataset.focusedOption || null
  
          // The focused value are stored in a data attribute.
          // So, send the selected value to the component.
          this.pushEventTo(myself, "select-option", {option: value})
        }
      })
  
      this.el.addEventListener('keyup', event => {
        if (['Enter', 'Tab', 'Escape', 'ArrowUp', 'ArrowDown'].includes(event.key)) return
  
        // Push the search phrase to the LiveComponent
        this.pushEventTo(myself, "filter-options", {search_phrase: this.el.value})
      })
  
      toggleButton && toggleButton.addEventListener('click', event => {
        this.el.focus()
      })
  
      this.handleEvent("set-input-value", data => {
        // This is sent to all instances of this hook so we need to compare id:s
        if (data.id !== this.el.id) return
        this.el.value = data.label
      })
    }
  }
  
  export const ComboboxOption = {
    mounted() {
      this.el.addEventListener('mouseover', event => {
        const el = event.target
        const value = el.getAttribute('phx-value-option')
        const target = el.getAttribute('phx-target')
  
        this.pushEventTo(target, "set-focus-to", {value: value})
      })
    }
  }
  