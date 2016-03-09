
import ObjectMapper

public class Asset
{
    var text:String?
    var image:UIImage?
    var data:NSData?
    
    init(text:String)
    {
        self.text = text
    }
    
    init(image:UIImage)
    {
        self.image = image
    }
    
    init(data:NSData)
    {
        self.data = data
    }
}