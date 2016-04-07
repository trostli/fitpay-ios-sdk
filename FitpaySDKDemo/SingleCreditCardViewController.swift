
import FitpaySDK

enum CreditCardRow : Int
{
    case Default,
    State,
    AcceptTerms
}

class SingleCreditCardViewController: GenericTableViewController<CreditCardRow>
{
    var creditCard:CreditCard?
    
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
        if let creditCard = self.creditCard
        {
            self.sections = [
                [
                     Item<CreditCardRow>(id: .Default, title: "Default", details: "", drilldown: false, useSwitcher:true, isSwitcherOn:creditCard.isDefault ?? false, isSwitcherEnabled:self.creditCard?.makeDefaultAvailable ?? false),
                     Item<CreditCardRow>(id: .State, title: "State", details: creditCard.state?.rawValue ?? "", drilldown: false),
                    Item<CreditCardRow>(id: .AcceptTerms, title: "Accept Terms", details: "", drilldown: false, useSwitcher:true, isSwitcherOn:creditCard.termsAssetId == nil, isSwitcherEnabled:creditCard.acceptTermsAvailable),
                ]
            ]
            
            self.didFinishLoadingData()
        }
        else
        {
            alert(title: "Error", message: "creditCard is nil", cancelButtonTitle: "OK")
        }
    }
    
    override func processSwitchForRowAtIndexPath(switcher switcher: UISwitch, indexPath: NSIndexPath)
    {
       if self.view.busy
       {
            return
       }
        
        
        self.view.busy = true
        
        let item = self.sections[indexPath.section][indexPath.row]
        
        switch item.id
        {
        case .Default:
            
            if switcher.on
            {
                self.creditCard?.makeDefault(
                    {
                        [unowned self](pending, creditCard, error) in
                        
                        self.view.busy = false
                        
                        if let error = error as? NSError
                        {
                            alert(title: "Error", message: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "", cancelButtonTitle: "OK")
                        }
                        else
                        {
                            self.creditCard = creditCard
                            self.prepareData()
                        }
                        
                    })
            }
        case .AcceptTerms:
            
            if switcher.on
            {
                self.creditCard?.acceptTerms
                {
                    [unowned self](pending, card, error) in
                    if let error = error as? NSError
                    {
                        alert(title: "Error", message: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "", cancelButtonTitle: "OK")
                    }
                    else
                    {
                        self.creditCard = card
                        self.prepareData()
                    }
                    self.view.busy = false
                }
            }
            
            break
            
        default:
            break
        }
        
        
        
        
    }
}
