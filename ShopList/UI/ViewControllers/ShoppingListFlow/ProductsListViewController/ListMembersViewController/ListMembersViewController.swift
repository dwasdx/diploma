import UIKit

protocol ListMembersViewControllerRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
    func presentContactsViewController(listId: String, completion: (() -> Void)?)
}

protocol ListMembersViewModeling: BaseViewModeling {
    
    var isEmptyModel: Bool { get }
    var listId: String { get }
        
    var sections: [MemberType] { get }
    var items: [[ListMemberModel]] { get }
    
    var didFailSynchronization: ((String) -> Void)? { get set }
    
    func removeFromList(memberOnIndexPath indexPath: IndexPath)
    func getCategoryModel(forSection section: Int) -> ListMemberCategoryModel?
    func sync()
}

typealias MembersDataSource = UITableViewDiffableDataSource<MemberType, ListMemberModel>
typealias MembersSnapshot = NSDiffableDataSourceSnapshot<MemberType, ListMemberModel>

class ListMembersViewController: BaseViewController {
    
    var initialCellXCoordinate: CGFloat {
        tableView.center.x
    }
    var currentCellOffset: CGFloat = 0
    var startingPoint = CGPoint.zero
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: MembersDataSource!
    
    var router: ListMembersViewControllerRouting?
    var viewModel: ListMembersViewModeling? {
        didSet {
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            viewModel?.didFailSynchronization = { [weak self] message in
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
        super.viewWillAppear(animated)
        viewModel?.sync()
        update()
    }
    
    private func setup() {
        navigationItem.title = "Участники списка"
        navigationItem.backButtonTitle = "Назад"
        setupTableView()
        setupDataSource()
    }
    
    private func setupTableView() {
        tableView.register(ListMemberTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: ListMemberTableViewHeaderView.reuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .shoppingListOrange
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControllTriggered), for: .valueChanged)
    }
    
    private func setupDataSource() {
        dataSource = MembersDataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, model) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ListMembersTableViewCell.reuseIdentifier, for: indexPath) as? ListMembersTableViewCell else {
                return UITableViewCell()
            }
            cell.gestureDelegate = self
            cell.panGestureBlock = { [weak self] gesture, cell in
                self?.swipeHelper(sender: gesture, cell: cell)
            }
            cell.configure(with: model)
            
            return cell
        })
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateRefreshControl()
        createSnapshot()
    }
    
    private func updateRefreshControl() {
        if viewModel?.isLoading == false {
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func createSnapshot() {
        var snapshot = MembersSnapshot()
        
        guard let sections = viewModel?.sections,
            let items = viewModel?.items else {
                return
        }
        snapshot.appendSections(sections)
        for (sectionIndex, section) in sections.enumerated() {
            snapshot.appendItems(items[sectionIndex], toSection: section)
        }
        dataSource.apply(snapshot)
    }
}

extension ListMembersViewController {
    
    @objc func refreshControllTriggered() {
        viewModel?.sync()
    }
    
    @IBAction func backgroundViewNoItemsTapped(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }
        router?.presentContactsViewController(listId: viewModel.listId, completion: nil)
    }
    
    @IBAction func backButtonTapped() {
        router?.navigateBack(animated: true, nil)
    }
    
    @IBAction func plusButtonTapped() {
        guard let viewModel = viewModel else {
            return
        }
        router?.presentContactsViewController(listId: viewModel.listId, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? ListMembersTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        viewModel?.removeFromList(memberOnIndexPath: indexPath)
    }
}

//MARK: Table View Delegate

extension ListMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListMemberTableViewHeaderView.reuseIdentifier) as? ListMemberTableViewHeaderView else {
            return nil
        }
        guard let model = viewModel?.getCategoryModel(forSection: section) else {
            return nil
        }
        view.configure(with: model)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        64
    }
}

//MARK: Gesture Delegate
extension ListMembersViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              gestureRecognizer.view?.superview?.superview is ListMembersTableViewCell else {
            return true
        }
        
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
}

//MARK: Swipe Helper
extension ListMembersViewController {
    
    private func swipeHelper(sender: UIPanGestureRecognizer, cell: ListMembersTableViewCell) {
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
            //small left shift so that reash icon appeared
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
