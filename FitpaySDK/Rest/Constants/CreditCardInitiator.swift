
/**
 Identifies the party initiating the deactivation/reactivation request
 
 - CARDHOLDER: card holder
 - ISSUER:     issuer
 */
public enum CreditCardInitiator: String
{
    case CARDHOLDER = "CARDHOLDER"
    case ISSUER = "ISSUER"
}