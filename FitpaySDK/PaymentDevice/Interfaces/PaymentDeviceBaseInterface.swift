public protocol PaymentDeviceBaseInterface
{
    init(paymentDevice device:PaymentDevice)
    
    func connect()
    func disconnect()
    
    func isConnected() -> Bool
    
    func writeSecurityState(state:PaymentDevice.SecurityState) -> ErrorType?
    
    func sendDeviceControl(state: PaymentDevice.DeviceControlState) -> ErrorType?
    
    func sendAPDUData(data: NSData, sequenceNumber: UInt16)
    
    func deviceInfo() -> DeviceInfo?
    
    func resetToDefaultState()
}
