//
//  UINavigationController+configure.swift
//  ShopList
//
//  Created by Андрей Журавлев on 17.05.2022.
//

import UIKit

extension UINavigationController {
    func configureNavigationColor(_ color: UIColor) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = color
        navBarAppearance.shadowColor = color   /// set separator color
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.tintColor = .white
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
}
