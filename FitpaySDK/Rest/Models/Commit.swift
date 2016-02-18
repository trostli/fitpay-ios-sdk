
class Commit
{
    var links:[ResourceLink]?
    var commitType:CommitType?
    var payload:Payload?
    var created:Int?
    var previousCommit:String?
    var commit:String?
}

class Payload
{
    var createdEpoch:Int?
    var reason:String?
    var cvv:String?
    var address:Address?
    var externalTokenReference:String?
    var deviceRelationships:[DeviceRelationships]?
    var cardType:String?
    var causedBy:CreditCardInitiator?
    var lastModifiedEpoch:Int?
    var userId:String?
    var created:String?
    var lastModified:String?
    var expMonth:Int?
    var targetDeviceType:String?
    var expYear:Int?
    var targetDeviceId:String?
    var name:String?
    var state:String? //TODO: consider adding enum
    var pan:String?
    var cardMetaData:CardMetadata?
}
