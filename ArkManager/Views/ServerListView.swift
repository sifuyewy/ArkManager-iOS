import SwiftUI

struct ServerListView: View {
    @State private var servers: [Server] = []
    @State private var statusMap: [String: ServerStatus] = [:]
    @State private var showAddDialog = false
    @State private var showThemeDialog = false
    @State private var newServerName = ""
    @State private var newServerHost = ""
    @State private var navigateToMain = false
    @State private var selectedServer: Server? = nil

    var body: some View {
        ZStack {
            ThemeManager.shared.getDarker().ignoresSafeArea()

            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text("ARK Manager")
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.getPrimary())
                    Spacer()
                    Button(action: { showThemeDialog = true }) {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(ThemeManager.shared.getDark())

                // 服务器列表
                if servers.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("🖥️")
                            .font(.system(size: 64))
                        Text("暂无服务器")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("点击右下角 + 添加服务器")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(servers) { server in
                                ServerCard(
                                    server: server,
                                    status: statusMap[server.host],
                                    isActive: server.host == Prefs.shared.getActiveHost(),
                                    onSelect: {
                                        Prefs.shared.setActiveHost(server.host)
                                        selectedServer = server
                                        navigateToMain = true
                                    },
                                    onDelete: {
                                        deleteServer(server)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddDialog = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(ThemeManager.shared.getPrimary())
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToMain) {
            MainView()
        }
        .sheet(isPresented: $showAddDialog) {
            AddServerSheet(newServerName: $newServerName, newServerHost: $newServerHost, onSave: {
                let id = "\(Int(Date().timeIntervalSince1970 * 1000))"
                let name = newServerName.isEmpty ? newServerHost : newServerName
                let _ = Prefs.shared.addServer(Server(id: id, name: name, host: newServerHost))
                newServerName = ""
                newServerHost = ""
                loadServers()
            })
        }
        .sheet(isPresented: $showThemeDialog) {
            ThemeSheet()
        }
        .onAppear { loadServers() }
    }

    private func loadServers() {
        servers = Prefs.shared.getServers()
        for server in servers {
            ArkApi.shared.getStatus(host: server.host) { result in
                if case .success(let status) = result {
                    DispatchQueue.main.async {
                        statusMap[server.host] = status
                    }
                }
            }
        }
    }

    private func deleteServer(_ server: Server) {
        let _ = Prefs.shared.deleteServer(id: server.id)
        loadServers()
    }
}

// MARK: - 服务器卡片
struct ServerCard: View {
    let server: Server
    let status: ServerStatus?
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(server.name.isEmpty ? server.host : server.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        if isActive {
                            Text("当前")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(ThemeManager.shared.getPrimary())
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                    Text("📍 \(server.host)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()

                if let status = status {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(status.running ? "🟢 运行中" : "🔴 已停止")
                            .font(.caption)
                        Text("👤 \(status.players)人")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("⏳ 检测中...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            HStack(spacing: 12) {
                Button(action: onSelect) {
                    Text("选择")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(ThemeManager.shared.getPrimary())
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
                Button(action: { showDeleteConfirm = true }) {
                    Text("删除")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.545, green: 0, blue: 0))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? ThemeManager.shared.getPrimary().opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .alert("删除服务器", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) { onDelete() }
        } message: {
            Text("确定删除「\(server.name.isEmpty ? server.host : server.name)」？")
        }
    }
}

// MARK: - 添加服务器 Sheet
struct AddServerSheet: View {
    @Binding var newServerName: String
    @Binding var newServerHost: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 20) {
                    DarkTextField(placeholder: "服务器名称（可选）", text: $newServerName, icon: "🏷️")
                    DarkTextField(placeholder: "IP:端口", text: $newServerHost, icon: "🌐")
                    Button(action: {
                        guard !newServerHost.isEmpty else { return }
                        onSave()
                        dismiss()
                    }) {
                        Text("添加")
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
            .navigationTitle("添加服务器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 主题选择 Sheet
struct ThemeSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = ThemeManager.shared.getThemeIndex()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(ThemeManager.shared.getThemeNames().enumerated()), id: \.offset) { index, name in
                            Button(action: {
                                ThemeManager.shared.setThemeIndex(index)
                                currentIndex = index
                            }) {
                                HStack {
                                    Text(name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if index == currentIndex {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ThemeManager.shared.getPrimary())
                                    }
                                }
                                .padding()
                                .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🎨 选择主题")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
