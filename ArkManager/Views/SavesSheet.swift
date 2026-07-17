import SwiftUI

struct SavesSheet: View {
    let host: String
    @Environment(\.dismiss) var dismiss
    @State private var saves: [SaveInfo] = []
    @State private var runningMapIndex = -1
    @State private var statusText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()

                    List {
                        ForEach(saves) { save in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(save.mapName)
                                            .foregroundColor(.white)
                                        if save.mapIndex == runningMapIndex {
                                            Text("运行中")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    HStack(spacing: 12) {
                                        Text("\(save.fileCount) 文件")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(formatBytes(save.sizeBytes))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Button(action: { deleteSave(save) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .listRowBackground(Color(red: 0.129, green: 0.149, blue: 0.176))
                        }
                    }
                    .listStyle(.plain)

                    Button(action: { dismiss() }) {
                        Text("关闭")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(24)
                    }
                    .padding()
                }
            }
            .navigationTitle("📦 存档管理")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadSaves() }
        }
        .presentationDetents([.large])
    }

    private func loadSaves() {
        ArkApi.shared.getSaves(host: host) { result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    saves = data.saves
                    runningMapIndex = data.runningMapIndex
                    let runningName = data.runningMapIndex >= 0 ? mapName(data.runningMapIndex) : "无"
                    statusText = "共 \(data.saves.count) 张地图，运行中: \(runningName)"
                }
            }
        }
    }

    private func deleteSave(_ save: SaveInfo) {
        ArkApi.shared.deleteSave(host: host, mapIndex: save.mapIndex) { result in
            DispatchQueue.main.async {
                if case .success = result { loadSaves() }
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

    private func formatBytes(_ bytes: Int64) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return "\(bytes / 1024) KB" }
        return "\(bytes / 1024 / 1024) MB"
    }
}
