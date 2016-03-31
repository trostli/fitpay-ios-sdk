
import UIKit
import FitpaySDK

enum UserRow : Int
{
    case email,
    userName,
    birthDay,
    creditCards,
    devices
}

class UserInfoViewController : GenericTableViewController<UserRow>
{
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
        if let user = self.user
        {
            self.sections = [
                [
                    Item<UserRow>(id: .email, title: "Email", details:(user.email ?? ""), drilldown: false, useSwitcher:false, isSwitcherOn:false),
                    Item<UserRow>(id: .userName, title: "User Name", details:(user.firstName ?? "") + " " + (user.lastName ?? ""), drilldown: false, useSwitcher:false, isSwitcherOn:false),
                    Item<UserRow>(id: .birthDay, title: "Birthdate", details:user.birthDate ?? "", drilldown: false, useSwitcher:false, isSwitcherOn:false),
                    Item<UserRow>(id: .creditCards, title: "Credit cards", details:"", drilldown: true, useSwitcher:false, isSwitcherOn:false),
                    Item<UserRow>(id: .devices, title: "Devices", details:"", drilldown: true, useSwitcher:false, isSwitcherOn:false),
                ]
            ]
        }
        else
        {
            alert(title: "Error", message: "user is nil", cancelButtonTitle: "OK")
        }
    }
    
    override func processSelection(row: UserRow, indexPath:NSIndexPath)
    {
        switch row
        {
        case .creditCards:
            self.loadCreditCards()
        case .devices:
            self.loadDevices()
        default:
            break
        }
    }
    
    private func loadCreditCards()
    {
        self.view.busy = true
        self.user?.listCreditCards(excludeState: [], limit: 20, offset: 0, completion:
        {
            [unowned self](result, error) -> Void in
            
            if let result = result
            {
                let creditCardsViewController = CreditCardsViewController()
                creditCardsViewController.title = "Credit Cards"
                creditCardsViewController.creditCardsResult = result
                self.navigationController?.pushViewController(creditCardsViewController, animated: true)
                
            }
            else if let error = error as? NSError
            {
                alert(title: "Error", message:error.userInfo[NSLocalizedDescriptionKey] as? String, cancelButtonTitle: "OK")
            }
            
            self.view.busy = false
        })
    }
    
    private func loadDevices()
    {
        self.view.busy = true
        self.user?.listDevices(100, offset: 0, completion:
        {
            [unowned self](result, error) -> Void in
            if let result = result
            {
                let devicesViewController = DevicesViewController()
                devicesViewController.title = "Devices"
                devicesViewController.devicesResult = result
                self.navigationController?.pushViewController(devicesViewController, animated: true)
                
            }
            else if let error = error as? NSError
            {
                alert(title: "Error", message:error.userInfo[NSLocalizedDescriptionKey] as? String, cancelButtonTitle: "OK")
            }
            
            self.view.busy = false
        })

    }
}
