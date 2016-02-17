
import Foundation

class RestClient
{
    private var _session:RestSession

    init(session:RestSession)
    {
        _session = session;
    }

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
    {

    }
    
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
    {

    }
    
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
    {

    }
    
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
    {

    }
    
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
    {

    }

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
    {

    }

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
    {

    }
    
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
    {

    }

    // MARK: Credit Card

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType? : Provides error object, or nil if no error occurs
     */
    typealias AcceptTermsHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has accepted the terms and conditions presented when the credit card was first added to the user's profile
    
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   AcceptTermsHandler closure
     */
    func acceptTerms(creditCardId creditCardId:String, userId:String, completion:AcceptTermsHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    typealias DeclineTermsHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Indicates a user has declined the terms and conditions. Once declined the credit card will be in a final state, no other actions may be taken

     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   DeclineTermsHandler closure
     */
    func declineTerms(creditCardId creditCardId:String, userId:String, completion:DeclineTermsHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    typealias MakeDefaultHandler = (Bool, CreditCard?, ErrorType?)->Void

    /**
     Mark the credit card as the default payment instrument. If another card is currently marked as the default, the default will automatically transition to the indicated credit card
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter completion:   MakeDefaultHandler closure
     */
    func makeDefault(creditCardId creditCardId:String, userId:String, completion:MakeDefaultHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides deactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    typealias DeactivateHandler = (Bool, CreditCard?, ErrorType?)->Void
    
    /**
     Transition the credit card into a deactived state so that it may not be utilized for payment. This link will only be available for qualified credit cards that are currently in an active state.
     
     - parameter creditCardId: credit card id
     - parameter userId:       user id
     - parameter causedBy:     deactivation initiator
     - parameter reason:       deactivation reason
     - parameter completion:   DeactivateHandler closure
     */
    func deactivate(creditCardId creditCardId:String, userId:String, causedBy:CreditCardInitiator, reason:String, completion:DeactivateHandler)
    {

    }

    /**
     Completion handler

     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
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
    {

    }

    /**
     Completion handler
     - parameter Bool:                Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter VerificationMethod?: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:          Provides error object, or nil if no error occurs
     */
    typealias SelectVerificationTypeHandler = (Bool, VerificationMethod?, ErrorType?)->Void
    
    /**
     When an issuer requires additional authentication to verfiy the identity of the cardholder, this indicates the user has selected the specified verification method by the indicated verificationTypeId
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter completion:         SelectVerificationTypeHandler closure
     */
    func selectVerificationType(creditCardId creditCardId:String, userId:String, verificationTypeId:String, completion:SelectVerificationTypeHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter Bool:                Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter VerificationMethod?: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias VerifyHandler = (Bool, VerificationMethod?, ErrorType?)->Void
    
    /**
     If a verification method is selected that requires an entry of a pin code, this transition will be available. Not all verification methods will include a secondary verification step through the FitPay API
     
     - parameter creditCardId:       credit card id
     - parameter userId:             user id
     - parameter verificationTypeId: verification type id
     - parameter verificationCode:   verification code
     - parameter completion:         VerifyHandler closure
     */
    func verify(creditCardId creditCardId:String, userId:String, verificationTypeId:String, verificationCode:String, completion:VerifyHandler)
    {

    }

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
    {

    }

    /**
    Completion handler

    - parameter Device?: Provides created Device object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias CreateNewDeviceHandler = (Device?, ErrorType?)->Void

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
    func createNewDevice(userId userId:String, deviceType:String, manufacturerName:String, deviceName:String,
                         serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
                         softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
                         secureElementId:String, pairing:String, completion:CreateNewDeviceHandler)
    {

    }

    /**
    Completion handler

    - parameter Device?: Provides existing Device object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias DeviceHandler = (Device?, ErrorType?)
    
    /**
     Retrieves the details of an existing device. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeviceHandler closure
     */
    func device(deviceId deviceId:String, userId:String, completion:DeviceHandler)
    {

    }

    /**
    Completion handler

    - parameter Device?: Provides updated Device object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias UpdateDeviceHandler = (Device?, ErrorType?)

    /**
     Update the details of an existing device
     (For optional? parameters use nil if field doesn't need to be updated) //TODO: consider adding default nil value

     - parameter deviceId:          device id
     - parameter userId:            user id
     - parameter firmwareRevision?: firmware revision
     - parameter softwareRevision?: software revision
     - parameter completion:        UpdateDeviceHandler closure
     */
    func updateDevice(deviceId deviceId:String, userId:String, firmwareRevision:String?, softwareRevision:String?,
                      completion:UpdateDeviceHandler)
    {

    }

    /**
    Completion handler

    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    typealias DeleteDeviceHandler = (ErrorType?)

    /**
     Delete a single device
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeleteDeviceHandler closure
     */
    func deleteDevice(deviceId deviceId:String, userId:String, completion:DeleteDeviceHandler)
    {

    }

    // MARK: Commits

    /**
     Completion handler

     - parameter ResultCollection<Commit>?: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter ErrorType?:                Provides error object, or nil if no error occurs
    */
    typealias CommitsHandler = (ResultCollection<Commit>?, ErrorType?)->Void
    
    /**
     Retrieves a collection of all events that should be committed to this device
     
     - parameter deviceId:     device id
     - parameter userId:       user id
     - parameter commitsAfter: the last commit successfully applied. Query will return all subsequent commits which need to be applied.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CommitsHandler closure
     */
    func commits(deviceId deviceId:String, userId:String, commitsAfter:String, limit:Int, offset:Int,
        completion:CommitsHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter Commit?:    Provides Commit object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias CommitHandler = (Commit?, ErrorType?)->Void
    
    /**
     Retrieves an individual commit
     
     - parameter commitId:   commit id
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: CommitHandler closure
     */
    func commit(commitId commitId:String, deviceId:String, userId:String, completion:CommitHandler)
    {

    }

    // MARK: Transactions

    /**
     Completion handler

     - parameter ResultCollection<Commit>?: Provides ResultCollection<Transaction> object, or nil if error occurs
     - parameter ErrorType?:                Provides error object, or nil if no error occurs
    */
    typealias TransactionsHandler = (ResultCollection<Transaction>?, ErrorType?)->Void

    /**
     Provides a transaction history (if available) for the user, results are limited by provider.
     
     - parameter userId:     user id
     - parameter completion: TransactionsHandler closure
     */
    func transactions(userId userId:String, completion:TransactionsHandler)
    {

    }

    /**
     Completion handler

     - parameter Transaction?: Provides Transaction object, or nil if error occurs
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    typealias TransactionHandler = (Transaction?, ErrorType?)->Void

    /**
     Get a single transaction
     
     - parameter transactionId: transaction id
     - parameter userId:        user id
     - parameter completion:    TransactionHandler closure
     */
    func transaction(transactionId transactionId:String, userId:String, completion:TransactionHandler)
    {

    }

    // MARK: APDU Packages

    /**
     Completion handler
     
     - parameter PackageConfirmation?: Provides PackageConfirmation object, or nil if error occurs
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    typealias ConfirmAPDUPackageHandler = (ApduPackage?, ErrorType?)->Void

    /**
     Endpoint to allow for returning responses to APDU execution
     
     - parameter packageId:  package id
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    func confirmAPDUPackage(packageId:String, completion: ConfirmAPDUPackageHandler)
    {

    }

    // MARK: Assets

    /**
     Completion handler

     - parameter AnyObject?: Provides AnyObject (UIImage or String) object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias AssetsHandler = (AnyObject?, ErrorType?)->Void

    /**
     Retrieve an individual asset (i.e. terms and conditions)
     
     - parameter adapterData: adapter data
     - parameter adapterId:   adapter id
     - parameter assetId:     asset id
     - parameter completion:  AssetsHandler closure
     */
    func assets(adapterData:String, adapterId:String, assetId:String, completion:AssetsHandler)
    {
        
    }

    // MARK: EncryptionKeys

    /**
     Completion handler

     - parameter EncryptionKey?: Provides created EncryptionKey object, or nil if error occurs
     - parameter ErrorType?:     Provides error object, or nil if no error occurs
     */
    typealias CreateEncryptionKeyHandler = (EncryptionKey?, ErrorType?)->Void

    /**
     Creates a new encryption key pair
     
     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    func createEncryptionKey(clientPublicKey:String, completion:CreateEncryptionKeyHandler)
    {
        
    }

    /**
     Completion handler

     - parameter EncryptionKey?: Provides EncryptionKey object, or nil if error occurs
     - parameter ErrorType?:     Provides error object, or nil if no error occurs
     */
    typealias EncryptionKeyHandler = (EncryptionKey?, ErrorType?)->Void

    /**
     Retrieve and individual key pair
     
     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    func encryptionKey(keyId:String, completion:EncryptionKeyHandler)
    {
        
    }

    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeleteEncryptionKeyHandler = (ErrorType?)->Void
    
    /**
     Deletes encryption key
     
     - parameter keyId:      key id
     - parameter completion: DeleteEncryptionKeyHandler
     */
    func deleteEncryptionKey(keyId:String, completion:DeleteEncryptionKeyHandler)
    {
        
    }

    // MARK: Webhooks
    
    /**
     Completion handler
     
     - parameter String?:    Provides String object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias SetWebhookHandler = (String?, ErrorType?)
    
    /**
     Sets the webhook endpoint you would like FitPay to send notifications to, must be a valid URL
     
     - parameter webhookURL: valid webhook URL
     - parameter completion: AddWebhookHandler closure
     */
    func setWebhook(webhookURL:NSURL, completion:SetWebhookHandler)
    {
        
    }
    
    /**
     Completion handler
     
     - parameter String?:    Provides String object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias WebhookHandler = (String?, ErrorType?)->Void
    
    /**
     TODO: add description when it becomes available on API documentation page
     
     - parameter completion: WebhookHandler closure
     */
    func webhook(completion:WebhookHandler)
    {

    }
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias RemoveWebhookHandler = (ErrorType)->Void
    
    /**
     Removes the current webhook endpoint, unsubscribing you from all Fitpay notifications
     
     - parameter webhookURL: webhook URL
     - parameter completion: RemoveWebhookHandler closure
     */
    func removeWebhook(webhookURL:NSURL, completion:RemoveWebhookHandler)
    {
        
    }
}