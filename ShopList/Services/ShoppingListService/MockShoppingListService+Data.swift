import Foundation

extension MockShoppingListService: ShoppingListDataServicable {
    var lastSentDataTimeStamp: Int {
        get {
            UserDefaults.standard.integer(forKey: "lastSentDataTimeStamp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSentDataTimeStamp")
        }
    }
    
    var lastGetDataTimeStamp: Int {
        get {
            UserDefaults.standard.integer(forKey: "lastGetDataTimeStamp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastGetDataTimeStamp")
        }
    }
    
    
    private var delay: DispatchTime {
        .now() + 1
    }
    
    private func fetchData(_ completion: @escaping (Result<SendDataObject?, ShoppingListServerError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            guard let bundlePath = Bundle.main.path(forResource: "synchronizationMockData", ofType: "json"),
                let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8) else {
                    completion(.failure(.parsing("bad mock file parsing")))
                    return
            }
            //            print(try? JSONSerialization.jsonObject(with: jsonData, options: []))
            let response: Result<SendDataObject?, ShoppingListServerError> = self.parseApiResponce(jsonData)
            completion(response)
            
        }
    }
    
    private func sentData(_ completion: ((ShoppingListServerError?) -> Void)?) {
        print("\(#function) is not implemented in file \(#file)")
    }
    
    func synchronize(token: String, fullUpdate: Bool = false, _ completion: ((ShoppingListServerError?) -> Void)?) {
        print("\(#function) is not implemented in file \(#file)")
    }
    
    func getAllData(token: String, completion: @escaping (Result<GetDataObject?, ShoppingListServerError>) -> Void) {
        print("\(#function) is not implemented in file \(#file)")
    }
    
    func acceptShare(shareId: String, _ completion: @escaping ((ShoppingListServerError?) -> Void)) {
        print("\(#function) is not implemented in file \(#file)")
    }
}
