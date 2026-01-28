const mongoose = require('mongoose')

const disabled = process.env.DISABLE_DB === 'true' || process.env.DISABLE_DB === '1'
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost/nodejs-mongo'

if (disabled) {
    console.log('DB disabled: running with in-memory storage')
} else {
    mongoose.connect(mongoUri, {
            useUnifiedTopology: true,
            useNewUrlParser: true,
            useFindAndModify: false
    })
    .then(() => console.log('Conectado a Mongo'))
    .catch((err) => console.log(err))
}