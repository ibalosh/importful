import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form", "progressBar", "progressBarValue"]
    initialize() {
        this.updateProgressBar(0);
        this.showUploadButton();
    }

    connect() {
        this.updateProgress = this.updateProgress.bind(this);
        this.hideUploadButton = this.hideUploadButton.bind(this);
        this.showUploadButton = this.showUploadButton.bind(this);

        addEventListener("direct-upload:start", this.hideUploadButton)
        addEventListener("direct-upload:progress", this.updateProgress)
        addEventListener("direct-upload:end", this.showUploadButton)
    }

    disconnect() {
        removeEventListener("direct-upload:start", this.hideUploadButton)
        removeEventListener("direct-upload:progress", this.updateProgress)
        removeEventListener("direct-upload:end", this.showUploadButton)
    }
    updateProgress(event) {
        const { progress } = event.detail;
        this.updateProgressBar(progress);
    }

    /**
     * @param {number} progress
     */
    updateProgressBar(progress) {
        this.progressBarValueTarget.style.width = `${progress}%`
        this.progressBarValueTarget.textContent = `${progress}%`
    }

    /**
     * @param {boolean} display
     */
    displayUploadButton(display) {
        this.formTarget.hidden = !display;
        this.progressBarTarget.hidden = display;
    }

    hideUploadButton() {
        this.displayUploadButton(false)
    }

    showUploadButton() {
        this.displayUploadButton(true)
    }
}