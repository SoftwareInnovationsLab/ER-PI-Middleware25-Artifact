class OrbitDB {
    constructor(id) {
        this.id = id
        this.keyStore = new KeyStore()
    }

    addToKeyStore(key, value) {
        this.keyStore.add(key, value)
    }

    getFromKeyStore(key) {
        return this.keyStore.get(key)
    }

    *iterateKeyStore() {
        yield* this.keyStore.iterator()
    }
}

class KeyStore {
    constructor() {
        this.store = {}
    }

    add(key, value) {
        this.store[key] = value
    }

    get(key) {
        return this.store[key] !== undefined ? this.store[key] : null
    }

    *iterator() {
        for (const key in this.store) {
            yield { key: key, value: this.store[key] }
        }
    }
}

module.exports = { OrbitDB }
