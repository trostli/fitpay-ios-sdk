
import XCTest

@testable import FitpaySDK

class RestSessionTests: XCTestCase {

    var session:RestSession!
    var client:RestClient!
    var testHelper:TestHelpers!
    var clientId = "fp_webapp_pJkVp2Rl"
    let redirectUri = "https://webapp.fit-pay.com"
    let password = "1029"
    
    override func setUp() {
        super.setUp()
        let config = FitpaySDKConfiguration(clientId:clientId, redirectUri:redirectUri, baseAuthURL: AUTHORIZE_BASE_URL, baseAPIURL: API_BASE_URL)
        if let error = config.loadEnvironmentVariables() {
            print("Can't load config from environment. Error: \(error)")
        } else {
            clientId = config.clientId
        }
        
        self.session = RestSession(configuration: config)
        self.client = RestClient(session: self.session!)
        self.testHelper = TestHelpers(clientId: clientId, redirectUri: redirectUri, session: self.session, client: self.client)
    }
    
    override func tearDown() {
        self.session = nil
        super.tearDown()
    }
    
    
    func testAcquireAccessTokenRetrievesToken() {
        let email = self.testHelper.randomEmail()
        let expectation = super.expectation(description: "'acquireAccessToken' retrieves auth details")

        self.client.createUser(
            email, password: self.password, firstName: nil, lastName: nil, birthDate: nil, termsVersion: nil,
            termsAccepted: nil, origin: nil, originAccountCreated: nil, clientId: clientId, completion:
        {
            (user, error) in

            XCTAssertNil(error)

            self.session.acquireAccessToken(
                clientId: self.clientId, redirectUri: self.redirectUri, username: email, password: self.password, completion:
            {
                authDetails, error in

                XCTAssertNotNil(authDetails)
                XCTAssertNil(error)
                XCTAssertNotNil(authDetails?.accessToken)

                expectation.fulfill()
            });
        })

        super.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoginRetrievesUserId() {
        let email = self.testHelper.randomEmail()
        let expectation = super.expectation(description: "'login' retrieves user id")

        self.client.createUser(
            email, password: self.password, firstName: nil, lastName: nil, birthDate: nil, termsVersion: nil,
            termsAccepted: nil, origin: nil, originAccountCreated: nil, clientId: clientId, completion:
        {
            (user, error) in

            self.session.login(username: email, password: self.password) {
                [unowned self]
                (error) -> Void in

                XCTAssertNil(error)
                XCTAssertNotNil(self.session.userId)

                expectation.fulfill()
            }
        })

        super.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoginFailsForWrongCredentials() {
        let expectation = super.expectation(description: "'login' fails for wrong credentials")
        
        self.session.login(username: "totally@wrong.abc", password:"fail") {
                [unowned self]
                (error) -> Void in
                
                XCTAssertNotNil(error)
                XCTAssertNil(self.session.userId)
                
                expectation.fulfill()
        }
        
        super.waitForExpectations(timeout: 10, handler: nil)
    }
}
