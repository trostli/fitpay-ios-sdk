
import ObjectMapper

open class ResultCollection<T: Mappable> : NSObject, ClientModel, Mappable, SecretApplyable
{
    open var limit:Int?
    open var offset:Int?
    open var totalResults:Int?
    open var results:[T]?
    internal var links:[ResourceLink]?
    fileprivate let lastResourse = "last"
    fileprivate let nextResourse = "next"
    fileprivate let previousResource = "previous"
    
    open var nextAvailable:Bool
    {
        return self.links?.url(self.nextResourse) != nil
    }
    
    open var lastAvailable:Bool
    {
        return self.links?.url(self.lastResourse) != nil
    }
    
    open var previousAvailable:Bool
    {
        return self.links?.url(self.previousResource) != nil
    }
    
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
                    else
                    {
                        print("Failed to convert \(result) to ClientModel")
                    }
                }
            }
        }
    }
    
    public required init?(_ map: Map)
    {
        
    }
    
    open func mapping(_ map: Map)
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
    
    internal func applySecret(_ secret:Data, expectedKeyId:String?)
    {
        if let results = self.results {
            for modelObject in results {
                if let objectWithEncryptedData = modelObject as? SecretApplyable {
                    objectWithEncryptedData.applySecret(secret, expectedKeyId: expectedKeyId)
                }
            }
        }
    }
    
    public typealias CollectAllAvailableCompletion = (_ results: [T]?, _ error: Error?) -> Void
    
    open func collectAllAvailable(_ completion: CollectAllAvailableCompletion) {
        if let nextUrl = self.links?.url(self.nextResourse), let _ = self.results {
            self.collectAllAvailable(&self.results!, nextUrl: nextUrl, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: nil, resource: self.nextResourse))
        }
    }
    
    fileprivate func collectAllAvailable(_ storage: inout [T], nextUrl: String, completion: @escaping CollectAllAvailableCompletion) {
        if let client = self.client {
            let _ : T? = client.collectionItems(nextUrl)
            {
                (resultCollection, error) -> Void in
                
                guard error == nil else {
                    completion(results: nil, error: error)
                    return
                }
                
                guard let resultCollection = resultCollection, let results = resultCollection.results else {
                    completion(results: nil, error: NSError.unhandledError(ResultCollection.self))
                    return
                }
                
                storage += results
                
                if let nextUrlItr = resultCollection.links?.url(self.nextResourse) {
                    self.collectAllAvailable(&storage, nextUrl: nextUrlItr, completion: completion)
                } else {
                    completion(results: storage, error: nil)
                }
            }
        } else {
            completion(nil, NSError.unhandledError(ResultCollection.self))
        }
    }
    
    open func next(_ completion:RestClient.CreditCardsHandler)
    {
        let resource = self.nextResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.creditCards(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func last(_ completion:RestClient.CreditCardsHandler)
    {
        let resource = self.lastResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.creditCards(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func next(_ completion:RestClient.DevicesHandler)
    {
        let resource = self.nextResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.devices(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func last(_ completion:RestClient.DevicesHandler)
    {
        let resource = self.lastResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.devices(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func next(_ completion:RestClient.TransactionsHandler)
    {
        let resource = self.nextResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.transactions(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func last(_ completion:RestClient.TransactionsHandler)
    {
        let resource = self.lastResourse
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.transactions(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
    
    open func previous(_ completion:RestClient.CommitsHandler)
    {
        let resource = self.previousResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.commits(url, parameters: nil, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:ResultCollection.self, code:0, client: client, url: url, resource: resource)
            completion(result: nil, error: error)
        }
    }
}
