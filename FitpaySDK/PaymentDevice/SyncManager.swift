
public enum SyncEventType : String {
    case CONNECTING_TO_DEVICE = "CONNECTING_TO_DEVICE"
    case CONNECTING_TO_DEVICE_FAILED = "CONNECTING_TO_DEVICE_FAILED"
    case CONNECTING_TO_DEVICE_COMPLETED = "CONNECTING_TO_DEVICE_COMPLETED"
    case SYNC_STARTED = "SYNC_STARTED"
    case SYNC_FAILED = "SYNC_FAILED"
    case SYNC_FINISHED = "SYNC_FINISHED"
    case SYNC_PROGRESS = "SYNC_PROGRESS"
    case CREDITCARD_CREATED = "CREDITCARD_CREATED"
    case CREDITCARD_DEACTIVATED = "CREDITCARD_DEACTIVATED"
    case CREDITCARD_ACTIVATED = "CREDITCARD_ACTIVATED"
    case CREDITCARD_DELETED = "CREDITCARD_DELETED"
    case RESET_DEFAULT_CREDITCARD = "RESET_DEFAULT_CREDITCARD"
    case SET_DEFAULT_CREDITCARD = "SET_DEFAULT_CREDITCARD"
}

public class SyncManager {
    static let sharedInstance = SyncManager()
    
    public let paymentDevice : PaymentDevice = PaymentDevice()
    
    internal let syncStorage : SyncStorage = SyncStorage()
    internal let paymentDeviceConnectionTimeoutInSecs : Int = 60
    
    private var syncEventsBlocks : [SyncEventType:SyncEventBlockHandler] = [:]
    private var user : User?
    
    private var commitsApplyer = CommitsApplyer()
    
    private init() {
        
    }
    
    public enum ErrorCode : Int, ErrorType, RawIntValue, CustomStringConvertible
    {
        case UnknownError = 0
        case CantConnectToDevice = 10001
        case CantApplyAPDUCommand = 10002
        case CantFetchCommits = 10003
        case CantFindDeviceWithSerialNumber = 10004
        case SyncAlreadyStarted = 10005
        
        public var description : String {
            switch self {
            case .UnknownError:
                return "Unknown error"
            case .CantConnectToDevice:
                return "Can't connect to payment device."
            case .CantApplyAPDUCommand:
                return "Can't apply APDU command to payment device."
            case .CantFetchCommits:
                return "Can't fetch commits from API."
            case .CantFindDeviceWithSerialNumber:
                return "Can't find device with serial number of connected payment device."
            case .SyncAlreadyStarted:
                return "Sync already started."
            }
        }
    }
    
    public private(set) var isSyncing : Bool = false
    
    /**
     Starts sync process with payment device. 
     If device disconnected, than system tries to connect.
     
     - parameter user: user from API to whom device belongs to.
     */
    public func sync(user: User) -> ErrorType? {
        if self.isSyncing {
            return NSError.error(code: SyncManager.ErrorCode.SyncAlreadyStarted, domain: SyncManager.self)
        }
        
        self.isSyncing = true
        self.user = user
        
        if self.paymentDevice.isConnected {
            startSync()
            return nil
        }
        
        self.paymentDevice.onDeviceConnected =
        {
            [unowned self] (deviceInfo, error) -> Void in
            guard (error == nil && deviceInfo != nil) else {
                
                self.callCompletionForSyncEvent(SyncEventType.CONNECTING_TO_DEVICE_COMPLETED, params: ["error": NSError.error(code: SyncManager.ErrorCode.CantConnectToDevice, domain: SyncManager.self)])
                
                self.syncFinished(error: NSError.error(code: SyncManager.ErrorCode.CantConnectToDevice, domain: SyncManager.self))
                
                return
            }
            
            self.callCompletionForSyncEvent(SyncEventType.CONNECTING_TO_DEVICE_COMPLETED)
            
            self.startSync()
        }
        
        self.paymentDevice.connect(self.paymentDeviceConnectionTimeoutInSecs)
        
        self.callCompletionForSyncEvent(SyncEventType.CONNECTING_TO_DEVICE)
        
        return nil
    }
    
    /**
     Completion handler
     
     - parameter eventPayload: Provides payload for event
     */
    public typealias SyncEventBlockHandler = (eventPayload:[String:AnyObject]) -> Void
    
    /**
     Binds to the sync event using SyncEventType and a block as callback.
     
     - parameter eventType: type of event which you want to bind to
     - parameter completion: completion handler which will be called when system receives commit with eventType
     */
    public func bindToSyncEvent(eventType eventType: SyncEventType, completion: SyncEventBlockHandler) {
        self.syncEventsBlocks[eventType] = completion
    }
    
    /**
     Removes bind with eventType.
     */
    public func removeSyncBinding(eventType eventType: SyncEventType) {
        self.syncEventsBlocks.removeValueForKey(eventType)
    }
    
    /**
     Removes all synchronization bindings.
     */
    public func removeAllSyncBindings() {
        self.syncEventsBlocks = [:]
    }
    
    private func startSync() {
        
        self.callCompletionForSyncEvent(SyncEventType.SYNC_STARTED)
        
        getCommits(self.syncStorage.lastCommitId)
        {
            [unowned self] (commits, error) -> Void in
            
            guard (error == nil && commits != nil) else {
                self.syncFinished(error: NSError.error(code: SyncManager.ErrorCode.CantFetchCommits, domain: SyncManager.self))
                return
            }
            
            let commits = self.___debug_appendAPDUCommits(commits!)
            self.commitsApplyer.apply(commits, completion:
            {
                [unowned self] (error) -> Void in
                
                if let _ = error {
                    self.syncFinished(error: error)
                    return
                }
                
                self.syncFinished(error: nil)
            })
        }
    }
    
    private func findDeviceInfo(itrSearchLimit: Int, searchOffset: Int, completion:(deviceInfo: DeviceInfo?, error: ErrorType?)->Void) {
        //let physicalDeviceInfo = self.paymentDevice.deviceInfo
        
        user?.listDevices(itrSearchLimit, offset: searchOffset, completion:
        {
            [unowned self] (result, error) -> Void in
            
            guard (error == nil && result != nil && result?.results?.count > 0) else {
                completion(deviceInfo: nil, error: error)
                return
            }
            
            for deviceInfo in result!.results! {
                // TODO: uncomment this
                // if deviceInfo.serialNumber == physicalDeviceInfo?.serialNumber {
                if deviceInfo.deviceName == "PSPS" {
                    completion(deviceInfo: deviceInfo, error: nil)
                    return
                }
            }
        
            if result!.results!.count + searchOffset >= result!.totalResults! {
                completion(deviceInfo: nil, error: NSError.error(code: SyncManager.ErrorCode.CantFindDeviceWithSerialNumber, domain: SyncManager.self))
                return
            }
            
            self.findDeviceInfo(itrSearchLimit, searchOffset: searchOffset+itrSearchLimit, completion: completion)
        })
    }
    
    private func getCommits(lastCommitId: String?, completion: (commits: [Commit]?, error: ErrorType?)->Void) {
        findDeviceInfo(20, searchOffset: 0)
        {
            (deviceInfo, error) -> Void in
            
            if let deviceInfo = deviceInfo {
                deviceInfo.listCommits(lastCommitId, limit: 20, offset: 0, completion:
                {
                    (result, error) -> Void in
                    
                    if let error = error {
                        completion(commits: nil, error: error)
                        return
                    }
                    
                    guard let result = result else {
                        completion(commits: nil, error: NSError.unhandledError(SyncManager.self))
                        return
                    }
                    
                    if result.totalResults > result.results?.count {
                        result.collectAllAvailable(
                        {
                            (results, error) -> Void in
                            
                            if let error = error {
                                completion(commits: nil, error: error)
                                return
                            }
                            
                            guard let results = results else {
                                completion(commits: nil, error: NSError.unhandledError(SyncManager.self))
                                return
                            }
                            
                            completion(commits: results, error: nil)
                        })
                    } else {
                        completion(commits: result.results, error: nil)
                    }
                })
            } else {
                completion(commits: nil, error: error)
            }
        }
    }

    internal func callCompletionForSyncEvent(event: SyncEventType, params: [String:AnyObject] = [:]) {
        if let completion = self.syncEventsBlocks[event] {
            dispatch_async(dispatch_get_main_queue(),
            {
                completion(eventPayload: params)
            })
        }
    }

    private func syncFinished(error error: ErrorType?) {
        self.isSyncing = false
        
        if let error = error as? NSError {
            callCompletionForSyncEvent(SyncEventType.SYNC_FAILED, params: ["error": error])
        } else {
            callCompletionForSyncEvent(SyncEventType.SYNC_FINISHED, params: [:])
        }
    }
    
    //TODO: debug code
    private func ___debug_appendAPDUCommits(commits: [Commit]) -> [Commit] {
        var commit = commits.last!
        
        for commitItr in commits {
            if let _ = commitItr.commitType, let _ = commitItr.payload {
                commit = commitItr
                break
            }
        }
        
        commit.commitType = CommitType.APDU_PACKAGE
        let apduPackage = ApduPackage()
        apduPackage.packageId = "1745"
        apduPackage.commands = ["00A4040008A00000000410101100".hexToData()!, "84E20001B0B12C352E835CBC2CA5CA22A223C6D54F3EDF254EF5E468F34CFD507C889366C307C7C02554BDACCDB9E1250B40962193AD594915018CE9C55FB92D25B0672E9F404A142446C4A18447FEAD7377E67BAF31C47D6B68D1FBE6166CF39094848D6B46D7693166BAEF9225E207F9322E34388E62213EE44184ED892AAF3AD1ECB9C2AE8A1F0DC9A9F19C222CE9F19F2EFE1459BDC2132791E851A090440C67201175E2B91373800920FB61B6E256AC834B9D".hexToData()!]
        
        commit.payload?.apduPackage = apduPackage
        
        let apduPackages = [commit, commit, commit, commit, commit]
        
        return commits + apduPackages
    }
}


