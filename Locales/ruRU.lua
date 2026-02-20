local addonName, ns = ...

ns:RegisterLocale("ruRU", {
    ---------------------------------------------------------------------------
    -- HOME PAGE
    ---------------------------------------------------------------------------
    HOME_SUBTITLE = "Выберите модуль в боковом меню для настройки",

    ---------------------------------------------------------------------------
    -- COMMON: UI Actions
    ---------------------------------------------------------------------------
    COMMON_UNLOCK = "Разблокировать",
    COMMON_SAVE = "Сохранить",
    COMMON_CANCEL = "Отмена",
    COMMON_ADD = "Добавить",
    COMMON_EDIT = "Изменить",
    COMMON_RELOAD_UI = "Перезагрузить интерфейс",
    COMMON_LATER = "Позже",
    COMMON_YES = "Да",
    COMMON_NO = "Нет",
    COMMON_RESET_DEFAULTS = "Сбросить по умолчанию",
    COMMON_SET = "Установить",

    ---------------------------------------------------------------------------
    -- COMMON: Section Headers
    ---------------------------------------------------------------------------
    COMMON_SECTION_APPEARANCE = "ВНЕШНИЙ ВИД",
    COMMON_SECTION_BEHAVIOR = "РЕЖИМ",
    COMMON_SECTION_DISPLAY = "ОТОБРАЖЕНИЕ",
    COMMON_SECTION_SETTINGS = "НАСТРОЙКИ",
    COMMON_SECTION_SOUND = "ЗВУК",
    COMMON_SECTION_AUDIO = "АУДИО",

    ---------------------------------------------------------------------------
    -- COMMON: Form Labels
    ---------------------------------------------------------------------------
    COMMON_LABEL_NAME = "Название:",
    COMMON_LABEL_SPELLID = "ID заклинания:",
    COMMON_LABEL_ICON_SIZE = "Размер иконки",
    COMMON_LABEL_FONT_SIZE = "Размер шрифта",
    COMMON_LABEL_TEXT_SIZE = "Размер текста",
    COMMON_LABEL_TEXT_COLOR = "Цвет текста",
    COMMON_LABEL_COLOR = "Цвет",
    COMMON_LABEL_ENABLE_SOUND = "Включить звук",
    COMMON_LABEL_PLAY_SOUND = "Проигрывать звук",
    COMMON_LABEL_ALERT_SOUND = "Звук оповещения:",
    COMMON_LABEL_ALERT_COLOR = "Цвет оповещения",
    COMMON_MATCH_BY = "Сопоставлять по:",
    COMMON_BUFF_NAME = "Название баффа",
    COMMON_ENTRIES_COMMA = "Значения (через запятую):",
    COMMON_LABEL_SCALE = "Масштаб",
    COMMON_LABEL_AUTO_CLOSE = "Автозакрытие",

    ---------------------------------------------------------------------------
    -- COMMON: Slider/Picker Labels
    ---------------------------------------------------------------------------
    COMMON_FONT_SIZE = "Размер шрифта",
    COMMON_COLOR = "Цвет",
    COMMON_ALPHA = "Прозрачность",

    ---------------------------------------------------------------------------
    -- COMMON: Difficulty Filters
    ---------------------------------------------------------------------------
    COMMON_DIFF_NORMAL_DUNGEON = "Обычное подземелье",
    COMMON_DIFF_HEROIC_DUNGEON = "Героическое подземелье",
    COMMON_DIFF_MYTHIC_DUNGEON = "Эпохальное подземелье",
    COMMON_DIFF_LFR = "Поиск рейда",
    COMMON_DIFF_NORMAL_RAID = "Обычный рейд",
    COMMON_DIFF_HEROIC_RAID = "Героический рейд",
    COMMON_DIFF_MYTHIC_RAID = "Эпохальный рейд",
    COMMON_DIFF_OTHER = "Другое",

    ---------------------------------------------------------------------------
    -- COMMON: Thresholds
    ---------------------------------------------------------------------------
    COMMON_THRESHOLD_DUNGEON = "Подземелье",
    COMMON_THRESHOLD_RAID = "Рейд",
    COMMON_THRESHOLD_OTHER = "Другое",

    ---------------------------------------------------------------------------
    -- COMMON: Status/States
    ---------------------------------------------------------------------------
    COMMON_ON = "ВКЛ.",
    COMMON_OFF = "ВЫКЛ.",
    COMMON_ENABLED = "Включено",
    COMMON_DISABLED = "Отключено",
    COMMON_EXPIRED = "ИСТЕКЛО",
    COMMON_MISSING = "ОТСУТСТВУЕТ",

    ---------------------------------------------------------------------------
    -- COMMON: Errors
    ---------------------------------------------------------------------------
    COMMON_ERR_ENTRY_REQUIRED = "Необходимо значение.",
    COMMON_ERR_SPELLID_REQUIRED = "Требуется ID заклинания.",

    ---------------------------------------------------------------------------
    -- COMMON: TTS Labels
    ---------------------------------------------------------------------------
    COMMON_TTS_MESSAGE = "Сообщение TTS:",
    COMMON_TTS_VOICE = "Голос TTS:",
    COMMON_TTS_VOLUME = "Громкость TTS",
    COMMON_TTS_SPEED = "Скорость TTS",

    ---------------------------------------------------------------------------
    -- COMMON: Hints
    ---------------------------------------------------------------------------
    COMMON_HINT_PARTIAL_MATCH = "Частичное совпадение, без учёта регистра.",
    COMMON_DRAG_TO_MOVE = "Перетащите для перемещения",

    ---------------------------------------------------------------------------
    -- SIDEBAR
    ---------------------------------------------------------------------------
    SIDEBAR_GROUP_COMBAT = "БОЙ",
    SIDEBAR_GROUP_HUD = "ИНТЕРФЕЙС",
    SIDEBAR_GROUP_TRACKING = "ОТСЛЕЖИВАНИЕ",
    SIDEBAR_GROUP_REMINDERS = "НАПОМИНАНИЯ / ПРОЧЕЕ",
    SIDEBAR_GROUP_SYSTEM = "СИСТЕМА",
    SIDEBAR_TAB_COMBAT_TIMER = "Таймер боя",
    SIDEBAR_TAB_COMBAT_ALERT = "Оповещения боя",
    SIDEBAR_TAB_COMBAT_LOGGER = "Журнал боя",
    SIDEBAR_TAB_GCD_TRACKER = "Отслеживание ГКД",
    SIDEBAR_TAB_MOUSE_RING = "Кольцо курсора",
    SIDEBAR_TAB_CROSSHAIR = "Прицел",
    SIDEBAR_TAB_FOCUS_CASTBAR = "Полоса каста фокуса",
    SIDEBAR_TAB_DRAGONRIDING = "Полёты на драконе",
    SIDEBAR_TAB_BUFF_TRACKER = "Отслеживание баффов",
    SIDEBAR_TAB_STEALTH = "Незаметность / стойки",
    SIDEBAR_TAB_RANGE_CHECK = "Проверка дистанции",
    SIDEBAR_TAB_TALENT_REMINDER = "Напоминание о талантах",
    SIDEBAR_TAB_EMOTE_DETECTION = "Обнаружение эмоций",
    SIDEBAR_TAB_EQUIPMENT_REMINDER = "Напоминание о снаряжении",
    SIDEBAR_TAB_CREZ = "Боевое воскрешение",
    SIDEBAR_TAB_RAID_ALERTS = "Рейдовые оповещения",
    SIDEBAR_TAB_OPTIMIZATIONS = "Оптимизация",
    SIDEBAR_TAB_MISC = "Разное",
    SIDEBAR_TAB_PROFILES = "Профили",
    SIDEBAR_TAB_SLASH_COMMANDS = "Слэш-команды",

    ---------------------------------------------------------------------------
    -- BUFF TRACKER
    ---------------------------------------------------------------------------
    BUFFTRACKER_TITLE = "ОТСЛЕЖИВАНИЕ БАФФОВ",
    BUFFTRACKER_SUBTITLE = "Отслеживание баффов, аур и стоек",
    BUFFTRACKER_ENABLE = "Включить отслеживание баффов",
    BUFFTRACKER_SECTION_TRACKING = "ОТСЛЕЖИВАНИЕ",
    BUFFTRACKER_RAID_MODE = "Режим рейда",
    BUFFTRACKER_RAID_MODE_DESC = "Показывать ВСЕ рейдовые баффы, а не только Ваши",
    BUFFTRACKER_RAID_BUFFS = "Рейдовые баффы",
    BUFFTRACKER_PERSONAL_AURAS = "Личные ауры",
    BUFFTRACKER_STANCES = "Стойки / формы",
    BUFFTRACKER_SHOW_MISSING = "Показывать только отсутствующие",
    BUFFTRACKER_COMBAT_ONLY = "Показывать только в бою",
    BUFFTRACKER_SHOW_COOLDOWN = "Показывать спираль перезарядки",
    BUFFTRACKER_SHOW_STACKS = "Показывать количество эффектов",
    BUFFTRACKER_GROW_DIR = "Направление роста",
    BUFFTRACKER_SPACING = "Отступ",
    BUFFTRACKER_ICONS_PER_ROW = "Иконок в ряду",

    ---------------------------------------------------------------------------
    -- COMBAT ALERT
    ---------------------------------------------------------------------------
    COMBATALERT_TITLE = "БОЕВЫЕ ОПОВЕЩЕНИЯ",
    COMBATALERT_SUBTITLE = "Оповещения о входе и выходе из боя",
    COMBATALERT_ENABLE = "Включить боевые оповещения",
    COMBATALERT_SECTION_ENTER = "ВХОД В БОЙ",
    COMBATALERT_SECTION_LEAVE = "ВЫХОД ИЗ БОЯ",
    COMBATALERT_DISPLAY_TEXT = "Отображаемый текст",
    COMBATALERT_AUDIO_MODE = "Аудиорежим",
    COMBATALERT_AUDIO_NONE = "Нет",
    COMBATALERT_AUDIO_SOUND = "Звук",
    COMBATALERT_AUDIO_TTS = "Синтез речи",
    COMBATALERT_DEFAULT_ENTER = "++ Бой",
    COMBATALERT_DEFAULT_LEAVE = "-- Бой",
    COMBATALERT_TTS_ENTER = "Бой",
    COMBATALERT_TTS_LEAVE = "Безопасно",

    ---------------------------------------------------------------------------
    -- COMBAT TIMER
    ---------------------------------------------------------------------------
    COMBATTIMER_TITLE = "ТАЙМЕР БОЯ",
    COMBATTIMER_SUBTITLE = "Настройки таймера боя",
    COMBATTIMER_ENABLE = "Включить таймер боя",
    COMBATTIMER_SECTION_OPTIONS = "ПАРАМЕТРЫ",
    COMBATTIMER_INSTANCE_ONLY = "Только в подземельях",
    COMBATTIMER_CHAT_REPORT = "Отчёт в чат",
    COMBATTIMER_STICKY = "Закреплённый таймер",
    COMBATTIMER_HIDE_PREFIX = "Скрыть префикс",
    COMBATTIMER_COLOR = "Цвет таймера",
    COMBATTIMER_CHAT_MSG = "Время в бою:",
    COMBATTIMER_SHOW_BACKGROUND = "Показывать фон",

    ---------------------------------------------------------------------------
    -- DRAGONRIDING
    ---------------------------------------------------------------------------
    DRAGON_TITLE = "ПОЛЁТ НА ДРАКОНЕ",
    DRAGON_SUBTITLE = "Отображение скорости и энергии небесного полёта",
    DRAGON_ENABLE = "Включить интерфейс полёта на драконе",
    DRAGON_SECTION_LAYOUT = "РАСПОЛОЖЕНИЕ",
    DRAGON_BAR_WIDTH = "Ширина полосы",
    DRAGON_SPEED_HEIGHT = "Высота полосы скорости",
    DRAGON_CHARGE_HEIGHT = "Высота полосы зарядов",
    DRAGON_GAP = "Отступ / Интервал",
    DRAGON_SECTION_ANCHOR = "КРЕПЛЕНИЕ",
    DRAGON_ANCHOR_FRAME = "Прикрепить к фрейму",
    DRAGON_ANCHOR_SELF = "Точка крепления (своя)",
    DRAGON_ANCHOR_TARGET = "Точка крепления (цель)",
    DRAGON_MATCH_WIDTH = "Подгонять ширину под крепление",
    DRAGON_MATCH_WIDTH_DESC = "Автоматически подстраивать ширину полосы под фрейм крепления",
    DRAGON_OFFSET_X = "Смещение по X",
    DRAGON_OFFSET_Y = "Смещение по Y",
    DRAGON_BAR_STYLE = "Стиль полос",
    DRAGON_SPEED_COLOR = "Цвет скорости",
    DRAGON_THRILL_COLOR = "Цвет азарта",
    DRAGON_CHARGE_COLOR = "Цвет зарядов",
    DRAGON_BG_COLOR = "Цвет фона",
    DRAGON_BG_OPACITY = "Прозрачность фона",
    DRAGON_BORDER_COLOR = "Цвет рамки",
    DRAGON_BORDER_OPACITY = "Прозрачность рамки",
    DRAGON_BORDER_SIZE = "Толщина рамки",
    DRAGON_SPEED_FONT = "Шрифт скорости",
    DRAGON_SHOW_SPEED = "Показывать значение скорости",
    DRAGON_SHOW_SPEED_DESC = "Отображать числовое значение на полосе скорости",
    DRAGON_SWAP_BARS = "Поменять местами скорость и заряды",
    DRAGON_SWAP_BARS_DESC = "Разместить полосы зарядов над полосой скорости",
    DRAGON_HIDE_GROUNDED = "Скрывать на земле при полной энергии",
    DRAGON_HIDE_GROUNDED_DESC = "Скрывать интерфейс после приземления при полной энергии",
    DRAGON_HIDE_COOLDOWN = "Скрывать менеджер перезарядок при полёте",
    DRAGON_HIDE_COOLDOWN_DESC = "Примечание: переключение может не работать в бою, используйте на свой риск.",
    DRAGON_SECTION_FEATURES = "ВОЗМОЖНОСТИ",
    DRAGON_SECOND_WIND = "Второе дыхание",
    DRAGON_SECOND_WIND_DESC = "Показывать заряды 'Второго дыхания' в виде подложки",
    DRAGON_WHIRLING_SURGE = "Крутящий импульс",
    DRAGON_WHIRLING_SURGE_DESC = "Показывать иконку восстановления 'Крутящего импульса'",
    DRAGON_SECTION_ICON = "ИКОНКА",
    DRAGON_ICON_SIZE = "Размер иконки (0 = авто)",
    DRAGON_ICON_ANCHOR = "Расположение",
    DRAGON_ICON_RIGHT = "Справа",
    DRAGON_ICON_LEFT = "Слева",
    DRAGON_ICON_TOP = "Сверху",
    DRAGON_ICON_BOTTOM = "Снизу",
    DRAGON_ICON_BORDER_COLOR = "Цвет рамки иконки",
    DRAGON_ICON_BORDER_OPACITY = "Прозрачность рамки иконки",
    DRAGON_ICON_BORDER_SIZE = "Толщина рамки иконки",
	
	---------------------------------------------------------------------------
    -- EMOTE DETECTION
    ---------------------------------------------------------------------------
    EMOTE_TITLE = "ОПРЕДЕЛЕНИЕ ЭМОЦИЙ",
    EMOTE_SUBTITLE = "Определяет пиршества, котлы и пользовательские эмоции",
    EMOTE_ENABLE = "Включить определение эмоций",
    EMOTE_SECTION_FILTER = "ФИЛЬТР ЭМОЦИЙ",
    EMOTE_MATCH_PATTERN = "Шаблон совпадения:",
    EMOTE_PATTERN_HINT = "Шаблоны через запятую, проверяемые по тексту эмоций.",
    EMOTE_SECTION_AUTO = "АВТОМАТИЧЕСКИЕ ЭМОЦИИ",
    EMOTE_AUTO_DESC = "Автоматически отправляет эмоции при применении определённых заклинаний.",
    EMOTE_ENABLE_AUTO = "Включить автоэмоции",
    EMOTE_COOLDOWN = "Перезарядка (сек.)",
    EMOTE_POPUP_EDIT = "Редактировать автоэмоцию",
    EMOTE_POPUP_NEW = "Новая автоэмоция",
    EMOTE_TEXT = "Текст эмоции:",
    EMOTE_TEXT_HINT = "Текст, отправляемый через /e (например: 'готовит колодец душ')",
    EMOTE_ADD = "Добавить автоэмоцию",
    EMOTE_NO_AUTO = "Автоэмоции не настроены.",
    EMOTE_CLICK_BLOCK = "Нажмите, чтобы заблокировать",
    EMOTE_ID = "ID:",
	
	---------------------------------------------------------------------------
    -- FOCUS CAST BAR
    ---------------------------------------------------------------------------
    FOCUS_TITLE = "ПОЛОСА КАСТА ФОКУСА",
    FOCUS_SUBTITLE = "Отслеживание прерываемых заклинаний цели фокуса",
    FOCUS_ENABLE = "Включить полосу каста фокуса",
    FOCUS_BAR_COLOR = "Цвет полосы",
    FOCUS_BAR_READY = "Прерывание готово",
    FOCUS_BAR_CD = "КД прерывания",
    FOCUS_BACKGROUND = "Фон",
    FOCUS_BG_OPACITY = "Прозрачность фона",
    FOCUS_SECTION_ICON = "ИКОНКА",
    FOCUS_SHOW_ICON = "Показывать иконку заклинания",
    FOCUS_ICON_POS = "Позиция иконки",
    FOCUS_SECTION_TEXT = "ТЕКСТ",
    FOCUS_SHOW_NAME = "Показывать название заклинания",
    FOCUS_SHOW_TIME = "Показывать оставшееся время",
    FOCUS_SHOW_EMPOWER = "Показывать стадии усиления",
    FOCUS_HIDE_FRIENDLY = "Скрывать касты союзных целей",
    FOCUS_SECTION_NONINT = "НЕПРЕРЫВАЕМЫЕ ЗАКЛИНАНИЯ",
    FOCUS_SHOW_SHIELD = "Показывать иконку щита",
    FOCUS_CHANGE_COLOR = "Менять цвет непрерываемых",
    FOCUS_SHOW_KICK_TICK = "Показывать индикатор перезарядки прерывания",
    FOCUS_TICK_COLOR = "Цвет индикатора",
    FOCUS_HIDE_ON_CD = "Скрывать, если прерывание на перезарядке",
    FOCUS_NONINT_COLOR = "Непрерываемое",
    FOCUS_SOUND_START = "Проигрывать звук в начале каста",
    FOCUS_USE_TTS = "Использовать синтез речи (TTS)",
    FOCUS_TTS_DEFAULT = "Прерывание",
	
	---------------------------------------------------------------------------
    -- GCD TRACKER
    ---------------------------------------------------------------------------
    GCD_TITLE = "ОТСЛЕЖИВАНИЕ ГКД",
    GCD_SUBTITLE = "Отслеживание последних заклинаний с прокруткой иконок",
    GCD_ENABLE = "Включить отслеживание ГКД",
    GCD_COMBAT_ONLY = "Только в бою",
    GCD_DURATION = "Длительность (сек.)",
    GCD_SPACING = "Интервал",
    GCD_FADE_START = "Начало затухания",
    GCD_SCROLL_DIR = "Направление прокрутки",
    GCD_STACK_OVERLAPPING = "Наложение повторяющихся заклинаний",
    GCD_SECTION_TIMELINE = "ВРЕМЕННАЯ ШКАЛА",
    GCD_THICKNESS = "Толщина",
    GCD_TIMELINE_COLOR = "Цвет временной шкалы",
    GCD_SHOW_DOWNTIME = "Сводка простоя",
    GCD_DOWNTIME_TOOLTIP = "Выводит процент простоя ГКД после окончания боя.",
    GCD_SECTION_ZONE = "ОТОБРАЖЕНИЕ В ЗОНАХ",
    GCD_SHOW_DUNGEONS = "Показывать в подземельях",
    GCD_SHOW_RAIDS = "Показывать в рейдах",
    GCD_SHOW_ARENAS = "Показывать на аренах",
    GCD_SHOW_BGS = "Показывать на полях боя",
    GCD_SHOW_WORLD = "Показывать в открытом мире",
    GCD_SECTION_BLOCKLIST = "СПИСОК ИСКЛЮЧЕНИЙ ЗАКЛИНАНИЙ",
    GCD_BLOCKLIST_DESC = "Исключить определённые заклинания из отображения (введите ID заклинания)",
    GCD_SPELLID_PLACEHOLDER = "ID заклинания...",
    GCD_RECENT_SPELLS = "Недавние заклинания (нажмите, чтобы исключить):",
    GCD_CAST_TO_POPULATE = "используйте способности для заполнения списка",
	
	---------------------------------------------------------------------------
    -- MODULES (QOL MISC)
    ---------------------------------------------------------------------------
    MODULES_TITLE = "УДОБСТВА (РАЗНОЕ)",
    MODULES_SUBTITLE = "Различные дополнительные функции",
    MODULES_SECTION_LOOT = "ПРЕДМЕТЫ / ДОБЫЧА",
    MODULES_FASTER_LOOT = "Быстрый автолут",
    MODULES_FASTER_LOOT_DESC = "Мгновенный автоматический сбор добычи",
    MODULES_SUPPRESS_WARNINGS = "Отключить предупреждения о добыче",
    MODULES_SUPPRESS_WARNINGS_DESC = "Автоматически подтверждать окна добычи",
    MODULES_EASY_DESTROY = "Простое уничтожение предметов",
    MODULES_EASY_DESTROY_DESC = "Автоматически заполнять текст 'DELETE'",
    MODULES_AUTO_KEYSTONE = "Автовставка ключа",
    MODULES_AUTO_KEYSTONE_DESC = "Автоматически вставлять мифический ключ",
    MODULES_AH_EXPANSION = "Аукцион: текущее дополнение",
    MODULES_AH_EXPANSION_DESC = "Фильтровать аукцион по текущему дополнению",
    MODULES_SECTION_UI = "ЗАГРОМОЖДЕНИЕ ИНТЕРФЕЙСА",
    MODULES_HIDE_ALERTS = "Скрывать оповещения",
    MODULES_HIDE_ALERTS_DESC = "Скрывать всплывающие окна достижений",
    MODULES_HIDE_TALKING = "Скрывать говорящую голову",
    MODULES_HIDE_TALKING_DESC = "Скрывать портреты NPC с репликами",
    MODULES_HIDE_TOASTS = "Скрывать уведомления событий",
    MODULES_HIDE_TOASTS_DESC = "Скрывать уведомления о повышении уровня",
    MODULES_HIDE_ZONE = "Скрывать название зоны",
    MODULES_HIDE_ZONE_DESC = "Скрывать надпись с названием зоны",
    MODULES_SKIP_QUEUE = "Пропуск подтверждения очереди",
    MODULES_SKIP_QUEUE_DESC = "Автоподтверждение заявок (Ctrl - отменить)",
    MODULES_SECTION_DEATH = "СМЕРТЬ / ПРОЧНОСТЬ / РЕМОНТ",
    MODULES_DONT_RELEASE = "Не отпускать дух",
    MODULES_DONT_RELEASE_DESC = "Удерживайте Alt 1 сек. для выпуска духа",
    MODULES_DONT_RELEASE_TIMER = "Удерживайте Alt %.1f",
    MODULES_AUTO_REPAIR = "Автоматический ремонт",
    MODULES_AUTO_REPAIR_DESC = "Ремонтировать экипировку у торговцев",
    MODULES_GUILD_FUNDS = "Использовать средства гильдии",
    MODULES_GUILD_FUNDS_DESC = "Сначала использовать банк гильдии",
    MODULES_DURABILITY = "Предупреждение о прочности",
    MODULES_DURABILITY_DESC = "Оповещать при низкой прочности",
    MODULES_DURABILITY_THRESHOLD = "Порог предупреждения",
    MODULES_SECTION_QUESTING = "ЗАДАНИЯ",
    MODULES_AUTO_ACCEPT = "Автопринятие заданий (Alt - пропустить)",
    MODULES_AUTO_TURNIN = "Автосдача заданий (Alt - пропустить)",
    MODULES_AUTO_GOSSIP = "Автовыбор заданий в диалогах (Alt - пропустить)",
	
	---------------------------------------------------------------------------
    -- OPTIMIZATIONS
    ---------------------------------------------------------------------------
    OPT_TITLE = "ОПТИМИЗАЦИЯ СИСТЕМЫ",
    OPT_SUBTITLE = "Оптимизация FPS",
    OPT_SUCCESS = "Агрессивная оптимизация FPS успешно применена.",
    OPT_RELOAD_REQUIRED = "Для применения всех изменений требуется перезагрузка интерфейса.",
    OPT_GFX_RESTART = "Графический движок успешно перезапущен.",
    OPT_CONFLICT_WARNING = "Для предотвращения конфликтов требуется перезагрузка интерфейса.",
    OPT_SECTION_PRESETS = "ПРЕСЕТЫ",
    OPT_OPTIMAL = "Оптимальные настройки FPS",
    OPT_ULTRA = "Настройки 'Ультра'",
    OPT_REVERT = "Вернуть настройки",
    OPT_SECTION_SQW = "ОКНО ОЧЕРЕДИ ЗАКЛИНАНИЙ",
    OPT_SQW_LABEL = "Окно очереди заклинаний (мс)",
    OPT_SQW_RECOMMENDED = "Рекомендуемые значения:",
    OPT_SQW_MELEE = "Ближний бой: пинг + 100,",
    OPT_SQW_RANGED = "Дальний бой: пинг + 150",
    OPT_SECTION_DIAG = "ДИАГНОСТИКА",
    OPT_PROFILER = "Профилирование аддонов",
    OPT_SECTION_MONITOR = "МОНИТОРИНГ В РЕАЛЬНОМ ВРЕМЕНИ",
    OPT_WARMING = "Инициализация...",
    OPT_UNAVAILABLE = "Профилирование недоступно",
    OPT_AVG_TICK = "Среднее (60 тиков):",
    OPT_LAST_TICK = "Последний тик:",
    OPT_PEAK = "Пик:",
    OPT_ENCOUNTER_AVG = "Среднее за бой:",
	
	---------------------------------------------------------------------------
    -- RAID ALERTS
    ---------------------------------------------------------------------------
    RAIDALERTS_TITLE = "РЕЙДОВЫЕ ОПОВЕЩЕНИЯ",
    RAIDALERTS_SUBTITLE = "Уведомления о пиршествах, котлах и полезных заклинаниях",
    RAIDALERTS_ENABLE = "Включить рейдовые оповещения",
    RAIDALERTS_SECTION_FEASTS = "ПИРШЕСТВА",
    RAIDALERTS_ENABLE_FEASTS = "Включить оповещения о пиршествах",
    RAIDALERTS_TRACKED = "Отслеживаемые заклинания:",
    RAIDALERTS_ADD_SPELLID = "Добавить ID заклинания:",
    RAIDALERTS_ERR_VALID = "Введите корректный ID заклинания",
    RAIDALERTS_ERR_BUILTIN = "Заклинание уже встроено",
    RAIDALERTS_ERR_ADDED = "Заклинание уже добавлено",
    RAIDALERTS_ERR_UNKNOWN = "Неизвестный ID заклинания",
    RAIDALERTS_SECTION_CAULDRONS = "КОТЛЫ",
    RAIDALERTS_ENABLE_CAULDRONS = "Включить оповещения о котлах",
    RAIDALERTS_SECTION_WARLOCK = "ЧЕРНОКНИЖНИК",
    RAIDALERTS_ENABLE_WARLOCK = "Включить оповещения чернокнижника",
    RAIDALERTS_SECTION_OTHER = "ПРОЧЕЕ",
    RAIDALERTS_ENABLE_OTHER = "Включить прочие оповещения",

    ---------------------------------------------------------------------------
    -- RANGE CHECK
    ---------------------------------------------------------------------------
    RANGE_TITLE = "ПРОВЕРКА ДИСТАНЦИИ",
    RANGE_SUBTITLE = "Отслеживание расстояния до цели",
    RANGE_ENABLE = "Включить проверку дистанции",
    RANGE_COMBAT_ONLY = "Показывать только в бою",

    ---------------------------------------------------------------------------
    -- SLASH COMMANDS
    ---------------------------------------------------------------------------
    SLASH_TITLE = "СЛЭШ-КОМАНДЫ",
    SLASH_SUBTITLE = "Создание команд для быстрого доступа",
    SLASH_ENABLE = "Включить модуль слэш-команд",
    SLASH_NO_COMMANDS = "Команды отсутствуют. Нажмите 'Добавить команду'.",
    SLASH_ADD = "+ Добавить команду",
    SLASH_RESTORE = "Восстановить по умолчанию",
    SLASH_PREFIX_RUNS = "Выполняет:",
    SLASH_PREFIX_OPENS = "Открывает:",
    SLASH_DEL = "Удалить",
    SLASH_POPUP_ADD = "Добавить слэш-команду",
    SLASH_CMD_NAME = "Название команды:",
    SLASH_CMD_HINT = "(например, 'r' для /r)",
    SLASH_ACTION_TYPE = "Тип действия:",
    SLASH_FRAME_TOGGLE = "Переключение фрейма",
    SLASH_COMMAND = "Слэш-команда",
    SLASH_SEARCH_FRAMES = "Поиск окон:",
    SLASH_CMD_RUN = "Выполняемая команда:",
    SLASH_CMD_RUN_HINT = "например: /reload, /script print('hi'), /invite Игрок",
    SLASH_ARGS_NOTE = "Аргументы автоматически добавляются к алиасу.",
    SLASH_FRAME_WARN = "Некоторые фреймы могут не работать или вызывать Lua-ошибки",
    SLASH_POPUP_TEST = "Тест фрейм",
    SLASH_TEST_WORKS = "Работает",
    SLASH_TEST_USELESS = "Бесполезно",
    SLASH_TEST_ERROR = "Lua-ошибка",
    SLASH_TEST_SILENT = "Тихий сбой",
    SLASH_TEST_SKIP = "Пропустить",
    SLASH_TEST_STOP = "Остановить",
    SLASH_ERR_NAME = "Введите название команды.",
    SLASH_ERR_INVALID = "Имя может содержать только буквы, цифры и подчёркивания.",
    SLASH_ERR_FRAME = "Пожалуйста, выберите фрейм.",
    SLASH_ERR_CMD = "Пожалуйста, введите команду для выполнения.",
    SLASH_ERR_EXISTS = "Команда с таким именем уже существует.",
    SLASH_WARN_CONFLICT = "уже существует в другом аддоне. Пропуск.",
    SLASH_ERR_COMBAT = "Нельзя переключать фреймы в бою.",
	
	---------------------------------------------------------------------------
    -- STEALTH REMINDER
    ---------------------------------------------------------------------------
    STEALTH_TITLE = "НЕЗАМЕТНОСТЬ / СТОЙКА",
    STEALTH_SUBTITLE = "Напоминания о незаметности и формах",
    STEALTH_ENABLE = "Включить напоминание о незаметности",
    STEALTH_SECTION_STEALTH = "НАСТРОЙКИ НЕЗАМЕТНОСТИ",
    STEALTH_SHOW_STEALTHED =  "Показывать уведомление 'В незаметности'",
    STEALTH_SHOW_NOT =  "Показывать уведомление 'Не в незаметности'",
    STEALTH_DISABLE_RESTED = "Отключать в зонах отдыха",
    STEALTH_COLOR_STEALTHED = "В незаметности",
    STEALTH_COLOR_NOT = "Не в незаметности",
    STEALTH_TEXT = "Текст незаметности:",
    STEALTH_DEFAULT = "НЕЗАМЕТНОСТЬ",
    STEALTH_WARNING_TEXT = "Текст предупреждения:",
    STEALTH_WARNING_DEFAULT = "ВОЙТИ В НЕЗАМЕТНОСТЬ",
    STEALTH_DRUID_NOTE = "Настройки друида ('Сила зверя' всегда включена):",
    STEALTH_BALANCE = "Баланс",
    STEALTH_GUARDIAN = "Страж",
    STEALTH_RESTORATION = "Исцеление",
    STEALTH_ENABLE_STANCE = "Включить проверку стойки",
    STEALTH_SECTION_STANCE = "ОПОВЕЩЕНИЯ О СТОЙКЕ",
    STEALTH_WRONG_COLOR = "Неверная стойка",
    STEALTH_STANCE_DEFAULT = "ПРОВЕРИТЬ СТОЙКУ",
    STEALTH_STANCE_DEFAULT_DRUID = "ПРОВЕРИТЬ ФОРМУ",
    STEALTH_STANCE_DEFAULT_WARRIOR = "ПРОВЕРИТЬ СТОЙКУ",
    STEALTH_STANCE_DEFAULT_PRIEST = "ФОРМА ТЬМЫ",
    STEALTH_STANCE_DEFAULT_PALADIN = "ПРОВЕРИТЬ АУРУ",
    STEALTH_ENABLE_SOUND = "Включить звуковое оповещение",
    STEALTH_REPEAT = "Интервал повторения (сек.)",
	
	---------------------------------------------------------------------------
    -- COMBAT REZ
    ---------------------------------------------------------------------------
    CREZ_SUBTITLE = "Таймер боевого воскрешения и оповещения о смерти",
    CREZ_ENABLE_TIMER = "Включить таймер боевого воскрешения",
    CREZ_UNLOCK_LABEL = "Таймер воскрешения",
    CREZ_ICON_SIZE = "Размер иконки",
    CREZ_TIMER_LABEL = "Текст таймера",
    CREZ_COUNT_LABEL = "Количество зарядов",
    CREZ_DEATH_WARNING = "Смерть как предупреждение",
    CREZ_DIED = "погиб",
    
    ---------------------------------------------------------------------------
    -- STATIC POPUPS
    ---------------------------------------------------------------------------
    POPUP_CHANGES_APPLIED = "Изменения применены.",
    POPUP_RELOAD_WARNING = "Для применения требуется перезагрузка интерфейса.",
    POPUP_SETTINGS_IMPORTED = "Настройки импортированы.",
    POPUP_PROFILER_ENABLE = "Для включения профилирования требуется перезагрузка.",
    POPUP_PROFILER_OVERHEAD = "Профилирование увеличивает нагрузку на процессор.",
    POPUP_PROFILER_DISABLE = "Для отключения профилирования требуется перезагрузка.",
    POPUP_PROFILER_RECOMMEND = "Рекомендуется для снижения нагрузки на процессор.",
    POPUP_BUFFTRACKER_RESET = "Сбросить отслеживание баффов к значениям по умолчанию?",
	
	---------------------------------------------------------------------------
    -- COMBAT LOGGER DISPLAY
    ---------------------------------------------------------------------------
    COMBATLOGGER_ENABLED = "Журнал боя включен для %s (%s).",
    COMBATLOGGER_DISABLED = "Журнал боя отключен для %s (%s).",
    COMBATLOGGER_STOPPED = "Запись журнала боя остановлена (выход из подземелья).",
    COMBATLOGGER_POPUP = "Включить запись журнала боя для:\n%s\n(%s)\n\nВаш выбор будет сохранён.",
    COMBATLOGGER_ENABLE_BTN = "Включить запись",
    COMBATLOGGER_SKIP_BTN = "Пропустить",
    COMBATLOGGER_ACL_WARNING = "Расширенный журнал боя отключён. Он необходим для детального анализа логов на Warcraft Logs. Включить сейчас?",
    COMBATLOGGER_ACL_ENABLE_BTN = "Включить и перезагрузить",
    COMBATLOGGER_ACL_SKIP_BTN = "Пропустить",
    
    ---------------------------------------------------------------------------
    -- TALENT REMINDER
    ---------------------------------------------------------------------------
    TALENT_COMBAT_ERROR = "Нельзя менять таланты в бою",
    TALENT_SWAPPED = "Активирована специализация: %s",
    TALENT_NOT_FOUND = "Сохранённый набор талантов не найден - возможно, он был удалён",
    TALENT_SAVE_POPUP = "Сохранить текущие таланты для:\n%s\n(%s)\n(%s)\n\nТекущие: %s",
    TALENT_MISMATCH_POPUP = "Несоответствие талантов для:\n%s\n\nТекущие: %s\nСохранённые: %s",
    TALENT_SAVED = "Таланты сохранены для %s",
    TALENT_OVERWRITTEN = "Таланты перезаписаны для %s",
    TALENT_SAVE_BTN = "Сохранить",
    TALENT_SWAP_BTN = "Сменить",
    TALENT_OVERWRITE_BTN = "Перезаписать",
    TALENT_IGNORE_BTN = "Игнорировать",
    
    ---------------------------------------------------------------------------
    -- DURABILITY DISPLAY
    ---------------------------------------------------------------------------
    DURABILITY_WARNING = "Низкая прочность: %d%%",
    
    ---------------------------------------------------------------------------
    -- GCD TRACKER DISPLAY
    ---------------------------------------------------------------------------
    GCD_DOWNTIME_MSG = "Простой: %.1f сек. (%.1f%%)",
    
    ---------------------------------------------------------------------------
    -- CROSSHAIR DISPLAY
    ---------------------------------------------------------------------------
    CROSSHAIR_MELEE_UNSUPPORTED = "Индикатор ближнего боя не поддерживается для классов дальнего боя",
    
    ---------------------------------------------------------------------------
    -- FOCUS CAST BAR DISPLAY
    ---------------------------------------------------------------------------
    FOCUS_PREVIEW_CAST = "Предпросмотр каста",
    FOCUS_PREVIEW_TIME = "1.5",
	
	---------------------------------------------------------------------------
    -- MOUSE RING
    ---------------------------------------------------------------------------
    MOUSE_TITLE = "КОЛЬЦО КУРСОРА",
    MOUSE_SUBTITLE = "Настройка кольца и следа курсора",
    MOUSE_ENABLE = "Включить кольцо курсора",
    MOUSE_VISIBLE_OOC = "Видимо вне боя",
    MOUSE_HIDE_ON_CLICK = "Скрывать при ПКМ",
    MOUSE_SECTION_APPEARANCE = "ВНЕШНИЙ ВИД",
    MOUSE_SHAPE = "Форма кольца",
    MOUSE_SHAPE_CIRCLE = "Круг",
    MOUSE_SHAPE_THIN = "Тонкий круг",
    MOUSE_SHAPE_THICK = "Толстый круг",
    MOUSE_COLOR_BACKGROUND = "Цвет фона",
    MOUSE_SIZE = "Размер кольца",
    MOUSE_OPACITY_COMBAT = "Прозрачность в бою",
    MOUSE_OPACITY_OOC = "Прозрачность вне боя",
    MOUSE_SECTION_GCD = "ИНДИКАТОР ГКД",
    MOUSE_GCD_ENABLE = "Включить индикатор ГКД",
    MOUSE_HIDE_BACKGROUND = "Скрывать фоновое кольцо (только ГКД)",
    MOUSE_COLOR_SWIPE = "Цвет заполнения",
    MOUSE_COLOR_READY = "Цвет готовности",
    MOUSE_GCD_READY_MATCH = "Совпадает с заполнением",
    MOUSE_OPACITY_SWIPE = "Прозрачность заполнения",
    MOUSE_CAST_SWIPE_ENABLE = "Индикатор каста",
    MOUSE_COLOR_CAST_SWIPE = "Цвет каста",
    MOUSE_SECTION_TRAIL = "СЛЕД КУРСОРА",
    MOUSE_TRAIL_ENABLE = "Включить след курсора",
    MOUSE_TRAIL_DURATION = "Длительность следа",
    MOUSE_TRAIL_COLOR = "Цвет",

    ---------------------------------------------------------------------------
    -- CROSSHAIR
    ---------------------------------------------------------------------------
    CROSSHAIR_TITLE = "ПРИЦЕЛ",
    CROSSHAIR_SUBTITLE = "Наложение прицела в центре экрана",
    CROSSHAIR_ENABLE = "Включить прицел",
    CROSSHAIR_COMBAT_ONLY = "Только в бою",
    CROSSHAIR_HIDE_MOUNTED = "Скрывать верхом",
    CROSSHAIR_SECTION_SHAPE = "ПРЕСЕТЫ ФОРМЫ",
    CROSSHAIR_PRESET_CROSS = "Крест",
    CROSSHAIR_PRESET_DOT = "Только точка",
    CROSSHAIR_PRESET_CIRCLE = "Круг + крест",
    CROSSHAIR_ARM_TOP = "Сверху",
    CROSSHAIR_ARM_RIGHT = "Справа",
    CROSSHAIR_ARM_BOTTOM = "Снизу",
    CROSSHAIR_ARM_LEFT = "Слева",
    CROSSHAIR_SECTION_DIMENSIONS = "РАЗМЕРЫ",
    CROSSHAIR_ROTATION = "Поворот",
    CROSSHAIR_ARM_LENGTH = "Длина лучей",
    CROSSHAIR_THICKNESS = "Толщина",
    CROSSHAIR_CENTER_GAP = "Зазор в центре",
    CROSSHAIR_DOT_SIZE = "Размер точки",
    CROSSHAIR_CENTER_DOT = "Центральная точка",
    CROSSHAIR_SECTION_APPEARANCE = "ВНЕШНИЙ ВИД",
    CROSSHAIR_COLOR_PRIMARY = "Основной цвет",
    CROSSHAIR_OPACITY = "Прозрачность",
    CROSSHAIR_DUAL_COLOR = "Двухцветный режим",
    CROSSHAIR_DUAL_COLOR_DESC = "Разные цвета для верх/низ и лево/право",
    CROSSHAIR_COLOR_SECONDARY = "Вторичный цвет",
    CROSSHAIR_BORDER_ALWAYS = "Всегда показывать обводку",
    CROSSHAIR_BORDER_THICKNESS = "Толщина обводки",
    CROSSHAIR_COLOR_BORDER = "Цвет обводки",
    CROSSHAIR_SECTION_CIRCLE = "КРУГ",
    CROSSHAIR_CIRCLE_ENABLE = "Включить круг",
    CROSSHAIR_COLOR_CIRCLE = "Цвет круга",
    CROSSHAIR_CIRCLE_SIZE = "Размер круга",
    CROSSHAIR_SECTION_POSITION = "ПОЗИЦИЯ",
    CROSSHAIR_OFFSET_X = "Смещение по X",
    CROSSHAIR_OFFSET_Y = "Смещение по Y",
    CROSSHAIR_RESET_POSITION = "Сбросить позицию",
    CROSSHAIR_SECTION_DETECTION = "ОПРЕДЕЛЕНИЕ ДИСТАНЦИИ",
    CROSSHAIR_MELEE_ENABLE = "Включить индикатор ближнего боя",
    CROSSHAIR_RECOLOR_BORDER = "Перекрашивать обводку",
    CROSSHAIR_RECOLOR_ARMS = "Перекрашивать лучи",
    CROSSHAIR_RECOLOR_DOT = "Перекрашивать точку",
    CROSSHAIR_RECOLOR_CIRCLE = "Перекрашивать круг",
    CROSSHAIR_COLOR_OUT_OF_RANGE = "Цвет вне дистанции",
    CROSSHAIR_SOUND_ENABLE = "Включить звуковое оповещение",
    CROSSHAIR_SOUND_INTERVAL = "Интервал повторения (сек.)",
    CROSSHAIR_SPELL_ID = "ID заклинания для проверки дистанции",
    CROSSHAIR_SPELL_CURRENT = "Текущее: %s",
    CROSSHAIR_SPELL_UNSUPPORTED = "Не поддерживается для этой специализации",
    CROSSHAIR_SPELL_NONE = "Заклинание не задано",
    CROSSHAIR_RESET_SPELL = "Сбросить по умолчанию",
	
	---------------------------------------------------------------------------
    -- PET TRACKER
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_PET_TRACKER = "Отслеживание питомцев",
    PETTRACKER_SUBTITLE = "Оповещения об отсутствующих или пассивных питомцах",
    PETTRACKER_ENABLE = "Включить отслеживание питомцев",
    PETTRACKER_SHOW_ICON = "Показывать иконку питомца",
    PETTRACKER_INSTANCE_ONLY = "Только в подземельях",
    PETTRACKER_SECTION_WARNINGS = "ТЕКСТ ПРЕДУПРЕЖДЕНИЙ",
    PETTRACKER_MISSING_LABEL = "Текст для отсутствующего питомца:",
    PETTRACKER_MISSING_DEFAULT = "Питомец отсутствует",
    PETTRACKER_PASSIVE_LABEL = "Текст для пассивного питомца:",
    PETTRACKER_PASSIVE_DEFAULT = "Питомец пассивен",
    PETTRACKER_WRONGPET_LABEL = "Текст для неправильного питомца:",
    PETTRACKER_WRONGPET_DEFAULT = "Неправильный питомец",
    PETTRACKER_FELGUARD_LABEL = "Локализация Стража Скверны:",
    PETTRACKER_CLASS_NOTE = "Поддерживаются: Охотник, Чернокнижник, Рыцарь смерти (Нечестивость), Маг (Лёд)",
    
    ---------------------------------------------------------------------------
    -- MOVEMENT ALERT
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_MOVEMENT_ALERT = "Оповещения о движении",
    MOVEMENT_ALERT_SUBTITLE = "Отслеживание КД способностей движения и срабатывания 'Спираль времени'",
    MOVEMENT_ALERT_ENABLE = "Включить оповещения перезарядки движения",
    MOVEMENT_ALERT_SETTINGS = "НАСТРОЙКИ ПЕРЕЗАРЯДКИ ДВИЖЕНИЯ",
    MOVEMENT_ALERT_DISPLAY_MODE = "Режим отображения:",
    MOVEMENT_ALERT_MODE_TEXT = "Только текст",
    MOVEMENT_ALERT_MODE_ICON = "Иконка + таймер",
    MOVEMENT_ALERT_MODE_BAR = "Полоса прогресса",
    MOVEMENT_ALERT_PRECISION = "Десятичные знаки таймера",
    MOVEMENT_ALERT_POLL_RATE = "Частота обновления (мс)",
    MOVEMENT_ALERT_TEXT_FORMAT = "Формат текста:",
    MOVEMENT_ALERT_TEXT_FORMAT_HELP = "%a = название способности, %t = оставшееся время",
    MOVEMENT_ALERT_BAR_SHOW_ICON = "Показывать иконку на полосе прогресса",
    TIME_SPIRAL_ENABLE = "Включить отслеживание 'Спираль времени'",
    TIME_SPIRAL_SETTINGS = "НАСТРОЙКИ 'СПИРАЛИ ВРЕМЕНИ'",
    TIME_SPIRAL_TEXT = "Отображать текст:",
    TIME_SPIRAL_COLOR = "Цвет текста",
    TIME_SPIRAL_SOUND_ON = "Проигрывать звук при активации",
    TIME_SPIRAL_TTS_ON = "Проигрывать TTS при активации",
    TIME_SPIRAL_TTS_MESSAGE = "Сообщение TTS:",
    TIME_SPIRAL_TTS_VOLUME = "Громкость TTS",
    -- Gateway Shard
    GATEWAY_SHARD_ENABLE = "Включить отслеживание 'Осколка Врат'",
    GATEWAY_SHARD_SETTINGS = "НАСТРОЙКИ 'ОСКОЛКА ВРАТ'",
    GATEWAY_SHARD_TEXT = "Отображать текст:",
    GATEWAY_SHARD_COLOR = "Цвет текста",
    GATEWAY_SHARD_SOUND_ON = "Проигрывать звук при доступности",
    GATEWAY_SHARD_TTS_ON = "Проигрывать TTS при доступности",
    GATEWAY_SHARD_TTS_MESSAGE = "Сообщение TTS:",
    GATEWAY_SHARD_TTS_VOLUME = "Громкость TTS",
	
	---------------------------------------------------------------------------
    -- CORE
    ---------------------------------------------------------------------------
    CORE_LOADED = "Загружено. Введите |cff00ff00/nao|r для открытия настроек.",
    CORE_MISSING_KEY = "Отсутствует ключ локализации:",
	
	---------------------------------------------------------------------------
    -- BUFF WATCHER V2
    ---------------------------------------------------------------------------
    BWV2_MODULE_NAME = "Buff Watcher V2",
    BWV2_TITLE = "Отслеживание баффов",
    BWV2_SUBTITLE = "Сканер баффов рейда при проверке готовности",
    BWV2_ENABLE = "Включить сканер баффов",
    BWV2_SCAN_NOW = "Сканировать сейчас",
    BWV2_SCAN_HINT = "или используйте /nscan. /nsup, чтобы запретить сканирование до перезагрузки.",
    BWV2_SCAN_ON_LOGIN = "Сканировать при входе",
    BWV2_CHAT_REPORT = "Вывод в чат",
    BWV2_UNKNOWN = "Неизвестно",
    BWV2_DEFAULT_TAG = "[По умолчанию]",
    BWV2_ADD_SPELL_ID = "Добавить ID заклинания:",
    BWV2_ADD_ITEM_ID = "Добавить ID предмета:",
    BWV2_RESTORE_DEFAULTS = "Восстановить по умолчанию",
    BWV2_RESTORE = "Восстановить",
    BWV2_DEFAULTS_HIDDEN = "(Некоторые значения по умолчанию скрыты)",
    BWV2_DISABLED = "(отключено)",
    BWV2_EXCLUSIVE_ONE = "(эксклюзивно - требуется один)",
    BWV2_EXCLUSIVE_REQUIRES = "(эксклюзивно, требуется %s)",
    BWV2_FOOD_BUFF_DETECT = "Определяется по иконке баффа (все баффы еды)",
    BWV2_WEAPON_ENCHANT_DETECT = "Определяется через чары оружия",
    BWV2_INVENTORY_DESC = "Проверяет наличие этих предметов в сумках. Некоторые предметы проверяются только если в группе есть нужный класс.",
    BWV2_YOU = "(Вы)",
    BWV2_GROUPS_COUNT = "(%d групп)",
    BWV2_TAG_TARGETED = "[на цели]",
    BWV2_TAG_WEAPON = "[оружие]",
    BWV2_EXCLUSIVE = "(эксклюзивно)",
    BWV2_ADD_GROUP = "+ Добавить группу",
    BWV2_SECTION_THRESHOLDS = "ПОРОГИ ДЛИТЕЛЬНОСТИ",
    BWV2_THRESHOLD_DESC = "Минимальная оставшаяся длительность (мин.), чтобы бафф считался активным.",
    BWV2_DUNGEON = "Подземелье:",
    BWV2_RAID = "Рейд:",
    BWV2_OTHER = "Прочее:",
    BWV2_MIN = "мин.",
    BWV2_SECTION_RAID = "БАФФЫ РЕЙДА",
    BWV2_SECTION_CONSUMABLES = "РАСХОДНИКИ",
    BWV2_SECTION_INVENTORY = "ПРОВЕРКА ИНВЕНТАРЯ",
    BWV2_SECTION_CLASS = "КЛАССОВЫЕ БАФФЫ",
    BWV2_SECTION_REPORT_CARD = "ОТЧЁТ",
    -- Class Buff Modal
    BWV2_MODAL_EDIT_TITLE = "Редактировать группу баффов",
    BWV2_MODAL_ADD_TITLE = "Добавить группу баффов",
    BWV2_CLASS = "Класс:",
    BWV2_SELECT_CLASS = "Выберите класс",
    BWV2_GROUP_NAME = "Название группы:",
    BWV2_CHECK_TYPE = "Тип проверки:",
    BWV2_TYPE_SELF = "Собственный бафф",
    BWV2_TYPE_TARGETED = "Бафф на других (на цели)",
    BWV2_TYPE_WEAPON = "Чары оружия",
    BWV2_MIN_REQUIRED = "Минимум требуется:",
    BWV2_MIN_HINT = "(0 = все, 1+ = минимум)",
    BWV2_TALENT_CONDITION = "Условие таланта:",
    BWV2_SELECT_TALENT = "Выберите талант...",
    BWV2_FILTER_TALENTS = "Введите для фильтрации...",
    BWV2_MODE_ACTIVATE = "Активировать при наличии таланта",
    BWV2_MODE_SKIP = "Пропускать при наличии таланта",
    BWV2_SPECS = "Специализации:",
    BWV2_ALL_SPECS = "Все специализации",
    BWV2_DURATION_THRESHOLDS = "Пороги длительности:",
    BWV2_THRESHOLD_HINT = "(мин., 0=выкл.)",
    BWV2_SPELL_ENCHANT_IDS = "ID заклинаний/чар:",
    BWV2_ERR_SELECT_CLASS = "Пожалуйста, выберите класс",
    BWV2_ERR_NAME_REQUIRED = "Требуется название группы",
    BWV2_ERR_ID_REQUIRED = "Требуется хотя бы один ID заклинания/чар",
    BWV2_DELETE = "Удалить",
    BWV2_AUTO_USE_ITEM = "Автоиспользование предметов:",
    BWV2_REPORT_TITLE = "Отчёт баффов",
    BWV2_REPORT_NO_DATA = "Отчёт баффов (нет данных)",
    BWV2_NO_ID = "Нет ID",
    BWV2_NO_SPELL_ID_ADDED = "ID заклинания не добавлен",
    BWV2_CLASSIC_DISPLAY = "Классическое отображение",
	
	---------------------------------------------------------------------------
    -- CO-TANK FRAME
    ---------------------------------------------------------------------------
    SIDEBAR_TAB_COTANK = "Фрейм совместного танка",
    COTANK_TITLE = "СОВМЕСТНЫЙ ТАНК",
    COTANK_SUBTITLE = "Отображение здоровья второго танка в Вашем рейде",
    COTANK_ENABLE = "Включить фрейм совместного танка",
    COTANK_ENABLE_DESC = "Показывается только в рейдах, когда Вы танк и присутствует другой танк",
    COTANK_SECTION_HEALTH = "ПОЛОСА ЗДОРОВЬЯ",
    COTANK_HEALTH_COLOR = "Цвет здоровья",
    COTANK_USE_CLASS_COLOR = "Использовать цвет класса",
    COTANK_BG_OPACITY = "Прозрачность фона",
    COTANK_WIDTH = "Ширина",
    COTANK_HEIGHT = "Высота",
    
    -- Настройки имени
    COTANK_SECTION_NAME = "ИМЯ",
    COTANK_SHOW_NAME = "Показывать имя",
    COTANK_NAME_FORMAT = "Формат имени",
    COTANK_NAME_FULL = "Полное",
    COTANK_NAME_ABBREV = "Сокращённое",
    COTANK_NAME_LENGTH = "Длина имени",
    COTANK_NAME_FONT_SIZE = "Размер шрифта",
    COTANK_NAME_USE_CLASS_COLOR = "Использовать цвет класса",
    COTANK_NAME_COLOR = "Цвет имени",
    COTANK_PREVIEW_NAME = "ИмяТанка",
})
