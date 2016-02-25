
import FPCrypto

class Crypto
{
    static let sharedInstance = Crypto()

    private let keyPair = UnsafeMutablePointer<SECP256R1_KeyPair>.alloc(sizeof(SECP256R1_KeyPair))
    
    var publicKey:String
    {
        let key = withUnsafePointer(&keyPair.memory.public_key)
        {
            String.fromCString(UnsafePointer($0))!
        }
        
        return key
    }
    
    var privateKey:String
    {
        let key = withUnsafePointer(&keyPair.memory.private_key)
        {
            String.fromCString(UnsafePointer($0))!
        }
        
        return key
    }
    
    init()
    {
        SECP256R1_GenerateKeyPair(keyPair);
    }

    deinit
    {
        EC_KEY_free(keyPair.memory.key)
        self.keyPair.dealloc(sizeof(SECP256R1_KeyPair))
    }
}
