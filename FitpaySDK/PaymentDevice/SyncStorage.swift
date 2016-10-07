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
            print("--- returning last commitID \(commitId) ---")
        } else {
            print("--- NO LAST COMMIT ID. So empty string ---")
            return String()
        }
    }

    internal func setLastCommitId(_ deviceId:String, commitId:String) -> Void {
        self.keychain[deviceId] = commitId
    }
}
