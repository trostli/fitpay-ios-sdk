
import UIKit
import FitpaySDK

enum DeviceRow : Int
{
    case Device
}

class DevicesViewController: GenericTableViewController<DeviceRow>
{
    var devicesResult:ResultCollection<DeviceInfo>?
    var user:User?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil ?? "\(BaseTableViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareData()
    {
        self.view.busy = true
        self.user?.listDevices(limit: 100, offset: 0, completion:
        {
            [unowned self](result, error) -> Void in
            if let devicesResult = result, let devices = devicesResult.results
            {
                var items = [Item<DeviceRow>]()
                for device in devices
                {
                    items.append( Item<DeviceRow>(id: .Device, title: "Device", details:(device.deviceName ?? ""), drilldown: true, useSwitcher:false, isSwitcherOn:false) )
                }
                
                self.sections = [items]
                self.devicesResult = devicesResult
                self.didFinishLoadingData()
            }
            else if let error = error
            {
                alert(title: "Error", message:error.userInfo[NSLocalizedDescriptionKey] as? String, cancelButtonTitle: "OK")
            }
            
            self.view.busy = false
        })
    }
}
