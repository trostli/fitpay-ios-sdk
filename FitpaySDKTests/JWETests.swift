import XCTest
@testable import FitpaySDK

class JWETests: XCTestCase
{
    let plainText = "{\"Hello world!\"}"
    let sharedSecret = "NFxCwmIncymviQp9-KKKgH_8McGHWGgwV-T-RNkMI-U".base64URLdecoded()
    
    func testJWEEncryption()
    {
        let jweObject = try? JWEObject.createNewObject("A256GCMKW", enc: "A256GCM", payload: plainText, keyId: nil)
        XCTAssertNotNil(jweObject)
        
        let encryptResult = try? jweObject!!.encrypt(sharedSecret!)
        XCTAssertNotNil(encryptResult)
        
        let jweResult = JWEObject.parse(payload: encryptResult!!)
        let decryptResult = try? jweResult?.decrypt(sharedSecret!)
        XCTAssertNotNil(decryptResult)
        
        XCTAssertTrue(plainText == decryptResult!!)
    }
}