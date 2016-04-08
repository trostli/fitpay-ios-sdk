
class JWEHeader
{
    var cty : String?
    var enc : JWEEncryption?
    var alg : JWEAlgorithm?
    var iv  : NSData?
    var tag : NSData?
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
        guard let json = try? NSJSONSerialization.JSONObjectWithData(headerData!, options: .MutableContainers) else {
            return
        }
        
        guard let mappedJson = json as? [String:String] else {
            return
        }
        
        cty = mappedJson["cty"]
        kid = mappedJson["kid"]
        iv = mappedJson["iv"]?.base64URLdecoded()
        tag = mappedJson["tag"]?.base64URLdecoded()
        
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
            throw JWEObjectError.EncryptionNotSpecified
        }
        
        guard alg != nil else {
            throw JWEObjectError.AlgorithmNotSpecified
        }
        
        guard iv != nil else {
            throw JWEObjectError.HeadersIVNotSpecified
        }
        
        guard tag != nil else {
            throw JWEObjectError.HeadersTagNotSpecified
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
        
        var jsonData : NSMutableData
        do
        {
            // we will serialize cty separately, because NSJSONSerialization is adding escape for "/"
            let dataWithoutCty = try NSJSONSerialization.dataWithJSONObject(paramsDict, options: NSJSONWritingOptions(rawValue: 0))
            jsonData = dataWithoutCty.mutableCopy() as! NSMutableData
            
            let ctyData = "{\"cty\":\"\(cty!)\",".dataUsingEncoding(NSUTF8StringEncoding)
            jsonData.replaceBytesInRange(NSMakeRange(0, 1), withBytes: ctyData!.bytes, length: ctyData!.length)
        } catch let error {
            throw error
        }
        
        return jsonData.base64URLencoded()
    }
}