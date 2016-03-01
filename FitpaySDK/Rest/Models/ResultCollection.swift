
import ObjectMapper

public class ResultCollection<T: Mappable> : Mappable
{
    public var limit:Int?
    public var offset:Int?
    public var totalResults:Int?
    public var results:[T]?
    public var links:[ResourceLink]?
    
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
}
