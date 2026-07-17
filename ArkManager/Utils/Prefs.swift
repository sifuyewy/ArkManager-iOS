import Foundation

class Prefs {
    static let shared = Prefs()
    private let defaults = UserDefaults.standard
    private let serversKey = "servers"
    private let activeHostKey = "active_host"

    func getServers() -> [Server] {
        guard let data = defaults.data(forKey: serversKey) else { return [] }
        return (try? JSONDecoder().decode([Server].self, from: data)) ?? []
    }

    func saveServers(_ servers: [Server]) {
        if let data = try? JSONEncoder().encode(servers) {
            defaults.set(data, forKey: serversKey)
        }
    }

    func addServer(_ server: Server) -> [Server] {
        var servers = getServers()
        servers.append(server)
        saveServers(servers)
        return servers
    }

    func deleteServer(id: String) -> [Server] {
        var servers = getServers()
        servers.removeAll { $0.id == id }
        saveServers(servers)
        return servers
    }

    func getActiveHost() -> String {
        defaults.string(forKey: activeHostKey) ?? ""
    }

    func setActiveHost(_ host: String) {
        defaults.set(host, forKey: activeHostKey)
    }

    func getActiveServer() -> Server? {
        let host = getActiveHost()
        return getServers().first { $0.host == host }
    }
}
