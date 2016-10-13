
import ObjectMapper

open class Relationship : NSObject, ClientModel, Mappable
{
    internal var links:[ResourceLink]?
    internal var card:CardInfo?
    open var device: DeviceInfo?
    
    fileprivate static let selfResource = "self"
    
    internal weak var client:RestClient?
    
    public required init?(map: Map)
    {
        
    }
    
    open func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        card <- map["card"]
        device <- map["device"]
    }
    
    /**
     Removes a relationship between a device and a creditCard if it exists
     
        - parameter completion:   DeleteRelationshipHandler closure
     */
    @objc open func deleteRelationship(_ completion:@escaping RestClient.DeleteRelationshipHandler) {
        let resource = Relationship.selfResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.deleteRelationship(url, completion: completion)
        }
        else
        {
            completion(NSError.clientUrlError(domain:Relationship.self, code:0, client: client, url: url, resource: resource))
        }
    }
}
