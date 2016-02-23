
import XCTest
@testable import FitpaySDK

class RestSessionTests: XCTestCase
{
    var session:RestSession!
    
    override func setUp()
    {
        super.setUp()
        self.session = RestSession()
    }
    
    override func tearDown()
    {
        self.session = nil
        super.tearDown()
    }
    
    func testAcquireAccessTokenRetrievesToken()
    {
        let expectation = super.expectationWithDescription("Test acquireAccessToken retrieves auth details")

        self.session.acquireAccessToken(clientId:"pagare", redirectUri:"http://demo.pagare.me",
                username:"pagareuser@fit-pay.com", password:"pagaresecret", completion:
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
}
