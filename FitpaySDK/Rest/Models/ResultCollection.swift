
import ObjectMapper

public class ResultCollection<T: Mappable> : ClientModel, Mappable, SecretApplyable
{
    public var limit:Int?
    public var offset:Int?
    public var totalResults:Int?
    public var results:[T]?
    public var links:[ResourceLink]?
    
    internal var client:RestClient?
    {
        get
        {
            if let results = self.results
            {
                for result in results
                {
                    if var result = result as? ClientModel
                    {
                        return result.client
                    }
                }
            }
            
            return nil
        }
        
        set
        {
            if let results = self.results
            {
                for result in results
                {
                    if var result = result as? ClientModel
                    {
                        result.client = newValue
                    }
                }
            }
        }
    }
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        limit <- map["limit"]
        offset <- map["offset"]
        totalResults <- map["totalResults"]
        
        if let objectsArray = map["results"].currentValue as? [AnyObject] {
            results = [T]()
            for objectMap in objectsArray {
                if let modelObject = Mapper<T>().map(objectMap) {
                    results!.append(modelObject)
                }
            }
        }
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        if let results = self.results {
            for modelObject in results {
                if let objectWithEncryptedData = modelObject as? SecretApplyable {
                    objectWithEncryptedData.applySecret(secret, expectedKeyId: expectedKeyId)
                }
            }
        }
    }
}
