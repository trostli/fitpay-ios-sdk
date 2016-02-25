
import XCTest
@testable import FitpaySDK

class RestClientTests: XCTestCase
{
    let clientId = "pagare"
    let redirectUri = "http://demo.pagare.me"

    var session:RestSession!
    var client:RestClient!
    var crypto:Crypto!

    override func setUp()
    {
        super.setUp()
        self.session = RestSession(clientId:self.clientId, redirectUri:self.redirectUri)
        self.client = RestClient(session: self.session!)
        self.crypto = Crypto()
    }
    
    override func tearDown()
    {
        self.client = nil
        self.session = nil
        self.client = nil
        super.tearDown()
    }
    
    
    func testCreateEncryptionKeyCreatesKey()
    {
        let expectation = super.expectationWithDescription("test createEncryptionKey creates key")
        
        self.client.createEncryptionKey(clientPublicKey:self.crypto.publicKey, completion: { (encryptionKey, error) -> Void in
            expectation.fulfill()
        })
        
        super.waitForExpectationsWithTimeout(10, handler: nil)

    }
    
    
    
}
