
internal protocol SecretApplyable
{
    func applySecret(secret:Foundation.NSData, expectedKeyId:String?)
}
