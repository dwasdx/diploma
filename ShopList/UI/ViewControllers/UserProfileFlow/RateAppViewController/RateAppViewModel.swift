//
//  RateAppViewModel.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 25.09.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import PhoneNumberKit

class RateAppViewModel: BaseViewModel {
    var rating: Int
    
    var theme: String? {
        didSet {
            didChange?()
        }
    }
    var problemDescription: String?
    
    var sendEmail: ((String, String) -> Void)?
    
    init(rating: Int) {
        self.rating = rating
    }
}

extension RateAppViewModel: RateAppViewModeling {
    func sendEmailIfPossible() {
//        guard let theme = theme else {
//            return
//        }
//        var phoneNumberString: String
//        do {
//            let phoneKit = PhoneNumberKit()
//            let phoneNumber = try phoneKit.parse(CurrentUserManager.shared.userPhoneNumber)
//            phoneNumberString = phoneNumber.numberString
//        } catch let error {
//            dLog(error: error)
//            phoneNumberString = CurrentUserManager.shared.userPhoneNumber
//        }
//        problemDescription = """
//        \(problemDescription ?? "")
//
//        Info:
//        User: \(phoneNumberString)
//        Rating: \(rating)
//        Phone: \(UIDevice.devicelName)
//        OS version: \(UIDevice.current.systemName + " " + UIDevice.current.systemVersion)
//        """
//        sendEmail?(theme, problemDescription ?? "")
    }
}
