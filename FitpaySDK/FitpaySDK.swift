//
//  FitpaySDK.swift
//  FitpaySDK
//
//  Created by Benjamin Walford on 12/15/15.
//  Copyright © 2015 Fitpay. All rights reserved.
//

import Foundation
import Alamofire

open class Test {
    public init() {}
    
    open func getApiHealth(_ callback: @escaping (_ arg: String) -> Void) {
        var url = "https://httpbin.org/get"
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        /*Alamofire.request(
            .GET, url, parameters: nil)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result.value)   // result of response serialization
                
                if let JSON = response.result.value {
                    callback(arg: "JSON: \(JSON)")
                }
            }*/
    }
}
