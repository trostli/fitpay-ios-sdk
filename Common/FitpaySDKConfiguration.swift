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
    public var redirectUri : String
    public var authorizeURL : String
    public var baseAPIURL : String
    public var webViewURL : String
    
    public init() {
        self.clientId = "pagare"
        self.redirectUri = BASE_URL
        self.authorizeURL = AUTHORIZE_URL
        self.baseAPIURL = API_BASE_URL
        self.webViewURL = BASE_URL
    }
    
    public init(clientId: String, redirectUri: String, authorizeURL: String, baseAPIURL: String, webViewURL: String = BASE_URL) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.authorizeURL = authorizeURL
        self.baseAPIURL = baseAPIURL
        self.webViewURL = webViewURL
    }
}