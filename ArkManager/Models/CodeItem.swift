import Foundation

struct CodeItem: Codable, Identifiable {
    var id: String { name }
    var name: String
    var code: String
    var category: String = ""
}
