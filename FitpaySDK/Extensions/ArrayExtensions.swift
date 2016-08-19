
extension Array
{
    var JSONString:String?
    {
        return Foundation.NSJSONSerialization.JSONString(self as! AnyObject)
    }
}

extension _ArrayType where Generator.Element == ResourceLink
{
    func url(resource:String) -> String?
    {
        for link in self
        {
            if let target = link.target where target == resource
            {
                return link.href
            }
        }
        
        return nil
    }
}

extension Array where Element : Equatable {
    mutating func removeObject(object : Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

//Stack - LIFO
extension Array {
    mutating func push(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func pop() -> Element? {
        return self.removeLast()
    }
    
    func peekAtStack() -> Element? {
        return self.last
    }
}

//Queue - FIFO
extension Array {
    mutating func enqueue(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        return self.removeAtIndex(0)
    }
    
    func peekAtQueue() -> Element? {
        return self.first
    }
}