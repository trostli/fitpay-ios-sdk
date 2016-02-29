
import XCTest

@testable import FitpaySDK

class RestSessionTests: XCTestCase
{
    var session:RestSession!
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "pagareuser@fit-pay.com"
    let password = "pagaresecret"
    
    override func setUp()
    {
        super.setUp()
        self.session = RestSession(clientId: self.clientId, redirectUri: self.redirectUri)
    }
    
    override func tearDown()
    {
        self.session = nil
        super.tearDown()
    }
    
    
    func testAcquireAccessTokenRetrievesToken()
    {
        let expectation = super.expectationWithDescription("Test acquireAccessToken retrieves auth details")

        self.session.acquireAccessToken(clientId:self.clientId, redirectUri:self.redirectUri,
                username:self.username, password:self.password, completion:
        {
            authDetails, error in

            XCTAssertNotNil(authDetails)
            XCTAssertNil(error)
            XCTAssertNotNil(authDetails?.accessToken)
            XCTAssertNotNil(authDetails?.expiresIn)
            XCTAssertNotNil(authDetails?.jti)
            XCTAssertNotNil(authDetails?.scope)

            expectation.fulfill()
        });

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testLoginRetrievesUserId()
    {
        let expectation = super.expectationWithDescription("Test login retrieves access token")
        
        self.session.login(username: self.username, password: self.password)
        {
            [unowned self]
            (error) -> Void in

            XCTAssertNil(error)
            XCTAssertNotNil(self.session.userId)
            
            expectation.fulfill()
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
