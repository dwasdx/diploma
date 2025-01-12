import UIKit

//MARK: RoutingProtocol

public protocol UserProfileViewControllerRouting: BaseRouting {
    
    func presentChangeNameViewController(_ completion: (()->Void)?)
    func presentConfirmLogOutViewController(_ completion: (() -> Void)?)
    func presentRateAppViewController(rating: Int, _ completion: (() -> Void)?)
}

protocol UserProfileViewModeling: BaseViewModeling {
    
    var shareMessage: String { get }
    var phoneNumber: String { get }
    var userName: String { get }
    var isRatingUpdated: Bool { get set }
    var currentRating: Int { get set }
}

class UserProfileViewController: BaseViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumerLabel: UILabel!
    
    //MARK: General
    
    var starsRating: Int = 0 {
        didSet {
            guard isViewLoaded, starsRating != 0, oldValue != starsRating, viewModel?.isRatingUpdated ?? false else {
                viewModel?.isRatingUpdated = true
                return
            }
            viewModel?.currentRating = starsRating
            if starsRating >= 4 {
                guard let url = URL(string: "https://itunes.apple.com/app/id1530377058?action=write-review" ) else {
                    return
                }
                UIApplication.shared.open(url)
            } else {
                router?.presentRateAppViewController(rating: starsRating, nil)
            }
        }
    }
    
    override func viewDidLoad() {
        setupNavBar()
        update()
    }
    
    var router: UserProfileViewControllerRouting?
    var viewModel: UserProfileViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: message)
                }
            }
        }
    }
    
    private func setup() {
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Профиль"
        let item = UIBarButtonItem(image: UIImage(named: "log-in"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(logOutTapped))
        navigationItem.setRightBarButton(item, animated: false)
        navigationController?.configureNavigationColor(.white)
        item.tintColor = .shoppingListOrange
    }
    
    //MARK: Updates
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        
        updateUserName()
        updatePhoneNumber()
    }
    
    private func updateUserName() {
        userNameLabel.text = viewModel?.userName  ?? "Не указано"
    }
    
    private func updatePhoneNumber() {
        phoneNumerLabel.text = viewModel?.phoneNumber ?? "Не указан"
    }
    
    //MARK: IBAtctions
    
    @IBAction func changeUserNameButtonTapped(_ sender: Any) {
        router?.presentChangeNameViewController(nil)
    }
    
    @objc func logOutTapped() {
        router?.presentConfirmLogOutViewController(nil)
    }
    
    @IBAction func notificationsSettingsButton(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString ) else {
            return
        }
        
        let app = UIApplication.shared
        
        app.open(url)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        guard let shareMessage = viewModel?.shareMessage else {
            return
        }
        let vc = UIActivityViewController(activityItems: [shareMessage], applicationActivities: [])
        present(vc, animated: true)
    }
    
    @IBAction func feedbackButton(_ sender: Any) {
        router?.presentRateAppViewController(rating: 0, nil)
    }
    
}

extension UserProfileViewController: RatingViewControllering {
    
}
