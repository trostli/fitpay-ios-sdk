import UIKit
import FitpaySDK

class LoginViewController : UIViewController
{

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    weak var restClient:RestClient?
    weak var restSession:RestSession?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI()
    {
        self.userNameTextField.text = "testableuser2@something.com"
        self.passwordTextField.text = "1029"
        self.loginButton.addTarget(self, action: #selector(LoginViewController.login), forControlEvents: .TouchUpInside)
        
    }
    
    func login()
    {
        if let email = self.userNameTextField.text, let password = self.passwordTextField.text where !email.isEmpty && !password.isEmpty
        {
            self.view.busy = true
            
            self.restSession?.login(username: email, password: password, completion:
            {
                [unowned self](error) -> Void in
                
                self.view.busy = false
                
                if let error = error as? NSError
                {
                    alert(title: "Error", message:error.userInfo[NSLocalizedDescriptionKey] as? String, cancelButtonTitle: "OK")
                }
                else
                {
                    self.restClient?.user(id: (self.restSession?.userId!)!, completion: {
                        [unowned self](user, error) -> Void in
                        
                        if let user = user
                        {
                            let userViewController = UserInfoViewController() //UserViewController()
                            userViewController.title = "User"
                            userViewController.user = user
                            let navigationController = UINavigationController(rootViewController: userViewController)
                            self.presentViewController(navigationController, animated: true, completion: nil)
                        }
                        else
                        {
                            alert(title: "Error", message:(error as? NSError)?.userInfo[NSLocalizedDescriptionKey] as? String, cancelButtonTitle: "OK")
                        }
                    })
                }  
            })
        }
        else
        {
            alert(title: "Error", message:"Please, fill in email and password", cancelButtonTitle: "OK")
        }

    }


}

