import Foundation

class CodeDatabase {
    static let shared = CodeDatabase()
    private var allCodes: [CodeItem]? = nil
    private let customCodesKey = "custom_codes"

    func getAllCodes() -> [CodeItem] {
        if let cached = allCodes { return cached }
        var codes = [CodeItem]()

        // 加载内置代码
        if let url = Bundle.main.url(forResource: "codes", withExtension: "txt"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            let data = parseDmText(text)
            for (name, code) in data {
                codes.append(CodeItem(name: name, code: code, category: categorize(name: name, code: code)))
            }
        }

        // 加载自定义代码
        if let customData = UserDefaults.standard.data(forKey: customCodesKey),
           let customCodes = try? JSONDecoder().decode([CodeItem].self, from: customData) {
            codes.append(contentsOf: customCodes)
        }

        allCodes = codes
        return codes
    }

    func addCode(name: String, code: String) {
        var customCodes = getCustomCodes()
        customCodes.append(CodeItem(name: name, code: code, category: categorize(name: name, code: code)))
        saveCustomCodes(customCodes)
        allCodes = nil
    }

    func deleteCode(name: String) {
        var customCodes = getCustomCodes()
        customCodes.removeAll { $0.name == name }
        saveCustomCodes(customCodes)
        allCodes = nil
    }

    func updateCode(name: String, newCode: String) {
        var customCodes = getCustomCodes()
        if let index = customCodes.firstIndex(where: { $0.name == name }) {
            customCodes[index].code = newCode
            saveCustomCodes(customCodes)
        }
        allCodes = nil
    }

    private func getCustomCodes() -> [CodeItem] {
        guard let data = UserDefaults.standard.data(forKey: customCodesKey) else { return [] }
        return (try? JSONDecoder().decode([CodeItem].self, from: data)) ?? []
    }

    private func saveCustomCodes(_ codes: [CodeItem]) {
        if let data = try? JSONEncoder().encode(codes) {
            UserDefaults.standard.set(data, forKey: customCodesKey)
        }
    }

    private func parseDmText(_ text: String) -> [(String, String)] {
        var result = [(String, String)]()
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var currentName = ""
        var contentBuffer = [String]()

        for i in 0..<lines.count {
            let line = lines[i]
            if line.hasPrefix("问") {
                if !currentName.isEmpty {
                    result.append((currentName, contentBuffer.joined(separator: "\n").trimmingCharacters(in: .whitespaces)))
                }
                currentName = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                contentBuffer.removeAll()
            } else if line.hasPrefix("答") && !currentName.isEmpty {
                let codeContent = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                if !codeContent.isEmpty { contentBuffer.append(codeContent) }
                var j = i + 1
                while j < lines.count && !lines[j].hasPrefix("问") {
                    contentBuffer.append(lines[j])
                    j += 1
                }
            }
        }
        if !currentName.isEmpty {
            result.append((currentName, contentBuffer.joined(separator: "\n").trimmingCharacters(in: .whitespaces)))
        }
        return result
    }

    private func categorize(name: String, code: String) -> String {
        let n = name.lowercased()
        let c = code.lowercased()
        if c.contains("spawndino") || c.contains("spawnexactdino") || c.contains("gmSummon") ||
            n.contains("龙") || n.contains("恐龙") || n.contains("霸王") || n.contains("南巨") ||
            n.contains("飞龙") || n.contains("翼龙") || n.contains("迅猛") || n.contains("牛龙") ||
            n.contains("三角") || n.contains("剑龙") || n.contains("镰刀") || n.contains("棘背") ||
            n.contains("古神") || n.contains("风神") || n.contains("狮鹫") || n.contains("渡渡") ||
            n.contains("企鹅") || n.contains("水獭") || n.contains("绵羊") || n.contains("恐狼") ||
            n.contains("恐熊") || n.contains("剑齿虎") || n.contains("袋狮") || n.contains("骇鸟") ||
            n.contains("巨猿") || n.contains("猛犸") || n.contains("羽暴") || n.contains("异特") ||
            n.contains("鲨齿") || n.contains("沧龙") || n.contains("巨齿鲨") || n.contains("蛇颈") ||
            n.contains("鱼龙") || n.contains("蝠鲼") || n.contains("电鳗") || n.contains("食人鱼") ||
            n.contains("水母") || n.contains("安康") || n.contains("邓氏") || n.contains("利兹") ||
            n.contains("鱿鱼") || n.contains("巨蟹") || n.contains("螳螂") || n.contains("蝎子") ||
            n.contains("蜘蛛") || n.contains("古马陆") || n.contains("美颌") || n.contains("窃蛋") ||
            n.contains("小盗") || n.contains("中猴") || n.contains("双脊") || n.contains("麝足") ||
            n.contains("星尾") || n.contains("魔鬼蛙") || n.contains("庞马") || n.contains("独角兽") ||
            n.contains("大角鹿") || n.contains("始祖") || n.contains("伪齿") || n.contains("水龙") ||
            n.contains("黄昏") || n.contains("鱼鸟") || n.contains("蜣螂") || n.contains("渐新") ||
            n.contains("甲龙") || n.contains("乌龟") || n.contains("淡水") || n.contains("禽龙") ||
            n.contains("肿头") || n.contains("厚鼻") || n.contains("兽头") || n.contains("肯氏") ||
            n.contains("袋鼠") || n.contains("砂矿") || n.contains("大地懒") || n.contains("猪鳄") ||
            n.contains("古巨蜥") || n.contains("棘蜥") || n.contains("帝鳄") || n.contains("似鸡") ||
            n.contains("重爪") || n.contains("驼峰") || n.contains("披毛犀") || n.contains("斑龙") ||
            n.contains("凤凰") || n.contains("狮蝎") || n.contains("死亡蠕虫") || n.contains("岩石巨人") ||
            n.contains("灯泡犬") || n.contains("闪角") || n.contains("耀尾") || n.contains("轻羽") ||
            n.contains("劫掠") || n.contains("翻滚鼠") || n.contains("无名怪") || n.contains("追寻者") ||
            n.contains("岩龙") || n.contains("毒蜥") || n.contains("死神") || n.contains("嘎查") ||
            n.contains("气囊") || n.contains("玛纳加尔") || n.contains("雪鸮") || n.contains("刺面") ||
            n.contains("侦察") || n.contains("执行者") || n.contains("恐爪") || n.contains("玛瑙螺") ||
            n.contains("血蛛") || n.contains("猿狐") || n.contains("岛龟") || n.contains("熔喉") ||
            n.contains("虚空鲸") || n.contains("虚空海豚") || n.contains("影鬃") || n.contains("影踪") ||
            n.contains("鸭嘴飞鼠") || n.contains("跨步者") || n.contains("虚空飞龙") || n.contains("阿马加龙") ||
            n.contains("恐狒") || n.contains("安氏兽") || n.contains("吸血蝙蝠") || n.contains("芬里尔") ||
            n.contains("贝拉") || n.contains("冰熊") || n.contains("莱尼虫") || n.contains("蜂后") ||
            n.contains("幽灵") || n.contains("僵尸") || n.contains("骷髅") || n.contains("腐化") ||
            n.contains("故障") || n.contains("凶恶") || n.contains("免驯") || n.contains("免训") ||
            n.contains("驯服") || n.contains("泰坦") || n.contains("精英") || n.contains("满变") ||
            n.contains("boss") || n.contains("金刚") || n.contains("喷火龙") ||
            n.contains("监察者") || n.contains("罗克韦尔") || n.contains("莫德尔") || n.contains("主宰") ||
            n.contains("水晶飞龙") || n.contains("芬里尔巨狼") || n.contains("双狼")) { return "恐龙" }
        if n.contains("资源") || n.contains("茅草") || n.contains("木头") || n.contains("石头") ||
            n.contains("燧石") || n.contains("沙子") || n.contains("金属") || n.contains("纤维") ||
            n.contains("兽皮") || n.contains("毛皮") || n.contains("角质") || n.contains("甲壳素") ||
            n.contains("油") || n.contains("水晶") || n.contains("黑曜石") || n.contains("珍珠") ||
            n.contains("黑珍珠") || n.contains("聚合物") || n.contains("树脂") || n.contains("硫磺") ||
            n.contains("蚕丝") || n.contains("生物毒素") || n.contains("仙人掌") || n.contains("冷凝瓦斯") ||
            n.contains("宝石") || n.contains("元素") || n.contains("诱变") || n.contains("黏脂") ||
            n.contains("木炭") || n.contains("引火粉") || n.contains("汽油") || n.contains("金属锭") ||
            n.contains("水泥") || n.contains("麻醉药") || n.contains("兴奋剂") || n.contains("火药") ||
            n.contains("电路") || n.contains("吸附剂") || n.contains("蓄电池") || n.contains("浆果") ||
            n.contains("种子") || n.contains("柠檬") || n.contains("玉米") || n.contains("胡萝卜") ||
            n.contains("土豆") || n.contains("稀有") || n.contains("蜂蜜") || n.contains("蘑菇") ||
            n.contains("化肥") || n.contains("生肉") || n.contains("熟肉") || n.contains("腐肉") ||
            n.contains("优质") || n.contains("羊肉") || n.contains("鱼肉") || n.contains("肉干") ||
            n.contains("饲料") || n.contains("肉")) { return "资源" }
        if n.contains("武器") || n.contains("剑") || n.contains("矛") || n.contains("弓") ||
            n.contains("弩") || n.contains("枪") || n.contains("步枪") || n.contains("手枪") ||
            n.contains("散弹") || n.contains("霰弹") || n.contains("狙击") || n.contains("火箭") ||
            n.contains("喷火") || n.contains("电击") || n.contains("鱼叉") || n.contains("长枪") ||
            n.contains("套索") || n.contains("手铐") || n.contains("电锯") || n.contains("矿枪") ||
            n.contains("弹弓") || n.contains("回旋镖") || n.contains("流星锤") || n.contains("信号枪") ||
            n.contains("c4") || n.contains("十字弩") || n.contains("复合弓") || n.contains("金属矛") ||
            n.contains("望远镜") || n.contains("gps") || n.contains("定位器") || n.contains("冷冻仓") ||
            n.contains("照相机") || n.contains("无线电") || n.contains("鱼竿") || n.contains("降落伞") ||
            n.contains("滑翔翼") || n.contains("登山镐") || n.contains("荧光棒") || n.contains("鞭子") ||
            n.contains("涂料刷") || n.contains("剪刀") || n.contains("钳子") || n.contains("抽血器") ||
            n.contains("喷枪") || n.contains("渔网") || n.contains("爪钩") || n.contains("捕捉网") ||
            n.contains("子弹") || n.contains("弹药") || n.contains("麻醉镖") || n.contains("火箭弹")) { return "武器" }
        if n.contains("衣服") || n.contains("裤子") || n.contains("帽子") || n.contains("手套") ||
            n.contains("鞋子") || n.contains("靴子") || n.contains("头盔") || n.contains("胸甲") ||
            n.contains("护腿") || n.contains("面具") || n.contains("盾牌") || n.contains("粗布") ||
            n.contains("吉利") || n.contains("甲壳") || n.contains("防护") || n.contains("防爆") ||
            n.contains("潜水") || n.contains("防毒") || n.contains("矿工") || n.contains("夜视") ||
            n.contains("眼镜") || n.contains("铁甲") || n.contains("防弹") || n.contains("泰克套") ||
            n.contains("神人套") || n.contains("腐化套") || n.contains("化身套") || n.contains("联邦套") ||
            n.contains("传说")) { return "装备" }
        if n.contains("鞍") { return "鞍具" }
        if n.contains("地基") || n.contains("墙") || n.contains("门") || n.contains("天花板") ||
            n.contains("屋顶") || n.contains("柱子") || n.contains("楼梯") || n.contains("梯子") ||
            n.contains("斜坡") || n.contains("栅栏") || n.contains("恐龙门") || n.contains("巨兽门") ||
            n.contains("树屋") || n.contains("悬崖平台") || n.contains("海洋平台") || n.contains("电梯") ||
            n.contains("炮塔") || n.contains("拒马") || n.contains("捕兽夹") || n.contains("水雷") ||
            n.contains("篝火") || n.contains("研磨器") || n.contains("睡袋") || n.contains("床") ||
            n.contains("储物箱") || n.contains("保险柜") || n.contains("木筏") || n.contains("摩托艇") ||
            n.contains("帐篷") || n.contains("饲料槽") || n.contains("火把") || n.contains("烹饪锅") ||
            n.contains("风干箱") || n.contains("精炼炉") || n.contains("铁匠台") || n.contains("机床") ||
            n.contains("工业") || n.contains("化学") || n.contains("蜂巢") || n.contains("酒桶") ||
            n.contains("肥料箱") || n.contains("油井") || n.contains("水管") || n.contains("蓄水池") ||
            n.contains("水井") || n.contains("电缆") || n.contains("插座") || n.contains("发电机") ||
            n.contains("风力") || n.contains("电灯") || n.contains("空调") || n.contains("冰箱") ||
            n.contains("遥控板") || n.contains("压力板") || n.contains("马桶") || n.contains("货运箱") ||
            n.contains("绳梯") || n.contains("壁炉") || n.contains("旗帜") || n.contains("画布") ||
            n.contains("广告牌") || n.contains("温室") || n.contains("耕地") || n.contains("火炮") ||
            n.contains("机枪") || n.contains("自动炮") || n.contains("浮空") || n.contains("圣诞") ||
            n.contains("花环") || n.contains("节日灯") || n.contains("南瓜") || n.contains("稻草人") ||
            n.contains("建筑")) { return "建筑" }
        if n.contains("皮肤") || n.contains("时装") || n.contains("服装") || n.contains("宠物") ||
            n.contains("chibi") || n.contains("头套") || n.contains("骨架") || n.contains("仿生") ||
            n.contains("驯鹿") || n.contains("兔子") || n.contains("高脚帽") || n.contains("棉花糖") ||
            n.contains("巫师帽") || n.contains("圣诞帽") || n.contains("派对帽") || n.contains("冬季帽") ||
            n.contains("兔耳朵") || n.contains("烟花") || n.contains("生日礼服") || n.contains("丘比特") ||
            n.contains("木舟")) { return "皮肤/宠物" }
        if n.contains("神器") || n.contains("奖杯") || n.contains("战利品") || n.contains("遗物") ||
            n.contains("符文石") || n.contains("钥匙")) { return "神器/奖杯" }
        if n.contains("飞升") || n.contains("升级") || n.contains("经验") || n.contains("印痕") ||
            n.contains("解锁") || n.contains("创造") || n.contains("管理员") || n.contains("gcm") ||
            n.contains("无敌") || n.contains("回血") || n.contains("gmbuff") || n.contains("强制") ||
            n.contains("强驯") || n.contains("强训") || n.contains("留痕") || n.contains("秒破壳") ||
            n.contains("秒长大") || n.contains("改颜色") || n.contains("改属性") || n.contains("改大小") ||
            n.contains("改视角") || n.contains("帧率") || n.contains("弹药无限") || n.contains("无限状态") ||
            n.contains("无限负重") || n.contains("加速") || n.contains("显示伤害") || n.contains("一键") ||
            n.contains("全服") || n.contains("范围") || n.contains("删除") || n.contains("清除") ||
            n.contains("收编") || n.contains("传送") || n.contains("下蛋") || n.contains("改画质") ||
            n.contains("解锁成就") || n.contains("解锁笔记") || n.contains("任务") || n.contains("六角币") ||
            n.contains("空投") || n.contains("矿脉") || n.contains("头发") || n.contains("胡子") ||
            n.contains("眩晕") || n.contains("指令") || n.contains("功能")) { return "指令/功能" }
        if n.contains("染料") || n.contains("黑色") || n.contains("白色") || n.contains("红色") ||
            n.contains("蓝色") || n.contains("黄色") || n.contains("绿色") || n.contains("砖红色") ||
            n.contains("棕色") || n.contains("蜜瓜") || n.contains("青色") || n.contains("森林绿") ||
            n.contains("品红") || n.contains("咖啡") || n.contains("深蓝") || n.contains("橄榄") ||
            n.contains("橙色") || n.contains("羊皮") || n.contains("粉色") || n.contains("紫色") ||
            n.contains("皇室紫") || n.contains("银白") || n.contains("天空白") || n.contains("石板") ||
            n.contains("黄褐") || n.contains("橘黄") || n.contains("薰衣草") || n.contains("柠檬色") ||
            n.contains("冰川") || n.contains("浅粉") || n.contains("深粉") || n.contains("纯黑") ||
            n.contains("纯白") || n.contains("纯蓝") || n.contains("纯红") || n.contains("纯绿") ||
            n.contains("纯黄") || n.contains("纯青") || n.contains("纯品")) { return "染料" }
        return "其他"
    }
}
