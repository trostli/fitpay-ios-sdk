
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "testableuser@something.com"
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
                        
                        user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
            
                user?.listCreditCards(excludeState:[], limit: 10, offset: 0, completion:
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
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardDeleteDeletesCreditCardAfterCreatingIt()
    {
        let expectation = super.expectationWithDescription("'delete' deletes credit card after creating it")
        
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                        
                        card?.delete
                        {
                            (error) -> Void in
                            
                            XCTAssertNil(error)
                            user?.listCreditCards(excludeState: [], limit: 0, offset: 0, completion: { (result, error) -> Void in
                                
                                XCTAssertNil(error)
                                
                                if let results = result?.results
                                {
                                    for currentCard in results
                                    {
                                        if currentCard.creditCardId == card?.creditCardId
                                        {
                                            XCTFail("credit card deletion failure")
                                        }
                                    }
                                    
                                    expectation.fulfill()
                                }
                            })
                        }
                    })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUpdateUpdatesCreditCard()
    {
        let expectation = super.expectationWithDescription("'update' updates credit card")
        
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
            
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                    
                    let name = "User\(NSDate().timeIntervalSince1970)"
                    
                    card?.update(name:name, street1: nil, street2: nil, city: nil, state: nil, postalCode: nil, countryCode: nil, completion:
                    {
                        (updatedCard, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(updatedCard)

                        user?.listCreditCards(excludeState: [], limit: 0, offset: 0, completion: { (result, error) -> Void in
                            
                            XCTAssertNil(error)
                            
                            if let results = result?.results
                            {
                                for currentCard in results
                                {
                                    if currentCard.creditCardId == updatedCard?.creditCardId
                                    {
                                        XCTAssertEqual(updatedCard?.info?.name, name)
                                        XCTAssertEqual(updatedCard?.info?.name, currentCard.info?.name)
                                        
                                        updatedCard?.delete
                                        {
                                            (error) in
                                            XCTAssertNil(error)
                                            expectation.fulfill()
                                        }
                                    }
                                }
                            }
                        })
                    })
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testMakeDefaultMakesCreditCardDefault()
    {
        let expectation = super.expectationWithDescription("'makeDefault' makes credit card default")
        
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
            
            self.client.user(id:self.session.userId!, completion:
                {
                    (user, error) -> Void in
                    XCTAssertNil(error)
                    user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                            
                            card?.acceptTerms
                                {
                                    (pending, acceptedCard, error) in
                                    XCTAssertNil(error)
                                    XCTAssertNotNil(acceptedCard)
                                    XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                                    
                                    if let verificationMethods = acceptedCard?.verificationMethods
                                    {
                                        for verificationMethod in verificationMethods
                                        {
                                            verificationMethod.selectVerificationType
                                                {
                                                    (pending, verificationMethod, error) in
                                                    XCTAssertNotNil(verificationMethod)
                                                    XCTAssertNil(error)
                                                    
                                                    verificationMethod?.verify("12345", completion:
                                                        {
                                                            (pending, verificationMethod, error) -> Void in
                                                            XCTAssertNil(error)
                                                            XCTAssertNotNil(verificationMethod)
                                                            
                                                            verificationMethod?.retrieveCreditCard
                                                            {
                                                                (retrievedCreditCard, error) -> Void in
                                                                XCTAssertNil(error)
                                                                XCTAssertNotNil(retrievedCreditCard)

                                                                retrievedCreditCard?.makeDefault
                                                                {
                                                                    (pending, defaultCreditCard, error) -> Void in
                                                                    XCTAssertNil(error)
                                                                    XCTAssertNotNil(defaultCreditCard)
                                                                    defaultCreditCard?.delete
                                                                    {
                                                                        (error) -> Void in
                                                                        XCTAssertNil(error)
                                                                        expectation.fulfill()
                                                                    }


                                                                }
                                                            }
                                                    })
                                            }
                                            
                                            break
                                        }
                                    }
                                    else
                                    {
                                        XCTFail("Failed to find verification methods")
                                        card?.delete
                                            {
                                                (error) -> Void in
                                                XCTAssertNil(error)
                                                expectation.fulfill()
                                        }
                                    }
                            }
                    })
            })

            
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeactivateCreditCard()
    {
        let expectation = super.expectationWithDescription("'deactivate' makes credit card deactivated")
        
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
            
            self.client.user(id:self.session.userId!, completion:
                {
                    (user, error) -> Void in
                    XCTAssertNil(error)
                    user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                            
                            card?.acceptTerms
                            {
                                (pending, acceptedCard, error) in
                                XCTAssertNil(error)
                                XCTAssertNotNil(acceptedCard)
                                XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                                
                                if let verificationMethods = acceptedCard?.verificationMethods
                                {
                                    for verificationMethod in verificationMethods
                                    {
                                        verificationMethod.selectVerificationType
                                        {
                                            (pending, verificationMethod, error) in
                                            XCTAssertNotNil(verificationMethod)
                                            XCTAssertNil(error)
                                            
                                            verificationMethod?.verify("12345", completion:
                                            {
                                                (pending, verificationMethod, error) -> Void in
                                                XCTAssertNil(error)
                                                XCTAssertNotNil(verificationMethod)
                                                
                                                verificationMethod?.retrieveCreditCard
                                                {
                                                    (retrievedCreditCard, error) -> Void in
                                                    retrievedCreditCard?.deactivate(causedBy:.CARDHOLDER, reason: "lost card", completion:
                                                        {
                                                            (pending, deactivatedCreditCard, error) -> Void in
                                                            XCTAssertNil(error)
                                                            XCTAssertNotNil(deactivatedCreditCard)
                                                            XCTAssertEqual(deactivatedCreditCard?.state, "DEACTIVATED")
                                                            deactivatedCreditCard?.delete
                                                            {
                                                                (error) -> Void in
                                                                XCTAssertNil(error)
                                                                expectation.fulfill()
                                                            }
                                                    })
                                                }
                                            })
                                        }
                                        
                                        break
                                    }
                                }
                                else
                                {
                                    XCTFail("Failed to find verification methods")
                                    card?.delete
                                        {
                                            (error) -> Void in
                                            XCTAssertNil(error)
                                            expectation.fulfill()
                                    }
                                }
                            }
                    })
            })
            
            
            
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testReactivateCreditCardActivatesCard()
    {
        let expectation = super.expectationWithDescription("'reactivate' makes credit card activated")
        
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
                
                self.client.user(id:self.session.userId!, completion:
                    {
                        (user, error) -> Void in
                        XCTAssertNil(error)
                        user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                                
                                card?.acceptTerms
                                    {
                                        (pending, acceptedCard, error) in
                                        XCTAssertNil(error)
                                        XCTAssertNotNil(acceptedCard)
                                        XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                                        
                                        if let verificationMethods = acceptedCard?.verificationMethods
                                        {
                                            for verificationMethod in verificationMethods
                                            {
                                                verificationMethod.selectVerificationType
                                                    {
                                                        (pending, verificationMethod, error) in
                                                        XCTAssertNotNil(verificationMethod)
                                                        XCTAssertNil(error)
                                                        
                                                        verificationMethod?.verify("12345", completion:
                                                            {
                                                                (pending, verificationMethod, error) -> Void in
                                                                XCTAssertNil(error)
                                                                XCTAssertNotNil(verificationMethod)
                                                                
                                                                verificationMethod?.retrieveCreditCard
                                                                    {
                                                                        (retrievedCreditCard, error) -> Void in
                                                                        retrievedCreditCard?.deactivate(causedBy:.CARDHOLDER, reason: "lost card", completion:
                                                                            {
                                        (pending, deactivatedCreditCard, error) -> Void in
                                        XCTAssertNil(error)
                                        XCTAssertNotNil(deactivatedCreditCard)
                                        XCTAssertEqual(deactivatedCreditCard?.state, "DEACTIVATED")
                                        
                                        deactivatedCreditCard?.reactivate(causedBy: .CARDHOLDER, reason: "found card", completion: { (pending, reactivatedCreditCard, error) -> Void in
                                            XCTAssertNil(error)
                                            XCTAssertNotNil(reactivatedCreditCard)
                                            XCTAssertEqual(reactivatedCreditCard?.state, "ACTIVE")
                                            reactivatedCreditCard?.delete
                                                {
                                                    (error) -> Void in
                                                    XCTAssertNil(error)
                                                    expectation.fulfill()
                                                                                    }
                                                                                })
                                                                                
                                                                                
                                                                        })
                                                                }
                                                        })
                                                }
                                                
                                                break
                                            }
                                        }
                                        else
                                        {
                                            XCTFail("Failed to find verification methods")
                                            card?.delete
                                                {
                                                    (error) -> Void in
                                                    XCTAssertNil(error)
                                                    expectation.fulfill()
                                            }
                                        }
                                }
                        })
                })
                
        }
        
        super.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testCreditCardAcceptTerms()
    {
        let expectation = super.expectationWithDescription("'creditCard' accept terms")
        
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                        
                        card?.acceptTerms
                        {
                            (pending, acceptedCard, error) in
                            XCTAssertNil(error)
                            XCTAssertNotNil(acceptedCard)
                            XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                            acceptedCard?.delete
                            {
                                (error) -> Void in
                                XCTAssertNil(error)
                                expectation.fulfill()
                            }}
                    })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    func testCreditCardDeclineTerms()
    {
        let expectation = super.expectationWithDescription("'creditCard' decline terms")
        
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                        
                        card?.declineTerms
                        {
                            (pending, declinedCard, error) in
                            XCTAssertNil(error)
                            XCTAssertNotNil(declinedCard)
                            XCTAssertEqual(declinedCard?.state, "DECLINED_TERMS_AND_CONDITIONS")
                            declinedCard?.delete
                            {
                                (error) -> Void in
                                XCTAssertNil(error)
                                expectation.fulfill()
                            }
                        }
                        
                    })
            })
            
            
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardSelectVerificationMethod()
    {
        let expectation = super.expectationWithDescription("'selectVerificationType' selects verification method")
        
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                        
                        card?.acceptTerms
                        {
                            (pending, acceptedCard, error) in
                            XCTAssertNil(error)
                            XCTAssertNotNil(acceptedCard)
                            XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                            
                            if let verificationMethods = acceptedCard?.verificationMethods
                            {
                                for verificationMethod in verificationMethods
                                {
                                    
                                    verificationMethod.selectVerificationType
                                    {
                                        (pending, verificationMethod, error) in
                                        XCTAssertNotNil(verificationMethod)
                                        XCTAssertNil(error)
                                        acceptedCard?.delete
                                        {
                                                (error) -> Void in
                                                XCTAssertNil(error)
                                                expectation.fulfill()
                                        }
                                    }
                                    
                                    break
                                }
                            }
                            else
                            {
                                XCTFail("Failed to find verification methods")
                                card?.delete
                                {
                                    (error) -> Void in
                                    XCTAssertNil(error)
                                    expectation.fulfill()
                                }
                            }
                        }
                    })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testCreditCardVerify()
    {
        let expectation = super.expectationWithDescription("'creditCard' verify card with id")
        
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.createCreditCard(pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                        
                        card?.acceptTerms
                        {
                            (pending, acceptedCard, error) in
                            XCTAssertNil(error)
                            XCTAssertNotNil(acceptedCard)
                            XCTAssertEqual(acceptedCard?.state, "PENDING_VERIFICATION")
                            
                            if let verificationMethods = acceptedCard?.verificationMethods
                            {
                                for verificationMethod in verificationMethods
                                {
                                    verificationMethod.selectVerificationType
                                    {
                                        (pending, verificationMethod, error) in
                                        XCTAssertNotNil(verificationMethod)
                                        XCTAssertEqual(verificationMethod?.state, "AWAITING_VERIFICATION")
                                        XCTAssertNil(error)
                                        
                                        verificationMethod?.verify("12345", completion:
                                        {
                                            (pending, verificationMethod, error) -> Void in
                                            XCTAssertNil(error)
                                            XCTAssertNotNil(verificationMethod)
                                            XCTAssertEqual(verificationMethod?.state, "VERIFIED")

                                            
                                            acceptedCard?.delete
                                            {
                                                (error) -> Void in
                                                XCTAssertNil(error)
                                                expectation.fulfill()
                                            }
                                        })
                                    }
                                    
                                    break
                                }
                            }
                            else
                            {
                                XCTFail("Failed to find verification methods")
                                card?.delete
                                    {
                                        (error) -> Void in
                                        XCTAssertNil(error)
                                        expectation.fulfill()
                                }
                            }
                        }
                    })
            })
            
            
            /*
            self.client.createCreditCard(userId: self.session.userId!, pan: "9999411111111114", expMonth: 2, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
            {
                (card, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(card)
                self.client.acceptTerms(creditCardId: card!.creditCardId!, userId: self.session.userId!, completion:
                {
                    (updateLater, card, error) -> Void in
                    XCTAssertNil(error)
                    self.client.selectVerificationType(creditCardId: card!.creditCardId!, userId: self.session.userId!, verificationTypeId: "12345", completion:
                    {
                        (pending, verification, error) -> Void in
                        XCTAssertNil(error)
                        
                        self.client.verify(creditCardId: card!.creditCardId!, userId: self.session.userId!, verificationTypeId: "12345", verificationCode: "12345", completion:
                        {
                            (pending, verification, error) -> Void in
                            XCTAssertNil(error)
                            
                            self.client.creditCard(creditCardId: card!.creditCardId!, userId: self.session.userId!, completion:
                            {
                                (creditCard, error) -> Void in
                                XCTAssertNil(error)
                                XCTAssertEqual(creditCard?.state, "ACTIVE")
                                
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
            })*/
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.listDevices(10, offset: 0, completion:
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
                
                device?.delete(
                {
                    (error) -> Void in
                    XCTAssertNil(error)
                    expectation.fulfill()
                })
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesUser()
    {
        let expectation = super.expectationWithDescription("test 'device' user retrieving ")
        
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
                
                device?.user(
                {
                    (user, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(user)
                    
                    device?.delete(
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
                    device?.delete(
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
                device?.update(firmwareRev, softwareRevision: softwareRev, completion:
                {
                    (updatedDevice, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(updatedDevice)
                    
                    XCTAssertTrue(updatedDevice?.softwareRevision == softwareRev)
                    XCTAssertTrue(updatedDevice?.firmwareRevision == firmwareRev)
                    
                    updatedDevice?.delete(
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
            
            self.client.user(id:self.session.userId!, completion:
            {
                (user, error) -> Void in
                XCTAssertNil(error)
                user?.listDevices(1, offset: 0, completion:
                {
                    (devices, error) -> Void in
                    XCTAssertNil(error)
                    devices!.results![0].listCommits("", limit: 10, offset: 0, completion:
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
        
        self.client.user(id:userId, completion:
        {
            (user, error) -> Void in
            
            if (error != nil) {
                completion(device: nil, error: error)
                return
            }
            
            user?.createNewDevice(deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion:
            {
                (device, error) -> Void in
                completion(device: device, error: error)
            })
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
                    
                    user?.listCreditCards(excludeState:[], limit: 10, offset: 0, completion:
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
                                    
                                    if let termsAssetReferences = card.termsAssetReferences
                                    {
                                        for termsAssetReference in termsAssetReferences
                                        {
                                            termsAssetReference.retrieveAsset
                                            {
                                                (asset, error) -> Void in
                                                
                                                XCTAssertNil(error)
                                                XCTAssertNotNil(asset)
                                                XCTAssertNotNil(asset?.text)
                                                
                                                if let brandLogo = card.cardMetaData?.brandLogo
                                                {
                                                    for brandLogoImage in brandLogo
                                                    {
                                                        brandLogoImage.retrieveAsset
                                                        {
                                                            (asset, error) -> Void in
                                                            XCTAssertNil(error)
                                                            XCTAssertNotNil(asset)
                                                            XCTAssertNotNil(asset?.image)
                                                            
                                                            expectation.fulfill()
                                                        }
                                                    }
                                                }

                                            }
                                            break
                                        }
                                    }
                                    
                                }
                            }
                            
                            XCTAssertNotNil(result?.links)
                            
                            
                    })
            })

            
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testTransactionRetrievesTransactionsByUserId()
    {
        let expectation = super.expectationWithDescription("'transaction' retrieves transactions by user id")
        
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
            
            self.client.creditCards(userId: self.session.userId!, excludeState: [], limit: 10, offset: 0, completion:
            {
                (result, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(result)
                
                for card in result!.results! {
                    self.client.transactions(userId: self.session.userId!, cardId:card.creditCardId!, limit:10, offset:0, completion:
                    {
                        (transactions, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(transactions)
                        XCTAssertNotNil(transactions?.limit)
                        XCTAssertNotNil(transactions?.totalResults)
                        XCTAssertNotNil(transactions?.links)
                        XCTAssertNotNil(transactions?.results)
                        
                        if let transactionsResults = transactions!.results {
                            if transactionsResults.count > 0 {
                                for transactionInfo in transactionsResults {
                                    XCTAssertNotNil(transactionInfo.transactionId)
                                    XCTAssertNotNil(transactionInfo.transactionType)
                                }
                                
                                expectation.fulfill()
                            }
                        }
                    })
                }
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testTransactionRetrievesTransactionById()
    {
        let expectation = super.expectationWithDescription("'transaction' retrieves transaction by id")
        
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
            
            self.client.creditCards(userId: self.session.userId!, excludeState: [], limit: 10, offset: 0, completion:
            {
                (result, error) -> Void in
                
                XCTAssertNil(error)
                XCTAssertNotNil(result)
                
                for card in result!.results! {
                    self.client.transactions(userId: self.session.userId!, cardId:card.creditCardId!, limit:10, offset:0, completion:
                    {
                        (transactions, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(transactions)
                        XCTAssertNotNil(transactions?.limit)
                        XCTAssertNotNil(transactions?.totalResults)
                        XCTAssertNotNil(transactions?.links)
                        XCTAssertNotNil(transactions?.results)
                        
                        if let transactionsResults = transactions!.results {
                            if transactionsResults.count > 0 {
                                for transactionInfo in transactionsResults {
                                    
                                    self.client.transaction(transactionId: transactionInfo.transactionId!, userId: self.session.userId!, cardId:card.creditCardId!, completion:
                                    {
                                        (transaction, error) -> Void in
                                        print(error)
                                        XCTAssertNil(error)
                                        XCTAssertNotNil(transaction?.transactionId)
                                        XCTAssertNotNil(transaction?.transactionType)
                                        
                                        expectation.fulfill()
                                    })
                                    
                                    break
                                }
                            }
                        }
                    })
                }
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testAPDUPackageConfirm()
    {
        let expectation = super.expectationWithDescription("'APDUPackage' confirms package")
        
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
        
            let package = ApduPackage()
            package.packageId = "0828a2a8-2ad6-4ea5-9f3c-188983986f25"
            package.state = "SUCCESSFUL"
            package.executed = "2015-12-15T23:54:20.510Z"
            package.executedDuration = 999

            let resp = ApduResponse()
            resp.commandId = "c3930e8d-0c87-454c-9d5c-bfda6e6e1eb1"
            resp.responseCode = "9000"
            resp.responseData = "011234567899000"
            
            package.apduResponses = [ resp ]
            
            self.client.confirmAPDUPackage(package, completion:
            {
                (error) -> Void in
                
                XCTAssertNil(error)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
}