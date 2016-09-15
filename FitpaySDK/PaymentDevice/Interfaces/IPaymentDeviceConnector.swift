@objc public protocol IPaymentDeviceConnector
{
    func connect()

    func disconnect()
    
    func isConnected() -> Bool
    
    func writeSecurityState(_ state: SecurityNFCState) -> NSError?
    
    func sendDeviceControl(_ state: DeviceControlState) -> NSError?
    
    func sendNotification(_ notificationData: Data) -> NSError?
    
    func executeAPDUCommand(_ apduCommand: APDUCommand)
    
    func deviceInfo() -> DeviceInfo?

    func nfcState() -> SecurityNFCState
    
    func resetToDefaultState()
}
