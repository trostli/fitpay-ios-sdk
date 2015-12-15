//
//  FitpaySDK.swift
//  FitpaySDK
//
//  Created by Benjamin Walford on 12/15/15.
//  Copyright © 2015 Fitpay. All rights reserved.
//

import Foundation
import Alamofire

public class Test {
    public init() {}
    
    public func getApiHealth(callback: (arg: String) -> Void) {
        var url = "https://httpbin.org/get"
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(
            .GET, url, parameters: nil)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result.value)   // result of response serialization
                
                if let JSON = response.result.value {
                    callback(arg: "JSON: \(JSON)")
                }
            }
    }
}