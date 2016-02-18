
public class ResultCollection<T>
{
    public var limit:Int?
    public var offset:Int?
    public var totalResults:Int?
    public var results:[T]?
    public var links:[ResourceLink]?
}
