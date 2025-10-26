import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "uploadTab", "manualTab",
    "uploadContent", "manualContent",
    "sheetsContainer", "piecesContainer",
    "sheetTemplate", "pieceTemplate",
    "fileName"
  ]

  static values = {
    sheetIndex: { type: Number, default: 1000 },
    pieceIndex: { type: Number, default: 1000 }
  }

  connect() {
    console.log("ProjectFormController connected")
  }

  switchToUpload(event) {
    event.preventDefault()
    this.uploadTabTarget.classList.add("border-indigo-500", "text-indigo-600")
    this.uploadTabTarget.classList.remove("border-transparent", "text-gray-500")
    this.manualTabTarget.classList.remove("border-indigo-500", "text-indigo-600")
    this.manualTabTarget.classList.add("border-transparent", "text-gray-500")
    
    this.uploadContentTarget.classList.remove("hidden")
    this.manualContentTarget.classList.add("hidden")
  }

  switchToManual(event) {
    event.preventDefault()
    this.manualTabTarget.classList.add("border-indigo-500", "text-indigo-600")
    this.manualTabTarget.classList.remove("border-transparent", "text-gray-500")
    this.uploadTabTarget.classList.remove("border-indigo-500", "text-indigo-600")
    this.uploadTabTarget.classList.add("border-transparent", "text-gray-500")
    
    this.manualContentTarget.classList.remove("hidden")
    this.uploadContentTarget.classList.add("hidden")
  }

  addSheet(event) {
    event.preventDefault()
    console.log("Adding sheet...")
    const content = this.sheetTemplateTarget.innerHTML.replace(/NEW_SHEET_RECORD/g, this.sheetIndexValue)
    this.sheetsContainerTarget.insertAdjacentHTML('beforeend', content)
    this.sheetIndexValue++
    console.log("Sheet added, new index:", this.sheetIndexValue)
  }

  addPiece(event) {
    event.preventDefault()
    console.log("Adding piece...")
    const content = this.pieceTemplateTarget.innerHTML.replace(/NEW_PIECE_RECORD/g, this.pieceIndexValue)
    this.piecesContainerTarget.insertAdjacentHTML('beforeend', content)
    this.pieceIndexValue++
    console.log("Piece added, new index:", this.pieceIndexValue)
  }

  removeField(event) {
    event.preventDefault()
    const field = event.target.closest('[data-project-form-target="sheetField"], [data-project-form-target="pieceField"]')
    
    if (field) {
      const destroyField = field.querySelector('input[name*="_destroy"]')
      if (destroyField) {
        destroyField.value = "1"
      }
      field.style.display = 'none'
    }
  }

  handleFileUpload(event) {
    const file = event.target.files[0]
    if (file) {
      this.fileNameTarget.textContent = `📄 Arquivo selecionado: ${file.name}`
    }
  }
}

