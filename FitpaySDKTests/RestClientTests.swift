
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"

    var session:RestSession!
    var client:RestClient!
    var crypto:Crypto!

    override func setUp()
    {
        super.setUp()
        self.session = RestSession(clientId:self.clientId, redirectUri:self.redirectUri)
        self.client = RestClient(session: self.session!)
        self.crypto = Crypto()
    }
    
    override func tearDown()
    {
        self.client = nil
        self.session = nil
        self.client = nil
        super.tearDown()
    }

    func testCreateEncryptionKeyCreatesKey()
    {
        let expectation = super.expectationWithDescription("test 'createEncryptionKey' creates key")
        
        self.client.createEncryptionKey(clientPublicKey:self.crypto.publicKey!, completion: { (encryptionKey, error) -> Void in

            XCTAssertNil(error)
            XCTAssertNotNil(encryptionKey)
            XCTAssertNotNil(encryptionKey?.links)
            XCTAssertNotNil(encryptionKey?.keyId)
            XCTAssertNotNil(encryptionKey?.created)
            XCTAssertNotNil(encryptionKey?.createdEpoch)
            XCTAssertNotEqual(encryptionKey?.createdEpoch, 0)
            XCTAssertNotNil(encryptionKey?.serverPublicKey)
            XCTAssertNotNil(encryptionKey?.clientPublicKey)
            XCTAssertNotNil(encryptionKey?.active)
            XCTAssertNotEqual(encryptionKey?.links?.count, 0)

            expectation.fulfill()
        })
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testEncryptionKeyRetrievesKeyWithSameFieldsAsCreated()
    {
        let expectation = super.expectationWithDescription("test 'encryptionKey' retrieves key")

        self.client.createEncryptionKey(clientPublicKey:self.crypto.publicKey!, completion:
        {
            [unowned self](createdEncryptionKey, createdError) -> Void in

            self.client.encryptionKey((createdEncryptionKey?.keyId)!, completion:
            {
                (retrievedEncryptionKey, retrievedError) -> Void in
                
                XCTAssertNil(createdError)
                XCTAssertNotNil(retrievedEncryptionKey)
                XCTAssertNotNil(retrievedEncryptionKey?.links)
                XCTAssertNotNil(retrievedEncryptionKey?.keyId)
                XCTAssertNotNil(retrievedEncryptionKey?.created)
                XCTAssertNotNil(retrievedEncryptionKey?.createdEpoch)
                XCTAssertNotEqual(retrievedEncryptionKey?.createdEpoch, 0)
                XCTAssertNotNil(retrievedEncryptionKey?.serverPublicKey)
                XCTAssertNotNil(retrievedEncryptionKey?.clientPublicKey)
                XCTAssertNotNil(retrievedEncryptionKey?.active)
                XCTAssertNotEqual(retrievedEncryptionKey?.links?.count, 0)
                
                XCTAssertEqual(retrievedEncryptionKey?.links?.count, createdEncryptionKey?.links?.count)
                XCTAssertEqual(retrievedEncryptionKey?.keyId, createdEncryptionKey?.keyId)
                XCTAssertEqual(retrievedEncryptionKey?.created, createdEncryptionKey?.created)
                XCTAssertEqual(retrievedEncryptionKey?.createdEpoch, createdEncryptionKey?.createdEpoch)
                XCTAssertEqual(retrievedEncryptionKey?.serverPublicKey, createdEncryptionKey?.serverPublicKey)
                XCTAssertEqual(retrievedEncryptionKey?.clientPublicKey, createdEncryptionKey?.clientPublicKey)
                XCTAssertEqual(retrievedEncryptionKey?.active, createdEncryptionKey?.active)
                
                expectation.fulfill()
            })

        })

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testEncryptionKeyFailsToRetrieveKeyWithFakeId()
    {
        let expectation = super.expectationWithDescription("test 'encryptionKey' fails to retrieve key with fale id")
        
        self.client.encryptionKey("some_fake_id", completion:
        {
                (retrievedEncryptionKey, retrievedError) -> Void in
                
                XCTAssertNotNil(retrievedError)
                expectation.fulfill()
        })
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }

    // TODO: Find out with Fitpay why this test fails
    func testDeleteEncryptionKeyDeletesCreatedKey()
    {
        let expectation = super.expectationWithDescription("test 'deleteEncryptionKey' deletes key")

        self.client.createEncryptionKey(clientPublicKey:self.crypto.publicKey!, completion:
            {
                [unowned self](createdEncryptionKey, createdError) -> Void in
                
                self.client.encryptionKey((createdEncryptionKey?.keyId)!, completion:
                {
                    [unowned self](retrievedEncryptionKey, retrievedError) -> Void in
                    
                    self.client.deleteEncryptionKey((retrievedEncryptionKey?.keyId)!, completion:
                    {
                        [unowned self](error) -> Void in
                        
                        XCTAssertNil(error)
                        
                        self.client.encryptionKey((retrievedEncryptionKey?.keyId)!, completion:
                        {
                                (againRetrievedEncryptionKey, againRetrievedError) -> Void in
                                
                                XCTAssertNil(againRetrievedEncryptionKey)
                                XCTAssertNotNil(againRetrievedError)
                                expectation.fulfill()
                        })
                    })
                })
                
            })

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
