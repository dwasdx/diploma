import UIKit

class AddNewProductHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = typeName
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .shoppingListTextBlack
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.masksToBounds = false
        
        addSubview(categoryLabel)
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
        
    }
    
    func configure(with model: ProductCategoryViewModel?) {
        guard let model = model else {
            return
        }
        categoryLabel.text = model.title
    }
}
