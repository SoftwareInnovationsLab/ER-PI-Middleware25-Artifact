var fs = require('fs')
var path = require('path')
var assert = require('assert')
const OrbitDB = require('../odb-Api')

var { createProxy, Single_Interleaving } = require('../ProxyInvocations')

const directoryPath = path.join(__dirname, '../interleavings')

describe('OrbitDB_KeyStore', function () {
  it('should perform operations and maintain correct state', async function () {

    const files = fs.readdirSync(directoryPath).filter(file => file.startsWith('ils_') && file.endsWith('.txt')).sort()

    for (const file of files) {
      console.log(`\nProcessing interleavings in: ${file}`)
      const filePath = path.join(directoryPath, file)

      Single_Interleaving(filePath)
      // await new Promise(resolve => setTimeout(resolve, 30000))

      const orbitDB1 = new OrbitDB.OrbitDB(1)
      orbitDB1.addToKeyStore('bar', 'foo')
      assert.strictEqual(orbitDB1.getFromKeyStore('bar'), 'foo', 'Key "bar" should return "foo"')
      const iterator = orbitDB1.iterateKeyStore();
      assert.deepStrictEqual(iterator.next().value, { key: 'bar', value: 'foo' }, 'Iterator should return { key: "bar", value: "foo" }')
    }

  })
})