
class SECP256R1KeyPair
{
    static let sharedInstance = SECP256R1KeyPair()

    private let keyPair = SECP256R1KeyPairContainer()

    var publicKey:String?
    {
        return self.keyPair.publicKey
    }

    var privateKey:String?
    {
        return self.keyPair.privateKey
    }
    
    func generateSecretForPublicKey(publicKey:String) -> NSData?
    {
        return self.keyPair.generateSecretForPublicKey(publicKey)
    }
}
