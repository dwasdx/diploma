import UIKit

// MARK: - Routing Protocol

protocol ProductsListViewControllerRouting {
    //func presenListMembersViewController(listId: String, _ completion: (() -> Void)?)
    func presentAddNewProductViewController(_ completion: (() -> Void)?)
    func presentConfirmDeleteViewController(with model: ProductModel, onIndexPath indexPath: IndexPath, _ completion: (() -> Void)?)
    func presentChangeValueViewController(indexPath: IndexPath, _ completion: (() -> Void)?)
    func presentUncheckAllViewController(confirmHandler: (() -> Void)?, _ completion: (() -> Void)?)
    func presentListActionsViewController(productsListViewModel: ProductsListViewModeling, _ completion: (() -> Void)?)
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
}

// MARK: - Enum Product Section

enum ProductSection {
    case checked
    case button
    case unchecked
}

protocol ProductsListViewModeling: BaseViewModel {
    
    var products: [ProductType: [ProductModel]] { get }
    var isEmptyModel: Bool { get }
    var isEmptyCheckedModel: Bool { get }
    var progress: Float { get }
    var progressString: String { get }
    var listTitle: String { get set }
    var listId: String { get }
    var currentUserIsListOwner: Bool { get }
    var listDescription: String { get }
    var cartHeaderViewHeight: Float { get }
    
    var didCancelModelDelete: ((IndexPath) -> Void)? { get set }
    var updateWithScroll: (() -> Void)? { get set }
    var didFailSynchronization: ((String) -> Void)? { get set }
    
    func uncheckAllProducts()
    func dropBadge()
    func getModel(at indexPath: IndexPath) -> ProductModel?
    func markCell(inIndexPath indexPath: IndexPath)
    func sync()
}

// MARK: - typealiases for DiffableDataSource

typealias ProductsListDataSource = UITableViewDiffableDataSource<ProductSection,  ProductModel>
typealias ProductsListDataSnapshot = NSDiffableDataSourceSnapshot<ProductSection, ProductModel>

// MARK: - General

class ProductsListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var containerProgressView: UIView!
    
    lazy var initialCellXCoordinate: CGFloat = tableView.center.x
    var currentCellOffset: CGFloat = 0
    var startingPoint = CGPoint.zero
    
    private var dataSource: ProductsListDataSource!
    var router: ProductsListViewControllerRouting?
    var viewModel: ProductsListViewModeling! {
        didSet {
            
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            
            viewModel.updateWithScroll = { [weak self] in
                DispatchQueue.main.async { [weak self]  in
                    self?.update(withScroll: true)
                }
            }
            
            viewModel.didCancelModelDelete = { [weak self] indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? CheckableProductListTableViewCell else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if self == nil {
                        return
                    }
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: .curveEaseInOut,
                                   animations: {
                                    cell.containerView.center.x = self!.tableView.center.x
                    },
                                   completion: nil)
                }
            }
            
            viewModel.didFailSynchronization = { [weak self] message in
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else {
                        return
                    }
                    self.showDefaultToast(withMessage: message,
                                          point: CGPoint(x: self.view.center.x, y: self.view.bounds.maxY - 45))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update(animatingDifferences: false)
        // inspired by https://stackoverflow.com/questions/24341192/uirefreshcontrol-stuck-after-switching-tabs-in-uitabbarcontroller
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.endRefreshing()
    }
    
    // MARK: Setup
    
    private func setup() {
        viewModel?.sync()
        backgroundView.isHidden = !viewModel.isEmptyModel
        viewModel.dropBadge()
        setupTableView()
        setupDataSource()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let isListOwner = viewModel.currentUserIsListOwner
        let item: UIBarButtonItem
        if isListOwner {
            item = UIBarButtonItem(image: UIImage(named: "three-dots")?.withRenderingMode(.alwaysTemplate),
                                   style: .plain,
                                   target: self,
                                   action: #selector(navigationBarButtonPressed))
        } else {
            item = UIBarButtonItem(image: UIImage(named: "share-arrow")?.withRenderingMode(.alwaysTemplate),
                                   style: .plain,
                                   target: self,
                                   action: #selector(navigationBarButtonPressed))
        }
        navigationController?.navigationBar.isHidden = false
        navigationItem.setRightBarButton(item, animated: false)
        navigationItem.setHidesBackButton(false, animated: false)
        navigationItem.backBarButtonItem?.tintColor = .shoppingListOrange
        item.tintColor = .shoppingListOrange
        navigationItem.backButtonTitle = "Назад"
        navigationItem.title = viewModel.listTitle
    }
    
    
    //MARK: DataSource
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.backgroundColor = nil
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: "CartHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: CartHeaderView.reuseId)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .shoppingListOrange
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControllerTriggered), for: .valueChanged)
    }
    
    private func setupDataSource() {
        dataSource = ProductsListDataSource(tableView: tableView) { [weak self] (tableView, indexPath, productModel) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckableProductListTableViewCell.reuseId) as? CheckableProductListTableViewCell else {
                fatalError("Unable to cast cell to \(type(of: CheckableProductListTableViewCell.self))")
            }
            
            cell.gestureDelegate = self
            cell.panGestureBlock = { [weak self] gesture, cell in
                self?.swipeHelper(sender: gesture, cell: cell)
            }
            cell.tapGestureBlock = { [weak self] cell in
                self?.cellTapped(cell)
            }
            
            cell.configure(with: productModel)
            cell.containerView.center.x = tableView.center.x
            
            return cell
            
        }
    }
    
     //MARK: Updates
    
    func updateTableView(animatingDifferences: Bool = true, withScroll: Bool = false) {
           var snapshot = ProductsListDataSnapshot()
           
           snapshot.appendSections([.unchecked, .checked])
           
           let items = viewModel.products
           
           snapshot.appendItems(items[.unchecked]!, toSection: .unchecked)
           snapshot.appendItems(items[.checked]!, toSection: .checked)
           
           dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        if withScroll {
            DispatchQueue.main.async {
                self.tableView.scrollToTop()
            }
        }
       }
    
    
    private func update(animatingDifferences: Bool = true, withScroll: Bool = false) {
        guard isViewLoaded else {
            return
        }
        navigationItem.title = viewModel.listTitle
        updateBackgroundView()
        updateProgressView(animate: animatingDifferences)
        updateTableView(animatingDifferences: animatingDifferences, withScroll: withScroll)
        updateRefreshControl()
    }
    
    
    func updateBackgroundView() {
        backgroundView.isHidden = !viewModel.isEmptyModel
    }
    
    private func updateProgressView(animate: Bool) {
        self.containerProgressView.frame.size.height = self.viewModel.isEmptyModel ? 0 : 78
        if animate {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.containerProgressView.layer.opacity = self.viewModel.isEmptyModel ? 0 : 1
                            self.view.layoutSubviews()
            },
                           completion: { completed in
                            self.containerProgressView.isHidden = self.viewModel.isEmptyModel
            })
        } else {
            self.containerProgressView.layer.opacity = self.viewModel.isEmptyModel ? 0 : 1
            self.containerProgressView.isHidden = self.viewModel.isEmptyModel
        }
        
        
        progressView.setProgress(viewModel.progress, animated: true)
        counterLabel.text = viewModel.progressString
    }
    
    private func updateRefreshControl() {
        if viewModel.isLoading == false {
            tableView.refreshControl?.endRefreshing()
        }
    }
    
}

//MARK: Actions

extension ProductsListViewController {
    
    private func cellTapped(_ cell: CheckableProductListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if cell.containerView.center.x != self.initialCellXCoordinate {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            cell.containerView.center.x = self.initialCellXCoordinate
                            cell.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.router?.presentChangeValueViewController(indexPath: indexPath, nil)
        }
    }
    
    func presentShareViewController(_ completion: (() -> Void)?) {
        guard let description = viewModel?.listDescription else {
            return
        }
        let vc = UIActivityViewController(activityItems: [description], applicationActivities: [])
        present(vc, animated: true, completion: completion)
    }
    
    @objc private func reuseButtonTapped() {
        router?.presentUncheckAllViewController(confirmHandler: viewModel.uncheckAllProducts, nil)
    }
    
    @IBAction func plusButtonTapped() {
        router?.presentAddNewProductViewController({
            self.tableView.scrollToTop()
        })
    }
    
    @IBAction func backgroundViewNoItemsTapped(_ sender: Any) {
        router?.presentAddNewProductViewController(nil)
    }
    
    @objc func navigationBarButtonPressed() {
        if viewModel.currentUserIsListOwner {
            router?.presentListActionsViewController(productsListViewModel: viewModel, nil)
        } else {
            presentShareViewController(nil)
        }
    }
    
    @IBAction func backButtonTapped() {
        router?.navigateBack(animated: true, nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? CheckableProductListTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let model = viewModel.getModel(at: indexPath) else {
            return
        }
        router?.presentConfirmDeleteViewController(with: model, onIndexPath: indexPath, nil)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? CheckableProductListTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        viewModel.markCell(inIndexPath: indexPath)
    }
    
    @objc private func refreshControllerTriggered() {
        viewModel?.sync()
    }
}

//MARK: UITableViewDataSource & UITableViewDelegate

extension ProductsListViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        //cartHeaderView
        case 1:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CartHeaderView.reuseId) as? CartHeaderView else {
                return nil
            }
            
            headerView.reuseButton.addTarget(self, action: #selector(reuseButtonTapped), for: .touchUpInside)
            headerView.contentView.backgroundColor = UIColor.white
            return headerView
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        //cartHeaderView (is hidden when number of checked products == 0)
        case 1:
            guard let checkedProductsCount = viewModel.products[.checked]?.count, checkedProductsCount > 0 else {
                return 0
            }
            return CGFloat(viewModel.cartHeaderViewHeight)
        default:
            return 0
        }
    }
}


//MARK: Extension Swipe settings

extension ProductsListViewController {
    
    private func swipeHelper(sender: UIPanGestureRecognizer, cell: CheckableProductListTableViewCell) {
        let translation = sender.translation(in: self.view)
        let velocity = sender.velocity(in: cell.containerView).x
        guard let view = cell.containerView else {
            return
        }
        startingPoint = view.center
        let initialCellXCoordinate = cell.contentView.center.x
        
        //prevent initial right swipe
        if view.center.x == initialCellXCoordinate, velocity > 0 {
            return
        }
        
        //prevent exit from the right border
        if self.currentCellOffset + translation.x > initialCellXCoordinate {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            view.center = CGPoint(x: initialCellXCoordinate, y: view.center.y)
                            //                            print(self.startingPoint)
                           },
                           completion: nil)
            return
        }
        
        //remembering offset when user started to swipe
        if sender.state == .began {
            currentCellOffset = view.center.x
        }
        
        if (sender.state == .began || sender.state == .changed) {
            //move view
            UIView.animate(withDuration: 0.05) {
                view.center = CGPoint(x: self.currentCellOffset + translation.x, y: view.center.y)
            }
        } else if sender.state == .ended, velocity < 0 {
            //small left shift so that trash icon appeared
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            let coord = CGPoint(x: initialCellXCoordinate - view.frame.height + 6, y: view.center.y)
                            view.center = coord
            },
                           completion: nil)
            return
        }
        if sender.state == .ended, velocity >= 0 {
            //return to default position
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            view.center = CGPoint(x: initialCellXCoordinate, y: view.center.y)
            },
                           completion: nil)
        }
    }
}

//MARK: Extension UIGestureRecognizerDelegate

extension ProductsListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              gestureRecognizer.view?.superview?.superview is CheckableProductListTableViewCell else {
            return true
        }
        
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}
