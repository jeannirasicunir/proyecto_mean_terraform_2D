const useMemory = process.env.DISABLE_DB === 'true' || process.env.DISABLE_DB === '1'

if (useMemory) {
    module.exports = require('./UserMemory')
} else {
    const { Schema, model } = require('mongoose')
    const UserSchema = new Schema({
        nombre    : { type: String },
        apellidos : { type: String },
        edad      : { type: Number },
        dni       : { type: String },
        cumple    : { type: String },
        colorFav  : { type: String },
        sexo      : { type: String }
    }, {
        timestamps: true,
        versionKey: false
    })
    module.exports = model('user', UserSchema)
}