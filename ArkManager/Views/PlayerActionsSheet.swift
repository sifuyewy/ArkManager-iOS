import SwiftUI

struct PlayerActionsSheet: View {
    let host: String
    let player: Player
    @Environment(\.dismiss) var dismiss
    @State private var showGiveKeys = false
    @State private var showCustomCmd = false
    @State private var keysAmount = ""
    @State private var customCmd = ""
    @State private var toastMessage = ""
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()

                VStack(spacing: 16) {
                    // 玩家信息
                    VStack(spacing: 8) {
                        Circle()
                            .fill(ThemeManager.shared.getPrimary())
                            .frame(width: 12, height: 12)
                        Text(player.characterName.isEmpty ? player.name : player.characterName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("ID: \(player.playerId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Lv.\(player.level)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)

                    // 操作按钮网格
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ActionButton(icon: "🔑", title: "发钥匙") { showGiveKeys = true }
                        ActionButton(icon: "👢", title: "踢出") { playerAction("kick") }
                        ActionButton(icon: "🚫", title: "封禁") { playerAction("ban") }
                        ActionButton(icon: "✅", title: "解封") { playerAction("unban") }
                        ActionButton(icon: "📍", title: "传送到") { playerAction("tpTo") }
                        ActionButton(icon: "📥", title: "拉过来") { playerAction("bring") }
                        ActionButton(icon: "💀", title: "击杀") { playerAction("kill") }
                        ActionButton(icon: "⌨️", title: "自定义") { showCustomCmd = true }
                    }
                    .padding(.horizontal)

                    // 命令输入
                    HStack(spacing: 8) {
                        DarkTextField(placeholder: "命令", text: $customCmd, icon: "⌨️")
                        Button(action: {
                            let cmd = customCmd.trimmingCharacters(in: .whitespaces)
                            guard !cmd.isEmpty else { return }
                            executeForPlayer(cmd)
                        }) {
                            Text("执行")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(ThemeManager.shared.getPrimary())
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }

                if showToast {
                    VStack {
                        Spacer()
                        Text(toastMessage)
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("玩家操作")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .sheet(isPresented: $showGiveKeys) {
                GiveKeysSheet(host: host, player: player)
            }
            .sheet(isPresented: $showCustomCmd) {
                CustomCmdSheet(host: host, player: player)
            }
        }
    }

    private func playerAction(_ action: String) {
        ArkApi.shared.playerAction(host: host, action: action, playerId: player.playerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): toast("✅ \(data.message ?? "成功")")
                case .failure(let err): toast("❌ \(err.localizedDescription)")
                }
            }
        }
    }

    private func executeForPlayer(_ cmd: String) {
        CommandExecutor.shared.execute(host: host, playerId: player.playerId, commands: cmd) { results in
            let ok = results.filter { $0.success }.count
            DispatchQueue.main.async { toast("✅ \(ok)/\(results.count)成功") }
        }
    }

    private func toast(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showToast = false } }
    }
}

// MARK: - 操作按钮
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(red: 0.129, green: 0.149, blue: 0.176))
            .cornerRadius(12)
        }
    }
}

// MARK: - 发钥匙 Sheet
struct GiveKeysSheet: View {
    let host: String
    let player: Player
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("🔑")
                        .font(.system(size: 48))
                    Text("发钥匙")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text(player.characterName.isEmpty ? player.name : player.characterName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    DarkTextField(placeholder: "钥匙数量", text: $amount, icon: "🔑")
                        .keyboardType(.numberPad)
                    Button(action: {
                        guard let num = Int(amount), num > 0 else { return }
                        ArkApi.shared.giveKeys(host: host, playerId: player.playerId, amount: num) { _ in
                            DispatchQueue.main.async { dismiss() }
                        }
                    }) {
                        Text("确认发放")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(24)
                    }
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 自定义命令 Sheet
struct CustomCmdSheet: View {
    let host: String
    let player: Player
    @Environment(\.dismiss) var dismiss
    @State private var cmd = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("⌨️")
                        .font(.system(size: 48))
                    Text("自定义命令")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("\(player.characterName.isEmpty ? player.name : player.characterName)\n支持 | 分隔多条")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    TextEditor(text: $cmd)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                        .cornerRadius(12)
                        .frame(minHeight: 100)
                    Button(action: {
                        let trimmed = cmd.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        CommandExecutor.shared.execute(host: host, playerId: player.playerId, commands: trimmed) { _ in
                            DispatchQueue.main.async { dismiss() }
                        }
                    }) {
                        Text("执行")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(24)
                    }
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
