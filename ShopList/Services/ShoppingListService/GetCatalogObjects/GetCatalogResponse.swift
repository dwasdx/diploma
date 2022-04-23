import Foundation

struct GetCatalogResponse: Codable {
    let categories: [CategoryResposne]
    let products: [ProductResposne]
}
