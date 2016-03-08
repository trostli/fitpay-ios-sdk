
import ObjectMapper

public class Asset : Mappable
{
    var text:String?
    var image:UIImage?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        //TODO: Implement parsing
    }
}