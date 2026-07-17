import SwiftUI

@main
struct ArkManagerApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
