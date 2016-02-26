
import FPCrypto

class Crypto
{
    static let sharedInstance = Crypto()

    private let keyPair = UnsafeMutablePointer<SECP256R1_KeyPair>.alloc(sizeof(SECP256R1_KeyPair))

    var publicKey:String?
    {
        let key = withUnsafePointer(&keyPair.memory.public_key)
        {
            String.fromCString(UnsafePointer($0))
        }

        return key
    }

    var privateKey:String?
    {
        let key = withUnsafePointer(&keyPair.memory.private_key)
        {
            String.fromCString(UnsafePointer($0))
        }

        return key
    }
    
    func generateSecretForPublicKey(publicKey: String!) -> NSData?
    {
        guard let cPublicKey = publicKey.cStringUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }
        
        guard cPublicKey.count > 1 else {
            return nil
        }
        
        let secretResult = UnsafeMutablePointer<SECP256R1_SharedSecret>.alloc(sizeof(SECP256R1_SharedSecret))
        
        secp256r1_generate_secret(keyPair, strdup(cPublicKey), secretResult)
        
        let data = NSData(bytes: &secretResult.memory.secret, length: Int(secretResult.memory.secret_size))
        
        secretResult.dealloc(sizeof(SECP256R1_SharedSecret))
        
        return data
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
