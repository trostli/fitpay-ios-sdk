
import Foundation

protocol RestUser
{
    /**
     Completion handler
     
     - parameter [User]?: Provides array of User objects, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias UsersHandler = ([User]?, ErrorType?)->Void
    
    /**
      Returns a list of all users that belong to your organization. The customers are returned sorted by creation date, with the most recently created customers appearing first
     
     - parameter limit:      Max number of profiles per page
     - parameter offset:     Start index position for list of entities returned
     - parameter completion: UsersHandler closure
     */
    func users(limit:Int, offset:Int, completion:UsersHandler)
    
    /**
     Completion handler
     
     - parameter [User]?: Provides User object, or nil if error occurs
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
    func createUser(firstName:String, lastName:String, birthDate:String, email:String, completion:CreateUsersHandler)
    
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
    func user(id:String, completion:UserHandler)
    
    /**
     Completion handler
     
     - parameter User?: Provides updated User object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias UpdateUserHandler = (User?, ErrorType?)->Void
    
    /**
     Update the details of an existing user
     
     - parameter id:                   used id
     - parameter firstName:            first name or nil if no change is required
     - parameter lastName:             last name or nil if no change is required
     - parameter birthDate:            birth date in date format [YYYY-MM-DD] or nil if no change is required
     - parameter originAccountCreated: origin account created in date format [TODO: specify date format] or nil if no change is required
     - parameter termsAccepted:        terms accepted in date format [TODO: specify date format] or nil if no change is required
     - parameter termsVersion:         terms version formatted as [0.0.0]
     - parameter completion:           UpdateUserHandler closure
     */
    func updateUser(id:String, firstName:String?, lastName:String?, birthDate:Int?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:UpdateUserHandler)
    
}
