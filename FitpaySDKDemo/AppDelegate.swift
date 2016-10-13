//
//  AppDelegate.swift
//  FitpaySDKDemo
//
//  Created by Igor Kravchenko on 3/22/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit
import FitpaySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let restSession = RestSession(clientId: "fp_webapp_pJkVp2Rl", redirectUri: "https://webapp.fit-pay.com", authorizeURL: AUTHORIZE_URL, baseAPIURL: API_BASE_URL)
    var restClient:RestClient?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let restClient = RestClient(session: self.restSession)
        let loginViewController = LoginViewController()
        loginViewController.restSession = self.restSession
        loginViewController.restClient = restClient
        self.restClient = restClient
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = loginViewController
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

