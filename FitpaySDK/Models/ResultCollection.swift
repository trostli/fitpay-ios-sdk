
class ResultCollection<T>
{
    var limit:Int?
    var offset:Int?
    var totalResults:Int?
    var results:[T]?
    var links:[ResourceLink]?
}
