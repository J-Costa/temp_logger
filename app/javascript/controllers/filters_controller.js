import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    // Auto-submit form on filter change
    this.formTarget.addEventListener("change", () => this.submitForm())
  }

  submitForm() {
    // Submit via Turbo to get Turbo Stream response
    this.formTarget.requestSubmit()
  }
}
