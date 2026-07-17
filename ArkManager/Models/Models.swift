import Foundation

// MARK: - Server
struct Server: Codable, Identifiable {
    var id: String = ""
    var name: String = ""
    var host: String = ""
}

// MARK: - ServerStatus
struct ServerStatus: Codable {
    var ok: Bool = false
    var running: Bool = false
    var players: Int = 0
    var mapIndex: Int = 0
    var uptimeSeconds: Int64 = 0
    var pendingAction: String = ""

    enum CodingKeys: String, CodingKey {
        case ok, running, players, mapIndex, uptimeSeconds, pendingAction
    }
}

// MARK: - Player
struct Player: Codable, Identifiable {
    var id: String { playerId }
    var playerId: String = ""
    var name: String = ""
    var characterName: String = ""
    var tribeName: String = ""
    var level: String = ""
    var characterId: String = ""

    enum CodingKeys: String, CodingKey {
        case playerId, name, characterName, tribeName, level, characterId
    }
}

// MARK: - PlayersResponse
struct PlayersResponse: Codable {
    var ok: Bool = false
    var running: Bool = false
    var players: [Player] = []
}

// MARK: - ConfigResponse
struct ConfigResponse: Codable {
    var ok: Bool = false
    var package: String = ""
    var dataDir: String = ""
    var configDir: String = ""
    var gameUserSettings: String = ""
    var gameIni: String = ""
}

// MARK: - GiftPackResponse
struct GiftPackResponse: Codable {
    var ok: Bool = false
    var enabled: Bool = false
    var keys: String = "0"
    var items: [GiftItem] = []
}

// MARK: - GiftItem
struct GiftItem: Codable, Identifiable {
    var id: String { blueprint }
    var blueprint: String = ""
    var qty: String = "1"
    var quality: String = "0"
    var blueprint_flag: Bool = false
}

// MARK: - GravestoneResponse
struct GravestoneResponse: Codable {
    var ok: Bool = false
    var enabled: Bool = false
}

// MARK: - SavesResponse
struct SavesResponse: Codable {
    var ok: Bool = false
    var running: Bool = false
    var runningMapIndex: Int = -1
    var saves: [SaveInfo] = []
}

// MARK: - SaveInfo
struct SaveInfo: Codable, Identifiable {
    var id: Int { mapIndex }
    var mapIndex: Int = 0
    var mapName: String = ""
    var dir: String = ""
    var exists: Bool = false
    var sizeBytes: Int64 = 0
    var fileCount: Int = 0
    var modifiedAt: Int64 = 0
}

// MARK: - ApiResponse
struct ApiResponse: Codable {
    var ok: Bool = false
    var message: String? = nil
    var commandId: String? = nil
}
