//
//  NotificationsManager.swift
//  FitpaySDK
//
//  Created by Anton on 19.08.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

public enum NotificationsType : String {
    case WithSync = "sync"
    case WithoutSync = "withoutsync"
}

public enum NotificationsEventType : Int, FitpayEventTypeProtocol {
    case ReceivedSyncNotification = 0x1
    case ReceivedSimpleNotification
    
    /**
     *  AllNotificationsProcessed event called when processing of notification finished e.g.
     *  sync with peyment device ect...
     *  If processing was done in background, than in completion for this event you should call
     *  fetchCompletionHandler from
     *  application(_:didReceiveRemoteNotification:fetchCompletionHandler:).
     */
    case AllNotificationsProcessed
    
    public func eventId() -> Int {
        return rawValue
    }
    
    public func eventDescription() -> String {
        switch self {
        case .ReceivedSyncNotification:
            return "Received notification with sync operation"
        case .ReceivedSimpleNotification:
            return "Received simple notification without sync operation"
        case .AllNotificationsProcessed:
            return "All notification processed"
        }
    }
}

public class FitpayNotificationsManager : NSObject {
    public static let sharedInstance = FitpayNotificationsManager()

    override public init() {
        super.init()
    }
    
    public typealias NotificationsPayload = [NSObject : AnyObject]
    
    /**
     Handle notification from Fitpay platform. It may call syncing process and other stuff.
     When all notifications processed we should receive AllNotificationsProcessed event. In completion
     (or in other place where handling of hotification completed) to this event
     you should call fetchCompletionHandler if this function was called from background.
     
     - parameter payload: payload of notification
     */
    public func handleNotification(payload: NotificationsPayload) {
        notificationsQueue.enqueue(payload)
        
        processNextNotificationIfAvailable()
    }
    
    /**
     Saves notification token after next sync process.
     
     - parameter token: notifications token which should be provided by Firebase
     */
    public func updateNotificationsToken(token: String) {
        notificationsToken = token
        
        SyncManager.sharedInstance.currentDeviceInfo?.updateNotificationTokenIfNeeded()
    }
    
    /**
     Completion handler
     
     - parameter event: Provides event with payload in eventData property
     */
    public typealias NotificationsEventBlockHandler = (event:FitpayEvent) -> Void
    
    /**
     Binds to the event using NotificationsEventType and a block as callback.
     
     - parameter eventType: type of event which you want to bind to
     - parameter completion: completion handler which will be called
     */
    public func bindToEvent(eventType eventType: NotificationsEventType, completion: NotificationsEventBlockHandler) -> FitpayEventBinding? {
        return eventsDispatcher.addListenerToEvent(FitpayBlockEventListener(completion: completion), eventId: eventType)
    }
    
    /**
     Binds to the event using NotificationsEventType and a block as callback.
     
     - parameter eventType: type of event which you want to bind to
     - parameter completion: completion handler which will be called
     - parameter queue: queue in which completion will be called
     */
    public func bindToEvent(eventType eventType: NotificationsEventType, completion: NotificationsEventBlockHandler, queue: dispatch_queue_t) -> FitpayEventBinding? {
        return eventsDispatcher.addListenerToEvent(FitpayBlockEventListener(completion: completion, queue: queue), eventId: eventType)
    }
    
    /**
     Removes bind.
     */
    public func removeSyncBinding(binding binding: FitpayEventBinding) {
        eventsDispatcher.removeBinding(binding)
    }
    
    /**
     Removes all synchronization bindings.
     */
    public func removeAllSyncBindings() {
        eventsDispatcher.removeAllBindings()
    }
    
    // MARK: internal
    internal var notificationsToken : String = ""
    
    // MARK: private
    private let eventsDispatcher = FitpayEventDispatcher()
    private var syncCompletedBinding : FitpayEventBinding?
    private var syncFailedBinding : FitpayEventBinding?
    private var notificationsQueue = [NotificationsPayload]()
    private var currentNotification : NotificationsPayload?
    
    private func processNextNotificationIfAvailable() {
        guard currentNotification == nil else {
            return
        }
        
        if notificationsQueue.peekAtQueue() == nil {
            self.callAllNotificationProcessedCompletion()
            return
        }
        
        self.currentNotification = notificationsQueue.dequeue()
        if let currentNotification = self.currentNotification {
            var notificationType = NotificationsType.WithoutSync

            if (currentNotification["fpField1"] as? String)?.lowercaseString == "sync" {
                notificationType = NotificationsType.WithSync
            }
            
            callReceivedCompletion(currentNotification, notificationType: notificationType)
            switch notificationType {
            case .WithSync:
                if let syncCompletedBinding = self.syncCompletedBinding {
                    SyncManager.sharedInstance.removeSyncBinding(binding: syncCompletedBinding)
                }
                syncCompletedBinding = SyncManager.sharedInstance.bindToSyncEvent(eventType: SyncEventType.SYNC_COMPLETED, completion: { (event) in
                    self.currentNotification = nil
                    self.processNextNotificationIfAvailable()
                })
                
                if let syncFailedBinding = self.syncFailedBinding {
                    SyncManager.sharedInstance.removeSyncBinding(binding: syncFailedBinding)
                }
                syncFailedBinding = SyncManager.sharedInstance.bindToSyncEvent(eventType: SyncEventType.SYNC_FAILED, completion: { (event) in
                    self.currentNotification = nil
                    self.processNextNotificationIfAvailable()
                })
                
                if let _ = SyncManager.sharedInstance.tryToMakeSyncWithLastUser() {
                    self.currentNotification = nil
                    self.processNextNotificationIfAvailable()
                }
                
                break
            case .WithoutSync: // just call completion
                self.currentNotification = nil
                processNextNotificationIfAvailable()
                break
            }
        }
    }
    
    private func callReceivedCompletion(payload: NotificationsPayload, notificationType: NotificationsType) {
        var eventType : NotificationsEventType
        switch notificationType {
        case .WithSync:
            eventType = .ReceivedSyncNotification
            break
        case .WithoutSync:
            eventType = .ReceivedSimpleNotification
            break
        }
        
        eventsDispatcher.dispatchEvent(FitpayEvent(eventId: eventType, eventData: payload))
    }
    
    private func callAllNotificationProcessedCompletion() {
        eventsDispatcher.dispatchEvent(FitpayEvent(eventId: NotificationsEventType.AllNotificationsProcessed, eventData: [:]))
    }
}
