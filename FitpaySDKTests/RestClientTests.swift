
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"

    var session:RestSession?
    var client:RestClient?

    override func setUp()
    {
        super.setUp()
        self.client = RestClient(self.session = RestSession(clientId:self.clientId, redirectUri:self.redirectUri))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
