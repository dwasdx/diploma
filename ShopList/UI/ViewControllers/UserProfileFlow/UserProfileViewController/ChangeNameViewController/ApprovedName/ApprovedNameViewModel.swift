//
//  ApprovedAndReturnUserNameViewModel.swift
//  ShoppingList
//
//  Created by Илья Соловьёв on 05.06.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import Foundation

//MARK: ModelingProtocol

protocol ApprovedNameViewModeling: ApprovedViewModeling {
    
    var title: String { get }
    var messege: String? { get }
}

//MARK: General

class ApprovedNameViewModel: BaseViewModel {
    
    var title: String = "Внимание"
    var messege: String? = "Вы успешно сменили имя!"
    
}

extension ApprovedNameViewModel: ApprovedNameViewModeling {
    
}
