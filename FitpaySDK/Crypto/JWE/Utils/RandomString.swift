extension String {
    static func random(size: Int) -> String {
        var randomNum = ""
        var randomBytes = [UInt8](count: size, repeatedValue: 0)
        
        SecRandomCopyBytes(kSecRandomDefault, size, &randomBytes)
        
        // Turn randomBytes into array of hexadecimal strings
        // Join array of strings into single string
        randomNum = randomBytes.map({String(format: "%02hhx", $0)}).joinWithSeparator("")
        
        return randomNum.subString(0, length: size)
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        let start = self.startIndex.advancedBy(startIndex)
        let end = self.startIndex.advancedBy(startIndex + length)
        return self.substringWithRange(start ..< end)
    }
}