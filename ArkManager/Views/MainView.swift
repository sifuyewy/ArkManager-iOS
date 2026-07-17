import SwiftUI

struct MainView: View {
    @State private var host: String = ""
    @State private var currentTab = 0
    @State private var status: ServerStatus? = nil
    @State private var allPlayers: [Player] = []
    @State private var allCodes: [CodeItem] = []
    @State private var selectedPlayer: Player? = nil
    @State private var currentMapIndex = 5
    @State private var searchText = ""
    @State private var codeSearchText = ""
    @State private var currentCategory = "全部"
    @State private var customCmd = ""
    @State private var allKeysNum = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showMapSelect = false
    @State private var showGiftPack = false
    @State private var showGravestone = false
    @State private var showSaves = false
    @State private var showAuthor = false
    @State private var showAddCode = false
    @State private var navigateToConfig = false
    @State private var timer: Timer? = nil
    @State private var showPlayerActions = false
    @State private var actionPlayer: Player? = nil
    @State private var showCodeDetail = false
    @State private var detailCode: CodeItem? = nil

    private let categories = ["全部", "恐龙", "资源", "武器", "装备", "鞍具", "建筑", "皮肤/宠物", "神器/奖杯", "指令/功能", "染料", "其他"]

    var filteredPlayers: [Player] {
        if searchText.isEmpty { return allPlayers }
        return allPlayers.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.characterName.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredCodes: [CodeItem] {
        allCodes.filter { item in
            let matchCategory = currentCategory == "全部" || item.category == currentCategory
            let matchKeyword = codeSearchText.isEmpty || item.name.localizedCaseInsensitiveContains(codeSearchText) || item.code.localizedCaseInsensitiveContains(codeSearchText)
            return matchCategory && matchKeyword
        }
    }

    var body: some View {
        ZStack {
            ThemeManager.shared.getDarker().ignoresSafeArea()

            VStack(spacing: 0) {
                // Toolbar
                toolbarView

                // 服务器状态
                statusView

                // Tab 切换
                tabBarView

                // 页面内容
                if currentTab == 0 {
                    playersPage
                } else {
                    codesPage
                }
            }

            // Toast
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
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showToast)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToConfig) {
            ServerConfigView()
        }
        .sheet(isPresented: $showMapSelect) { mapSelectSheet }
        .sheet(isPresented: $showGiftPack) { GiftPackSheet(host: host) }
        .sheet(isPresented: $showGravestone) { GravestoneSheet(host: host) }
        .sheet(isPresented: $showSaves) { SavesSheet(host: host) }
        .sheet(isPresented: $showAuthor) { AuthorSheet() }
        .sheet(isPresented: $showAddCode) { AddCodeSheet(onSave: { name, code in
            CodeDatabase.shared.addCode(name: name, code: code)
            loadCodes()
            toast("✅ 已添加: \(name)")
        }) }
        .sheet(isPresented: $showPlayerActions) {
            if let player = actionPlayer {
                PlayerActionsSheet(host: host, player: player)
            }
        }
        .sheet(isPresented: $showCodeDetail) {
            if let item = detailCode {
                CodeDetailSheet(host: host, item: item, allPlayers: allPlayers, selectedPlayer: $selectedPlayer, onRefresh: { loadCodes() })
            }
        }
        .onAppear {
            host = Prefs.shared.getActiveServer()?.host ?? ""
            loadAll()
            loadCodes()
            startTimer()
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Toolbar
    private var toolbarView: some View {
        HStack(spacing: 12) {
            Text("🦖 ARK Manager")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Button(action: { navigateToConfig = true }) {
                Image(systemName: "gearshape")
                    .foregroundColor(.white)
            }
            Button(action: { showSaves = true }) {
                Image(systemName: "archivebox")
                    .foregroundColor(.white)
            }
            Button(action: { showAuthor = true }) {
                Image(systemName: "person.circle")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(ThemeManager.shared.getDark())
    }

    // MARK: - 状态栏
    private var statusView: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(status?.running == true ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(status?.running == true ? "运行中" : (status == nil ? "连接中..." : "已停止"))
                    .font(.caption)
                    .foregroundColor(.white)

                Spacer()

                Text("👤 \(status?.players ?? 0)")
                    .font(.caption)
                    .foregroundColor(.gray)

                let h = (status?.uptimeSeconds ?? 0) / 3600
                let m = ((status?.uptimeSeconds ?? 0) % 3600) / 60
                Text("⏱ \(h)时\(m)分")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("🗺 \(mapName(status?.mapIndex ?? 0))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if let pending = status?.pendingAction, !pending.isEmpty {
                Text("⏳ \(pending)")
                    .font(.caption)
                    .foregroundColor(Color(red: 1, green: 0.569, blue: 0))
            }

            // 操作按钮
            HStack(spacing: 8) {
                Button(action: { showMapSelect = true }) {
                    Label("启动", systemImage: "play.fill")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(status?.running == true ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .disabled(status?.running == true)

                Button(action: { serverAction("stop") }) {
                    Label("停止", systemImage: "stop.fill")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(status?.running == true ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .disabled(status?.running != true)

                Button(action: { showGiftPack = true }) {
                    Text("🎁")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.486, green: 0.302, blue: 1))
                        .cornerRadius(20)
                }

                Button(action: { showGravestone = true }) {
                    Text("🪦")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.902, green: 0.318, blue: 0))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(ThemeManager.shared.getDarker())
    }

    // MARK: - Tab Bar
    private var tabBarView: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { currentTab = 0 } }) {
                VStack(spacing: 4) {
                    Text("玩家管理")
                        .font(.subheadline)
                        .fontWeight(currentTab == 0 ? .bold : .regular)
                        .foregroundColor(currentTab == 0 ? Color(red: 0, green: 0.898, blue: 1) : Color(red: 0.545, green: 0.580, blue: 0.616))
                    Rectangle()
                        .fill(currentTab == 0 ? Color(red: 0, green: 0.898, blue: 1) : Color.clear)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
            }
            Button(action: { withAnimation { currentTab = 1 } }) {
                VStack(spacing: 4) {
                    Text("代码库")
                        .font(.subheadline)
                        .fontWeight(currentTab == 1 ? .bold : .regular)
                        .foregroundColor(currentTab == 1 ? Color(red: 0, green: 0.898, blue: 1) : Color(red: 0.545, green: 0.580, blue: 0.616))
                    Rectangle()
                        .fill(currentTab == 1 ? Color(red: 0, green: 0.898, blue: 1) : Color.clear)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .background(ThemeManager.shared.getDarker())
    }

    // MARK: - 玩家页面
    private var playersPage: some View {
        VStack(spacing: 0) {
            // 搜索和选择玩家
            HStack(spacing: 8) {
                DarkTextField(placeholder: "搜索玩家...", text: $searchText, icon: "🔍")

                Button(action: { selectedPlayer = nil }) {
                    Text(selectedPlayer == nil ? "未选择" : (selectedPlayer!.characterName.isEmpty ? selectedPlayer!.name : selectedPlayer!.characterName))
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(ThemeManager.shared.getPrimary())
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // 玩家数量
            HStack {
                Text("\(filteredPlayers.count)人")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { loadPlayers() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)

            // 玩家列表
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredPlayers) { player in
                        Button(action: {
                            actionPlayer = player
                            showPlayerActions = true
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(player.characterName.isEmpty ? player.name : player.characterName)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    HStack(spacing: 8) {
                                        Text("ID: \(player.playerId)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        if !player.tribeName.isEmpty {
                                            Text("部落: \(player.tribeName)")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                Spacer()
                                Text("Lv.\(player.level)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            // 自定义命令区域
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    DarkTextField(placeholder: "自定义命令", text: $customCmd, icon: "⌨️")
                    Button(action: { executeCustomCommand(all: false) }) {
                        Text("执行")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                    Button(action: { executeCustomCommand(all: true) }) {
                        Text("全员")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 1, green: 0.569, blue: 0))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }

                HStack(spacing: 8) {
                    DarkTextField(placeholder: "钥匙数量", text: $allKeysNum, icon: "🔑")
                        .frame(maxWidth: 150)
                    Button(action: giveAllKeys) {
                        Text("全员发钥匙")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 1, green: 0.843, blue: 0))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(ThemeManager.shared.getDarker())
        }
    }

    // MARK: - 代码库页面
    private var codesPage: some View {
        VStack(spacing: 0) {
            // 搜索
            HStack {
                DarkTextField(placeholder: "搜索代码...", text: $codeSearchText, icon: "🔍")
                Button(action: { showAddCode = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(ThemeManager.shared.getPrimary())
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

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
            }
            .padding(.bottom, 8)

            // 代码数量
            HStack {
                Text("共 \(filteredCodes.count) 条")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 4)

            // 代码列表
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredCodes) { item in
                        Button(action: {
                            detailCode = item
                            showCodeDetail = true
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(item.category)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(ThemeManager.shared.getPrimary().opacity(0.2))
                                        .foregroundColor(ThemeManager.shared.getPrimary())
                                        .cornerRadius(10)
                                }
                                Text(item.code)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(12)
                            .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Map Select Sheet
    private var mapSelectSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 0) {
                    let maps = ["孤岛(0)", "焦土(1)", "畸变(2)", "仙境(3)", "灭绝(4)", "创世1(5)", "创世2(6)"]
                    ForEach(0..<maps.count, id: \.self) { i in
                        Button(action: { currentMapIndex = i }) {
                            HStack {
                                Text(maps[i])
                                    .foregroundColor(.white)
                                Spacer()
                                if currentMapIndex == i {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ThemeManager.shared.getPrimary())
                                }
                            }
                            .padding()
                        }
                        Divider().background(Color.gray.opacity(0.3))
                    }
                    Button(action: { serverAction("start") }) {
                        Text("启动")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .padding()
                }
            }
            .navigationTitle("选择地图")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions
    private func loadAll() {
        loadStatus()
        loadPlayers()
    }

    private func loadStatus() {
        ArkApi.shared.getStatus(host: host) { result in
            if case .success(let data) = result {
                DispatchQueue.main.async {
                    status = data
                    currentMapIndex = data.mapIndex
                }
            }
        }
    }

    private func loadPlayers() {
        ArkApi.shared.getPlayers(host: host) { result in
            if case .success(let data) = result {
                DispatchQueue.main.async { allPlayers = data.players }
            }
        }
    }

    private func loadCodes() {
        allCodes = CodeDatabase.shared.getAllCodes()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            loadStatus()
        }
    }

    private func serverAction(_ action: String) {
        ArkApi.shared.serverAction(host: host, action: action, mapIndex: currentMapIndex) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    toast("✅ \(data.message ?? "成功")")
                    loadAll()
                case .failure(let err):
                    toast("❌ \(err.localizedDescription)")
                }
            }
        }
    }

    private func giveAllKeys() {
        let num = Int(allKeysNum.trimmingCharacters(in: .whitespaces)) ?? 0
        guard num > 0 else { toast("请输入数量"); return }
        guard !allPlayers.isEmpty else { toast("没有在线玩家"); return }
        var done = 0
        var ok = 0
        let total = allPlayers.count
        for player in allPlayers {
            ArkApi.shared.giveKeys(host: host, playerId: player.playerId, amount: num) { result in
                DispatchQueue.main.async {
                    done += 1
                    if case .success = result { ok += 1 }
                    if done == total { toast("✅ \(ok)人发\(num)钥匙") }
                }
            }
        }
    }

    private func executeCustomCommand(all: Bool) {
        let cmd = customCmd.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { toast("请输入命令"); return }
        let targets: [Player]
        if all {
            guard !allPlayers.isEmpty else { toast("没有在线玩家"); return }
            targets = allPlayers
        } else {
            guard let p = selectedPlayer else { toast("请先选择玩家"); return }
            targets = [p]
        }
        var totalDone = 0
        var totalOk = 0
        let totalOps = targets.count
        for player in targets {
            CommandExecutor.shared.execute(host: host, playerId: player.playerId, commands: cmd) { results in
                let ok = results.filter { $0.success }.count
                DispatchQueue.main.async {
                    totalDone += 1
                    if ok > 0 { totalOk += 1 }
                    if totalDone == totalOps { toast("✅ \(totalOk)/\(totalOps)玩家成功") }
                }
            }
        }
    }

    private func mapName(_ i: Int) -> String {
        switch i {
        case 0: return "孤岛"; case 1: return "焦土"; case 2: return "畸变"
        case 3: return "仙境"; case 4: return "灭绝"; case 5: return "创世1"
        case 6: return "创世2"; default: return "地图\(i)"
        }
    }

    private func toast(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
}
