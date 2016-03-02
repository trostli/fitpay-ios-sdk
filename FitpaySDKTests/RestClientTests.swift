
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "testable@something.com"
    let password = "1029"

    var session:RestSession!
    var client:RestClient!

    override func setUp()
    {
        super.setUp()
        self.session = RestSession(clientId:self.clientId, redirectUri:self.redirectUri)
        self.client = RestClient(session: self.session!)
    }
    
    override func tearDown()
    {
        self.client = nil
        self.session = nil
        super.tearDown()
    }

    func testCreateEncryptionKeyCreatesKey()
    {
        let expectation = super.expectationWithDescription("'createEncryptionKey' creates key")
        
        self.client.createEncryptionKey(clientPublicKey:self.client.keyPair.publicKey!, completion: { (encryptionKey, error) -> Void in

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
        let expectation = super.expectationWithDescription("'encryptionKey' retrieves key")

        self.client.createEncryptionKey(clientPublicKey:self.client.keyPair.publicKey!, completion:
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
        let expectation = super.expectationWithDescription("'encryptionKey' fails to retrieve key with fale id")
        
        self.client.encryptionKey("some_fake_id", completion:
        {
                (retrievedEncryptionKey, retrievedError) -> Void in
                
                XCTAssertNotNil(retrievedError)
                expectation.fulfill()
        })
        
        super.waitForExpectationsWithTimeout(100, handler: nil)
    }

    func testDeleteEncryptionKeyDeletesCreatedKey()
    {
        let expectation = super.expectationWithDescription("'deleteEncryptionKey' deletes key")

        self.client.createEncryptionKey(clientPublicKey:self.client.keyPair.publicKey!, completion:
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

        super.waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    func testUserRetrievesUserById()
    {
        let expectation = super.expectationWithDescription("'user' retrieves user by her id")
        
        self.session.login(username: self.username, password: self.password)
        {
            [unowned self](error) -> Void in
            
            XCTAssertNil(error)
            XCTAssertTrue(self.session.isAuthorized)
            
            if !self.session.isAuthorized
            {
                expectation.fulfill()
                return
            }
            
            self.client.user(id: self.session.userId!, completion:
            {
                (user, error) -> Void in
                
                XCTAssertNotNil(user)
                XCTAssertNotNil(user?.info)
                XCTAssertNotNil(user?.created)
                XCTAssertNotNil(user?.links)
                XCTAssertNotNil(user?.createdEpoch)
                XCTAssertNotNil(user?.lastModified)
                XCTAssertNotNil(user?.lastModifiedEpoch)
                XCTAssertNotNil(user?.encryptedData)
                XCTAssertNotNil(user?.info?.email)
                XCTAssertNil(error)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardRetrievesCreditCardsForUser()
    {
        let expectation = super.expectationWithDescription("'creditCards' retrieves credit cards for user")
        
        self.session.login(username: self.username, password: self.password)
        {
            [unowned self](error) -> Void in
            
            XCTAssertNil(error)
            XCTAssertTrue(self.session.isAuthorized)

            if !self.session.isAuthorized
            {
                expectation.fulfill()
                return
            }
            
            self.client.creditCards(userId: self.session.userId!, excludeState:[], limit: 10, offset: 0, completion:
            {
                (result, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(result)
                XCTAssertNotNil(result?.limit)
                XCTAssertNotNil(result?.offset)
                XCTAssertNotNil(result?.totalResults)
                XCTAssertNotNil(result?.results)
                XCTAssertNotEqual(result?.results?.count, 0)
                
                if let results = result?.results
                {
                    for card in results
                    {
                        XCTAssertNotNil(card.links)
                        XCTAssertNotNil(card.creditCardId)
                        XCTAssertNotNil(card.userId)
                        XCTAssertNotNil(card.isDefault)
                        XCTAssertNotNil(card.created)
                        XCTAssertNotNil(card.createdEpoch)
                        XCTAssertNotNil(card.state)
                        XCTAssertNotNil(card.cardType)
                        XCTAssertNotNil(card.cardMetaData)
                        XCTAssertNotNil(card.deviceRelationships)
                        XCTAssertNotEqual(card.deviceRelationships?.count, 0)
                        XCTAssertNotNil(card.encryptedData)
                    }
                }
                
                XCTAssertNotNil(result?.links)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesDevicesByUserId()
    {
        let expectation = super.expectationWithDescription("test 'device' retrieves devices by user id")
        
        self.session.login(username: self.username, password: self.password)
        {
            [unowned self](error) -> Void in
            self.client.devices(userId: self.session.userId!, limit: 10, offset: 0, completion:
            {
                (devices, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(devices)
                XCTAssertNotNil(devices?.limit)
                XCTAssertNotNil(devices?.totalResults)
                XCTAssertNotNil(devices?.links)
                XCTAssertNotNil(devices?.results)
                
                for deviceInfo in devices!.results! {
                    XCTAssertNotNil(deviceInfo.metadata)
                }
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
