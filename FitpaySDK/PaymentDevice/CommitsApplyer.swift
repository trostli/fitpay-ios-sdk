
internal class CommitsApplyer {
    private var commits : [Commit]!
    private let semaphore = dispatch_semaphore_create(0)
    private var thread : NSThread?
    private var applyerCompletionHandler : ApplyerCompletionHandler!
    private var totalApduCommands = 0
    private var appliedApduCommands = 0
    
    internal var isRunning : Bool {
        guard let thread = self.thread else {
            return false
        }
        
        return thread.executing
    }
    
    internal typealias ApplyerCompletionHandler = (error: ErrorType?)->Void
    
    internal func apply(commits:[Commit], completion: ApplyerCompletionHandler) -> Bool {
        if isRunning {
            return false
        }
        
        self.commits = commits
        
        totalApduCommands = 0
        appliedApduCommands = 0
        for commit in commits {
            if commit.commitType == CommitType.APDU_PACKAGE {
                if let apduCommandsCount = commit.payload?.apduPackage?.apduCommands?.count {
                    totalApduCommands += apduCommandsCount
                }
            }
        }
        
        self.applyerCompletionHandler = completion
        self.thread = NSThread(target: self, selector:#selector(CommitsApplyer.processCommits), object: nil)
        self.thread?.start()
        
        return true
    }
    
    @objc private func processCommits() {
        var commitsApplied = 0
        for commit in commits {
            var errorItr : ErrorType? = nil
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            {
                self.processCommit(commit)
                {
                    (error) -> Void in
                    errorItr = error
                    dispatch_semaphore_signal(self.semaphore)
                }
            })
            
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            
            if let error = errorItr {
                dispatch_async(dispatch_get_main_queue(),
                {
                    self.applyerCompletionHandler(error: error)
                })
                return
            }
            
            commitsApplied += 1
            
            SyncManager.sharedInstance.callCompletionForSyncEvent(SyncEventType.SYNC_PROGRESS, params: ["applied":commitsApplied, "total":commits.count])
        }
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.applyerCompletionHandler(error: nil)
        })
    }
    
    private typealias CommitCompletion = (error: ErrorType?)->Void
    
    private func processCommit(commit: Commit, completion: CommitCompletion) {
        guard let commitType = commit.commitType else {
            completion(error: NSError.unhandledError(SyncManager.self))
            return
        }
        
        let commitCompletion = { (error: ErrorType?) -> Void in
            if error == nil {
                SyncManager.sharedInstance.syncStorage.lastCommitId = commit.commit
            }
            
            completion(error: error)
        }
        
        switch (commitType) {
        case CommitType.APDU_PACKAGE:
            processAPDUCommit(commit, completion: commitCompletion)
        default:
            processNonAPDUCommit(commit, completion: commitCompletion)
        }
    }
    
    private func processAPDUCommit(commit: Commit, completion: CommitCompletion) {
        guard let apduPackage = commit.payload?.apduPackage else {
            completion(error: NSError.unhandledError(SyncManager.self))
            return
        }
        
        let applyingStartDate = NSDate().timeIntervalSince1970
        
        
        if apduPackage.isExpired {
            apduPackage.state = APDUPackageResponseState.EXPIRED
            
            // is this error?
            commit.confirmAPDU(
            {
                (error) -> Void in
                completion(error: error)
            })
            
            return
        }
        
        self.applyAPDUPackage(apduPackage, apduCommandIndex: 0)
        {
            (error) -> Void in

            let currentTimestamp = NSDate().timeIntervalSince1970
            
            apduPackage.executedDuration = Int(currentTimestamp - applyingStartDate)
            apduPackage.executedEpoch = CLong(currentTimestamp)
            
            if apduPackage.isExpired {
                apduPackage.state = APDUPackageResponseState.EXPIRED
                
                commit.confirmAPDU(
                {
                    (error) -> Void in
                    completion(error: error)
                })
                
                return
            }
            
            var hasCommandError = false
            for command in apduPackage.apduCommands! {
                if command.responseType == APDUResponseType.Error {
                    hasCommandError = true
                    break
                }
            }
            
            if error != nil {
                apduPackage.state = APDUPackageResponseState.ERROR
            } else if hasCommandError {
                apduPackage.state = APDUPackageResponseState.FAILED
            } else {
                apduPackage.state = APDUPackageResponseState.PROCESSED
            }
            
            //TODO: uncomment this when apdu will be implemented on backend
//            commit.confirmAPDU(
//            {
//                (confirmError) -> Void in
//                completion(error: error ?? confirmError)
//            })
            completion(error: error)
        }
    }
    
    private func processNonAPDUCommit(commit: Commit, completion: CommitCompletion) {
        guard let _ = commit.commitType else {
            return
        }
        
        SyncManager.sharedInstance.callCompletionForSyncEvent(SyncEventType.COMMIT_PROCESSED, params: ["commit":commit])
        
        
        completion(error: nil)
    }
    
    private func applyAPDUPackage(apduPackage: ApduPackage, apduCommandIndex: Int, completion: (error:ErrorType?)->Void) {
        let isFinished = apduPackage.apduCommands?.count <= apduCommandIndex
        
        if isFinished {
            completion(error: nil)
            return
        }
        
        var apdu = apduPackage.apduCommands![apduCommandIndex]
        SyncManager.sharedInstance.paymentDevice.executeAPDUCommand(&apdu, completion:
        {
            [unowned self] (apduPack, error) -> Void in
            
            if let error = error {
                completion(error: error)
                return
            }
            
            self.appliedApduCommands += 1
            
            SyncManager.sharedInstance.callCompletionForSyncEvent(SyncEventType.APDU_COMMANDS_PROGRESS, params: ["applied":self.appliedApduCommands, "total":self.totalApduCommands])
            
            self.applyAPDUPackage(apduPackage, apduCommandIndex: apduCommandIndex + 1, completion: completion)
        })
    }
}