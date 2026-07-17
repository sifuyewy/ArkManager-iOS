import SwiftUI

struct ServerConfigView: View {
    @State private var host: String = ""
    @State private var configText: String = ""
    @State private var gameIniText: String = ""
    @State private var loaded = false
    @State private var statusText = "请先点击「读取配置」"
    @State private var statusColor = Color.orange
    @State private var currentCategory = "基础信息"
    @State private var fieldValues: [String: String] = [:]
    @State private var showSaveDialog = false
    @Environment(\.dismiss) var dismiss

    private let categories = ServerConfigSpec.getCategories()

    var body: some View {
        ZStack {
            ThemeManager.shared.getDarker().ignoresSafeArea()

            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Text("服务器配置")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { loadConfig() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(ThemeManager.shared.getDark())

                // 分类标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { currentCategory = cat }) {
                                Text(cat)
                                    .font(.caption)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(currentCategory == cat ? ThemeManager.shared.getPrimary() : Color(red: 0.129, green: 0.149, blue: 0.176))
                                    .foregroundColor(currentCategory == cat ? .black : .gray)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // 状态
                HStack {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                // 配置字段
                if loaded {
                    ScrollView {
                        VStack(spacing: 0) {
                            let fields = ServerConfigSpec.getByCategory(currentCategory)
                            ForEach(fields) { field in
                                ConfigFieldRow(field: field, value: Binding(
                                    get: { fieldValues[field.key] ?? getIniValue(configText, section: field.section, key: field.key).isEmpty ? field.defaultValue : getIniValue(configText, section: field.section, key: field.key) },
                                    set: { fieldValues[field.key] = $0 }
                                ))
                                Divider().background(Color.gray.opacity(0.3))
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    Text("请先读取配置")
                        .foregroundColor(.gray)
                    Spacer()
                }

                // 底部按钮
                HStack(spacing: 12) {
                    Button(action: { loadConfig() }) {
                        Label("读取配置", systemImage: "arrow.down.doc")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                    Button(action: { saveConfig(restart: false) }) {
                        Label("保存", systemImage: "square.and.arrow.down")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.486, green: 0.302, blue: 1))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    Button(action: { saveConfig(restart: true) }) {
                        Label("保存重启", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 1, green: 0.569, blue: 0))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(ThemeManager.shared.getDarker())
            }
        }
        .navigationBarHidden(true)
        .onAppear { host = Prefs.shared.getActiveServer()?.host ?? "" }
    }

    private func loadConfig() {
        statusText = "正在读取配置..."
        statusColor = .gray
        ArkApi.shared.getConfig(host: host) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    configText = data.gameUserSettings
                    gameIniText = data.gameIni
                    loaded = true
                    statusText = "✅ 已读取配置"
                    statusColor = .green
                    fieldValues.removeAll()
                case .failure(let err):
                    statusText = "❌ \(err.localizedDescription)"
                    statusColor = .red
                }
            }
        }
    }

    private func saveConfig(restart: Bool) {
        guard loaded else { return }
        var text = configText
        for (key, value) in fieldValues {
            if !value.isEmpty {
                text = setIniValue(text, section: "ServerSettings", key: key, value: value)
                text = setIniValue(text, section: "SessionSettings", key: key, value: value)
                text = setIniValue(text, section: "/Script/Engine.GameSession", key: key, value: value)
                text = setIniValue(text, section: "MessageOfTheDay", key: key, value: value)
            }
        }
        statusText = "正在保存..."
        statusColor = .gray
        ArkApi.shared.saveConfig(host: host, gameUserSettings: text, gameIni: gameIniText, restart: restart) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    configText = text
                    statusText = restart ? "✅ 已保存，服务器重启中..." : "✅ 已保存"
                    statusColor = .green
                case .failure(let err):
                    statusText = "❌ \(err.localizedDescription)"
                    statusColor = .red
                }
            }
        }
    }

    private func getIniValue(_ text: String, section: String, key: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var currentSection = ""
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                currentSection = String(trimmed.dropFirst().dropLast())
                continue
            }
            if currentSection == section && trimmed.hasPrefix("\(key)=") {
                return String(trimmed.dropFirst(key.count + 1)).trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }

    private func setIniValue(_ text: String, section: String, key: String, value: String) -> String {
        var lines = text.components(separatedBy: "\n")
        var currentSection = ""
        var found = false
        var result = [String]()

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                currentSection = String(trimmed.dropFirst().dropLast())
                result.append(line)
                continue
            }
            if currentSection == section && trimmed.hasPrefix("\(key)=") {
                result.append("\(key)=\(value)")
                found = true
                continue
            }
            result.append(line)
        }

        if !found {
            if let insertIndex = result.lastIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "[\(section)]" }) {
                result.insert("\(key)=\(value)", at: insertIndex + 1)
            }
        }

        return result.joined(separator: "\n")
    }
}

// MARK: - 配置字段行
struct ConfigFieldRow: View {
    let field: ConfigField
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(field.label)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.788, green: 0.820, blue: 0.851))
            Text("\(field.section) → \(field.key)")
                .font(.caption2)
                .foregroundColor(.gray)

            if field.kind == "bool" {
                Picker("", selection: $value) {
                    Text("True").tag("True")
                    Text("False").tag("False")
                }
                .pickerStyle(.segmented)
            } else {
                TextField(field.defaultValue, text: $value)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                    .cornerRadius(8)
                    .keyboardType(field.kind == "int" ? .numberPad : (field.kind == "float" ? .decimalPad : .default))
            }
        }
        .padding(.vertical, 8)
    }
}
