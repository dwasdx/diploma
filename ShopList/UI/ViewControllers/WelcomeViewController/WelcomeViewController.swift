import UIKit

public protocol WelcomeViewControllerRouting {
    
    func presentSignInViewController(_ completion: (() -> Void)?)
    func presentRegisterationViewController(_ completion: (() -> Void)?)
}

class WelcomeViewController: BaseViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = "Добро\nпожаловать"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    var router: WelcomeViewControllerRouting?

    // MARK: - Actions
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        router?.presentSignInViewController(nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        router?.presentRegisterationViewController(nil)
    }
    

}
