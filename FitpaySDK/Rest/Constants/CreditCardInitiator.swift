
/**
 Identifies the party initiating the deactivation/reactivation request
 
 - CARDHOLDER: card holder
 - ISSUER:     issuer
 */
enum CreditCardInitiator: String
{
    case CARDHOLDER = "CARDHOLDER"
    case ISSUER = "ISSUER"
}