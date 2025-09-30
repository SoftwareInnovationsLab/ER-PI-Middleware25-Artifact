const { OrbitDB } = require('./odb-Api')
const fs = require('fs')
const path = require('path')

function createProxy(object) {
    return new Proxy(object, {
        get(target, propKey, receiver) {
            const originalMethod = target[propKey]

            if (typeof originalMethod === 'function') {
                return function (...args) {
                    console.log(`Calling method: ${propKey} with arguments:`, args)
                    const result = originalMethod.apply(target, args)
                    //   console.log(`Method ${propKey} returned:`, result)
                    return result
                }
            }

            return Reflect.get(target, propKey, receiver)
        }
    })
}


// const orbitDB = new OrbitDB(1)
// const proxyOrbitDB = createProxy(orbitDB)
// proxyOrbitDB.addToKeyStore('foo', 'bar')
// proxyOrbitDB.addToKeyStore('bar', 'foo')

// console.log(proxyOrbitDB.getFromKeyStore('foo'))
// console.log(proxyOrbitDB.getFromKeyStore('bar'))

// for (const entry of proxyOrbitDB.iterateKeyStore()) {
//     console.log(entry.key, entry.value)
// }

function Single_Interleaving(filePath) {
    const commands = fs.readFileSync(filePath, 'utf-8').trim().split('\n')

    // console.log("commands: ", commands)
    const orbitDBInstances = {}

    for (const command of commands) {
        const parts = command.split('_')
        // console.log("parts: ", parts)
        const len = parts.length
        const action = parts[0]
        const lamportTime = parts[len - 1]
        const id = parts[len - 2]
        var key
        var value

        if (action === 'OrbitDB') {
            orbitDBInstances[id] = createProxy(new OrbitDB(id))
            console.log(`Created OrbitDB instance with id ${id}`)
        } else if (action === 'add') {
            if (orbitDBInstances[id]) {
                key = parts[1]
                value = parts[2]
                orbitDBInstances[id].addToKeyStore(key, value)
                console.log(`Added key-value pair (${key}: ${value}) to OrbitDB instance with id ${id}`)
            }
        } else if (action === 'get') {
            if (orbitDBInstances[id]) {
                key = parts[1]
                const result = orbitDBInstances[id].getFromKeyStore(key)
                console.log(`Retrieved value for key '${key}' from OrbitDB instance with id ${id}: ${result}`)
            }
        } else if (action === 'iterate') {
            if (orbitDBInstances[id]) {
                console.log(`Iterating over key-value pairs in OrbitDB instance with id ${id}:`)
                for (const entry of orbitDBInstances[id].iterateKeyStore()) {
                    console.log(`${entry.key}: ${entry.value}`)
                }
            }
        }
    }
}

async function All_Interleavings(directoryPath) {
    const files = fs.readdirSync(directoryPath).filter(file => file.startsWith('ils_') && file.endsWith('.txt')).sort()

    for (const file of files) {
        console.log(`\nProcessing interleavings in: ${file}`)
        const filePath = path.join(directoryPath, file)
        Single_Interleaving(filePath)
        //   console.log(`Finished processing interleavings: ${file}`)
        //   console.log('------------------------------')
        await new Promise(resolve => setTimeout(resolve, 30000))
    }
}
const filePath = path.join(__dirname, 'interleavings')
// All_Interleavings(filePath)

module.exports = { createProxy, Single_Interleaving }
