import UIKit

protocol AddNewContactDelegate: AnyObject {
    func actionButtonTapped()
}

protocol ContactsViewControllerRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
    func presentShareAppViewController(shareAppDelegate: AddNewContactDelegate, _ completion: (() -> Void)?)
}

protocol ContactsViewModeling: BaseViewModeling {
    var sections: [Character] { get }
    var items: [[ListMemberModel]] { get }
    var isEmptyModel: Bool { get }
    
    var filter: String? { get set }
    var isFiltering: Bool { get set }
    
    var didRecieveDeniedAccessToContacts: ((String) -> Void)? { get set }
    var didRecieveCheckContactsError: ((String) -> Void)? { get set }
    
    func getMemberViewModel(_ indexPath: IndexPath) -> ListMemberModel?
    func getSectionTitle(for section: Int) -> Character?
    func addMemberToList(on indexPath: IndexPath, _ completion: (() -> Void))
    func createNewUser(indexPath: IndexPath)
    func fetchContacts()
}

typealias ContactsDataSource = UITableViewDiffableDataSource<Character, ListMemberModel>
typealias ContactsSnapshot = NSDiffableDataSourceSnapshot<Character, ListMemberModel>

class ContactsViewController: BaseViewController {
    
    @IBOutlet weak var backgroundViewNoItems: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contactSearchTextFIeld: UITextField!
    
    private var tappedCellIndex: IndexPath?
    var router: ContactsViewControllerRouting?
    var viewModel: ContactsViewModeling? {
        didSet {
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async {
                    self?.update()
                }
            }
            viewModel?.didRecieveDeniedAccessToContacts = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showMessageAlert(message: message)
                }
            }
            viewModel?.didRecieveCheckContactsError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(title: "Ошибка", message: message)
                }
            }
        }
    }
    
    private var dataSource: ContactsDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetchContacts()
    }
    
    private func updateBackgroundView() {
        backgroundViewNoItems.isHidden = !(viewModel?.isEmptyModel ?? true)
        tableView.bounces = !(viewModel?.isEmptyModel ?? true)
    }
    
    private func update() {
        guard isViewLoaded, view.window != nil else {
            return
        }
        createSnapshot()
        updateBackgroundView()
    }
    
    //MARK: DataSource
    
    private func setupTableView() {
        tableView.register(ContactTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: ContactTableViewHeaderView.reuseIdentifier)
        tableView.delegate = self
    }
    
    private func setupDataSource() {
        dataSource = ContactsDataSource(tableView: tableView) { (tableView, indexPath, model) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier, for: indexPath) as? ContactTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(model)
            
            return cell
        }
    }
    
    //MARK: Snapshot
    
    private func createSnapshot() {
        var snapshot = ContactsSnapshot()
        
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
    
    @IBAction func addMemberButtonTapped(_ sender: UIButton) {
//        return
        guard let cell = sender.superview?.superview?.superview as? ContactTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        self.tappedCellIndex = indexPath
            viewModel?.addMemberToList(on: indexPath) {
            router?.presentShareAppViewController(shareAppDelegate: self, nil)
        }
        
        sender.isHidden = true
    }
    
    @IBAction func contactSearchTextFieldEditingChanged(_ sender: UITextField) {
        viewModel?.isFiltering = !(sender.text?.isEmpty ?? true)
        viewModel?.filter = sender.text
    }
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContactTableViewHeaderView.reuseIdentifier) as? ContactTableViewHeaderView else {
            return nil
        }
        guard let char = viewModel?.getSectionTitle(for: section) else {
            return nil
        }
        headerView.label.text = String(char)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        39
    }
}

extension ContactsViewController: AddNewContactDelegate {
    func actionButtonTapped() {
        guard let indexPath = tappedCellIndex else {
            return
        }
        viewModel?.createNewUser(indexPath: indexPath)
    }
    
    
}
