//
//  ProductModel.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 03.06.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreData

struct ProductModel: Hashable, Equatable {
    let id: String
    var name: String
    var value: String
    var isMarked: Bool
    let userMarkedId: String?
    let listId: String
    let isDeleted: Bool
    let createdAt: Int
    let updatedAt: Int
    var categoryName: String?
    
    init(name: String, value: String, isMarked: Bool, userMarkedId: String?, listId: String, isDeleted: Bool, createdAt: Int, updatedAt: Int) {
        self.id = NSUUID().uuidString.lowercased()
        self.name = name
        self.value = value
        self.isMarked = isMarked
        self.userMarkedId = userMarkedId
        self.listId = listId
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(name: String, value: String, userMarkedId: String?, listId: String, isDeleted: Bool, createdAt: Int, updatedAt: Int) {
        self.id = NSUUID().uuidString.lowercased()
        self.name = name
        self.value = value
        self.isMarked = false
        self.userMarkedId = userMarkedId
        self.listId = listId
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(name: String, listId: String, value: String, date: Int) {
        self.id = NSUUID().uuidString.lowercased()
        self.name = name
        self.value = value
        self.isMarked = false
        self.userMarkedId = nil
        self.listId = listId
        self.isDeleted = false
        self.createdAt = date
        self.updatedAt = date
    }
    
    init(productEntity: ProductEntity) {
        self.id = productEntity.id
        self.name = productEntity.name
        self.value = productEntity.value
        self.isMarked = productEntity.isMarked
        self.userMarkedId = productEntity.userMarkedId
        self.listId = productEntity.listId
        self.isDeleted = productEntity.isDeleted
        self.createdAt = Int(productEntity.createdAt)
        self.updatedAt = Int(productEntity.updatedAt)
        self.categoryName = productEntity.categoryName
    }
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func ==(lhs: ProductModel, rhs: ProductModel) -> Bool {
//        return lhs.id == rhs.id
//            }
}
