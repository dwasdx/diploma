import UIKit

class ShareListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messegeLabel: UILabel!
    
    var shareModel: ShareModel?
    
    static let reuseIdentifier = typeName

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: ShareModel) {
        
        self.shareModel = model
        //To be done - get list name by id 
        listNameLabel.text = model.listName
        
        let date = Date(timeIntervalSince1970: TimeInterval(model.createdAt))
        let formatter = DayDateFormatter()
        //FIXME: do something with this NA
        let updatedAt = formatter.time(date) ?? "NA"
        
        dateLabel.text = updatedAt
        
        messegeLabel.text = "Приглашение от пользователя \(model.ownerName)"
        
        userIconImageView.image = [UIImage(named: "user.icon"), UIImage(named: "users.icon")].randomElement().flatMap { $0 }
        
    }
    
    @IBAction func acceptButton(_ sender: Any) {
        guard let shareModel = shareModel else {
            return
        }
        CoreDataService.shared.acceptShare(model: shareModel, in: .view)
        SynchronizationService.shared.acceptShare(shareModel.id)
    }
    
    @IBAction func rejectButton(_ sender: Any) {
        guard let shareModel = shareModel else {
            return
        }
        CoreDataService.shared.rejectShare(model: shareModel, in: .view)
        if let token = CurrentUserManager.shared.userToken {
            SynchronizationService.shared.synchronizeDatabaseWithDelay(token: token)
        }
    }
    
    
}

