import UIKit

protocol ChangeValueViewControllerRouting {
    func presentProductsListViewController(_ completion: (() -> Void)?)
}

protocol ChangeValueViewModeling: BaseViewModeling {
    var value: String? { get set }
    var name: String? { get set }
    var model: ProductModel? { get}
    
    var numberOfSections: Int { get }
    
    var choosenProductCategory: Int? { get set }
    var isFiltering: Bool { get set }
    var itemsFiltered: [[ProductViewModel]] { get }
    var sectionsFiltered: [ProductCategoryViewModel] { get }
    
    var didChangeFilter: (() -> Void)? { get set }
    
    func changeValue()
    func getNumberOfRows(in section: Int) -> Int
    func getProductViewModel(_ indexPath: IndexPath) -> ProductViewModeling?
    func getCategoryViewModel(_ section: Int) -> ProductCategoryViewModel?
}

class ChangeValueViewController: NameEditingViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var productsStackView: UIStackView!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 343
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.presentProductsListViewController(nil)
        }
    }
    
    var dataSource: ProductsDataSource!
    var router: ChangeValueViewControllerRouting?
    var viewModel: ChangeValueViewModeling? {
        didSet {
            viewModel?.didChangeFilter = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = viewModel?.name
        valueTextField.text = viewModel?.value
        
        scrollViewHeightAnchor.constant = 0
        view.backgroundColor = .clear
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollViewHeightAnchor.constant = defaultContainerViewHeight
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutSubviews()
        },
                       completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func animateBeforeDismiss() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
    
    //MARK: Setup
    
    private func setup() {
        super.nameEditingTextField = nameTextField
        setupTableView()
        setupDataSource()
    }
    
    private func setupTableView() {
        tableView.maxHeight = 206 
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
        tableView.register(AddNewProductHeaderView.self, forHeaderFooterViewReuseIdentifier: AddNewProductHeaderView.reuseIdentifier)
    }
    
    private func setupDataSource() {
        dataSource = ProductsDataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, productViewModel) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewProductTableViewCell.reuseIdentifier, for: indexPath) as? AddNewProductTableViewCell else {
                return UITableViewCell()
            }
            
            guard let model = self?.viewModel?.getProductViewModel(indexPath) else {
                return UITableViewCell()
            }
            cell.configure(model: model)
            
            return cell
        })
    }
    
    //MARK: Update
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateProductOptionsTableView()
        updateLabels()
    }
    
    private func updateProductOptionsTableView() {
        createSnapshot()
        let numberOfSections = viewModel?.numberOfSections ?? 0
        let isFiltering = viewModel?.isFiltering ?? false
        let isAllowedToHideTableView = numberOfSections == 0 || isFiltering == false
        productsStackView.isHidden = isAllowedToHideTableView
        tableView.reloadSize()
    }
    
    private func createSnapshot() {
        var snapshot = ProductsSnapshot()
        
        let sectionsFiltered = viewModel!.sectionsFiltered
        let itemsFiltered = viewModel!.itemsFiltered
        
        snapshot.appendSections(sectionsFiltered)
        for(sectionIndex, section) in sectionsFiltered.enumerated() {
            let items = itemsFiltered[sectionIndex]
            snapshot.appendItems(items, toSection: section)
        }
        dataSource.apply(snapshot)
    }
    
    private func updateLabels() {
        nameLabel.isHidden = nameTextField.text?.isEmpty ?? false
        valueLabel.isHidden = valueTextField.text?.isEmpty ?? false
    }
    
    @IBAction func doneButtonTapped() {
        guard self.viewModel?.model?.name != "" else {
            return
        }
        
        containerViewYPosition.constant = 0
        animateBeforeDismiss()
        
        router?.presentProductsListViewController({ [weak self] in
            self?.viewModel?.changeValue()
        })
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss { [weak self] in
            self?.didDismiss?()
        }
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss { [weak self] in
            self?.didDismiss?()
        }
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        viewModel?.name = sender.text
        viewModel?.choosenProductCategory = nil
        viewModel?.isFiltering = true
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        viewModel?.value = sender.text
        updateLabels()
    }
    
    @IBAction func nameEditingDidBegin(_ sender: UITextField) {
        viewModel?.isFiltering = true
    }
    
    @IBAction func nameEditingDidEnd(_ sender: UITextField) {
        viewModel?.isFiltering = false
    }
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        didSwipeContainerView(sender)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        containerViewYPosition.constant = keyboardSize.height
        animateBeforeDismiss()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        containerViewYPosition.constant = 0
        animateBeforeDismiss()
    }
}

extension ChangeValueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddNewProductHeaderView.reuseIdentifier) as? AddNewProductHeaderView else {
            return nil
        }
        guard let model = viewModel?.getCategoryViewModel(section) else {
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
        nameTextField.text = model?.title
        viewModel?.name = model?.title
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel?.isFiltering = false
        viewModel?.choosenProductCategory = indexPath.section
    }
}

extension ChangeValueViewController: SwipeableViewController {
    func dismiss(_ completion: @escaping (() -> Void)) {
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
    
    var threshold: CGFloat {
        nameTextField.isEditing || valueTextField.isEditing ? 0.5 : 0.3
    }
}

extension ChangeValueViewController: UIGestureRecognizerDelegate {
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
