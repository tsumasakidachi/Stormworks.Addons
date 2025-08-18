name = "TSU Mission Foundation for SCG"
version = "1.2.1"

-- properties
g_savedata = {
    mode = "prod",
    missions = {},
    objects = {},
    oil_spills = {},
    oil_spill_count = 0,
    disasters_gross = 0,
    players = {},
    players_map = {},
    locations = {},
    locations_history = {},
    zones = {},
    location_comparer = "pattern",
    subsystems = {
        mission = {
            timer_tickrate = 0,
            interval = 0,
            interval_min = property.slider("Minimum interval at which new missions occur (minutes)", 0, 30, 1, 10) * 3600,
            interval_max = property.slider("Maximum interval at which new missions occur (minutes)", 0, 60, 1, 20) * 3600,
            range_min = property.slider("Minimum range in which new missions occur (km)", 0, 10, 1, 1) * 1000,
            range_max = property.slider("Maximum range in which new missions occur (km)", 1, 100, 1, 6) * 1000,
            range_limited = true,
            count = 0,
            count_limited = true,
            player_factor = property.slider("Number of players required to complete per mission", 1, 32, 1, 3),
            taken_to_long_threshold = property.slider("The time it takes volunteers to locate rescuees (minutes)", 5, 90, 1, 15) * 3600,
            eot = "END OF TABLE"
        },
        rescuee = {
            dispensable = false,
            cpa_recurrence_rate = property.slider("CPA recurrence rate (%)", 0, 100, 1, 20),
            cpa_recurrence_threshold_players = property.slider("CPA recurrence occur when players are more than", 0, 32, 1, 8),
            has_strobe = property.checkbox("Rescuees has strobe", true),
            eot = "END OF TABLE"
        },
        fire = {
            dispensable = false,
            rate_explode = property.slider("Explosion rate per second due to spillage (%)", 0, 1, 0.1, 0.5),
            eot = "END OF TABLE"
        },
        forest_fire = {
            dispensable = false
        },
        suspect = {
            dispensable = false
        },
        spillage = {
            dispensable = false
        },
        wreckage = {
            dispensable = true
        },
        hostile = {
            dispensable = true
        },
        mapping = {
            mission = {},
            object = {},
            zone = {
                markar_id = 0
            }
        },
        eot = "END OF TABLE"
    },
    disabled_components = {},
    eot = "END OF TABLE"
}

location_properties = {{
    pattern = "^mission:climber_missing_%d+$",
    tracker = "sar",
    suitable_zones = {"forest", "mountain"},
    is_main_location = false,
    sub_locations = {"^mission:climber_missing_%d+$", "^mission:raft_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "行方不明者\n悪天候により登山客の集団遭難が発生した. このエリアを捜索し行方不明者を全員救出せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "警察署からの通報"
}, {
    pattern = "^mission:em_call_%d+$",
    tracker = "sar",
    suitable_zones = {"house"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 250,
    report = "緊急搬送\nタス...ケ......タ......",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "民間人からの通報"
}, {
    pattern = "^mission:passenger_fallen_land_%d+$",
    tracker = "sar",
    suitable_zones = {"field", "mountain", "forest"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "落水者",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:passenger_fallen_water_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel", "shallow"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "落水者",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:lifeboat_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel", "shallow"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "救命ボート",
    report_timer = 0,
    note = ""
}, {
    pattern = "^mission:raft_%d+$",
    tracker = "sar",
    suitable_zones = {"lake", "beach"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "水難事故\nいかだを作ってあそんでいたら転覆した!",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "民間人からの通報"
}, {
    pattern = "^mission:freighter_fire_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "メーデー\n船内で突然何かが爆発した! もう助からないぞ!",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗員からの通報"
}, {
    pattern = "^mission:ferry_fire_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "メーデー\n本船客室より出火し, 船全体に火の手が回りつつあり非常に危険な状況である. 迅速な救援を求む.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗員からの通報"
}, {
    pattern = "^mission:tanker_fire_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "メーデー\n積荷の石油に火がアアア......",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗員からの通報"
}, {
    pattern = "^mission:boat_sink_%d+$",
    tracker = "sar",
    suitable_zones = {"lake", "channel"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "水難事故\nボートが壊れて沈没しそう!",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:overboard_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel", "beach"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$"},
    sub_location_min = 1,
    sub_location_max = 1,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "水難事故\n船から人が落ちた!",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "職員からの通報"
}, {
    pattern = "^mission:ferry_sink_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 2000,
    report = "メーデー\n本船は何らかの物体と接触, 浸水し沈没しかかっている. 乗員乗客はほとんど脱出に成功したが漂流している. 至急救援を求む.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗員からの通報"
}, {
    pattern = "^mission:fishboat_fire_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "メーデー\n漁船のエンジンが爆発し炎上中! どうやら浸水も起きているようだ. 終わった.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗員からの通報"
}, {
    pattern = "^mission:heli_crash_wind_turbine_%d+$",
    tracker = "sar",
    suitable_zones = {"wind_turbine"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "メーデー\nヘリコプターが風力発電機と接触し墜落した. 激しく炎上しており周囲の森林に延焼する可能性がある, 至急救援求む.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 100,
    rescuee_max = 100,
    note = "乗員からの通報"
}, {
    pattern = "^mission:diver_yacht_%d+$",
    tracker = "sar",
    suitable_zones = {"diving_spot"},
    is_main_location = true,
    sub_locations = {"^mission:diver_missing_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "行方不明者\nダイビング中に事故が発生した模様で戻ってこない人がいる. もう1時間以上経っているので捜索してほしい.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "民間人からの通報"
}, {
    pattern = "^mission:diver_missing_%d+$",
    tracker = "sar",
    suitable_zones = {"underwater"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "行方不明のダイバー",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:oil_platform_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 1,
    sub_location_max = 5,
    is_unique_sub_location = false,
    search_radius = 2000,
    report = "火災\n操業中の事故により海上油田で爆発が発生. 油井が激しく炎上し, もう我々の手には負えない. 我々は脱出を開始しているが救命艇が足りず, 身一つで海へ飛び込んだ者もいる. 早急な救出が必要だ.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    fire_min = 50,
    fire_max = 100,
    note = "職員からの通報"
}, {
    pattern = "^mission:tunnel_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {"^mission:car_collision_%d+$", "^mission:car_stuck_%d+$"},
    sub_location_min = 3,
    sub_location_max = 5,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "火災\nトンネルの中が全部燃えていてこのままでは全員焼け死んでしまう!",
    report_timer_min = 0,
    report_timer_max = 0,
    fire_min = 50,
    fire_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:car_collision_%d+$",
    tracker = "sar",
    suitable_zones = {"road", "tunnel"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = true,
    search_radius = 200,
    report = "交通事故\n自動車が正面衝突しけが人がいる.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "民間人からの通報"
}, {
    pattern = "^mission:car_stuck_%d+$",
    tracker = "sar",
    suitable_zones = {"road", "tunnel"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 200,
    report = "スタックした自動車",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:aircraft_down_%d+$",
    tracker = "sar",
    suitable_zones = {"field", "mountain"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_land_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = true,
    search_radius = 1000,
    report = "メーデー\nバラバラになって落ちていく飛行機が見えた!",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "民間人からの通報"
}, {
    pattern = "^mission:marina_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "火災\nマリーナに係留されているボートから出火して周りの船にも燃え移っている.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "民間人からの通報"
}, {
    pattern = "^mission:campsite_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "火災\nキャンプ場で火事, 森林火災に発展する可能性が高い. 早急な対応を頼む.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "キャンプ場からの通報"
}, {
    pattern = "^mission:hostile_forest_%d+$",
    tracker = "sar",
    suitable_zones = {"forest", "field", "mountain", "hill"},
    is_main_location = true,
    sub_locations = {"^mission:climber_missing_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 250,
    report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を駆除せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "パトロールからの通報"
}, {
    pattern = "^mission:wind_turbine_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "火災\n洋上風力発電機のエレベーターが故障, 落下し火災が発生. タービン室から降りられず閉じこめられている.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "パトロールからの通報"
    -- }, {
    --     pattern = "^mission:hostile_offshore_%d+$",
    --     tracker = "sar",
    --     suitable_zones = {"offshore", "underwater", "diving_spot"},
    --     is_main_location = true,
    --     sub_locations = {},
    --     sub_location_min = 1,
    --     sub_location_max = 1,
    --     is_unique_sub_location = false,
    --     search_radius = 250,
    --     --     report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を駆除せよ.",
    --     report_timer_min = 0,
    --     report_timer_max = 0,
    --     note = "パトロールからの通報"
}, {
    pattern = "^mission:hostile_water_%d+$",
    tracker = "sar",
    suitable_zones = {"lake", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:boat_sink_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 250,
    report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を駆除せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "パトロールからの通報"
}, {
    pattern = "^mission:naval_mine_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel", "diving_spot"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 500,
    report = "落下物\n付近を航行する船舶から漂流する機雷を発見したとの通報があった. このエリアで機雷を捜索し, 破壊 (報酬なし) またはスクラップヤードへ輸送 (報酬あり) せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "パトロールからの通報"
}, {
    pattern = "^mission:train_crash_head_on$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "鉄道事故\n旅客列車が正面衝突し脱線転覆, 多数の負傷者が発生!",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "運転士からの通報"
}, {
    pattern = "^mission:train_crash_log_trailer$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "鉄道事故\n旅客列車がトレーラーと衝突し脱線, 負傷者多数. また積荷の丸太が線路に散乱し, 運行不能に陥っている.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "運転士からの通報"
}, {
    pattern = "^mission:power_plant_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "火災\n発電所のタービンが発火, 天井にまで燃え広がっている. 数名の職員と連絡がつかず中に取り残されているものと思われる.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "職員からの通報"
}, {
    pattern = "^mission:chemical_storage_fire_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "火災\n化学物質が保管されている倉庫が炎上している. 不意の爆発に注意せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "職員からの通報"
}, {
    pattern = "^mission:highway_car_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "交通事故\n高速道路で乗用車が衝突し横転, 本線を塞いでいる.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 100,
    rescuee_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:highway_oil_tanker_%d+$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "交通事故\n高速道路でタンクローリーが横転, 炎上中. 運転手は無事だがインターチェンジを完全に塞いでいる.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 100,
    rescuee_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:air_medevac_%d+$",
    tracker = "sar",
    suitable_zones = {"airfield", "heliport"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 100,
    report = "救急搬送\n近隣で発生した救急患者をこの空港に搬送する. 引き継いで病院へ後送せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "職員からの通報"
}, {
    pattern = "^mission:pirate_boat_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "shallow", "channel"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 50,
    report = "海賊",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "哨戒機からの通報"
}, {
    pattern = "^mission:tornado_alert_%d+$",
    tracker = "disaster",
    suitable_zones = {"channel", "late", "ait", "forest", "field", "beach"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "竜巻警報\nこのエリアで竜巻が発生する可能性が高まっている...",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "気象当局からの通報"
}, {
    pattern = "^mission:whirlpool_alert_%d+$",
    tracker = "disaster",
    suitable_zones = {"offshore"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "大渦警報\nこのエリアで大渦が発生する可能性が高まっている...",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "気象当局からの通報"
}, {
    pattern = "^mission:meteor_alert_%d+$",
    tracker = "disaster",
    suitable_zones = {"offshore"},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 1000,
    report = "隕石警報\nこのエリアに隕石の落下が予測されている...",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "気象当局からの通報"
}}

zone_properties = {{
    landscape = "base",
    mapped = true,
    icon = 11
}, {
    landscape = "hospital",
    mapped = true,
    icon = 8
}, {
    landscape = "clinic",
    mapped = true,
    icon = 8
}, {
    landscape = "police_station",
    mapped = true,
    icon = 11
}, {
    landscape = "scrap_yard",
    mapped = true,
    icon = 3
}, {
    landscape = "forest"
}, {
    landscape = "hill"
}, {
    landscape = "mountain"
}, {
    landscape = "volcano"
}, {
    landscape = "field"
}, {
    landscape = "beach"
}, {
    landscape = "ait"
}, {
    landscape = "island"
}, {
    landscape = "campsite"
}, {
    landscape = "offshore"
}, {
    landscape = "shallow"
}, {
    landscape = "underwater"
}, {
    landscape = "channel"
}, {
    landscape = "lake"
}, {
    landscape = "diving_spot"
}, {
    landscape = "airfield"
}, {
    landscape = "heliport"
}, {
    landscape = "runway"
}, {
    landscape = "road"
}, {
    landscape = "track"
}, {
    landscape = "crossing"
}, {
    landscape = "tunnel"
}, {
    landscape = "bridge"
}, {
    landscape = "house"
}, {
    landscape = "building"
}, {
    landscape = "wind_turbine"
}, {
    landscape = "plant"
}, {
    landscape = "mine"
}, {
    landscape = "first_spawn"
}, {
    landscape = "respawn"
}}

strings = {
    statuses = {
        essentials = "必須の目標",
        dispensables = "オプションの目標"
    },
    events = {
        chemical = "chemical spills",
        oil = "oil spills",
        gas = "gas spills",
        dust = "dust spills",
        radioactive = "radioactive spills",
        whirlpool = "whirlpool",
        tornado = "tornado",
        tsunami = "tsunami",
        eruption = "eruption",
        meteor = "meteor"
    },
    disasters = {
        massive_meteor_impact = "津波警報. 津波警報. 巨大隕石の落下により津波の発生が確実視されている. 早急に高台へ避難せよ."
    }
}

mission_trackers = {
    sar = {
        init = function(self)
        end,
        clear = function(self)
        end,
        tick = function(self, tick)
        end,
        complete = function(self)
            local completed = self.spawned

            for i = 1, #g_savedata.objects do
                if g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker ~= nil then
                    completed = completed and (g_savedata.objects[i]:dispensable() or g_savedata.objects[i]:complete())
                end
            end

            return completed
        end,
        reward = function(self)
            local reward = self.rewards

            for k, object in pairs(g_savedata.objects) do
                if object.mission == self.id and object.tracker ~= nil and object:complete() then
                    reward = reward + object:reward()
                end
            end

            if reward > 0 then
                local distance = matrix.distance(self.start_position, self.locations[1].transform)
                reward = reward + math.floor(distance / 1000) * 2000 * 2
            end

            return reward
        end,
        report = function(self)
            return string.format("#%d %s", self.id, self.locations[1].report)
        end,
        status = function(self)
            local text = self.locations[1].note

            text = text .. "\n\n[目標]"

            for tracker, data in pairs(self.objectives) do
                if data.count > 0 then
                    text = text .. string.format("\n%.0f %s", data.count, object_trackers[tracker].text)

                    if data.count_picked > 0 then
                        text = text .. string.format("\n(%.0f %s)", data.count_picked, "収容済み")
                    end

                    if #data.contents > 0 then
                        text = text .. "\n("

                        for i = 1, #data.contents do
                            if i > 1 then
                                text = text .. ", "
                            end

                            text = text .. data.contents[i]
                        end

                        text = text .. ")"
                    end
                end
            end

            if #self.events > 0 then
                text = text .. "\n\n[事象]"
                text = text .. "\n"

                for i = 1, #self.events do
                    if i > 1 then
                        text = text .. ", "
                    end

                    text = text .. strings.events[self.events[i]]
                end
            end

            text = text .. "\n\n[捜索半径]"
            text = text .. string.format("\n%dm", self.search_radius)

            text = text .. "\n\n[出動区分]"
            text = text .. "\nカテゴリ:"

            if self.category ~= nil then
                text = text .. string.format(" %d", self.category)
            else
                text = text .. " 不明"
            end

            text = text .. "\nユニット: "

            for name, available in pairs(self.units) do
                if available then
                    text = text .. " " .. string.upper(name)
                end
            end

            return text
        end
    },
    disaster = {
        init = function(self)
            local type = string.match(self.locations[1].name, "^mission:(%w+)_alert_%d+$")
            self.type = type
            self.started = false
            self.start_timer = math.random(14400, 28800)

            if self.type == "tornado" or self.type == "whirlpool" then
                self.finish_timer = self.start_timer + 21600
            elseif self.type == "meteor" then
                self.finish_timer = self.start_timer + 3600
            else
                self.finish_timer = 0
            end
        end,
        clear = function(self)
        end,
        tick = function(self, tick)
            self.start_timer = math.max(self.start_timer - tick, 0)
            self.finish_timer = math.max(self.finish_timer - tick, 0)

            if not self.started and self.start_timer <= 0 then
                if self.type == "tornado" then
                    server.spawnTornado(self.start_position)
                    console.notify(string.format("Tornado has occurred."))
                elseif self.type == "whirlpool" then
                    local magnitude = math.max(math.random() ^ 2, 0.5)
                    local s = server.spawnWhirlpool(self.start_position, magnitude)

                    if s then
                        console.notify(string.format("Whirlpool of magnitude %.3f has occurred.", magnitude))
                    else
                        console.notify("Failed to spawn whirlpool")
                    end
                elseif self.type == "meteor" then
                    local magnitude = math.random() ^ 2
                    local tsunami = magnitude > 0.75

                    if tsunami then
                        self.finish_timer = 28800
                        self.search_radius = 7500
                        self.locations[1].report = strings.disasters.massive_meteor_impact
                    end

                    server.spawnMeteor(self.start_position, magnitude, tsunami)
                    console.notify(string.format("Meteor of magnitude %.3f has occurred.", magnitude))
                end

                self.started = true
            end
        end,
        complete = function(self)
            return self.finish_timer <= 0
        end,
        reward = function(self)
            return 0
        end,
        report = function(self)
            return string.format("#%d %s", self.id, self.locations[1].report)
        end,
        status = function(self)
            local text = self.locations[1].note
            text = text .. string.format("\n\n[半径]\n%dm", self.search_radius)

            return text
        end
    }
}

object_trackers = {
    rescuee = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "character" and tags.tracker ~= nil and tags.tracker == "rescuee"
        end,
        init = function(self)
            local hp_min = -20
            local hp_max = 100

            self.vital = server.getCharacterData(self.id)
            self.vital.hp = tonumber(self.tags.hp) or math.max(0, math.random(0, hp_max - hp_min) + hp_min)

            if self.vital.incapacitated then
                self.cpa_count = 1
            else
                self.cpa_count = 0
            end

            self.is_cpa_recurrent = false
            self.strobe = {
                opt = false,
                ir = false
            }
            self.admitted_time = 0
            self.activated = false
            self.picked = false

            server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, self.vital.ai)
            server.setCharacterTooltip(self.id, string.format("%s\n\nMission ID: %d\nObject ID: %d", self.text, self.mission, self.id))
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            local character_vehicle = server.getCharacterVehicle(self.id)
            local picked = table.any(g_savedata.objects, function(x)
                return character_vehicle > 0 and x.tracker == "unit" and x.id == character_vehicle
            end)
            local vital_update = server.getCharacterData(self.id)
            local is_in_hospital = zones:is_in_landscape(self.transform, "hospital")
            local is_in_clinic = zones:is_in_landscape(self.transform, "clinic")
            local is_in_base = zones:is_in_landscape(self.transform, "base")
            local activated = self.activated or players:is_in_range(self.transform, 500)
            local is_doctor_nearby = is_doctor_nearby(self.transform)
            local is_safe = is_in_hospital or is_doctor_nearby

            if #players.items >= g_savedata.subsystems.rescuee.cpa_recurrence_threshold_players and g_savedata.subsystems.rescuee.cpa_recurrence_rate > 0 and not is_safe then
                if not self.vital.incapacitated and vital_update.incapacitated then
                    self.is_cpa_recurrent = self.is_cpa_recurrent or math.random(0, 99) < g_savedata.subsystems.rescuee.cpa_recurrence_rate

                    if self.is_cpa_recurrent then
                        self.cpa_count = self.cpa_count + 1
                    end
                end

                vital_update.hp = math.max(vital_update.hp - (self.cpa_count / 2), 0)
            end

            if g_savedata.subsystems.rescuee.has_strobe then
                local opt = (self.strobe.opt or players:is_in_range(self.transform, 250)) and not picked
                local ir = (self.strobe.ir or players:is_in_range(self.transform, 500)) and not picked
                local dead = not self.vital.dead and vital_update.dead

                if opt ~= self.strobe.opt or dead then
                    server.setCharacterItem(self.id, 2, 23, opt, 0, 100)
                end

                if ir ~= self.strobe.ir or dead then
                    server.setCharacterItem(self.id, 3, 24, ir, 0, 100)
                end

                self.strobe.opt = opt
                self.strobe.ir = ir
            end

            -- if not self.activated and activated then
            --     console.notify(string.format("Objective#%d activated.", self.id))
            -- end

            self.picked = picked
            self.vital = vital_update
            self.activated = activated

            if is_in_hospital or not self.is_cpa_recurrent and (is_in_base or is_in_clinic) then
                self.admitted_time = self.admitted_time + tick
            end

            server.setCharacterData(self.id, self.vital.hp, not self.completed and activated, self.vital.ai)
        end,
        dispensable = function(self)
            return g_savedata.subsystems.rescuee.dispensable
        end,
        complete = function(self)
            return self.admitted_time > 120
        end,
        reward = function(self)
            local value = math.ceil(self.reward_base * (math.floor(self.vital.hp / 25) / 4))

            if self.cpa_count >= 2 then
                value = value - self.cpa_count * 500
            end

            return value
        end,
        label = function(self)
            -- return string.format("%s\n\nHP: %.00f/100\n心肺停止回数: %.00f回", self.text, self.vital.hp, self.cpa_count)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            local mission = table.find(g_savedata.missions, function(x) return x.id == self.mission end)
            return mission.taken_to_long
        end,
        reward_base = 1000,
        text = "要救助者を医療機関へ搬送",
        marker_type = 1,
        clear_timer = 300
    },
    fire = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "fire"
        end,
        init = function(self)
            self.is_lit = server.getFireData(self.id)
            self.is_explosive = false
            self.cooling_timer = math.random(1800, 7200)
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            self.is_lit = server.getFireData(self.id)

            if not self.is_lit then
                self.cooling_timer = math.max(self.cooling_timer - tick, 0)
            end

            local is_explosive = false

            for i = 1, #g_savedata.missions do
                is_explosive = is_explosive or g_savedata.missions[i].id == self.mission and has_explosive_event(g_savedata.missions[i]) and math.random() < g_savedata.subsystems.fire.rate_explode * 0.001
            end

            if is_explosive and not self.is_explosive then
                self.is_explosive = is_explosive
                server.setFireData(self.id, true, false)
                server.spawnExplosion(self.transform, math.random() ^ 2)
                console.notify(string.format("Fire#%d exploded.", self.id))
            end
        end,
        dispensable = function(self)
            return g_savedata.subsystems.fire.dispensable
        end,
        complete = function(self)
            return self.cooling_timer <= 0
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 100,
        text = "炎を鎮火",
        marker_type = 5,
        clear_timer = 0
    },
    forest_fire = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "forest_fire"
        end,
        init = function(self, transform)
            self.transform = transform
            self.is_lit = true
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
        end,
        dispensable = function(self)
            return g_savedata.subsystems.forest_fire.dispensable
        end,
        complete = function(self)
            return not self.is_lit
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 2000,
        text = "森林火災を鎮火",
        marker_type = 5,
        clear_timer = 0
    },
    suspect = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "character" and tags.tracker ~= nil and tags.tracker == "suspect"
        end,
        init = function(self)
            self.vital = server.getCharacterData(self.id)
            self.path = {}
            self.admitted_time = 0

            server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, self.ai ~= nil)
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            local vital_update = server.getCharacterData(self.id)
            local vehicle_id = server.getCharacterVehicle(self.id)
            local is_in_police_sta = zones:is_in_landscape(self.transform, "police_station")
            local is_in_base = zones:is_in_landscape(self.transform, "base")

            if is_in_base or is_in_police_sta then
                self.admitted_time = self.admitted_time + tick
            end

            if self.ai ~= nil then
                local command = nil

                for i = 1, #g_savedata.objects do
                    if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
                        command = g_savedata.objects[i].command
                    end
                end

                if command == "escape" then
                    if self.ai == "pilot" then
                        if #self.path > 0 then
                            if matrix.distance(self.transform, self.path[1]) <= 100 then
                                table.remove(self.path, 1)
                                self.targeted = false
                            end

                            if not self.targeted then
                                server.setAITarget(self.id, self.path[1])
                                server.setAIState(self.id, 1)
                                self.targeted = true

                                local x, y, z = matrix.position(self.path[1])

                                console.notify(string.format("%s#%d destination to %.0f, %.0f, %.0f", self.tracker, self.id, x, y, z))
                            end
                        else
                            local distance = math.random(5000, 10000)
                            local heading = math.random() * 2
                            local x = distance * math.cos(heading * math.pi)
                            local z = distance * math.sin(heading * math.pi)
                            local destination = matrix.multiply(self.transform, matrix.translation(x, 0, z))
                            local path = server.pathfind(self.transform, destination, "ocean_path", "")
                            self.path = {}

                            for i = 1, #path do
                                table.insert(self.path, matrix.translation(path[i].x, 0, path[i].z))
                            end
                        end
                    end
                elseif command == nil then
                    server.setAIState(self.id, 0)
                end
            end

            self.vital = vital_update
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return self.admitted_time > 120
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 100,
        text = "被疑者を制圧して基地へ連行",
        marker_type = 1,
        clear_timer = 300
    },
    oil_spill = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "oil_spill"
        end,
        init = function(self, transform, tile_x, tile_y, amount)
            self.transform = transform
            self.tile_x = tile_x
            self.tile_y = tile_y
            self.complete_threshold = math.max(amount * 0.2, 0)
            self.amount = amount
        end,
        clear = function(self)
            if g_savedata.oil_spills[self.tile_x] ~= nil then
                g_savedata.oil_spills[self.tile_x][self.tile_y] = nil
                server.setOilSpill(self.transform, 0)
            end
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            if g_savedata.oil_spills[self.tile_x] ~= nil and g_savedata.oil_spills[self.tile_x][self.tile_y] ~= nil then
                self.amount = g_savedata.oil_spills[self.tile_x][self.tile_y]
            else
                self.amount = 0
            end
        end,
        dispensable = function(self)
            return g_savedata.subsystems.spillage.dispensable
        end,
        complete = function(self)
            return self.amount <= self.complete_threshold
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return string.format("%s\n\n%.0f", self.text, self.amount)
        end,
        count = function(self)
            return self.amount
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 0,
        text = "漏出した油を回収",
        marker_type = 2,
        clear_timer = 0
    },
    wreckage = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "vehicle" and tags.tracker ~= nil and tags.tracker == "wreckage"
        end,
        init = function(self)
            self.components_checked = false
            self.completion_timer = 0
            self.initial_transform = server.getVehiclePos(self.id)
            self.mass = 0

            if self.tags.indispensable == "true" then
                self.indispensable = true
            else
                self.indispensable = false
            end

            server.setVehicleTooltip(self.id, string.format("%s\n\nMission ID: %d\nVehicle ID: %d", self.text, self.mission, self.id))
        end,
        clear = function(self)
        end,
        load = function(self)
            if not self.components_checked then
                local d, s = server.getVehicleComponents(self.id)
                self.mass = d.mass

                for i = 1, #d.components.signs do
                    local tags = string.parse_tags(d.components.signs[i].name)

                    if tags.damage ~= nil and tags.radius ~= nil then
                        local damage = tonumber(tags.damage)
                        local radius = tonumber(tags.radius)
                        server.addDamage(self.id, damage, d.components.signs[i].pos.x, d.components.signs[i].pos.y, d.components.signs[i].pos.z, radius)
                    end
                end

                self.components_checked = true
            end
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            if zones:is_in_landscape(self.transform, "scrap_yard") then
                self.completion_timer = self.completion_timer + tick
            end
        end,
        dispensable = function(self)
            return not self.indispensable and not players:is_in_range(self.transform, 500)
        end,
        complete = function(self)
            return self.completion_timer >= 300
        end,
        reward = function(self)
            return math.ceil(self.mass * self.reward_base / 100) * 100
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 2,
        text = "残骸をスクラップヤードへ輸送",
        marker_type = 2,
        clear_timer = 3600
    },
    hostile = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return (type == "creature" or type == "animal") and tags.tracker ~= nil and tags.tracker == "hostile"
        end,
        init = function(self)
            local mission = table.find(g_savedata.missions, function(x)
                return x.id == self.mission
            end)
            self.target = table.random(table.find_all(mission.locations, function(x)
                local d = matrix.distance(x.transform, self.transform)
                return d >= 10 and d < 500
            end))
            self.vital = server.getCharacterData(self.id)

            if self.tags.indispensable ~= nil and self.tags.indispensable == "true" then
                self.indispensable = true
            else
                self.indispensable = false
            end

            server.setCreatureTooltip(self.id, string.format("%s\n\nMission ID: %d\nObject ID: %d", self.text, self.mission, self.id))
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            if self.loaded and self.target ~= nil then
                local x, y, z = matrix.position(self.target.transform)
                local s = server.setCreatureMoveTarget(self.id, self.target.transform)

                if s then
                    self.target = nil
                end
            end

            self.vital = server.getCharacterData(self.id)
        end,
        dispensable = function(self)
            return g_savedata.subsystems.hostile.dispensable and not self.indispensable
        end,
        complete = function(self)
            return self.vital.incapacitated or self.vital.dead
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 500,
        text = "危険生物を駆除",
        marker_type = 6,
        clear_timer = 300
    },
    sniffer = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "creature" and tags.tracker ~= nil and tags.tracker == "sniffer"
        end,
        init = function(self)
            server.setCreatureTooltip(self.id, string.format("%s\n\nObject ID: %d", self.text, self.id))
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return false
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 0,
        text = "捜査犬",
        marker_type = 9,
        clear_timer = 0
    },
    headquarter = {
        test_type = function(self, id, type, tags, component_id, mission_id)
            return type == "vehicle" and tags.tracker ~= nil and tags.tracker == "headquarter"
        end,
        init = function(self)
            self.components_checked = false
            self.alert = nil
            self.em_beacon = nil
            self.missions = {}
        end,
        clear = function(self)
        end,
        load = function(self)
            if not self.components_checked then
                local d, s = server.getVehicleComponents(self.id)

                if not s then
                    return
                end

                self.alert = table.find(d.components.buttons, function(t)
                    return string.lower(t.name) == "alert"
                end)

                for i = 1, 6 do
                    self.missions[i] = {}
                    self.missions[i].id = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_id", i)
                    end)
                    self.missions[i].x = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_x", i)
                    end)
                    self.missions[i].y = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_y", i)
                    end)
                    self.missions[i].r = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_r", i)
                    end)
                    self.missions[i].category = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_category", i)
                    end)
                    self.missions[i].rescuees = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_rescuees", i)
                    end)
                    self.missions[i].fires = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_fires", i)
                    end)
                    self.missions[i].suspects = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_suspects", i)
                    end)
                    self.missions[i].wreckages = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_wreckages", i)
                    end)
                    self.missions[i].hostiles = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_hostiles", i)
                    end)
                    self.missions[i].sar = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_sar", i)
                    end)
                    self.missions[i].med = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_med", i)
                    end)
                    self.missions[i].fire = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_fire", i)
                    end)
                    self.missions[i].spc = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_spc", i)
                    end)
                end

                self.components_checked = true
            end
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            -- if self.components_checked then
            --     for index = 1, math.max(#g_savedata.missions, 6) do
            --         if g_savedata.missions[index] ~= nil then
            --             local x, y, z = matrix.position(g_savedata.missions[index].locations[1].transform)

            --             if self.missions[index].id ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].id, g_savedata.missions[index].id)
            --             end

            --             if self.missions[index].x ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].x, x)
            --             end

            --             if self.missions[index].y ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].y, z)
            --             end

            --             if self.missions[index].r ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].r, g_savedata.missions[index].search_radius)
            --             end

            --             if self.missions[index].category ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].category, g_savedata.missions[index].category)
            --             end

            --             if self.missions[index].rescuees ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].rescuees, g_savedata.missions[index].objectives.rescuees)
            --             end

            --             if self.missions[index].fires ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].fires, g_savedata.missions[index].objectives.fires)
            --             end

            --             if self.missions[index].suspects ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].suspects, g_savedata.missions[index].objectives.suspects)
            --             end

            --             if self.missions[index].wreckages ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].wreckages, g_savedata.missions[index].objectives.wreckages)
            --             end

            --             if self.missions[index].hostiles ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].hostiles, g_savedata.missions[index].objectives.hostiles)
            --             end

            --             if self.missions[index].sar ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].sar, g_savedata.missions[index].units.sar)
            --             end

            --             if self.missions[index].med ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].med, g_savedata.missions[index].units.med)
            --             end

            --             if self.missions[index].fire ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].fire, g_savedata.missions[index].units.fire)
            --             end

            --             if self.missions[index].spc ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].spc, g_savedata.missions[index].units.spc)
            --             end
            --         else
            --             if self.missions[index].id ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].id, 0)
            --             end

            --             if self.missions[index].x ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].x, 0)
            --             end

            --             if self.missions[index].y ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].y, 0)
            --             end

            --             if self.missions[index].r ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].r, 0)
            --             end

            --             if self.missions[index].category ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].category, 0)
            --             end

            --             if self.missions[index].rescuees ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].rescuees, 0)
            --             end

            --             if self.missions[index].fires ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].fires, 0)
            --             end

            --             if self.missions[index].suspects ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].suspects, 0)
            --             end

            --             if self.missions[index].wreckages ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].wreckages, 0)
            --             end

            --             if self.missions[index].hostiles ~= nil then
            --                 set_vehicle_keypad(self.id, self.missions[index].hostiles, 0)
            --             end

            --             if self.missions[index].sar ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].sar, false)
            --             end

            --             if self.missions[index].med ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].med, false)
            --             end

            --             if self.missions[index].fire ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].fire, false)
            --             end

            --             if self.missions[index].spc ~= nil then
            --                 set_vehicle_button(self.id, self.missions[index].spc, false)
            --             end
            --         end
            --     end
            -- end
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return false
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 0,
        text = "",
        marker_type = 11,
        clear_timer = 0
    },
    unit = {
        test_type = function(self, id, type, tags, component_id, mission_id, owner, cost)
            return type == "vehicle" and owner ~= nil and cost ~= nil
        end,
        init = function(self, owner, cost)
            self.components_checked = false
            self.owner_steam_id = owner
            self.cost = cost
            self.mass = 0
        end,
        clear = function(self)
        end,
        load = function(self)
            if not self.components_checked then
                local d, s = server.getVehicleComponents(self.id)
                self.mass = d.mass
                self.components_checked = true
            end
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return false
        end,
        reward = function(self)
            return self.reward_base
        end,
        label = function(self)
            return self.text
        end,
        count = function(self)
            return 1
        end,
        reported = function(self)
            return true
        end,
        mapped = function(self)
            return false
        end,
        reward_base = 0,
        text = "",
        marker_type = 12,
        clear_timer = 0
    }
}

-- main logics
-- missions

function random_mission(center, range_max, range_min, is_unprecedented, pattern)
    if is_unprecedented == nil then
        is_unprecedented = true
    end

    local patterns = {}

    if pattern ~= nil then
        patterns[1] = pattern
    end

    local _locations = locations:random(center, range_min, range_max, true, is_unprecedented, patterns)

    if #_locations == 0 then
        return
    end

    initialize_mission(_locations)
end

function initialize_mission(_locations, report_timer, ...)
    local mission = {}
    mission.cleared = false
    mission.id = g_savedata.subsystems.mission.count + 1

    console.notify(string.format("Initializing mission #%d.", mission.id))

    mission.locations = _locations
    mission.start_position = mission.locations[1].transform
    mission.tracker = mission.locations[1].tracker
    mission.search_center = mission.locations[1].transform
    mission.search_radius = mission.locations[1].search_radius
    mission.category = 0
    mission.reported = false
    mission.report_timer = report_timer or math.random(mission.locations[1].report_timer_min, mission.locations[1].report_timer_max)
    mission.spawned = false
    mission.terminated = false
    mission.elapsed = 0
    mission.launched = false
    mission.taken_to_long = false
    mission.marker_id = server.getMapID()
    mission.rewards = 0
    based(mission, mission_trackers[mission.tracker])
    mission.objectives = aggregate_mission_objectives(mission)
    mission.landscapes = aggregate_mission_landscapes(mission)
    mission.events = aggregate_mission_events(mission)
    mission.category = aggregate_mission_category(mission)
    mission.units = aggregate_mission_units(mission)
    mission:init({...})

    record_location_history(mission.locations[1])
    table.insert(g_savedata.missions, mission)
    spawn_mission(mission)
    g_savedata.subsystems.mission.count = g_savedata.subsystems.mission.count + 1
end

function clear_mission(mission)
    console.notify(string.format("Clearing mission #%d.", mission.id))

    for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].mission == mission.id then
            despawn_object(g_savedata.objects[i])
        end
    end

    server.removeMapID(-1, mission.marker_id)
    mission:clear()
    mission.cleared = true

    server.notify(-1, string.format("Cleared mission #%d.", mission.id), mission:report(), 4)
end

function tick_mission(mission, tick)
    if not mission.launched and players:is_in_range(mission.search_center, mission.search_radius) then
        mission.launched = true
    end

    if mission.launched then
        mission.elapsed = mission.elapsed + tick
    end

    if not mission.taken_to_long and mission.elapsed > g_savedata.subsystems.mission.taken_to_long_threshold then
        mission.taken_to_long = true
        server.notify(-1, string.format("ミッション#%dの要救助を発見した.", mission.id), "ボランティアの捜索者からの通報", 0)
    end
    
    mission.objectives = aggregate_mission_objectives(mission)
    mission.landscapes = aggregate_mission_landscapes(mission)
    mission.events = aggregate_mission_events(mission)
    mission.category = aggregate_mission_category(mission)
    mission.units = aggregate_mission_units(mission)

    mission:tick(tick)

    if g_savedata.mode == "debug" or mission.search_center ~= nil then
        local label = mission:report()
        local label_hover = mission:status()
        local x, y, z = matrix.position(mission.search_center)
        local red = {255, 0, 255, 255}
        local yellow = {255, 255, 0, 255}
        local color = red

        if mission.category >= 2 then
            color = yellow
        end

        for i = 1, #players.items do
            if players.items[i].map_opened then
                server.removeMapID(players.items[i].id, mission.marker_id)
                server.addMapObject(players.items[i].id, mission.marker_id, 0, 1, x, z, 0, 0, nil, nil, label, mission.search_radius, label_hover, color[1], color[2], color[3], color[4])
            end
        end
    end

    -- mission.report_timer = math.max(mission.report_timer - tick, 0)

    if not mission.reported and mission.report_timer == 0 then
        alert_headquarter()

        local notification_type = 0

        if mission.category >= 2 then
            notification_type = 1
        end

        server.notify(-1, mission:report(), mission.locations[1].note, notification_type)
        mission.reported = true
    end

    if mission:complete() or mission.terminated then
        reward_mission(mission)
        clear_mission(mission)
    end
end

function spawn_mission(mission)
    local cl = #mission.locations

    for i = 1, cl do
        spawn_location(mission.locations[i], mission.id)
    end

    local co, x, y, z = 0, 0, 0, 0

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].transform ~= nil then
            local ox, oy, oz = matrix.position(g_savedata.objects[i].transform)
            co = co + 1
            x = x + ox
            y = y + oy
            z = z + oz
        end
    end

    if co >= 2 then
        x = x / co
        y = y / co
        z = z / co

        mission.search_center = matrix.translation(x, y, z)
    end

    if cl == 1 then
        local r = math.random() * 0.75 * mission.search_radius
        local t = math.random() * 2 * math.pi

        x = r * math.cos(t)
        z = r * math.sin(t)

        mission.search_center = matrix.multiply(mission.search_center, matrix.translation(x, y, z))
    end

    local sub_location_count = math.random(mission.locations[1].sub_location_min, mission.locations[1].sub_location_max)

    for i = 1, sub_location_count do
        local sub_locations = locations:random(mission.search_center, 0, mission.search_radius, false, false, mission.locations[1].sub_locations, {}, mission.locations)

        for j = 1, #sub_locations do
            spawn_location(sub_locations[j], mission.id)
            table.insert(mission.locations, sub_locations[j])
        end
    end

    mission.spawned = true

    console.notify(string.format("Spawned mission #%d.", mission.id))
end

function reward_mission(mission)
    local reward = mission:reward()

    transact(reward, string.format("Cleared mission #%d.", mission.id))
end

function terminate_mission(mission)
    mission.terminated = true
end

function aggregate_mission_landscapes(mission)
    return {}
end

function aggregate_mission_events(mission)
    local events = {}

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].tags ~= nil and g_savedata.objects[i].tags.spillage ~= nil then
            table.insert(events, g_savedata.objects[i].tags.spillage)
        elseif g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].type == "oil_spill" then
            table.insert(events, "oil")
        end
    end

    events = table.distinct(events)

    return events
end

function aggregate_mission_objectives(mission)
    local objs = {}

    for k, v in pairs(object_trackers) do
        objs[k] = {
            count = 0,
            obligatory = 0,
            dispensable = 0,
            count_picked = 0,
            contents = {}
        }
    end

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].tracker ~= nil then
            local data = objs[g_savedata.objects[i].tracker]
            local amount = g_savedata.objects[i]:count()

            data.count = data.count + amount

            -- if g_savedata.objects[i]:dispensable() then
            --     data.dispensable = data.dispensable + amount
            -- else
            --     data.obligatory = data.obligatory + amount
            -- end

            if g_savedata.objects[i].picked then
                data.count_picked = data.count_picked + g_savedata.objects[i]:count()
            end

            if not string.nil_or_empty(g_savedata.objects[i].name) then
                table.insert(data.contents, g_savedata.objects[i].name)
                data.contents = table.distinct(data.contents)
            end
        end
    end

    return objs
end

function aggregate_mission_category(mission)
    local category = 0
    local category_basis = 0
    local category_bonus = 0

    if mission.objectives.rescuee.count >= 20 or mission.objectives.fire.count >= 25 or mission.objectives.suspect.count >= 10 or mission.objectives.forest_fire.count >= 1 or mission.search_radius > 1000 then
        category_basis = 2
    elseif mission.objectives.rescuee.count >= 5 or mission.objectives.fire.count >= 5 or mission.objectives.suspect.count >= 2 or mission.search_radius > 500 then
        category_basis = 1
    else
        category_basis = 0
    end

    category_bonus = math.min(category_bonus, 2)
    category = math.max(mission.category, category_basis + category_bonus)

    -- if category >= 2 and mission.category < 2 then
    --     server.notify(-1, string.format("ミッション#%dの状況が深刻.", mission.id), "詳細はミッション情報を確認せよ.", 1)
    -- end

    return category
end

function aggregate_mission_units(mission)
    return {
        sar = mission.units ~= nil and mission.units.sar or mission.locations[1].search_radius >= 500 and #mission.locations >= 2,
        fire = mission.units ~= nil and mission.units.fire or mission.objectives.fire.count >= 5 or mission.objectives.fire.count >= 1,
        med = mission.units ~= nil and mission.units.med or mission.objectives.rescuee.count >= 1,
        spc = mission.units ~= nil and mission.units.spc or mission.objectives.suspect.count >= 1 or mission.objectives.wreckage.count >= 1 or mission.objectives.hostile.count >= 1
    }
end

function has_explosive_event(mission)
    return table.contains(mission.events, "chemical") or table.contains(mission.events, "dust") or table.contains(mission.events, "oil") or table.contains(mission.events, "gas")
end

-- objects

function initialize_object(id, type, name, tags, mission_id, component_id, parent_id, ...)
    local params = {...}
    local object = {}

    object.id = id
    object.type = type
    object.name = name

    console.notify(string.format("Initializing object %s#%d.", object.type, object.id))

    object.tags = tags
    object.marker_id = server.getMapID()
    object.component_id = component_id
    object.parent_id = parent_id
    object.mission = mission_id
    object.loaded = false
    object.completed = false
    object.cleared = false
    object.elapsed_clear = 0
    object.transform = position(object)
    object.tracker = nil
    object.ai = nil
    object.mounted = false
    object.mounts = {}

    if type == "vehicle" then
        object.command = nil
        object.actions = {}

        if object.tags.actions ~= nil then
            object.actions = string.split(object.tags.actions, ";")
        end
    end

    for k, v in pairs(object_trackers) do
        if v.test_type(object, id, type, tags, component_id, mission_id, table.unpack(params)) then
            object.tracker = k
            break
        end
    end

    if object.tags.mount_vehicle ~= nil and object.tags.mount_seat ~= nil then
        for i = 1, #g_savedata.objects do
            if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].mission == mission_id and string.lower(g_savedata.objects[i].name) == string.lower(object.tags.mount_vehicle) then
                table.insert(g_savedata.objects[i].mounts, {
                    id = id,
                    seat = object.tags.mount_seat
                })
            end
        end
    end

    if object.type == "character" and object.tags.ai ~= nil then
        object.ai = object.tags.ai
    end

    if object.type == "vehicle" and object.tags.keep_active == "true" then
        server.setVehicleTransponder(object.id, true)
    end

    if object.tracker ~= nil then
        based(object, object_trackers[object.tracker])
        object:init(table.unpack(params))
    end

    if object.tags.oil_spill ~= nil then
        local oil_spill = tonumber(object.tags.oil_spill)

        if oil_spill ~= nil then
            server.setOilSpill(object.transform, oil_spill)
        end
    end

    table.insert(g_savedata.objects, object)
end

function clear_object(object)
    console.notify(string.format("Clearing object %s#%d.", object.type, object.id))

    if object.tracker ~= nil then
        object:clear()
    end

    server.removeMapID(-1, object.marker_id)

    object.cleared = true
end

function despawn_object(object)
    if is_vehicle(object) then
        server.despawnVehicle(object.id, true)
    else
        if is_object(object) then
            server.despawnObject(object.id, true)
        end

        clear_object(object)
    end
end

function tick_object(object, tick)
    if object.tracker ~= nil then
        object.transform = position(object) or object.transform
        object:tick(tick)

        server.removeMapID(-1, object.marker_id)

        if g_savedata.mode == "debug" or object.tracker ~= nil and object:mapped() then
            local x, y, z = matrix.position(object.transform)
            local r, g, b, a = 128, 128, 128, 255
            local label = string.format("%s #%d", object.tracker, object.id)
            local popup = string.format("%s\n\nX: %.0f\nY: %.0f\nZ: %.0f", object.text, x, y, z)

            server.addMapObject(-1, object.marker_id, 0, object.marker_type, x, z, 0, 0, nil, nil, label, 0, popup, r, g, b, a)
        end

        if object.mission ~= nil and not object.completed and object:complete() then
            for j = 1, #g_savedata.missions do
                if g_savedata.missions[j].id == object.mission then
                    local reward = object:reward()
                    g_savedata.missions[j].rewards = g_savedata.missions[j].rewards + reward

                    console.notify(string.format("Reward: %d", reward))
                end
            end

            local label = object.text

            for i = 1, #players.items do
                if matrix.distance(object.transform, players.items[i].transform) <= 250 then
                    server.notify(players.items[i].id, label, "Objective achieved", 4)
                end
            end

            object.completed = true
        end

        if object.mission ~= nil and object.completed then
            if object.elapsed_clear >= object.clear_timer then
                despawn_object(object)
            else
                object.elapsed_clear = object.elapsed_clear + tick
            end
        end
    end

    if object.type == "vehicle" and #object.actions > 0 and object.command == nil then
        local nearby = false

        for i = 1, #g_savedata.objects do
            if g_savedata.objects[i].tracker == "unit" then
                nearby = nearby or matrix.distance(g_savedata.objects[i].transform, object.transform) < 500
            end
        end

        for i = 1, #players.items do
            nearby = nearby or matrix.distance(players.items[i].transform, object.transform) < 500
        end

        if nearby then
            object.command = table.random(object.actions)

            console.log(string.format("%s#%d entered %s command.", object.type, object.id, object.command))
        end
    elseif object.type == "vehicle" and #object.actions > 0 and (object.command == "attack" or object.command == "escape") then
    end
end

function find_parent_object(vehicle_parent_component_id, mission_id)
    return table.find(g_savedata.objects, function(x)
        return x.mission == mission_id and x.component_id == vehicle_parent_component_id
    end)
end

function spawn_character(transform, data)
    local object_id, is_scuccess = server.spawnCharacter(transform, data.character_outfit_type)
    local object = {}
    object.object_id = object_id
    object.group_id = nil
    object.vehicle_id = nil
    object.vehicle_ids = {}
    object.id = nil
    object.tags_full = data.tags_full
    object.tags = data.tags
    object.display_name = data.display_name
    object.type = data.type

    return object
end

function spawn_equipment(transform, type, int, flt)
    local object_id, is_success = server.spawnEquipment(transform, type, int, flt)
    local object = {}
    object.object_id = object_id
    object.group_id = nil
    object.vehicle_id = nil
    object.vehicle_ids = {}
    object.id = nil
    object.tags_full = ""
    object.tags = {}
    object.display_name = nil
    object.type = type

    return object
end

function loaded_object(object)
    object.loaded = true
    object:load()
end

function unloaded_object(object)
    object.loaded = false
    object:unload()
end

function is_doctor_nearby(transform)
    local is = false

    for i = 1, #g_savedata.objects do
        is = is or g_savedata.objects[i].tracker == "doctor" and matrix.distance(transform, g_savedata.objects[i].transform) <= 10
    end

    return is
end

function position(object)
    if is_vehicle(object) then
        return server.getVehiclePos(object.id)
    elseif is_object(object) then
        return server.getObjectPos(object.id)
    end
end

function is_vehicle(object)
    return object.type == "vehicle"
end

function is_object(object)
    return object.type == "object" or object.type == "character" or object.type == "flare" or object.type == "fire" or object.type == "loot" or object.type == "button" or object.type == "animal" or object.type == "creature" or object.type == "ice"
end

function is_tile(object)
    return object.type == "forest_fire" or object.type == "oil_spill"
end

function is_zone(object)
    return object.type == "zone"
end

function is_disaster(object)
    return object.type == "tornado" or object.type == "tsunami" or object.type == "whirlpool" or object.type == "meteor" or object.type == "eruption"
end

function mount_vehicle(vehicle)
    local components = server.getVehicleComponents(vehicle.id)

    for i = 1, #vehicle.mounts do
        local seats = table.find_all(components.components.seats, function(x)
            return string.lower(x.name) == string.lower(vehicle.mounts[i].seat)
        end)
        local seat = table.random(seats)
        server.setSeated(vehicle.mounts[i].id, vehicle.id, seat.pos.x, seat.pos.y, seat.pos.z)
    end
end

function wreck_players_vehicle(player)
    local vehicles = table.find_all(g_savedata.objects, function(x) return x.owner_steam_id == player.steam_id end)
    local cost = 0

    for i = 1, #vehicles do
        cost = cost - math.ceil(vehicles[i].mass * 5)
        server.despawnVehicle(vehicles[i].id, true)
    end

    transact(cost, string.format("%s's vehicles has wrecked.", player.name))
end

-- locations

locations = {
    items = {},
    load = function(self)
        local ls = {}
        local addon_index = 0
        local addon_count = server.getAddonCount()

        while addon_index < addon_count do
            local addon_data = server.getAddonData(addon_index)
            addon_data.index = addon_index
            local location_index = 0
            local location_count = addon_data ~= nil and addon_data.location_count or 0

            while location_index < location_count do
                local location_data = server.getLocationData(addon_index, location_index)
                local location = self:init(0, addon_index, location_index, location_data)

                if location ~= nil then
                    table.insert(ls, location)
                end

                location_index = location_index + 1
            end

            addon_index = addon_index + 1
        end

        return ls
    end,
    init = function(self, id, addon_index, location_index, obj)
        if obj == nil then
            return nil
        end

        if obj.env_mod then
            return nil
        end

        local prop = table.find(location_properties, function(x)
            return string.match(obj.name, x.pattern) ~= nil
        end)

        if prop == nil then
            return nil
        end

        obj.id = 0
        obj.addon_index = addon_index
        obj.location_index = location_index
        obj.pattern = prop.pattern or nil
        obj.tracker = prop.tracker or nil
        obj.suitable_zones = prop.suitable_zones or {}

        if prop.is_main_location ~= nil then
            obj.is_main_location = prop.is_main_location
        else
            obj.is_main_location = true
        end

        obj.sub_locations = prop.sub_locations or {}
        obj.sub_location_min = prop.sub_location_min or 0
        obj.sub_location_max = prop.sub_location_max or 0
        obj.is_unique_sub_location = prop.is_unique_sub_location or false
        obj.search_radius = prop.search_radius or 0
        obj.category = prop.category or nil
        obj.report = prop.report or ""
        obj.report_timer_min = prop.report_timer_min or 0
        obj.report_timer_max = prop.report_timer_max or 0
        obj.rescuee_min = prop.rescuee_min or 100
        obj.rescuee_max = prop.rescuee_max or 100
        obj.fire_min = prop.fire_min or 100
        obj.fire_max = prop.fire_max or 100
        obj.hostile_min = prop.hostile_min or 100
        obj.hostile_max = prop.hostile_max or 100
        obj.disaster = prop.disaster or nil
        obj.note = prop.note or ""

        return obj
    end,
    refresh = function(self)
        self.items = self:load()
    end,
    match_name = function(self, location, patterns)
        local matched = false

        for i = 1, #patterns do
            matched = matched or string.match(location.name, patterns[i]) ~= nil
        end

        return matched
    end,
    is_match_multipattern = function(self, location, patterns)
        local is = false

        for i = 1, #patterns do
            is = is or string.match(location.name, patterns[i]) ~= nil
        end

        return is
    end,
    is_unprecedented = function(self, location)
        local is = true
        local unique = {}

        for i = 1, #self.items do
            if self.items[i].is_main_location then
                table.insert(unique, self.items[i][g_savedata.location_comparer])
            end
        end

        unique = table.distinct(unique)

        local history_back = #g_savedata.locations_history - math.floor(#unique * 0.75) + 1

        for i = #g_savedata.locations_history, math.max(history_back, 1), -1 do
            is = is and g_savedata.locations_history[i][g_savedata.location_comparer] ~= location[g_savedata.location_comparer]
        end

        return is
    end,
    is_suitable = function(self, location, center, range_min, range_max)
        local is = false

        if location.tile == "" then
            for i = 1, #zones.items do
                is = is or zones:is_suitable(zones.items[i], location, center, range_min, range_max)
            end

            if table.contains(location.suitable_zones, "offshore") then
                local _, s = server.getOceanTransform(center, range_min, range_max)
                is = is or s
            end
        else
            local transform, s = server.getTileTransform(center, location.tile, range_max)

            is = is or s
        end

        return is
    end,
    random_offshore = function(self, center, range_min, range_max)
        local transform, s = server.getOceanTransform(center, range_min, range_max)

        if not s then
            return matrix.identity(), s
        end

        local noise_x = math.random() * 1000 - 500
        local noise_z = math.random() * 1000 - 500
        local noise = matrix.translation(noise_x, 0, noise_z)
        transform = matrix.multiply(transform, noise)

        return transform, s
    end,
    random = function(self, center, range_min, range_max, is_main, is_unprecedented, patterns, landscapes, sibling_locations)
        local result = {}

        if patterns == nil then
            patterns = {}
        end

        if landscapes == nil then
            landscapes = {}
        end

        if sibling_locations == nil then
            sibling_locations = {}
        end

        local _locations = table.find_all(self.items, function(x)
            return (#patterns == 0 or self:is_match_multipattern(x, patterns)) and (not is_main or x.is_main_location) and self:is_suitable(x, center, range_min, range_max) and (not is_main or not is_unprecedented or self:is_unprecedented(x))
        end)

        if #_locations == 0 then
            local text = "No locations matching your requirements were found: "
            for i = 1, #patterns do
                if i > 1 then
                    text = text .. ", "
                end

                text = text .. patterns[i]
            end

            console.log(text)
            return {}
        end

        local _locations_name = table.select(_locations, function(x)
            return x.name
        end)

        local location_name = table.random(_locations_name)

        _locations = table.find_all(_locations, function(x)
            return x.name == location_name
        end)

        for i = #_locations, 1, -1 do
            local zone = nil
            local transform = nil

            if _locations[i].tile == "" then
                local _zones = zones:find_all(function(x)
                    return zones:is_suitable(x, _locations[i], center, range_min, range_max) and (not is_main or not zones:is_in_another_mission(x, _locations[i].search_radius)) and not zones:is_occupied(x, result) and not zones:is_occupied(x, sibling_locations)
                end)
                local _zones_landscape = table.distinct(table.select(_zones, function(x)
                    return x.landscape
                end))

                if table.contains(_locations[i].suitable_zones, "offshore") then
                    table.insert(_zones_landscape, "offshore")
                end

                local landscapes_text = ""

                for i = 1, #_zones_landscape do
                    landscapes_text = landscapes_text .. _zones_landscape[i] .. " "
                end

                local landscape = table.random(_zones_landscape)

                if landscape == "offshore" then
                    local t, s = self:random_offshore(center, range_min, range_max)

                    transform = s and t or nil
                else
                    local _zones = table.find_all(_zones, function(x)
                        return x.landscape == landscape
                    end)
                    zone = table.random(_zones)

                    if zone ~= nil then
                        transform = zone.transform
                    end
                end
            else
                local t, s = server.getTileTransform(center, _locations[i].tile, range_max)

                transform = s and t or nil
            end

            if transform ~= nil then
                local l = table.copy(_locations[i])
                l.zone = zone
                l.transform = transform

                table.insert(result, l)

                if is_main then
                    center = transform
                    range_min = 0
                    range_max = _locations[i].search_radius
                end
            else
                console.log(string.format("Although locations matching the requirements were found, no landscapes were found for them: %s", _locations[i].name))
            end
        end

        return result
    end,
    list = function(self, peer_id)
        for i = 1, #self.items do
            server.announce("[Mission Foundation]", self.items[i].name, peer_id)
        end

        server.announce("[Mission Foundation]", string.format("%d all locations", #self.items), peer_id)
    end
}

function spawn_location(location, mission_id)
    local vehicles = {}
    local rescuees = {}
    local fires = {}
    local others = {}

    if location.zone then
        console.notify(string.format("Spawning dynamic location %s in %s", location.name, location.zone.tags.landscape))
    else
        console.notify(string.format("Spawning static location %s in %s", location.name, location.tile))
    end

    for component_index = 0, location.component_count do
        local data = server.getLocationComponentData(location.addon_index, location.location_index, component_index)

        if data ~= nil then
            data.addon_index = location.addon_index
            data.location_index = location.location_index
            data.component_index = component_index
            data.tags = string.parse_tags(data.tags_full)

            if data.type == "vehicle" then
                table.insert(vehicles, data)
            elseif data.type == "character" and data.tags.tracker == "rescuee" then
                table.insert(rescuees, data)
            elseif data.type == "fire" then
                table.insert(fires, data)
            else
                table.insert(others, data)
            end
        end
    end

    for i = 1, #vehicles do
        spawn_component(vehicles[i], location.transform, mission_id)
    end

    local rescuees_limit = math.ceil(#rescuees * math.random(location.rescuee_min, location.rescuee_max) / 100)
    table.shuffle(rescuees)

    for i = 1, rescuees_limit do
        spawn_component(rescuees[i], location.transform, mission_id)
    end

    local fires_limit = math.ceil(#fires * math.random(location.fire_min, location.fire_max) / 100)
    table.shuffle(fires)

    for i = 1, fires_limit do
        spawn_component(fires[i], location.transform, mission_id)
    end

    for i = 1, #others do
        spawn_component(others[i], location.transform, mission_id)
    end
end

function spawn_component(component, transform, mission_id)
    if table.has(g_savedata.disabled_components, component.type) then
        return
    end

    local transform = matrix.multiply(transform, component.transform)
    local parent_object_id = nil
    local id = nil

    if component.vehicle_parent_component_id > 0 then
        local parent_object = find_parent_object(component.vehicle_parent_component_id, mission_id)
        parent_object_id = parent_object.id
    end

    spawn_by_foundation = true
    local object, is_success = server.spawnAddonComponent(transform, component.addon_index, component.location_index, component.component_index, parent_object_id)
    spawn_by_foundation = false

    local tags = string.parse_tags(object.tags_full)

    if is_vehicle(object) then
        for i = 1, #object.vehicle_ids do
            initialize_object(object.vehicle_ids[i], object.type, object.display_name, tags, mission_id, component.id, parent_object_id)
        end
    else
        initialize_object(object.id, object.type, object.display_name, tags, mission_id, component.id, parent_object_id)
    end
end

function record_location_history(location)
    table.insert(g_savedata.locations_history, table.copy(location))
end

function list_location_history(peer_id)
    local peer_id = peer_id

    for i = 1, #g_savedata.locations_history do
        server.announce("[Mission Foundation]", string.format("%d %s", i, g_savedata.locations_history[i].name), peer_id)
    end
end

-- zones

zones = {
    items = {},
    load = function(self)
        local raws = server.getZones()
        local models = {}

        for i = 1, #raws do
            local z = self:init(raws[i])

            if i ~= nil then
                table.insert(models, z)
            end
        end

        return models
    end,
    init = function(self, obj)
        local tags = string.parse_tags(obj.tags_full)
        local prop = table.find(zone_properties, function(x)
            return tags.landscape == x.landscape
        end)

        if prop == nil then
            return nil
        end

        obj.tags = tags
        obj.landscape = prop.landscape
        obj.marker_id = server.getMapID()
        obj.mapped = prop.mapped or false
        obj.icon = prop.icon or 0

        return obj
    end,
    refresh = function(self)
        for j = 1, #players.items do
            if players.items[j].map_opened then
                self:clear_all_map(players.items[j].id)
            end
        end

        self.items = self:load()

        for i = 1, #zones.items do
            for j = 1, #players.items do
                if players.items[j].map_opened then
                    self:map(zones.items[i], players.items[j].id)
                end
            end
        end
    end,
    is_in_landscape = function(self, transform, landscape)
        local is = false

        for i = 1, #self.items do
            is = is or self.items[i].landscape == landscape and self:is_in(transform, self.items[i])
        end

        return is
    end,
    is_in = function(self, transform, zone)
        return server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z)
    end,
    is_in_range = function(self, zone, center, min, max)
        local d = matrix.distance(zone.transform, center)
        return d >= min and d <= max
    end,
    is_occupied = function(self, zone, locations)
        local is = false

        for i = 1, #locations do
            if locations[i].zone ~= nil then
                is = is or self:is_in(zone.transform, locations[i].zone)
            end
        end

        return is
    end,
    is_in_another_mission = function(self, zone, clearance)
        local is = false

        for i = 1, #g_savedata.missions do
            is = is or matrix.distance(g_savedata.missions[i].search_center, zone.transform) <= g_savedata.missions[i].search_radius + clearance
        end

        return is
    end,
    is_suitable = function(self, zone, location, center, range_min, range_max)
        return self:is_in_range(zone, center, range_min, range_max) and self:is_match_landscapes(location.suitable_zones, zone)
    end,
    is_match_landscapes = function(self, landscapes, zone)
        return table.contains(landscapes, zone.landscape)
    end,
    find = function(self, test)
        return table.find(self.items, test)
    end,
    find_all = function(self, test)
        return table.find_all(self.items, test)
    end,
    map = function(self, zone, peer_id)
        local peer_id = peer_id or -1

        if (g_savedata.mode == "debug") or zone.mapped then
            local x, y, z = matrix.position(zone.transform)
            local color = zone.icon == 8 and 255 or 0
            local name = zone.name

            if name == "" then
                name = zone.landscape
            end

            server.addMapLabel(peer_id, g_savedata.subsystems.mapping.zone.markar_id, zone.icon, name, x, z, color, color, color, 255)
        end
    end,
    clear_all_map = function(self, peer_id)
        local peer_id = peer_id or -1
        server.removeMapID(peer_id, g_savedata.subsystems.mapping.zone.markar_id)
    end
}

-- headquarter

function alert_headquarter()
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "headquarter" and g_savedata.objects[i].alert ~= nil then
            press_vehicle_button(g_savedata.objects[i].id, g_savedata.objects[i].alert)
        end
    end
end

-- oil spill

oil_spill_threshold = 500

function create_oil_spill_id()
    g_savedata.oil_spill_count = g_savedata.oil_spill_count + 1
    return g_savedata.oil_spill_count
end

-- budgets

function transact(amount, title)
    if server.getGameSettings().infinite_money then
        return
    end

    local not_type = 4
    local text = "Accepted $%d"

    if amount == 0 then
        return
    elseif amount < 0 then
        not_type = 2
        text = "Paid out $%d"
    end

    local money = server.getCurrency() + amount
    local format = string.format(text, amount)

    server.setCurrency(money)
    server.notify(-1, format, title, not_type)
    console.log(format)
end

-- spawn point

function teleport_to_spawn_points(peer_id)
    local _zones = zones:find_all(function(x)
        return zones:is_in_range(x, start_tile_transform(), 0, g_savedata.subsystems.mission.range_max) and zones:is_match_landscapes({"respawn"}, x)
    end)
    local _z = table.random(_zones)

    server.setPlayerPos(peer_id, _z.transform)
end

-- players

players = {
    items = {},
    load = function(self)
        local raws = server.getPlayers()
        local models = {}

        for i = 1, #raws do
            local model = self:init(raws[i])

            if model ~= nil then
                table.insert(models, model)
            end
        end

        return models
    end,
    init = function(self, player)
        if player.id == 0 and player.name == "Server" then
            return nil
        end

        player.steam_id = tostring(player.steam_id)

        local transform, is_success = server.getPlayerPos(player.id)

        if is_success then
            player.transform = transform
        else
            player.transform = matrix.identity()
        end

        player.object_id = (server.getPlayerCharacterID(player.id))
        player.vehicle_id = (server.getCharacterVehicle(player.object_id))
        player.map_opened = g_savedata.players_map[player.id]
        player.vital = server.getCharacterData(player.id)

        return player
    end,
    refresh = function(self)
        self.items = self:load()
    end,
    find = function(self, test)
        return table.find(self.items, test)
    end,
    find_all = function(self, test)
        return table.find_all(self.items, test)
    end,
    is_in_range = function(self, transform, distance)
        local is = false

        for i = 1, #self.items do
            is = is or matrix.distance(transform, self.items[i].transform) <= distance
        end

        return is
    end,
}

-- callbacks

cycle = 60
timing = 0

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if timing % 10 == 0 then
        players:refresh()
    end

    if timing % 15 == 0 then
        zones:refresh()
    end

    for i = #g_savedata.objects, 1, -1 do
        if i % cycle == timing then
            if g_savedata.objects[i].cleared then
                table.remove(g_savedata.objects, i)
            else
                tick_object(g_savedata.objects[i], tick * cycle)
            end
        end
    end

    for i = #g_savedata.missions, 1, -1 do
        if i % cycle == timing then
            if g_savedata.missions[i].cleared then
                table.remove(g_savedata.missions, i)
            else
                tick_mission(g_savedata.missions[i], tick * cycle)
            end
        end
    end

    if g_savedata.subsystems.mission.timer_tickrate > 0 then
        if g_savedata.subsystems.mission.interval <= 0 and (not g_savedata.subsystems.mission.count_limited or missions_less_than_limit()) then
            random_mission(start_tile_transform(), g_savedata.subsystems.mission.range_max, g_savedata.subsystems.mission.range_min)
            g_savedata.subsystems.mission.interval = math.random(g_savedata.subsystems.mission.interval_min, g_savedata.subsystems.mission.interval_max)
        else
            g_savedata.subsystems.mission.interval = g_savedata.subsystems.mission.interval - (tick * g_savedata.subsystems.mission.timer_tickrate)
        end
    end

    timing = timing + 1

    if timing >= cycle then
        timing = 0
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
    if command == "?mission" or command == "?m" then
        if verb == "list" and is_admin then
            locations:list(peer_id)
        elseif verb == "history" then
            list_location_history(peer_id)
        elseif verb == "start" and is_admin then
            g_savedata.subsystems.mission.timer_tickrate = 1
        elseif verb == "stop" and is_admin then
            g_savedata.subsystems.mission.timer_tickrate = 0
        elseif verb == "init" and is_admin then
            local location = ...
            local center = start_tile_transform()

            if location ~= nil then
                location = "^" .. location .. "$"
            else
                console.error("location name is empty")
                return
            end

            random_mission(center, g_savedata.subsystems.mission.range_max, g_savedata.subsystems.mission.range_min, false, location)
        elseif verb == "clear-all" and is_admin then
            for i = #g_savedata.missions, 1, -1 do
                clear_mission(g_savedata.missions[i])
            end
        elseif verb == "clear" and is_admin then
            local id = ...
            id = tonumber(id)
            local mission = table.find(g_savedata.missions, function(x)
                return x.id == id
            end)

            if mission == nil then
                console.error(string.format("Mission #%d is not exist.", id))
                return
            end

            clear_mission(mission)
        elseif verb == "next" and is_admin then
            g_savedata.subsystems.mission.interval = 0
        elseif verb == "close" and is_admin then
            local id = ...
            id = tonumber(id)
            local mission = table.find(g_savedata.missions, function(x)
                return x.id == id
            end)

            if mission == nil then
                console.error(string.format("Mission #%d is not exist.", id))
                return
            end

            terminate_mission(mission)
        elseif verb == "register-hq" and is_admin then
            console.error("'?mission register-hq' removed. Please read a manual for new methods.")
        elseif verb == "prod" and is_admin then
            g_savedata.mode = "prod"
        elseif verb == "debug" and is_admin then
            g_savedata.mode = "debug"
        elseif verb == "limit-count" and is_admin then
            local set = ...
            g_savedata.subsystems.mission.count_limited = set_or_not(g_savedata.subsystems.mission.count_limited, set)
        elseif verb == "range-min" and is_admin then
            local range = ...
            local range = tonumber(range)

            if range ~= nil then
                g_savedata.subsystems.mission.range_min = range * 1000
            end
        elseif verb == "range-max" and is_admin then
            local range = ...
            local range = tonumber(range)

            if range ~= nil then
                g_savedata.subsystems.mission.range_max = range * 1000
            end
        elseif verb == "gather" and is_admin then
            local mission_id = ...
            mission_id = tonumber(mission_id)
            local transform, is_success = server.getPlayerPos(peer_id)

            for i = #g_savedata.objects, 1, -1 do
                if g_savedata.objects[i].tracker == "rescuee" and g_savedata.objects[i].mission == mission_id then
                    server.setObjectPos(g_savedata.objects[i].id, transform)
                end
            end
        elseif verb == "clear-history" and is_admin then
            g_savedata.locations_history = {}
        elseif verb == "dispensable" and is_admin then
            local objective, set = ...

            if g_savedata.subsystems[objective] ~= nil then
                g_savedata.subsystems[objective].dispensable = set_or_not(g_savedata.subsystems[objective].dispensable, set)
            end
        elseif verb == "disable" and is_admin then
            local value = ...

            if value == nil then
                return
            end

            table.insert(g_savedata.disabled_components, value)
        elseif verb == "enable" and is_admin then
            local value = ...

            if value == nil then
                return
            end

            table.remove(g_savedata.disabled_components, table.find_index(g_savedata.disabled_components, function(x)
                return x == value
            end))
        elseif verb == "clear-disabled-components" and is_admin then
            g_savedata.disabled_components = {}
        end
    elseif command == "?tp" then
        local target = tonumber(verb)

        if target == nil then
            return
        end

        local object_id, s = server.getPlayerCharacterID(target)

        if not s then
            return
        end

        local vehicle_id = server.getCharacterVehicle(object_id)

        if vehicle_id > 0 then
            server.command(string.format("?ttv %d %d", vehicle_id, peer_id))
        else
            server.command(string.format("?ttp %d %d", target, peer_id))
        end

        local player = players:find(function(x)
            return x.id == peer_id
        end)
        local target_player = players:find(function(x)
            return x.id == target
        end)

        transact(-2500, string.format("%s has teleported."))
        console.log(string.format("%s has teleported to %s.", player.name, target_player.name))
    elseif command == "?clear" then
        local player = players:find(function(x) return x.id == peer_id end)
        wreck_players_vehicle(player)
    elseif command == "?kill" then
        local player = players:find(function(x) return x.id == peer_id end)
        local object_id = server.getPlayerCharacterID(peer_id)
        wreck_players_vehicle(player)
        server.killCharacter(object_id)
        transact(-10000, string.format("%s has bought a new life.", player.name))
    end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    if peer_id < 0 or name == "Server" then
        return
    end

    local transform = server.getPlayerPos(peer_id)

    if zones:is_in_landscape(transform, "first_spawn") then
        teleport_to_spawn_points(peer_id)
    end
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
end

function onPlayerRespawn(peer_id)
    local player = players:find(function(p)
        return p.id == peer_id
    end)

    teleport_to_spawn_points(peer_id)
end

spawn_by_foundation = false

function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
    if spawn_by_foundation then
        return
    end

    local vehicle_ids = server.getVehicleGroup(group_id)
    local data = server.getVehicleData(vehicle_ids[1])
    local owner = nil
    local cost = nil

    if peer_id >= 0 then
        local player = players:find(function(x)
            return x.id == peer_id
        end)

        if player ~= nil then
            owner = player.steam_id
        else
            owner = nil
        end

        cost = group_cost
    end

    local tags = string.parse_tags(data.tags_full)
    local test = false

    for k, v in pairs(object_trackers) do
        test = test or v:test_type(vehicle_ids[1], "vehicle", tags, nil, nil, owner, cost)
    end

    if test then
        initialize_object(vehicle_ids[1], "vehicle", data.name, tags, nil, nil, nil, owner, cost)
    end
end

function onVehicleLoad(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            if g_savedata.objects[i].tracker ~= nil then
                loaded_object(g_savedata.objects[i])
            end

            if not g_savedata.objects[i].mounted and #g_savedata.objects[i].mounts > 0 then
                mount_vehicle(g_savedata.objects[i])
            end
        end
    end
end

function onVehicleUnload(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            if g_savedata.objects[i].tracker ~= nil then
                unloaded_object(g_savedata.objects[i])
            end
        end
    end
end

function onObjectLoad(object_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type ~= "vehicle" and g_savedata.objects[i].id == object_id and g_savedata.objects[i].tracker ~= nil then
            loaded_object(g_savedata.objects[i])
        end
    end
end

function onObjectUnload(object_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type ~= "vehicle" and g_savedata.objects[i].id == object_id and g_savedata.objects[i].tracker ~= nil then
            unloaded_object(g_savedata.objects[i])
        end
    end
end

function onVehicleDespawn(vehicle_id, peer_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and (g_savedata.objects[i].id == vehicle_id or g_savedata.objects[i].parent_id == vehicle_id) then
            clear_object(g_savedata.objects[i])
        end
    end
end

function onForestFireSpawned(fire_objective_id, x, y, z)
    local transform = matrix.translation(x, y, z)
    local mission_id = nil
    local distance = 2000

    for i = 1, #g_savedata.missions do
        local d = matrix.distance(transform, g_savedata.missions[i].search_center)

        if d <= distance then
            mission_id = g_savedata.missions[i].id
            distance = d
        end
    end

    if mission_id ~= nil then
        initialize_object(fire_objective_id, "forest_fire", nil, {}, mission_id, nil, nil, transform)
    end
end

function onForestFireExtinguished(fire_objective_id, fire_x, fire_y, fire_z)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "forest_fire" and g_savedata.objects[i].id == fire_objective_id then
            g_savedata.objects[i].is_lit = false
        end
    end
end

function onOilSpill(x, z, delta, total, vehicle_id)
    if total > oil_spill_threshold and g_savedata.oil_spills[x] == nil then
        g_savedata.oil_spills[x] = {}
    end

    if total > oil_spill_threshold and g_savedata.oil_spills[x][z] == nil then
        g_savedata.oil_spills[x][z] = 0

        local id = create_oil_spill_id()
        local mx = x * 1000

        if mx > 0 then
            mx = mx + 500
        elseif mx < 0 then
            mx = mx - 500
        end

        local mz = z * 1000

        if mz > 0 then
            mz = mz + 500
        elseif mz < 0 then
            mz = mz - 500
        end

        local transform = matrix.translation(mx, 0, mz)
        local mission_id = nil
        local distance = 2000

        for i = 1, #g_savedata.missions do
            local d = matrix.distance(transform, g_savedata.missions[i].search_center)

            if d <= distance then
                mission_id = g_savedata.missions[i].id
                distance = d
            end
        end

        if mission_id ~= nil then
            initialize_object(id, "oil_spill", nil, {}, mission_id, nil, nil, transform, x, z, total)
        end
    end

    if g_savedata.oil_spills[x] ~= nil and g_savedata.oil_spills[x][z] ~= nil then
        g_savedata.oil_spills[x][z] = total
    end
end

function onClearOilSpill()
    g_savedata.oil_spills = {}
end

function onToggleMap(peer_id, is_open)
    g_savedata.players_map[peer_id] = is_open
end

function onCreate(is_world_create)
    if is_world_create then
        g_savedata.subsystems.mapping.zone.markar_id = server.getMapID()
    end

    zones:refresh()
    locations:refresh()
    players:refresh()

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker ~= nil then
            based(g_savedata.objects[i], object_trackers[g_savedata.objects[i].tracker])
        end
    end

    for i = 1, #g_savedata.missions do
        based(g_savedata.missions[i], mission_trackers[g_savedata.missions[i].tracker])
    end

    console.notify(name)
    console.notify(version)
    console.notify(string.format("Locations: %d", #locations.items))
    console.notify(string.format("Zones: %d", #zones.items))
    console.notify(string.format("Gone missions: %d", #g_savedata.locations_history))
    console.notify(string.format("Active missions: %d", #g_savedata.missions))
    console.notify(string.format("Active objects: %d", #g_savedata.objects))
    console.notify(string.format("Mission range limited: %s", g_savedata.subsystems.mission.range_limited))
    console.notify(string.format("Mission count limited: %s", g_savedata.subsystems.mission.count_limited))
end

function onEquipmentDrop(object_id_actor, object_id_target, equipment_id)
    local is_npc = false

    for i = #g_savedata.objects, 1, -1 do
        is_npc = is_npc or g_savedata.objects[i].type == "character" and g_savedata.objects[i].id == object_id_actor
    end

    server.despawnObject(object_id_target, is_npc)
end

-- utils

function set_or_not(value, set)
    if set == "true" then
        return true
    elseif set == "false" then
        return false
    elseif set == nil then
        return not value
    end
end

function set_vehicle_button(vehicle_id, button, value)
    local data, s = server.getVehicleButton(vehicle_id, button.pos.x, button.pos.y, button.pos.z)

    if s and ((value or data.on) and (not value or not data.on)) then
        press_vehicle_button(vehicle_id, button)
    end
end

function press_vehicle_button(vehicle_id, button)
    -- server.pressVehicleButton(vehicle_id, 0, 0, 0)
    server.pressVehicleButton(vehicle_id, button.name)
end

function set_vehicle_keypad(vehicle_id, keypad, value)
    server.setVehicleKeypad(vehicle_id, keypad.pos.x, keypad.pos.y, keypad.pos.z, value)
end

function missions_less_than_limit()
    return #g_savedata.missions < (#players.items / g_savedata.subsystems.mission.player_factor)
end

function despawn_vehicle_group(group_id, is_instant)
    local vehicle_ids, is_success = server.getVehicleGroup(group_id)

    if not is_success then
        return
    end

    for k, v in pairs(vehicle_ids) do
        server.despawnVehicle(v, is_instant or false)
    end
end

function start_tile_transform()
    local start_tile = server.getStartTile()
    return matrix.translation(start_tile.x, start_tile.y, start_tile.z)
end

console = {}

function console.log(text, peer_id)
    if peer_id == nil then
        peer_id = -1
    end

    server.announce("[LOG]", text, peer_id)
end

function console.notify(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
        server.announce("[NOTICE]", text, peer_id)
    end
end

function console.error(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[ERROR]", text, peer_id)
end

function string.parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([^%s%c,]+)") do
        t[k] = v
    end

    return t
end

function string.split(s, separator)
    local t = {}

    for part in string.gmatch(s, "([^" .. separator .. "]+)") do
        table.insert(t, part)
    end

    return t
end

function string.nil_or_empty(s)
    return s == nil or s == ""
end

function table.any(t, test)
    local any = false

    for i = 1, #t do
        any = any or test(t[i])
    end

    return any
end

function table.contains(t, x)
    local contains = false

    for i = 1, #t do
        contains = contains or t[i] == x
    end

    return contains
end

function table.find_index(t, test)
    for i = 1, #t do
        if test(t[i]) then
            return i
        end
    end

    return nil
end

function table.find(t, test)
    for i = 1, #t do
        if test == nil or test(t[i]) then
            return t[i], i
        end
    end

    return nil, nil
end

function table.find_all(t, test)
    local items = {}

    for i = 1, #t do
        if test(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

function table.has(t, x)
    for i = 1, #t do
        if t[i] == x then
            return true
        end
    end

    return false
end

function table.intersect(m, n)
    local r = {}

    for i = 1, #m do
        for j = 1, #n do
            if n[j] == m[i] then
                table.insert(r, m[i])
            end
        end
    end

    return r
end

function table.keys(t)
    local items = {}

    for k, v in pairs(t) do
        table.insert(items, k)
    end

    return items
end

function table.random(t)
    if #t == 0 then
        return nil
    end

    return t[math.random(1, #t)]
end

function table.select(t, selector)
    local items = {}

    for i = 1, #t do
        local value = selector(t[i])

        if value ~= nil then
            table.insert(items, value)
        end
    end

    return items
end

function table.where(t, selector)
    local items = {}

    for i = 1, #t do
        if selector(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

function table.copy(t)
    local u = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            u[k] = table.copy(v)
        else
            u[k] = v
        end
    end

    return u
end

function table.distinct(t)
    local u = {}
    local hash = {}

    for _, v in ipairs(t) do
        if not hash[v] then
            u[#u + 1] = v
            hash[v] = true
        end
    end

    return u
end

function table.shuffle(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end

function math.round(x)
    return math.floor(x + 0.5)
end

function based(table1, table2)
    for k, v in pairs(table2) do
        table1[k] = v
    end
end
