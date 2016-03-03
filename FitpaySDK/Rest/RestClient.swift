
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
    public func relationship(userId userId:String, creditCardId:String, deviceId:String, completion:RelationshipHandler)
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

     - parameter Relationship?: Provides created Relationship object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias CreateRelationshipHandler = (Relationship?, ErrorType?)->Void

    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    public func createRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:CreateRelationshipHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias DeleteRelationshipHandler = (ErrorType?)->Void
    
    /**
     Removes a relationship between a device and a creditCard if it exists
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   DeleteRelationshipHandler closure
     */
    public func deleteRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:DeleteRelationshipHandler)
    {

    }

    // MARK: Credit Card
    
    /**
    Completion handler
    
    - parameter result: Provides collection of credit cards, or nil if error occurs
    - parameter error:  Provides error object, or nil if no error occurs
    */
    public typealias CreditCardsHandler = (result:ResultCollection<CreditCard>?, error:ErrorType?) -> Void

    public func creditCards(userId userId:String, excludeState:[String], limit:Int, offset:Int, completion:CreditCardsHandler)
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

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType? : Provides error object, or nil if no error occurs
     */
    public typealias AcceptTermsHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has accepted the terms and conditions presented when the credit card was first added to the user's profile
    
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   AcceptTermsHandler closure
     */
    public func acceptTerms(creditCardId creditCardId:String, userId:String, completion:AcceptTermsHandler)
    {
        
    }
    
    /**
     Completion handler
     
     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias DeclineTermsHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has declined the terms and conditions. Once declined the credit card will be in a final state, no other actions may be taken

     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   DeclineTermsHandler closure
     */
    public func declineTerms(creditCardId creditCardId:String, userId:String, completion:DeclineTermsHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias MakeDefaultHandler = (Bool, CreditCard?, ErrorType?)->Void

    /**
     Mark the credit card as the default payment instrument. If another card is currently marked as the default, the default will automatically transition to the indicated credit card
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   MakeDefaultHandler closure
     */
    public func makeDefault(creditCardId creditCardId:String, userId:String, completion:MakeDefaultHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides deactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias DeactivateHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Transition the credit card into a deactived state so that it may not be utilized for payment. This link will only be available for qualified credit cards that are currently in an active state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     deactivation initiator
     - parameter reason:       deactivation reason
     - parameter completion:   DeactivateHandler closure
     */
    public func deactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:DeactivateHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias ReactivateHandler = (CreditCard?, ErrorType?)->Void

    /**
     Transition the credit card into an active state where it can be utilized for payment. This link will only be available for qualified credit cards that are currently in a deactivated state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     reactivation initiator
     - parameter reason:       reactivation reason
     - parameter completion:   ReactivateHandler closure
     */
    public func reactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:ReactivateHandler)
    {

    }

    /**
     Completion handler
     - parameter Bool:                Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter VerificationMethod?: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:          Provides error object, or nil if no error occurs
     */
    public typealias SelectVerificationTypeHandler = (Bool, VerificationMethod?, ErrorType?)->Void
    
    /**
     When an issuer requires additional authentication to verfiy the identity of the cardholder, this indicates the user has selected the specified verification method by the indicated verificationTypeId
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter completion:         SelectVerificationTypeHandler closure
     */
    public func selectVerificationType(creditCardId creditCardId:String, userId:String, verificationTypeId:String, completion:SelectVerificationTypeHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter Bool:                Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter VerificationMethod?: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias VerifyHandler = (Bool, VerificationMethod?, ErrorType?)->Void
    
    /**
     If a verification method is selected that requires an entry of a pin code, this transition will be available. Not all verification methods will include a secondary verification step through the FitPay API
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter verificationCode:   verification code
     - parameter completion:         VerifyHandler closure
     */
    public func verify(creditCardId creditCardId:String, userId:String, verificationTypeId:String, verificationCode:String, completion:VerifyHandler)
    {

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
    public func devices(userId userId:String, limit:Int, offset:Int, completion:DevicesHandler)
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
                completion(devices: nil, error: error)
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
    public func createNewDevice(userId userId:String, deviceType:String, manufacturerName:String, deviceName:String,
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
                completion(device: nil, error: error)
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
    public func device(deviceId deviceId:String, userId:String, completion:DeviceHandler)
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
                completion(device: nil, error: error)
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
    public func updateDevice(deviceId deviceId:String, userId:String, firmwareRevision:String?, softwareRevision:String?,
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
                completion(device: nil, error: error)
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
    public func deleteDevice(deviceId deviceId:String, userId:String, completion:DeleteDeviceHandler)
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
                completion(error: error)
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
    public func commits(deviceId deviceId:String, userId:String, commitsAfter:String, limit:Int, offset:Int,
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
                completion(commits: nil, error: error)
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
    public func commit(commitId commitId:String, deviceId:String, userId:String, completion:CommitHandler)
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
                completion(commit: nil, error: error)
            }
        }
    }

    // MARK: Transactions

    /**
     Completion handler

     - parameter ResultCollection<Commit>?: Provides ResultCollection<Transaction> object, or nil if error occurs
     - parameter ErrorType?:                Provides error object, or nil if no error occurs
    */
    public typealias TransactionsHandler = (ResultCollection<Transaction>?, ErrorType?)->Void

    /**
     Provides a transaction history (if available) for the user, results are limited by provider.
     
     - parameter userId:     user id
     - parameter completion: TransactionsHandler closure
     */
    public func transactions(userId userId:String, completion:TransactionsHandler)
    {

    }

    /**
     Completion handler

     - parameter Transaction?: Provides Transaction object, or nil if error occurs
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    public typealias TransactionHandler = (Transaction?, ErrorType?)->Void

    /**
     Get a single transaction
     
     - parameter transactionId: transaction id
     - parameter userId:        user id
     - parameter completion:    TransactionHandler closure
     */
    public func transaction(transactionId transactionId:String, userId:String, completion:TransactionHandler)
    {

    }

    // MARK: APDU Packages

    /**
     Completion handler
     
     - parameter PackageConfirmation?: Provides PackageConfirmation object, or nil if error occurs
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    public typealias ConfirmAPDUPackageHandler = (ApduPackage?, ErrorType?)->Void

    /**
     Endpoint to allow for returning responses to APDU execution
     
     - parameter packageId:  package id
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    public func confirmAPDUPackage(packageId:String, completion: ConfirmAPDUPackageHandler)
    {

    }

    // MARK: Assets

    /**
     Completion handler

     - parameter AnyObject?: Provides AnyObject (UIImage or String) object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias AssetsHandler = (AnyObject?, ErrorType?)->Void

    /**
     Retrieve an individual asset (i.e. terms and conditions)
     
     - parameter adapterData: adapter data
     - parameter adapterId:   adapter id
     - parameter assetId:     asset id
     - parameter completion:  AssetsHandler closure
     */
    public func assets(adapterData:String, adapterId:String, assetId:String, completion:AssetsHandler)
    {
        
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
}