local addonName, ns = ...

ns:RegisterLocale("zhCN", {
    ---------------------------------------------------------------------------
    -- HOME PAGE
    ---------------------------------------------------------------------------
    HOME_SUBTITLE = "从侧边栏选择一个模块进行配置",

    ---------------------------------------------------------------------------
    -- COMMON: UI Actions
    ---------------------------------------------------------------------------
    COMMON_UNLOCK = "解锁",
    COMMON_SAVE = "保存",
    COMMON_CANCEL = "取消",
    COMMON_ADD = "添加",
    COMMON_EDIT = "编辑",
    COMMON_RELOAD_UI = "重载界面",
    COMMON_LATER = "稍后",
    COMMON_YES = "是",
    COMMON_NO = "否",
    COMMON_RESET_DEFAULTS = "恢复默认",
    COMMON_SET = "设置",

    ---------------------------------------------------------------------------
    -- COMMON: Section Headers
    ---------------------------------------------------------------------------
    COMMON_SECTION_APPEARANCE = "外观",
    COMMON_SECTION_BEHAVIOR = "行为",
    COMMON_SECTION_DISPLAY = "显示",
    COMMON_SECTION_SETTINGS = "设置",
    COMMON_SECTION_SOUND = "声音",
    COMMON_SECTION_AUDIO = "音频",

    ---------------------------------------------------------------------------
    -- COMMON: Form Labels
    ---------------------------------------------------------------------------
    COMMON_LABEL_NAME = "名称:",
    COMMON_LABEL_SPELLID = "法术ID:",
    COMMON_LABEL_ICON_SIZE = "图标大小",
    COMMON_LABEL_FONT_SIZE = "字体大小",
    COMMON_LABEL_TEXT_SIZE = "文本大小",
    COMMON_LABEL_TEXT_COLOR = "文本颜色",
    COMMON_LABEL_COLOR = "颜色",
    COMMON_LABEL_ENABLE_SOUND = "启用声音",
    COMMON_LABEL_PLAY_SOUND = "播放声音",
    COMMON_LABEL_ALERT_SOUND = "提示音:",
    COMMON_LABEL_ALERT_COLOR = "提示颜色",
    COMMON_MATCH_BY = "匹配方式:",
    COMMON_BUFF_NAME = "增益名称",
    COMMON_ENTRIES_COMMA = "条目（逗号分隔）:",
    COMMON_LABEL_SCALE = "缩放",
    COMMON_LABEL_AUTO_CLOSE = "自动关闭",

    ---------------------------------------------------------------------------
    -- COMMON: Slider/Picker Labels (short form)
    ---------------------------------------------------------------------------
    COMMON_FONT_SIZE = "字体大小",
    COMMON_COLOR = "颜色",
    COMMON_ALPHA = "透明度",

    ---------------------------------------------------------------------------
    -- COMMON: Difficulty Filters
    ---------------------------------------------------------------------------
    COMMON_DIFF_NORMAL_DUNGEON = "普通地下城",
    COMMON_DIFF_HEROIC_DUNGEON = "英雄地下城",
    COMMON_DIFF_MYTHIC_DUNGEON = "史诗地下城",
    COMMON_DIFF_LFR = "随机团队",
    COMMON_DIFF_NORMAL_RAID = "普通团队",
    COMMON_DIFF_HEROIC_RAID = "英雄团队",
    COMMON_DIFF_MYTHIC_RAID = "史诗团队",
    COMMON_DIFF_OTHER = "其他",

    ---------------------------------------------------------------------------
    -- COMMON: Thresholds
    ---------------------------------------------------------------------------
    COMMON_THRESHOLD_DUNGEON = "地下城",
    COMMON_THRESHOLD_RAID = "团队",
    COMMON_THRESHOLD_OTHER = "其他",

    ---------------------------------------------------------------------------
    -- COMMON: Status/States
    ---------------------------------------------------------------------------
    COMMON_ON = "开",
    COMMON_OFF = "关",
    COMMON_ENABLED = "已启用",
    COMMON_DISABLED = "已禁用",
    COMMON_EXPIRED = "已过期",
    COMMON_MISSING = "缺失",

    ---------------------------------------------------------------------------
    -- COMMON: Errors
    ---------------------------------------------------------------------------
    COMMON_ERR_ENTRY_REQUIRED = "需要填写条目。",
    COMMON_ERR_SPELLID_REQUIRED = "需要填写法术ID。",

    ---------------------------------------------------------------------------
    -- COMMON: TTS Labels
    ---------------------------------------------------------------------------
    COMMON_TTS_MESSAGE = "TTS消息:",
    COMMON_TTS_VOICE = "TTS语音:",
    COMMON_TTS_VOLUME = "TTS音量",
    COMMON_TTS_SPEED = "TTS语速",

    ---------------------------------------------------------------------------
    -- COMMON: Hints
    ---------------------------------------------------------------------------
    COMMON_HINT_PARTIAL_MATCH = "部分匹配，不区分大小写。",
    COMMON_DRAG_TO_MOVE = "拖动以移动",

    ---------------------------------------------------------------------------
    -- SIDEBAR
    ---------------------------------------------------------------------------
    SIDEBAR_GROUP_COMBAT = "战斗",
    SIDEBAR_GROUP_HUD = "HUD",
    SIDEBAR_GROUP_TRACKING = "追踪",
    SIDEBAR_GROUP_REMINDERS = "提醒/杂项",
    SIDEBAR_GROUP_SYSTEM = "系统",
    SIDEBAR_TAB_COMBAT_TIMER = "战斗计时",
    SIDEBAR_TAB_COMBAT_ALERT = "战斗提醒",
    SIDEBAR_TAB_COMBAT_LOGGER = "战斗记录",
    SIDEBAR_TAB_GCD_TRACKER = "GCD追踪",
    SIDEBAR_TAB_MOUSE_RING = "鼠标光环",
    SIDEBAR_TAB_CROSSHAIR = "准星",
    SIDEBAR_TAB_FOCUS_CASTBAR = "焦点施法条",
    SIDEBAR_TAB_DRAGONRIDING = "驭龙术",
    SIDEBAR_TAB_BUFF_TRACKER = "增益追踪",
    SIDEBAR_TAB_STEALTH = "潜行/姿态",
    SIDEBAR_TAB_RANGE_CHECK = "距离检测",
    SIDEBAR_TAB_TALENT_REMINDER = "天赋提醒",
    SIDEBAR_TAB_EMOTE_DETECTION = "表情侦测",
    SIDEBAR_TAB_EQUIPMENT_REMINDER = "装备提醒",
    SIDEBAR_TAB_CREZ = "战斗复活",
    SIDEBAR_TAB_RAID_ALERTS = "团队提醒",
    SIDEBAR_TAB_OPTIMIZATIONS = "优化",
    SIDEBAR_TAB_MISC = "杂项",
    SIDEBAR_TAB_PROFILES = "配置",
    SIDEBAR_TAB_SLASH_COMMANDS = "斜杠命令",

    ---------------------------------------------------------------------------
    -- BUFF TRACKER
    ---------------------------------------------------------------------------
    BUFFTRACKER_TITLE = "增益追踪",
    BUFFTRACKER_SUBTITLE = "追踪增益、光环、姿态",
    BUFFTRACKER_ENABLE = "启用增益追踪",
    BUFFTRACKER_SECTION_TRACKING = "追踪",
    BUFFTRACKER_RAID_MODE = "团队模式",
    BUFFTRACKER_RAID_MODE_DESC = "显示所有团队增益，而不仅是你的",
    BUFFTRACKER_RAID_BUFFS = "团队增益",
    BUFFTRACKER_PERSONAL_AURAS = "个人光环",
    BUFFTRACKER_STANCES = "姿态/形态",
    BUFFTRACKER_SHOW_MISSING = "仅显示缺失",
    BUFFTRACKER_COMBAT_ONLY = "仅战斗中显示",
    BUFFTRACKER_SHOW_COOLDOWN = "显示冷却旋转",
    BUFFTRACKER_SHOW_STACKS = "显示叠加层数",
    BUFFTRACKER_GROW_DIR = "增长方向",
    BUFFTRACKER_SPACING = "间距",
    BUFFTRACKER_ICONS_PER_ROW = "每行图标数",

    ---------------------------------------------------------------------------
    -- COMBAT ALERT
    ---------------------------------------------------------------------------
    COMBATALERT_TITLE = "战斗提醒",
    COMBATALERT_SUBTITLE = "战斗通知",
    COMBATALERT_ENABLE = "启用战斗提醒",
    COMBATALERT_SECTION_ENTER = "进入战斗",
    COMBATALERT_SECTION_LEAVE = "离开战斗",
    COMBATALERT_DISPLAY_TEXT = "显示文本",
    COMBATALERT_AUDIO_MODE = "音频模式",
    COMBATALERT_AUDIO_NONE = "无",
    COMBATALERT_AUDIO_SOUND = "声音",
    COMBATALERT_AUDIO_TTS = "文字转语音",
    COMBATALERT_DEFAULT_ENTER = "++ 战斗",
    COMBATALERT_DEFAULT_LEAVE = "-- 战斗",
    COMBATALERT_TTS_ENTER = "战斗",
    COMBATALERT_TTS_LEAVE = "安全",

    ---------------------------------------------------------------------------
    -- COMBAT TIMER
    ---------------------------------------------------------------------------
    COMBATTIMER_TITLE = "战斗计时",
    COMBATTIMER_SUBTITLE = "战斗计时设置",
    COMBATTIMER_ENABLE = "启用战斗计时",
    COMBATTIMER_SECTION_OPTIONS = "选项",
    COMBATTIMER_INSTANCE_ONLY = "仅副本",
    COMBATTIMER_CHAT_REPORT = "聊天报告",
    COMBATTIMER_STICKY = "固定计时器",
    COMBATTIMER_HIDE_PREFIX = "隐藏前缀",
    COMBATTIMER_COLOR = "计时颜色",
    COMBATTIMER_CHAT_MSG = "你的战斗时长为:",
    COMBATTIMER_SHOW_BACKGROUND = "显示背景",

    ---------------------------------------------------------------------------
    -- DRAGONRIDING
    ---------------------------------------------------------------------------
    DRAGON_TITLE = "驭龙术",
    DRAGON_SUBTITLE = "天空骑行速度与精力显示",
    DRAGON_ENABLE = "启用驭龙术HUD",
    DRAGON_SECTION_LAYOUT = "布局",
    DRAGON_BAR_WIDTH = "条宽",
    DRAGON_SPEED_HEIGHT = "速度高度",
    DRAGON_CHARGE_HEIGHT = "充能高度",
    DRAGON_GAP = "间距/内边距",
    DRAGON_SECTION_ANCHOR = "锚点",
    DRAGON_ANCHOR_FRAME = "锚定到框体",
    DRAGON_ANCHOR_SELF = "锚点（自身）",
    DRAGON_ANCHOR_TARGET = "锚点（目标）",
    DRAGON_MATCH_WIDTH = "匹配锚点宽度",
    DRAGON_MATCH_WIDTH_DESC = "自动调整条宽以匹配锚点框体",
    DRAGON_OFFSET_X = "X偏移",
    DRAGON_OFFSET_Y = "Y偏移",
    DRAGON_BAR_STYLE = "条样式",
    DRAGON_SPEED_COLOR = "速度颜色",
    DRAGON_THRILL_COLOR = "刺激颜色",
    DRAGON_CHARGE_COLOR = "充能颜色",
    DRAGON_BG_COLOR = "背景颜色",
    DRAGON_BG_OPACITY = "背景不透明度",
    DRAGON_BORDER_COLOR = "边框颜色",
    DRAGON_BORDER_OPACITY = "边框不透明度",
    DRAGON_BORDER_SIZE = "边框大小",
    DRAGON_SPEED_FONT = "速度字体",
    DRAGON_SHOW_SPEED = "显示速度文本",
    DRAGON_SHOW_SPEED_DESC = "在速度条上显示数值速度",
    DRAGON_SWAP_BARS = "交换速度/充能",
    DRAGON_SWAP_BARS_DESC = "将充能条放在速度条上方",
    DRAGON_HIDE_GROUNDED = "落地且满精力时隐藏",
    DRAGON_HIDE_GROUNDED_DESC = "着陆且精力满时隐藏显示",
    DRAGON_HIDE_COOLDOWN = "骑乘时隐藏冷却管理器",
    DRAGON_HIDE_COOLDOWN_DESC = "注意：战斗中可能失败，风险自负。",
    DRAGON_SECTION_FEATURES = "功能",
    DRAGON_SECOND_WIND = "第二阵风",
    DRAGON_SECOND_WIND_DESC = "将第二阵风充能显示为底层",
    DRAGON_WHIRLING_SURGE = "旋风冲刺",
    DRAGON_WHIRLING_SURGE_DESC = "显示旋风冲刺冷却图标",
    DRAGON_SECTION_ICON = "图标",
    DRAGON_ICON_SIZE = "图标大小（0=自动）",
    DRAGON_ICON_ANCHOR = "锚点",
    DRAGON_ICON_RIGHT = "右",
    DRAGON_ICON_LEFT = "左",
    DRAGON_ICON_TOP = "上",
    DRAGON_ICON_BOTTOM = "下",
    DRAGON_ICON_BORDER_COLOR = "图标边框颜色",
    DRAGON_ICON_BORDER_OPACITY = "图标边框不透明度",
    DRAGON_ICON_BORDER_SIZE = "图标边框大小",

    ---------------------------------------------------------------------------
    -- EMOTE DETECTION
    ---------------------------------------------------------------------------
    EMOTE_TITLE = "表情侦测",
    EMOTE_SUBTITLE = "侦测盛宴、大锅和自定义表情",
    EMOTE_ENABLE = "启用表情侦测",
    EMOTE_SECTION_FILTER = "表情过滤",
    EMOTE_MATCH_PATTERN = "匹配模式:",
    EMOTE_PATTERN_HINT = "用逗号分隔的模式，用于匹配表情文本。",
    EMOTE_SECTION_AUTO = "自动表情",
    EMOTE_AUTO_DESC = "在施放特定法术时自动发送表情。",
    EMOTE_ENABLE_AUTO = "启用自动表情",
    EMOTE_COOLDOWN = "冷却（秒）",
    EMOTE_POPUP_EDIT = "编辑自动表情",
    EMOTE_POPUP_NEW = "新建自动表情",
    EMOTE_TEXT = "表情文本:",
    EMOTE_TEXT_HINT = "通过 /e 发送的文本（例如 'prepares soulwell'）",
    EMOTE_ADD = "添加自动表情",
    EMOTE_NO_AUTO = "未配置自动表情。",
    EMOTE_CLICK_BLOCK = "点击以屏蔽",
    EMOTE_ID = "ID:",

    ---------------------------------------------------------------------------
    -- FOCUS CAST BAR
    ---------------------------------------------------------------------------
    FOCUS_TITLE = "焦点施法条",
    FOCUS_SUBTITLE = "追踪焦点目标可打断的施法",
    FOCUS_ENABLE = "启用焦点施法条",
    FOCUS_BAR_COLOR = "条颜色",
    FOCUS_BAR_READY = "打断就绪",
    FOCUS_BAR_CD = "打断冷却",
    FOCUS_BACKGROUND = "背景",
    FOCUS_BG_OPACITY = "背景不透明度",
    FOCUS_SECTION_ICON = "图标",
    FOCUS_SHOW_ICON = "显示法术图标",
    FOCUS_ICON_POS = "图标位置",
    FOCUS_SECTION_TEXT = "文本",
    FOCUS_SHOW_NAME = "显示法术名称",
    FOCUS_SHOW_TIME = "显示剩余时间",
    FOCUS_SHOW_EMPOWER = "显示蓄力阶段标记",
    FOCUS_HIDE_FRIENDLY = "隐藏友方单位的施法",
    FOCUS_SECTION_NONINT = "不可打断显示",
    FOCUS_SHOW_SHIELD = "显示护盾图标",
    FOCUS_CHANGE_COLOR = "重新着色不可打断",
    FOCUS_SHOW_KICK_TICK = "显示打断冷却刻度",
    FOCUS_TICK_COLOR = "刻度颜色",
    FOCUS_HIDE_ON_CD = "打断冷却时隐藏",
    FOCUS_NONINT_COLOR = "不可打断",
    FOCUS_SOUND_START = "施法开始时播放声音",
    FOCUS_USE_TTS = "使用文字转语音（TTS）",
    FOCUS_TTS_DEFAULT = "打断",

    ---------------------------------------------------------------------------
    -- GCD TRACKER
    ---------------------------------------------------------------------------
    GCD_TITLE = "GCD追踪",
    GCD_SUBTITLE = "用滚动图标追踪最近施放的法术",
    GCD_ENABLE = "启用GCD追踪",
    GCD_COMBAT_ONLY = "仅战斗中",
    GCD_DURATION = "持续时间（秒）",
    GCD_SPACING = "间距",
    GCD_FADE_START = "开始淡出",
    GCD_SCROLL_DIR = "滚动方向",
    GCD_STACK_OVERLAPPING = "叠加重叠施放",
    GCD_SECTION_TIMELINE = "时间轴",
    GCD_THICKNESS = "厚度",
    GCD_TIMELINE_COLOR = "时间轴颜色",
    GCD_SHOW_DOWNTIME = "空档汇总",
    GCD_DOWNTIME_TOOLTIP = "战斗结束后在聊天中输出你的GCD空档百分比。",
    GCD_SECTION_ZONE = "区域可见性",
    GCD_SHOW_DUNGEONS = "在地下城显示",
    GCD_SHOW_RAIDS = "在团队副本显示",
    GCD_SHOW_ARENAS = "在竞技场显示",
    GCD_SHOW_BGS = "在战场显示",
    GCD_SHOW_WORLD = "在世界显示",
    GCD_SECTION_BLOCKLIST = "法术屏蔽列表",
    GCD_BLOCKLIST_DESC = "屏蔽特定法术不显示（输入法术ID）",
    GCD_SPELLID_PLACEHOLDER = "法术ID...",
    GCD_RECENT_SPELLS = "最近的法术（点击以屏蔽）:",
    GCD_CAST_TO_POPULATE = "施放一些技能以生成列表",

    ---------------------------------------------------------------------------
    -- MODULES (QOL MISC)
    ---------------------------------------------------------------------------
    MODULES_TITLE = "便捷功能",
    MODULES_SUBTITLE = "杂项功能",
    MODULES_SECTION_LOOT = "物品/拾取",
    MODULES_FASTER_LOOT = "更快自动拾取",
    MODULES_FASTER_LOOT_DESC = "即时自动拾取",
    MODULES_SUPPRESS_WARNINGS = "抑制拾取警告",
    MODULES_SUPPRESS_WARNINGS_DESC = "自动确认拾取对话框",
    MODULES_EASY_DESTROY = "轻松摧毁物品",
    MODULES_EASY_DESTROY_DESC = "自动填充 DELETE 文本",
    MODULES_AUTO_KEYSTONE = "自动放入钥石",
    MODULES_AUTO_KEYSTONE_DESC = "自动插入钥石",
    MODULES_AH_EXPANSION = "拍卖行当前资料片",
    MODULES_AH_EXPANSION_DESC = "将拍卖行筛选为当前资料片",
    MODULES_SECTION_UI = "界面杂乱",
    MODULES_HIDE_ALERTS = "隐藏提示",
    MODULES_HIDE_ALERTS_DESC = "隐藏成就弹窗",
    MODULES_HIDE_TALKING = "隐藏对话头像",
    MODULES_HIDE_TALKING_DESC = "隐藏NPC对话头像",
    MODULES_HIDE_TOASTS = "隐藏事件提示",
    MODULES_HIDE_TOASTS_DESC = "隐藏升级提示",
    MODULES_HIDE_ZONE = "隐藏区域文本",
    MODULES_HIDE_ZONE_DESC = "隐藏区域名称覆盖层",
    MODULES_SKIP_QUEUE = "跳过队列确认",
    MODULES_SKIP_QUEUE_DESC = "自动确认申请（按住Ctrl跳过）",
    MODULES_SECTION_DEATH = "死亡/耐久/修理",
    MODULES_DONT_RELEASE = "不自动释放",
    MODULES_DONT_RELEASE_DESC = "按住Alt 1秒释放灵魂",
    MODULES_DONT_RELEASE_TIMER = "按住Alt %.1f",
    MODULES_AUTO_REPAIR = "自动修理",
    MODULES_AUTO_REPAIR_DESC = "在商人处修理装备",
    MODULES_GUILD_FUNDS = "使用公会资金",
    MODULES_GUILD_FUNDS_DESC = "优先使用公会银行",
    MODULES_DURABILITY = "耐久警告",
    MODULES_DURABILITY_DESC = "耐久过低时提示",
    MODULES_DURABILITY_THRESHOLD = "警告阈值",
    MODULES_SECTION_QUESTING = "任务",
    MODULES_AUTO_ACCEPT = "自动接受任务（按Alt跳过）",
    MODULES_AUTO_TURNIN = "自动交任务（按Alt跳过）",
    MODULES_AUTO_GOSSIP = "自动选择对话任务（按Alt跳过）",

    ---------------------------------------------------------------------------
    -- OPTIMIZATIONS
    ---------------------------------------------------------------------------
    OPT_TITLE = "系统优化",
    OPT_SUBTITLE = "FPS优化",
    OPT_SUCCESS = "已成功应用激进的FPS优化。",
    OPT_RELOAD_REQUIRED = "需要重载界面以应用所有更改。",
    OPT_GFX_RESTART = "图形引擎已成功重启。",
    OPT_CONFLICT_WARNING = "需要重载界面以防止冲突。",
    OPT_SECTION_PRESETS = "预设",
    OPT_OPTIMAL = "最佳FPS设置",
    OPT_ULTRA = "超高设置",
    OPT_REVERT = "还原设置",
    OPT_SECTION_SQW = "法术队列窗口",
    OPT_SQW_LABEL = "法术队列窗口（毫秒）",
    OPT_SQW_RECOMMENDED = "推荐设置:",
    OPT_SQW_MELEE = "近战：延迟 + 100，",
    OPT_SQW_RANGED = "远程：延迟 + 150",
    OPT_SECTION_DIAG = "诊断",
    OPT_PROFILER = "插件性能分析器",
    OPT_SECTION_MONITOR = "实时监控",
    OPT_WARMING = "预热中...",
    OPT_UNAVAILABLE = "分析器不可用",
    OPT_AVG_TICK = "平均值（60次）:",
    OPT_LAST_TICK = "最近一次:",
    OPT_PEAK = "峰值:",
    OPT_ENCOUNTER_AVG = "本次战斗平均:",

    -- Category headers
    OPT_CAT_RENDER    = "渲染与显示",
    OPT_CAT_GRAPHICS  = "图形质量",
    OPT_CAT_DETAIL    = "视距与细节",
    OPT_CAT_ADVANCED  = "高级设置",
    OPT_CAT_FPS       = "FPS限制",
    OPT_CAT_POST      = "后期处理",

    -- CVar names (displayed in the settings table)
    OPT_CVAR_RENDER_SCALE       = "渲染比例",
    OPT_CVAR_VSYNC              = "垂直同步",
    OPT_CVAR_MSAA               = "多重采样",
    OPT_CVAR_LOW_LATENCY        = "低延迟模式",
    OPT_CVAR_ANTI_ALIASING      = "抗锯齿",
    OPT_CVAR_SHADOW             = "阴影质量",
    OPT_CVAR_LIQUID             = "液体细节",
    OPT_CVAR_PARTICLE           = "粒子密度",
    OPT_CVAR_SSAO               = "SSAO",
    OPT_CVAR_DEPTH              = "景深效果",
    OPT_CVAR_COMPUTE            = "计算效果",
    OPT_CVAR_OUTLINE            = "轮廓模式",
    OPT_CVAR_TEXTURE_RES        = "纹理分辨率",
    OPT_CVAR_SPELL_DENSITY      = "法术密度",
    OPT_CVAR_PROJECTED          = "投射纹理",
    OPT_CVAR_VIEW_DISTANCE      = "视距",
    OPT_CVAR_ENV_DETAIL         = "环境细节",
    OPT_CVAR_GROUND             = "地面杂物",
    OPT_CVAR_TRIPLE_BUFFERING   = "三重缓冲",
    OPT_CVAR_TEXTURE_FILTERING  = "纹理过滤",
    OPT_CVAR_RT_SHADOWS         = "光线追踪阴影",
    OPT_CVAR_RESAMPLE_QUALITY   = "重采样质量",
    OPT_CVAR_GFX_API            = "图形API",
    OPT_CVAR_PHYSICS            = "物理集成",
    OPT_CVAR_TARGET_FPS         = "目标FPS",
    OPT_CVAR_BG_FPS_ENABLE      = "启用后台FPS",
    OPT_CVAR_BG_FPS             = "将后台FPS设为30",
    OPT_CVAR_RESAMPLE_SHARPNESS = "重采样锐度",
    OPT_CVAR_CAMERA_SHAKE       = "镜头抖动",

    -- Quality-level display labels
    OPT_QL_UNLIMITED = "无限制",
    OPT_QL_LEVEL     = "等级 %d",

    -- Row buttons & tooltip labels
    OPT_BTN_APPLY           = "应用",
    OPT_BTN_REVERT          = "还原",
    OPT_TOOLTIP_CURRENT     = "当前:",
    OPT_TOOLTIP_RECOMMENDED = "推荐:",

    -- Spell Queue Window detail text
    OPT_SQW_DETAIL = "推荐：100-400ms。更低更灵敏，更高更能容忍延迟。",

    -- Print / notification messages
    OPT_MSG_SAVED            = "当前设置已保存！你可以随时恢复。",
    OPT_MSG_APPLIED          = "已应用 %d 项设置！正在重载界面...",
    OPT_MSG_FAILED_APPLY     = "%d 项设置无法应用。",
    OPT_MSG_RESTORED         = "已恢复 %d 项设置！正在重载界面...",
    OPT_MSG_NO_SAVED         = "未找到已保存的设置！",
    OPT_MSG_MAXFPS_SET       = "maxFPS 已设置为 %s",
    OPT_MSG_MAXFPS_REVERTED  = "maxFPS 已还原为 %s",
    OPT_MSG_CVAR_SET         = "%s 已设置为 %s",
    OPT_MSG_CVAR_FAILED      = "设置 %s 失败",
    OPT_MSG_CVAR_NO_BACKUP   = "未找到 %s 的备份",
    OPT_MSG_CVAR_REVERTED    = "%s 已还原为 %s",
    OPT_MSG_CVAR_REVERT_FAILED = "还原 %s 失败",
    OPT_MSG_SHARPENING_PREFIX = "锐化现在为 ",
    OPT_SHARP_ON             = "开（0.5）",
    OPT_SHARP_OFF            = "关",

    ---------------------------------------------------------------------------
    -- RAID ALERTS
    ---------------------------------------------------------------------------
    RAIDALERTS_TITLE = "团队提醒",
    RAIDALERTS_SUBTITLE = "盛宴、大锅和功能性施法通知",
    RAIDALERTS_ENABLE = "启用团队提醒",
    RAIDALERTS_SECTION_FEASTS = "盛宴",
    RAIDALERTS_ENABLE_FEASTS = "启用盛宴提醒",
    RAIDALERTS_TRACKED = "追踪的法术:",
    RAIDALERTS_ADD_SPELLID = "添加法术ID:",
    RAIDALERTS_ERR_VALID = "请输入有效的法术ID",
    RAIDALERTS_ERR_BUILTIN = "已是内置法术",
    RAIDALERTS_ERR_ADDED = "已添加",
    RAIDALERTS_ERR_UNKNOWN = "未知法术ID",
    RAIDALERTS_SECTION_CAULDRONS = "大锅",
    RAIDALERTS_ENABLE_CAULDRONS = "启用大锅提醒",
    RAIDALERTS_SECTION_WARLOCK = "术士",
    RAIDALERTS_ENABLE_WARLOCK = "启用术士提醒",
    RAIDALERTS_SECTION_OTHER = "其他",
    RAIDALERTS_ENABLE_OTHER = "启用其他提醒",

    ---------------------------------------------------------------------------
    -- RANGE CHECK
    ---------------------------------------------------------------------------
    RANGE_TITLE = "距离检测",
    RANGE_SUBTITLE = "目标距离追踪",
    RANGE_ENABLE = "启用距离检测",
    RANGE_COMBAT_ONLY = "仅战斗中显示",

    ---------------------------------------------------------------------------
    -- SLASH COMMANDS
    ---------------------------------------------------------------------------
    SLASH_TITLE = "斜杠命令",
    SLASH_SUBTITLE = "创建打开框体的快捷方式",
    SLASH_ENABLE = "启用斜杠命令模块",
    SLASH_NO_COMMANDS = "还没有命令。点击“添加命令”创建一个。",
    SLASH_ADD = "+ 添加命令",
    SLASH_RESTORE = "恢复默认",
    SLASH_PREFIX_RUNS = "执行:",
    SLASH_PREFIX_OPENS = "打开:",
    SLASH_DEL = "删除",
    SLASH_POPUP_ADD = "添加斜杠命令",
    SLASH_CMD_NAME = "命令名称:",
    SLASH_CMD_HINT = "（例如 'r' 对应 /r）",
    SLASH_ACTION_TYPE = "动作类型:",
    SLASH_FRAME_TOGGLE = "切换框体",
    SLASH_COMMAND = "斜杠命令",
    SLASH_SEARCH_FRAMES = "搜索框体:",
    SLASH_CMD_RUN = "要执行的命令:",
    SLASH_CMD_RUN_HINT = "例如 /reload, /script print('hi'), /invite Playername",
    SLASH_ARGS_NOTE = "传入你的别名的参数会自动追加。",
    SLASH_FRAME_WARN = "并非所有框体都可用或有意义，有些可能会抛出Lua错误",
    SLASH_POPUP_TEST = "框体测试",
    SLASH_TEST_WORKS = "可用",
    SLASH_TEST_USELESS = "无用",
    SLASH_TEST_ERROR = "Lua错误",
    SLASH_TEST_SILENT = "静默失败",
    SLASH_TEST_SKIP = "跳过",
    SLASH_TEST_STOP = "停止",
    SLASH_ERR_NAME = "请输入命令名称。",
    SLASH_ERR_INVALID = "命令名称只能包含字母、数字和下划线。",
    SLASH_ERR_FRAME = "请选择一个框体。",
    SLASH_ERR_CMD = "请输入要执行的命令。",
    SLASH_ERR_EXISTS = "已存在同名命令。",
    SLASH_WARN_CONFLICT = "已在另一个插件中存在。跳过。",
    SLASH_ERR_COMBAT = "战斗中无法切换框体。",

    ---------------------------------------------------------------------------
    -- STEALTH REMINDER
    ---------------------------------------------------------------------------
    STEALTH_TITLE = "潜行/姿态",
    STEALTH_SUBTITLE = "潜行与姿态形态提醒",
    STEALTH_ENABLE = "启用潜行提醒",
    STEALTH_SECTION_STEALTH = "潜行设置",
    STEALTH_SHOW_STEALTHED = "显示已潜行提示",
    STEALTH_SHOW_NOT = "显示未潜行提示",
    STEALTH_DISABLE_RESTED = "在休息区禁用",
    STEALTH_COLOR_STEALTHED = "已潜行",
    STEALTH_COLOR_NOT = "未潜行",
    STEALTH_TEXT = "潜行文本:",
    STEALTH_DEFAULT = "潜行",
    STEALTH_WARNING_TEXT = "警告文本:",
    STEALTH_WARNING_DEFAULT = "重新潜行",
    STEALTH_DRUID_NOTE = "德鲁伊选项（野性始终启用）:",
    STEALTH_BALANCE = "平衡",
    STEALTH_GUARDIAN = "守护",
    STEALTH_RESTORATION = "恢复",
    STEALTH_ENABLE_STANCE = "启用姿态检测",
    STEALTH_SECTION_STANCE = "姿态提醒",
    STEALTH_WRONG_COLOR = "错误姿态",
    STEALTH_STANCE_DEFAULT = "检查姿态",
    STEALTH_STANCE_DEFAULT_DRUID = "检查形态",
    STEALTH_STANCE_DEFAULT_WARRIOR = "检查姿态",
    STEALTH_STANCE_DEFAULT_PRIEST = "暗影形态",
    STEALTH_STANCE_DEFAULT_PALADIN = "检查光环",
    STEALTH_ENABLE_SOUND = "启用声音提醒",
    STEALTH_REPEAT = "重复间隔（秒）",

    ---------------------------------------------------------------------------
    -- COMBAT REZ
    ---------------------------------------------------------------------------
    CREZ_SUBTITLE = "战斗复活计时与死亡提醒",
    CREZ_ENABLE_TIMER = "启用战斗复活计时",
    CREZ_UNLOCK_LABEL = "复活计时",
    CREZ_ICON_SIZE = "图标大小",
    CREZ_TIMER_LABEL = "计时文本",
    CREZ_COUNT_LABEL = "叠加层数",
    CREZ_DEATH_WARNING = "将死亡视为警告",
    CREZ_DIED = "死亡",

    ---------------------------------------------------------------------------
    -- STATIC POPUPS
    ---------------------------------------------------------------------------
    POPUP_CHANGES_APPLIED = "更改已应用。",
    POPUP_RELOAD_WARNING = "重载界面以应用。",
    POPUP_SETTINGS_IMPORTED = "设置已导入。",
    POPUP_PROFILER_ENABLE = "需要重载以启用性能分析。",
    POPUP_PROFILER_OVERHEAD = "性能分析会增加CPU开销。",
    POPUP_PROFILER_DISABLE = "需要重载以禁用性能分析。",
    POPUP_PROFILER_RECOMMEND = "建议禁用以减少CPU开销。",
    POPUP_BUFFTRACKER_RESET = "将增益追踪重置为默认？",

    ---------------------------------------------------------------------------
    -- COMBAT LOGGER DISPLAY
    ---------------------------------------------------------------------------
    COMBATLOGGER_ENABLED = "已为 %s (%s) 启用战斗记录。",
    COMBATLOGGER_DISABLED = "已为 %s (%s) 禁用战斗记录。",
    COMBATLOGGER_STOPPED = "战斗记录已停止（离开副本）。",
    COMBATLOGGER_POPUP = "为以下内容启用战斗记录:\n%s\n(%s)\n\n你的选择将被记住。",
    COMBATLOGGER_ENABLE_BTN = "启用记录",
    COMBATLOGGER_SKIP_BTN = "跳过",
    COMBATLOGGER_ACL_WARNING = "高级战斗记录未启用。Warcraft Logs 的详细分析需要它。现在启用？",
    COMBATLOGGER_ACL_ENABLE_BTN = "启用并重载",
    COMBATLOGGER_ACL_SKIP_BTN = "跳过",

    ---------------------------------------------------------------------------
    -- TALENT REMINDER
    ---------------------------------------------------------------------------
    TALENT_COMBAT_ERROR = "战斗中无法切换天赋",
    TALENT_SWAPPED = "已切换到 %s",
    TALENT_NOT_FOUND = "未找到已保存的方案，可能已被删除",
    TALENT_SAVE_POPUP = "保存当前天赋用于:\n%s\n(%s)\n(%s)\n\n当前: %s",
    TALENT_MISMATCH_POPUP = "天赋不匹配:\n%s\n\n当前: %s\n已保存: %s",
    TALENT_SAVED = "已为 %s 保存天赋",
    TALENT_OVERWRITTEN = "已为 %s 覆盖天赋",
    TALENT_SAVE_BTN = "保存",
    TALENT_SWAP_BTN = "切换",
    TALENT_OVERWRITE_BTN = "覆盖",
    TALENT_IGNORE_BTN = "忽略",

    ---------------------------------------------------------------------------
    -- DURABILITY DISPLAY
    ---------------------------------------------------------------------------
    DURABILITY_WARNING = "耐久度过低: %d%%",

    ---------------------------------------------------------------------------
    -- GCD TRACKER DISPLAY
    ---------------------------------------------------------------------------
    GCD_DOWNTIME_MSG = "空档: %.1fs（%.1f%%）",

    ---------------------------------------------------------------------------
    -- CROSSHAIR DISPLAY
    ---------------------------------------------------------------------------
    CROSSHAIR_MELEE_UNSUPPORTED = "远程职业不支持近战距离指示器",

    ---------------------------------------------------------------------------
    -- FOCUS CAST BAR DISPLAY
    ---------------------------------------------------------------------------
    FOCUS_PREVIEW_CAST = "预览施法",
    FOCUS_PREVIEW_TIME = "1.5",

    ---------------------------------------------------------------------------
    -- MOUSE RING
    ---------------------------------------------------------------------------
    MOUSE_TITLE = "鼠标光环",
    MOUSE_SUBTITLE = "自定义光标光环与轨迹",
    MOUSE_ENABLE = "启用鼠标光环",
    MOUSE_VISIBLE_OOC = "脱战可见",
    MOUSE_HIDE_ON_CLICK = "右键时隐藏",
    MOUSE_SECTION_APPEARANCE = "外观",
    MOUSE_SHAPE = "光环形状",
    MOUSE_SHAPE_CIRCLE = "圆形",
    MOUSE_SHAPE_THIN = "细圆环",
    MOUSE_SHAPE_THICK = "粗圆环",
    MOUSE_COLOR_BACKGROUND = "背景颜色",
    MOUSE_SIZE = "光环大小",
    MOUSE_OPACITY_COMBAT = "战斗透明度",
    MOUSE_OPACITY_OOC = "脱战透明度",
    MOUSE_SECTION_GCD = "GCD扫掠",
    MOUSE_GCD_ENABLE = "启用GCD扫掠",
    MOUSE_HIDE_BACKGROUND = "隐藏背景光环（仅GCD模式）",
    MOUSE_COLOR_SWIPE = "扫掠颜色",
    MOUSE_COLOR_READY = "就绪颜色",
    MOUSE_GCD_READY_MATCH = "与扫掠相同",
    MOUSE_OPACITY_SWIPE = "扫掠透明度",
    MOUSE_CAST_SWIPE_ENABLE = "施法进度扫掠",
    MOUSE_COLOR_CAST_SWIPE = "施法扫掠颜色",
    MOUSE_SECTION_TRAIL = "鼠标轨迹",
    MOUSE_TRAIL_ENABLE = "启用鼠标轨迹",
    MOUSE_TRAIL_DURATION = "轨迹持续时间",
    MOUSE_TRAIL_COLOR = "颜色",

    ---------------------------------------------------------------------------
    -- CROSSHAIR
    ---------------------------------------------------------------------------
    CROSSHAIR_TITLE = "准星",
    CROSSHAIR_SUBTITLE = "屏幕中心准星覆盖",
    CROSSHAIR_ENABLE = "启用准星",
    CROSSHAIR_COMBAT_ONLY = "仅战斗中",
    CROSSHAIR_HIDE_MOUNTED = "骑乘时隐藏",
    CROSSHAIR_SECTION_SHAPE = "形状预设",
    CROSSHAIR_PRESET_CROSS = "十字",
    CROSSHAIR_PRESET_DOT = "仅圆点",
    CROSSHAIR_PRESET_CIRCLE = "圆环+十字",
    CROSSHAIR_ARM_TOP = "上",
    CROSSHAIR_ARM_RIGHT = "右",
    CROSSHAIR_ARM_BOTTOM = "下",
    CROSSHAIR_ARM_LEFT = "左",
    CROSSHAIR_SECTION_DIMENSIONS = "尺寸",
    CROSSHAIR_ROTATION = "旋转",
    CROSSHAIR_ARM_LENGTH = "臂长",
    CROSSHAIR_THICKNESS = "厚度",
    CROSSHAIR_CENTER_GAP = "中心间隙",
    CROSSHAIR_DOT_SIZE = "圆点大小",
    CROSSHAIR_CENTER_DOT = "中心圆点",
    CROSSHAIR_SECTION_APPEARANCE = "外观",
    CROSSHAIR_COLOR_PRIMARY = "主颜色",
    CROSSHAIR_OPACITY = "透明度",
    CROSSHAIR_DUAL_COLOR = "双色模式",
    CROSSHAIR_DUAL_COLOR_DESC = "上下与左右使用不同颜色",
    CROSSHAIR_COLOR_SECONDARY = "副颜色",
    CROSSHAIR_BORDER_ALWAYS = "始终添加边框",
    CROSSHAIR_BORDER_THICKNESS = "边框厚度",
    CROSSHAIR_COLOR_BORDER = "边框颜色",
    CROSSHAIR_SECTION_CIRCLE = "圆环",
    CROSSHAIR_CIRCLE_ENABLE = "启用圆环",
    CROSSHAIR_COLOR_CIRCLE = "圆环颜色",
    CROSSHAIR_CIRCLE_SIZE = "圆环大小",
    CROSSHAIR_SECTION_POSITION = "位置",
    CROSSHAIR_OFFSET_X = "X偏移",
    CROSSHAIR_OFFSET_Y = "Y偏移",
    CROSSHAIR_RESET_POSITION = "重置位置",
    CROSSHAIR_SECTION_DETECTION = "检测",
    CROSSHAIR_MELEE_ENABLE = "启用近战距离指示器",
    CROSSHAIR_RECOLOR_BORDER = "重新着色边框",
    CROSSHAIR_RECOLOR_ARMS = "重新着色准星臂",
    CROSSHAIR_RECOLOR_DOT = "重新着色圆点",
    CROSSHAIR_RECOLOR_CIRCLE = "重新着色圆环",
    CROSSHAIR_COLOR_OUT_OF_RANGE = "超出距离颜色",
    CROSSHAIR_SOUND_ENABLE = "启用声音提醒",
    CROSSHAIR_SOUND_INTERVAL = "重复间隔（秒）",
    CROSSHAIR_SPELL_ID = "距离检测法术ID",
    CROSSHAIR_SPELL_CURRENT = "当前: %s",
    CROSSHAIR_SPELL_UNSUPPORTED = "此专精不支持",
    CROSSHAIR_SPELL_NONE = "未配置法术",
    CROSSHAIR_RESET_SPELL = "重置为默认",

    ---------------------------------------------------------------------------
    -- PET TRACKER
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_PET_TRACKER = "宠物追踪",
    PETTRACKER_SUBTITLE = "提醒缺失宠物或宠物为被动",
    PETTRACKER_ENABLE = "启用宠物追踪",
    PETTRACKER_SHOW_ICON = "显示宠物图标",
    PETTRACKER_INSTANCE_ONLY = "仅副本中显示",
    PETTRACKER_SECTION_WARNINGS = "警告文本",
    PETTRACKER_MISSING_LABEL = "缺失文本:",
    PETTRACKER_MISSING_DEFAULT = "宠物缺失",
    PETTRACKER_PASSIVE_LABEL = "被动文本:",
    PETTRACKER_PASSIVE_DEFAULT = "宠物被动",
    PETTRACKER_WRONGPET_LABEL = "错误宠物文本:",
    PETTRACKER_WRONGPET_DEFAULT = "错误宠物",
    PETTRACKER_FELGUARD_LABEL = "恶魔卫士本地化:",
    PETTRACKER_CLASS_NOTE = "支持：猎人、术士、死亡骑士（邪恶）、法师（冰霜）",

    ---------------------------------------------------------------------------
    -- MOVEMENT ALERT
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_MOVEMENT_ALERT = "移动提醒",
    MOVEMENT_ALERT_SUBTITLE = "追踪移动冷却与时间螺旋触发",
    MOVEMENT_ALERT_ENABLE = "启用移动冷却提醒",
    MOVEMENT_ALERT_SETTINGS = "移动冷却设置",
    MOVEMENT_ALERT_DISPLAY_MODE = "显示模式:",
    MOVEMENT_ALERT_MODE_TEXT = "仅文本",
    MOVEMENT_ALERT_MODE_ICON = "图标+计时",
    MOVEMENT_ALERT_MODE_BAR = "进度条",
    MOVEMENT_ALERT_PRECISION = "计时小数位",
    MOVEMENT_ALERT_POLL_RATE = "更新频率（毫秒）",
    MOVEMENT_ALERT_TEXT_FORMAT = "文本格式:",
    MOVEMENT_ALERT_TEXT_FORMAT_HELP = "%a = 技能名称，%t = 剩余时间",
    MOVEMENT_ALERT_BAR_SHOW_ICON = "在进度条上显示图标",
    TIME_SPIRAL_ENABLE = "启用时间螺旋追踪",
    TIME_SPIRAL_SETTINGS = "时间螺旋设置",
    TIME_SPIRAL_TEXT = "显示文本:",
    TIME_SPIRAL_COLOR = "文本颜色",
    TIME_SPIRAL_SOUND_ON = "触发时播放声音",
    TIME_SPIRAL_TTS_ON = "触发时播放TTS",
    TIME_SPIRAL_TTS_MESSAGE = "TTS消息:",
    TIME_SPIRAL_TTS_VOLUME = "TTS音量",
    -- Gateway Shard
    GATEWAY_SHARD_ENABLE = "启用传送门碎片追踪",
    GATEWAY_SHARD_SETTINGS = "传送门碎片设置",
    GATEWAY_SHARD_TEXT = "显示文本:",
    GATEWAY_SHARD_COLOR = "文本颜色",
    GATEWAY_SHARD_SOUND_ON = "可用时播放声音",
    GATEWAY_SHARD_TTS_ON = "可用时播放TTS",
    GATEWAY_SHARD_TTS_MESSAGE = "TTS消息:",
    GATEWAY_SHARD_TTS_VOLUME = "TTS音量",

    ---------------------------------------------------------------------------
    -- CORE
    ---------------------------------------------------------------------------
    CORE_LOADED = "已加载。输入 |cff00ff00/nao|r 打开设置。",
    CORE_MISSING_KEY = "缺少本地化键:",

    ---------------------------------------------------------------------------
    -- BUFF WATCHER V2
    ---------------------------------------------------------------------------
    BWV2_MODULE_NAME = "增益监视器 V2",
    BWV2_TITLE = "增益监视器",
    BWV2_SUBTITLE = "就绪检查时触发的团队增益扫描",
    BWV2_ENABLE = "启用增益监视器",
    BWV2_SCAN_NOW = "立即扫描",
    BWV2_SCAN_HINT = "或使用 /nscan。/nsup 可在重载前抑制扫描。",
    BWV2_SCAN_ON_LOGIN = "登录时扫描",
    BWV2_CHAT_REPORT = "输出到聊天",
    BWV2_UNKNOWN = "未知",
    BWV2_DEFAULT_TAG = "[默认]",
    BWV2_ADD_SPELL_ID = "添加法术ID:",
    BWV2_ADD_ITEM_ID = "添加物品ID:",
    BWV2_RESTORE_DEFAULTS = "恢复默认",
    BWV2_RESTORE = "恢复",
    BWV2_DEFAULTS_HIDDEN = "（部分默认项已隐藏）",
    BWV2_DISABLED = "（已禁用）",
    BWV2_EXCLUSIVE_ONE = "（互斥：必须选择一个）",
    BWV2_EXCLUSIVE_REQUIRES = "（互斥，需要 %s）",
    BWV2_FOOD_BUFF_DETECT = "通过增益图标侦测（所有食物增益）",
    BWV2_WEAPON_ENCHANT_DETECT = "通过武器附魔检查侦测",
    BWV2_INVENTORY_DESC = "检查背包中是否有这些物品。部分物品仅在需要的职业在队伍中时检查。",
    BWV2_YOU = "（你）",
    BWV2_GROUPS_COUNT = "（%d 组）",
    BWV2_TAG_TARGETED = "[目标]",
    BWV2_TAG_WEAPON = "[武器]",
    BWV2_EXCLUSIVE = "（互斥）",
    BWV2_ADD_GROUP = "+ 添加组",
    BWV2_SECTION_THRESHOLDS = "持续时间阈值",
    BWV2_THRESHOLD_DESC = "将增益视为有效所需的最小剩余时间（分钟）。",
    BWV2_DUNGEON = "地下城:",
    BWV2_RAID = "团队:",
    BWV2_OTHER = "其他:",
    BWV2_MIN = "分钟",
    BWV2_SECTION_RAID = "团队增益",
    BWV2_SECTION_CONSUMABLES = "消耗品",
    BWV2_SECTION_INVENTORY = "背包检查",
    BWV2_SECTION_CLASS = "职业增益",
    BWV2_SECTION_REPORT_CARD = "报告卡",

    -- Class Buff Modal
    BWV2_MODAL_EDIT_TITLE = "编辑增益组",
    BWV2_MODAL_ADD_TITLE = "添加增益组",
    BWV2_CLASS = "职业:",
    BWV2_SELECT_CLASS = "选择职业",
    BWV2_GROUP_NAME = "组名:",
    BWV2_CHECK_TYPE = "检查类型:",
    BWV2_TYPE_SELF = "自身增益",
    BWV2_TYPE_TARGETED = "目标（给他人）",
    BWV2_TYPE_WEAPON = "武器附魔",
    BWV2_MIN_REQUIRED = "最少需要:",
    BWV2_MIN_HINT = "（0=全部，1+=最少）",
    BWV2_TALENT_CONDITION = "天赋条件:",
    BWV2_SELECT_TALENT = "选择天赋...",
    BWV2_FILTER_TALENTS = "输入以筛选...",
    BWV2_MODE_ACTIVATE = "点出天赋时启用",
    BWV2_MODE_SKIP = "点出天赋时跳过",
    BWV2_SPECS = "专精:",
    BWV2_ALL_SPECS = "所有专精",
    BWV2_DURATION_THRESHOLDS = "持续时间阈值:",
    BWV2_THRESHOLD_HINT = "（分钟，0=关闭）",
    BWV2_SPELL_ENCHANT_IDS = "法术/附魔ID:",
    BWV2_ERR_SELECT_CLASS = "请选择职业",
    BWV2_ERR_NAME_REQUIRED = "组名为必填",
    BWV2_ERR_ID_REQUIRED = "至少需要一个法术/附魔ID",
    BWV2_DELETE = "删除",
    BWV2_AUTO_USE_ITEM = "自动使用物品:",
    BWV2_REPORT_TITLE = "增益报告",
    BWV2_REPORT_NO_DATA = "增益报告（无数据）",
    BWV2_NO_ID = "无ID",
    BWV2_NO_SPELL_ID_ADDED = "未添加法术ID",
    BWV2_CLASSIC_DISPLAY = "经典显示",

    ---------------------------------------------------------------------------
    -- CO-TANK FRAME
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_COTANK = "副坦克框体",
    COTANK_TITLE = "副坦克框体",
    COTANK_SUBTITLE = "在团队中显示另一名坦克的生命值",
    COTANK_ENABLE = "启用副坦克框体",
    COTANK_ENABLE_DESC = "仅在团队中显示：你为坦克专精且存在另一名坦克时",
    COTANK_SECTION_HEALTH = "生命条",
    COTANK_HEALTH_COLOR = "生命颜色",
    COTANK_USE_CLASS_COLOR = "使用职业颜色",
    COTANK_BG_OPACITY = "背景不透明度",
    COTANK_WIDTH = "宽度",
    COTANK_HEIGHT = "高度",

    -- Name settings
    COTANK_SECTION_NAME = "姓名",
    COTANK_SHOW_NAME = "显示姓名",
    COTANK_NAME_FORMAT = "姓名格式",
    COTANK_NAME_FULL = "全名",
    COTANK_NAME_ABBREV = "缩写",
    COTANK_NAME_LENGTH = "姓名长度",
    COTANK_NAME_FONT_SIZE = "字体大小",
    COTANK_NAME_USE_CLASS_COLOR = "使用职业颜色",
    COTANK_NAME_COLOR = "姓名颜色",
    COTANK_PREVIEW_NAME = "TankName",

    ---------------------------------------------------------------------------
    -- EQUIPMENT REMINDER (CONFIG)
    ---------------------------------------------------------------------------
    EQUIPMENTREMINDER_ENABLE               = "启用装备提醒",
    EQUIPMENTREMINDER_SECTION_TRIGGERS     = "触发",
    EQUIPMENTREMINDER_TRIGGER_DESC         = "选择何时显示装备提醒",
    EQUIPMENTREMINDER_SHOW_INSTANCE        = "进入副本时显示",
    EQUIPMENTREMINDER_SHOW_INSTANCE_DESC   = "进入地下城、团队或场景战役时显示装备",
    EQUIPMENTREMINDER_SHOW_READYCHECK      = "就绪检查时显示",
    EQUIPMENTREMINDER_SHOW_READYCHECK_DESC = "发起就绪检查时显示装备",
    EQUIPMENTREMINDER_AUTOHIDE             = "自动隐藏延迟",
    EQUIPMENTREMINDER_AUTOHIDE_DESC        = "自动隐藏前的秒数（0=仅手动关闭）",
    EQUIPMENTREMINDER_ICON_SIZE_DESC       = "装备图标大小",
    EQUIPMENTREMINDER_SECTION_PREVIEW      = "预览",
    EQUIPMENTREMINDER_SHOW_FRAME           = "显示装备框体",
    EQUIPMENTREMINDER_SECTION_ENCHANT      = "附魔检查",
    EQUIPMENTREMINDER_ENCHANT_DESC         = "在装备提醒框体中显示附魔状态",
    EQUIPMENTREMINDER_ENCHANT_ENABLE       = "启用附魔检查",
    EQUIPMENTREMINDER_ENCHANT_ENABLE_DESC  = "在装备提醒中显示附魔状态行",
    EQUIPMENTREMINDER_ALL_SPECS            = "所有专精使用相同规则",
    EQUIPMENTREMINDER_ALL_SPECS_DESC       = "启用后，附魔规则对所有专精生效",
    EQUIPMENTREMINDER_CAPTURE              = "捕获当前",
    EQUIPMENTREMINDER_EXPECTED_ENCHANT     = "期望附魔",
    EQUIPMENTREMINDER_CAPTURED             = "已从已装备物品捕获 %d 个附魔",
})