import SwiftUI

struct CodeDetailSheet: View {
    let host: String
    let item: CodeItem
    let allPlayers: [Player]
    @Binding var selectedPlayer: Player?
    let onRefresh: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var editedCode: String = ""
    @State private var showPlayerSelect = false
    @State private var toastMessage = ""
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()

                VStack(spacing: 16) {
                    // 标题
                    Text(item.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    // 已选玩家
                    HStack {
                        Text(selectedPlayer == nil ? "未选择玩家" : "👤 \(selectedPlayer!.characterName.isEmpty ? selectedPlayer!.name : selectedPlayer!.characterName)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: { showPlayerSelect = true }) {
                            Text("选择玩家")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(ThemeManager.shared.getPrimary())
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    // 代码编辑器
                    TextEditor(text: $editedCode)
                        .foregroundColor(.white)
                        .font(.system(.caption, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                        .cornerRadius(12)
                        .frame(minHeight: 150)
                        .padding(.horizontal)

                    // 操作按钮
                    HStack(spacing: 12) {
                        Button(action: {
                            UIPasteboard.general.string = editedCode
                            toast("✅ 已复制")
                        }) {
                            Label("复制", systemImage: "doc.on.doc")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }

                        Button(action: {
                            CodeDatabase.shared.updateCode(name: item.name, newCode: editedCode)
                            onRefresh()
                            toast("✅ 已保存")
                        }) {
                            Label("保存", systemImage: "square.and.arrow.down")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.486, green: 0.302, blue: 1))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }

                        Button(action: {
                            guard !editedCode.isEmpty else { toast("代码为空"); return }
                            if let player = selectedPlayer {
                                executeForPlayer(player)
                            } else {
                                showPlayerSelect = true
                            }
                        }) {
                            Label("执行", systemImage: "play.fill")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(ThemeManager.shared.getPrimary())
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        guard !editedCode.isEmpty else { toast("代码为空"); return }
                        executeForAll()
                    }) {
                        Text("全员执行")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 1, green: 0.569, blue: 0))
                            .foregroundColor(.black)
                            .cornerRadius(24)
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
            .navigationTitle("代码详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .sheet(isPresented: $showPlayerSelect) {
                PlayerSelectSheet(players: allPlayers, selectedPlayer: $selectedPlayer)
            }
            .onAppear { editedCode = item.code }
        }
    }

    private func executeForPlayer(_ player: Player) {
        CommandExecutor.shared.execute(host: host, playerId: player.playerId, commands: editedCode) { results in
            let ok = results.filter { $0.success }.count
            DispatchQueue.main.async { toast("✅ \(ok)/\(results.count)成功") }
        }
    }

    private func executeForAll() {
        guard !allPlayers.isEmpty else { toast("没有在线玩家"); return }
        var totalDone = 0
        var totalOk = 0
        let totalOps = allPlayers.count
        for player in allPlayers {
            CommandExecutor.shared.execute(host: host, playerId: player.playerId, commands: editedCode) { results in
                let ok = results.filter { $0.success }.count
                DispatchQueue.main.async {
                    totalDone += 1
                    if ok > 0 { totalOk += 1 }
                    if totalDone == totalOps { toast("✅ \(totalOk)/\(totalOps)玩家成功") }
                }
            }
        }
    }

    private func toast(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showToast = false } }
    }
}

// MARK: - 玩家选择 Sheet
struct PlayerSelectSheet: View {
    let players: [Player]
    @Binding var selectedPlayer: Player?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filtered: [Player] {
        if searchText.isEmpty { return players }
        return players.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.characterName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack {
                    DarkTextField(placeholder: "搜索玩家...", text: $searchText, icon: "🔍")
                        .padding()

                    Text("\(filtered.count) 人")
                        .font(.caption)
                        .foregroundColor(.gray)

                    List {
                        ForEach(filtered) { player in
                            Button(action: {
                                selectedPlayer = player
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(player.characterName.isEmpty ? player.name : player.characterName)
                                            .foregroundColor(.white)
                                        Text("ID: \(player.playerId) | Lv.\(player.level)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if selectedPlayer?.playerId == player.playerId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ThemeManager.shared.getPrimary())
                                    }
                                }
                            }
                            .listRowBackground(Color(red: 0.129, green: 0.149, blue: 0.176))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("选择玩家")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
