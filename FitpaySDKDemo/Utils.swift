
import Foundation
import UIKit

func alert(title title:String?, message:String?, cancelButtonTitle:String, delegate:UIAlertViewDelegate? = nil)
{
    let view = UIAlertView(title: title, message:message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)
    view.show()
}

internal enum Tags : Int
{
    case busyView = 10001,
    switcher
}

extension UIView
{
    private var busyTag:Int
    {
        return Tags.busyView.rawValue
    }
    
    var busy:Bool
    {
        get
        {
            return self.viewWithTag(self.busyTag) != nil
        }
        
        set
        {
            if let view = self.viewWithTag(self.busyTag)
            {
                if newValue
                {
                    view.superview?.bringSubviewToFront(view)
                }
                else
                {
                    view.removeFromSuperview()
                }
            }
            else
            {
                if newValue
                {
                    let rect = self.bounds
                    let bgView = UIView(frame: rect)
                    bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
                    bgView.frame = rect
                    bgView.tag = self.busyTag
                    
                    let view = UIActivityIndicatorView()
                    view.activityIndicatorViewStyle = .Gray
                    view.sizeToFit()
                    view.hidden = false
                    view.startAnimating()
                    view.center = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
                    bgView.addSubview(view)
                    self.addSubview(bgView)
                }
            }
        }
    }
}

class TableViewDataSource : NSObject, UITableViewDataSource
{
    var numberOfRowsInSection:((tableView: UITableView, section: Int)->Int)?
    var cellForRowAtIndexPath:((tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell)?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        assert(self.numberOfRowsInSection != nil)
        return self.numberOfRowsInSection!(tableView: tableView, section: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        assert(self.cellForRowAtIndexPath != nil)
        return cellForRowAtIndexPath!(tableView:tableView, indexPath: indexPath)
    }
}

class TableViewDelegate : NSObject, UITableViewDelegate
{
    var shouldHighlightRowAtIndexPath:((tableView: UITableView, indexPath: NSIndexPath) -> Bool)?
    var willSelectRowAtIndexPath:((tableView: UITableView, indexPath: NSIndexPath) -> NSIndexPath?)?
    var didSelectRowAtIndexPath:((tableView: UITableView, indexPath: NSIndexPath) -> Void)?
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if let shouldHighlightRowAtIndexPath = self.shouldHighlightRowAtIndexPath
        {
            return shouldHighlightRowAtIndexPath(tableView: tableView, indexPath: indexPath)
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        if let willSelectRowAtIndexPath = self.willSelectRowAtIndexPath
        {
            return willSelectRowAtIndexPath(tableView: tableView, indexPath: indexPath)
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.didSelectRowAtIndexPath?(tableView:tableView, indexPath:indexPath)
    }
    

}

extension UITableViewCell
{
    private var switcherTag:Int
    {
        return Tags.switcher.rawValue
    }
    
    var enableSwitcher:Bool
    {
        get
        {
            return self.switcher != nil
        }
        
        set
        {
            if let switcher = self.switcher
            {
                newValue ? self.bringSubviewToFront(switcher) : switcher.removeFromSuperview()
            }
            else
            {
                if newValue
                {
                    let switcher = UISwitch()
                    switcher.sizeToFit()
                    switcher.tag = self.switcherTag
                    switcher.center = CGPoint(x:CGRectGetWidth(self.bounds) - CGRectGetWidth(switcher.bounds), y: CGRectGetMidY(self.bounds))
                    self.addSubview(switcher)
                }
            }
        }
    }
    
    var switcher:UISwitch?
    {
       return self.viewWithTag(self.switcherTag) as? UISwitch
    }
}

import ObjectiveC.objc_runtime

private class ClosureWrapper<T>
{
    var closure: ((type:T) -> Void)?
    
    init(_ closure: ((T) -> Void)?)
    {
        self.closure = closure
    }
}


extension UIControl
{
    private struct AssociatedKeys
    {
        static var valueChangeHandlerKey = "\(UIControl.self)_valueChangeHandler"
    }
    
    var valueChangeHandler:((UIControl) -> Void)?
    {
        set
        {
            if let handler = newValue
            {
                
                self.addTarget(self, action: #selector(self.handleChange(_:)), forControlEvents: .ValueChanged)
                objc_setAssociatedObject(self, &AssociatedKeys.valueChangeHandlerKey, ClosureWrapper<UIControl>(handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            else
            {
                self.removeTarget(self, action: #selector(self.handleChange(_:)), forControlEvents: .ValueChanged)
                 objc_setAssociatedObject(self, &AssociatedKeys.valueChangeHandlerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
            }
        }
        
        get
        {
            return (objc_getAssociatedObject(self, &AssociatedKeys.valueChangeHandlerKey) as? ClosureWrapper<UIControl>)?.closure
        }
    }
    
    @objc private func handleChange(sender:UIControl)
    {
       self.valueChangeHandler?(sender)
    }
}


