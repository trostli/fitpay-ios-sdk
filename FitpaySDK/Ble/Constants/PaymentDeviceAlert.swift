
import Foundation

enum PaymentDeviceAlert : String
{
    case TransactionAlert = "TransactionAlert" // - indication a transaction has occurred.
    case SecurityAlert = "SecurityAlert" // - indication that a security event has taken place (i.e. the wearable has been removed, the wearable has been activated/enabled/placed on person).
    case ConnectionAlert = "ConnectionAlert" // - indication on connection status change with the wearable itself.
}
