import KeychainAccess

public class PaymentDevice : NSObject
{
    public enum ErrorCode : Int, ErrorType, RawIntValue
    {
        case UnknownError = 0
        case BadBLEState = 10001
        case DeviceDataNotCollected = 10002
        case WaitingForAPDUResponse = 10003
        case APDUPacketCorrupted = 10004
        case OperationTimeout = 10005
    }
    
    public enum SecurityState : Int
    {
        case SecurityNFCStateDisabled = 0x00
        case SecurityNFCStateEnabled = 0x01
        case SecurityNFCStateDoNotChangeState = 0xFF
    }
    
    public typealias ConnectionHandler = (deviceInfo:DeviceInfo?, error:ErrorType?)->Void
    public typealias DisconnectionHandler = ()->Void
    public typealias TransactionHandler = (transactionData:NSData?)->Void
    public typealias SecurityStateHandler = (securityState:SecurityState)->Void
    public typealias ApplicationControlHandler = (applicationControl:ApplicationControlMessage) -> Void
    
    
    /// Called when phone connected to payment device
    public var onDeviceConnected : ConnectionHandler?
    
    /// Called when connection with payment device was lost
    public var onDeviceDisconnected : DisconnectionHandler?
    
    /// Called when transaction was made
    public var onReceivingTransactionNotification : TransactionHandler?
    
    /// Called when security event has taken place 
    /// (i.e. the wearable has been removed, the wearable has been activated/enabled/placed on person)
    public var onSecurityStateChanged : SecurityStateHandler?
    
    /// Called when payment device made reset?
    public var onApplicationControlReceived : ApplicationControlHandler?
    
    /**
     Establishes BLE connection with payment device and collects DeviceInfo from it.
     Calls onDeviceConnected callback.
     
     - parameter secsTimeout: timeout for connection process in seconds. If nil then there is no timeout.
     */
    public func connect(secsTimeout: Int? = nil) {
        if isConnected {
            self.deviceInterface.resetToDefaultState()
        }
        
        if let secsTimeout = secsTimeout {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(secsTimeout) * NSEC_PER_SEC))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                [unowned self] () -> Void in
                if (!self.isConnected || self.deviceInfo == nil) {
                    self.deviceInterface.resetToDefaultState()
                    if let onDeviceConnected = self.onDeviceConnected {
                        onDeviceConnected(deviceInfo: nil, error: NSError.error(code: PaymentDevice.ErrorCode.OperationTimeout, domain: PaymentDevice.self, message: "Connection timeout. Can't find device."))
                    }
                }
            }
        }
        
        self.deviceInterface.connect()
    }
    
    /**
     Close connection with payment device.
     */
    public func disconnect() {
        self.deviceInterface.disconnect()
    }
    
    /**
     Returns true if phone connected to payment device and device info was collected.
     */
    public var isConnected : Bool {
        return self.deviceInterface.isConnected()
    }
    
    /**
     Returns DeviceInfo if phone already connected to payment device.
     */
    public var deviceInfo : DeviceInfo? {
        return self.deviceInterface.deviceInfo()
    }
    
    /**
     Completion handler
     
     - parameter eventPayload: Provides payload for event
     */
    public typealias SyncEventBlockHandler = (eventPayload:[String:AnyObject]) -> Void
    
    /**
     Binds to the sync event using CommitType and a block as callback.
     
     - parameter eventType: type of event which you want to bind to
     - parameter completion: completion handler which will be called when system receives commit with eventType
     */
    public func bindToSyncEvent(eventType eventType: CommitType, completion: SyncEventBlockHandler) {
        self.syncEventsBlocks[eventType.rawValue] = completion
    }
    
    /**
     Removes bind with eventType.
     */
    public func removeSyncBinding(eventType eventType: CommitType) {
        self.syncEventsBlocks.removeValueForKey(eventType.rawValue)
    }
    
    /**
     Removes all synchronization bindings.
     */
    public func removeAllSyncBindings() {
        self.syncEventsBlocks = [:]
    }
    
    /**
     Returns commitId which was the last commit that was applied to payment device.
     */
    public var lastSynchronizedCommitId : String? {
        guard let deviceInfo = self.deviceInfo, let serialNumber = deviceInfo.serialNumber else {
            return nil
        }
        
        return keychain[serialNumber]
    }
    
    /**
     Allows to reset the secure element and prepare it to receive APDU and other commands.
     Calls onApplicationControlReceived on device reset?
     
     - parameter state: desired security state
     */
    public func sendDeviceReset() -> ErrorType? {
        return self.deviceInterface.sendDeviceReset()
    }
    
    /**
     Allows to change state of NFC at payment device.
     Calls onSecurityStateChanged when state changed.
     
     - parameter state: desired security state
     */
    // TODO: shoud it be public?
    internal func writeSecurityState(state:SecurityState) -> ErrorType? {
        return self.deviceInterface.writeSecurityState(state)
    }
    
    
    internal var deviceInterface : PaymentDeviceBaseInterface!
    internal var keychain : Keychain!
    
    internal typealias APDUResponseHandler = (apduResponse:ApduResultMessage?, error:ErrorType?)->Void
    internal var apduResponseHandler : APDUResponseHandler?
    
    private var syncEventsBlocks : [String:SyncEventBlockHandler] = [:]
    
    override init() {
        super.init()
        
        self.keychain = Keychain(service: "com.masterofcode-llc.FitpaySDK")
        self.deviceInterface = PaymentDeviceBLEInterface(paymentDevice: self)
    }
    
    internal func sendAPDUData(data: NSData, completion: APDUResponseHandler) {
        self.apduResponseHandler = completion
        self.deviceInterface.sendAPDUData(data)
    }
    
    internal func sync(commits:[Commit]) -> ErrorType? {
        guard self.deviceInfo != nil else {
            return NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDevice.self, message: "Device data not collected.")
        }
        
        for commit in commits {
            guard let commitType = commit.commitType, payload = commit.payload?.payloadDictionary else {
                continue
            }
            
            if let syncEventCompletion = self.syncEventsBlocks[commitType.rawValue] {
                syncEventCompletion(eventPayload: payload)
            }
        }
        
        if let commitId = commits.last?.commit {
            saveLastSynchronizedCommitId(commitId)
        }
        
        return nil
    }
    
    internal func saveLastSynchronizedCommitId(commitId : String) {
        guard let deviceInfo = self.deviceInfo, let serialNumber = deviceInfo.serialNumber else {
            return
        }
        
        keychain[serialNumber] = commitId
    }
}
