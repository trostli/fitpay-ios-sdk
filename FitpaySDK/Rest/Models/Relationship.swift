
import ObjectMapper

public class Relationship : ClientModel, Mappable
{
    public var links:[ResourceLink]?
    internal var card:CardInfo?
    public var device: DeviceInfo?
    
    private static let selfResource = "self"
    
    internal weak var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        card <- map["card"]
        device <- map["device"]
    }
    
    /**
     Removes a relationship between a device and a creditCard if it exists
     
        - parameter completion:   DeleteRelationshipHandler closure
     */
    public func delete(completion:RestClient.DeleteRelationshipHandler) {
        let resource = Relationship.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deleteRelationship(url, completion: completion)
        }
        else
        {
            completion(error: NSError.clientUrlError(domain:Relationship.self, code:0, client: client, url: url, resource: resource))
        }
    }
}
