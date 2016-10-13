import KeychainAccess

internal class SyncStorage {
    fileprivate var keychain : Keychain
    fileprivate let keychainFieldName : String = "FitPayLastSyncCommitId"

    init() {
        self.keychain = Keychain(service: "com.masterofcode-llc.FitpaySDK")
    }

    internal func getLastCommitId(_ deviceId:String) -> String {
        if let commitId = self.keychain[deviceId] {
            return commitId
        } else {
            return String()
        }
    }

    internal func setLastCommitId(_ deviceId:String, commitId:String) -> Void {
        self.keychain[deviceId] = commitId
    }
}
