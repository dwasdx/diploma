import UIKit

protocol ListActionsViewControllerRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
    func presentChangeNameListViewController(productsListViewModel: ProductsListViewModeling, _ completion: (() -> Void)?)
    func presenListMembersViewController(listId: String, _ completion: (() -> Void)?)
    func presentShareViewController(_ completion: (() -> Void)?)
}

protocol ListActionsViewModeling: BaseViewModeling {
    var productsListViewModel: ProductsListViewModeling { get }
    
    var numberOfSections: Int { get }
    func getNumberOfRows(inSection section: Int) -> Int
    func getModel(forIndexPath indexPath: IndexPath) -> ListActionsModel
}

class ListActtionsViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ListActionsViewModeling?
    var router: ListActionsViewControllerRouting?
    
    let defaultContainerViewHeight: CGFloat = 246
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewHeightAnchor.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        containerViewHeightAnchor.constant = defaultContainerViewHeight
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutIfNeeded()
                        self.containerView.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    func dismiss(_ completion: (() -> Void)?) {
        self.containerViewHeightAnchor.constant = 0
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .clear
                        self.view.layoutIfNeeded()
                        self.containerView.layoutIfNeeded()
        }) { (_) in
            completion?()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss { [weak self] in
            self?.router?.navigateBack(animated: false, nil)
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismiss { [weak self] in
            self?.router?.navigateBack(animated: false, nil)
        }
    }
}

extension ListActtionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getNumberOfRows(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListActtionsTableViewCell.reuseIdentifier, for: indexPath)
        return cell
    }
}

extension ListActtionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ListActtionsTableViewCell,
            let model = viewModel?.getModel(forIndexPath: indexPath) else {
            return
        }
        cell.configure(with: model)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            case 0:
                guard let productsViewModel = viewModel?.productsListViewModel else {
                    return
                }
                dismiss { [weak self] in
                    self?.router?.navigateBack(animated: false, { [weak self] in
                        self?.router?.presentChangeNameListViewController(productsListViewModel: productsViewModel, nil)
                    })
            }
            case 1:
                guard let listId = viewModel?.productsListViewModel.listId else {
                    return
                }
                dismiss { [weak self] in
                    self?.router?.navigateBack(animated: false) { [weak self] in
                        self?.router?.presenListMembersViewController(listId: listId, nil)
                    }
                }
            case 2:
                dismiss { [weak self] in
                    self?.router?.navigateBack(animated: false) { [weak self] in
                        self?.router?.presentShareViewController(nil)
                    }
                }
            default:
                break
        }
    }
}
