import UIKit
import SwipeCellKit

enum UIConstants {
    /// equals to 16
    static let defaultInset: CGFloat = 16
    
    /// equals to 8
    static let listInterItemInset: CGFloat = 8
    
    /// equals to 32
    static let collectionTopPadding: CGFloat = 32
    
    /// equals to 70
    static let cellStandartHeight: CGFloat = 70
}

// MARK: - Routing Protocol

protocol ShoppingListViewControllerRouting: BaseRouting {
    func presentHomePage(_ completion: (() -> Void)?)
    func presentCreateShoppingListViewController(_ completion: (() -> Void)?)
    func presentConfirmDeleteViewController(with model: ShoppingListModel, onIndexPath indexPath: IndexPath, _ completion: (() -> Void)?)
    func presentProductsListViewController(with model: ShoppingListModel, _ completion: (() -> Void)?)
}

// MARK: - Enum Shopping List Section

enum ShoppingListSection {
    case shares
    case lists
}

//MARK: ShoppingListViewModeling

protocol ShoppingListViewModeling: BaseViewModeling {
    
    var shares: [ShareModel] { get }
    var lists: [ShoppingListModel] { get set }
    var isEmptyShares: Bool { get }
    var isEmptyModel: Bool { get }
    
    var didCancelModelDelete: ((IndexPath) -> Void)? { get set }
    var updateWithScroll: (() -> Void)? { get set }
    
    func getModelForRow(at indexPath: IndexPath) -> ShoppingListModel?
    func removeModel(inCellWithIndexPath indexPath: IndexPath)
    func moveList(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func sync()
    
    var didFailSynchronization: ((String) -> Void)? { get set }
}

// MARK: - typealiases for DiffableDataSource

typealias ShoppingListsDataSource = UICollectionViewDiffableDataSource<ShoppingListSection,  GeneralModel>
typealias ShoppingListsSnapshot = NSDiffableDataSourceSnapshot<ShoppingListSection, GeneralModel>

// MARK: - General

class ShoppingListViewController: BaseViewController {
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    //@IBOutlet weak var plusContainerView: UIView!
    
    
    var initialCellXCoordinate: CGFloat {
        collectionView.center.x
    }
    var currentCellOffset: CGFloat = 0
    var startingPoint = CGPoint.zero
    
    private var dataSource: ShoppingListsDataSource!
    var router: ShoppingListViewControllerRouting?
    var viewModel: ShoppingListViewModeling! {
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
                DispatchQueue.main.async { [weak self] in
                    guard let cell = self?.collectionView.cellForItem(at: indexPath) as? ShoppingListCollectionViewCell else {
                        return
                    }
                    cell.hideSwipe(animated: true)
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
        // inspired by https://stackoverflow.com/questions/24341192/uirefreshcontrol-stuck-after-switching-tabs-in-uitabbarcontroller
        collectionView.refreshControl?.beginRefreshing()
        collectionView.refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.updateConstraintsIfNeeded()
        update()
    }
    
    // MARK: Setup
    
    private func setup() {
        viewModel?.sync()
        setupCollectionView()
        setupDataSource()
    }
    
    //MARK: DataSource
    
    func setupCollectionView() {
        collectionView.backgroundColor = nil
        collectionView.collectionViewLayout = makeLayout()
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.tintColor = .shoppingListOrange
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        collectionView.delegate = self
        let topInset = UIConstants.collectionTopPadding - UIConstants.listInterItemInset
        collectionView.contentInset = UIEdgeInsets(top: topInset,
                                                   left: 0,
                                                   bottom:  UIConstants.listInterItemInset,
                                                   right: 0)
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    func setupDataSource() {
        dataSource = ShoppingListsDataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, generalModel) -> UICollectionViewCell in
            
            if let shoppingListModel = generalModel as? ShoppingListModel {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingListCollectionViewCell.reuseIdentifier, for: indexPath) as? ShoppingListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.delegate = self
                cell.configure(with: shoppingListModel)
                
                return cell
                
            } else if let shareModel = generalModel as? ShareModel {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareListCollectionViewCell.reuseIdentifier, for: indexPath) as? ShareListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(with: shareModel)
            
                return cell
            }
            
            return UICollectionViewCell()
        }
    }
    
    // https://stackoverflow.com/questions/44187881/uicollectionview-full-width-cells-allow-autolayout-dynamic-height
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnv -> NSCollectionLayoutSection in
            let height: NSCollectionLayoutDimension = sectionIndex == 0 ? .estimated(150) :
                .absolute(UIConstants.cellStandartHeight)
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: height
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: UIConstants.listInterItemInset,
                                                            leading: UIConstants.defaultInset,
                                                            bottom: 0,
                                                            trailing: UIConstants.defaultInset)
            section.interGroupSpacing = UIConstants.listInterItemInset
            return section
        }
        return layout
    }
    
    //MARK: Updates
    
    func updateTableView(animatingDifferences: Bool = true, withScroll: Bool = false) {
        var snapshot = ShoppingListsSnapshot()
        
        snapshot.appendSections([.shares, .lists])
        
        let lists = viewModel.lists
        let shares = viewModel.shares

        snapshot.appendItems(shares, toSection: .shares)
        snapshot.appendItems(lists, toSection: .lists)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        if withScroll {
            DispatchQueue.main.async {
                self.collectionView.scrollToBottomRow()
            }
        }
    }
    
    
    func update(animatingDifferences: Bool = true, withScroll: Bool = false) {
        guard isViewLoaded, view.window != nil else {
            return
        }
        updateViewsWithoutReloadingTableView()
        updateRefreshControl()
        updateTableView(animatingDifferences: animatingDifferences, withScroll: withScroll)
    }
    
    
    func updateViewsWithoutReloadingTableView() {
        backgroundView.isHidden = !viewModel.isEmptyModel
    }
    
    func updateRefreshControl() {
        if viewModel.isLoading == false {
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: Actions
    
    @objc private func refreshControlTriggered() {
        viewModel?.sync()
    }
    
    @IBAction func backgroundViewNoItemsTapped(_ sender: Any) {
        router?.presentCreateShoppingListViewController(nil)
    }
    
    @IBAction func plusButtonTapped() {
        router?.presentCreateShoppingListViewController(nil)
    }
    
}

extension ShoppingListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1,
              let model = viewModel.getModelForRow(at: indexPath) else {
            return
        }
        router?.presentProductsListViewController(with: model, nil)
    }
}

//MARK: Swipe Cells

extension ShoppingListViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return []
        }
        let delete = SwipeAction(style: .default, title: nil) { _, indexPath in
            guard let model = self.viewModel.getModelForRow(at: indexPath) else {
                return
            }
            self.router?.presentConfirmDeleteViewController(with: model, onIndexPath: indexPath, nil)
        }
        delete.backgroundColor = .clear
//        delete.hidesWhenSelected = true
        return [delete]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.backgroundColor = .clear
        options.transitionStyle = .reveal
//        options.expansionStyle = .fill
        return options
    }
}

//MARK: Rows drag and drop delegates
//inspired by https://www.thetopsites.net/article/59699679.shtml and
// https://www.raywenderlich.com/3121851-drag-and-drop-tutorial-for-ios#c-rate

extension ShoppingListViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.section != 0 else {
            return []
        }
        let model = viewModel.getModelForRow(at: indexPath)
        let itemProvider = NSItemProvider(object: (model?.id ?? "") as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension ShoppingListViewController: UICollectionViewDropDelegate {
    private func reorderItems(_ coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            var destIndexPath = destinationIndexPath
            if destIndexPath.row >= collectionView.numberOfItems(inSection: destIndexPath.section) {
                destIndexPath.row = collectionView.numberOfItems(inSection: destIndexPath.section) - 1
            }
            viewModel.moveList(from: sourceIndexPath, to: destIndexPath)
            //MARK: commented the next string because App crashes in some cases
            // for example if to move the last list to the first position
            //            coordinator.drop(item.dragItem, toRowAt: destIndexPath)
            update(animatingDifferences: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.section == 0 {
            return UICollectionViewDropProposal(operation: .forbidden)
        } else {
            return UICollectionViewDropProposal(operation: .move)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
            case .move:
                self.reorderItems(coordinator,
                                  destinationIndexPath: destinationIndexPath,
                                  collectionView: collectionView)
            default:
                return
        }
    }
}
