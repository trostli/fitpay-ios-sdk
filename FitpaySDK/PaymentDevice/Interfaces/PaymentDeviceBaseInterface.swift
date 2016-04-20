public protocol PaymentDeviceBaseInterface
{
    init(paymentDevice device:PaymentDevice)
    
    func connect()
    func disconnect()
    
    func isConnected() -> Bool
    
    func writeSecurityState(state: SecurityNFCState) -> ErrorType?
    
    func sendDeviceControl(state: DeviceControlState) -> ErrorType?
    
    func sendNotification(notificationData: NSData) -> ErrorType?
    
    func sendAPDUData(data: NSData, sequenceNumber: UInt16)
    
    func deviceInfo() -> DeviceInfo?
    func nfcState() -> SecurityNFCState?
    
    func resetToDefaultState()
}
