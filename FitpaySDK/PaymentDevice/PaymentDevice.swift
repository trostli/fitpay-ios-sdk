
public class PaymentDevice : NSObject
{
    public enum ErrorCode : Int, ErrorType, RawIntValue
    {
        case UnknownError = 0
        case BadBLEState = 10001
        case BLEDataNotCollected = 10002
        case WaitingForAPDUResponse = 10003
        case APDUPacketCorrupted = 10004
    }
    
    public enum SecurityState : Int {
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
     */
    public func connect() {
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
    
    override init() {
        super.init()
        
        self.deviceInterface = PaymentDeviceBLEInterface(paymentDevice: self)
    }
    
    internal typealias APDUResponseHandler = (apduResponse:ApduResultMessage?, error:ErrorType?)->Void
    internal var apduResponseHandler : APDUResponseHandler?
    
    internal func sendAPDUData(data: NSData, completion: APDUResponseHandler) {
        self.apduResponseHandler = completion
        self.deviceInterface.sendAPDUData(data)
    }
    
    internal func sync(commits:[Commit]) {
        
    }
}
