import XCTest
@testable import FitpaySDK
@testable import RTMClientApp

class RtmSessionTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "testableuser2@something.com"
    let password = "1029"
    
    var session:RtmSession!
    var restSession:RestSession!
    var restClient:RestClient!
    var deviceToDelete:DeviceInfo?
    
    override func setUp()
    {
        super.setUp()
        
        self.session = RtmSession(authorizationURL: NSURL(string: RTM_AUTHORIZATION_URL)!)
        self.restSession = RestSession(clientId:self.clientId, redirectUri:self.redirectUri)
        self.restClient = RestClient(session: self.restSession!)
    }
    
    override func tearDown()
    {
        self.restClient = nil
        self.session = nil
        self.restSession = nil
        
        if let deviceToDelete = self.deviceToDelete {
            deviceToDelete.deleteDeviceInfo(
            { (_) -> Void in
                
            })
        }
        
        super.tearDown()
    }
    
    func connect()
    {
        self.restSession.login(username: self.username, password: self.password)
        {
            [unowned self](error) -> Void in
            XCTAssertNil(error)
            XCTAssertTrue(self.restSession.isAuthorized)
            
            if !self.restSession.isAuthorized
            {
                return
            }
            
            self.restClient.user(id: self.restSession.userId!, completion:
            {
                (user, error) -> Void in
            
                user?.listDevices(limit: 20, offset: 0, completion:
                {
                    (devices, error) -> Void in
                    var secureElementFound = false
                    for deviceInfo in devices!.results! {
                        if (deviceInfo.secureElementId != nil) {
                            secureElementFound = true
                            self.session?.connectAndWaitForParticipants(deviceInfo)
                            break
                        }
                    }
                    
                    if !secureElementFound {
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
                            XCTAssertNil(error)
                            XCTAssertNotNil(device)
                            
                            self.deviceToDelete = device
                            if device?.secureElementId != nil {
                                self.session?.connectAndWaitForParticipants(device!)
                            } else {
                                XCTAssert(secureElementFound)
                            }
                        })
                    }
                })
            })
        }
    }
    
    func testRtmConnectionCheck()
    {
        let expectation = super.expectationWithDescription("connection check")
        self.session.onConnect =
        {
            (url, error) -> Void in
            
            XCTAssertNil(error)
            XCTAssertNotNil(url)
            
            expectation.fulfill()
        }
        
        self.connect()
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUserLogin()
    {
        let expectation = super.expectationWithDescription("connection check")
        self.session.onConnect =
        {
            (url, error) -> Void in
            
            XCTAssertNil(error)
            XCTAssertNotNil(url)
            
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate, let window = delegate.window {
                let webview = UIWebView(frame: UIScreen.mainScreen().bounds)
                window.addSubview(webview)
                webview.loadRequest(NSURLRequest(URL: url!))
            }
        }
        
        self.session.onUserLogin =
        {
            (sessionData) -> Void in
            
            XCTAssertNotNil(sessionData)
            XCTAssertNotNil(sessionData.userId)
            XCTAssertNotNil(sessionData.deviceId)
            XCTAssertNotNil(sessionData.token)
            
            expectation.fulfill()
        }
        
        self.connect()
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
}