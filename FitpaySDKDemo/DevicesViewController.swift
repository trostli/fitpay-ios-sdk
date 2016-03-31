
import UIKit
import FitpaySDK

enum DeviceRow : Int
{
    case Device
}

class DevicesViewController: GenericTableViewController<DeviceRow>
{
    var devicesResult:ResultCollection<DeviceInfo>?
    
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
        if let devicesResult = self.devicesResult, let devices = devicesResult.results
        {
            var items = [Item<DeviceRow>]()
            for device in devices
            {
                items.append( Item<DeviceRow>(id: .Device, title: "Device", details:(device.deviceName ?? ""), drilldown: true, useSwitcher:false, isSwitcherOn:false) )
            }
            
            self.sections = [items]
        }
        else
        {
            alert(title: "Error", message: "devicesResult is nil", cancelButtonTitle: "OK")
        }
    }
}
