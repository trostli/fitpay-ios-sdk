
public enum PaymentDeviceAlert : String
{
    case TransactionAlert = "TransactionAlert" // - indication a transaction has occurred.
    case SecurityAlert = "SecurityAlert" // - indication that a security event has taken place (i.e. the wearable has been removed, the wearable has been activated/enabled/placed on person).
    case ConnectionAlert = "ConnectionAlert" // - indication on connection status change with the wearable itself.
}


public protocol AlertObserver
{
    func handleAlert(alert:PaymentDeviceAlert)
}


public class PaymentDevice
{
    /**
     Provides current device information
     
     - returns: DeviceInfo object or nil
     */
    public func deviceInfo() -> DeviceInfo?
    {
        return nil
    }

    /**
     Sets current device information
     
     - parameter deviceInfo: DeviceInfo object
     */
    public func setDeviceInfo(deviceInfo:DeviceInfo)
    {

    }

    /**
     Adds observer for a specific alert
     
     - parameter observer: object that that confirmes to AlertObserver protocol
     - parameter alert:    PaymentDeviceAlert enum
     */
    public func addAlertObserver(observer:AlertObserver, alert:PaymentDeviceAlert)
    {

    }

    /**
     Removes observer for a specific alert
     
     - parameter observer: object that that confirmes to AlertObserver protocol
     - parameter alert:    PaymentDeviceAlert enum
     */
    public func removeAlertObserver(observer:AlertObserver, alert:PaymentDeviceAlert)
    {

    }
}
