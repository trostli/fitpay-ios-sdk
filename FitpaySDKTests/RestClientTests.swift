
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
                XCTAssertNotNil(user?.encryptedData)
                XCTAssertNotNil(user?.info?.email)
                XCTAssertNil(error)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreateCreditCardCreatesCreditCardsForUser()
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
                
                self.client.createCreditCard(userId: self.session.userId!, pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
                {
                    (card, error) -> Void in
                        
                    XCTAssertNil(error)
                    XCTAssertNotNil(card?.links)
                    XCTAssertNotNil(card?.creditCardId)
                    XCTAssertNotNil(card?.userId)
                    XCTAssertNotNil(card?.isDefault)
                    XCTAssertNotNil(card?.created)
                    XCTAssertNotNil(card?.createdEpoch)
                    XCTAssertNotNil(card?.state)
                    XCTAssertNotNil(card?.cardType)
                    XCTAssertNotNil(card?.cardMetaData)
                    XCTAssertNotNil(card?.deviceRelationships)
                    XCTAssertNotEqual(card?.deviceRelationships?.count, 0)
                    XCTAssertNotNil(card?.encryptedData)
                    XCTAssertNotNil(card?.info)
                    XCTAssertNotNil(card?.info?.address)
                    XCTAssertNotNil(card?.info?.cvv)
                    XCTAssertNotNil(card?.info?.expMonth)
                    XCTAssertNotNil(card?.info?.expYear)
                    XCTAssertNotNil(card?.info?.pan)
                    
                    expectation.fulfill()
                })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardsRetrievesCreditCardsForUser()
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
                        XCTAssertNotNil(card.info)
                        XCTAssertNotNil(card.info?.address)
                        XCTAssertNotNil(card.info?.cvv)
                        XCTAssertNotNil(card.info?.expMonth)
                        XCTAssertNotNil(card.info?.expYear)
                        XCTAssertNotNil(card.info?.pan)
                    }
                }
                
                XCTAssertNotNil(result?.links)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardRetrievesCreditCardForUser()
    {
        let expectation = super.expectationWithDescription("'creditCard' retrieves credit card for user")
        
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
                [unowned self](result, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(result)
                XCTAssertNotNil(result?.limit)
                XCTAssertNotNil(result?.offset)
                XCTAssertNotNil(result?.totalResults)
                XCTAssertNotNil(result?.results)
                XCTAssertNotEqual(result?.results?.count, 0)
                XCTAssertNotNil(result?.links)
                
                if let results = result?.results where result?.results?.count > 0
                {
                    // pick one of the cards randomly
                    let card = results[Int(arc4random() % UInt32(results.count))]
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
                    XCTAssertNotNil(card.info)
                    XCTAssertNotNil(card.info?.address)
                    XCTAssertNotNil(card.info?.cvv)
                    XCTAssertNotNil(card.info?.expMonth)
                    XCTAssertNotNil(card.info?.expYear)
                    XCTAssertNotNil(card.info?.pan)
                    
                    self.client.creditCard(creditCardId: card.creditCardId!, userId: self.session.userId!, completion:
                    {
                        (creditCard, error) -> Void in
                        XCTAssertNil(error)
                        XCTAssertNotNil(creditCard?.links)
                        XCTAssertNotNil(creditCard?.creditCardId)
                        XCTAssertNotNil(creditCard?.userId)
                        XCTAssertNotNil(creditCard?.isDefault)
                        XCTAssertNotNil(creditCard?.state)
                        XCTAssertNotNil(creditCard?.cardType)
                        XCTAssertNotNil(creditCard?.cardMetaData)
                        XCTAssertNotNil(creditCard?.deviceRelationships)
                        XCTAssertNotEqual(creditCard?.deviceRelationships?.count, 0)
                        XCTAssertNotNil(creditCard?.encryptedData)
                        XCTAssertNotNil(creditCard?.info)
                        XCTAssertNotNil(creditCard?.info?.address)
                        XCTAssertNotNil(creditCard?.info?.cvv)
                        XCTAssertNotNil(creditCard?.info?.expMonth)
                        XCTAssertNotNil(creditCard?.info?.expYear)
                        XCTAssertNotNil(creditCard?.info?.pan)
                                                
                        XCTAssertEqual(creditCard?.userId, card.userId)
                        XCTAssertEqual(creditCard?.isDefault, card.isDefault)
                        XCTAssertEqual(creditCard?.state, card.state)
                        XCTAssertEqual(creditCard?.cardType, card.cardType)
                        
                        expectation.fulfill()

                    })
                }
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardGetErrorForFakeCardId()
    {
        let expectation = super.expectationWithDescription("'creditCard' gets error for fake card id")
        
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
            
            self.client.creditCard(creditCardId:"fakeCraditCardId" , userId: self.session.userId!, completion:
            {
                (creditCard, error) -> Void in
                XCTAssertNotNil(error)
                XCTAssertNil(creditCard)
                expectation.fulfill()
            })
            
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeleteCreditCardDeletesCreditCardAfterCreatingIt()
    {
        let expectation = super.expectationWithDescription("'deleteCreditCard' deletes credit card after creating it")
        
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
                
                self.client.createCreditCard(userId: self.session.userId!, pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
                    {
                        [unowned self](card, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(card?.links)
                        XCTAssertNotNil(card?.creditCardId)
                        XCTAssertNotNil(card?.userId)
                        XCTAssertNotNil(card?.isDefault)
                        XCTAssertNotNil(card?.created)
                        XCTAssertNotNil(card?.createdEpoch)
                        XCTAssertNotNil(card?.state)
                        XCTAssertNotNil(card?.cardType)
                        XCTAssertNotNil(card?.cardMetaData)
                        XCTAssertNotNil(card?.deviceRelationships)
                        XCTAssertNotEqual(card?.deviceRelationships?.count, 0)
                        XCTAssertNotNil(card?.encryptedData)
                        XCTAssertNotNil(card?.info)
                        XCTAssertNotNil(card?.info?.address)
                        XCTAssertNotNil(card?.info?.cvv)
                        XCTAssertNotNil(card?.info?.expMonth)
                        XCTAssertNotNil(card?.info?.expYear)
                        XCTAssertNotNil(card?.info?.pan)
                        
                        self.client.deleteCreditCard(creditCardId: card!.creditCardId!, userId: self.session.userId!, completion:
                        {
                            [unowned self](error) -> Void in
                            
                            XCTAssertNil(error)
                            self.client.creditCard(creditCardId:card!.creditCardId! , userId: self.session.userId!, completion:
                            {
                                (creditCard, error) -> Void in
                                XCTAssertNotNil(error)
                                XCTAssertNil(creditCard)
                                expectation.fulfill()
                            })
                        })
                })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUpdateCreditCardUpdatesCreditCard()
    {
        let expectation = super.expectationWithDescription("'creditCard' update credit card for user")
        
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
                [unowned self](result, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(result)
                XCTAssertNotNil(result?.limit)
                XCTAssertNotNil(result?.offset)
                XCTAssertNotNil(result?.totalResults)
                XCTAssertNotNil(result?.results)
                XCTAssertNotEqual(result?.results?.count, 0)
                XCTAssertNotNil(result?.links)
                
                if let results = result?.results where result?.results?.count > 0
                {
                    // pick one of the cards randomly
                    let card = results[Int(arc4random() % UInt32(results.count))]
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
                    XCTAssertNotNil(card.info)
                    XCTAssertNotNil(card.info?.address)
                    XCTAssertNotNil(card.info?.cvv)
                    XCTAssertNotNil(card.info?.expMonth)
                    XCTAssertNotNil(card.info?.expYear)
                    XCTAssertNotNil(card.info?.pan)
                    
                    let street2 = "Street \(NSDate().timeIntervalSince1970)"
                    
                    self.client.updateCreditCard(creditCardId: card.creditCardId!, userId: self.session.userId!, name: nil, street1: nil, street2: street2, city: "California", state: "CA", postalCode: nil, countryCode: nil, completion:
                        {
                            (updatedCreditCard, error) -> Void in
                            
                            XCTAssertNil(error)
                            XCTAssertNotNil(updatedCreditCard)
                            XCTAssertEqual(updatedCreditCard?.info?.address?.street2, street2)
                            
                            expectation.fulfill()

                        })
                    }
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
            XCTAssertNil(error)
            XCTAssertTrue(self.session.isAuthorized)
            
            if !self.session.isAuthorized
            {
                expectation.fulfill()
                return
            }
            
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
                    XCTAssertNotNil(deviceInfo.deviceIdentifier)
                    XCTAssertNotNil(deviceInfo.metadata)
                }
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceCreateNewDeviceForUser()
    {
        let expectation = super.expectationWithDescription("test 'device' creates new device for user with id")
        
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
            
            self.createDefaultDevice(self.session.userId!, completion:
            {
                (device, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(device)
                XCTAssertNotNil(device!.deviceIdentifier)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceDeleteDeviceWithId()
    {
        let expectation = super.expectationWithDescription("test 'device' delete device")
        
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
            
            self.createDefaultDevice(self.session.userId!, completion:
            {
                (device, error) -> Void in
                XCTAssertNil(error)
                
                self.client.deleteDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                {
                    (error) -> Void in
                    XCTAssertNil(error)
                    expectation.fulfill()
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesDeviceById()
    {
        let expectation = super.expectationWithDescription("test 'device' delete device")
        
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
            
            self.createDefaultDevice(self.session.userId!, completion:
            {
                (device, error) -> Void in
                XCTAssertNil(error)
                
                self.client.device(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                {
                    (device, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(device)
                    self.client.deleteDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                    {
                        (error) -> Void in
                        XCTAssertNil(error)
                        expectation.fulfill()
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceUpdateDeviceWithId()
    {
        let expectation = super.expectationWithDescription("test 'device' update device")
        
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
            
            self.createDefaultDevice(self.session.userId!, completion:
            {
                (device, error) -> Void in
                XCTAssertNil(error)
                
                let firmwareRev = "2.7.7.7"
                let softwareRev = "6.8.1"
                self.client.updateDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, firmwareRevision: firmwareRev, softwareRevision: softwareRev, completion:
                {
                    (updatedDevice, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(updatedDevice)
                    
                    XCTAssertTrue(updatedDevice?.softwareRevision == softwareRev)
                    XCTAssertTrue(updatedDevice?.firmwareRevision == firmwareRev)
                    
                    self.client.deleteDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                    {
                        (error) -> Void in
                        XCTAssertNil(error)
                        expectation.fulfill()
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesCommitsFromDevice()
    {
        let expectation = super.expectationWithDescription("test 'device' retrieving commits from device")
        
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
            
            self.client.devices(userId: self.session.userId!, limit: 1, offset: 0, completion:
            {
                (devices, error) -> Void in
                XCTAssertNil(error)
                self.client.commits(deviceId: devices!.results![0].deviceIdentifier!, userId: self.session.userId!, commitsAfter: "", limit: 10, offset: 0, completion:
                {
                    (commits, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(commits)
                    XCTAssertNotNil(commits?.limit)
                    XCTAssertNotNil(commits?.totalResults)
                    XCTAssertNotNil(commits?.links)
                    XCTAssertNotNil(commits?.results)
                    
                    for commit in commits!.results! {
                        XCTAssertNotNil(commit.commitType)
                        XCTAssertNotNil(commit.payload)
                        XCTAssertNotNil(commit.commit)
                    }
                    
                    expectation.fulfill()
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesCommitFromDeviceWithCommitId()
    {
        let expectation = super.expectationWithDescription("test 'device' retrieving commit from device")
        
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
            
            self.client.devices(userId: self.session.userId!, limit: 1, offset: 0, completion:
            {
                (devices, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(devices)
                
                if devices == nil
                {
                    expectation.fulfill()
                }
                
                self.client.commits(deviceId: devices!.results![0].deviceIdentifier!, userId: self.session.userId!, commitsAfter: "", limit: 10, offset: 0, completion:
                {
                    (commits, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(commits)
                    XCTAssertNotNil(commits?.limit)
                    XCTAssertNotNil(commits?.totalResults)
                    XCTAssertNotNil(commits?.links)
                    XCTAssertNotNil(commits?.results)
                    
                    var someCommitId = ""
                    for commit in commits!.results! {
                        XCTAssertNotNil(commit.commitType)
                        XCTAssertNotNil(commit.payload)
                        XCTAssertNotNil(commit.commit)
                        someCommitId = commit.commit!
                    }
                    
                    self.client.commit(commitId: someCommitId, deviceId: devices!.results![0].deviceIdentifier!, userId: self.session.userId!, completion:
                    {
                        (commit, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(commit)
                        XCTAssertNotNil(commit?.commitType)
                        XCTAssertNotNil(commit?.payload)
                        XCTAssertNotNil(commit?.commit)
                        
                        expectation.fulfill()
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testRelationshipsRetrievesRelationshipsWithUserId()
    {
        let expectation = super.expectationWithDescription("test 'relationships' retrieving relationships with user id")
        
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
            
            self.client.createCreditCard(userId: self.session.userId!, pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
            {
                (card, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(card)
                
                self.createDefaultDevice(self.session.userId!, completion:
                {
                    (device, error) -> Void in
                    
                    XCTAssertNil(error)
                    XCTAssertNotNil(device)
                    
                    self.client.createRelationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                    {
                        (relationship, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(device)
                        
                        XCTAssertNotNil(relationship?.device)
                        XCTAssertNotNil(relationship?.card)
                        
                        self.client.relationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                        {
                            (relationship, error) -> Void in
                            XCTAssertNil(error)
                            XCTAssertNotNil(relationship)
                            XCTAssertNotNil(relationship?.device)
                            XCTAssertNotNil(relationship?.card)
                        
                            self.client.deleteRelationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                            {
                                (error) -> Void in
                                
                                XCTAssertNil(error)
                                    
                                self.client.deleteDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                                {
                                    (error) -> Void in
                                    
                                    XCTAssertNil(error)
                                    
                                    self.client.deleteCreditCard(creditCardId: card!.creditCardId!, userId: self.session.userId!, completion:
                                    {
                                        (error) -> Void in
                                        
                                        XCTAssertNil(error)
                                        
                                        expectation.fulfill()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testRelationshipsCreatesAndDeletesRelationship()
    {
        let expectation = super.expectationWithDescription("test 'relationships' creates and deletes relationship")
        
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
            
            self.client.createCreditCard(userId: self.session.userId!, pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
            {
                (card, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(card)
                
                self.createDefaultDevice(self.session.userId!, completion:
                {
                    (device, error) -> Void in
                    
                    XCTAssertNil(error)
                    XCTAssertNotNil(device)
                    
                    self.client.createRelationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                    {
                        (relationship, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(device)
                        
                        XCTAssertNotNil(relationship?.device)
                        XCTAssertNotNil(relationship?.card)
                        
                        self.client.deleteRelationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                        {
                            (error) -> Void in
                            
                            XCTAssertNil(error)
                            
                            self.client.relationship(userId: self.session.userId!, creditCardId: card!.creditCardId!, deviceId: device!.deviceIdentifier!, completion:
                            {
                                (relationship, error) -> Void in
                                XCTAssertNotNil(error)
                                
                                self.client.deleteDevice(deviceId: device!.deviceIdentifier!, userId: self.session.userId!, completion:
                                {
                                    (error) -> Void in
                                    
                                    XCTAssertNil(error)
                                    self.client.deleteCreditCard(creditCardId: card!.creditCardId!, userId: self.session.userId!, completion:
                                    {
                                        (error) -> Void in
                                        XCTAssertNil(error)
                                        expectation.fulfill()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func createDefaultDevice(userId: String, completion:RestClient.CreateNewDeviceHandler)
    {
        let deviceType = "ACTIVITY_TRACKER"
        let manufacturerName = "Fitpay"
        let deviceName = "PSPS"
        let serialNumber = "074DCC022E14"
        let modelNumber = "FB404"
        let hardwareRevision = "1.0.0.0"
        let firmwareRevision = "1030.6408.1309.0001"
        let softwareRevision = "2.0.242009.6"
        let systemId = "0x123456FFFE9ABCDE"
        let osName = "ANDROID"
        let licenseKey = "6b413f37-90a9-47ed-962d-80e6a3528036"
        let bdAddress = "977214bf-d038-4077-bdf8-226b17d5958d"
        let secureElementId = "8615b2c7-74c5-43e5-b224-38882060161b"
        let pairing = "2016-02-29T21:42:21.469Z"
        
        self.client.createNewDevice(userId: self.session.userId!, deviceType: deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion:
        {
            (device, error) -> Void in
            completion(device: device, error: error)
        })
    }
    
    func testAssetsRetrievesAsset()
    {
        let expectation = super.expectationWithDescription("'assets' retrieving commits from device")
        
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
            
            self.client.assets(adapterData:"401", adapterId: "1131178c-aab5-438b-ab9d-a6572cb64c8c", assetId:"143320683", completion:
            {
                (asset, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(asset)
                XCTAssertNotNil(asset?.image)
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
