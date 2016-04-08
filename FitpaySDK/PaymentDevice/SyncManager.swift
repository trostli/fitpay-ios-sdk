
import ObjectMapper

public enum SyncEventType : Int {
    case CONNECTING_TO_DEVICE = 0x1
    case CONNECTING_TO_DEVICE_FAILED
    case CONNECTING_TO_DEVICE_COMPLETED
    
    case SYNC_STARTED
    case SYNC_FAILED
    case SYNC_COMPLETED
    case SYNC_PROGRESS
    
    case COMMIT_PROCESSED
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
            
            //TODO: delete this once approved
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
        //TODO: uncomment this once approved
        //let physicalDeviceInfo = self.paymentDevice.deviceInfo
        
        user?.listDevices(itrSearchLimit, offset: searchOffset, completion:
        {
            [unowned self] (result, error) -> Void in
            
            guard (error == nil && result != nil && result?.results?.count > 0) else {
                completion(deviceInfo: nil, error: error)
                return
            }
            
            for deviceInfo in result!.results! {
                // TODO: uncomment this once approved
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
            callCompletionForSyncEvent(SyncEventType.SYNC_COMPLETED, params: [:])
        }
    }
    
    //TODO: delete this once approved
    // debug
    private func ___debug_appendAPDUCommits(commits: [Commit]) -> [Commit] {
        var commit = commits.last!
        
        for commitItr in commits {
            if let _ = commitItr.commitType, let _ = commitItr.payload {
                commit = commitItr
                break
            }
        }
        let resourceLink = ResourceLink()
        resourceLink.href = "https://demo.pagare.me/apduPackages/baff08fb-0b73-5019-8877-7c490a43dc64/confirm"
        resourceLink.target = "apduResponse"
        commit.links?.append(resourceLink)
        
        commit.commitType = CommitType.APDU_PACKAGE
        let apduPackage = Mapper<ApduPackage>().map("{  \r\n   \"seIdType\":\"iccid\",\r\n   \"targetDeviceType\":\"fitpay.gandd.model.Device\",\r\n   \"targetDeviceId\":\"72425c1e-3a17-4e1a-b0a4-a41ffcd00a5a\",\r\n   \"packageId\":\"baff08fb-0b73-5019-8877-7c490a43dc64\",\r\n   \"seId\":\"333274689f09352405792e9493356ac880c44444442\",\r\n   \"targetAid\":\"8050200008CF0AFB2A88611AD51C\",\r\n   \"commandApdus\":[  \r\n      {  \r\n         \"commandId\":\"5f2acf6f-536d-4444-9cf4-7c83fdf394bf\",\r\n         \"groupId\":0,\r\n         \"sequence\":0,\r\n         \"command\":\"00E01234567890ABCDEF\",\r\n         \"type\":\"CREATE FILE\"\r\n      },\r\n      {  \r\n         \"commandId\":\"00df5f39-7627-447d-9380-46d8574e0643\",\r\n         \"groupId\":1,\r\n         \"sequence\":1,\r\n         \"command\":\"8050200008CF0AFB2A88611AD51C\",\r\n         \"type\":\"UNKNOWN\"\r\n      },\r\n      {  \r\n         \"commandId\":\"9c719928-8bb0-459c-b7c0-2bc48ec53f3c\",\r\n         \"groupId\":1,\r\n         \"sequence\":2,\r\n         \"command\":\"84820300106BBC29E6A224522E83A9B26FD456111500\",\r\n         \"type\":\"UNKNOWN\"\r\n      },\r\n      {  \r\n         \"commandId\":\"b148bea5-6d98-4c83-8a20-575b4edd7a42\",\r\n         \"groupId\":1,\r\n         \"sequence\":3,\r\n         \"command\":\"84F2200210F25397DCFB728E25FBEE52E748A116A800\",\r\n         \"type\":\"UNKNOWN\"\r\n      },\r\n      {  \r\n         \"commandId\":\"905fc5ab-4b15-4704-889b-2c5ffcfb2d68\",\r\n         \"groupId\":2,\r\n         \"sequence\":4,\r\n         \"command\":\"84F2200210F25397DCFB728E25FBEE52E748A116A800\",\r\n         \"type\":\"UNKNOWN\"\r\n      },\r\n      {  \r\n         \"commandId\":\"8e87ff12-dfc2-472a-bbf1-5f2e891e864c\",\r\n         \"groupId\":3,\r\n         \"sequence\":5,\r\n         \"command\":\"84F2200210F25397DCFB728E25FBEE52E748A116A800\",\r\n         \"type\":\"UNKNOWN\"\r\n      }\r\n   ],\r\n   \"validUntil\":\"2015-12-11T21:22:58.691Z\",\r\n   \"apduPackageUrl\":\"http://localhost:9103/transportservice/v1/apdupackages/baff08fb-0b73-5019-8877-7c490a43dc64\"\r\n}")
        apduPackage?.validUntilEpoch = 1559862740

        
        commit.payload?.apduPackage = apduPackage
        
        let apduPackages = [commit, commit, commit, commit, commit]
        
        return commits + apduPackages
    }
}


