
import Foundation
import Alamofire
import AlamofireObjectMapper
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class RestClient : NSObject
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
    public enum ErrorCode : Int, Error, RawIntValue
    {
        case ok = 200
        case badRequest = 400
        case unauthorized = 401
        case requestFailed = 402
        case notFound = 404
        case serverError0 = 500
        case serverError1 = 502
        case serverError2 = 503
        case serverError3 = 504
    }

    fileprivate static let fpKeyIdKey:String = "fp-key-id"

    fileprivate let defaultHeaders = ["Accept" : "application/json"]
    fileprivate var _session:RestSession
    internal var keyPair:SECP256R1KeyPair = SECP256R1KeyPair()

    lazy fileprivate var _manager:SessionManager =
    {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return SessionManager(configuration: configuration)
    }()

    fileprivate var key:EncryptionKey?

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
    public typealias ListUsersHandler = (ResultCollection<User>?, Error?)->Void

    /**
      Returns a list of all users that belong to your organization. The customers are returned sorted by creation date, with the most recently created customers appearing first

     - parameter limit:      Max number of profiles per page
     - parameter offset:     Start index position for list of entities returned
     - parameter completion: ListUsersHandler closure
     */
    open func listUsers(limit:Int, offset:Int, completion: ListUsersHandler)
    {
        //TODO: Implement or remove this
        assertionFailure("unimplemented functionality")
    }

    /**
     Completion handler
     
     - parameter [User]?: Provides created User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias CreateUserHandler = (_ user:User?, _ error:NSError?)->Void
    
    /**
     Creates a new user within your organization
     
     - parameter firstName:  first name of the user
     - parameter lastName:   last name of the user
     - parameter birthDate:  birth date of the user in date format [YYYY-MM-DD]
     - parameter email:      email of the user
     - parameter completion: CreateUserHandler closure
     */
    open func createUser(
        _ email:String, password:String, firstName:String?, lastName:String?, birthDate:String?,
        termsVersion:String?, termsAccepted:String?, origin:String?, originAccountCreated:String?,
        clientId:String, completion:@escaping CreateUserHandler
    ) {
        debugPrint("request create user: \(email)")

        self.preparKeyHeader
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    debugPrint("got headers: \(headers)")
                    var parameters:[String : String] = [:]
                    if (termsVersion != nil) {
                        parameters += ["termsVersion": termsVersion!]
                    }
                    if (termsAccepted != nil) {
                        parameters += ["termsAcceptedTsEpoch": termsAccepted!]
                    }
                    
                    if (origin != nil) {
                        parameters += ["origin": origin!]
                    }
                    
                    if (termsVersion != nil) {
                        parameters += ["originAccountCreatedTsEpoch": originAccountCreated!]
                    }

                    parameters["client_id"] = clientId

                    let rawUserInfo = [
                        "email" : email as AnyObject,
                        "pin" : password as AnyObject
                        ] as [String : AnyObject]
                    if (firstName != nil) {
                        rawUserInfo += ["firstName" : firstName!]
                    }
                    
                    if (lastName != nil) {
                        rawUserInfo += ["lastName" : lastName!]
                    }
                    
                    if (birthDate != nil) {
                        rawUserInfo += ["birthDate" : birthDate!]
                    }
                    
                    if let userInfoJSON = rawUserInfo.JSONString
                    {
                        if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: userInfoJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                        {
                            if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)
                            {
                                parameters["encryptedData"] = encrypted
                            }
                        }
                    }
                    
                    debugPrint("user creation url: \(self._session.baseAPIURL)/users")
                    debugPrint("Headers: \(headers)")
                    debugPrint("user creation json: \(parameters)")
                    
                    let request = self._manager.request(.POST, self._session.baseAPIURL + "/users", parameters: parameters, encoding: .JSON, headers: headers)
                    
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                        {
                            (response:Response<User, NSError>) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    () -> Void in
                                    
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        completion(user: nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                        resultValue.client = self
                                        completion(user:resultValue, error: nil)
                                    }
                                    else
                                    {
                                        completion(user:nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                    })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(nil, error)
                    })
                }
        }
    }
    
    /**
     Completion handler
     
     - parameter user: Provides User object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias UserHandler = (_ user:User?, _ error:NSError?)->Void
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    @objc open func user(id:String, completion:@escaping UserHandler)
    {
        self.prepareAuthAndKeyHeaders(
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, self._session.baseAPIURL + "/users/" + id, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                    () -> Void in
                    completion(nil, error)
                })
            }
            
        })
    }
    
    /**
     Completion handler
     
     - parameter User?: Provides updated User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias UpdateUserHandler = (_ user:User?, _ error:NSError?)->Void
    
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
    internal func updateUser(_ url:String, firstName:String?, lastName:String?, birthDate:String?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:@escaping UpdateUserHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                (headers, error) -> Void in
                if let headers = headers
                {
                    
                    var operations = [AnyObject]()
                    
                    if let firstName = firstName
                    {
                        operations.append(["op": "replace", "path": "/firstName", "value": firstName])
                    }
                    
                    if let lastName = lastName
                    {
                        operations.append(["op": "replace", "path": "/lastName", "value": lastName])
                    }
                    
                    if let birthDate = birthDate
                    {
                        operations.append(["op": "replace", "path": "/birthDate", "value": birthDate])
                    }
                    
                    if let originAccountCreated = originAccountCreated
                    {
                        operations.append(["op": "replace", "path": "/originAccountCreatedTs", "value": originAccountCreated])
                    }
                    
                    if let termsAccepted = termsAccepted
                    {
                        operations.append(["op": "replace", "path": "/termsAcceptedTs", "value": termsAccepted])
                    }
                    
                    if let termsVersion = termsVersion
                    {
                        operations.append(["op": "replace", "path": "/termsVersion", "value": termsVersion])
                    }
                    
                    var parameters = [String:AnyObject]()
                    
                    if let updateJSON = operations.JSONString
                    {
                        if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: updateJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                        {
                            if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)!
                            {
                                parameters["encryptedData"] = encrypted
                            }
                        }
                    }

                    let request = self._manager.request(.PATCH, url, parameters: parameters, encoding: .JSON, headers: headers)
                    request.validate().responseObject(
                        queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    completion(nil, error)
                }
        }

    }
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias DeleteUserHandler = (_ error:NSError?)->Void

    /**
     Delete a single user from your organization
     
     - parameter id:         user id
     - parameter completion: DeleteUserHandler closure
     */
    internal func deleteUser(_ url:String, completion:@escaping DeleteUserHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.DELETE, url, parameters: nil, encoding: .URLEncodedInURL, headers: headers)
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
                completion(error)
            }
        }
    }
    
    
    /**
     Completion handler

     - parameter relationship: Provides created Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias CreateRelationshipHandler = (_ relationship:Relationship?, _ error:NSError?)->Void

    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    internal func createRelationship(_ url:String, creditCardId:String, deviceId:String, completion:@escaping CreateRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let parameters = [
                    "creditCardId" : "\(creditCardId)",
                    "deviceId" : "\(deviceId)"
                ]
                let request = self._manager.request(.PUT, url + "/relationships", parameters: parameters, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                            resultValue.client = self
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
                completion(nil, error)
            }
        }
    }
    
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeleteRelationshipHandler = (_ error:NSError?)->Void
    
    /**
    Completion handler
    
    - parameter creditCard: Provides credit card object, or nil if error occurs
    - parameter error:      Provides error object, or nil if no error occurs
    */
    public typealias CreateCreditCardHandler = (_ creditCard:CreditCard?, _ error:NSError?)->Void
    
    /**
    Completion handler
    
    - parameter result: Provides collection of credit cards, or nil if error occurs
    - parameter error:  Provides error object, or nil if no error occurs
    */
    public typealias CreditCardsHandler = (_ result:ResultCollection<CreditCard>?, _ error:NSError?) -> Void

    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias CreditCardHandler = (_ creditCard:CreditCard?, _ error:NSError?)->Void
        
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeleteCreditCardHandler = (_ error:NSError?)->Void
    
    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias UpdateCreditCardHandler = (_ creditCard:CreditCard?, _ error:NSError?) -> Void
    
    /**
     Completion handler

     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card?:   Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error?:  Provides error object, or nil if no error occurs
     */
    public typealias AcceptTermsHandler = (_ pending:Bool, _ card:CreditCard?, _ error:NSError?)->Void
    
    /**
     Completion handler
     
     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card:    Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
     */
    public typealias DeclineTermsHandler = (_ pending:Bool, _ card:CreditCard?, _ error:NSError?)->Void
    
    /**
     Completion handler

     - parameter pending:     Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard:  Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:       Provides error object, or nil if no error occurs
     */
    public typealias MakeDefaultHandler = (_ pending:Bool, _ creditCard:CreditCard?, _ error:NSError?)->Void

    /**
     Completion handler

     - parameter pending:    Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard: Provides deactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:      Provides error object, or nil if no error occurs
     */
    public typealias DeactivateHandler = (_ pending:Bool, _ creditCard:CreditCard?, _ error:NSError?)->Void
    
    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias ReactivateHandler = (_ pending:Bool, _ creditCard:CreditCard?, _ error:NSError?)->Void

    /**
     Completion handler
     - parameter pending:             Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod:  Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:               Provides error object, or nil if no error occurs
     */
    public typealias SelectVerificationTypeHandler = (_ pending:Bool, _ verificationMethod:VerificationMethod?, _ error:NSError?)->Void
    
    /**
     Completion handler
     
     - parameter pending:            Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    public typealias VerifyHandler = (_ pending:Bool, _ verificationMethod:VerificationMethod?, _ error:NSError?)->Void
    
    /**
     Completion handler
     
     - parameter relationship: Provides Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias RelationshipHandler = (_ relationship:Relationship?, _ error:NSError?)->Void
    
    /**
    Completion handler
    
    - parameter result: Provides ResultCollection<DeviceInfo> object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DevicesHandler = (_ result:ResultCollection<DeviceInfo>?, _ error:NSError?)->Void
    
    /**
    Completion handler

    - parameter device: Provides created DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias CreateNewDeviceHandler = (_ device:DeviceInfo?, _ error:NSError?)->Void

    /**
    Completion handler

    - parameter device: Provides existing DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DeviceHandler = (_ device:DeviceInfo?, _ error:NSError?) -> Void
    
    /**
    Completion handler

    - parameter device: Provides updated DeviceInfo object, or nil if error occurs
    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias UpdateDeviceHandler = (_ device:DeviceInfo?, _ error:NSError?) -> Void

    /**
    Completion handler

    - parameter error: Provides error object, or nil if no error occurs
    */
    public typealias DeleteDeviceHandler = (_ error:NSError?) -> Void

    /**
     Completion handler

     - parameter commits: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
    */
    public typealias CommitsHandler = (_ result:ResultCollection<Commit>?, _ error:NSError?)->Void
    
    /**
     Completion handler
     
     - parameter commit:    Provides Commit object, or nil if error occurs
     - parameter error:     Provides error object, or nil if no error occurs
     */
    public typealias CommitHandler = (_ commit:Commit?, _ error:Error?)->Void
    
    /**
     Completion handler

     - parameter transactions: Provides ResultCollection<Transaction> object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
    */
    public typealias TransactionsHandler = (_ result:ResultCollection<Transaction>?, _ error:NSError?)->Void

    /**
     Completion handler

     - parameter transaction: Provides Transaction object, or nil if error occurs
     - parameter error:       Provides error object, or nil if no error occurs
     */
    public typealias TransactionHandler = (_ transaction:Transaction?, _ error:NSError?)->Void

    /**
     Completion handler
    
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    public typealias ConfirmAPDUPackageHandler = (_ error:NSError?)->Void

    /**
     Endpoint to allow for returning responses to APDU execution
     
     - parameter package:    ApduPackage object
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    open func confirmAPDUPackage(_ url:String, package:ApduPackage, completion: @escaping ConfirmAPDUPackageHandler)
    {
        guard package.packageId != nil else {
            completion(NSError.error(code: ErrorCode.badRequest, domain: RestClient.self, message: "packageId should not be nil"))
            return
        }
        
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.POST, url, parameters: package.responseDictionary, encoding: .JSON, headers: headers)
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
                DispatchQueue.main.async(execute: {
                    completion(error)
                })
            }
        }
    }

    /**
     Completion handler

     - parameter asset: Provides Asset object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias AssetsHandler = (_ asset:Asset?, _ error:NSError?)->Void

    // MARK: EncryptionKeys

    /**
     Completion handler

     - parameter encryptionKey?: Provides created EncryptionKey object, or nil if error occurs
     - parameter error?:         Provides error object, or nil if no error occurs
     */
    internal typealias CreateEncryptionKeyHandler = (_ encryptionKey:EncryptionKey?, _ error:NSError?)->Void

    /**
     Creates a new encryption key pair
     
     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    internal func createEncryptionKey(clientPublicKey:String, completion:@escaping CreateEncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let parameters = [
                "clientPublicKey" : clientPublicKey
        ]

        let request = _manager.request(.POST, self._session.baseAPIURL + "/config/encryptionKeys", parameters: parameters, encoding:.JSON, headers: headers)
        request.validate().responseObject(queue: dispatch_get_global_queue( DispatchQueue.GlobalQueuePriority.default, 0))
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
    internal typealias EncryptionKeyHandler = (_ encryptionKey:EncryptionKey?, _ error:NSError?)->Void

    /**
     Retrieve and individual key pair
     
     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    internal func encryptionKey(_ keyId:String, completion:@escaping EncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let request = _manager.request(.GET, self._session.baseAPIURL + "/config/encryptionKeys/" + keyId, parameters: nil, encoding:.JSON, headers: headers)
        request.validate().responseObject(queue: dispatch_get_global_queue( DispatchQueue.GlobalQueuePriority.default, 0))
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
    internal typealias DeleteEncryptionKeyHandler = (_ error:Error?)->Void
    
    /**
     Deletes encryption key
     
     - parameter keyId:      key id
     - parameter completion: DeleteEncryptionKeyHandler
     */
    internal func deleteEncryptionKey(_ keyId:String, completion:@escaping DeleteEncryptionKeyHandler)
    {
        let headers = self.defaultHeaders
        let request = _manager.request(.DELETE, self._session.baseAPIURL + "/config/encryptionKeys/" + keyId, parameters: nil, encoding:.JSON, headers: headers)
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
    
    typealias CreateKeyIfNeededHandler = CreateEncryptionKeyHandler
    
    fileprivate func createKeyIfNeeded(_ completion: @escaping CreateKeyIfNeededHandler)
    {
        if let key = self.key
        {
            completion(key, nil)
        }
        else
        {
            self.createEncryptionKey(clientPublicKey: self.keyPair.publicKey!, completion:
            {
                [unowned self](encryptionKey, error) -> Void in
                
                if let error = error
                {
                    completion(nil, error)
                }
                else if let encryptionKey = encryptionKey
                {
                    self.key = encryptionKey
                    completion(self.key, nil)
                }
            })
        }
    }

    
    // MARK: Request Signature Helpers
    typealias CreateAuthHeaders = (_ headers:[String:String]?, _ error:NSError?) -> Void

    fileprivate func createAuthHeaders(_ completion:CreateAuthHeaders)
    {
        if self._session.isAuthorized
        {
            completion(["Authorization" : "Bearer " + self._session.accessToken!], nil)
        }
        else
        {
            completion(nil, NSError.error(code: ErrorCode.unauthorized, domain: RestClient.self, message: "\(ErrorCode.unauthorized)"))
        }
    }
 
    fileprivate func skipAuthHeaders(_ completion:CreateAuthHeaders)
    {
        // do nothing
        completion(self.defaultHeaders, nil)
    }


    typealias PrepareAuthAndKeyHeaders = (_ headers:[String:String]?, _ error:NSError?) -> Void
    fileprivate func prepareAuthAndKeyHeaders(_ completion:@escaping PrepareAuthAndKeyHeaders)
    {
        self.createAuthHeaders
        {
            [unowned self](headers, error) -> Void in
            
            if let error = error
            {
                completion(nil, error)
            }
            else
            {
                self.createKeyIfNeeded(
                {
                    (encryptionKey, keyError) -> Void in
                    
                    if let keyError = keyError
                    {
                        completion(nil, keyError)
                    }
                    else
                    {
                        completion(headers! + [RestClient.fpKeyIdKey : encryptionKey!.keyId!], nil)
                    }
                })
            }
            
        }
    }
    
    typealias PrepareKeyHeader = (_ headers:[String:String]?, _ error:NSError?) -> Void

    fileprivate func preparKeyHeader(_ completion:@escaping PrepareAuthAndKeyHeaders)
    {
        self.skipAuthHeaders
            {
                [unowned self](headers, error) -> Void in
                
                if let error = error
                {
                    completion(nil, error)
                }
                else
                {
                    self.createKeyIfNeeded(
                        {
                            (encryptionKey, keyError) -> Void in
                            
                            if let keyError = keyError
                            {
                                completion(nil, keyError)
                            }
                            else
                            {
                                completion(headers! + [RestClient.fpKeyIdKey : encryptionKey!.keyId!], nil)
                            }
                    })
                }
                
        }
    }

    
    // MARK: Hypermedia-driven implementation
    
    // MARK: Credit Card
    internal func createCreditCard(_ url:String, pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
        street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
        completion:@escaping CreateCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                var parameters:[String : String] = [:]
                
                let rawCard = [
                    "pan" : pan as AnyObject,
                    "expMonth" : expMonth as AnyObject,
                    "expYear" : expYear as AnyObject,
                    "cvv" : cvv as AnyObject,
                    "name" : name as AnyObject,
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
                    if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: cardJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                    {
                        if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)
                        {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
                
                let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                
                request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                        () -> Void in
                        completion(nil, error)
                })
            }
        }
    }

    internal func creditCards(_ url:String, excludeState:[String], limit:Int, offset:Int, completion:@escaping CreditCardsHandler)
    {
        let parameters:[String : AnyObject] = ["excludeState" : excludeState.joined(separator: ",") as AnyObject, "limit" : limit as AnyObject, "offest" : offset as AnyObject]
        self.creditCards(url, parameters: parameters, completion: completion)
    }
    
    internal func creditCards(_ url:String, parameters:[String:AnyObject]?, completion:@escaping CreditCardsHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                    
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(nil, error)
                    })
                }
        }
    }

    internal func deleteCreditCard(_ url:String, completion:@escaping DeleteCreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.DELETE, url, parameters: nil, encoding: .URL, headers: headers)
                request.validate().responseData(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                    () -> Void in
                    completion(error)
                })
            }
        }
    }
    
    internal func updateCreditCard(_ url:String, name:String?, street1:String?, street2:String?, city:String?, state:String?, postalCode:String?, countryCode:String?, completion:@escaping UpdateCreditCardHandler)
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
                        if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: updateJSON, keyId:headers[RestClient.fpKeyIdKey]!)
                        {
                            if let encrypted = try? jweObject?.encrypt(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!)!
                            {
                                parameters["encryptedData"] = encrypted
                            }
                        }
                    }
                    
                    let request = self._manager.request(.PATCH, url, parameters: parameters, encoding: .JSON, headers: headers)
                    
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(nil, error)
                    })
                }
        }
    }
    
    internal func acceptTerms(_ url:String, completion:@escaping AcceptTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                        () -> Void in
                        completion(false, nil, error)
                })
            }
        }
    }
    
    internal func declineTerms(_ url:String, completion:@escaping DeclineTermsHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(false, nil, error)
                    })
                }
        }
    }
    
    internal func selectVerificationType(_ url:String, completion:@escaping SelectVerificationTypeHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                        completion(false, nil, error)
                })
            }
        }
    }
    
    internal func verify(_ url:String, verificationCode:String, completion:@escaping VerifyHandler)
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
                request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                        completion(false, nil, error)
                    })
                }
        }
    }
    
    internal func deactivate(_ url:String, causedBy:CreditCardInitiator, reason:String, completion:@escaping DeactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                    let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(false, nil, error)
                    })
                }
        }
    }
    
    internal func reactivate(_ url:String, causedBy:CreditCardInitiator, reason:String, completion:@escaping ReactivateHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let parameters = ["causedBy" : causedBy.rawValue, "reason" : reason]
                    let request = self._manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(false, nil, error)
                    })
                }
        }
    }
    
    internal func retrieveCreditCard(_ url:String, completion:@escaping CreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            [unowned self](headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                        () -> Void in
                        completion(nil, error)
                })
            }
        }
    }

    internal func makeDefault(_ url:String, completion:@escaping MakeDefaultHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self](headers, error) -> Void in
                if let headers = headers
                {
                    let request = self._manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
                    request.validate().responseObject(queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(false, nil, error)
                    })
                }
        }
        
    }
    
    // MARK: Devices
    internal func devices(_ url:String, limit:Int, offset:Int, completion:@escaping DevicesHandler)
    {
        let parameters = [
            "limit" : "\(limit)",
            "offset" : "\(offset)"
        ]

        self.devices(url, parameters: parameters as [String : AnyObject]?, completion: completion)
    }
    
    internal func devices(_ url:String, parameters:[String : AnyObject]?, completion:@escaping DevicesHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self] (headers, error) -> Void in
                if let headers = headers {
                    
                    let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                    request.validate().responseObject(
                        queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                        {
                            [unowned self] (response: Response<ResultCollection<DeviceInfo>, NSError>) -> Void in
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        
                                        completion(result:nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                        
                                        completion(result:resultValue, error:response.result.error)
                                    }
                                    else
                                    {
                                        completion(result: nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                        })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        completion(nil, error)
                    })
                }
        }
    }


    internal func createNewDevice(_ url:String, deviceType:String, manufacturerName:String, deviceName:String,
        serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
        softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
        secureElementId:String, pairing:String, completion:@escaping CreateNewDeviceHandler)
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
                    "secureElement" : [
                        "secureElementId" : secureElementId
                    ],
                    "pairingTs" : pairing
                ] as [String : Any]
                let request = self._manager.request(.POST, url, parameters: params as? [String : AnyObject], encoding: .JSON, headers: headers)
                request.validate().responseObject(
                queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        }
    }
    
    internal func deleteDevice(_ url:String, completion:@escaping DeleteDeviceHandler)
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
                DispatchQueue.main.async(execute: {
                    completion(error)
                })
            }
        }
    }
    
    internal func updateDevice(_ url:String, firmwareRevision:String?, softwareRevision:String?, notifcationToken: String?,
        completion:@escaping UpdateDeviceHandler)
    {
        var paramsArray = [AnyObject]()
        if let firmwareRevision = firmwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/firmwareRevision", "value" : firmwareRevision])
        }
        
        if let softwareRevision = softwareRevision {
            paramsArray.append(["op" : "replace", "path" : "/softwareRevision", "value" : softwareRevision])
        }
        
        if let notifcationToken = notifcationToken {
            paramsArray.append(["op" : "replace", "path" : "/notifcationToken", "value" : notifcationToken])
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
                    queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        }
    }
    
    internal func addDeviceProperty(_ url:String, propertyPath:String, propertyValue:String, completion:@escaping UpdateDeviceHandler) {
        var paramsArray = [AnyObject]()
        paramsArray.append(["op" : "add", "path" : propertyPath, "value" : propertyValue])
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
                        queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                    DispatchQueue.main.async(execute: {
                            completion(nil, error)
                    })
                }
        }
    }
    
    open func commits(_ url:String, commitsAfter:String?, limit:Int, offset:Int,
        completion:@escaping CommitsHandler)
    {
        var parameters = [
            "limit" : "\(limit)",
            "offset" : "\(offset)"
        ]
        
        if (commitsAfter != nil && commitsAfter?.characters.count > 0) {
            parameters["commitsAfter"] = commitsAfter!
        }
        
        self.prepareAuthAndKeyHeaders
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers {
                
                let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                request.validate().responseObject(
                    queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                {
                    [unowned self] (response: Response<ResultCollection<Commit>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(result: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(result: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(result: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        }
    }
    
    internal func commits(_ url:String, parameters:[String : AnyObject]?,
        completion:@escaping CommitsHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                [unowned self] (headers, error) -> Void in
                if let headers = headers {
                    
                    let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                    request.validate().responseObject(
                        queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                        {
                            [unowned self] (response: Response<ResultCollection<Commit>, NSError>) -> Void in
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        
                                        completion(result: nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                                        completion(result: resultValue, error: response.result.error)
                                    }
                                    else
                                    {
                                        completion(result: nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                        })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                            completion(nil, error)
                    })
                }
        }
    }
    
    // MARK: User
    open func user(_ url:String, completion:@escaping UserHandler)
    {
        self.prepareAuthAndKeyHeaders(
        {
            [unowned self] (headers, error) -> Void in
            if let headers = headers
            {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers)
                request.validate().responseObject(
                    queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        })
    }
    
    
    internal func relationship(_ url:String, completion:@escaping RelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .URLEncodedInURL, headers: headers)
                request.validate().responseObject(
                    queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
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
                            resultValue.client = self
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
                completion(nil, error)
            }
        }
    }
    
    internal func deleteRelationship(_ url:String, completion:@escaping DeleteRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.DELETE, url, parameters: nil, encoding: .URLEncodedInURL, headers: headers)
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
                completion(error)
            }
        }
    }

    // MARK: Transactions
    internal func transactions(_ url:String, limit:Int, offset:Int, completion:@escaping TransactionsHandler)
    {
        let parameters = [
            "limit" : "\(limit)",
            "offset" : "\(offset)",
        ]
        
        self.transactions(url, parameters: parameters as [String : AnyObject]?, completion: completion)
    }
    
    internal func transactions(_ url:String, parameters:[String : AnyObject]?, completion:@escaping TransactionsHandler)
    {
        self.prepareAuthAndKeyHeaders
            {
                (headers, error) -> Void in
                if let headers = headers {
                    let request = self._manager.request(.GET, url, parameters: parameters, encoding: .URL, headers: headers)
                    request.validate().responseObject(
                        queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                        {
                            (response: Response<ResultCollection<Transaction>, NSError>) -> Void in
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    if let resultError = response.result.error
                                    {
                                        let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                                        
                                        completion(result: nil, error: error)
                                    }
                                    else if let resultValue = response.result.value
                                    {
                                        resultValue.client = self
                                        completion(result: resultValue, error: response.result.error)
                                    }
                                    else
                                    {
                                        completion(result: nil, error: NSError.unhandledError(RestClient.self))
                                    }
                            })
                    })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                            completion(nil, error)
                    })
                }
        }
    }

    internal func assets(_ url:String, completion:@escaping AssetsHandler)
    {
        let request = self._manager.request(.GET, url, parameters: nil, encoding: .URL, headers: nil)
        
        dispatch_get_global_queue( DispatchQueue.GlobalQueuePriority.default, 0).async(execute: {
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
    
    
    internal func collectionItems<T>(_ url:String, completion:@escaping (_ resultCollection:ResultCollection<T>?, _ error:Error?) -> Void) -> T?
    {
        self.prepareAuthAndKeyHeaders
        {
            (headers, error) -> Void in
            if let headers = headers {
                let request = self._manager.request(.GET, url, parameters: nil, encoding: .URL, headers: headers)
                request.validate().responseObject(
                queue: DispatchQueue.global( DispatchQueue.GlobalQueuePriority.default, 0), completionHandler:
                {
                    (response: Response<ResultCollection<T>, NSError>) -> Void in
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if let resultError = response.result.error
                        {
                            let error = NSError.errorWithData(code: response.response?.statusCode ?? 0, domain: RestClient.self, data: response.data, alternativeError: resultError)
                            
                            completion(resultCollection: nil, error: error)
                        }
                        else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(self.keyPair.generateSecretForPublicKey(self.key!.serverPublicKey!)!, expectedKeyId:headers[RestClient.fpKeyIdKey])
                            completion(resultCollection: resultValue, error: response.result.error)
                        }
                        else
                        {
                            completion(resultCollection: nil, error: NSError.unhandledError(RestClient.self))
                        }
                    })
                })
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        }
        
        return nil
    }
}

/**
 Retrieve an individual asset (i.e. terms and conditions)
 
 - parameter completion:  AssetsHandler closure
 */
public protocol AssetRetrivable
{
    func retrieveAsset(_ completion:RestClient.AssetsHandler)
}
