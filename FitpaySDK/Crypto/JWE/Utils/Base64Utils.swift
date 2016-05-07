extension NSData {
    func base64URLencoded() -> String {
        var base64 = self.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        base64 = base64.stringByReplacingOccurrencesOfString("/", withString: "_")
        base64 = base64.stringByReplacingOccurrencesOfString("+", withString: "-")
        base64 = base64.stringByReplacingOccurrencesOfString("=", withString: "")
        
        return base64
    }
}

extension String {
    func base64URLencoded() -> String? {
        return self.dataUsingEncoding(NSUTF8StringEncoding)?.base64URLencoded()
    }
    
    func base64URLdecoded() -> NSData? {
        let base64EncodedString = convertBase64URLtoBase64(self)
        if let decodedData = NSData(base64EncodedString: base64EncodedString, options:NSDataBase64DecodingOptions(rawValue: 0)){
            return decodedData
        }
        return nil
    }
    
    private func convertBase64URLtoBase64(encodedString: String) -> String {
        var tempEncodedString = encodedString.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        tempEncodedString = tempEncodedString.stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let equalsToBeAdded = (encodedString as NSString).length % 4
        if (equalsToBeAdded > 0) {
            for _ in 0..<equalsToBeAdded {
                tempEncodedString += "="
            }
        }
        return tempEncodedString
    }
}
