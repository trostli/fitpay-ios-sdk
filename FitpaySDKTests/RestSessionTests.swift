
import XCTest

@testable import FitpaySDK

class RestSessionTests: XCTestCase
{
    var session:RestSession!
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"
    let username = "testableuser@something.com"
    let password = "1029"
    
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
        let expectation = super.expectationWithDescription("'acquireAccessToken' retrieves auth details")

        self.session.acquireAccessToken(clientId:self.clientId, redirectUri:self.redirectUri,
                username:self.username, password:self.password, completion:
        {
            authDetails, error in

            XCTAssertNotNil(authDetails)
            XCTAssertNil(error)
            XCTAssertNotNil(authDetails?.accessToken)
           
            expectation.fulfill()
        });

        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testLoginRetrievesUserId()
    {
        let expectation = super.expectationWithDescription("'login' retrieves user id")
        
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
    
    func testLoginFailsForWrongCredentials()
    {
        let expectation = super.expectationWithDescription("'login' fails for wrond credentials")
        
        self.session.login(username: "totally@wrong.abc", password:"this is wrong")
            {
                [unowned self]
                (error) -> Void in
                
                XCTAssertNotNil(error)
                XCTAssertNil(self.session.userId)
                
                expectation.fulfill()
        }
        
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
