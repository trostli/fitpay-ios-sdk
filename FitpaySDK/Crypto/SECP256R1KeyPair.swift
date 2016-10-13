
class SECP256R1KeyPair
{
    static let sharedInstance = SECP256R1KeyPair()

    fileprivate let keyPair = SECP256R1KeyPairContainer()

    var publicKey:String?
    {
        return self.keyPair.publicKey
    }

    var privateKey:String?
    {
        return self.keyPair.privateKey
    }
    
    func generateSecretForPublicKey(_ publicKey:String) -> Data?
    {
        return self.keyPair.generateSecret(forPublicKey: publicKey)
    }
}
