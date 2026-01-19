let store = []
let idCounter = 1

class UserMemory {
  constructor(data) {
    this._id = String(idCounter++)
    this.nombre = data?.nombre || null
    this.apellidos = data?.apellidos || null
    this.edad = data?.edad || null
    this.dni = data?.dni || null
    this.cumple = data?.cumple || null
    this.colorFav = data?.colorFav || null
    this.sexo = data?.sexo || null
    this.createdAt = new Date()
    this.updatedAt = new Date()
  }

  async save() {
    const existingIndex = store.findIndex(u => u._id === this._id)
    if (existingIndex >= 0) {
      this.updatedAt = new Date()
      store[existingIndex] = this
    } else {
      store.push(this)
    }
    return this
  }

  static async find() {
    return store
  }

  static async findById(id) {
    return store.find(u => u._id === String(id)) || null
  }

  static async findByIdAndUpdate(id, update) {
    const idx = store.findIndex(u => u._id === String(id))
    if (idx === -1) return null
    const current = store[idx]
    const updated = { ...current, ...update, updatedAt: new Date() }
    store[idx] = updated
    return updated
  }

  static async findByIdAndDelete(id) {
    const idx = store.findIndex(u => u._id === String(id))
    if (idx === -1) return null
    const [removed] = store.splice(idx, 1)
    return removed
  }
}

module.exports = UserMemory
