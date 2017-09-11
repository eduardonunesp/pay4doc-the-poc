const PayForDoc = artifacts.require('./PayForDoc.sol');

contract('PayForDoc', accounts => {
  it('should add a new document', () => {
    const title = 'the doc'
    const description = 'an awesome doc about solidity'
    const ipfsHash = '1234-4321-abcd-edfg'
    const price = 1

    return PayForDoc.deployed().then(instance => {
      return instance.addDocument(title, description, ipfsHash, price)
    }).then(result => {
      const newContractFound = result.logs.find(log => log.event === 'NewDocument')
      assert.equal(!!newContractFound, true, "New Contract isn't executed")
    });
  });

  it('should get document by address', () => {
    const title = 'my doc'
    const description = 'some document from computers'
    const ipfsHash = 'abcd-efgh-1234-4321'
    const price = 2
    let payForDoc
    let newContractFound

    return PayForDoc.deployed().then(instance => {
      payForDoc = instance
      return instance.addDocument(title, description, ipfsHash, price)
    }).then(result => {
      newContractFound = result.logs.find(log => log.event === 'NewDocument')
      assert.equal(!!newContractFound, true, "New Contract isn't executed")
      return payForDoc.documentTitleByAddress.call(newContractFound.args.documentAddr)
    }).then(result => {
      assert.equal(newContractFound.args.title, result)
    })
  })

  it('should buy an existing document', () => {
    const title = 'doc'
    const description = 'fine doc'
    const ipfsHash = '1234-4321-abcd-efgh'
    const price = 3
    let payForDoc
    let newContractFound

    return PayForDoc.deployed().then(instance => {
      payForDoc = instance
      return instance.addDocument(title, description, ipfsHash, price)
    }).then(result => {
      newContractFound = result.logs.find(log => log.event === 'NewDocument')
      assert.equal(!!newContractFound, true, "New Contract isn't executed")
      return payForDoc.buyDocument(newContractFound.args.documentAddr, {from: accounts[1], value: 3})
    }).then(result => {
      NewOwner = result.logs.find(log => log.event === 'NewOwner')
      assert.equal(!!NewOwner, true, 'Cannot buy the document')
      // console.log('transaction', JSON.stringify(result.logs, null, 2))
    })
  })
});
