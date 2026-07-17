import Foundation

class CommandExecutor {
    static let shared = CommandExecutor()

    struct CommandResult {
        var command: String
        var targeted: Bool
        var type: String // "item", "dino", "global"
        var success: Bool
        var message: String
    }

    func execute(host: String, playerId: String?, commands: String, completion: @escaping ([CommandResult]) -> Void) {
        let cmdList = commands.split(separator: "|").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if cmdList.isEmpty { completion([]); return }

        var results = [CommandResult]()
        let group = DispatchGroup()
        let lock = NSLock()

        for cmd in cmdList {
            group.enter()
            if let pid = playerId {
                executeSingleForPlayer(host: host, playerId: pid, cmd: cmd) { apiResult in
                    let parsed = self.parseCommandType(cmd)
                    let success: Bool
                    let message: String
                    switch apiResult {
                    case .success(let resp):
                        success = resp.ok
                        message = resp.message ?? "成功"
                    case .failure(let err):
                        success = false
                        message = err.localizedDescription
                    }
                    lock.lock()
                    results.append(CommandResult(command: cmd, targeted: true, type: parsed, success: success, message: message))
                    lock.unlock()
                    group.leave()
                }
            } else {
                ArkApi.shared.execCommand(host: host, command: cmd) { apiResult in
                    let success: Bool
                    let message: String
                    switch apiResult {
                    case .success(let resp):
                        success = resp.ok
                        message = resp.message ?? "成功"
                    case .failure(let err):
                        success = false
                        message = err.localizedDescription
                    }
                    lock.lock()
                    results.append(CommandResult(command: cmd, targeted: false, type: "global", success: success, message: message))
                    lock.unlock()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    private func executeSingleForPlayer(host: String, playerId: String, cmd: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        // GiveItem "blueprint" qty quality times
        let giveItemPattern = #"(?i)\bGiveItem\s+"([^"]+)"\s+(\d+)\s+(\d+)\s+(\d+)"#
        if let match = cmd.range(of: giveItemPattern, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: giveItemPattern)
            let nsRange = NSRange(cmd.startIndex..., in: cmd)
            if let result = regex.firstMatch(in: cmd, range: nsRange) {
                let blueprint = String(cmd[Range(result.range(at: 1), in: cmd)!])
                let qty = String(cmd[Range(result.range(at: 2), in: cmd)!])
                let quality = String(cmd[Range(result.range(at: 3), in: cmd)!])
                let times = String(cmd[Range(result.range(at: 4), in: cmd)!])
                ArkApi.shared.giveItemToPlayer(host: host, playerId: playerId, blueprint: blueprint, qty: qty, quality: quality, times: times, completion: completion)
                return
            }
        }

        // SpawnDino / adminSpawnDino "blueprint" ... level
        let spawnDinoPattern = #"(?i)\b(?:admincheat\s+)?(?:adminSpawnDino|SpawnDino)\s+"([^"]+)"\s+\d+\s+\d+\s+\d+\s+(\d+)"#
        if let _ = cmd.range(of: spawnDinoPattern, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: spawnDinoPattern)
            let nsRange = NSRange(cmd.startIndex..., in: cmd)
            if let result = regex.firstMatch(in: cmd, range: nsRange) {
                let blueprint = String(cmd[Range(result.range(at: 1), in: cmd)!])
                let level = String(cmd[Range(result.range(at: 2), in: cmd)!])
                ArkApi.shared.giveDinoToPlayer(host: host, playerId: playerId, blueprint: blueprint, level: level, completion: completion)
                return
            }
        }

        // GMSummon "className" level
        let gmSummonPattern = #"(?i)\bGMSummon\s+"([^"]+)"\s+(\d+)"#
        if let _ = cmd.range(of: gmSummonPattern, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: gmSummonPattern)
            let nsRange = NSRange(cmd.startIndex..., in: cmd)
            if let result = regex.firstMatch(in: cmd, range: nsRange) {
                let className = String(cmd[Range(result.range(at: 1), in: cmd)!])
                let level = String(cmd[Range(result.range(at: 2), in: cmd)!])
                ArkApi.shared.giveDinoToPlayer(host: host, playerId: playerId, blueprint: className, level: level, completion: completion)
                return
            }
        }

        // 无法定向，退回全局命令
        ArkApi.shared.execCommand(host: host, command: cmd, completion: completion)
    }

    private func parseCommandType(_ cmd: String) -> String {
        let lower = cmd.lowercased()
        if lower.contains("giveitem") { return "item" }
        if lower.contains("spawndino") || lower.contains("gmSummon") { return "dino" }
        return "global"
    }
}
