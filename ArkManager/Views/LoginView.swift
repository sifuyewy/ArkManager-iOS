import SwiftUI

struct LoginView: View {
    @State private var cardNumber = ""
    @State private var password = ""
    @State private var statusText = ""
    @State private var statusColor = Color.gray
    @State private var isLoading = false
    @State private var isActive = false
    @State private var showServerList = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.051, green: 0.067, blue: 0.090).ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Logo
                    VStack(spacing: 12) {
                        Text("🦖")
                            .font(.system(size: 72))
                        Text("ARK Server Manager")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("方舟服务器管理器")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }

                    // 输入框
                    VStack(spacing: 16) {
                        DarkTextField(placeholder: "请输入卡号", text: $cardNumber, icon: "💳")
                        DarkSecureField(placeholder: "请输入密码", text: $password, icon: "🔒")
                    }
                    .padding(.horizontal, 24)

                    // 状态文本
                    if !statusText.isEmpty {
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(statusColor)
                    }

                    // 验证按钮
                    Button(action: verify) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isLoading ? "正在验证..." : "验证")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0, green: 0.898, blue: 1))
                        .foregroundColor(.black)
                        .cornerRadius(24)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showServerList) {
                ServerListView()
            }
            .onAppear {
                if CardApi.shared.isVerified() {
                    showServerList = true
                }
            }
        }
    }

    private func verify() {
        let cn = cardNumber.trimmingCharacters(in: .whitespaces)
        let pw = password.trimmingCharacters(in: .whitespaces)
        guard !cn.isEmpty else { statusText = "请输入卡号"; statusColor = .red; return }
        guard !pw.isEmpty else { statusText = "请输入密码"; statusColor = .red; return }

        isLoading = true
        statusText = "正在验证..."
        statusColor = .gray

        CardApi.shared.verify(cardNumber: cn, password: pw) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result.code {
                case 200:
                    CardApi.shared.setVerified(cardNumber: cn)
                    statusText = "✅ 验证成功"
                    statusColor = .green
                    showServerList = true
                case 400:
                    statusText = "❌ \(result.message)"
                    statusColor = Color(red: 1, green: 0.090, blue: 0.267)
                case 404:
                    statusText = "❌ 卡号或密码错误"
                    statusColor = Color(red: 1, green: 0.090, blue: 0.267)
                case 500:
                    statusText = "❌ 服务器异常"
                    statusColor = Color(red: 1, green: 0.090, blue: 0.267)
                default:
                    statusText = "❌ \(result.message)"
                    statusColor = Color(red: 1, green: 0.090, blue: 0.267)
                }
            }
        }
    }
}

// MARK: - 自定义输入框组件
struct DarkTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct DarkSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.129, green: 0.149, blue: 0.176))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
