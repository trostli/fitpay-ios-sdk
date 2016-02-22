
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
        let expectation = super.expectationWithDescription("testAcquireAccessTokenRetrievesToken")
        session.acquireAccessToken(clientId: "e362a5cd-ab9d-4f9a-98ff-f91fcdd27936",
            clientSecret:"s2CLUBKcbvQP6IqKx31XLclyqAd3nf6tyIPk74rL")
            {
                (token, error) -> Void in
                expectation.fulfill()
            }
        super.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
