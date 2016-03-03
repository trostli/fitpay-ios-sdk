
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
        let expectation = super.expectationWithDescription("test 'createEncryptionKey' creates key")
        
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
        let expectation = super.expectationWithDescription("test 'encryptionKey' retrieves key")

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
        let expectation = super.expectationWithDescription("test 'encryptionKey' fails to retrieve key with fale id")
        
        self.client.encryptionKey("some_fake_id", completion:
        {
                (retrievedEncryptionKey, retrievedError) -> Void in
                
                XCTAssertNotNil(retrievedError)
                print(retrievedError)
                expectation.fulfill()
        })
        
        super.waitForExpectationsWithTimeout(100, handler: nil)
    }

    func testDeleteEncryptionKeyDeletesCreatedKey()
    {
        let expectation = super.expectationWithDescription("test 'deleteEncryptionKey' deletes key")

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
        let expectation = super.expectationWithDescription("test 'user' retrieves user by her id")
        
        self.session.login(username: self.username, password: self.password)
        {
            [unowned self](error) -> Void in
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
                XCTAssertNotNil(user?.info?.firstName)
                XCTAssertNotNil(user?.info?.lastName)
                XCTAssertNotNil(user?.info?.email)
                XCTAssertNil(error)
                
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
            XCTAssertNil(error)
            XCTAssertTrue(self.session.isAuthorized)
            
            if !self.session.isAuthorized
            {
                expectation.fulfill()
                return
            }
            
            self.client.devices(userId: self.session.userId!, limit: 1, offset: 3, completion:
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
    
    func createDefaultDevice(userId: String, completion:RestClient.CreateNewDeviceHandler)
    {
        let deviceType = "SMART_STRAP"
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
}
