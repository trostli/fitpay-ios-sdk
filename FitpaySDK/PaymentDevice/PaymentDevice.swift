import KeychainAccess

public class PaymentDevice : NSObject
{
    public enum ErrorCode : Int, ErrorType, RawIntValue, CustomStringConvertible
    {
        case UnknownError = 0
        case BadBLEState = 10001
        case DeviceDataNotCollected = 10002
        case WaitingForAPDUResponse = 10003
        case APDUPacketCorrupted = 10004
        case OperationTimeout = 10005
        case DeviceShouldBeDisconnected = 10006
        
        public var description : String {
            switch self {
            case .UnknownError:
                return "Unknown error"
            case .BadBLEState:
                return "Can't connect to the device. BLE state: %d."
            case .DeviceDataNotCollected:
                return "Device data not collected."
            case .WaitingForAPDUResponse:
                return "Waiting for APDU response."
            case .APDUPacketCorrupted:
                return "APDU packet checksum is not equal."
            case .OperationTimeout:
                return "Connection timeout. Can't find device."
            case .DeviceShouldBeDisconnected:
                return "Payment device should be disconnected."
            }
        }
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
                        onDeviceConnected(deviceInfo: nil, error: NSError.error(code: PaymentDevice.ErrorCode.OperationTimeout, domain: PaymentDevice.self))
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
    
    /**
     Changes interface with payment device. Default is BLE (PaymentDeviceBLEInterface).
     If you want to implement your own interface than it should confirm PaymentDeviceBaseInterface protocol.
     Can be changed if device disconnected.
     */
    public func changeDeviceInterface(interface: PaymentDeviceBaseInterface) -> ErrorType? {
        if isConnected {
            return NSError.error(code: PaymentDevice.ErrorCode.DeviceShouldBeDisconnected, domain: PaymentDeviceBLEInterface.self)
        }
        
        self.deviceInterface = interface
        return nil
    }
    
    internal var deviceInterface : PaymentDeviceBaseInterface!
    
    internal typealias APDUResponseHandler = (apduResponse:ApduResultMessage?, error:ErrorType?)->Void
    internal var apduResponseHandler : APDUResponseHandler?
    
    override init() {
        super.init()
        
        self.deviceInterface = PaymentDeviceBLEInterface(paymentDevice: self)
    }
    
    internal func sendAPDUData(data: NSData, completion: APDUResponseHandler) {
        self.apduResponseHandler = completion
        self.deviceInterface.sendAPDUData(data)
    }
    
}
