import Foundation
import UIKit

class CardApi {
    static let shared = CardApi()
    private let verifyUrl = "https://api.919247.xyz/API/arkkm.php"
    private let session: URLSession
    private let defaults = UserDefaults.standard

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        self.session = URLSession(configuration: config, delegate: TrustAllDelegate(), delegateQueue: nil)
    }

    struct VerifyResult {
        var code: Int = 0
        var message: String = ""
        var cardNumber: String = ""
    }

    func getDeviceId() -> String {
        if let id = defaults.string(forKey: "device_id") { return id }
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        defaults.set(id, forKey: "device_id")
        return id
    }

    func verify(cardNumber: String, password: String, completion: @escaping (VerifyResult) -> Void) {
        let deviceId = getDeviceId()
        let urlString = "\(verifyUrl)?action=verify&card_number=\(cardNumber)&password=\(password)&device_id=\(deviceId)"
        guard let url = URL(string: urlString) else {
            completion(VerifyResult(code: 0, message: "无效URL"))
            return
        }
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(VerifyResult(code: 0, message: "网络错误: \(error.localizedDescription)"))
                return
            }
            guard let data = data else {
                completion(VerifyResult(code: 0, message: "无数据"))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let code = json["code"] as? Int ?? 0
                    let message = json["message"] as? String ?? ""
                    let cardNum = (json["data"] as? [String: Any])?["card_number"] as? String ?? ""
                    completion(VerifyResult(code: code, message: message, cardNumber: cardNum))
                } else {
                    completion(VerifyResult(code: 0, message: "解析失败"))
                }
            } catch {
                completion(VerifyResult(code: 0, message: "解析失败"))
            }
        }
        task.resume()
    }

    func isVerified() -> Bool {
        defaults.bool(forKey: "verified")
    }

    func setVerified(cardNumber: String) {
        defaults.set(true, forKey: "verified")
        defaults.set(cardNumber, forKey: "card_number")
    }

    func getCardNumber() -> String {
        defaults.string(forKey: "card_number") ?? ""
    }

    func logout() {
        defaults.removeObject(forKey: "verified")
        defaults.removeObject(forKey: "card_number")
    }
}
