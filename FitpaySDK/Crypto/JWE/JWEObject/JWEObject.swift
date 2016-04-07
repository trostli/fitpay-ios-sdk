
import FPCrypto

enum JWEObjectError: ErrorType {
    case UnsupportedAlgorithm
    case UnsupportedEncryption
    
    case HeaderNotSpecified
    case EncryptionNotSpecified
    case AlgorithmNotSpecified
    case HeadersIVNotSpecified
    case HeadersTagNotSpecified
}

class JWEObject {
    
    static let AuthenticationTagSize = 16
    static let CekSize = 32
    static let CekIVSize = 12
    static let PayloadIVSize = 16
    
    var header : JWEHeader?
    
    private var cekCt : NSData?
    private var iv : NSData?
    private var ct : NSData?
    private var tag : NSData?
    
    private(set) var encryptedPayload : String?
    private(set) var decryptedPayload : String?
    private var payloadToEncrypt : String?
    
    static func parse(payload payload:String) -> JWEObject?
    {
        let jweObject : JWEObject = JWEObject()
        jweObject.encryptedPayload = payload
        
        let jwe = payload.componentsSeparatedByString(".")
        jweObject.header = JWEHeader(headerPayload: jwe[0])
        jweObject.cekCt = jwe[1].base64URLdecoded()
        jweObject.iv = jwe[2].base64URLdecoded()
        jweObject.ct = jwe[3].base64URLdecoded()
        jweObject.tag = jwe[4].base64URLdecoded()

        return jweObject
    }
    
    static func createNewObject(alg: String, enc: String, payload: String, keyId: String?) throws -> JWEObject?
    {
        guard JWEObject.isAlgorithmSupported(alg) else {
            throw JWEObjectError.UnsupportedAlgorithm
        }
        
        guard JWEObject.isEncryptionSupported(enc) else {
            throw JWEObjectError.UnsupportedEncryption
        }
        
        let jweObj = JWEObject()
        jweObj.header = JWEHeader(encryption: enc, algorithm: alg)
        jweObj.header!.kid = keyId
        
        jweObj.payloadToEncrypt = payload
        
        return jweObj
    }
    
    static func isAlgorithmSupported(algorithm: String!) -> Bool
    {
        switch algorithm {
        case "A256GCMKW":
            return true
        default:
            return false
        }
    }
    
    static func isEncryptionSupported(encryption: String!) -> Bool
    {
        switch encryption {
        case "A256GCM":
            return true
        default:
            return false
        }
    }
    
    func encrypt(sharedSecret: NSData) throws -> String?
    {
        guard payloadToEncrypt != nil else {
            return nil
        }
        
        guard header != nil else {
            throw JWEObjectError.HeaderNotSpecified
        }
        
        guard JWEObject.isAlgorithmSupported(header?.alg) else {
            throw JWEObjectError.UnsupportedAlgorithm
        }
        
        guard JWEObject.isEncryptionSupported(header?.enc) else {
            throw JWEObjectError.UnsupportedEncryption
        }
        
        if (header?.alg == "A256GCMKW" && header?.enc == "A256GCM") {
            let cek = String.random(JWEObject.CekSize).dataUsingEncoding(NSUTF8StringEncoding)
            let cekIV = String.random(JWEObject.CekIVSize).dataUsingEncoding(NSUTF8StringEncoding)
            
            let (cekCtCt, cekCTTag) = A256GCMEncryptData(sharedSecret, data: cek!, iv: cekIV!, aad: nil)
            let encodedCekCt = cekCtCt!.base64URLencoded()
            
            let payloadIV = String.random(JWEObject.PayloadIVSize).dataUsingEncoding(NSUTF8StringEncoding)
            let encodedPayloadIV = payloadIV?.base64URLencoded()
            
            let encodedHeader : NSData!
            let base64UrlHeader : String!
            do {
                header?.tag = cekCTTag
                header?.iv = cekIV
                
                base64UrlHeader = try header?.serialize()
                encodedHeader = base64UrlHeader.dataUsingEncoding(NSUTF8StringEncoding)
            } catch let error {
                throw error
            }
            
            let (encryptedPayloadCt, encryptedPayloadTag) = A256GCMEncryptData(cek!, data: payloadToEncrypt!.dataUsingEncoding(NSUTF8StringEncoding)!, iv: payloadIV!, aad: encodedHeader)
            
            let encodedCipherText = encryptedPayloadCt?.base64URLencoded()
            let encodedAuthTag = encryptedPayloadTag?.base64URLencoded()
            
            guard base64UrlHeader != nil && encodedPayloadIV != nil && encodedCipherText != nil && encodedAuthTag != nil else {
                return nil
            }
            
            encryptedPayload = "\(base64UrlHeader!).\(encodedCekCt).\(encodedPayloadIV!).\(encodedCipherText!).\(encodedAuthTag!)"
        }
        
        return encryptedPayload
    }
    
    func decrypt(sharedSecret: NSData) throws -> String?
    {
        guard header != nil else {
            throw JWEObjectError.HeaderNotSpecified
        }
        
        guard JWEObject.isAlgorithmSupported(header?.alg) else {
            throw JWEObjectError.UnsupportedAlgorithm
        }
        
        guard JWEObject.isEncryptionSupported(header?.enc) else {
            throw JWEObjectError.UnsupportedEncryption
        }
        
        if (header?.alg == "A256GCMKW" && header?.enc == "A256GCM") {
            
            guard header!.iv != nil else {
                throw JWEObjectError.HeadersIVNotSpecified
            }
            
            guard header!.tag != nil else {
                throw JWEObjectError.HeadersTagNotSpecified
            }
            
            guard ct != nil && tag != nil else {
                return nil
            }
            
            guard let cek = A256GCMDecryptData(sharedSecret, data: cekCt!, iv: header!.iv!, tag: header!.tag!, aad: nil) else {
                return nil
            }
            let jwe = encryptedPayload!.componentsSeparatedByString(".")
            let aad = jwe[0].dataUsingEncoding(NSUTF8StringEncoding)
            
            // ensure that we have 16 bytes in Authentication Tag
            if (tag?.length < JWEObject.AuthenticationTagSize) {
                let concatedCtAndTag = NSMutableData(data: ct!)
                concatedCtAndTag.appendData(tag!)
                if (concatedCtAndTag.length > JWEObject.AuthenticationTagSize) {
                    ct = concatedCtAndTag.subdataWithRange(NSRange(location: 0, length: concatedCtAndTag.length-JWEObject.AuthenticationTagSize))
                    tag = concatedCtAndTag.subdataWithRange(NSRange(location: concatedCtAndTag.length-JWEObject.AuthenticationTagSize, length: JWEObject.AuthenticationTagSize))
                }
            }
            
            let data = A256GCMDecryptData(cek, data: ct!, iv: iv!, tag: tag!, aad: aad)
            decryptedPayload = String(data: data!, encoding: NSUTF8StringEncoding)
        }
        
        return decryptedPayload
    }
    
    private init() {
        
    }
    
    private func A256GCMDecryptData(cipherKey:NSData, data:NSData, iv:NSData, tag:NSData, aad:NSData?) -> NSData?
    {
        let cipherKeyUInt8 = UnsafeMutablePointer<UInt8>(cipherKey.bytes)
        let dataUInt8 = UnsafeMutablePointer<UInt8>(data.bytes)
        let ivUInt8 = UnsafeMutablePointer<UInt8>(iv.bytes)
        let tagUInt8 = UnsafeMutablePointer<UInt8>(tag.bytes)
        
        let aadUInt8 : UnsafeMutablePointer<UInt8>!
        let aadLenght : Int
        if (aad != nil) {
            aadUInt8 = UnsafeMutablePointer<UInt8>(aad!.bytes)
            aadLenght = aad!.length
        } else {
            aadUInt8 = UnsafeMutablePointer<UInt8>(nil)
            aadLenght = 0
        }
        
        let decryptResult = UnsafeMutablePointer<AESGCM_DecryptionResult>.alloc(sizeof(AESGCM_DecryptionResult))
        guard aes_gcm_decrypt(cipherKeyUInt8, Int32(cipherKey.length),
                        ivUInt8, Int32(iv.length),
                        aadUInt8, Int32(aadLenght),
                        dataUInt8, Int32(data.length),
                        tagUInt8, Int32(tag.length),
                        decryptResult) else {
            return nil
        }
        
        let nsdata = NSData(bytes:  decryptResult.memory.plain_text,
                            length: Int(decryptResult.memory.plain_text_size))
        
        aes_gcm_free_decryption_result(decryptResult)
        
        return nsdata
    }
    
    private func A256GCMEncryptData(key: NSData, data: NSData, iv: NSData, aad: NSData?) -> (NSData?, NSData?)
    {
        let cipherKeyUInt8 = UnsafeMutablePointer<UInt8>(key.bytes)
        let dataUInt8 = UnsafeMutablePointer<UInt8>(data.bytes)
        let ivUInt8 = UnsafeMutablePointer<UInt8>(iv.bytes)
        
        let aadUInt8 : UnsafeMutablePointer<UInt8>!
        let aadLenght : Int
        if (aad != nil) {
            aadUInt8 = UnsafeMutablePointer<UInt8>(aad!.bytes)
            aadLenght = aad!.length
        } else {
            aadUInt8 = UnsafeMutablePointer<UInt8>(nil)
            aadLenght = 0
        }
        let encryptResult = UnsafeMutablePointer<AESGCM_EncryptionResult>.alloc(sizeof(AESGCM_EncryptionResult))
        aes_gcm_encrypt(cipherKeyUInt8, Int32(key.length),
                        ivUInt8, Int32(iv.length),
                        aadUInt8, Int32(aadLenght),
                        dataUInt8, Int32(data.length),
                        encryptResult)
        
        let cipherText = NSData(bytes:  encryptResult.memory.cipher_text,
                                length: Int(encryptResult.memory.cipher_text_size))
        let tag = NSData(bytes:  encryptResult.memory.auth_tag,
                         length: Int(encryptResult.memory.auth_tag_size))

        aes_gcm_free_encryption_result(encryptResult)
        
        return (cipherText, tag)
    }
}
