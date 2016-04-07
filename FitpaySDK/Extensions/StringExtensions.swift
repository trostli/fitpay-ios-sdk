extension String {
    var SHA1:String? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            return data.SHA1
        }
        
        return nil
    }
}