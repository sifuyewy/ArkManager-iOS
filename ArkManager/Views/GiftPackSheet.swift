import SwiftUI

struct GiftPackSheet: View {
    let host: String
    @Environment(\.dismiss) var dismiss
    @State private var enabled = false
    @State private var keys = "0"
    @State private var itemsText = ""
    @State private var statusText = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // 开关
                        Toggle("启用新手礼包", isOn: $enabled)
                            .foregroundColor(.white)
                            .tint(ThemeManager.shared.getPrimary())
                            .padding(.horizontal)

                        // 钥匙数量
                        DarkTextField(placeholder: "钥匙数量", text: $keys, icon: "🔑")
                            .keyboardType(.numberPad)
                            .padding(.horizontal)

                        // 物品列表
                        VStack(alignment: .leading) {
                            Text("物品列表（每行一个，格式: 蓝图|数量|品质|flag）")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextEditor(text: $itemsText)
                                .foregroundColor(.white)
                                .font(.system(.caption, design: .monospaced))
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                                .cornerRadius(12)
                                .frame(minHeight: 150)
                        }
                        .padding(.horizontal)

                        // 添加物品按钮
                        Button(action: {
                            let newItem = "Blueprint'/Game/...'|1|0|false"
                            itemsText = itemsText.isEmpty ? newItem : "\(itemsText)\n\(newItem)"
                        }) {
                            Label("添加物品", systemImage: "plus")
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.486, green: 0.302, blue: 1))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }

                        // 操作按钮
                        HStack(spacing: 12) {
                            Button(action: readGiftPack) {
                                Label("读取", systemImage: "arrow.down.doc")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(ThemeManager.shared.getPrimary())
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                            }
                            Button(action: saveGiftPack) {
                                Label("保存", systemImage: "square.and.arrow.down")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.486, green: 0.302, blue: 1))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                            Button(action: resetGiftPack) {
                                Label("重置领取", systemImage: "arrow.clockwise")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 1, green: 0.569, blue: 0))
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)

                        if !statusText.isEmpty {
                            Text(statusText)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("🎁 新手礼包")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .onAppear { readGiftPack() }
        }
        .presentationDetents([.large])
    }

    private func readGiftPack() {
        isLoading = true
        statusText = "正在读取..."
        ArkApi.shared.getGiftPack(host: host) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    enabled = data.enabled
                    keys = data.keys
                    itemsText = data.items.map { "\($0.blueprint)|\($0.qty)|\($0.quality)|\($0.blueprint_flag)" }.joined(separator: "\n")
                    statusText = "已读取: \(data.items.count)件物品, 钥匙:\(keys), \(data.enabled ? "已启用" : "未启用")"
                case .failure(let err):
                    statusText = "❌ \(err.localizedDescription)"
                }
            }
        }
    }

    private func saveGiftPack() {
        let items: [[String: Any]] = itemsText.components(separatedBy: "\n").filter { !$0.isEmpty }.map { line in
            let parts = line.split(separator: "|").map { String($0) }
            return [
                "blueprint": parts.count > 0 ? parts[0] : "",
                "qty": parts.count > 1 ? parts[1] : "1",
                "quality": parts.count > 2 ? parts[2] : "0",
                "blueprint_flag": parts.count > 3 ? (parts[3] == "true") : false
            ] as [String: Any]
        }
        statusText = "正在保存..."
        ArkApi.shared.saveGiftPack(host: host, enabled: enabled, keys: keys, items: items) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: statusText = "✅ 礼包已保存"
                case .failure(let err): statusText = "❌ \(err.localizedDescription)"
                }
            }
        }
    }

    private func resetGiftPack() {
        statusText = "正在重置..."
        ArkApi.shared.resetGiftPack(host: host) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: statusText = "✅ 已重置领取记录"
                case .failure(let err): statusText = "❌ \(err.localizedDescription)"
                }
            }
        }
    }
}
