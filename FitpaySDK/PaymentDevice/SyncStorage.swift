import KeychainAccess

internal class SyncStorage {
    private var keychain : Keychain
    private let keychainFieldName : String = "FitPayLastSyncCommitId"
    
    init() {
        self.keychain = Keychain(service: "com.masterofcode-llc.FitpaySDK")
    }
    
    internal var lastCommitId : String? {
        get {
            return self.keychain[self.keychainFieldName]
        }
        set(newValue) {
            self.keychain[self.keychainFieldName] = newValue
        }
    }
}