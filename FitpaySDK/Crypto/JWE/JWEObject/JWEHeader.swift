
class JWEHeader
{
    var cty : String?
    var enc : JWEEncryption?
    var alg : JWEAlgorithm?
    var iv  : Data?
    var tag : Data?
    var kid : String?
    
    var sender: String?
    var destination : String?
    
    init(encryption: JWEEncryption, algorithm: JWEAlgorithm)
    {
        enc = encryption
        alg = algorithm
    }
    
    init(headerPayload:String)
    {
        let headerData = headerPayload.base64URLdecoded()
        guard let json = try? JSONSerialization.jsonObject(with: headerData!, options: .mutableContainers) else {
            return
        }
        
        guard let mappedJson = json as? [String:String] else {
            return
        }
        
        cty = mappedJson["cty"]
        kid = mappedJson["kid"]
        iv = mappedJson["iv"]?.base64URLdecoded() as Data?
        tag = mappedJson["tag"]?.base64URLdecoded() as Data?
        
        if let encStr = mappedJson["enc"] {
            enc = JWEEncryption(rawValue: encStr)
        }
        
        if let algStr = mappedJson["alg"] {
            alg = JWEAlgorithm(rawValue: algStr)
        }
    }
    
    func serialize() throws -> String?
    {
        var paramsDict : [String:String]! = [String:String]()
    
        guard enc != nil else {
            throw JWEObjectError.encryptionNotSpecified
        }
        
        guard alg != nil else {
            throw JWEObjectError.algorithmNotSpecified
        }
        
        guard iv != nil else {
            throw JWEObjectError.headersIVNotSpecified
        }
        
        guard tag != nil else {
            throw JWEObjectError.headersTagNotSpecified
        }
        
        if (cty == nil) {
            cty = "application/json"
        }
        
        paramsDict["enc"] = enc?.rawValue
        paramsDict["alg"] = alg?.rawValue
        paramsDict["iv"]  = iv!.base64URLencoded()
        paramsDict["tag"] = tag!.base64URLencoded()
        
        if (kid != nil) {
            paramsDict["kid"] = kid!
        }
        
        if (sender != nil) {
            paramsDict["sender"] = sender!
        }
        
        if (destination != nil) {
            paramsDict["destination"] = destination!
        }
        
        var jsonData : Data
        do
        {
            // we will serialize cty separately, because NSJSONSerialization is adding escape for "/"
            let dataWithoutCty = try JSONSerialization.data(withJSONObject: paramsDict, options: JSONSerialization.WritingOptions(rawValue: 0))
            jsonData = ((dataWithoutCty as NSData).mutableCopy() as! NSMutableData) as Data
            
            let ctyData = "{\"cty\":\"\(cty!)\",".data(using: String.Encoding.utf8)
            jsonData.replaceSubrange(jsonData.startIndex..<jsonData.startIndex+1, with: ctyData!)
        } catch let error {
            throw error
        }
        
        return jsonData.base64URLencoded()
    }
}
