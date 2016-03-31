
import UIKit

struct Item<T>
{
    let id:T
    let title:String
    let details:String
    let drilldown:Bool
    let useSwitcher:Bool
    let isSwitcherOn:Bool
    
}

class BaseTableViewController : UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewDataSource = TableViewDataSource()
    var tableViewDelegate = TableViewDelegate()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil ?? "\(BaseTableViewController.self)", bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self.tableViewDataSource
        self.tableView.delegate = self.tableViewDelegate
        self.setupTableView()
    }
    
    func setupTableView()
    {
        
    }
}

class GenericTableViewController<T> : BaseTableViewController
{
    var sections:[[Item<T>]] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil ?? "\(BaseTableViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupTableView()
    {
        self.prepareData()
        
        self.tableViewDataSource.numberOfRowsInSection =
        {
            [unowned self](tableView, section) in
              return self.sections[section].count
        }
        
        self.tableViewDataSource.cellForRowAtIndexPath = self.cellForRowAtIndexPath
            
        self.tableViewDelegate.shouldHighlightRowAtIndexPath = {
            [unowned self](tableView, indexPath) in
            
            return self.sections[indexPath.section][indexPath.row].drilldown
        }
        
        self.tableViewDelegate.didSelectRowAtIndexPath = {
            [unowned self](tableView, indexPath) in
            let item = self.sections[indexPath.section][indexPath.row]
            self.processSelection(item.id, indexPath: indexPath)
        }
        
        self.tableView.reloadData()
    }
    
    func prepareData()
    {
        
    }
    
    func processSelection(row:T, indexPath:NSIndexPath)
    {
        
    }
    
    func cellIdentifierForIndexPath(indexPath:NSIndexPath) -> String
    {
        let cellClass = UITableViewCell.self
        return NSStringFromClass(cellClass)
    }
    
    func cellForIdentifier(cellIdentifier:String) -> UITableViewCell
    {
        return UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
    }
    
    func cellForRowAtIndexPath(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell
    {
        let item = self.sections[indexPath.section][indexPath.row]
        let cellIdentifier = self.cellIdentifierForIndexPath(indexPath)
        let cell:UITableViewCell = (tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ?? self.cellForIdentifier(cellIdentifier))!
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.details
        cell.accessoryType = item.drilldown ? UITableViewCellAccessoryType.DisclosureIndicator
            : UITableViewCellAccessoryType.None
        
        if item.useSwitcher
        {
            if !cell.enableSwitcher
            {
                cell.enableSwitcher = true
            }
            
            if let switcher = cell.switcher
            {
                switcher.on = item.isSwitcherOn
            }

        }
        else
        {
            cell.switcher?.hidden = true
        }
        
        return cell
    }
}



