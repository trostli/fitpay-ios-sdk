
import FitpaySDK
import Foundation

public extension RestSession
{
    public typealias CompLoginHandler = (error:NSError!)->Void

    @objc public func login(username:String, password:String, completion:CompLoginHandler)
    {
        self.login(username: username, password: password)
        {
            (error:ErrorType?) in
            completion(error: error as? NSError)
        }
    }
}

public extension RestClient
{
    public typealias CompUserHandler = (user:User!, error:NSError!)->Void
    
    @objc public func user(id id:String, completion:CompUserHandler)
    {
        self.user(id: id)
        {
            (user, error) in
            completion(user:user, error:error as? NSError)
        }
    }
    
    public typealias CompCreateRelationshipHandler = (relationship:Relationship!, error:NSError!)->Void
    
    @objc public func createRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:CompCreateRelationshipHandler)
    {
        self.createRelationship(userId: userId, creditCardId: creditCardId, deviceId: deviceId)
        {
            (relationship:Relationship?, error:ErrorType?) in
            completion(relationship: relationship, error: error as? NSError)
        }
    }
}


public class СompResultCollection : NSObject
{
    public var rawCollection:AnyObject?
    
    public var limit:Int = 0
    public var offset:Int = 0
    public var totalResults:Int = 0
    public var results:[AnyObject]?
    
    private var creditCardsCollection:ResultCollection<CreditCard>?
    {
        return self.rawCollection as? ResultCollection<CreditCard>
    }
    
    private var devicesCollection:ResultCollection<DeviceInfo>?
    {
        return self.rawCollection as? ResultCollection<DeviceInfo>
    }
    
    private var transactionsCollection:ResultCollection<Transaction>?
    {
        return self.rawCollection as? ResultCollection<Transaction>
    }
}

public extension User
{
    public typealias CompCreateCreditCardHandler = (creditCard:CreditCard!, error:NSError!)->Void
    
    @objc public func createCreditCard(pan pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
                                     street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
                                     completion:CompCreateCreditCardHandler)
    {
        self.createCreditCard(pan: pan, expMonth: expMonth, expYear: expYear, cvv: cvv, name: name, street1: street1, street2: street2, street3: street3, city: city, state: state, postalCode: postalCode, country: country)
        {
            (creditCard:CreditCard?, error:ErrorType?) in
            completion(creditCard: creditCard, error: error as? NSError)
        }
    }
    
    public typealias CompCreditCardsHandler = (result:СompResultCollection!, error:NSError!) -> Void

    
    @objc public func listCreditCards(excludeState excludeState:[String], limit:Int, offset:Int, completion:CompCreditCardsHandler)
    {
        self.listCreditCards(excludeState: excludeState, limit: limit, offset: offset)
        {
            (result:ResultCollection<CreditCard>?, error:ErrorType?) in
            
            completion(result: CreateCompatibleResultColletion(result), error: error as? NSError)
        }
    }
}

public func CreateCompatibleResultColletion<T>(resultCollection:ResultCollection<T>?) -> СompResultCollection?
{
    if let resultCollection = resultCollection
    {
        let compResultCollection = СompResultCollection()
        
        compResultCollection.rawCollection = resultCollection
        compResultCollection.limit = resultCollection.limit ?? 0
        compResultCollection.offset = resultCollection.offset ?? 0
        compResultCollection.totalResults = resultCollection.totalResults ?? 0
        
        if let results = resultCollection.results
        {
            var compResults = [AnyObject]()
            
            for item in results
            {
                if let item = item as? AnyObject
                {
                    compResults.append(item)
                }
            }
            
            compResultCollection.results = compResults
        }
        
        return compResultCollection
    }
    
    return nil
}
