import Foundation

class ArkApi {
    static let shared = ArkApi()
    private let token = "admin"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config, delegate: TrustAllDelegate(), delegateQueue: nil)
    }

    private func url(host: String, path: String) -> URL? {
        URL(string: "https://\(host)\(path)?token=\(token)")
    }

    // MARK: - GET
    private func get<T: Decodable>(host: String, path: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let requestUrl = url(host: host, path: path) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效URL"])))
            return
        }
        let task = session.dataTask(with: requestUrl) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据"])))
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - POST
    private func post<T: Decodable>(host: String, path: String, body: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        guard let requestUrl = url(host: host, path: path) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效URL"])))
            return
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据"])))
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - 服务器状态
    func getStatus(host: String, completion: @escaping (Result<ServerStatus, Error>) -> Void) {
        get(host: host, path: "/api/server/status", completion: completion)
    }

    // MARK: - 服务器操作
    func serverAction(host: String, action: String, mapIndex: Int = 5, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/server/action", body: ["action": action, "mapIndex": mapIndex], completion: completion)
    }

    // MARK: - 玩家列表
    func getPlayers(host: String, completion: @escaping (Result<PlayersResponse, Error>) -> Void) {
        get(host: host, path: "/api/players", completion: completion)
    }

    // MARK: - 玩家操作
    func playerAction(host: String, action: String, playerId: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/player/action", body: ["action": action, "playerId": playerId], completion: completion)
    }

    // MARK: - 发钥匙
    func giveKeys(host: String, playerId: String, amount: Int, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/player/action", body: ["action": "addKeys", "playerId": playerId, "amount": amount], completion: completion)
    }

    // MARK: - 执行命令
    func execCommand(host: String, command: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/command", body: ["command": command], completion: completion)
    }

    // MARK: - 发物品
    func giveItemToPlayer(host: String, playerId: String, blueprint: String, qty: String, quality: String, times: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        let body: [String: Any] = [
            "playerId": playerId,
            "blueprint": blueprint,
            "blueprint_flag": false,
            "qty": qty,
            "quality": quality,
            "times": times
        ]
        post(host: host, path: "/api/item/give", body: body, completion: completion)
    }

    // MARK: - 发恐龙
    func giveDinoToPlayer(host: String, playerId: String, blueprint: String, level: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        let body: [String: Any] = [
            "playerId": playerId,
            "blueprint": blueprint,
            "level": level,
            "times": "1"
        ]
        post(host: host, path: "/api/dino/give", body: body, completion: completion)
    }

    // MARK: - 服务器配置
    func getConfig(host: String, completion: @escaping (Result<ConfigResponse, Error>) -> Void) {
        get(host: host, path: "/api/config", completion: completion)
    }

    func saveConfig(host: String, gameUserSettings: String, gameIni: String, restart: Bool, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        let body: [String: Any] = [
            "gameUserSettings": gameUserSettings,
            "gameIni": gameIni,
            "restart": restart
        ]
        post(host: host, path: "/api/config", body: body, completion: completion)
    }

    // MARK: - 新手礼包
    func getGiftPack(host: String, completion: @escaping (Result<GiftPackResponse, Error>) -> Void) {
        get(host: host, path: "/api/giftpack", completion: completion)
    }

    func saveGiftPack(host: String, enabled: Bool, keys: String, items: [[String: Any]], completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        let body: [String: Any] = ["enabled": enabled, "keys": keys, "items": items]
        post(host: host, path: "/api/giftpack/save", body: body, completion: completion)
    }

    func resetGiftPack(host: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/giftpack/reset", body: [:], completion: completion)
    }

    // MARK: - 墓碑
    func getGravestone(host: String, completion: @escaping (Result<GravestoneResponse, Error>) -> Void) {
        get(host: host, path: "/api/gravestone", completion: completion)
    }

    func saveGravestone(host: String, enabled: Bool, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/gravestone/save", body: ["enabled": enabled], completion: completion)
    }

    // MARK: - 存档
    func getSaves(host: String, completion: @escaping (Result<SavesResponse, Error>) -> Void) {
        get(host: host, path: "/api/saves", completion: completion)
    }

    func deleteSave(host: String, mapIndex: Int, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        post(host: host, path: "/api/saves/delete", body: ["mapIndex": mapIndex], completion: completion)
    }
}

// MARK: - 信任所有证书（与 Android 版一致）
class TrustAllDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}
