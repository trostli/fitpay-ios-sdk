
import ObjectMapper

extension JWEObject
{
    class func decrypt<T:Mappable>(encryptedData:String?, expectedKeyId:String?, secret:NSData )->T?
    {
        if let encryptedData = encryptedData
        {
            let jweResult = JWEObject.parse(payload: encryptedData)
            if let expectedKeyId = expectedKeyId {
                if let kid = jweResult?.header?.kid
                {
                    // decrypt only if keys match
                    if kid == expectedKeyId
                    {
                        if let decryptResult = try? jweResult?.decrypt(secret)
                        {
                            return Mapper<T>().map(decryptResult)
                        }
                    }
                }
            } else {
                if let decryptResult = try? jweResult?.decrypt(secret)
                {
                    return Mapper<T>().map(decryptResult)
                }
            }
        }
        
        return nil
    }
}