//
//  FitpaySDKConfiguration.swift
//  FitpaySDK
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

public class FitpaySDKConfiguration {
    public static let defaultConfiguration = FitpaySDKConfiguration()
    
    public var clientId : String
    public var clientSecret : String
    public var redirectUri : String
    public var baseAuthURL : String
    public var baseAPIURL : String
    public var webViewURL : String
    
    public init() {
        self.clientId = "pagare"
        self.redirectUri = BASE_URL
        self.baseAuthURL = AUTHORIZE_BASE_URL
        self.baseAPIURL = API_BASE_URL
        self.webViewURL = BASE_URL
        self.clientSecret = self.clientId
    }
    
    public init(clientId: String, clientSecret: String, redirectUri: String, baseAuthURL: String, baseAPIURL: String, webViewURL: String = BASE_URL) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.baseAuthURL = baseAuthURL
        self.baseAPIURL = baseAPIURL
        self.webViewURL = webViewURL
    }
    
    
    enum EnvironmentLoadingErrors : ErrorType {
        case ClientIdIsEmpty
        case ClientSecretIsEmpty
        case BaseApiUrlIsEmpty
        case AuthorizeURLIsEmpty
    }
    
    public func loadEnvironmentVariables() -> ErrorType? {
        let envDict = NSProcessInfo.processInfo().environment

        //cleintId checks
        guard let clientId = envDict["SDK_CLIENT_ID"] else {
            return EnvironmentLoadingErrors.ClientIdIsEmpty
        }
        
        guard clientId.characters.count > 0 else {
            return EnvironmentLoadingErrors.ClientIdIsEmpty
        }
        
        //clientSecret checks
        guard let clientSecret = envDict["SDK_CLIENT_SECRET"] else {
            return EnvironmentLoadingErrors.ClientSecretIsEmpty
        }
        
        guard clientSecret.characters.count > 0 else {
            return EnvironmentLoadingErrors.ClientSecretIsEmpty
        }
        
        //baseAPIUrl checks
        guard let baseAPIUrl = envDict["SDK_API_BASE_URL"] else {
            return EnvironmentLoadingErrors.BaseApiUrlIsEmpty
        }
        
        guard baseAPIUrl.characters.count > 0 else {
            return EnvironmentLoadingErrors.BaseApiUrlIsEmpty
        }
        
        //baseAuthBaseUrl checks
        guard let baseAuthBaseUrl = envDict["SDK_AUTHORIZE_BASE_URL"] else {
            return EnvironmentLoadingErrors.AuthorizeURLIsEmpty
        }
        
        guard baseAuthBaseUrl.characters.count > 0 else {
            return EnvironmentLoadingErrors.AuthorizeURLIsEmpty
        }
        
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.baseAuthURL = baseAuthBaseUrl
        self.baseAPIURL = baseAPIUrl
        
        return nil
    }
}