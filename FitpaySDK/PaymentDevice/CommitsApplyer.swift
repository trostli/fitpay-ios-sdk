
internal class CommitsApplyer {
    private var commits : [Commit]!
    private let semaphore = dispatch_semaphore_create(0)
    private var thread : NSThread?
    private var applyerCompletionHandler : ApplyerCompletionHandler!
    
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
        
        self.applyerCompletionHandler = completion
        self.thread = NSThread(target: self, selector:"processCommits", object: nil)
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
        
        self.applyAPDUPackage(apduPackage, apduCommandIndex: 0)
        {
            (error) -> Void in
            
            //TODO: send response here
            
            completion(error: error)
        }
    }
    
    private func processNonAPDUCommit(commit: Commit, completion: CommitCompletion) {
        guard let commitType = commit.commitType else {
            return
        }
        
        if let eventType = SyncEventType(rawValue: commitType.rawValue) {
            SyncManager.sharedInstance.callCompletionForSyncEvent(eventType, params: ["commit":commit])
        }
        
        completion(error: nil)
    }
    
    private func applyAPDUPackage(apduPackage: ApduPackage, apduCommandIndex: Int, completion: (error:ErrorType?)->Void) {
        let isFinished = apduPackage.commands?.count <= apduCommandIndex
        
        if isFinished {
            completion(error: nil)
            return
        }
        
        let apdu = apduPackage.commands![apduCommandIndex]
        SyncManager.sharedInstance.paymentDevice.sendAPDUData(apdu, completion:
        {
            [unowned self] (apduResponse, error) -> Void in
            
            if let error = error {
                completion(error: error)
                return
            }
            
            //TODO: save response here
            
            self.applyAPDUPackage(apduPackage, apduCommandIndex: apduCommandIndex + 1, completion: completion)
        })
    }
}