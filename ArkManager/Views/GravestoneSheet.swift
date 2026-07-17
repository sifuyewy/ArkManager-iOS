import SwiftUI

struct GravestoneSheet: View {
    let host: String
    @Environment(\.dismiss) var dismiss
    @State private var enabled = false
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    Text("🪦")
                        .font(.system(size: 64))
                    Text("墓碑功能")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text(loaded ? (enabled ? "✅ 已开启" : "❌ 已关闭") : "加载中...")
                        .font(.headline)
                        .foregroundColor(enabled ? .green : .red)

                    Button(action: {
                        ArkApi.shared.saveGravestone(host: host, enabled: !enabled) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let data):
                                    enabled.toggle()
                                    loaded = true
                                case .failure: break
                                }
                            }
                        }
                    }) {
                        Text(loaded ? (enabled ? "关闭" : "开启") : "...")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(loaded ? (enabled ? Color.red : Color.green) : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .disabled(!loaded)
                    .padding(.horizontal, 40)

                    Spacer()
                }
            }
            .navigationTitle("墓碑功能")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .onAppear {
                ArkApi.shared.getGravestone(host: host) { result in
                    DispatchQueue.main.async {
                        if case .success(let data) = result {
                            enabled = data.enabled
                            loaded = true
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
