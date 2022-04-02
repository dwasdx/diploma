import UIKit

protocol AddNewProductViewControllerRouting {
    func presentProductsListViewController(_ completion: (() -> Void)?)
}

protocol AddNewProductViewModeling: BaseViewModeling {
    
    var names:String? { get set }
    var value:String? { get set }
    var filter: String? { get set }
    var isEmptyFilter: Bool { get }
    var numberOfSections: Int { get }
    var numberOfModels: Int { get }
    
    var isFiltering: Bool { get set }
    var itemsFiltered: [[ProductViewModel]] { get }
    var sectionsFiltered: [ProductCategoryViewModel] { get }
    
    var choosenProductSection: Int? { get set }
    
    var didAddSuccessfully: (() -> Void)? { get set }
    
    func addNewProduct(_ completion: ((Error?) -> Void)?)
    func getNumberOfRows(in section: Int) -> Int
    func getProductViewModel(_ indexPath: IndexPath) -> ProductViewModeling?
    func getProductCategoryViewModel(_ section: Int) -> ProductCategoryViewModel?
    
    var didChangeFilter: (()->Void)? { get set }
}

typealias ProductsDataSource = UITableViewDiffableDataSource<ProductCategoryViewModel,ProductViewModel>
typealias ProductsSnapshot = NSDiffableDataSourceSnapshot<ProductCategoryViewModel,ProductViewModel>

class AddNewProductViewController: NameEditingViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var productNameTextField: DesignableTextField!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTextField: DesignableTextField!

    @IBOutlet weak var plusButton: DesignableButton!
    @IBOutlet weak var tableView: SelfSizedTableView!
    @IBOutlet weak var shadowedView: UIView!
    @IBOutlet weak var productsStackView: UIStackView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var containerViewYPosition: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 379
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.presentProductsListViewController(nil)
        }
    }
    
    private var dataSource: ProductsDataSource!
    
    var router: AddNewProductViewControllerRouting?
    var viewModel: AddNewProductViewModeling? {
        didSet {
            viewModel?.didChangeFilter = { [weak self] in
                DispatchQueue.main.async {
                    self?.updateProductOptionsTableView()
                }
            }
            
            viewModel?.didAddSuccessfully = { [weak self] in
                DispatchQueue.main.async {
                    self?.dismiss {
                        self?.router?.presentProductsListViewController(nil)
                    }
                }
            }
            
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async {
                    self?.update()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewHeightAnchor.constant = 0
        setup()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollViewHeightAnchor.constant = 379
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutSubviews()
        },
                       completion: nil)
        
        _ = productNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss(_ completion: @escaping (()->Void)) {
        self.scrollViewHeightAnchor.constant = 0
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .clear
                        self.view.layoutSubviews()
        }) { (_) in
            completion()
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        super.nameEditingTextField = productNameTextField
        productNameTextField.delegate = self
        
        setupTableView()
        setupDataSource()
        textFieldAddTarget()
    }
    
    private func textFieldAddTarget() {
        productNameTextField.addTarget(self, action: #selector(textfieldEditingChanged), for: .editingChanged)
    }
    
    @objc func textfieldEditingChanged() {
        guard let text = productNameTextField.text else {
            return
        }
        errorLabel.isHidden = text.isValid
        plusButton.isEnabled = text.isValid
        plusButton.backgroundColor = text.isValid ? UIColor(named: "shoppinglist.orange") : UIColor(named: "shoppinglist.icons.gray")
    }
    
    func setupTableView() {
        tableView.maxHeight = 255
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
        tableView.register(AddNewProductHeaderView.self, forHeaderFooterViewReuseIdentifier: AddNewProductHeaderView.reuseIdentifier)
    }
    
    func setupDataSource() {
        dataSource = ProductsDataSource(tableView: tableView) { [weak self] (tableView, indexPath, productViewModel) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewProductTableViewCell.reuseIdentifier, for: indexPath) as? AddNewProductTableViewCell else {
                return UITableViewCell()
            }
            
            guard let model = self?.viewModel?.getProductViewModel(indexPath) else {
                return UITableViewCell()
            }
            cell.configure(model: model)
            
            return cell
        }
    }
    
    // MARK: - Updates
    
    private func update() {
        guard isViewLoaded else {
            return
        }
         
        updateProductOptionsTableView()
        updateLabels()
    }
    
    func updateProductOptionsTableView() {
        createSnapshot()
        let numberOfSections = viewModel?.numberOfSections ?? 0
        let isFiltering = viewModel?.isFiltering ?? false
        let isAllowedToHideTableView = numberOfSections == 0 || isFiltering == false
        productsStackView.isHidden = isAllowedToHideTableView
        tableView.reloadSize()
        
    }
    
    func createSnapshot() {
        var snapshot = ProductsSnapshot()
        
        let sectionsFiltered = viewModel!.sectionsFiltered
        let itemsFiltered = viewModel!.itemsFiltered
        
        snapshot.appendSections(sectionsFiltered)
        for (sectionIndex, section) in sectionsFiltered.enumerated() {
            let items = itemsFiltered[sectionIndex]
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource.apply(snapshot)
    }
    
    private func updateLabels() {
        nameLabel.isHidden = viewModel?.names?.isEmpty ?? true
        valueLabel.isHidden = viewModel?.value?.isEmpty ?? true
    }
    
    // MARK: - Actions
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        guard viewModel?.isEmptyFilter ?? true else {
            return
        }
            didSwipeContainerView(sender)
    }
    
    @IBAction func saveButtonTapped() {
        viewModel?.addNewProduct({ (error) in
            guard error == nil else {
                return
            }
            self.router?.presentProductsListViewController(nil)
        })
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss {
            self.router?.presentProductsListViewController(nil)
        }
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss {
            self.router?.presentProductsListViewController(nil)
        }
    }
    
    @IBAction func nameChanged(_ textField: UITextField) {
        viewModel?.choosenProductSection = nil
        viewModel?.isFiltering = true
        viewModel?.filter = textField.text
        viewModel?.names = textField.text
    }
    
    @IBAction func nameEditingDidBegin(_ sender: UITextField) {
        viewModel?.isFiltering = true
    }
    
    @IBAction func nameEditingDidEnd(_ sender: UITextField) {
        viewModel?.isFiltering = false
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        viewModel?.value = sender.text
    }
    
    
}

extension AddNewProductViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddNewProductHeaderView.reuseIdentifier) as? AddNewProductHeaderView else {
            return nil
        }
        guard let model = viewModel?.getProductCategoryViewModel(section) else {
            return nil
        }
        view.configure(with: model)
        return view
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        37
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        28
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel?.getProductViewModel(indexPath)
        productNameTextField.text = model?.title
        viewModel?.names = model?.title
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel?.choosenProductSection = indexPath.section
        viewModel?.isFiltering = false
    }
    
}

// MARK: - Keyboard
extension AddNewProductViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        containerViewYPosition.constant = keyboardSize.height
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        containerViewYPosition.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
}

extension AddNewProductViewController: SwipeableViewController {
    var threshold: CGFloat {
        productNameTextField.isEditing || valueTextField.isEditing ? 0.5 : 0.3
    }
}

extension AddNewProductViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let direction = gesture.velocity(in: gesture.view).y
        
        if scrollView.contentOffset.y == 0, direction > 0 {
            return false
        }
        return true
    }
}
