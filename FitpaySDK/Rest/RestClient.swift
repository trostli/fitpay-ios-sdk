
import Foundation
import Alamofire
import AlamofireObjectMapper

public class RestClient
{
    /**
     FitPay uses conventional HTTP response codes to indicate success or failure of an API request. In general, codes in the 2xx range indicate success, codes in the 4xx range indicate an error that resulted from the provided information (e.g. a required parameter was missing, etc.), and codes in the 5xx range indicate an error with FitPay servers.

     Not all errors map cleanly onto HTTP response codes, however. When a request is valid but does not complete successfully (e.g. a card is declined), we return a 402 error code.

     - OK:               Everything worked as expected
     - BadRequest:       Often missing a required parameter
     - Unauthorized:     No valid API key provided
     - RequestFailed:    Parameters were valid but request failed
     - NotFound:         The requested item doesn't exist
     - ServerError[0-3]: Something went wrong on FitPay's end
     */
    public enum ErrorCode : Int, ErrorType, RawIntValue
    {
        case OK = 200
        case BadRequest = 400
        case Unauthorized = 401
        case RequestFailed = 402
        case NotFound = 404
        case ServerError0 = 500
        case ServerError1 = 502
        case ServerError2 = 503
        case ServerError3 = 504
    }

    private static let fpKeyIdKey:String = "fp-key-id"

    private let defaultHeaders = ["Accept" : "application/json"]
    private var _session:RestSession
    internal var keyPair:SECP256R1KeyPair = SECP256R1KeyPair()

    lazy private var _manager:Manager =
    {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        return Manager(configuration: configuration)
    }()

    private var key:EncryptionKey?

    public init(session:RestSession)
    {
        _session = session;
    }

    // MARK: User

    /**
     Completion handler

     - parameter ResultCollection<User>?: Provides ResultCollection<User> object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias ListUsersHandler = (ResultCollection<User>?, ErrorType?)->Void

    /**
      Returns a list of all users that belong to your organization. The customers are returned sorted by creation date, with the most recently created customers appearing first

     - parameter limit:      Max number of profiles per page
     - parameter offset:     Start index position for list of entities returned
     - parameter completion: ListUsersHandler closure
     */
    public func listUsers(limit limit:Int, offset:Int, completion: ListUsersHandler)
    {
        //TODO: Implement or remove this
    }

    /**
     Completion handler
     
     - parameter [User]?: Provides created User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias CreateUsersHandler = (User?, ErrorType?)->Void
    
    /**
     Creates a new user within your organization
     
     - parameter firstName:  first name of the user
     - parameter lastName:   last name of the user
     - parameter birthDate:  birth date of the user in date format [YYYY-MM-DD]
     - parameter email:      email of the user
     - parameter completion: CreateUsersHandler closure
     */
    public func createUser(firstName firstName:String, lastName:String, birthDate:String, email:String, completion:CreateUsersHandler)
    {
        //TODO: Implement or remove this
    }
    
    /**
     Completion handler
     
     - parameter user: Provides User object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias UserHandler = (user:User?, error:ErrorType?)->Void
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    public func user(id id:String, completion:UserHandler)
    {
        self.prepareAuthAndKeyHeaders(
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, API_BASE_URL + "/users/" + id, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<User, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(user:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(user:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(user: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(user: nil, error: error)
                })
            }
            
        })
    }
    
    /**
     Completion handler
     
     - parameter User?: Provides updated User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias UpdateUserHandler = (User?, ErrorType?)->Void
    
    /**
     Update the details of an existing user
     
     - parameter id:                   user id
     - parameter firstName:            first name or nil if no change is required
     - parameter lastName:             last name or nil if no change is required
     - parameter birthDate:            birth date in date format [YYYY-MM-DD] or nil if no change is required
     - parameter originAccountCreated: origin account created in date format [TODO: specify date format] or nil if no change is required
     - parameter termsAccepted:        terms accepted in date format [TODO: specify date format] or nil if no change is required
     - parameter termsVersion:         terms version formatted as [0.0.0]
     - parameter completion:           UpdateUserHandler closure
     */
    public func updateUser(id id:String, firstName:String?, lastName:String?, birthDate:Int?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:UpdateUserHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias DeleteUserHandler = (ErrorType?)->Void

    /**
     Delete a single user from your organization
     
     - parameter id:         user id
     - parameter completion: DeleteUserHandler closure
     */
     public func deleteUser(id id:String, completion:DeleteUserHandler)
    {

    }

    // MARK: Relationship
    
    /**
     Completion handler

     - parameter relationship: Provides Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias RelationshipHandler = (relationship:Relationship?, error:ErrorType?)->Void

    /**
     Get a single relationship
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   RelationshipHandler closure
     */
    @available(*, deprecated=1.0)  public func relationship(userId userId:String, creditCardId:String, deviceId:String, completion:RelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "creditCardId" : "\(creditCardId)",
                    "deviceId" : "\(deviceId)"
                ]
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/relationships", parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<Relationship, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(relationship:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(relationship:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(relationship: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                completion(relationship: nil, error: error)
            }
        }
    }

    /**
     Completion handler

     - parameter relationship: Provides created Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias CreateRelationshipHandler = (relationship:Relationship?, error:ErrorType?)->Void

    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    @available(*, deprecated=1.0) public func createRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:CreateRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "creditCardId" : "\(creditCardId)",
                    "deviceId" : "\(deviceId)"
                ]
                let request = self._manager.request(.PUT, "\(API_BASE_URL)/users/\(userId)/relationships", parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<Relationship, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(relationship:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(relationship:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(relationship: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                completion(relationship: nil, error: error)
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeleteRelationshipHandler = (error:ErrorType?)->Void
    
    /**
     Removes a relationship between a device and a creditCard if it exists
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   DeleteRelationshipHandler closure
     */
    @available(*, deprecated=1.0) public func deleteRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:DeleteRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "creditCardId" : "\(creditCardId)",
                    "deviceId" : "\(deviceId)"
                ]
                let request = self._manager.request(.DELETE, "\(API_BASE_URL)/users/\(userId)/relationships", parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseString
                {
                    (response:Response<String, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(error:response.result.error)
                    })
                }
            }
            else
            {
                completion(error: error)
            }
        }
    }

    // MARK: Credit Card
    
    /**
    Completion handler
    
    - parameter creditCard: Provides credit card object, or nil if error occurs
    - parameter error:      Provides error object, or nil if no error occurs
    */
    public typealias CreateCreditCardHandler = (creditCard:CreditCard?, error:ErrorType?)->Void
    
    /**
     Add a single credit card to a user's profile. If the card owner has no default card, then the new card will become the default.
     
     - parameter userId:     user id
     - parameter pan:        pan
     - parameter expMonth:   expiration month
     - parameter expYear:    expiration year
     - parameter cvv:        cvv code
     - parameter name:       user name
     - parameter street1:    address
     - parameter street2:    address
     - parameter street3:    street name
     - parameter city:       address
     - parameter state:      state
     - parameter postalCode: postal code
     - parameter country:    country
     - parameter completion: CreateCreditCardHandler closure
     */
    @available(*, deprecated=1.0) public func createCreditCard(userId userId:String, pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
        street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
        completion:CreateCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                var parameters:[String : String] = [:]
                
                let rawCard = [
                    "pan" : pan,
                    "expMonth" : expMonth,
                    "expYear" : expYear,
                    "cvv" : cvv,
                    "name" : name,
                    "address" : [
                        "street1" : street1,
                        "street2" : street2,
                        "street3" : street3,
                        "city" : city,
                        "state" : state,
                        "postalCode" : postalCode,
                        "country" : country
                        ]
                ] as [String : AnyObject]
                
                if let cardJSON = rawCard.JSONString
                {
                    if let jweObject = try? JWEObject.createNewObject("A256GCMKW", enc: "A256GCM", payload: cardJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                    {
                        if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)
                        {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
            
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards", parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(creditCard: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                        () -> Void in
                        completion(creditCard:nil, error: error)
                })
            }
        }
    }
    
    /**
    Completion handler
    
    - parameter result: Provides collection of credit cards, or nil if error occurs
    - parameter error:  Provides error object, or nil if no error occurs
    */
    public typealias CreditCardsHandler = (result:ResultCollection<CreditCard>?, error:ErrorType?) -> Void

    /**
     Retrieves the details of an existing credit card. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter userId:       user id
     - parameter excludeState: Exclude all credit cards in the specified state. If you desire to specify multiple excludeState values, then repeat this query parameter multiple times.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CreditCardsHandler closure
     */
    @available(*, deprecated=1.0) internal func creditCards(userId userId:String, excludeState:[String], limit:Int, offset:Int, completion:CreditCardsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let parameters:[String : AnyObject] = ["excludeState" : excludeState.joinWithSeparator(","), "limit" : limit, "offest" : offset]
                let request = self._manager.request(.GET, API_BASE_URL + "/users/" + userId + "/creditCards", parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<ResultCollection<CreditCard>, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(result:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(result:resultValue, error: nil)
                        }
                        else
                        {
                            completion(result:nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(result:nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias CreditCardHandler = (creditCard:CreditCard?, error:ErrorType?)->Void
    
    /**
     Retrieves the details of an existing credit card. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   CreditCardHandler closure
     */
    @available(*, deprecated=1.0) public func creditCard(creditCardId creditCardId:String, userId:String, completion:CreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(creditCard:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(creditCard:nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeleteCreditCardHandler = (error:ErrorType?)->Void
    
    /**
     Delete a single credit card from a user's profile. If you delete a card that is currently the default source, then the most recently added source will become the new default.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   DeleteCreditCardHandler closure
     */
    @available(*, deprecated=1.0) public func deleteCreditCard(creditCardId creditCardId:String, userId:String, completion:DeleteCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.DELETE, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseData(
                {
                    (response:Response<NSData, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(error: error)
                        }
                        else if let _ = response.result.value
                        {
                            completion(error: nil)
                        }
                        else
                        {
                            completion(error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias UpdateCreditCardHandler = (creditCard:CreditCard?, error:ErrorType?) -> Void
    
    /**
     Update the details of an existing credit card
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter name:         name
     - parameter street1:      address
     - parameter street2:      address
     - parameter city:         city
     - parameter state:        state
     - parameter postalCode:   postal code
     - parameter countryCode:  country code
     - parameter completion:   UpdateCreditCardHandler closure
     */
    @available(*, deprecated=1.0)  public func updateCreditCard(creditCardId creditCardId:String, userId:String, name:String?, street1:String?, street2:String?, city:String?, state:String?, postalCode:String?, countryCode:String?, completion:UpdateCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                var operations:[[String : String]] = []
                
                var parameters:[String : AnyObject] = [:]
                
                if let name = name
                {
                    operations.append([
                        "op": "replace", "path": "/name", "value" : name
                        ])
                }
                
                if let street1 = street1
                {
                    operations.append([
                        "op": "replace", "path": "/address/street1", "value" : street1
                        ])
                }
                
                if let street2 = street2
                {
                    operations.append([
                        "op": "replace", "path": "/address/street2", "value" : street2
                        ])
                }
                
                if let city = city
                {
                    operations.append([
                        "op": "replace", "path": "/address/city", "value" : city
                        ])
                }
                
                if let state = state
                {
                    operations.append([
                        "op": "replace", "path": "/address/state", "value" : state
                        ])
                }
                
                if let postalCode = postalCode
                {
                    operations.append([
                        "op": "replace", "path": "/address/postalCode", "value" : postalCode
                        ])
                }
                
                if let countryCode = countryCode
                {
                    operations.append([
                        "op": "replace", "path": "/address/countryCode", "value" : countryCode
                        ])
                }
                
                if let updateJSON = operations.JSONString
                {
                    if let jweObject = try? JWEObject.createNewObject("A256GCMKW", enc: "A256GCM", payload: updateJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                    {
                        if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)!
                        {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
                
                let request = self._manager.request(.PATCH, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId, parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(creditCard:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(creditCard:nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler

     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card?:   Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error?:  Provides error object, or nil if no error occurs
     */
    public typealias AcceptTermsHandler = (pending:Bool, card:CreditCard?, error:ErrorType?)->Void
    
    /**
     Indicates a user has accepted the terms and conditions presented when the credit card was first added to the user's profile
    
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   AcceptTermsHandler closure
     */
    @available(*, deprecated=1.0) public func acceptTerms(creditCardId creditCardId:String, userId:String, completion:AcceptTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/acceptTerms", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending: false, card: nil, error: error)
                        }
                        else if let value = response.result.value
                        {
                            completion(pending: false, card: value, error: nil)
                        }
                        else if (response.response != nil && response.response!.statusCode == 202)
                        {
                            completion(pending: true, card: nil, error: nil)
                        }
                        else
                        {
                            completion(pending: false, card: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(pending: false, card: nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card:    Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
     */
    public typealias DeclineTermsHandler = (pending:Bool, card:CreditCard?, error:ErrorType?)->Void
    
    /**
     Indicates a user has declined the terms and conditions. Once declined the credit card will be in a final state, no other actions may be taken

     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   DeclineTermsHandler closure
     */
    @available(*, deprecated=1.0) public func declineTerms(creditCardId creditCardId:String, userId:String, completion:DeclineTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/declineTerms", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending: false, card: nil, error: error)
                        }
                        else if let value = response.result.value
                        {
                            completion(pending: false, card: value, error: nil)
                        }
                        else if (response.response != nil && response.response!.statusCode == 202)
                        {
                            completion(pending: true, card: nil, error: nil)
                        }
                        else
                        {
                            completion(pending: false, card: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(pending: false, card: nil, error: error)
                })
            }
        }
    }

    /**
     Completion handler

     - parameter pending:     Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias MakeDefaultHandler = (pending:Bool, creditCard:CreditCard?, error:ErrorType?)->Void

    /**
     Mark the credit card as the default payment instrument. If another card is currently marked as the default, the default will automatically transition to the indicated credit card
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   MakeDefaultHandler closure
     */
    @available(*, deprecated=1.0) public func makeDefault(creditCardId creditCardId:String, userId:String, completion:MakeDefaultHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/makeDefault", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending:false, creditCard:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(pending:false, creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            if let statusCode = response.response?.statusCode
                            {
                                switch statusCode
                                {
                                    case 202:
                                    completion(pending:true, creditCard:nil, error: nil)
                                    
                                    default:
                                    completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                            else
                            {
                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(pending:false, creditCard:nil, error: error)
                })
            }
        }

    }

    /**
     Completion handler

     - parameter pending:    Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard: Provides deactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:      Provides error object, or nil if no error occurs
     */
    public typealias DeactivateHandler = (pending:Bool, creditCard:CreditCard?, error:ErrorType?)->Void
    
    /**
     Transition the credit card into a deactived state so that it may not be utilized for payment. This link will only be available for qualified credit cards that are currently in an active state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     deactivation initiator
     - parameter reason:       deactivation reason
     - parameter completion:   DeactivateHandler closure
     */
    @available(*, deprecated=1.0) public func deactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:DeactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/deactivate", parameters: parameters, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending:false, creditCard:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(pending:false, creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            if let statusCode = response.response?.statusCode
                            {
                                switch statusCode
                                {
                                case 202:
                                    completion(pending:true, creditCard:nil, error: nil)
                                    
                                default:
                                    completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                            else
                            {
                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(pending:false, creditCard:nil, error: error)
                })
            }
        }
    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias ReactivateHandler = (pending:Bool, creditCard:CreditCard?, error:ErrorType?)->Void

    /**
     Transition the credit card into an active state where it can be utilized for payment. This link will only be available for qualified credit cards that are currently in a deactivated state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     reactivation initiator
     - parameter reason:       reactivation reason
     - parameter completion:   ReactivateHandler closure
     */
    @available(*, deprecated=1.0) public func reactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:ReactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/reactivate", parameters: parameters, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<CreditCard, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending:false, creditCard:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(pending:false, creditCard:resultValue, error: nil)
                        }
                        else
                        {
                            if let statusCode = response.response?.statusCode
                            {
                                switch statusCode
                                {
                                case 202:
                                    completion(pending:true, creditCard:nil, error: nil)
                                    
                                default:
                                    completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                            else
                            {
                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(pending:false, creditCard:nil, error: error)
                })
            }
        }
    }

    /**
     Completion handler
     - parameter pending:             Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod:  Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:               Provides error object, or nil if no error occurs
     */
    public typealias SelectVerificationTypeHandler = (pending:Bool, verificationMethod:VerificationMethod?, error:ErrorType?)->Void
    
    /**
     When an issuer requires additional authentication to verfiy the identity of the cardholder, this indicates the user has selected the specified verification method by the indicated verificationTypeId
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter completion:         SelectVerificationTypeHandler closure
     */
    @available(*, deprecated=1.0) public func selectVerificationType(creditCardId creditCardId:String, userId:String, verificationTypeId:String, completion:SelectVerificationTypeHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/verificationMethods/\(verificationTypeId)/select", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<VerificationMethod, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending:false, verificationMethod:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(pending:false, verificationMethod:resultValue, error: nil)
                        }
                        else
                        {
                            if let statusCode = response.response?.statusCode
                            {
                                switch statusCode
                                {
                                case 202:
                                    completion(pending:true, verificationMethod:nil, error: nil)
                                    
                                default:
                                    completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                            else
                            {
                                completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(pending:false, verificationMethod:nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter pending:            Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    public typealias VerifyHandler = (pending:Bool, verificationMethod:VerificationMethod?, error:ErrorType?)->Void
    
    /**
     If a verification method is selected that requires an entry of a pin code, this transition will be available. Not all verification methods will include a secondary verification step through the FitPay API
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter verificationCode:   verification code
     - parameter completion:         VerifyHandler closure
     */
    @available(*, deprecated=1.0)  public func verify(creditCardId creditCardId:String, userId:String, verificationTypeId:String, verificationCode:String, completion:VerifyHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let params = [
                    "verificationCode" : verificationCode
                ]
                
                let request = self._manager.request(.POST, API_BASE_URL + "/users/" + userId + "/creditCards/" + creditCardId + "/verificationMethods/\(verificationTypeId)/verify", parameters: params, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<VerificationMethod, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(pending:false, verificationMethod:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(pending:false, verificationMethod:resultValue, error: nil)
                        }
                        else
                        {
                            if let statusCode = response.response?.statusCode
                            {
                                switch statusCode
                                {
                                case 202:
                                    completion(pending:true, verificationMethod:nil, error: nil)
                                    
                                default:
                                    completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                            else
                            {
                                completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(pending:false, verificationMethod:nil, error: error)
                })
            }
        }
    }

    // MARK: Devices
    
    /**
    Completion handler
    
    - parameter devices: Provides ResultCollection<DeviceInfo> object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DevicesHandler = (devices:ResultCollection<DeviceInfo>?, error:ErrorType?)->Void
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter userId:     user id
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    @available(*, deprecated=1.0)  public func devices(userId userId:String, limit:Int, offset:Int, completion:DevicesHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "limit" : "\(limit)",
                    "offset" : "\(offset)"
                ]
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/devices", parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<ResultCollection<DeviceInfo>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)

                            completion(devices:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            
                            completion(devices:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(devices: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(devices: nil, error: error)
                })
            }
        }
    }

    /**
    Completion handler

    - parameter device: Provides created DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias CreateNewDeviceHandler = (device:DeviceInfo?, error:ErrorType?)->Void

    /**
     For a single user, create a new device in their profile
     
     - parameter userId:           user id
     - parameter deviceType:       device type
     - parameter manufacturerName: manufacturer name
     - parameter deviceName:       device name
     - parameter serialNumber:     serial number
     - parameter modelNumber:      model number
     - parameter hardwareRevision: hardware revision
     - parameter firmwareRevision: firmware revision
     - parameter softwareRevision: software revision
     - parameter systemId:         system id
     - parameter osName:           os name
     - parameter licenseKey:       license key
     - parameter bdAddress:        bd address //TODO: provide better description
     - parameter secureElementId:  secure element id
     - parameter pairing:          pairing date [MM-DD-YYYY]
     - parameter completion:       CreateNewDeviceHandler closure
     */
    @available(*, deprecated=1.0)  public func createNewDevice(userId userId:String, deviceType:String, manufacturerName:String, deviceName:String,
                         serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
                         softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
                         secureElementId:String, pairing:String, completion:CreateNewDeviceHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let params = [
                    "deviceType" : deviceType,
                    "manufacturerName" : manufacturerName,
                    "deviceName" : deviceName,
                    "serialNumber" : serialNumber,
                    "modelNumber" : modelNumber,
                    "hardwareRevision" : hardwareRevision,
                    "firmwareRevision" : firmwareRevision,
                    "softwareRevision" : softwareRevision,
                    "systemId" : systemId,
                    "osName" : osName,
                    "licenseKey" : licenseKey,
                    "bdAddress" : bdAddress,
                    "secureElementId" : secureElementId,
                    "pairingTs" : pairing
                ]
                let request = self._manager.request(.POST, "\(API_BASE_URL)/users/\(userId)/devices", parameters: params, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<DeviceInfo, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(device:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(device:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(device: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(device: nil, error: error)
                })
            }
        }
    }

    /**
    Completion handler

    - parameter device: Provides existing DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DeviceHandler = (device:DeviceInfo?, error:ErrorType?) -> Void
    
    /**
     Retrieves the details of an existing device. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeviceHandler closure
     */
    @available(*, deprecated=1.0) public func device(deviceId deviceId:String, userId:String, completion:DeviceHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/devices/\(deviceId)", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<DeviceInfo, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(device:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            
                            completion(device:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(device: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(device: nil, error: error)
                })
            }
        }
    }

    /**
    Completion handler

    - parameter device: Provides updated DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias UpdateDeviceHandler = (device:DeviceInfo?, error:ErrorType?) -> Void

    /**
     Update the details of an existing device
     (For optional? parameters use nil if field doesn't need to be updated) //TODO: consider adding default nil value

     - parameter deviceId:          device id
     - parameter userId:            user id
     - parameter firmwareRevision?: firmware revision
     - parameter softwareRevision?: software revision
     - parameter completion:        UpdateDeviceHandler closure
     */
    @available(*, deprecated=1.0) public func updateDevice(deviceId deviceId:String, userId:String, firmwareRevision:String?, softwareRevision:String?,
                      completion:UpdateDeviceHandler)
    {
        var paramsArray = [AnyObject]()
        if let firmwareRevision = firmwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/firmwareRevision", "value" : firmwareRevision])
        }
    
        if let softwareRevision = softwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/softwareRevision", "value" : softwareRevision])
        }
        
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let params = ["params" : paramsArray]
                let request = self._manager.request(.PATCH, "\(API_BASE_URL)/users/\(userId)/devices/\(deviceId)", parameters: params, encoding: .Custom({
                    (convertible, params) in
                    let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                    let jsondata = try? NSJSONSerialization.dataWithJSONObject(params!["params"]!, options: NSJSONWritingOptions(rawValue: 0))
                    if let jsondata = jsondata {
                        mutableRequest.HTTPBody = jsondata
                        mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                    return (mutableRequest, nil)
                }), headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        (response: Response<DeviceInfo, NSError>) -> Void in
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                
                                completion(device:nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                
                                completion(device:resultValue, error:response.result.error)
                            }
                            else
                            {
                                completion(device: nil, error: NSError.unhandledError(RestClient.self))
                            }
                        })
                    })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(device: nil, error: error)
                })
            }
        }
    }

    /**
    Completion handler

    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DeleteDeviceHandler = (error:ErrorType?) -> Void

    /**
     Delete a single device
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeleteDeviceHandler closure
     */
    @available(*, deprecated=1.0) public func deleteDevice(deviceId deviceId:String, userId:String, completion:DeleteDeviceHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.DELETE, "\(API_BASE_URL)/users/\(userId)/devices/\(deviceId)", parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseString
                {
                    (response:Response<String, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                            () -> Void in
                            completion(error:response.result.error)
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(error: error)
                })
            }
        }
    }

    // MARK: Commits

    /**
     Completion handler

     - parameter commits: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
    */
    public typealias CommitsHandler = (commits:ResultCollection<Commit>?, error:ErrorType?)->Void
    
    /**
     Retrieves a collection of all events that should be committed to this device
     
     - parameter deviceId:     device id
     - parameter userId:       user id
     - parameter commitsAfter: the last commit successfully applied. Query will return all subsequent commits which need to be applied.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CommitsHandler closure
     */
    @available(*, deprecated=1.0) public func commits(deviceId deviceId:String, userId:String, commitsAfter:String, limit:Int, offset:Int,
        completion:CommitsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "limit" : "\(limit)",
                    "offset" : "\(offset)"
                ]
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/devices/\(deviceId)/commits", parameters: parameters, encoding: .URL, headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        (response: Response<ResultCollection<Commit>, NSError>) -> Void in
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                
                                completion(commits: nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                completion(commits: resultValue, error: response.result.error)
                            }
                            else
                            {
                                completion(commits: nil, error: NSError.unhandledError(RestClient.self))
                            }
                        })
                    })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(commits: nil, error: error)
                })
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter commit:    Provides Commit object, or nil if error occurs
     - parameter error:     Provides error object, or nil if no error occurs
     */
    public typealias CommitHandler = (commit:Commit?, error:ErrorType?)->Void
    
    /**
     Retrieves an individual commit
     
     - parameter commitId:   commit id
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: CommitHandler closure
     */
    @available(*, deprecated=1.0) public func commit(commitId commitId:String, deviceId:String, userId:String, completion:CommitHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/devices/\(deviceId)/commits/\(commitId)", parameters: nil, encoding: .URL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<Commit, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(commit: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(commit: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(commit: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(commit: nil, error: error)
                })
            }
        }
    }

    // MARK: Transactions

    /**
     Completion handler

     - parameter transactions: Provides ResultCollection<Transaction> object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
    */
    public typealias TransactionsHandler = (transactions:ResultCollection<Transaction>?, error:ErrorType?)->Void

    /**
     Provides a transaction history (if available) for the user, results are limited by provider.
     
     - parameter userId:     user id
     - parameter cardId:     card id
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: TransactionsHandler closure
     */
    @available(*, deprecated=1.0) public func transactions(userId userId:String, cardId:String, limit:Int, offset:Int, completion:TransactionsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "limit" : "\(limit)",
                    "offset" : "\(offset)"
                ]
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/creditCards/\(cardId)/transactions", parameters: parameters, encoding: .URL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<ResultCollection<Transaction>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(transactions: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(transactions: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(transactions: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(transactions: nil, error: error)
                })
            }
        }
    }

    /**
     Completion handler

     - parameter transaction: Provides Transaction object, or nil if error occurs
     - parameter error:       Provides error object, or nil if no error occurs
     */
    public typealias TransactionHandler = (transaction:Transaction?, error:ErrorType?)->Void

    /**
     Get a single transaction
     
     - parameter transactionId: transaction id
     - parameter userId:        user id
     - parameter cardId:        card id
     - parameter completion:    TransactionHandler closure
     */
    @available(*, deprecated=1.0) public func transaction(transactionId transactionId:String, userId:String, cardId:String, completion:TransactionHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.GET, "\(API_BASE_URL)/users/\(userId)/creditCards/\(cardId)/transactions/\(transactionId)", parameters: nil, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response: Response<Transaction, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(transaction: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            completion(transaction: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(transaction: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(transaction: nil, error: error)
                })
            }
        }
    }

    // MARK: APDU Packages

    /**
     Completion handler
    
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    public typealias ConfirmAPDUPackageHandler = (error:ErrorType?)->Void

    /**
     Endpoint to allow for returning responses to APDU execution
     
     - parameter package:    ApduPackage object
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    public func confirmAPDUPackage(package:ApduPackage, completion: ConfirmAPDUPackageHandler)
    {
        guard package.packageId != nil else {
            completion(error:NSError.error(code: ErrorCode.BadRequest, domain: RestClient.self, message: "packageId should not be nil"))
            return
        }
        
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.POST, "\(API_BASE_URL)/apduPackages/\(package.packageId!)/confirm", parameters: package.dictoinary, encoding: .JSON, headers: headers)
                request.validate().responseString
                {
                    (response:Response<String, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(error:response.result.error)
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(error: error)
                })
            }
        }
    }

    // MARK: Assets

    /**
     Completion handler

     - parameter asset: Provides Asset object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias AssetsHandler = (asset:Asset?, error:ErrorType?)->Void

    /**
     Retrieve an individual asset (i.e. terms and conditions)
     
     - parameter adapterData: adapter data
     - parameter adapterId:   adapter id
     - parameter assetId:     asset id
     - parameter completion:  AssetsHandler closure
     */
    public func assets(adapterData adapterData:String, adapterId:String, assetId:String, completion:AssetsHandler)
    {
        let patameters = ["adapterData" : adapterData, "adapterId" : adapterId, "assetId" : assetId]
        
        let request = self._manager.request(.GET, API_BASE_URL + "/assets", parameters: patameters, encoding: .URL, headers: nil)
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        {
            () -> Void in
            request.responseData
            {
                (response:Response<NSData, NSError>) -> Void in
                if let resultError = response.result.error
                {
                    let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(asset: nil, error: error)
                    })
                }
                else if let resultValue = response.result.value
                {
                    var asset:Asset?
                    if let image = UIImage(data: resultValue)
                    {
                        asset = Asset(image: image)
                    }
                    else if let string = resultValue.UTF8String
                    {
                        asset = Asset(text: string)
                    }
                    else
                    {
                        asset = Asset(data: resultValue)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(asset: asset, error: nil)
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(asset: nil, error: NSError.unhandledError(RestClient.self))
                    })
                }
            }
                
        })
        
        
        
        
    }

    // MARK: EncryptionKeys

    /**
     Completion handler

     - parameter encryptionKey?: Provides created EncryptionKey object, or nil if error occurs
     - parameter error?:         Provides error object, or nil if no error occurs
     */
    internal typealias CreateEncryptionKeyHandler = (encryptionKey:EncryptionKey?, error:ErrorType?)->Void

    /**
     Creates a new encryption key pair
     
     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    internal func createEncryptionKey(clientPublicKey clientPublicKey:String, completion:CreateEncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let parameters = [
                "clientPublicKey" : clientPublicKey
        ]

        let request = _manager.request(.POST, API_BASE_URL + "/config/encryptionKeys", parameters: parameters, encoding:.JSON, headers: headers)
        request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            (response: Response<EncryptionKey, NSError>) -> Void in

            dispatch_async(dispatch_get_main_queue(),
            { () -> Void in
                
                if let resultError = response.result.error
                {
                    let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                    
                    completion(encryptionKey:nil, error: error)
                }
                else if let resultValue = response.result.value
                {
                    completion(encryptionKey:resultValue, error:response.result.error)
                }
                else
                {
                    completion(encryptionKey: nil, error: NSError.unhandledError(RestClient.self))
                }
            })
        }
    }

    /**
     Completion handler

     - parameter encryptionKey?: Provides EncryptionKey object, or nil if error occurs
     - parameter error?:         Provides error object, or nil if no error occurs
     */
    internal typealias EncryptionKeyHandler = (encryptionKey:EncryptionKey?, error:ErrorType?)->Void

    /**
     Retrieve and individual key pair
     
     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    internal func encryptionKey(keyId:String, completion:EncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let request = _manager.request(.GET, API_BASE_URL + "/config/encryptionKeys/" + keyId, parameters: nil, encoding:.JSON, headers: headers)
        request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            (response: Response<EncryptionKey, NSError>) -> Void in
            
            dispatch_async(dispatch_get_main_queue(),
            { () -> Void in

                if let resultError = response.result.error
                {
                    let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                    
                    completion(encryptionKey:nil, error: error)
                }
                else if let resultValue = response.result.value
                {
                    completion(encryptionKey:resultValue, error:nil)
                }
                else
                {
                    completion(encryptionKey: nil, error: NSError.unhandledError(RestClient.self))
                }
            })
        }
        
    }

    /**
     Completion handler
     
     - parameter error?: Provides error object, or nil if no error occurs
     */
    internal typealias DeleteEncryptionKeyHandler = (error:ErrorType?)->Void
    
    /**
     Deletes encryption key
     
     - parameter keyId:      key id
     - parameter completion: DeleteEncryptionKeyHandler
     */
    internal func deleteEncryptionKey(keyId:String, completion:DeleteEncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let request = _manager.request(.DELETE, API_BASE_URL + "/config/encryptionKeys/" + keyId, parameters: nil, encoding:.JSON, headers: headers)
        request.validate().responseString
        {
            (response:Response<String, NSError>) -> Void in
            dispatch_async(dispatch_get_main_queue(),
            {
                () -> Void in
                completion(error:response.result.error)
            })
        }
    }
    
    typealias CreateKeyIfNeeded = CreateEncryptionKeyHandler
    
    private func createKeyIfNeeded(completion: CreateKeyIfNeeded)
    {
        if let key = self.key
        {
            completion(encryptionKey: key, error: nil)
        }
        else
        {
            self.createEncryptionKey(clientPublicKey: self.keyPair.publicKey!, completion:
            {
                [unowned self](encryptionKey, error) -> Void in
                
                if let error = error
                {
                    completion(encryptionKey:nil, error:error)
                }
                else if let encryptionKey = encryptionKey
                {
                    self.key = encryptionKey
                    completion(encryptionKey: self.key, error: nil)
                }
            })
        }
    }

    
    // MARK: Request Signature Helpers
    typealias CreateAuthHeaders = (headers:[String:String]?, error:ErrorType?) -> Void
    private func createAuthHeaders(completion:CreateAuthHeaders)
    {
        if self._session.isAuthorized
        {
            completion(headers:["Authorization" : "Bearer " + self._session.accessToken!], error:nil)
        }
        else
        {
            completion(headers: nil, error: NSError.error(code: ErrorCode.Unauthorized, domain: RestClient.self, message: "\(ErrorCode.Unauthorized)"))
        }
    }
    

    typealias PrepareAuthAndKeyHeaders = (headers:[String:String]?, error:ErrorType?) -> Void
    private func prepareAuthAndKeyHeaders(completion:PrepareAuthAndKeyHeaders)
    {
        self.createAuthHeaders
        {
            [unowned self](headers, error) -> Void in
            
            if let error = error
            {
                completion(headers:nil, error:error)
            }
            else
            {
                self.createKeyIfNeeded(
                {
                    (encryptionKey, keyError) -> Void in
                    
                    if let keyError = keyError
                    {
                        completion(headers:nil, error: keyError)
                    }
                    else
                    {
                        completion(headers: headers! + [RestClient.fpKeyIdKey : encryptionKey!.keyId!], error: nil)
                    }
                })
            }
            
        }
    }
    
    // MARK: Hypermedia-driven implementation
    
    // MARK: Credit Card
    internal func createCreditCard(url:String, pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
        street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
        completion:CreateCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                var parameters:[String : String] = [:]
                
                let rawCard = [
                    "pan" : pan,
                    "expMonth" : expMonth,
                    "expYear" : expYear,
                    "cvv" : cvv,
                    "name" : name,
                    "address" : [
                        "street1" : street1,
                        "street2" : street2,
                        "street3" : street3,
                        "city" : city,
                        "state" : state,
                        "postalCode" : postalCode,
                        "country" : country
                    ]
                    ] as [String : AnyObject]
                
                if let cardJSON = rawCard.JSONString
                {
                    if let jweObject = try? JWEObject.createNewObject("A256GCMKW", enc: "A256GCM", payload: cardJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                    {
                        if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)
                        {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
                
                let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        (response:Response<CreditCard, NSError>) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                completion(creditCard: nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                resultValue.client = self
                                completion(creditCard:resultValue, error: nil)
                            }
                            else
                            {
                                completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(creditCard:nil, error: error)
                })
            }
        }
    }
    
    internal func creditCards(url:String, excludeState:[String], limit:Int, offset:Int, completion:CreditCardsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let parameters:[String : AnyObject] = ["excludeState" : excludeState.joinWithSeparator(","), "limit" : limit, "offest" : offset]
                let request = self._manager.request(.GET, url, parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    (response:Response<ResultCollection<CreditCard>, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(result:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                        resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                        
                            resultValue.client = self
                            
                            completion(result:resultValue, error: nil)
                        }
                        else
                        {
                            completion(result:nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(result:nil, error: error)
                })
            }
        }
    }

    internal func deleteCreditCard(url:String, completion:DeleteCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.DELETE, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseData(
                {
                    (response:Response<NSData, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            completion(error: error)
                        }
                        else if let _ = response.result.value
                        {
                            completion(error: nil)
                        }
                        else
                        {
                            completion(error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    () -> Void in
                    completion(error: error)
                })
            }
        }
    }
    
    internal func updateCreditCard(url:String, name:String?, street1:String?, street2:String?, city:String?, state:String?, postalCode:String?, countryCode:String?, completion:UpdateCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    var operations:[[String : String]] = []
                    
                    var parameters:[String : AnyObject] = [:]
                    
                    if let name = name
                    {
                        operations.append([
                            "op": "replace", "path": "/name", "value" : name
                            ])
                    }
                    
                    if let street1 = street1
                    {
                        operations.append([
                            "op": "replace", "path": "/address/street1", "value" : street1
                            ])
                    }
                    
                    if let street2 = street2
                    {
                        operations.append([
                            "op": "replace", "path": "/address/street2", "value" : street2
                            ])
                    }
                    
                    if let city = city
                    {
                        operations.append([
                            "op": "replace", "path": "/address/city", "value" : city
                            ])
                    }
                    
                    if let state = state
                    {
                        operations.append([
                            "op": "replace", "path": "/address/state", "value" : state
                            ])
                    }
                    
                    if let postalCode = postalCode
                    {
                        operations.append([
                            "op": "replace", "path": "/address/postalCode", "value" : postalCode
                            ])
                    }
                    
                    if let countryCode = countryCode
                    {
                        operations.append([
                            "op": "replace", "path": "/address/countryCode", "value" : countryCode
                            ])
                    }
                    
                    if let updateJSON = operations.JSONString
                    {
                        if let jweObject = try? JWEObject.createNewObject("A256GCMKW", enc: "A256GCM", payload: updateJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                        {
                            if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)!
                            {
                                parameters["encryptedData"] = encrypted
                            }
                        }
                    }
                    
                    let request = self._manager.request(.PATCH, url, parameters: parameters, encoding: .JSON, headers: headers)
                    
                    request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                        {
                            [unowned self](response:Response<CreditCard, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(creditCard:nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                        resultValue.client = self
                                        completion(creditCard:resultValue, error: nil)
                                    }
                                    else
                                    {
                                        completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            completion(creditCard:nil, error: error)
                    })
                }
        }
    }
    
    internal func acceptTerms(url:String, completion:AcceptTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        [unowned self](response:Response<CreditCard, NSError>) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                completion(pending: false, card: nil, error: error)
                            }
                            else if let value = response.result.value
                            {
                                value.client = self
                                completion(pending: false, card: value, error: nil)
                            }
                            else if (response.response != nil && response.response!.statusCode == 202)
                            {
                                completion(pending: true, card: nil, error: nil)
                            }
                            else
                            {
                                completion(pending: false, card: nil, error: NSError.unhandledError(RestClient.self))
                            }
                        })
                    })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(pending: false, card: nil, error: error)
                })
            }
        }
    }
    
    internal func declineTerms(url:String, completion:DeclineTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                    request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                        {
                            (response:Response<CreditCard, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(pending: false, card: nil, error: error)
                                    }
                                    else if let value = response.result.value
                                    {
                                        value.client = self
                                        completion(pending: false, card: value, error: nil)
                                    }
                                    else if (response.response != nil && response.response!.statusCode == 202)
                                    {
                                        completion(pending: true, card: nil, error: nil)
                                    }
                                    else
                                    {
                                        completion(pending: false, card: nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            completion(pending: false, card: nil, error: error)
                    })
                }
        }
    }
    
    internal func selectVerificationType(url:String, completion:SelectVerificationTypeHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        [unowned self](response:Response<VerificationMethod, NSError>) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                completion(pending:false, verificationMethod:nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.client = self
                                completion(pending:false, verificationMethod:resultValue, error: nil)
                            }
                            else
                            {
                                if let statusCode = response.response?.statusCode
                                {
                                    switch statusCode
                                    {
                                    case 202:
                                        completion(pending:true, verificationMethod:nil, error: nil)
                                        
                                    default:
                                        completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                    }
                                }
                                else
                                {
                                    completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                        })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(pending:false, verificationMethod:nil, error: error)
                })
            }
        }
    }
    
    internal func verify(url:String, verificationCode:String, completion:VerifyHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let params = [
                    "verificationCode" : verificationCode
                ]
                
                let request = self._manager.request(.POST, url, parameters: params, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        [](response:Response<VerificationMethod, NSError>) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                completion(pending:false, verificationMethod:nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.client = self
                                completion(pending:false, verificationMethod:resultValue, error: nil)
                            }
                            else
                            {
                                if let statusCode = response.response?.statusCode
                                {
                                    switch statusCode
                                    {
                                    case 202:
                                        completion(pending:true, verificationMethod:nil, error: nil)
                                        
                                    default:
                                        completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                    }
                                }
                                else
                                {
                                    completion(pending:false, verificationMethod:nil, error: NSError.unhandledError(RestClient.self))
                                }
                            }
                        })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        completion(pending:false, verificationMethod:nil, error: error)
                    })
                }
        }
    }
    
    internal func deactivate(url:String, causedBy:CreditCardInitiator, reason:String, completion:DeactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                    let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                    request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                        {
                            [unowned self](response:Response<CreditCard, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(pending:false, creditCard:nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        completion(pending:false, creditCard:resultValue, error: nil)
                                    }
                                    else
                                    {
                                        if let statusCode = response.response?.statusCode
                                        {
                                            switch statusCode
                                            {
                                            case 202:
                                                completion(pending:true, creditCard:nil, error: nil)
                                                
                                            default:
                                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                            }
                                        }
                                        else
                                        {
                                            completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                        }
                                    }
                            })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            completion(pending:false, creditCard:nil, error: error)
                    })
                }
        }
    }
    
    internal func reactivate(url:String, causedBy:CreditCardInitiator, reason:String, completion:ReactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                    let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                    request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                        {
                            [unowned self](response:Response<CreditCard, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(pending:false, creditCard:nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        completion(pending:false, creditCard:resultValue, error: nil)
                                    }
                                    else
                                    {
                                        if let statusCode = response.response?.statusCode
                                        {
                                            switch statusCode
                                            {
                                            case 202:
                                                completion(pending:true, creditCard:nil, error: nil)
                                                
                                            default:
                                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                            }
                                        }
                                        else
                                        {
                                            completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                        }
                                    }
                            })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            completion(pending:false, creditCard:nil, error: error)
                    })
                }
        }
    }
    
    internal func retrieveCreditCard(url:String, completion:CreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                    {
                        [unowned self](response:Response<CreditCard, NSError>) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            if let resultError = response.result.error
                            {
                                let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                completion(creditCard:nil, error: error)
                            }
                            else if let resultValue = response.result.value
                            {
                                resultValue.client = self
                                resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                completion(creditCard:resultValue, error: nil)
                            }
                            else
                            {
                                completion(creditCard:nil, error: NSError.unhandledError(RestClient.self))
                            }
                        })
                    })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(creditCard:nil, error: error)
                })
            }
        }
    }

    internal func makeDefault(url:String, completion:MakeDefaultHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                    request.validate().responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                        {
                            [unowned self](response:Response<CreditCard, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(pending:false, creditCard:nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        completion(pending:false, creditCard:resultValue, error: nil)
                                    }
                                    else
                                    {
                                        if let statusCode = response.response?.statusCode
                                        {
                                            switch statusCode
                                            {
                                            case 202:
                                                completion(pending:true, creditCard:nil, error: nil)
                                                
                                            default:
                                                completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                            }
                                        }
                                        else
                                        {
                                            completion(pending:false, creditCard:nil, error: NSError.unhandledError(RestClient.self))
                                        }
                                    }
                            })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            () -> Void in
                            completion(pending:false, creditCard:nil, error: error)
                    })
                }
        }
        
    }
    
    // MARK: Devices
    public func devices(url:String, limit:Int, offset:Int, completion:DevicesHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "limit" : "\(limit)",
                    "offset" : "\(offset)"
                ]
                let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    [unowned self] (response: Response<ResultCollection<DeviceInfo>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(devices:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            
                            completion(devices:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(devices: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(devices: nil, error: error)
                })
            }
        }
    }

    public func createNewDevice(url:String, deviceType:String, manufacturerName:String, deviceName:String,
        serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
        softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
        secureElementId:String, pairing:String, completion:CreateNewDeviceHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                let params = [
                    "deviceType" : deviceType,
                    "manufacturerName" : manufacturerName,
                    "deviceName" : deviceName,
                    "serialNumber" : serialNumber,
                    "modelNumber" : modelNumber,
                    "hardwareRevision" : hardwareRevision,
                    "firmwareRevision" : firmwareRevision,
                    "softwareRevision" : softwareRevision,
                    "systemId" : systemId,
                    "osName" : osName,
                    "licenseKey" : licenseKey,
                    "bdAddress" : bdAddress,
                    "secureElementId" : secureElementId,
                    "pairingTs" : pairing
                ]
                let request = self._manager.request(.POST, url, parameters: params, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    [unowned self] (response: Response<DeviceInfo, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(device:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(device:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(device: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(device: nil, error: error)
                })
            }
        }
    }
    
    public func deleteDevice(url:String, completion:DeleteDeviceHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.DELETE, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseString
                {
                    (response:Response<String, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        completion(error:response.result.error)
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(error: error)
                })
            }
        }
    }
    
    public func updateDevice(url:String, firmwareRevision:String?, softwareRevision:String?,
        completion:UpdateDeviceHandler)
    {
        var paramsArray = [AnyObject]()
        if let firmwareRevision = firmwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/firmwareRevision", "value" : firmwareRevision])
        }
        
        if let softwareRevision = softwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/softwareRevision", "value" : softwareRevision])
        }
        
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                let params = ["params" : paramsArray]
                let request = self._manager.request(.PATCH, url, parameters: params, encoding: .Custom({
                    (convertible, params) in
                    let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                    let jsondata = try? NSJSONSerialization.dataWithJSONObject(params!["params"]!, options: NSJSONWritingOptions(rawValue: 0))
                    if let jsondata = jsondata {
                        mutableRequest.HTTPBody = jsondata
                        mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                    return (mutableRequest, nil)
                }), headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    [unowned self] (response: Response<DeviceInfo, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        () -> Void in
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(device:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            
                            completion(device:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(device: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(device: nil, error: error)
                })
            }
        }
    }
    
    public func commits(url:String, commitsAfter:String, limit:Int, offset:Int,
        completion:CommitsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                //TODO: commitsAfter make research how to use this property
                let parameters = [
                    "limit" : "\(limit)",
                    "offset" : "\(offset)"
                ]
                let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    [unowned self] (response: Response<ResultCollection<Commit>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(commits: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(commits: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(commits: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(commits: nil, error: error)
                })
            }
        }
    }
    
    // MARK: User
    public func user(url:String, completion:UserHandler)
    {
        self.prepareAuthAndKeyHeaders(
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                    dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler:
                {
                    [unowned self] (response: Response<User, NSError>) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(user:nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(user:resultValue, error:response.result.error)
                        }
                        else
                        {
                            completion(user: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    completion(user: nil, error: error)
                })
            }
        })
    }
}