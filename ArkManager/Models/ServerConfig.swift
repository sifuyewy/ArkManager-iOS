import Foundation

struct ConfigField: Identifiable {
    var id: String { key }
    let category: String
    let file: String
    let section: String
    let key: String
    let label: String
    let defaultValue: String
    let kind: String // text, int, float, bool
}

struct ServerConfigSpec {
    static let fields: [ConfigField] = [
        // 基础信息
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "SessionSettings", key: "SessionName", label: "服务器名称", defaultValue: "", kind: "text"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "ServerSettings", key: "ServerPassword", label: "服务器密码", defaultValue: "", kind: "text"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "ServerSettings", key: "ServerAdminPassword", label: "管理员密码", defaultValue: "123456", kind: "text"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "ServerSettings", key: "SpectatorPassword", label: "旁观者密码", defaultValue: "", kind: "text"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "/Script/Engine.GameSession", key: "MaxPlayers", label: "最大玩家数", defaultValue: "51", kind: "int"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "ServerSettings", key: "AutoSavePeriodMinutes", label: "自动保存间隔(分钟)", defaultValue: "15.0", kind: "float"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "MessageOfTheDay", key: "Message", label: "每日消息", defaultValue: "", kind: "text"),
        ConfigField(category: "基础信息", file: "GameUserSettings.ini", section: "MessageOfTheDay", key: "Duration", label: "每日消息秒数", defaultValue: "20", kind: "int"),

        // 倍率
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "XPMultiplier", label: "经验倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "HarvestAmountMultiplier", label: "采集倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "HarvestHealthMultiplier", label: "资源血量倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "TamingSpeedMultiplier", label: "驯服速度倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "ItemStackSizeMultiplier", label: "物品堆叠倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "倍率", file: "GameUserSettings.ini", section: "ServerSettings", key: "ResourcesRespawnPeriodMultiplier", label: "资源刷新周期", defaultValue: "1.0", kind: "float"),

        // 玩家
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerDamageMultiplier", label: "玩家伤害倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerResistanceMultiplier", label: "玩家抗性倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerCharacterWaterDrainMultiplier", label: "玩家口渴消耗", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerCharacterFoodDrainMultiplier", label: "玩家饥饿消耗", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerCharacterStaminaDrainMultiplier", label: "玩家耐力消耗", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "PlayerCharacterHealthRecoveryMultiplier", label: "玩家回血倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "玩家", file: "GameUserSettings.ini", section: "ServerSettings", key: "OxygenSwimSpeedStatMultiplier", label: "氧气游泳速度", defaultValue: "1.0", kind: "float"),

        // 恐龙
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoCountMultiplier", label: "野生恐龙数量", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoDamageMultiplier", label: "恐龙伤害倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "TamedDinoDamageMultiplier", label: "驯养恐龙伤害", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoResistanceMultiplier", label: "恐龙抗性倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "TamedDinoResistanceMultiplier", label: "驯养恐龙抗性", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoCharacterFoodDrainMultiplier", label: "恐龙食物消耗", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoCharacterStaminaDrainMultiplier", label: "恐龙耐力消耗", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "DinoCharacterHealthRecoveryMultiplier", label: "恐龙回血倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "MaxTamedDinos", label: "最大驯养恐龙数", defaultValue: "2400", kind: "int"),
        ConfigField(category: "恐龙", file: "GameUserSettings.ini", section: "ServerSettings", key: "MaxPersonalTamedDinos", label: "个人最大驯养数", defaultValue: "40.0", kind: "float"),

        // 繁殖留痕
        ConfigField(category: "繁殖留痕", file: "GameUserSettings.ini", section: "ServerSettings", key: "MatingIntervalMultiplier", label: "交配间隔倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "繁殖留痕", file: "GameUserSettings.ini", section: "ServerSettings", key: "EggHatchSpeedMultiplier", label: "孵蛋速度倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "繁殖留痕", file: "GameUserSettings.ini", section: "ServerSettings", key: "BabyMatureSpeedMultiplier", label: "幼崽成长速度", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "繁殖留痕", file: "GameUserSettings.ini", section: "ServerSettings", key: "BabyImprintAmountMultiplier", label: "每次留痕量", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "繁殖留痕", file: "GameUserSettings.ini", section: "ServerSettings", key: "BabyCuddleIntervalMultiplier", label: "留痕间隔倍率", defaultValue: "1.0", kind: "float"),

        // 规则
        ConfigField(category: "规则", file: "GameUserSettings.ini", section: "ServerSettings", key: "ServerHardcore", label: "硬核模式", defaultValue: "False", kind: "bool"),
        ConfigField(category: "规则", file: "GameUserSettings.ini", section: "ServerSettings", key: "ServerPVE", label: "PVE模式", defaultValue: "False", kind: "bool"),
        ConfigField(category: "规则", file: "GameUserSettings.ini", section: "ServerSettings", key: "AllowCaveBuildingPvP", label: "PVP允许洞穴建筑", defaultValue: "True", kind: "bool"),
        ConfigField(category: "规则", file: "GameUserSettings.ini", section: "ServerSettings", key: "PreventOfflinePvP", label: "离线保护", defaultValue: "False", kind: "bool"),
        ConfigField(category: "规则", file: "GameUserSettings.ini", section: "ServerSettings", key: "PreventOfflinePvPInterval", label: "离线保护延迟(秒)", defaultValue: "900", kind: "int"),

        // 显示
        ConfigField(category: "显示", file: "GameUserSettings.ini", section: "ServerSettings", key: "ServerCrosshair", label: "启用准星", defaultValue: "True", kind: "bool"),
        ConfigField(category: "显示", file: "GameUserSettings.ini", section: "ServerSettings", key: "AllowThirdPersonPlayer", label: "允许第三人称", defaultValue: "True", kind: "bool"),
        ConfigField(category: "显示", file: "GameUserSettings.ini", section: "ServerSettings", key: "ShowMapPlayerLocation", label: "地图显示玩家位置", defaultValue: "True", kind: "bool"),
        ConfigField(category: "显示", file: "GameUserSettings.ini", section: "ServerSettings", key: "AllowHitMarkers", label: "启用命中提示", defaultValue: "True", kind: "bool"),
        ConfigField(category: "显示", file: "GameUserSettings.ini", section: "ServerSettings", key: "ShowFloatingDamageText", label: "显示浮动伤害", defaultValue: "False", kind: "bool"),

        // 环境
        ConfigField(category: "环境", file: "GameUserSettings.ini", section: "ServerSettings", key: "DayCycleSpeedScale", label: "昼夜循环速度", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "环境", file: "GameUserSettings.ini", section: "ServerSettings", key: "DayTimeSpeedScale", label: "白天速度", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "环境", file: "GameUserSettings.ini", section: "ServerSettings", key: "NightTimeSpeedScale", label: "夜晚速度", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "环境", file: "GameUserSettings.ini", section: "ServerSettings", key: "DisableWeatherFog", label: "禁用天气雾", defaultValue: "False", kind: "bool"),

        // 建筑
        ConfigField(category: "建筑", file: "GameUserSettings.ini", section: "ServerSettings", key: "StructureResistanceMultiplier", label: "建筑抗性倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "建筑", file: "GameUserSettings.ini", section: "ServerSettings", key: "StructureDamageMultiplier", label: "建筑伤害倍率", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "建筑", file: "GameUserSettings.ini", section: "ServerSettings", key: "TheMaxStructuresInRange", label: "范围最大建筑数", defaultValue: "10500", kind: "int"),
        ConfigField(category: "建筑", file: "GameUserSettings.ini", section: "ServerSettings", key: "AlwaysAllowStructurePickup", label: "总是允许拾取建筑", defaultValue: "False", kind: "bool"),
        ConfigField(category: "建筑", file: "GameUserSettings.ini", section: "ServerSettings", key: "StructurePickupTimeAfterPlacement", label: "建筑可拾取时间", defaultValue: "30.0", kind: "float"),

        // 高级
        ConfigField(category: "高级", file: "GameUserSettings.ini", section: "ServerSettings", key: "DifficultyOffset", label: "难度偏移", defaultValue: "1.0", kind: "float"),
        ConfigField(category: "高级", file: "GameUserSettings.ini", section: "ServerSettings", key: "OverrideOfficialDifficulty", label: "官方难度覆盖", defaultValue: "4.0", kind: "float"),
        ConfigField(category: "高级", file: "GameUserSettings.ini", section: "ServerSettings", key: "KickIdlePlayersPeriod", label: "挂机踢出(秒)", defaultValue: "3600", kind: "int"),
        ConfigField(category: "高级", file: "GameUserSettings.ini", section: "ServerSettings", key: "RCONEnabled", label: "启用RCON", defaultValue: "True", kind: "bool"),
        ConfigField(category: "高级", file: "GameUserSettings.ini", section: "ServerSettings", key: "RCONPort", label: "RCON端口", defaultValue: "27020", kind: "int"),
    ]

    static func getCategories() -> [String] {
        var seen = Set<String>()
        return fields.filter { seen.insert($0.category).inserted }.map { $0.category }
    }

    static func getByCategory(_ category: String) -> [ConfigField] {
        fields.filter { $0.category == category }
    }
}
