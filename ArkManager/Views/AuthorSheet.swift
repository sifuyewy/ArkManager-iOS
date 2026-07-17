import SwiftUI

struct AuthorSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 20) {
                    Spacer()
                    Text("🦖")
                        .font(.system(size: 64))
                    Text("ARK Server Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("方舟服务器管理器 iOS 版")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("基于 Android 版完整移植")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("确定")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.getPrimary())
                            .foregroundColor(.black)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct AddCodeSheet: View {
    let onSave: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var code = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()
                VStack(spacing: 16) {
                    DarkTextField(placeholder: "名称", text: $name, icon: "🏷️")
                    TextEditor(text: $code)
                        .foregroundColor(.white)
                        .font(.system(.caption, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
                        .cornerRadius(12)
                        .frame(minHeight: 150)
                    Button(action: {
                        let n = name.trimmingCharacters(in: .whitespaces)
                        let c = code.trimmingCharacters(in: .whitespaces)
                        guard !n.isEmpty, !c.isEmpty else { return }
                        onSave(n, c)
                        dismiss()
                    }) {
                        Text("保存")
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
            .navigationTitle("添加代码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
