
public enum SyncEventType : String {
    case SYNC_STARTED = "SYNC_STARTED"
    case SYNC_FAILED = "SYNC_FAILED"
    case SYNC_FINISHED = "SYNC_FINISHED"
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
    
    private init() {
    }
    
    public enum ErrorCode : Int, ErrorType, RawIntValue, CustomStringConvertible
    {
        case UnknownError = 0
        case CantConnectToDevice = 10001
        case CantApplyAPDUCommand = 10002
        case CantFetchCommits = 10003
        case CantFindDeviceWithSerialNumber = 10004
        
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
            }
        }
    }
    
    public func sync(user: User) {
        self.user = user
        
        if self.paymentDevice.isConnected {
            startSync()
            return
        }
        
        self.paymentDevice.onDeviceConnected =
        {
            [unowned self] (deviceInfo, error) -> Void in
            guard (error == nil && deviceInfo != nil) else {
                if let syncFailedCompletion = self.syncEventsBlocks[SyncEventType.SYNC_FAILED] {
                    syncFailedCompletion(eventPayload: ["error": NSError.error(code: SyncManager.ErrorCode.CantConnectToDevice, domain: SyncManager.self, message: SyncManager.ErrorCode.CantConnectToDevice.description)])
                }
                return
            }
                
            self.startSync()
        }
        
        self.paymentDevice.connect(self.paymentDeviceConnectionTimeoutInSecs)
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
                completion(deviceInfo: nil, error: NSError.error(code: SyncManager.ErrorCode.CantFindDeviceWithSerialNumber, domain: SyncManager.self, message: SyncManager.ErrorCode.CantFindDeviceWithSerialNumber.description))
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
                deviceInfo.listCommits(lastCommitId ?? "", limit: 20, offset: 0, completion:
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
    
    private func getAPDUPackagesFromCommits(commits: [Commit]) -> [ApduPackage] {
        //TODO: temp code, we should rewrite it when we get APDU structure
        let apduPackage = ApduPackage()
        apduPackage.packageId = "1745"
        apduPackage.commands = ["00A4040008A00000000410101100".hexToData()!, "84E20001B0B12C352E835CBC2CA5CA22A223C6D54F3EDF254EF5E468F34CFD507C889366C307C7C02554BDACCDB9E1250B40962193AD594915018CE9C55FB92D25B0672E9F404A142446C4A18447FEAD7377E67BAF31C47D6B68D1FBE6166CF39094848D6B46D7693166BAEF9225E207F9322E34388E62213EE44184ED892AAF3AD1ECB9C2AE8A1F0DC9A9F19C222CE9F19F2EFE1459BDC2132791E851A090440C67201175E2B91373800920FB61B6E256AC834B9D".hexToData()!]
        
        let apduPackages = [apduPackage, apduPackage, apduPackage, apduPackage]
        
        return apduPackages
    }
    
    private func startSync() {
        
        if let syncStartedCompletion = self.syncEventsBlocks[SyncEventType.SYNC_STARTED] {
            syncStartedCompletion(eventPayload: [:])
        }

        getCommits(self.syncStorage.lastCommitId)
        {
            [unowned self] (commits, error) -> Void in
    
            guard (error == nil && commits != nil) else {
                if let syncFailedCompletion = self.syncEventsBlocks[SyncEventType.SYNC_FAILED] {
                    syncFailedCompletion(eventPayload: ["error": NSError.error(code: SyncManager.ErrorCode.CantFetchCommits, domain: SyncManager.self, message: SyncManager.ErrorCode.CantFetchCommits.description)])
                }
                return
            }
            
            let apduPackages = self.getAPDUPackagesFromCommits(commits!)
            
            self.applyAPDUPackages(apduPackages, apduIndex: 0)
            {
                [unowned self] (error) -> Void in
                                
                if let _ = error, let syncFailedCompletion = self.syncEventsBlocks[SyncEventType.SYNC_FAILED] {
                    syncFailedCompletion(eventPayload: ["error": NSError.error(code: SyncManager.ErrorCode.CantApplyAPDUCommand, domain: SyncManager.self, message: SyncManager.ErrorCode.CantApplyAPDUCommand.description)])
                    
                    return
                }
                
                self.processNonAPDUCommits(commits!)
                
                if let commitId = commits?.last?.commit {
                    self.syncStorage.lastCommitId = commitId
                }
                
                if let syncFinishedCompletion = self.syncEventsBlocks[SyncEventType.SYNC_FINISHED] {
                    syncFinishedCompletion(eventPayload: [:])
                }
            }
        }
    }
    
    private func processNonAPDUCommits(commits: [Commit]) {
        for commit in commits {
            guard let commitType = commit.commitType, payload = commit.payload?.payloadDictionary else {
                continue
            }
            
            if let eventType = SyncEventType(rawValue: commitType.rawValue) {
                if let syncEventCompletion = self.syncEventsBlocks[eventType] {
                    syncEventCompletion(eventPayload: payload)
                }
            }
        }
    }
    
    // uses recursion
    private func applyAPDUPackages(apduPackages: [ApduPackage], apduIndex: Int, completion: (error:ErrorType?)->Void) {
        let isFinished = apduPackages.count <= apduIndex
        
        if isFinished {
            completion(error: nil)
            return
        }
        
        let apdu = apduPackages[apduIndex]
        self.applyAPDUPackage(apdu, apduCommandIndex: 0)
        {
            [unowned self] (error) -> Void in
            if let error = error {
                completion(error: error)
                return
            }
            
            self.applyAPDUPackages(apduPackages, apduIndex: apduIndex+1, completion: completion)
        }
    }
    
    // uses recursion
    private func applyAPDUPackage(apduPackage: ApduPackage, apduCommandIndex: Int, completion: (error:ErrorType?)->Void) {
        let isFinished = apduPackage.commands?.count <= apduCommandIndex
        
        if isFinished {
            completion(error: nil)
            return
        }
        
        let apdu = apduPackage.commands![apduCommandIndex]
        self.paymentDevice.sendAPDUData(apdu, completion:
        {
            [unowned self] (apduResponse, error) -> Void in
            
            if let error = error {
                completion(error: error)
                return
            }
            
            //TODO: send response here
            
            self.applyAPDUPackage(apduPackage, apduCommandIndex: apduCommandIndex + 1, completion: completion)
        })
    }


}