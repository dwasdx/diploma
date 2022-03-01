import Foundation

protocol ShoppingListUserServicable: AnyObject {
    
    func createUser(_ user: UserRegisterObject, completion: @escaping (Result<UserObject?, ShoppingListServerError>) -> Void)
    func login(phone: Int, completion: @escaping (Result<UserLoginResponse?, ShoppingListServerError>) -> Void)
    func confirmRegistration(withCode code: String, completion: @escaping (Result<PhoneConfirmationResponse?, ShoppingListServerError>) -> Void)
    func getUser(byPhoneNumber phone: String, completion: @escaping (Result<GetUserResponse?, ShoppingListServerError>) -> Void)
    func checkUsersRegistrationStatus(_ phoneNumbers: [Int], completion: @escaping (Result<CheckRegistrationResponse?, ShoppingListServerError>) -> Void)
}

extension ShoppingListService: ShoppingListUserServicable {
    
    func createUser(_ user: UserRegisterObject, completion: @escaping (Result<UserObject?, ShoppingListServerError>) -> Void) {
        let request = UserRegisterRequest(user)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    func login(phone: Int, completion: @escaping (Result<UserLoginResponse?, ShoppingListServerError>) -> Void) {
        let loginModel = UserLoginModel(phone: phone)
        let request = UserLoginRequest(loginModel)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    func confirmRegistration(withCode code: String, completion: @escaping (Result<PhoneConfirmationResponse?, ShoppingListServerError>) -> Void) {
        let model = PhoneConfirmationModel(code)
        let request = PhoneConfirmationRequest(model)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    func getUser(byPhoneNumber phone: String, completion: @escaping (Result<GetUserResponse?, ShoppingListServerError>) -> Void) {
        let request = GetUserRequest(phoneNumber: phone)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    func checkUsersRegistrationStatus(_ phoneNumbers: [Int], completion: @escaping (Result<CheckRegistrationResponse?, ShoppingListServerError>) -> Void) {
        let object = CheckRegistrationObject(phones: phoneNumbers)
        let request = CheckRegistrationRequest(object: object)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    func checkAuthorizationLimit(phoneNumber: String, _ completion: @escaping (Result<CheckAuthoriztionLimitResponse?, ShoppingListServerError>) -> Void) {
        let request = CheckAuthoriztionLimitRequest(phoneNumber: phoneNumber)
        makeRequestAndParseResponce(request, completion: completion)
    }

}
