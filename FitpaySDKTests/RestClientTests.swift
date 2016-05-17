
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "testableuser2@something.com"
    let password = "1029"

    var session:RestSession!
    var client:RestClient!
    
    override func invokeTest()
    {
        // stop test on first failure - kind of like jUnit.  Avoid unexpected null references etc
        self.continueAfterFailure = false;
        
        super.invokeTest();
        
        // keep running tests in suite
        self.continueAfterFailure = true;

    }

    override func setUp()
    {
        super.setUp()
        self.session = RestSession(clientId:self.clientId, redirectUri:self.redirectUri, authorizeURL: AUTHORIZE_URL, baseAPIURL: API_BASE_URL)
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
            
            XCTAssertNil(createdError)
            XCTAssertNotNil(createdEncryptionKey)
            
            if createdError != nil
            {
                expectation.fulfill()
                return
            }
            
            self.client.encryptionKey(createdEncryptionKey!.keyId!, completion:
            {
                (retrievedEncryptionKey, retrievedError) -> Void in
                
                XCTAssertNil(retrievedError)
                if retrievedError != nil
                {
                    expectation.fulfill()
                    return
                }
                
                self.client.deleteEncryptionKey((retrievedEncryptionKey?.keyId)!, completion:
                {
                    (error) -> Void in
                    
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
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
 
    func testUserCreate()
    {
        let expectation = super.expectationWithDescription("'user' created")
        
        let email = randomStringWithLength(8)
            .stringByAppendingString("@")
            .stringByAppendingString(randomStringWithLength(5))
            .stringByAppendingString(".")
            .stringByAppendingString(randomStringWithLength(5))
        let pin = "1234"
        
        self.client.createUser(email, password: pin, firstName:nil, lastName:nil,
                               birthDate:nil,
                               termsVersion:nil, termsAccepted:nil,
                               origin:nil, originAccountCreated:nil,
                               completion:
                {
                    (user, error) -> Void in
                    
                    XCTAssertNotNil(user, "user is nil")
                    XCTAssertNotNil(user?.info)
                    XCTAssertNotNil(user?.created)
                    XCTAssertNotNil(user?.links)
                    XCTAssertNotNil(user?.createdEpoch)
                    XCTAssertNotNil(user?.encryptedData)
                    XCTAssertNotNil(user?.info?.email)
                    XCTAssertNil(error)
                    expectation.fulfill()
                })
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    func testUserCreateAndLogin()
    {
        let expectation = super.expectationWithDescription("'user' created")
        
        self.createAndLoginUser(expectation)
        {
           [unowned self] user in
            self.deleteUser(user, expectation: expectation)
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserDeleteUserDeletesUser()
    {
        let expectation = super.expectationWithDescription("'user.deleteUser' deletes user")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self] user in
            self.deleteUser(user, expectation: expectation)
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserUpdateUserGetsError400()
    {
        let expectation = super.expectationWithDescription("'user.updateUser' gets error 400")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self] (user) in
            
            let firstName = self.randomStringWithLength(10)
            let lastNname = self.randomStringWithLength(10)
            
            user?.updateUser(firstName: firstName, lastName: lastNname, birthDate: nil, originAccountCreated: nil, termsAccepted: nil, termsVersion: nil)
            {
                updateUser, updateError in
                XCTAssertNil(updateUser)
                //XCTAssertEqual(updateUser?.firstName, firstName)
                //XCTAssertEqual(updateUser?.lastName, lastNname)
                
                XCTAssertEqual(updateError?.code, 400)
                self.deleteUser(user, expectation: expectation)
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testUserRetrievesUserById()
    {
        let expectation = super.expectationWithDescription("'user' retrieves user by her id")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            self.client.user(id: (user?.id)!, completion:
            {
                (user, error) -> Void in
                self.deleteUser(user, expectation: expectation)
            })
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreateCreditCardCreatesCreditCardsForUser()
    {
        let expectation = super.expectationWithDescription("'creditCards' retrieves credit cards for user")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    self.deleteUser(user, expectation: expectation)
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserListCreditCardsListsCreditCardsForUser()
    {
        let expectation = super.expectationWithDescription("'listCreditCards' lists credit cards for user")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    self.listCreditCards(expectation, user: user)
                    {
                        (user, result) in
                        
                        XCTAssertEqual(creditCard?.creditCardId, result?.results?.first?.creditCardId)
                        
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardDeleteDeletesCreditCardAfterCreatingIt()
    {
        let expectation = super.expectationWithDescription("'delete' deletes credit card after creating it")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    creditCard?.deleteCreditCard
                    {
                        (deleteCardError) in
                        XCTAssertNil(deleteCardError)
                        
                        if deleteCardError != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }
        
       
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUpdateUpdatesCreditCard()
    {
        let expectation = super.expectationWithDescription("'update' updates credit card")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    let name:String? = "User\(NSDate().timeIntervalSince1970)"
                    let street1:String? = "Street1\(NSDate().timeIntervalSince1970)"
                    let street2:String? = "Street2\(NSDate().timeIntervalSince1970)"
                    let city:String? = "Beverly Hills"
                    
                    let state = "MO"
                    let postCode:String? = "90210"
                    
                    // TODO: Ask why this causes error 400 is passed
                    let countryCode:String? = nil//"USA"
                    
                    creditCard?.update(name:name, street1: street1, street2: street2, city: city, state: state, postalCode: postCode, countryCode: countryCode, completion:
                    {
                        (updatedCard, error) -> Void in
                        
                        XCTAssertNil(error)
                        XCTAssertNotNil(updatedCard)
                        
                        self.listCreditCards(expectation, user: user)
                        {
                            (user, result) in
                            let currentCard = result?.results?.first
                            
                            if currentCard?.creditCardId == updatedCard?.creditCardId
                            {
                                XCTAssertEqual(updatedCard?.info?.name, name)
                                XCTAssertEqual(updatedCard?.info?.name, currentCard?.info?.name)
                                
                                XCTAssertEqual(updatedCard?.info?.address?.street1, street1)
                                XCTAssertEqual(updatedCard?.info?.address?.street1, currentCard?.info?.address?.street1)
                                
                                XCTAssertEqual(updatedCard?.info?.address?.street2, street2)
                                XCTAssertEqual(updatedCard?.info?.address?.street2, currentCard?.info?.address?.street2)
                                
                                XCTAssertEqual(updatedCard?.info?.address?.city, city)
                                XCTAssertEqual(updatedCard?.info?.address?.city, currentCard?.info?.address?.city)
                                
                                XCTAssertEqual(updatedCard?.info?.address?.state, state)
                                XCTAssertEqual(updatedCard?.info?.address?.state, currentCard?.info?.address?.state)
                                
                                XCTAssertEqual(updatedCard?.info?.address?.postalCode, postCode)
                                XCTAssertEqual(updatedCard?.info?.address?.postalCode, currentCard?.info?.address?.postalCode)
                                
                                //XCTAssertEqual(updatedCard?.info?.address?.countryCode, countryCode)
                                //XCTAssertEqual(updatedCard?.info?.address?.countryCode, currentCard.info?.address?.countryCode)
                                
                                self.deleteUser(user, expectation: expectation)
                            }

                        }
                    })
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testMakeDefaultMakesCreditCardDefault()
    {
        let expectation = super.expectationWithDescription("'makeDefault' makes credit card default")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.selectVerificationType(expectation, card: card)
                        {
                            (verificationMethod) in
                            
                            self.verifyCreditCard(expectation, verificationMethod: verificationMethod)
                            {
                                card in
                                XCTAssertTrue(card!.isDefault!)

                                self.createAcceptVerifyAmExCreditCard(expectation, pan: "9999611111111114", user: user)
                                {
                                    (creditCard) in
                                    
                                    self.makeCreditCardDefault(expectation, card: creditCard)
                                    {
                                        (defaultCreditCard) in
                                        self.deleteUser(user, expectation: expectation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeactivateCreditCard()
    {
        let expectation = super.expectationWithDescription("'deactivate' makes credit card deactivated")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.selectVerificationType(expectation, card: card)
                        {
                            (verificationMethod) in
                            
                            self.verifyCreditCard(expectation, verificationMethod: verificationMethod)
                            {
                                (verifiedCreditCard) in
                                
                                self.deactivateCreditCard(expectation, creditCard: verifiedCreditCard)
                                {
                                    (deactivatedCard) in
                                 
                                    self.deleteUser(user, expectation: expectation)
                                }
                            }
                        }
                    }
                }
            }
        }

        
        /*
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
                    user?.createCreditCard(pan: "9999411111111114", expMonth: 12, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA", completion:
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
                                XCTAssertEqual(acceptedCard?.state, .PENDING_VERIFICATION)
                                
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
                                                            XCTAssertEqual(deactivatedCreditCard?.state, .DEACTIVATED)
                                                            deactivatedCreditCard?.deleteCreditCard
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
                                    card?.deleteCreditCard
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
        */
        
        
        
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testReactivateCreditCardActivatesCard()
    {
        let expectation = super.expectationWithDescription("'reactivate' makes credit card activated")
        
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.selectVerificationType(expectation, card: card)
                        {
                            (verificationMethod) in
                            
                            self.verifyCreditCard(expectation, verificationMethod: verificationMethod)
                            {
                                (verifiedCreditCard) in
                                
                                self.deactivateCreditCard(expectation, creditCard: verifiedCreditCard)
                                {
                                    (deactivatedCard) in
                                    
                                    deactivatedCard?.reactivate(causedBy: .CARDHOLDER, reason: "found card")
                                    {
                                        (pending, creditCard, error) in
                                        XCTAssertNil(error)
                                        if error != nil
                                        {
                                            expectation.fulfill()
                                            return
                                        }
                                        
                                        XCTAssertEqual(creditCard?.state, .ACTIVE)
                                        
                                        self.deleteUser(user, expectation: expectation)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
        }

        
        super.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testCreditCardAcceptTerms()
    {
        let expectation = super.expectationWithDescription("'creditCard' accept terms")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    
    func testCreditCardDeclineTerms()
    {
        let expectation = super.expectationWithDescription("'creditCard' decline terms")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    creditCard?.declineTerms
                    {
                        (pending, card, error) in
                        XCTAssertNil(error)
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        XCTAssertEqual(card?.state, .DECLINED_TERMS_AND_CONDITIONS)
                        
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testCreditCardSelectVerificationMethod()
    {
        let expectation = super.expectationWithDescription("'selectVerificationType' selects verification method")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.selectVerificationType(expectation, card: card)
                        {
                            (verificationMethod) in
                            self.deleteUser(user, expectation: expectation)
                        }
                    }
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testCreditCardVerify()
    {
        let expectation = super.expectationWithDescription("'creditCard' verify card with id")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    self.acceptTermsForCreditCard(expectation, card: creditCard)
                    {
                        (card) in
                        self.selectVerificationType(expectation, card: card)
                        {
                            (verificationMethod) in
                            
                            self.verifyCreditCard(expectation, verificationMethod: verificationMethod)
                            {
                                (verificationMethod) in
                                self.deleteUser(user, expectation: expectation)
                            }
                        }
                    }
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserListDevisesListsDevices()
    {
        let expectation = super.expectationWithDescription("test 'device' retrieves devices by user id")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                user?.listDevices(limit: 10, offset: 0)
                {
                    (result, error) in
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    XCTAssertNotNil(result)
                    XCTAssertEqual(result?.results?.count, 1)
                    
                    for deviceInfo in result!.results!
                    {
                        XCTAssertNotNil(deviceInfo.deviceIdentifier)
                        XCTAssertNotNil(deviceInfo.metadata)
                    }
                    
                    self.deleteUser(user, expectation: expectation)
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserCreateNewDeviceCreatesDevice()
    {
        let expectation = super.expectationWithDescription("test 'user.createDevice' creates device")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.deleteUser(user, expectation: expectation)
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceDeleteDeviceDeletesDevice()
    {
        let expectation = super.expectationWithDescription("test 'device.deleteDevice' deletes device")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                user?.listDevices(limit: 10, offset: 0)
                {
                    (result, error) in
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    XCTAssertNotNil(result)
                    XCTAssertEqual(result?.results?.count, 1)
                    
                    let deviceInfo = result!.results!.first!
                    
                    XCTAssertNotNil(deviceInfo.deviceIdentifier)
                    XCTAssertNotNil(deviceInfo.metadata)
                    
                    deviceInfo.deleteDeviceInfo
                    {
                        (error) in
                        XCTAssertNil(error)
                        
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        user?.listDevices(limit: 10, offset: 0)
                        {
                            (result, error) in
                            XCTAssertNil(error)
                            
                            if error != nil
                            {
                                expectation.fulfill()
                                return
                            }
                            
                            XCTAssertEqual(result?.totalResults, 0)
                            self.deleteUser(user, expectation: expectation)
                        }
                    }
                }
            }
        }

        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceUserRetrievesUser()
    {
        let expectation = super.expectationWithDescription("test 'device.user' retrieves user ")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                
                device?.user
                {
                    (retrievedUser, error) in
                    
                    XCTAssertNotNil(user)
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    self.deleteUser(retrievedUser, expectation: expectation)
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceUpdateUpdatesDevice()
    {
        let expectation = super.expectationWithDescription("test 'device' update device")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                
                let firmwareRev = "2.7.7.7"
                let softwareRev = "6.8.1"
                device?.update(firmwareRev, softwareRevision: softwareRev, completion:
                {
                    (updatedDevice, error) -> Void in
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    XCTAssertNotNil(updatedDevice)
                    XCTAssertEqual(updatedDevice!.softwareRevision!, softwareRev)
                    XCTAssertEqual(updatedDevice!.firmwareRevision!, firmwareRev)
                        
                    self.deleteUser(user, expectation: expectation)
                })
            }
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDeviceRetrievesCommitsFromDevice()
    {
        let expectation = super.expectationWithDescription("test 'device' retrieving commits from device")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                
                user?.listDevices(limit: 10, offset: 0)
                {
                    (result, error) in
                    
                    XCTAssertNil(error)
                    
                    if error != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    result?.results?.first?.listCommits(commitsAfter: nil, limit: 10, offset: 0)
                    {
                        (commits, error) in
                        
                        XCTAssertNil(error)
                        
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        XCTAssertNotNil(commits)
                        XCTAssertNotNil(commits?.limit)
                        XCTAssertNotNil(commits?.totalResults)
                        XCTAssertNotNil(commits?.links)
                        XCTAssertNotNil(commits?.results)
                        
                        for commit in commits!.results!
                        {
                            XCTAssertNotNil(commit.commitType)
                            XCTAssertNotNil(commit.payload)
                            XCTAssertNotNil(commit.commit)
                        }
                        
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testRelationshipsCreatesAndDeletesRelationship()
    {
        let expectation = super.expectationWithDescription("test 'relationships' creates and deletes relationship")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    user?.createRelationship(creditCardId: creditCard!.creditCardId!, deviceId: device!.deviceIdentifier!)
                    {
                        (relationship, error) -> Void in
                        XCTAssertNil(error)
                        
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        XCTAssertNotNil(device)
                        XCTAssertNotNil(relationship?.device)
                        XCTAssertNotNil(relationship?.card)
                        
                        relationship?.deleteRelationship
                        {
                            (error) in
                            
                            XCTAssertNil(error)
                            
                            if error != nil
                            {
                                expectation.fulfill()
                                return
                            }
                            
                            device?.deleteDeviceInfo
                            {
                                (error) -> Void in
                                
                                XCTAssertNil(error)
                                
                                if error != nil
                                {
                                    expectation.fulfill()
                                    return
                                }
                                
                                self.deleteUser(user, expectation: expectation)
                            }
                        }
                    }
                }
            }
        }
        
        super.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testAssetsRetrievesAsset()
    {
        let expectation = super.expectationWithDescription("'assets' retrievs asset")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    creditCard?.cardMetaData?.brandLogo?.first?.retrieveAsset
                    {
                        (asset, error) in
                        
                        XCTAssertNil(error)
                        
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        self.deleteUser(user, expectation: expectation)
                    }
                }
            }
        }

        super.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testTransactionRetrievesTransactionsByUserId()
    {
        let expectation = super.expectationWithDescription("'transaction' retrieves transactions by user id")
        
        self.createAndLoginUser(expectation)
        {
            [unowned self](user) in
            
            self.createDevice(expectation, user: user)
            {
                (user, device) in
                self.createCreditCard(expectation, user: user)
                {
                    (user, creditCard) in
                    
                    creditCard?.listTransactions(limit: 1, offset:0)
                    {
                        
                        (transactions, error) -> Void in
                        
                        XCTAssertNil(error)
                        
                        if error != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        XCTAssertNotNil(transactions)
                        XCTAssertNotNil(transactions?.limit)
                        XCTAssertNotNil(transactions?.totalResults)
                        XCTAssertNotNil(transactions?.links)
                        XCTAssertNotNil(transactions?.results)
                        
                        if let transactionsResults = transactions!.results
                        {
                            if transactionsResults.count > 0
                            {
                                for transactionInfo in transactionsResults
                                {
                                    XCTAssertNotNil(transactionInfo.transactionId)
                                    XCTAssertNotNil(transactionInfo.transactionType)
                                }
                            }
                            
                            self.deleteUser(user, expectation: expectation)
                        }
                    }
                }
            }
        }

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
//    func testAPDUPackageConfirm()
//    {
//        let expectation = super.expectationWithDescription("'APDUPackage' confirms package")
//        
//        self.session.login(username: self.username, password: self.password)
//        {
//            [unowned self](error) -> Void in
//            XCTAssertNil(error)
//            XCTAssertTrue(self.session.isAuthorized)
//            
//            if !self.session.isAuthorized
//            {
//                expectation.fulfill()
//                return
//            }
//        
//            let package = ApduPackage()
//            package.packageId = "0828a2a8-2ad6-4ea5-9f3c-188983986f25"
//            package.state = "SUCCESSFUL"
//            package.executed = "2015-12-15T23:54:20.510Z"
//            package.executedDuration = 999
//
//            let resp = APDUCommand()
//            resp.commandId = "c3930e8d-0c87-454c-9d5c-bfda6e6e1eb1"
//            resp.responseCode = "9000"
//            resp.responseData = "011234567899000"
//            
//            package.apduCommands = [ resp ]
//            
//            self.client.confirmAPDUPackage(package, completion:
//            {
//                (error) -> Void in
//                
//                XCTAssertNil(error)
//                
//                expectation.fulfill()
//            })
//        }
//        
//        super.waitForExpectationsWithTimeout(10, handler: nil)
//    }
    
    // Helpers
    
    func createAndLoginUser(expectation:XCTestExpectation, completion:(User?)->Void)
    {
        let email = randomStringWithLength(8)
            .stringByAppendingString("@")
            .stringByAppendingString(randomStringWithLength(5))
            .stringByAppendingString(".")
            .stringByAppendingString(randomStringWithLength(5))
        let pin = "1234"
        
        self.client.createUser(email, password: pin, firstName:nil, lastName:nil,
                               birthDate:nil,
                               termsVersion:nil, termsAccepted:nil,
                               origin:nil, originAccountCreated:nil,
                               completion:
            {
                [unowned self](user, error) -> Void in
                
                XCTAssertNil(error)
                
                if error != nil
                {
                    expectation.fulfill()
                    return
                }
                
                XCTAssertNotNil(user, "user is nil")
                debugPrint("created user: \(user?.info?.email)")
                XCTAssertNotNil(user?.info)
                XCTAssertNotNil(user?.created)
                XCTAssertNotNil(user?.links)
                XCTAssertNotNil(user?.createdEpoch)
                XCTAssertNotNil(user?.encryptedData)
                XCTAssertNotNil(user?.info?.email)
                
                self.session.login(username: email, password: pin, completion:
                {
                    (loginError) -> Void in
                    XCTAssertNil(loginError)
                    debugPrint("user isAuthorized: \(self.session.isAuthorized)")
                    XCTAssertTrue(self.session.isAuthorized, "user should be authorized")
                    
                    if loginError != nil
                    {
                        expectation.fulfill()
                        return
                    }
                    
                    self.client.user(id: self.session.userId!)
                    {
                        (user, userError) in
                        
                        XCTAssertNotNil(user)
                        XCTAssertNotNil(user?.info)
                        XCTAssertNotNil(user?.created)
                        XCTAssertNotNil(user?.links)
                        XCTAssertNotNil(user?.createdEpoch)
                        XCTAssertNotNil(user?.encryptedData)
                        XCTAssertNotNil(user?.info?.email)
                        XCTAssertNil(userError)
                        
                        if userError != nil
                        {
                            expectation.fulfill()
                            return
                        }
                        
                        completion(user)
                    }
                    
                })
        })
    }
    
    func deleteUser(user:User?, expectation:XCTestExpectation)
    {
        user?.deleteUser
        {
            (error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
    }
    
    func createDevice(expectation:XCTestExpectation, user:User?, completion:(user:User?, device:DeviceInfo?) -> Void)
    {
        let deviceType = "WATCH"
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
        
        user?.createNewDevice(deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion:
            {
                (device, error) -> Void in
                XCTAssertNotNil(user)
                XCTAssertNil(error)
                if error != nil
                {
                    expectation.fulfill()
                    return
                }
                completion(user:user, device: device)
        })
    }
    
    func assetCreditCard(card:CreditCard?)
    {
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
    }
    
    func createCreditCard(expectation:XCTestExpectation, user:User?, completion:(user:User?, creditCard:CreditCard?) -> Void)
    {
        user?.createCreditCard(pan: "9999411111111116", expMonth: 12, expYear: 2016, cvv: "434", name: "Jon Doe", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "Kansas City", state: "MO", postalCode: "66002", country: "USA")
        {
            [unowned self](card, error) -> Void in
            
            self.assetCreditCard(card)
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            completion(user: user, creditCard: card)
        }
    }
    
    func listCreditCards(expectation:XCTestExpectation, user:User?, completion:(user:User?, result:ResultCollection<CreditCard>?) -> Void)
    {
        user?.listCreditCards(excludeState:[], limit: 10, offset: 0)
        {
            [unowned self](result, error) -> Void in
            
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            XCTAssertNotNil(result)
            XCTAssertNotNil(result?.limit)
            XCTAssertNotNil(result?.offset)
            XCTAssertNotNil(result?.totalResults)
            XCTAssertNotNil(result?.results)
            XCTAssertNotEqual(result?.results?.count, 0)
            XCTAssertNotNil(result?.links)
            
            if let results = result?.results
            {
                for card in results
                {
                    self.assetCreditCard(card)
                }
            }
            
            completion(user: user, result: result)
        }
    }
    
    func createDefaultDevice(userId: String, completion:RestClient.CreateNewDeviceHandler)
    {
        let deviceType = "WATCH"
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
    
    func acceptTermsForCreditCard(expectation:XCTestExpectation, card:CreditCard?, completion:(card:CreditCard?) -> Void)
    {
        card?.acceptTerms
        {
            (pending, acceptedCard, error) in
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            XCTAssertNotNil(acceptedCard)
            XCTAssertEqual(acceptedCard?.state, .PENDING_VERIFICATION)
            completion(card: acceptedCard)
        }
    }
    
    func selectVerificationType(expectation:XCTestExpectation, card:CreditCard?, completion:(verificationMethod:VerificationMethod?) -> Void)
    {
        let verificationMethod = card?.verificationMethods?.first
        verificationMethod?.selectVerificationType
        {
            (pending, verificationMethod, error) in
            XCTAssertNotNil(verificationMethod)
            XCTAssertEqual(verificationMethod?.state, .AWAITING_VERIFICATION)
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            completion(verificationMethod: verificationMethod)
        }
    }
    
    func verifyCreditCard(expectation:XCTestExpectation, verificationMethod:VerificationMethod?, completion:(card:CreditCard?) -> Void)
    {
        verificationMethod?.verify("12345")
        {
            (pending, verificationMethod, error) -> Void in
            
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            XCTAssertNotNil(verificationMethod)
            XCTAssertEqual(verificationMethod?.state, .VERIFIED)
            
            verificationMethod?.retrieveCreditCard
            {
                (creditCard, error) in
                completion(card: creditCard)

            }
            
        }
    }
    
    func makeCreditCardDefault(expectation:XCTestExpectation, card:CreditCard?, completion:(defaultCreditCard:CreditCard?) -> Void)
    {
        card?.makeDefault
        {
            (pending, defaultCreditCard, error) -> Void in
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            XCTAssertNotNil(defaultCreditCard)
            XCTAssertTrue(defaultCreditCard!.isDefault!)
            completion(defaultCreditCard: defaultCreditCard)
        }
    }
    
    func createAcceptVerifyAmExCreditCard(expectation:XCTestExpectation, pan:String, user:User?, completion:(creditCard:CreditCard?) -> Void)
    {
        user?.createCreditCard(pan: pan, expMonth: 5, expYear: 2020, cvv: "434", name: "John Smith", street1: "Street 1", street2: "Street 2", street3: "Street 3", city: "New York", state: "NY", postalCode: "80302", country: "USA")
        {
            [unowned self](creditCard, error) in
            
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            self.assetCreditCard(creditCard)
            
            self.acceptTermsForCreditCard(expectation, card: creditCard)
            {
                (card) in
                self.selectVerificationType(expectation, card: card)
                {
                    (verificationMethod) in
                    self.verifyCreditCard(expectation, verificationMethod: verificationMethod)
                    {
                        (card) in
                        completion(creditCard: card)
                    }
                }
            }
        }
    }
    
    func deactivateCreditCard(expectation:XCTestExpectation, creditCard:CreditCard?, completion:(deactivatedCard:CreditCard?) -> Void)
    {
        creditCard?.deactivate(causedBy: .CARDHOLDER, reason: "lost card")
        {
            (pending, creditCard, error) in
            
            XCTAssertNil(error)
            
            if error != nil
            {
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(creditCard?.state, TokenizationState.DEACTIVATED)
            completion(deactivatedCard: creditCard)
        }
    }
    
    func randomStringWithLength (len : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ... (len-1) {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString as String
    }
    
    func randomNumbers (len:Int = 16) -> String {
        
        let letters : NSString = "0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ... (len-1) {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString as String
    }
    
    func randomPan() -> String
    {
        return "999941111111" + randomNumbers(4)
    }
}