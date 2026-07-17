import SwiftUI

struct Theme {
    let primary: Color
    let dark: Color
    let darker: Color
    let isLight: Bool
}

class ThemeManager {
    static let shared = ThemeManager()
    private let defaults = UserDefaults.standard

    private let themes: [Theme] = [
        Theme(primary: Color(red: 0, green: 0.898, blue: 1), dark: Color(red: 0, green: 0.722, blue: 0.831), darker: Color(red: 0, green: 0.376, blue: 0.392), isLight: false), // 青色科技
        Theme(primary: Color(red: 0.486, green: 0.302, blue: 1), dark: Color(red: 0.396, green: 0.122, blue: 1), darker: Color(red: 0.192, green: 0.106, blue: 0.573), isLight: false), // 紫色梦幻
        Theme(primary: Color(red: 0, green: 0.902, blue: 0.463), dark: Color(red: 0, green: 0.784, blue: 0.325), darker: Color(red: 0, green: 0.302, blue: 0.251), isLight: false), // 绿色自然
        Theme(primary: Color(red: 1, green: 0.090, blue: 0.267), dark: Color(red: 0.835, green: 0, blue: 0), darker: Color(red: 0.545, green: 0, blue: 0), isLight: false), // 红色热情
        Theme(primary: Color(red: 1, green: 0.569, blue: 0), dark: Color(red: 1, green: 0.427, blue: 0), darker: Color(red: 0.902, green: 0.318, blue: 0), isLight: false), // 橙色活力
        Theme(primary: Color(red: 0, green: 0.690, blue: 1), dark: Color(red: 0, green: 0.569, blue: 0.918), darker: Color(red: 0.004, green: 0.341, blue: 0.612), isLight: false), // 天蓝清爽
        Theme(primary: Color(red: 1, green: 0.251, blue: 0.506), dark: Color(red: 0.961, green: 0, blue: 0.341), darker: Color(red: 0.533, green: 0.055, blue: 0.310), isLight: false), // 粉色浪漫
        Theme(primary: Color(red: 1, green: 0.843, blue: 0), dark: Color(red: 1, green: 0.757, blue: 0.039), darker: Color(red: 1, green: 0.561, blue: 0), isLight: false), // 金色奢华
        Theme(primary: Color(red: 0.878, green: 0.878, blue: 0.878), dark: Color(red: 0.129, green: 0.129, blue: 0.129), darker: Color(red: 0, green: 0, blue: 0), isLight: false), // 深色
        Theme(primary: Color(red: 0.098, green: 0.463, blue: 0.824), dark: Color(red: 0.878, green: 0.878, blue: 0.878), darker: Color(red: 1, green: 1, blue: 1), isLight: true), // 白色
        Theme(primary: Color(red: 0, green: 0.898, blue: 1), dark: Color(red: 0, green: 0.722, blue: 0.831), darker: Color(red: 0, green: 0.376, blue: 0.392), isLight: false), // 自适应
    ]

    private let themeNames = [
        "🌊 青色科技", "💜 紫色梦幻", "🟢 绿色自然", "🔴 红色热情",
        "🟠 橙色活力", "🩵 天蓝清爽", "🩷 粉色浪漫", "💛 金色奢华",
        "🌑 深色", "☀️ 白色", "⏰ 自适应"
    ]

    func getThemeIndex() -> Int {
        let idx = defaults.integer(forKey: "theme_index")
        return min(idx, themes.count - 1)
    }

    func setThemeIndex(_ index: Int) {
        defaults.set(index, forKey: "theme_index")
    }

    func getThemeNames() -> [String] { themeNames }

    func getCurrentTheme() -> Theme {
        let index = getThemeIndex()
        if index == themes.count - 1 {
            let hour = Calendar.current.component(.hour, from: Date())
            return hour >= 6 && hour <= 18 ? themes[9] : themes[8]
        }
        return themes[index]
    }

    func getPrimary() -> Color { getCurrentTheme().primary }
    func getDark() -> Color { getCurrentTheme().dark }
    func getDarker() -> Color { getCurrentTheme().darker }
    func isLightTheme() -> Bool { getCurrentTheme().isLight }
}
