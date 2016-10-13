
extension Array
{
    var JSONString:String?
    {
        return Foundation.JSONSerialization.JSONString(self as AnyObject)
    }
}

extension Array where Element : ResourceLink
{
    func url(_ resource:String) -> String?
    {
        for link in self
        {
            if let target = link.target , target == resource
            {
                return link.href
            }
        }
        
        return nil
    }
}

extension Array where Element : Equatable {
    mutating func removeObject(_ object : Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

//Stack - LIFO
extension Array {
    mutating func push(_ newElement: Element) {
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
    mutating func enqueue(_ newElement: Element) {
        self.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        return self.remove(at: 0)
    }
    
    func peekAtQueue() -> Element? {
        return self.first
    }
}
