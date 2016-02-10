
import Foundation
/**
 FitPay uses conventional HTTP response codes to indicate success or failure of an API request. In general, codes in the 2xx range indicate success, codes in the 4xx range indicate an error that resulted from the provided information (e.g. a required parameter was missing, etc.), and codes in the 5xx range indicate an error with FitPay servers.
 
 Not all errors map cleanly onto HTTP response codes, however. When a request is valid but does not complete successfully (e.g. a card is declined), we return a 402 error code.
 
 - OK:               Everything worked as expected
 - BadRequest:       Often missing a required parameter
 - Unauthorized:     No valid API key provided
 - RequestFailed:    Parameters were valid but request failed
 - NotFound:         The requested item doesn't exist
 - ServerError[0-3]: Something went wrong on FitPay's end
 */
enum ErrorCode : Int
{
    case OK = 200
    case BadRequest = 400
    case Unauthorized = 401
    case RequestFailed = 402
    case NotFound = 404
    case ServerError0 = 500
    case ServerError1 = 502
    case ServerError2 = 503
    case ServerError3 = 504
}
