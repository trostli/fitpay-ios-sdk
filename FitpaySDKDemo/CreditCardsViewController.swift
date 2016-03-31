
import UIKit
import FitpaySDK

enum CreditCardsRow : Int
{
    case CreditCard
}


class CreditCardsViewController: GenericTableViewController<CreditCardsRow>
{
    var creditCardsResult:ResultCollection<CreditCard>?
    
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
        if let creditCardsResult = self.creditCardsResult, let creditCards = creditCardsResult.results
        {
            var items = [Item<CreditCardsRow>]()
            for creditCard in creditCards
            {
                items.append( Item<CreditCardsRow>(id: .CreditCard, title: "Credit Card", details:(creditCard.cardType ?? ""), drilldown: true, useSwitcher:false, isSwitcherOn:false) )
            }
      
            self.sections = [items]
        }
        else
        {
            alert(title: "Error", message: "creditCardsResult is nil", cancelButtonTitle: "OK")
        }
    }
    
    override func processSelection(row:CreditCardsRow, indexPath:NSIndexPath)
    {
        if let creditCardsResult = self.creditCardsResult, let creditCards = creditCardsResult.results
        {
            switch row
            {
            case .CreditCard:
                let singleCreditCardViewController = SingleCreditCardViewController()
                let creditCard = creditCards[indexPath.row]
                singleCreditCardViewController.title = creditCard.cardType
                singleCreditCardViewController.creditCard = creditCard
                self.navigationController?.pushViewController(singleCreditCardViewController, animated: true)
                break
            }
        }
    }
}
