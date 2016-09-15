
internal protocol SecretApplyable
{
    func applySecret(_ secret:Foundation.Data, expectedKeyId:String?)
}
