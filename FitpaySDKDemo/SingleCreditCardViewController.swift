
import FitpaySDK

enum CreditCardRow : Int
{
    case Default
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
                    Item<CreditCardRow>(id: .Default, title: "Default", details: "", drilldown: false, useSwitcher:true, isSwitcherOn:creditCard.isDefault ?? false),
                ]
            ]
        }
        else
        {
            alert(title: "Error", message: "creditCard is nil", cancelButtonTitle: "OK")
        }
    }
}
