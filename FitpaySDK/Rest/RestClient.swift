
import Foundation

public class RestClient
{
    private var _session:RestSession

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

    }
    
    /**
     Completion handler
     
     - parameter User?: Provides User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias UserHandler = (User?, ErrorType?)->Void
    
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    public func user(id id:String, completion:UserHandler)
    {

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

     - parameter Relationship?: Provides Relationship object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias RelationshipHandler = (Relationship?, ErrorType?)->Void

    /**
     Get a single relationship
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   RelationshipHandler closure
     */
    public func relationship(userId userId:String, creditCardId:String, deviceId:String, completion:RelationshipHandler)
    {

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
    
    - parameter ResultCollection<DeviceInfo>?: Provides ResultCollection<DeviceInfo> object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    public typealias DevicesHandler = (ResultCollection<DeviceInfo>?, ErrorType?)->Void
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter userId:     user id
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    public func devices(userId userId:String, limit:Int, offset:Int, completion:DevicesHandler)
    {

    }

    /**
    Completion handler

    - parameter DeviceInfo?: Provides created DeviceInfo object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    public typealias CreateNewDeviceHandler = (DeviceInfo?, ErrorType?)->Void

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

    }

    /**
    Completion handler

    - parameter DeviceInfo?: Provides existing DeviceInfo object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    public typealias DeviceHandler = (DeviceInfo?, ErrorType?)
    
    /**
     Retrieves the details of an existing device. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeviceHandler closure
     */
    public func device(deviceId deviceId:String, userId:String, completion:DeviceHandler)
    {

    }

    /**
    Completion handler

    - parameter DeviceInfo?: Provides updated DeviceInfo object, or nil if error occurs
    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    public typealias UpdateDeviceHandler = (DeviceInfo?, ErrorType?)

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

    }

    /**
    Completion handler

    - parameter ErrorType?: Provides error object, or nil if no error occurs
    */
    public typealias DeleteDeviceHandler = (ErrorType?)

    /**
     Delete a single device
     
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: DeleteDeviceHandler closure
     */
    public func deleteDevice(deviceId deviceId:String, userId:String, completion:DeleteDeviceHandler)
    {

    }

    // MARK: Commits

    /**
     Completion handler

     - parameter ResultCollection<Commit>?: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter ErrorType?:                Provides error object, or nil if no error occurs
    */
    public typealias CommitsHandler = (ResultCollection<Commit>?, ErrorType?)->Void
    
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

    }
    
    /**
     Completion handler
     
     - parameter Commit?:    Provides Commit object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias CommitHandler = (Commit?, ErrorType?)->Void
    
    /**
     Retrieves an individual commit
     
     - parameter commitId:   commit id
     - parameter deviceId:   device id
     - parameter userId:     user id
     - parameter completion: CommitHandler closure
     */
    public func commit(commitId commitId:String, deviceId:String, userId:String, completion:CommitHandler)
    {

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
    public typealias CreateEncryptionKeyHandler = (encryptionKey:EncryptionKey?, error:ErrorType?)->Void

    /**
     Creates a new encryption key pair
     
     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    public func createEncryptionKey(clientPublicKey:String, completion:CreateEncryptionKeyHandler)
    {
        let parameters = ["" : ""]
    }

    /**
     Completion handler

     - parameter EncryptionKey?: Provides EncryptionKey object, or nil if error occurs
     - parameter ErrorType?:     Provides error object, or nil if no error occurs
     */
    public typealias EncryptionKeyHandler = (EncryptionKey?, ErrorType?)->Void

    /**
     Retrieve and individual key pair
     
     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    public func encryptionKey(keyId:String, completion:EncryptionKeyHandler)
    {
        
    }

    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias DeleteEncryptionKeyHandler = (ErrorType?)->Void
    
    /**
     Deletes encryption key
     
     - parameter keyId:      key id
     - parameter completion: DeleteEncryptionKeyHandler
     */
    public func deleteEncryptionKey(keyId:String, completion:DeleteEncryptionKeyHandler)
    {

    }
}