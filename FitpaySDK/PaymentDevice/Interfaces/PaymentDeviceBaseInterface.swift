public protocol PaymentDeviceBaseInterface
{
    init(paymentDevice device:PaymentDevice)
    
    func connect()
    func disconnect()
    
    func isConnected() -> Bool
    
    func writeSecurityState(state:PaymentDevice.SecurityState) -> ErrorType?
    
    func sendDeviceReset() -> ErrorType?
    
    func sendAPDUData(data: NSData)
    
    func deviceInfo() -> DeviceInfo?
    
    func resetToDefaultState()
}
