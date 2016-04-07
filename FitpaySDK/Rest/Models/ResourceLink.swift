
import Foundation

internal class ResourceLink
{
    var target:String?
    var href:String?
}

import ObjectMapper

internal class ResourceLinkTransformType : TransformType
{
    typealias Object = [ResourceLink]
    typealias JSON = [String:[String:String]]

    func transformFromJSON(value: AnyObject?) -> [ResourceLink]?
    {
        if let links = value as? [String:[String:String]]
        {
            var list = [ResourceLink]()

            for (target, map) in links
            {
                let link = ResourceLink()
                link.target = target
                link.href = map["href"]
                list.append(link)
            }

            return list
        }

        return nil
    }

    func transformToJSON(value:[ResourceLink]?) -> [String:[String:String]]?
    {
        if let links = value
        {
            var map = [String:[String:String]]()

            for link in links
            {
                if let target = link.target, href = link.href
                {
                    map[target] = ["href" : href]
                }
            }

            return map
        }

        return nil
    }
}
