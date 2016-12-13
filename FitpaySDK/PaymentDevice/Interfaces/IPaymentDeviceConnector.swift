
@objc public protocol IPaymentDeviceConnector
{
    func connect()

    func disconnect()
    
    func isConnected() -> Bool
    
    func validateConnection(completion : @escaping (_ isValid:Bool, _ error: NSError?) -> Void)
    
    func writeSecurityState(_ state: SecurityNFCState) -> NSError?
    
    func sendDeviceControl(_ state: DeviceControlState) -> NSError?
    
    func sendNotification(_ notificationData: Data) -> NSError?
    
    @objc optional func onPreApduPackageExecute(_ apduPackage: ApduPackage)
    
    func executeAPDUCommand(_ apduCommand: APDUCommand)
    
    @objc optional func onPostApduPackageExecute(_ apduPackage: ApduPackage)

    func deviceInfo() -> DeviceInfo?

    func nfcState() -> SecurityNFCState
    
    func resetToDefaultState()
}
