
import Foundation

protocol RestClient
{
    // MARK: User
    
    /**
     Completion handler
     
     - parameter ResultCollection<User>?: Provides ResultCollection<User> object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias ListUsersHandler = (ResultCollection<User>?, ErrorType?)->Void
    
    /**
      Returns a list of all users that belong to your organization. The customers are returned sorted by creation date, with the most recently created customers appearing first
     
     - parameter limit:      Max number of profiles per page
     - parameter offset:     Start index position for list of entities returned
     - parameter completion: ListUsersHandler closure
     */
    func listUsers(limit limit:Int, offset:Int, completion: ListUsersHandler)
    
    /**
     Completion handler
     
     - parameter [User]?: Provides created User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias CreateUsersHandler = (User?, ErrorType?)->Void
    
    /**
     Creates a new user within your organization
     
     - parameter firstName:  first name of the user
     - parameter lastName:   last name of the user
     - parameter birthDate:  birth date of the user in date format [YYYY-MM-DD]
     - parameter email:      email of the user
     - parameter completion: CreateUsersHandler closure
     */
    func createUser(firstName firstName:String, lastName:String, birthDate:String, email:String, completion:CreateUsersHandler)
    
    /**
     Completion handler
     
     - parameter User?: Provides User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias UserHandler = (User?, ErrorType?)->Void
    
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    func user(id id:String, completion:UserHandler)
    
    /**
     Completion handler
     
     - parameter User?: Provides updated User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias UpdateUserHandler = (User?, ErrorType?)->Void
    
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
    func updateUser(id id:String, firstName:String?, lastName:String?, birthDate:Int?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:UpdateUserHandler)
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeleteUserHandler = (ErrorType?)->Void

    /**
     Delete a single user from your organization
     
     - parameter id:         user id
     - parameter completion: DeleteUserHandler closure
     */
    func deleteUser(id id:String, completion:DeleteUserHandler)

    // MARK: Relationship
    
    /**
     Completion handler

     - parameter Relationship?: Provides Relationship object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias RelationshipHandler = (Relationship?, ErrorType?)->Void

    /**
     Get a single relationship
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   RelationshipHandler closure
     */
    func relationship(userId userId:String, creditCardId:String, deviceId:String, completion:RelationshipHandler)

    /**
     Completion handler

     - parameter Relationship?: Provides created Relationship object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias CreateRelationshipHandler = (Relationship?, ErrorType?)->Void

    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    func createRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:CreateRelationshipHandler)
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeleteRelationshipHandler = (ErrorType?)->Void
    
    /**
     Removes a relationship between a device and a creditCard if it exists
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   DeleteRelationshipHandler closure
     */
    func deleteRelationship(userId userId:String, creditCardId:String, deviceId:String, completion:DeleteRelationshipHandler)

    // MARK: Credit Card

    /**
     Completion handler
     
     - parameter CreditCard?: Provides updated CreditCard object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias AcceptTermsHandler = (CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has accepted the terms and conditions presented when the credit card was first added to the user's profile
    
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   AcceptTermsHandler closure
     */
    func acceptTerms(creditCardId creditCardId:String, userId:String, completion:AcceptTermsHandler)
    
    /**
     Completion handler
     
     - parameter CreditCard?: Provides updated CreditCard object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeclineTermsHandler = (CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has declined the terms and conditions. Once declined the credit card will be in a final state, no other actions may be taken
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   DeclineTermsHandler closure
     */
    func declineTerms(creditCardId creditCardId:String, userId:String, completion:DeclineTermsHandler)

    /**
     Completion handler
     
     - parameter CreditCard?: Provides updated CreditCard object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias MakeDefaultHandler = (CreditCard?, ErrorType?)->Void

    /**
     Mark the credit card as the default payment instrument. If another card is currently marked as the default, the default will automatically transition to the indicated credit card
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   MakeDefaultHandler closure
     */
    func makeDefault(creditCardId creditCardId:String, userId:String, completion:MakeDefaultHandler)

    /**
     Completion handler

     - parameter CreditCard?: Provides deactivated CreditCard object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeactivateHandler = (CreditCard?, ErrorType?)->Void
    
    /**
     Transition the credit card into a deactived state so that it may not be utilized for payment. This link will only be available for qualified credit cards that are currently in an active state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     deactivation initiator
     - parameter reason:       deactivation reason
     - parameter completion:   DeactivateHandler closure
     */
    func deactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:DeactivateHandler)
    
    
    /**
     Completion handler
     
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias ReactivateHandler = (CreditCard?, ErrorType?)->Void

    /**
     Transition the credit card into an active state where it can be utilized for payment. This link will only be available for qualified credit cards that are currently in a deactivated state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     reactivation initiator
     - parameter reason:       reactivation reason
     - parameter completion:   ReactivateHandler closure
     */
    func reactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:ReactivateHandler)


    /**
     Completion handler

     - parameter VerificationType?: Provides VerificationType object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias SelectVerificationTypeHandler = (VerificationType?, ErrorType?)->Void
    
    /**
     When an issuer requires additional authentication to verfiy the identity of the cardholder, this indicates the user has selected the specified verification method by the indicated verificationTypeId
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter completion:         SelectVerificationTypeHandler closure
     */
    func selectVerificationType(creditCardId creditCardId:String, userId:String, verificationTypeId:String, completion:SelectVerificationTypeHandler)
    
    /**
     Completion handler
     
     - parameter VerificationType?: Provides VerificationType object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias VerifyHandler = (VerificationResult?, ErrorType?)->Void
    
    /**
     If a verification method is selected that requires an entry of a pin code, this transition will be available. Not all verification methods will include a secondary verification step through the FitPay API
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter verificationCode:   verification code
     - parameter completion:         VerifyHandler closure
     */
    func verify(creditCardId creditCardId:String, userId:String, verificationTypeId:String, verificationCode:String, completion:VerifyHandler)

    // MARK: Devices
    
    /**
    Completion handler
    
    - parameter ResultCollection<Device>?: Provides ResultCollection<Device> object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias DevicesHandler = (ResultCollection<Device>?, ErrorType?)->Void
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter userId:     user id
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    func devices(userId userId:String, limit:Int, offset:Int, completion:DevicesHandler)

    /**
    Completion handler

    - parameter Device?: Provides created Device object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias CreateNewDeviceHandler = (Device?, ErrorType?)->Void

    /**
     For a single user, create a new device in their profile
     
     - parameter userId:           user id
     - parameter deviceType:       device typr
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
    func createNewDevice(userId userId:String, deviceType:String, manufacturerName:String, deviceName:String,
                         serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
                         softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
                         secureElementId:String, pairing:String, completion:CreateNewDeviceHandler)


}
