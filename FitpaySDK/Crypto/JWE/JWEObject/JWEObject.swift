
enum JWEAlgorithm : String {
    case A256GCMKW = "A256GCMKW"
}

enum JWEEncryption : String {
    case A256GCM = "A256GCM"
}

enum JWEObjectError: Error {
    case unsupportedAlgorithm
    case unsupportedEncryption
    
    case headerNotSpecified
    case encryptionNotSpecified
    case algorithmNotSpecified
    case headersIVNotSpecified
    case headersTagNotSpecified
}

class JWEObject {
    
    static let AuthenticationTagSize = 16
    static let CekSize = 32
    static let CekIVSize = 12
    static let PayloadIVSize = 16
    
    var header : JWEHeader?
    
    fileprivate var cekCt : Data?
    fileprivate var iv : Data?
    fileprivate var ct : Data?
    fileprivate var tag : Data?
    
    fileprivate(set) var encryptedPayload : String?
    fileprivate(set) var decryptedPayload : String?
    fileprivate var payloadToEncrypt : String?
    
    static func parse(payload:String) -> JWEObject?
    {
        let jweObject : JWEObject = JWEObject()
        jweObject.encryptedPayload = payload
        
        let jwe = payload.components(separatedBy: ".")
        jweObject.header = JWEHeader(headerPayload: jwe[0])
        jweObject.cekCt = jwe[1].base64URLdecoded() as Data?
        jweObject.iv = jwe[2].base64URLdecoded() as Data?
        jweObject.ct = jwe[3].base64URLdecoded() as Data?
        jweObject.tag = jwe[4].base64URLdecoded() as Data?

        return jweObject
    }
    
    static func createNewObject(_ alg: JWEAlgorithm, enc: JWEEncryption, payload: String, keyId: String?) throws -> JWEObject?
    {
        
        let jweObj = JWEObject()
        jweObj.header = JWEHeader(encryption: enc, algorithm: alg)
        jweObj.header!.kid = keyId
        
        jweObj.payloadToEncrypt = payload
        
        return jweObj
    }
    
    func encrypt(_ sharedSecret: Data) throws -> String?
    {
        guard payloadToEncrypt != nil else {
            return nil
        }
        
        guard header != nil else {
            throw JWEObjectError.headerNotSpecified
        }
        
        if (header?.alg == JWEAlgorithm.A256GCMKW && header?.enc == JWEEncryption.A256GCM) {
            let cek = String.random(JWEObject.CekSize).data(using: String.Encoding.utf8)
            let cekIV = String.random(JWEObject.CekIVSize).data(using: String.Encoding.utf8)
            
            let (cekCtCt, cekCTTag) = A256GCMEncryptData(sharedSecret, data: cek!, iv: cekIV!, aad: nil)
            let encodedCekCt = cekCtCt!.base64URLencoded()
            
            let payloadIV = String.random(JWEObject.PayloadIVSize).data(using: String.Encoding.utf8)
            let encodedPayloadIV = payloadIV?.base64URLencoded()
            
            let encodedHeader : Data!
            let base64UrlHeader : String!
            do {
                header?.tag = cekCTTag
                header?.iv = cekIV
                
                base64UrlHeader = try header?.serialize()
                encodedHeader = base64UrlHeader.data(using: String.Encoding.utf8)
            } catch let error {
                throw error
            }
            
            let (encryptedPayloadCt, encryptedPayloadTag) = A256GCMEncryptData(cek!, data: payloadToEncrypt!.data(using: String.Encoding.utf8)!, iv: payloadIV!, aad: encodedHeader)
            
            let encodedCipherText = encryptedPayloadCt?.base64URLencoded()
            let encodedAuthTag = encryptedPayloadTag?.base64URLencoded()
            
            guard base64UrlHeader != nil && encodedPayloadIV != nil && encodedCipherText != nil && encodedAuthTag != nil else {
                return nil
            }
            
            encryptedPayload = "\(base64UrlHeader!).\(encodedCekCt).\(encodedPayloadIV!).\(encodedCipherText!).\(encodedAuthTag!)"
        }
        
        return encryptedPayload
    }
    
    func decrypt(_ sharedSecret: Data) throws -> String?
    {
        guard header != nil else {
            throw JWEObjectError.headerNotSpecified
        }
        
        if (header?.alg == JWEAlgorithm.A256GCMKW && header?.enc == JWEEncryption.A256GCM) {
            
            guard header!.iv != nil else {
                throw JWEObjectError.headersIVNotSpecified
            }
            
            guard header!.tag != nil else {
                throw JWEObjectError.headersTagNotSpecified
            }
            
            guard ct != nil && tag != nil else {
                return nil
            }
            
            guard let cek = A256GCMDecryptData(sharedSecret, data: cekCt!, iv: header!.iv! as Data, tag: header!.tag! as Data, aad: nil) else {
                return nil
            }
            let jwe = encryptedPayload!.components(separatedBy: ".")
            let aad = jwe[0].data(using: String.Encoding.utf8)
            
            // ensure that we have 16 bytes in Authentication Tag
            if ((tag?.count)! < JWEObject.AuthenticationTagSize) {
                let concatedCtAndTag = NSMutableData(data: ct!)
                concatedCtAndTag.append(tag!)
                if (concatedCtAndTag.length > JWEObject.AuthenticationTagSize) {
                    ct = concatedCtAndTag.subdata(with: NSRange(location: 0, length: concatedCtAndTag.length-JWEObject.AuthenticationTagSize))
                    tag = concatedCtAndTag.subdata(with: NSRange(location: concatedCtAndTag.length-JWEObject.AuthenticationTagSize, length: JWEObject.AuthenticationTagSize))
                }
            }
            
            let data = A256GCMDecryptData(cek, data: ct!, iv: iv!, tag: tag!, aad: aad)
            decryptedPayload = String(data: data!, encoding: String.Encoding.utf8)
        }
        
        return decryptedPayload
    }
    
    fileprivate init() {
        
    }
    
    fileprivate func A256GCMDecryptData(_ cipherKey:Data, data:Data, iv:Data, tag:Data, aad:Data?) -> Data?
    {
        let cipherKeyUInt8 = UnsafeMutablePointer<UInt8>(mutating: (cipherKey as NSData).bytes.bindMemory(to: UInt8.self, capacity: cipherKey.count))
        let dataUInt8 = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
        let ivUInt8 = UnsafeMutablePointer<UInt8>(mutating: (iv as NSData).bytes.bindMemory(to: UInt8.self, capacity: iv.count))
        let tagUInt8 = UnsafeMutablePointer<UInt8>(mutating: (tag as NSData).bytes.bindMemory(to: UInt8.self, capacity: tag.count))
        
        let aadUInt8 : UnsafeMutablePointer<UInt8>!
        let aadLenght : Int
        if (aad != nil) {
            aadUInt8 = UnsafeMutablePointer<UInt8>(mutating: (aad! as NSData).bytes.bindMemory(to: UInt8.self, capacity: aad!.count))
            aadLenght = aad!.count
        } else {
            aadUInt8 = UnsafeMutablePointer<UInt8>(nil)
            aadLenght = 0
        }
        
        let decryptResult = UnsafeMutablePointer<AESGCM_DecryptionResult>.allocate(capacity: MemoryLayout<AESGCM_DecryptionResult>.size)
        
        let openssl = OpenSSLHelper.sharedInstance()
        
        guard (openssl?.aes_GSM_decrypt(cipherKeyUInt8, keySize: Int32(cipherKey.count), iv: ivUInt8, ivSize: Int32(iv.count), aad: aadUInt8, aadSize: Int32(aadLenght), cipherText: dataUInt8, cipherTextSize: Int32(data.count), authTag: tagUInt8, authTagSize: Int32(tag.count), result: decryptResult))! else {
            return nil
        }
        
        let nsdata = Data(bytes: UnsafePointer<UInt8>(decryptResult.pointee.plain_text),
                            count: Int(decryptResult.pointee.plain_text_size))
        openssl?.aes_GSM_freeDecryptionResult(decryptResult)
        
        return nsdata
    }
    
    fileprivate func A256GCMEncryptData(_ key: Data, data: Data, iv: Data, aad: Data?) -> (Data?, Data?)
    {
        let cipherKeyUInt8 = UnsafeMutablePointer<UInt8>(mutating: (key as NSData).bytes.bindMemory(to: UInt8.self, capacity: key.count))
        let dataUInt8 = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
        let ivUInt8 = UnsafeMutablePointer<UInt8>(mutating: (iv as NSData).bytes.bindMemory(to: UInt8.self, capacity: iv.count))
        
        let aadUInt8 : UnsafeMutablePointer<UInt8>!
        let aadLenght : Int
        if (aad != nil) {
            aadUInt8 = UnsafeMutablePointer<UInt8>(mutating: (aad! as NSData).bytes.bindMemory(to: UInt8.self, capacity: aad!.count))
            aadLenght = aad!.count
        } else {
            aadUInt8 = UnsafeMutablePointer<UInt8>(nil)
            aadLenght = 0
        }
        let encryptResult = UnsafeMutablePointer<AESGCM_EncryptionResult>.allocate(capacity: MemoryLayout<AESGCM_EncryptionResult>.size)
        
        let openssl = OpenSSLHelper.sharedInstance()

        openssl?.aes_GSM_encrypt(cipherKeyUInt8, keySize: Int32(key.count), iv: ivUInt8, ivSize: Int32(iv.count), aad: aadUInt8, aadSize: Int32(aadLenght), plainText: dataUInt8, plainTextSize: Int32(data.count), result: encryptResult)
        
        let cipherText = Data(bytes: UnsafePointer<UInt8>(encryptResult.pointee.cipher_text),
                                count: Int(encryptResult.pointee.cipher_text_size))
        let tag = Data(bytes: UnsafePointer<UInt8>(encryptResult.pointee.auth_tag),
                         count: Int(encryptResult.pointee.auth_tag_size))

        openssl?.aes_GSM_freeEncryptionResult(encryptResult)
        
        return (cipherText, tag)
    }
}
