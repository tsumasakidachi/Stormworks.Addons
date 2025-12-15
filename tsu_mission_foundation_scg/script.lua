name = "TSU Mission Foundation for SCG"
version = "1.3.0"

-- properties
g_savedata = {
  mode = "debug",
  missions = {},
  objects = {},
  oil_spills = {},
  oil_spill_count = 0,
  investigation_points = {},
  players = {},
  players_map = {},
  players_alert = {},
  players_enroute = {},
  locations_count = 0,
  locations_history = {},
  location_comparer = "pattern",
  subsystems = {
    mission = {
      timer_tickrate = 0,
      interval = 0,
      -- interval_min = property.slider("Minimum interval at which new missions occur (minutes)", 0, 30, 1, 1) * 3600,
      -- interval_max = property.slider("Maximum interval at which new missions occur (minutes)", 0, 60, 1, 5) * 3600,
      range_min = property.slider("Minimum range in which new missions occur (km)", 0, 10, 1, 1) * 1000,
      range_max = property.slider("Maximum range in which new missions occur (km)", 1, 100, 1, 6) * 1000,
      count_limited = true,
      count = 0,
      geologic = {
        waters = true,
        mainlands = true,
        islands = true,
      },
      area_limited = false,
      area_x_min = -30000,
      area_x_max = 20000,
      area_y_min = -26000,
      area_y_max = -10000,
      difficulty = 0,
      difficulty_remaining_min = 20 * 3600,
      difficulty_remaining_max = 40 * 3600,
      difficulty_remaining = 0,
      category_default = property.slider("Number of players required to complete per mission", 1, 32, 1, 3),
      taken_to_long_threshold = property.slider("Time taken for volunteers to locate missing persons (minutes)", 5, 90, 1, 10) * 3600,
    },
    rescuee = {
      tracker = true,
      dispensable = false,
      cpa_recurrence_rate = property.slider("CPA recurrence rate (%)", 0, 100, 1, 20),
      cpa_recurrence_threshold_players = property.slider("CPA recurrence occur when players are more than", 0, 32, 1, 8),
      has_strobe = property.checkbox("Rescuees has strobe", true),
    },
    fire = {
      tracker = true,
      dispensable = false,
      rate_explode = property.slider("Explosion rate per second due to spillage (%)", 0, 10, 0.1, 0.5),
    },
    forest_fire = {
      tracker = true,
      dispensable = false
    },
    suspect = {
      tracker = true,
      spawn = true,
      dispensable = false
    },
    spillage = {
      tracker = true,
      dispensable = false
    },
    accessory = {
      tracker = true,
      active = true,
      dispensable = true
    },
    hostile = {
      tracker = true,
      active = true,
      dispensable = true
    },
    cargo = {
      tracker = false,
    },
    mapping = {
      mission = {},
      object = {},
      interaction = {
        markar_id = 0
      },
      landscape = {
        markar_id = 0
      }
    },
  },
  disabled_components = {},
  dlcs = {
    weapon = false,
    industry = false,
    space = false,
  },
}

cases = {
  ems = {
    id = 1,
    text = "EMS 救急",
  },
  far = {
    id = 2,
    text = "FAR 火災",
  },
  sar = {
    id = 3,
    text = "SAR 捜索救難",
  },
  water = {
    id = 4,
    text = "WAT 水難",
  },
  securite = {
    id = 5,
    text = "SEC 警備行動",
  },
  supply = {
    id = 6,
    text = "SUP 物資輸送",
  },
  accident = {
    id = 51,
    text = "ACC 事故",
  },
  mayday = {
    id = 52,
    text = "MDY メーデー",
  },
  alert = {
    id = 91,
    text = "WRN 警報"
  }
}

geologics = {
  mainlands = "mainlands",
  islands = "islands",
  waters = "waters",
}

difficulties = {
  0, common = 2, occasional = 4, rare = 8
}

location_properties = { {
  pattern = "^mission:climber_missing_%d+$",
  tracker = "sar",
  case = cases.sar,
  geologic = geologics.mainlands,
  suitable_zones = { "forest", "mountain" },
  is_main_location = false,
  sub_locations = { "^mission:climber_missing_%d+$", "^mission:raft_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 1000,
  difficulty = 8,
  report = "悪天候により登山客の集団遭難が発生した. このエリアを捜索し行方不明者を全員救出せよ.",
  note = "警察署からの通報",
}, {
  pattern = "^mission:em_call_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = { "house" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 0,
  difficulty = 2,
  report = "タス...ケ......タ......",
  note = "民間人からの通報",
}, {
  pattern = "^mission:passenger_fallen_land_%d+$",
  tracker = "sar",
  case = cases.water,
  geologic = geologics.waters,
  suitable_zones = { "field", "mountain", "forest" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 0,
  report = "落水者",
  note = "",
}, {
  pattern = "^mission:passenger_fallen_water_%d+$",
  tracker = "sar",
  case = cases.water,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel", "shallow" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 0,
  report = "落水者",
  note = "",
}, {
  pattern = "^mission:lifeboat_%d+$",
  tracker = "sar",
  case = cases.water,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel", "shallow" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 0,
  report = "救命ボート",
  note = "",
}, {
  pattern = "^mission:raft_%d+$",
  tracker = "sar",
  geologic = geologics.mainlands,
  case = cases.water,
  suitable_zones = { "lake", "beach" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 500,
  difficulty = 2,
  report = "いかだを作ってあそんでいたら転覆した!",
  note = "民間人からの通報",
}, {
  pattern = "^mission:freighter_fire_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 1000,
  difficulty = 8,
  report = "船内で突然何かが爆発した! もう助からないぞ!",
  character_min = 25,
  character_max = 75,
  note = "乗員からの通報",
}, {
  pattern = "^mission:ferry_fire_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 1000,
  difficulty = 8,
  report = "本船客室より出火し, 船全体に火の手が回りつつあり非常に危険な状況である. 迅速な救援を求む.",
  character_min = 25,
  character_max = 75,
  note = "乗員からの通報",
}, {
  pattern = "^mission:tanker_fire_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 1000,
  difficulty = 8,
  report = "積荷の石油に火がアアア......",
  character_min = 25,
  character_max = 75,
  note = "乗員からの通報",
}, {
  pattern = "^mission:boat_sink_%d+$",
  tracker = "sar",
  case = cases.water,
  geologic = geologics.mainlands,
  suitable_zones = { "lake" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 500,
  difficulty = 2,
  report = "ボートが壊れて沈没しそう!",
  character_min = 25,
  character_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:overboard_%d+$",
  tracker = "sar",
  case = cases.water,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel", "beach" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$" },
  sub_location_min = 1,
  sub_location_max = 1,
  dispersal_area = 1000,
  difficulty = 2,
  report = "船から人が落ちた!",
  note = "職員からの通報",
}, {
  pattern = "^mission:ferry_sink_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 2000,
  difficulty = 8,
  report = "本船は何らかの物体と接触, 浸水し沈没しかかっている. 乗員乗客はほとんど脱出に成功したが漂流している. 至急救援を求む.",
  character_min = 25,
  character_max = 75,
  note = "乗員からの通報",
}, {
  pattern = "^mission:fishboat_fire_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 1000,
  difficulty = 8,
  report = "漁船のエンジンが爆発し炎上中! どうやら浸水も起きているようだ. 終わった.",
  character_min = 25,
  character_max = 75,
  note = "乗員からの通報",
}, {
  pattern = "^mission:heli_crash_wind_turbine_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.islands,
  suitable_zones = { "wind_turbine" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 500,
  difficulty = 4,
  report = "ヘリコプターが風力発電機と接触し墜落した. 激しく炎上しており周囲の森林に延焼する可能性がある, 至急救援求む.",
  character_min = 100,
  character_max = 100,
  note = "乗員からの通報",
}, {
  pattern = "^mission:diver_yacht_%d+$",
  tracker = "sar",
  case = cases.sar,
  geologic = geologics.waters,
  suitable_zones = { "diving_spot" },
  is_main_location = true,
  sub_locations = { "^mission:diver_missing_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  difficulty = 4,
  dispersal_area = 500,
  report = "ダイビング中に事故が発生した模様で戻ってこない人がいる. もう1時間以上経っているので捜索してほしい.",
  note = "民間人からの通報",
}, {
  pattern = "^mission:diver_missing_%d+$",
  tracker = "sar",
  case = cases.sar,
  geologic = geologics.waters,
  suitable_zones = { "underwater" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 0,
  report = "行方不明のダイバー",
  note = "",
}, {
  pattern = "^mission:oil_platform_fire_%d+$",
  tracker = "sar",
  case = cases.accident,
  geologic = geologics.waters,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 2000,
  difficulty = 8,
  report = "操業中の事故により海上油田で爆発が発生. 油井が激しく炎上し, もう我々の手には負えない. 我々は脱出を開始しているが救命艇が足りず, 身一つで海へ飛び込んだ者もいる. 早急な救出が必要だ.",
  character_min = 25,
  character_max = 75,
  fire_min = 50,
  fire_max = 100,
  note = "職員からの通報",
}, {
  pattern = "^mission:tunnel_fire_%d+$",
  tracker = "sar",
  case = cases.accident,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = { "^mission:car_collision_%d+$", "^mission:car_stuck_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 500,
  difficulty = 8,
  report = "大型トラックの事故で大火災が発生. トンネルの中が全部燃えていてこのままでは全員焼け死んでしまう!",
  fire_min = 100,
  fire_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:car_collision_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = { "road", "tunnel" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 2,
  report = "スタックした自動車",
  note = "",
}, {
  pattern = "^mission:car_stuck_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = { "road", "tunnel" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 0,
  report = "スタックした自動車",
  note = "",
}, {
  pattern = "^mission:aircraft_down_%d+$",
  tracker = "sar",
  case = cases.mayday,
  geologic = geologics.mainlands,
  suitable_zones = { "field", "mountain" },
  is_main_location = true,
  sub_locations = {},
  sub_location_min = 0,
  sub_location_max = 0,
  dispersal_area = 1000,
  difficulty = 4,
  report = "バラバラになって落ちていく飛行機が見えた!",
  note = "民間人からの通報",
  character_min = 50,
  character_max = 100,
}, {
  pattern = "^mission:marina_fire_%d+$",
  tracker = "sar",
  case = cases.accident,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 8,
  report = "マリーナに係留されているボートから出火して周りの船にも燃え移っている.",
  character_min = 100,
  character_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:campsite_fire_%d+$",
  tracker = "sar",
  case = cases.far,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 500,
  difficulty = 4,
  report = "キャンプ場で火事, 森林火災に発展する可能性が高い. 早急な対応を頼む.",
  character_min = 25,
  character_max = 75,
  note = "キャンプ場からの通報",
}, {
  pattern = "^mission:hostile_forest_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = { "forest", "field", "mountain", "hill" },
  is_main_location = true,
  sub_locations = { "^mission:climber_missing_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 500,
  difficulty = 2,
  report = "危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を駆除せよ.",
  note = "パトロールからの通報",
}, {
  pattern = "^mission:wind_turbine_fire_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.waters,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 4,
  report = "洋上風力発電機のエレベーターが故障, タービン室から降りられず閉じこめられている.",
  note = "パトロールからの通報",
}, {
  pattern = "^mission:hostile_water_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = { "lake", "channel" },
  is_main_location = true,
  sub_locations = { "^mission:boat_sink_%d+$" },
  sub_location_min = 2,
  sub_location_max = 4,
  dispersal_area = 500,
  difficulty = 2,
  report = "危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を駆除せよ.",
  note = "パトロールからの通報",
}, {
  pattern = "^mission:naval_mine_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel", "diving_spot" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 500,
  difficulty = 2,
  report = "付近を航行する船舶から漂流する機雷を発見したとの通報があった. このエリアで機雷を捜索し, 破壊または基地へ輸送せよ.",
  note = "パトロールからの通報",
}, {
  pattern = "^mission:train_crash_head_on$",
  tracker = "sar",
  case = cases.accident,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 4,
  report = "旅客列車が正面衝突し脱線転覆, 多数の負傷者が発生!",
  character_min = 25,
  character_max = 75,
  note = "運転士からの通報",
}, {
  pattern = "^mission:train_crash_log_trailer$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 4,
  report = "旅客列車がトレーラーと衝突し脱線, 負傷者多数. また積荷の丸太が線路に散乱し, 運行不能に陥っている.",
  character_min = 25,
  character_max = 75,
  note = "運転士からの通報",
}, {
  pattern = "^mission:power_plant_fire_%d+$",
  tracker = "sar",
  case = cases.accident,
  geologic = geologics.islands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 8,
  report = "発電所のタービンが発火, 天井にまで燃え広がっている. 数名の職員と連絡がつかず中に取り残されているものと思われる.",
  character_min = 25,
  character_max = 75,
  note = "職員からの通報",
}, {
  pattern = "^mission:chemical_storage_fire_%d+$",
  tracker = "sar",
  case = cases.far,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 4,
  report = "化学物質が保管されている倉庫が炎上している. 不意の爆発には十分注意せよ.",
  character_min = 25,
  character_max = 75,
  note = "職員からの通報",
}, {
  pattern = "^mission:house_fire_%d+$",
  tracker = "sar",
  case = cases.far,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 200,
  difficulty = 2,
  report = "近所の家が燃えている. この家の住民と連絡が取れておらず中に取り残されている可能性がある.",
  character_min = 100,
  character_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:highway_car_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 2,
  report = "高速道路で乗用車が衝突し横転, 本線を塞いでいる.",
  character_min = 100,
  character_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:highway_oil_tanker_%d+$",
  tracker = "sar",
  case = cases.far,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 4,
  report = "高速道路でタンクローリーが横転, 炎上中. 運転手は無事だがインターチェンジを完全に塞いでいる.",
  character_min = 100,
  character_max = 100,
  note = "民間人からの通報",
}, {
  pattern = "^mission:air_medevac_%d+$",
  tracker = "sar",
  case = cases.ems,
  geologic = geologics.mainlands,
  suitable_zones = { "airfield", "heliport" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 2,
  report = "近隣で発生した救急患者をこの空港に搬送する. 引き継いで後送せよ.",
  note = "職員からの通報",
}, {
  pattern = "^mission:visit_cargo_vessel_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "channel" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 100,
  difficulty = 2,
  report = "違法な貨物を輸送している疑いのある船舶が見つかった. 当該船舶は現在この付近を航行していると思われる. 捜索し乗り込んで調査せよ.",
  note = "情報局からの通報",
}, {
  pattern = "^mission:piracy_boat_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "shallow" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 1000,
  difficulty = 2,
  report = "武装した小型船を発見した. 乗員を拘束せよ.",
  character_min = 50,
  character_max = 100,
  note = "哨戒機からの通報",
}, {
  pattern = "^mission:smuggling_boat_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.waters,
  suitable_zones = { "offshore" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 2000,
  difficulty = 2,
  report = "ソーヤー島に違法な貨物を運び込むという情報を掴んだ. 不審な船舶を捜索し, 乗り込んで調査せよ.",
  character_min = 50,
  character_max = 100,
  note = "情報局からの通報",
}, {
  pattern = "^mission:vessel_hijacked_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.waters,
  suitable_zones = { "offshore", "shallow" },
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 1000,
  difficulty = 4,
  report = "この船は我々が乗っ取った! 人質を解放するには ?mission ransom [MissionID] [Amount] (小文字) で身代金 $1,000,000 を振り込んでください.",
  character_min = 50,
  character_max = 100,
  note = "ハイジャッカーからの通報",
}, {
  pattern = "^mission:piracy_infantry_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = { "field", "forest", "airfield", "heliport", "runway", "road", "track", "crossing", "tunnel", "bridge", "house", "building", "wind_turbine", "plant", "wharf", "mine" },
  is_main_location = false,
  sub_locations = { "bunker" },
  difficulty = 2,
  report = "海賊の歩兵",
  note = "",
}, {
  pattern = "^mission:piracy_technical_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = { "bunker" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 2,
  report = "海賊のテクニカル",
  note = "",
}, {
  pattern = "^mission:piracy_static_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = { "bunker" },
  is_main_location = false,
  sub_locations = {},
  difficulty = 2,
  report = "海賊の固定機銃",
  note = "",
}, {
  pattern = "^mission:port_occupied_%d+$",
  tracker = "sar",
  case = cases.securite,
  geologic = geologics.mainlands,
  suitable_zones = {},
  is_main_location = true,
  dispersal_area = 500,
  sub_locations = { "^mission:piracy_infantry_%d+$", "^mission:piracy_static_%d+$", "^mission:piracy_technical_%d+$" },
  sub_location_min = 10,
  sub_location_max = 12,
  difficulty = 4,
  report = "この付近の港が武装勢力に占拠された. 当地は交通の要害であり国民生活への影響は測り知れない. 速やかに武装勢力を排除し安全を確保せよ. 民間人の退避は完了している.",
  note = "警察署からの通報",
}, {
  pattern = "^mission:tornado_alert_%d+$",
  tracker = "disaster",
  case = cases.alert,
  geologic = geologics.mainlands,
  suitable_zones = { "channel", "lake", "ait", "forest", "field", "beach" },
  count = 0,
  save_to_history = false,
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 1000,
  difficulty = 0,
  report = "このエリアで竜巻が発生する可能性が高まっている...",
  note = "気象当局からの通報",
}, {
  pattern = "^mission:whirlpool_alert_%d+$",
  tracker = "disaster",
  case = cases.alert,
  geologic = geologics.waters,
  suitable_zones = { "offshore" },
  count = 0,
  save_to_history = false,
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 1000,
  difficulty = 0,
  report = "このエリアで大渦が発生する可能性が高まっている...",
  note = "気象当局からの通報",
}, {
  pattern = "^mission:meteor_alert_%d+$",
  tracker = "disaster",
  case = cases.alert,
  geologic = geologics.waters,
  suitable_zones = { "offshore" },
  count = 0,
  save_to_history = false,
  is_main_location = true,
  sub_locations = {},
  dispersal_area = 1000,
  difficulty = 0,
  report = "このエリアに隕石の落下が予測されている...",
  note = "気象当局からの通報",
} }

interactions_property = { {
  type = "base",
  mapped = true,
  icon = 11,
}, {
  type = "hospital",
  mapped = true,
  icon = 8,
}, {
  type = "police_station",
  mapped = true,
  icon = 11,
}, {
  type = "scrap_yard",
  mapped = true,
  icon = 3,
}, {
  type = "investigate",
}, {
  type = "first_spawn",
}, {
  type = "respawn",
} }

landscape_properties = { "forest", "hill", "mountain", "volcano", "field", "beach", "ait", "island", "campsite", "offshore", "shallow", "underwater", "channel", "lake", "diving_spot", "airfield", "heliport", "runway", "road", "track", "crossing", "tunnel",
  "bridge", "house", "building", "wind_turbine", "plant", "wharf", "mine", "bunker" }

strings = {
  statuses = {
    objectives = "[目標]",
    objective_item = "%d %sを%s",
    objective_admitted = "%d 収容済み",
    events = "[事象]",
    search_radius = "[範囲]",
    responders = "[対応中]",
    check_in = "(?go %d でチェックイン)",
    remainings = "[有効期間]",
    remaining_item = "この警報は残り%d分間有効.",
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
    meteor = "meteor",
  },
  notice = {
    massive_meteor_impact = "津波警報. 津波警報. 巨大隕石の落下により津波の発生が確実視されている. 早急に高台へ避難せよ.",
    mission_taken_to_long = "協力者によってミッション#%dの残りの行方不明者が発見された.",
  },
  objects = {
    rescuee = "要救助者",
    suspect = "被疑者",
    fire = "火災",
    forest_fire = "森林火災",
    hostile = "危険生物",
    oil_spills = "漏出した油",
    failure = "障害",
    illigal_object = "違法貨物",
    cargo = "貨物",
    wreckage = "残骸",
    picked = "収容済み",
  },
  works = {
    search = {
      rescuee = "治療しHQか病院へ搬送",
      suspect = "制圧しHQか警察署へ連行",
      illigal_object = "検査",
    },
    extinguish = {
      fire = "鎮圧",
      forest_fire = "鎮圧",
    },
    destroy = {
      hostile = "排除",
    },
    remediation = {
      oil_spills = "回収",
      failure = "復旧",
    },
    transportation = {
      cargo = "配送先へ輸送",
      illigal_object = "HQへ輸送",
      wreckage = "HQへ輸送(報酬あり)\nまたは破壊(報酬なし)",
    },
  }
}

objects = {
  rescuee = "rescuee",
  suspect = "suspect",
  fire = "fire",
  forest_fire = "forest_fire",
  hostile = "hostile",
  oil_spill = "oil_spill",
  failure = "failure",
  cargo = "cargo",
  illigal_vehicle = "illigal_object",
  wreckage = "wreckage",
}

works = {
  search = "search",
  extinguish = "extinguish",
  destroy = "destroy",
  remediation = "remediation",
  transportation = "transportation",
}

objectives = { {
  object = objects.rescuee,
  work = works.search,
}, {
  object = objects.suspect,
  work = works.search,
}, {
  object = objects.illigal_vehicle,
  work = works.search,
}, {
  object = objects.fire,
  work = works.extinguish,
}, {
  object = objects.forest_fire,
  work = works.extinguish,
}, {
  object = objects.hostile,
  work = works.destroy,
}, {
  object = objects.oil_spill,
  work = works.remediation,
}, {
  object = objects.failure,
  work = works.remediation,
}, {
  object = objects.cargo,
  work = works.transportation,
}, {
  object = objects.illigal_vehicle,
  work = works.transportation,
}, {
  object = objects.wreckage,
  work = works.transportation,
}, }

weapons = { {
  id = 35,
  slot = 2,
  ammo = 10,
}, {
  id = 37,
  slot = 1,
  ammo = 45,
}, {
  id = 39,
  slot = 1,
  ammo = 30,
} }

stormwoofs = {
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
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

      if reward > 0 then
        local distance = matrix.distance(get_center_transform(), self.locations[1].transform)
        reward = reward + math.ceil(distance / 1000) * 1000 * 2
      end

      return reward
    end,
    report = function(self)
      return string.format("#%d %s\n%s", self.id, self.case.text, self.locations[1].report)
    end,
    status = function(self)
      local text = self.locations[1].note

      text = text .. "\n\n" .. strings.statuses.objectives

      for i = 1, #self.objectives do
        if self.objectives[i].count > 0 then
          text = text .. "\n" .. string.format(strings.statuses.objective_item, self.objectives[i].count, strings.objects[self.objectives[i].object], strings.works[self.objectives[i].work][self.objectives[i].object])

          if self.objectives[i].count_picked > 0 then
            text = text .. "\n" .. string.format(strings.statuses.objective_admitted, self.objectives[i].count_picked)
          end

          if #self.objectives[i].contents > 0 then
            text = text .. "\n("

            for j = 1, #self.objectives[i].contents do
              if j > 1 then
                text = text .. ", "
              end

              text = text .. self.objectives[i].contents[j]
            end

            text = text .. ")"
          end
        end
      end

      if #self.events > 0 then
        text = text .. "\n\n" .. strings.statuses.events

        for i = 1, #self.events do
          text = text .. "\n" .. strings.events[self.events[i]]
        end
      end

      text = text .. "\n\n" .. strings.statuses.search_radius
      text = text .. string.format("\n%dm", self.search_radius)

      text = text .. "\n\n" .. strings.statuses.responders

      local count = 0

      for i = 1, #players.items do
        if g_savedata.players_enroute[players.items[i].steam_id] ~= nil and g_savedata.players_enroute[players.items[i].steam_id] == self.id then
          text = text .. string.format("\n%s", players.items[i].name)
          count = count + 1
        end
      end

      text = text .. "\n" .. string.format(strings.statuses.check_in, self.id)

      return text
    end
  },
  disaster = {
    init = function(self)
      local type = string.match(self.locations[1].name, "^mission:(%w+)_alert_%d+$")
      self.type = type
      self.started = false
      self.start_timer = math.random(7200, 14400)

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
          server.spawnTornado(self.transform)
          console.notify(string.format("Tornado has occurred."))
        elseif self.type == "whirlpool" then
          local magnitude = math.max(math.random() ^ 2, 0.5)
          local s = server.spawnWhirlpool(self.transform, magnitude)

          if s then
            console.notify(string.format("Whirlpool of magnitude %.3f has occurred.", magnitude))
          else
            console.notify("Failed to spawn whirlpool.")
          end
        elseif self.type == "meteor" then
          local magnitude = math.random() ^ 2
          local tsunami = magnitude > 0.75

          if tsunami then
            self.finish_timer = 28800
            self.search_radius = 7500
            self.locations[1].report = strings.notice.massive_meteor_impact
            server.notify(-1, self:report(), self.locations[1].note, 1)
          end

          server.spawnMeteor(self.transform, magnitude, tsunami)
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
      return string.format("#%d %s\n%s", self.id, self.case.text, self.locations[1].report)
    end,
    status = function(self)
      local text = self.locations[1].note
      text = text .. "\n\n" .. strings.statuses.search_radius
      text = text .. "\n" .. string.format("%dm", self.search_radius)
      text = text .. "\n\n" .. strings.statuses.remainings
      text = text .. "\n" .. string.format(strings.statuses.remaining_item, math.ceil(self.finish_timer / 3600))

      return text
    end
  }
}

object_trackers = {
  rescuee = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.rescuee.tracker and type == "character" and tags.tracker == "rescuee"
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
      self.hostage = self.tags.hostage == "true"
      self.activated = false
      self.picked = false

      server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, self.vital.ai)
      server.setCharacterTooltip(self.id, string.format("%s\n\nMission ID: %d\nObject ID: %d", strings.objects.rescuee, self.mission, self.id))
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
        return character_vehicle > 0 and x.tracker == "unit" and x.player_owned and x.id == character_vehicle
      end)
      local vital_update = server.getCharacterData(self.id)
      local is_in_hospital = interactions:is_in_interaction(self.transform, "hospital")
      local is_in_base = interactions:is_in_interaction(self.transform, "base")
      local activated = self.activated or players:is_in_range(self.transform, 500)
      local is_doctor_nearby = is_doctor_nearby(self.transform)
      local is_safe = is_in_hospital or is_doctor_nearby

      if #players.items >= g_savedata.subsystems.rescuee.cpa_recurrence_threshold_players and g_savedata.subsystems.rescuee.cpa_recurrence_rate > 0 and not is_safe then
        if not self.vital.incapacitated and vital_update.incapacitated then
          local weather = server.getWeather(self.transform)
          local weather_factor = math.max(1 + weather.fog * 1, 1 + weather.rain * 4, 1 + weather.snow * 9, 1 + weather.wind * 4, 1 - weather.temp + 1)

          self.is_cpa_recurrent = self.is_cpa_recurrent or
              math.random(0, 99) < g_savedata.subsystems.rescuee.cpa_recurrence_rate * weather_factor

          if self.is_cpa_recurrent then
            self.cpa_count = self.cpa_count + 1
          end
        end

        vital_update.hp = math.max(vital_update.hp - self.cpa_count * 2, 0)
      end

      if g_savedata.subsystems.rescuee.has_strobe and not self.hostage then
        local p = players:is_in_range(self.transform, 250)
        local opt = (self.strobe.opt or p) and not picked
        local ir = (self.strobe.ir or p) and not picked
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

      if is_in_hospital or is_in_base then
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
    fail = function(self)
      return self.vital.dead and self.admitted_time > 120
    end,
    reward = function(self)
      local value = math.ceil(self.reward_base * (math.floor(self.vital.hp / 25) / 4))

      if self.cpa_count >= 2 then
        value = value - self.cpa_count * 500
      end

      return value
    end,
    objectives = function(self)
      return {
        objective(works.search, objects.rescuee, 1, self.picked and 1 or 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 2000,
    marker_type = 1,
    clear_timer = 300
  },
  fire = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.fire.tracker and type == "fire"
    end,
    init = function(self)
      self.is_lit = server.getFireData(self.id)
      self.activated = self.is_lit
      self.explosive = false
      self.magnitude = 0
      self.explosive_timer = 0
      self.cooling_timer = math.random(900, 1800)
    end,
    clear = function(self)
    end,
    load = function(self)
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      self.is_lit = server.getFireData(self.id)
      self.activated = self.activated or self.is_lit

      if self.activated and not self.is_lit then
        self.cooling_timer = math.max(self.cooling_timer - tick, 0)
      end

      if g_savedata.dlcs.weapon then
        local explosive = false

        for i = 1, #g_savedata.missions do
          explosive = explosive or self.is_lit and g_savedata.missions[i].id == self.mission and g_savedata.missions[i].explosive and math.random() < g_savedata.subsystems.fire.rate_explode * 0.001
        end

        if not self.explosive and explosive then
          self.explosive = true
          self.magnitude = math.max(0.25, math.random() * 1.414) ^ 2
          self.explosive_timer = math.random(240, 720)
        end

        if self.explosive then
          self.explosive_timer = math.max(0, self.explosive_timer - tick)

          if self.explosive_timer == 0 then
            explode(self.transform, self.magnitude)
            console.notify(string.format("fire#%d has caused a magnitude %.3f explosion.", self.id, self.magnitude))
            self.explosive = false
          end
        end
      end
    end,
    dispensable = function(self)
      return g_savedata.subsystems.fire.dispensable or not self.activated
    end,
    complete = function(self)
      return self.cooling_timer <= 0
    end,
    fail = function(self)
      return false
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {
        objective(works.extinguish, objects.fire, self.activated and 1 or 0, 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 500,
    marker_type = 5,
    clear_timer = 0
  },
  forest_fire = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.forest_fire.tracker and type == "forest_fire"
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
    fail = function(self)
      return false
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {
        objective(works.extinguish, objects.forest_fire, 1, 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 2500,
    marker_type = 5,
    clear_timer = 0
  },
  suspect = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.suspect.tracker and type == "character" and tags.tracker == "suspect"
    end,
    init = function(self)
      self.vital = server.getCharacterData(self.id)
      self.admitted_time = 0
      self.picked = false
      self.is_in_the_act = false
      self.team = 2
      self.activated = false
      self.illigal = false
      self.neutralized = false
      self.ai_state = 0
      self.destination = nil
      self.target = nil
      self.close_quarters = false
      self.weapon = nil
      self.ransom_paid = false
      server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, true)
      server.setAICharacterTeam(self.id, self.team)
      server.setCharacterTooltip(self.id, string.format("%s\n\nMission ID: %d\nObject ID: %d", strings.objects.suspect, self.mission, self.id))
    end,
    clear = function(self)
    end,
    load = function(self)
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      local character_vehicle = server.getCharacterVehicle(self.id)
      local vital_update = server.getCharacterData(self.id)
      local is_in_police_sta = interactions:is_in_interaction(self.transform, "police_station")
      local is_in_base = interactions:is_in_interaction(self.transform, "base")
      local picked = table.any(g_savedata.objects, function(x)
        return character_vehicle > 0 and x.tracker == "unit" and x.player_owned and x.id == character_vehicle
      end)

      if self.simulated and self.command == nil and players:is_in_range(self.transform, self.invocation_distance) then
        local command = table.random(self.commands)

        if command ~= nil then
          for i = 1, #g_savedata.objects do
            if g_savedata.objects[i].mission == self.mission and g_savedata.objects[i].tracker == self.tracker and g_savedata.objects[i].team == self.team then
              g_savedata.objects[i].command = command
              console.notify(string.format("%s#%d has invoked %s command.", g_savedata.objects[i].type, g_savedata.objects[i].id, g_savedata.objects[i].command))
            end
          end
        end
      end

      if self.simulated and not self.neutralized then
        local unit_closest = nil
        local unit_distance = math.maxinteger
        local player_closest = nil
        local player_distance = math.maxinteger

        for i = 1, #g_savedata.objects do
          if g_savedata.objects[i].tracker == "unit" and g_savedata.objects[i].player_owned then
            local _d = matrix.distance(g_savedata.objects[i].transform, self.transform)

            if _d < 500 and _d < unit_distance then
              unit_distance = _d
              unit_closest = g_savedata.objects[i]
            end
          end
        end

        for i = 1, #players.items do
          local _d = matrix.distance(players.items[i].transform, self.transform)

          if _d <= 500 and _d < player_distance then
            player_distance = _d
            player_closest = players.items[i]
          end
        end

        if self.weapon == nil and self.role == nil and (self.command == "attack" or self.command == "escape") then
          self.weapon = table.random(weapons)
          server.setCharacterItem(self.id, self.weapon.slot, self.weapon.id, false, self.weapon.ammo, 0.0)
        end

        if self.role == "pilot" then
          if self.command == "travel" then
            if self.ai_state == 0 and #self.paths == 0 then
              travel(self, locations:random_offshore(self.transform, 10000, 20000))
            elseif self.ai_state == 0 and #self.paths > 0 and player_distance > 250 then
              follow_path(self)
            elseif self.ai_state >= 1 and player_distance <= 250 then
              pause(self)
            end
          elseif self.command == "escape" then
            if self.ai_state == 0 then
              travel(self, locations:random_offshore(self.transform, 10000, 20000))
              resist(self)
            end
          elseif self.command == "attack" then
            if self.ai_state == 0 and unit_closest ~= nil then
              travel(self, unit_closest.transform)
              resist(self)
            elseif unit_closest ~= nil then
              travel(self, unit_closest.transform)
            end
          end
        else
          if self.command == "attack" or self.command == "escape" then
            if self.role ~= nil and (string.match(self.role, "^gunner%s-%d-$") ~= nil or string.match(self.role, "^designator%s-%d-$") ~= nil) then
              if self.ai_state == 0 then
                self.ai_state = 1
                server.setAIState(self.id, self.ai_state)
                resist(self)
              end
            elseif not self.activated then
              resist(self)
            end

            if self.mounted and self.weapon ~= nil then
              local close_quarters_update = unit_distance < 100 or player_distance < 100

              if close_quarters_update and not self.close_quarters then
                local t = matrix.translation(0, 0.25, 0)
                server.setObjectPos(self.id, matrix.multiply(self.transform, t))
                console.notify(string.format("%s#%d has set close quarter combat.", self.type, self.id))
              elseif not close_quarters_update and self.close_quarters then
                console.log(tostring(self.mount_vehicle))
                local vehicle = table.find(g_savedata.objects, function(x) return x.type == "vehicle" and x.id == self.mount_vehicle end)
                local _d = matrix.distance(vehicle.transform, self.transform)

                if _d <= 50 then
                  server.setSeated(self.id, self.mount_vehicle, self.mount_seat.pos.x, self.mount_seat.pos.y, self.mount_seat.pos.z)
                  console.notify(string.format("%s#%d has set seated.", self.type, self.id))
                end
              end

              self.close_quarters = close_quarters_update
            end

            local target = nil

            if player_closest ~= nil and player_distance <= unit_distance then
              target = player_closest.object_id

              if target ~= self.target then
                server.setAITargetCharacter(self.id, target)
              end
            elseif unit_closest ~= nil then
              target = unit_closest.id

              if target ~= self.target then
                server.setAITargetVehicle(self.id, target)
              end
            end

            self.target = target
          end
        end

        if self.activated and (vital_update.incapacitated or vital_update.dead or self.mounted and self.weapon == nil and character_vehicle == 0) then
          neutralize(self)
        end
      end

      self.activated = self.activated or self.command ~= nil
      self.illigal = self.illigal or self.command == "attack" or self.command == "escape" or has_illigality(self.mission)
      self.picked = picked
      self.vital = vital_update

      if self.illigal and (is_in_base or is_in_police_sta) then
        self.admitted_time = self.admitted_time + tick
      end
    end,
    dispensable = function(self)
      return self.activated and not self.illigal
    end,
    complete = function(self)
      return self.admitted_time > 120
    end,
    fail = function(self)
      return not self.neutralized and self.command == "escape" and not players:is_in_range(self.transform, 2000) or self.vital.dead or self.ransom_paid
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {
        objective(works.search, objects.suspect, self.illigal and 1 or 0, self.picked and 1 or 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 2000,
    marker_type = 1,
    clear_timer = 300
  },
  hostile = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.hostile.tracker and (type == "character" or type == "creature" or type == "animal") and tags.tracker ~= nil and tags.tracker == "hostile"
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
    end,
    clear = function(self)
    end,
    load = function(self)
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      if g_savedata.dlcs.industry and self.simulated and self.target ~= nil then
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
    fail = function(self)
      return false
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {
        objective(works.destroy, objects.hostile, 1, 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 1000,
    marker_type = 6,
    clear_timer = 300
  },
  oil_spill = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.spillage.tracker and type == "oil_spill"
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
    fail = function(self)
      return false
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {
        objective(works.remediation, objects.oil_spill, 1, 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 0,
    marker_type = 2,
    clear_timer = 0
  },
  accessory = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.accessory.tracker and (type == "vehicle" or type == "object") and tags.tracker == "accessory"
    end,
    init = function(self)
      self.completion_timer = 0
      self.initial_transform = server.getVehiclePos(self.id)
      self.indispensable = self.tags.indispensable == "true"
      self.wreckage = self.tags.wreckage == "true"
      self.illigal = self.tags.illigal == "true"
      self.investigated = self.tags.investigated == "true"
      self.investigation_points = {}

      if self.wreckage then
        server.setVehicleTooltip(self.id, string.format("%s\n\nMission ID: %d\nVehicle ID: %d", strings.objects.wreckage, self.mission, self.id))
      elseif self.illigal then
        server.setVehicleTooltip(self.id, string.format("%s\n\nMission ID: %d\nVehicle ID: %d", strings.objects.illigal_object, self.mission, self.id))
      end
    end,
    clear = function(self)
    end,
    load = function(self)
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      if self.illigal and not self.investigated then
        self.investigation_points = interactions:find_all(function(x) return x.type == "investigate" and x.parent_vehicle_id == self.id end)
        local investigated = false
        local illigal = false

        for i = 1, #self.investigation_points do
          investigated = investigated and self.investigation_points[i].investigated
          illigal = illigal or self.investigation_points[i].illigal
        end

        if investigated or illigal then
          self.investigated = true
          self.illigal = illigal
        end
      end

      local x, y, z = matrix.position(self.transform)

      if self.investigated and not self.illigal or (self.illigal or self.wreckage) and interactions:is_in_interaction(self.transform, "scrap_yard") or y <= -20 then
        self.completion_timer = self.completion_timer + tick
      end
    end,
    dispensable = function(self)
      return not self.indispensable and (self.investigated or self.wreckage) and not players:is_in_range(self.transform, 500)
    end,
    complete = function(self)
      return self.completion_timer >= 300
    end,
    fail = function(self)
      return false
    end,
    reward = function(self)
      return math.ceil(self.mass / 1000) * 1000 * self.reward_base
    end,
    objectives = function(self)
      local o = {}

      if self.illigal and not self.investigated then
        table.insert(o, objective(works.search, objects.illigal_vehicle, #self.investigation_points, 0))
      elseif self.illigal and self.investigated then
        table.insert(o, objective(works.transportation, objects.illigal_vehicle, 1, 0, self.name))
      elseif self.wreckage then
        table.insert(o, objective(works.transportation, objects.wreckage, 1, 0, self.name))
      end

      return o
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 5,
    marker_type = 2,
    clear_timer = 3600
  },
  cargo = {
    test_type = function(self, id, type, name, tags)
      return g_savedata.subsystems.cargo.tracker and (type == "vehicle" or type == "object") and tags.tracker == "cargo"
    end,
    init = function(self)
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
    fail = function(self)
      return false
    end,
    reward = function(self)
      return 0
    end,
    objectives = function(self)
      return {
        objective(works.transportation, objects.cargo, 1, 0),
      }
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 10,
    marker_type = 2,
    clear_timer = 3600
  },
  sniffer = {
    test_type = function(self, id, type, name, tags)
      return type == "creature" and tags.tracker == "sniffer"
    end,
    init = function(self, owner_steam_id)
      if string.nil_or_empty(self.name) then
        self.name = tostring(self.id) .. "号"
      end

      self.owner_steam_id = owner_steam_id
      self.vital = server.getObjectData(self.id)
      self.destination = nil
      self.command = nil
      self.search_speed = math.random() + 0.5
      self.search_completion_time = 900 * self.search_speed
      self.search_duration = 0
      server.setAICharacterTeam(self.id, 1)
    end,
    clear = function(self)
    end,
    load = function(self)
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      local vital = server.getObjectData(self.id)

      if not vital.incapacitated and not vital.dead then
        if self.command == "search" and self.destination ~= nil and matrix.distance(self.transform, self.destination) < 50 then
          self.command = nil
          self.destination = nil
        elseif self.command == "search" and self.destination == nil then
          local destination = nil
          local target_distance = math.maxinteger

          for i = 1, #g_savedata.objects do
            if g_savedata.objects[i].tracker == "rescuee" and not g_savedata.objects[i].picked then
              local d = matrix.distance(g_savedata.objects[i].transform, self.transform)

              if d < target_distance then
                target_distance = d
                destination = g_savedata.objects[i].transform
              end
            end
          end

          for i = 1, #interactions.items do
            if interactions.items[i].interaction == "search" then
              local d = matrix.distance(interactions.items.transform, self.transform)

              if d <= 250 and d < target_distance then
                target_distance = d
                destination = interactions.items[i].transform
              end
            end
          end

          if destination ~= nil then
            local noise = matrix.translation(math.random() * target_distance * 0.5, 0, math.random() * target_distance * 0.5)
            self.destination = matrix.multiply(destination, noise)
            server.setCreatureMoveTarget(self.id, self.destination)
          end
        end

        local player = players:find(function(x) return x.steam_id == self.owner_steam_id end)
        local is_investigating = false

        for i = 1, #interactions.items do
          if interactions.items[i].interaction == "investigate" and not interactions.items[i].investigated and interactions:is_in(self.transform, interactions.items[i]) then
            is_investigating = true
            self.search_duration = self.search_duration + tick

            if self.search_duration >= self.search_completion_time then
              local illigality = investigate(interactions.items[i])

              if illigality then
                server.notify(player.id, "ワンワン!", "違法貨物を発見!", 1)
              else
                server.notify(player.id, "ヘッヘッヘッ...", "違法貨物は発見されなかった.", 1)
              end
            end
          end
        end

        if is_investigating then
          server.notify(player.id, "スンスン...", "捜査犬が違法貨物を検査中...", 0)
        end

        if not is_investigating and self.search_duration > 0 then
          self.search_duration = 0
        end
      end

      self.vital = vital
    end,
    dispensable = function(self)
      return false
    end,
    complete = function(self)
      return false
    end,
    fail = function(self)
      return self.vital.dead
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {}
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return true
    end,
    reward_base = 0,
    marker_type = 9,
    clear_timer = 0
  },
  unit = {
    test_type = function(self, id, type, name, tags, owner, cost)
      return type == "vehicle" and (tags.tracker == "unit" or owner ~= nil)
    end,
    init = function(self, owner, cost)
      self.owner_steam_id = owner
      self.player_owned = self.owner_steam_id ~= nil
      self.cost = cost
      self.headquarter = self.tags.headquarter == "true"
      self.components_checked = false
      self.attention = nil
      self.missions = {}
      server.setAIVehicleTeam(self.id, 1)
    end,
    clear = function(self)
    end,
    load = function(self)
      if self.components ~= nil and not self.components_checked then
        self.attention = find_component(self.components.buttons, "attention")

        for i = 1, 5 do
          self.missions[i] = {}
          self.missions[i].id = find_component(self.components.buttons, string.format("mission_%d_id", i))
          self.missions[i].c = find_component(self.components.buttons, string.format("mission_%d_code", i))
          self.missions[i].x = find_component(self.components.buttons, string.format("mission_%d_gpsx", i))
          self.missions[i].y = find_component(self.components.buttons, string.format("mission_%d_gpsy", i))
          self.missions[i].r = find_component(self.components.buttons, string.format("mission_%d_radius", i))
        end

        self.components_checked = true
      end
    end,
    unload = function(self)
    end,
    tick = function(self, tick)
      if self.components_checked and self.headquarter then
        for i = 1, 5 do
          local id = 0
          local x = 0
          local y = 0
          local r = 0
          local c = 0

          if g_savedata.missions[i] ~= nil then
            local _x, _y, _z = matrix.position(g_savedata.missions[i].search_center)
            id = g_savedata.missions[i].id
            x = _x
            y = _z
            r = g_savedata.missions[i].search_radius
            c = g_savedata.missions[i].case.id
          end

          if self.missions[i].id ~= nil then set_vehicle_keypad(self.id, self.missions[i].id, id) end
          if self.missions[i].c ~= nil then set_vehicle_keypad(self.id, self.missions[i].c, c) end
          if self.missions[i].x ~= nil then set_vehicle_keypad(self.id, self.missions[i].x, x) end
          if self.missions[i].y ~= nil then set_vehicle_keypad(self.id, self.missions[i].y, y) end
          if self.missions[i].r ~= nil then set_vehicle_keypad(self.id, self.missions[i].r, r) end
        end
      end
    end,
    dispensable = function(self)
      return false
    end,
    complete = function(self)
      return false
    end,
    fail = function(self)
      return false
    end,
    reward = function(self)
      return self.reward_base
    end,
    objectives = function(self)
      return {}
    end,
    reported = function(self)
      return true
    end,
    mapped = function(self)
      return false
    end,
    reward_base = 0,
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
  else
    patterns[1] = "^mission:.+$"
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
  mission.locations = _locations
  mission.transform = mission.locations[1].transform
  mission.dispersal_area = mission.locations[1].dispersal_area
  mission.tracker = mission.locations[1].tracker
  mission.case = mission.locations[1].case
  mission.count = mission.locations[1].count
  mission.save_to_history = mission.locations[1].save_to_history
  mission.search_center = matrix.identity()
  mission.search_radius = 0
  mission.difficulty = mission.locations[1].difficulty
  mission.reported = false
  mission.report_timer = report_timer or math.random(mission.locations[1].report_timer_min, mission.locations[1].report_timer_max)
  mission.spawned = false
  mission.terminated = false
  mission.elapsed = 0
  mission.activated = false
  mission.taken_to_long = false
  mission.marker_id = server.getMapID()
  mission.rewards = 0
  based(mission, mission_trackers[mission.tracker])
  mission.objectives = aggregate_mission_objectives(mission)
  mission.landscapes = aggregate_mission_landscapes(mission)
  mission.events = aggregate_mission_events(mission)
  mission.explosive = false
  mission:init({ ... })

  if mission.save_to_history then
    record_location_history(mission.locations[1])
  end

  table.insert(g_savedata.missions, mission)
  spawn_mission(mission)
  g_savedata.subsystems.mission.count = g_savedata.subsystems.mission.count + 1

  console.notify(string.format("mission#%d has initialized.", mission.id))
end

function clear_mission(mission)
  for i = #g_savedata.objects, 1, -1 do
    if g_savedata.objects[i].mission == mission.id then
      despawn_object(g_savedata.objects[i])
    end
  end

  server.removeMapID(-1, mission.marker_id)
  mission:clear()
  mission.cleared = true

  console.notify(string.format("mission#%d has cleared.", mission.id))
end

function tick_mission(mission, tick)
  if not mission.activated and players:is_in_range(mission.search_center, mission.search_radius) then
    mission.activated = true
  end

  if mission.activated then
    mission.elapsed = mission.elapsed + tick
  end

  mission.objectives = aggregate_mission_objectives(mission)
  mission.landscapes = aggregate_mission_landscapes(mission)
  mission.events = aggregate_mission_events(mission)
  mission.explosive = has_explosive_event(mission)

  -- if not mission.taken_to_long and mission.elapsed > g_savedata.subsystems.mission.taken_to_long_threshold then
  --   mission.taken_to_long = true
  --   server.notify(-1, string.format(strings.notice.mission_taken_to_long, mission.id), nil, 0)
  --   console.notify(string.format("mission#%d is taking to long.", mission.id))
  -- end

  mission:tick(tick)

  if g_savedata.mode == "debug" or mission.search_center ~= nil and mission.search_radius ~= nil then
    local label = mission:report()
    local label_hover = mission:status()
    local x, y, z = matrix.position(mission.search_center)
    local red = { 255, 0, 255, 255 }
    local yellow = { 255, 255, 0, 255 }

    for i = 1, #players.items do
      if players.items[i].map_opened then
        server.removeMapID(players.items[i].id, mission.marker_id)
        server.addMapObject(players.items[i].id, mission.marker_id, 0, 1, x, z, 0, 0, nil, nil, label, mission.search_radius, label_hover, yellow[1], yellow[2], yellow[3], yellow[4])
      end
    end
  end

  -- mission.report_timer = math.max(mission.report_timer - tick, 0)

  if not mission.reported and mission.report_timer == 0 then
    alert_headquarter()

    local notification_type = 0

    server.notify(-1, mission:report(), mission.locations[1].note, notification_type)
    mission.reported = true
  end

  if mission:complete() or mission.terminated then
    reward_mission(mission)
    clear_mission(mission)
    server.notify(-1, "Mission has cleared.", string.format("mission#%d", mission.id), 4)
  end
end

function spawn_mission(mission)
  local x, y, z, object_count, location_count = 0, 0, 0, 0, #mission.locations

  for i = 1, location_count do
    spawn_location(mission.locations[i], mission.id)
  end

  for i = 1, #g_savedata.objects do
    if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].transform ~= nil then
      local ox, oy, oz = matrix.position(g_savedata.objects[i].transform)
      object_count = object_count + 1
      x = x + ox
      y = y + oy
      z = z + oz
    end
  end

  if object_count > 0 then
    x = x / object_count
    y = y / object_count
    z = z / object_count

    mission.transform = matrix.translation(x, y, z)
  end

  local sub_location_count = math.random(mission.locations[1].sub_location_min, mission.locations[1].sub_location_max)

  for i = 1, sub_location_count do
    local sub_locations = locations:random(mission.transform, 0, mission.dispersal_area, false, false, mission.locations[1].sub_locations, {}, mission.locations)

    for j = 1, #sub_locations do
      table.insert(mission.locations, sub_locations[j])
      spawn_location(sub_locations[j], mission.id)
    end
  end

  local r = math.random() * mission.dispersal_area
  local t = math.random() * 2 * math.pi
  local cx = r * math.cos(t)
  local cy = 0
  local cz = r * math.sin(t)

  mission.search_center = matrix.multiply(mission.transform, matrix.translation(cx, cy, cz))

  local distance_max = 0

  for i = 1, #g_savedata.objects do
    if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].transform ~= nil then
      distance_max = math.max(distance_max, matrix.distance(mission.search_center, g_savedata.objects[i].transform))
    end
  end

  mission.search_radius = math.max(math.ceil(distance_max / 500) * 500, mission.dispersal_area)
  mission.spawned = true

  local tx, ty, tz = matrix.position(mission.transform)
  console.notify(string.format("mission#%d has spawned at %.0f, %.0f, %.0f.", mission.id, tx, ty, tz))
end

function reward_mission(mission)
  local reward = mission:reward()

  transact(reward, string.format("Reward for mission#%d.", mission.id))
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
  local objs_result = {}

  for i = 1, #objectives do
    local obj = {
      object = objectives[i].object,
      work = objectives[i].work,
      count = 0,
      count_picked = 0,
      contents = {}
    }

    for j = 1, #g_savedata.objects do
      if g_savedata.objects[j].mission == mission.id and g_savedata.objects[j].objectives ~= nil then
        local objs_object = g_savedata.objects[j]:objectives()

        for k = 1, #objs_object do
          if obj.object == objs_object[k].object and obj.work == objs_object[k].work then
            obj.count = obj.count + objs_object[k].count
            obj.count_picked = obj.count_picked + objs_object[k].count_picked
            table.insert(obj.contents, objs_object[k].content)
          end
        end
      end
    end

    obj.contents = table.distinct(obj.contents)

    table.insert(objs_result, obj)
  end

  return objs_result
end

function objective(work, object, count, count_picked, content)
  return {
    work = work,
    object = object,
    count = count,
    count_picked = count_picked,
    content = content
  }
end

function has_explosive_event(mission)
  return table.contains(mission.events, "chemical") or table.contains(mission.events, "dust") or table.contains(mission.events, "oil") or table.contains(mission.events, "gas")
end

function has_illigality(mission_id)
  local illigal = false

  for i = 1, #g_savedata.objects do
    illigal = illigal or g_savedata.objects[i].mission == mission_id and (g_savedata.objects[i].tracker == "accessory" and g_savedata.objects[i].investigated and g_savedata.objects[i].illigal) or
        (g_savedata.objects[i].tracker == "suspect" and g_savedata.objects[i].illigal)
  end

  return illigal
end

function get_difficulties()
  local ds = {}
  local dsds = {}
  local min = 0
  local max = 0

  for i = 1, #locations.items do
    min = math.min(min, locations.items[i].difficulty)
    max = math.max(max, locations.items[i].difficulty)
    table.insert(ds, locations.items[i].difficulty)
  end

  ds = table.distinct(ds)
  table.sort(ds)

  for i = 1, #ds do
    if ds[i] > 0 then
      local count = max / ds[i]

      for j = 1, count do
        table.insert(dsds, ds[i])
      end
    end
  end

  return dsds
end

-- objects

function initialize_object(id, type, name, tags, mission_id, location_id, component_id, parent_id, ...)
  local params = { ... }
  local object = {}

  object.id = id
  object.type = type
  object.name = name
  object.tags = tags
  object.marker_id = server.getMapID()
  object.location_id = location_id
  object.component_id = component_id
  object.parent_id = parent_id
  object.mission = mission_id
  object.loaded = false
  object.simulated = false
  object.completed = false
  object.failed = false
  object.cleared = false
  object.elapsed_clear = 0
  object.transform = position(object)
  object.tracker = nil
  object.follow = false
  object.paths = {}
  object.mounted = false
  object.mount_vehicle = nil
  object.mount_seat = nil
  object.team = 0
  object.role = nil
  object.commands = {}
  object.voxels = nil
  object.mass = nil
  object.components = nil
  object.damage_total = 0
  object.damages = {}
  object.explosive = object.tags.explosive == "true"
  object.invulnerability_timer = 0

  if object.tags.commands ~= nil then
    object.commands = string.split(object.tags.commands, ";")
  end

  object.invocation_distance = tonumber(object.tags.invocation_distance) or 100

  local tracker = nil

  for k, v in pairs(object_trackers) do
    if v.test_type(nil, id, type, name, tags, table.unpack(params)) then
      tracker = k
      break
    end
  end

  if object.type == "character" and object.tags.mount ~= nil then
    local cid = tonumber(object.tags.mount)
    local v = table.find(g_savedata.objects, function(x)
      return x.type == "vehicle" and x.mission == mission_id and x.location_id == location_id and x.component_id == cid
    end)

    if v ~= nil then
      object.mount_vehicle = v.id
    end
  end

  if object.type == "vehicle" and object.tags.keep_active == "true" then
    server.setVehicleTransponder(object.id, true)
  end

  if tracker ~= nil then
    track_object(object, tracker, params)
  end

  if object.tags.oil_spill ~= nil then
    local oil_spill = tonumber(object.tags.oil_spill)

    if oil_spill ~= nil then
      server.setOilSpill(object.transform, oil_spill)
    end
  end

  table.insert(g_savedata.objects, object)
  console.notify(string.format("%s#%d has initialized.", object.type, object.id))
end

function track_object(object, tracker, params)
  object.tracker = tracker
  based(object, object_trackers[tracker])
  object:init(table.unpack(params))
end

function clear_object(object)
  if object.tracker ~= nil then
    object:clear()
  end

  server.removeMapID(-1, object.marker_id)

  object.cleared = true
  console.notify(string.format("%s#%d has cleared.", object.type, object.id))
end

function despawn_object(object)
  if is_vehicle(object) then
    server.despawnVehicle(object.id, true)
  elseif is_object(object) then
    server.despawnObject(object.id, true)
  end

  clear_object(object)
end

function tick_object(object, tick)
  object.transform = position(object)

  if is_object(object) then
    object.simulated = server.getObjectSimulating(object.id)
  elseif is_vehicle(object) then
    object.simulated = server.getVehicleSimulating(object.id)
  end

  if object.simulated and object.type == "character" then
    if object.mount_vehicle ~= nil and not object.mounted then
      object.mounted = mount_vehicle(object)
    end

    if #object.paths > 0 and object.ai_state > 0 then
      if matrix.distance(object.transform, object.paths[1]) <= 100 then
        pass_path(object)
      end

      if not object.follow then
        follow_path(object)
      end
    end
  end

  if object.simulated and is_vehicle(object) and object.explosive then
    local damages_density = {}

    for i = 1, #object.damages do
      object.damage_total = object.damage_total + object.damages[i].amount
      local x, y, z = matrix.position(object.damages[i].transform)
      x = math.round(x / 20) * 20
      y = math.round(y / 20) * 20
      z = math.round(z / 20) * 20
      local key = string.format("%+.0f%+.0f%+.0f", x, y, z)

      if damages_density[key] == nil then
        local tl = matrix.translation(x, y, z)
        damages_density[key] = {
          transform = matrix.multiply(object.transform, tl),
          transform_local = tl,
          amount = 0
        }
      end

      damages_density[key].amount = damages_density[key].amount + object.damages[i].amount
    end

    for key, damage in pairs(damages_density) do
      if damage.amount >= 25 then
        for i = 1, #g_savedata.objects do
          if g_savedata.objects[i].tracker == "fire" and not g_savedata.objects[i].activated and matrix.distance(g_savedata.objects[i].transform, damage.transform) <= 10 then
            g_savedata.objects[i].explosive = true
            g_savedata.objects[i].magnitude = math.random() ^ 2 + 1
            server.setFireData(g_savedata.objects[i].id, true, false)
            console.notify(string.format("%s#%d has ignited by %d damage.", g_savedata.objects[i].type, g_savedata.objects[i].id, damage.amount))
          end
        end
      elseif damage.amount >= 10 then
        for i = 1, #g_savedata.objects do
          if g_savedata.objects[i].tracker == "fire" and not g_savedata.objects[i].activated and matrix.distance(g_savedata.objects[i].transform, damage.transform) <= 2 then
            server.setFireData(g_savedata.objects[i].id, true, false)
            console.notify(string.format("%s#%d has ignited by %d damage.", g_savedata.objects[i].type, g_savedata.objects[i].id, damage.amount))
          end
        end
      end
    end

    object.damages = {}
  end

  if object.simulated and is_vehicle(object) and object.invulnerability_timer > 0 then
    object.invulnerability_timer = math.max(object.invulnerability_timer - tick, 0)

    if object.invulnerability_timer == 0 then
      server.setVehicleInvulnerable(object.id, false)
      console.notify(string.format("%s#%d invulnerability has released.", object.type, object.id))
    end
  end

  if object.tracker ~= nil then
    object:tick(tick)

    server.removeMapID(-1, object.marker_id)

    if g_savedata.mode == "debug" or object.tracker ~= nil and object:mapped() then
      local x, y, z = matrix.position(object.transform)
      local r, g, b, a = 128, 128, 128, 255
      local label = string.format("%s#%d", object.tracker ~= nil and object.tracker or object.type, object.id)
      local popup = string.format("X: %.0f\nY: %.0f\nZ: %.0f", x, y, z)

      server.addMapObject(-1, object.marker_id, 0, object.marker_type, x, z, 0, 0, nil, nil, label, 0, popup, r, g, b, a)
    end

    if not object.failed and object:fail() then
      object.failed = true
      server.notify(-1, "Objective has lost.", object.tracker, 2)
    end

    if not object.failed and not object.completed and object:complete() then
      reward_object(object)
      server.notify(-1, "Objective has achieved.", object.tracker, 4)
      object.completed = true
    end

    if object.completed or object.failed then
      if object.elapsed_clear >= object.clear_timer then
        despawn_object(object)
      end

      object.elapsed_clear = object.elapsed_clear + tick
    end
  end
end

function reward_object(object)
  local reward = object:reward()

  if object.mission ~= nil then
    for j = 1, #g_savedata.missions do
      if g_savedata.missions[j].id == object.mission then
        g_savedata.missions[j].rewards = g_savedata.missions[j].rewards + reward
      end
    end
  end

  transact(reward, "Objective has achieved.")
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

function spawn_sniffer(owner_steam_id, transform, name, size)
  if size == nil then
    size = math.random() + 0.5
  end

  local id = server.spawnCreature(transform, table.random(stormwoofs), size)
  initialize_object(id, "creature", name, { tracker = "sniffer" }, nil, nil, nil, nil, owner_steam_id)
end

function loaded_object(object)
  object.loaded = true

  if is_vehicle(object) then
    local data, s = server.getVehicleComponents(object.id)

    if not s then return end

    object.voxels = data.voxels
    object.mass = data.mass
    object.components = data.components

    for i = 1, #object.components.signs do
      local tags = string.parse_tags(object.components.signs[i].name)

      if tags.damage ~= nil and tags.radius ~= nil then
        local damage = tonumber(tags.damage)
        local radius = tonumber(tags.radius)
        server.addDamage(object.id, damage, object.components.signs[i].pos.x, object.components.signs[i].pos.y,
          object.components.signs[i].pos.z, radius)
      end
    end
  end

  if object.tracker ~= nil then
    object:load()
  end

  console.notify(string.format("%s#%d has loaded.", object.type, object.id))
end

function unloaded_object(object)
  object.loaded = false

  if object.tracker ~= nil then
    object:unload()
  end

  console.notify(string.format("%s#%d has unloaded.", object.type, object.id))
end

function damaged_vehicle(vehicle, amount, x, y, z, body_index)
  table.insert(vehicle.damages, {
    amount = amount,
    transform = matrix.translation(x, y, z),
    body_index = body_index
  })
end

function explode(transform, magnitude)
  for i = 1, #g_savedata.objects do
    if is_vehicle(g_savedata.objects[i]) and g_savedata.objects.tracker ~= "unit" and matrix.distance(g_savedata.objects[i].transform, transform) <= 25 then
      set_invulnerable(g_savedata.objects[i], 120)
    end
  end

  server.spawnExplosion(transform, magnitude)

  -- for i = 1, #vehicles do
  --   server.setVehicleInvulnerable(vehicles[i], false)
  -- end
end

function set_invulnerable(object, timer)
  server.setVehicleInvulnerable(object.id, true)
  object.invulnerability_timer = timer
end

function is_doctor_nearby(transform)
  local is = false

  for i = 1, #g_savedata.objects do
    is = is or
        g_savedata.objects[i].tracker == "doctor" and matrix.distance(transform, g_savedata.objects[i].transform) <= 10
  end

  return is
end

function position(object)
  if is_vehicle(object) then
    return server.getVehiclePos(object.id)
  elseif is_object(object) then
    return server.getObjectPos(object.id)
  elseif object.transform ~= nil then
    return object.transform
  else
    return nil
  end
end

function is_headquarter(object)
  return object.tracker == "unit" and object.type == "vehicle" and object.headquarter
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

function mount_vehicle(object)
  local vehicle = table.find(g_savedata.objects, function(x) return x.type == "vehicle" and x.id == object.mount_vehicle end)

  if vehicle == nil or vehicle.components == nil then
    return false
  end

  local priority_seats = { "^pilot$", "^driver$", "^designator%s-%d-$", "^gunner%s-%d-$" }
  local i_end = #priority_seats + 1

  for i = 1, i_end do
    for j = 1, #vehicle.components.seats do
      local seat_name = string.lower(vehicle.components.seats[j].name)

      if vehicle.components.seats[j].seated_id >= 4294967295 and (i == i_end or string.match(seat_name, priority_seats[i])) then
        server.setSeated(object.id, vehicle.id, vehicle.components.seats[j].pos.x, vehicle.components.seats[j].pos.y, vehicle.components.seats[j].pos.z)
        vehicle.components.seats[j].seated_id = object.id
        object.mount_seat = vehicle.components.seats[j]

        if i < i_end then
          object.role = seat_name
        end

        console.notify(string.format("%s#%d has mounted to %s#%d.", object.type, object.id, vehicle.type, vehicle.id))

        return true
      end
    end
  end

  return false
end

function travel(object, destination)
  object.destination = destination
  object.paths = pathfind(object.transform, object.destination, "ocean_path", "")
  follow_path(object)
end

function follow_path(object)
  object.follow = true
  object.ai_state = 1
  server.setAITarget(object.id, object.paths[1])
  server.setAIState(object.id, object.ai_state)
  local x, y, z = matrix.position(object.paths[1])
  console.notify(string.format("%s#%d has set destination to %.0f, %.0f, %.0f.", object.tracker, object.id, x, y, z))
end

function pass_path(object)
  table.remove(object.paths, 1)
  object.follow = false
  console.notify(string.format("%s#%d has arrived to destination.", object.tracker, object.id))
end

function pause(object)
  object.ai_state = 0
  server.setAIState(object.id, object.ai_state)
  console.notify(string.format("%s#%d has momentary paused.", object.tracker, object.id))
end

function resist(object)
  server.setAICharacterTargetTeam(object.id, 1, true)
  console.notify(string.format("%s#%d has resisted.", object.tracker, object.id))
end

function neutralize(object)
  object.neutralized = true
  object.ai_state = 0
  server.setAIState(object.id, object.ai_state)
  server.setAICharacterTargetTeam(object.id, 1, false)
  server.setCharacterItem(object.id, 9, 23, false, 1, 100)

  if object.weapon ~= nil then
    server.setCharacterItem(object.id, object.weapon.slot, 0, false, 0, 0.0)
  end

  console.notify(string.format("%s#%d has neutralized.", object.type, object.id))
end

function wreck_players_vehicle(player)
  local vehicles = table.find_all(g_savedata.objects, function(x)
    return x.owner_steam_id == player.steam_id
  end)
  local cost = 0

  for i = 1, #vehicles do
    cost = cost - math.ceil(vehicles[i].mass * 5)
    server.despawnVehicle(vehicles[i].id, true)
  end

  transact(cost, string.format("%s's vehicles has wrecked.", player.name))
end

function find_component(components, name)
  return table.find(components, function(t)
    return string.lower(t.name) == name
  end)
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
    obj.case = prop.case or nil
    obj.geologic = prop.geologic or nil
    obj.spawnable = prop.spawnable or (function() return true end)
    obj.count = prop.count or 1
    obj.save_to_history = prop.save_to_history or true
    obj.suitable_zones = prop.suitable_zones or {}

    if prop.is_main_location ~= nil then
      obj.is_main_location = prop.is_main_location
    else
      obj.is_main_location = true
    end

    obj.sub_locations = prop.sub_locations or {}
    obj.sub_location_min = prop.sub_location_min or 0
    obj.sub_location_max = prop.sub_location_max or 0
    obj.dispersal_area = prop.dispersal_area or 0
    obj.difficulty = prop.difficulty or 0
    obj.report = prop.report or ""
    obj.report_timer_min = prop.report_timer_min or 0
    obj.report_timer_max = prop.report_timer_max or 0
    obj.character_min = prop.character_min or 100
    obj.character_max = prop.character_max or 100
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
  is_match = function(self, location, pattern)
    return string.match(location.name, pattern) ~= nil
  end,
  is_match_multipattern = function(self, location, patterns)
    local is = false

    for i = 1, #patterns do
      is = is or self:is_match(location, patterns[i])
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
      is = is and g_savedata.locations_history[i][g_savedata.location_comparer] ~= location
          [g_savedata.location_comparer]
    end

    return is
  end,
  is_suitable = function(self, location, center, range_min, range_max)
    local is = false

    if location.tile == "" then
      for i = 1, #landscapes.items do
        is = is or landscapes:is_suitable(landscapes.items[i], location, center, range_min, range_max)
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
    local noise_rotation_y = matrix.rotationY(math.random() * 2 * math.pi)
    transform = matrix.multiply(transform, noise)
    transform = matrix.multiply(transform, noise_rotation_y)

    return transform, s
  end,
  random = function(self, center, range_min, range_max, is_main, is_unprecedented, patterns, ls, sibling_locations)
    local result = {}

    if patterns == nil then
      patterns = {}
    end

    if ls == nil then
      ls = {}
    end

    if sibling_locations == nil then
      sibling_locations = {}
    end

    local _locations = table.find_all(self.items, function(x)
      return (#patterns == 0 or self:is_match_multipattern(x, patterns))
          and (not is_main or x.is_main_location and (x.difficulty == g_savedata.subsystems.mission.difficulty or x.difficulty == 0))
          and
          (g_savedata.subsystems.mission.geologic.waters and x.geologic == geologics.waters or g_savedata.subsystems.mission.geologic.mainlands and x.geologic == geologics.mainlands or g_savedata.subsystems.mission.geologic.islands and x.geologic == geologics.islands)
          and self:is_suitable(x, center, range_min, range_max)
          and (not is_main or not is_unprecedented or self:is_unprecedented(x))
          and x.spawnable()
    end)

    if #_locations == 0 then
      local text = "No locations has matchd your conditions were found: "

      for i = 1, #patterns do
        if i > 1 then
          text = text .. ", "
        end

        text = text .. patterns[i]
      end

      console.error(text)
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
        local _zones = landscapes:find_all(function(x)
          return landscapes:is_suitable(x, _locations[i], center, range_min, range_max)
              and (not is_main or not landscapes:is_in_another_mission(x, _locations[i].dispersal_area))
              and not landscapes:is_occupied(x, result)
              and not landscapes:is_occupied(x, sibling_locations)
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
          range_max = _locations[i].dispersal_area
        end
      else
        console.error(string.format(
          "Although locations matching your conditions were found, no landscapes were found for them: %s", _locations[i].name))
      end
    end

    return result
  end,
  list = function(self, peer_id)
    for i = 1, #self.items do
      server.announce("[Mission Foundation]", self.items[i].name, peer_id)
    end

    server.announce("[Mission Foundation]", string.format("%d locations", #self.items), peer_id)
  end
}

function spawn_location(location, mission_id)
  g_savedata.locations_count = g_savedata.locations_count + 1
  local location_id = g_savedata.locations_count
  local vehicles = {}
  local characters = {}
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
      elseif data.type == "character" then
        table.insert(characters, data)
      elseif data.type == "fire" then
        table.insert(fires, data)
      else
        table.insert(others, data)
      end
    end
  end

  for i = 1, #vehicles do
    spawn_component(vehicles[i], location.transform, mission_id, location_id)
  end

  local characters_limit = math.ceil(#characters * math.random(location.character_min, location.character_max) / 100)
  table.shuffle(characters)

  for i = 1, characters_limit do
    spawn_component(characters[i], location.transform, mission_id, location_id)
  end

  local fires_limit = math.ceil(#fires * math.random(location.fire_min, location.fire_max) / 100)
  table.shuffle(fires)

  for i = 1, fires_limit do
    spawn_component(fires[i], location.transform, mission_id, location_id)
  end

  for i = 1, #others do
    spawn_component(others[i], location.transform, mission_id, location_id)
  end
end

function spawn_component(component, transform, mission_id, location_id)
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
      initialize_object(object.vehicle_ids[i], object.type, object.display_name, tags, mission_id, location_id, component.id, parent_object_id)
    end
  else
    initialize_object(object.id, object.type, object.display_name, tags, mission_id, location_id, component.id, parent_object_id)
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

-- landscapes

landscapes = {
  items = {},
  load = function(self)
    local raws = server.getZones()
    local models = {}

    for i = 1, #raws do
      local z = self:init(raws[i])

      if z ~= nil then
        table.insert(models, z)
      end
    end

    return models
  end,
  init = function(self, obj)
    local tags = string.parse_tags(obj.tags_full)

    if tags.landscape == nil then return nil end
    if not table.contains(landscape_properties, tags.landscape) then return nil end

    obj.tags = tags
    obj.landscape = obj.tags.landscape
    obj.icon = 1

    return obj
  end,
  refresh = function(self)
    self.items = self:load()
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
      is = is or
          matrix.distance(g_savedata.missions[i].search_center, zone.transform) <=
          g_savedata.missions[i].dispersal_area + clearance
    end

    return is
  end,
  is_suitable = function(self, zone, location, center, range_min, range_max)
    return self:is_in_range(zone, center, range_min, range_max) and
        table.contains(location.suitable_zones, zone.landscape)
  end,
  find = function(self, test)
    return table.find(self.items, test)
  end,
  find_all = function(self, test)
    return table.find_all(self.items, test)
  end,
  map_all = function(self, peer_id)
    for i = 1, #self.items do
      self:map(self.items[i], peer_id)
    end
  end,
  map = function(self, zone, peer_id)
    local peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
      local x, y, z = matrix.position(zone.transform)
      local color = zone.icon == 8 and 255 or 0
      local name = zone.name

      if name == "" then
        name = zone.landscape
      end

      server.addMapLabel(peer_id, g_savedata.subsystems.mapping.landscape.markar_id, zone.icon, zone.landscape, x, z, color, color, color, 255)
    end
  end,
  clear_map_all = function(self, peer_id)
    local peer_id = peer_id or -1
    server.removeMapID(peer_id, g_savedata.subsystems.mapping.landscape.markar_id)
  end
}

-- interactions

interactions = {
  items = {},
  load = function(self)
    local models = {}

    for i = 1, #interactions_property do
      if interactions_property[i].type ~= nil then
        local raws = server.getZones(string.format("interaction=%s", interactions_property[i].type))

        for i = 1, #raws do
          local z = self:init(raws[i])

          if z ~= nil then
            table.insert(models, z)
          end
        end
      end
    end

    return models
  end,
  init = function(self, obj)
    obj.tags = string.parse_tags(obj.tags_full)

    local prop = table.find(interactions_property, function(x)
      return x.type == obj.tags.interaction
    end)

    if prop == nil then
      return nil
    end

    obj.type = prop.type
    obj.mapped = prop.mapped or false
    obj.icon = prop.icon or 1
    obj.interaction = obj.tags.interaction

    if obj.type == "investigate" then
      local investigation = table.find(g_savedata.investigation_points, function(x) return x.vehicle_id == obj.parent_vehicle_id and x.name == obj.name end)

      obj.investigated = investigation ~= nil
      obj.illigal = obj.investigated and investigation.illigal
    end

    return obj
  end,
  refresh = function(self)
    for j = 1, #players.items do
      if players.items[j].map_opened then
        self:clear_map_all(players.items[j].id)
      end
    end

    self.items = self:load()

    for j = 1, #players.items do
      if players.items[j].map_opened then
        self:map_all(players.items[j].id)
      end
    end
  end,
  is_in_interaction = function(self, transform, type)
    local is = false

    for i = 1, #self.items do
      is = is or self.items[i].type == type and self:is_in(transform, self.items[i])
    end

    return is
  end,
  is_in = function(self, transform, zone, name)
    return server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z)
  end,
  is_in_range = function(self, zone, center, min, max)
    local d = matrix.distance(zone.transform, center)
    return d >= min and d <= max
  end,
  find = function(self, test)
    return table.find(self.items, test)
  end,
  find_all = function(self, test)
    return table.find_all(self.items, test)
  end,
  map_all = function(self, peer_id)
    for i = 1, #self.items do
      self:map(self.items[i], peer_id)
    end
  end,
  map = function(self, zone, peer_id)
    local peer_id = peer_id or -1

    if g_savedata.mode == "debug" or zone.mapped and zone.parent_vehicle_id == 0 then
      local x, y, z = matrix.position(zone.transform)
      local color = zone.icon == 8 and 255 or 0
      local name = zone.name

      if g_savedata.mode == "debug" and string.nil_or_empty(name) then
        name = zone.type
      end

      server.addMapLabel(peer_id, g_savedata.subsystems.mapping.interaction.markar_id, zone.icon, name, x, z, color, color, color, 255)
    end
  end,
  clear_map_all = function(self, peer_id)
    local peer_id = peer_id or -1
    server.removeMapID(peer_id, g_savedata.subsystems.mapping.interaction.markar_id)
  end
}

function investigate(zone)
  local illigal = math.random(0, 99) < 50
  table.insert(g_savedata.investigation_points, {
    vehicle_id = zone.parent_vehicle_id,
    name = zone.name,
    illigal = illigal,
  })
  return illigal
end

-- headquarter

function alert_headquarter()
  for i = 1, #g_savedata.objects do
    if is_headquarter(g_savedata.objects[i]) and g_savedata.objects[i].attention ~= nil then
      press_vehicle_button(g_savedata.objects[i].id, g_savedata.objects[i].attention)
      console.notify(string.format("%s#%d has received an attention.", g_savedata.objects[i].type, g_savedata.objects[i].id))
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

function transact(amount, message)
  local inf = server.getGameSettings().infinite_money
  -- if server.getGameSettings().infinite_money then
  --   return true
  -- end

  if amount == 0 then
    return true
  end

  local money = server.getCurrency() + amount

  if not inf and money < 0 then
    server.notify(-1, "Payment failed.", "Your account balance is insufficient.", 2)
    return false
  end

  local not_type = 4
  local title = string.format("Accepted $%d", amount)

  if amount < 0 then
    not_type = 2
    text = string.format("Paid out $%d", math.abs(amount))
  end

  server.setCurrency(money)
  server.notify(-1, title, message, not_type)

  return true
end

-- spawn point

function teleport_to_spawn_points(peer_id)
  local _zones = interactions:find_all(function(x)
    return interactions:is_in_range(x, get_start_tile_transform(), 0, g_savedata.subsystems.mission.range_max) and
        x.type == "respawn"
  end)

  if #_zones == 0 then
    console.error("Respawn points were not found.")
  end
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

    player.object_id, s = server.getPlayerCharacterID(player.id)

    if not s then
      return nil
    end

    player.steam_id = tostring(player.steam_id)
    player.transform = get_player_transform(player.id)
    player.vehicle_id = server.getCharacterVehicle(player.object_id)
    player.map_opened = g_savedata.players_map[player.id]
    player.vital = server.getObjectData(player.object_id)

    return player
  end,
  refresh = function(self)
    self.items = self:load()

    for i = 1, #self.items do
      if g_savedata.players_alert[self.items[i].steam_id] == nil then
        g_savedata.players_alert[self.items[i].steam_id] = { strobe = false, transponder = false }
      end

      local transponder = self.items[i].vital.incapacitated
      local strobe = transponder
      local explosive = false

      for j = 1, #g_savedata.missions do
        strobe = strobe or g_savedata.missions[j].tracker == "disaster" and matrix.distance(g_savedata.missions[j].search_center, self.items[i].transform) <= g_savedata.missions[j].search_radius
      end

      -- for j = 1, #g_savedata.objects do
      --   strobe = strobe or g_savedata.objects[j].tracker == "fire" and g_savedata.objects[j].explosive and matrix.distance(g_savedata.objects[j].transform, self.items[i].transform) <= 20
      -- end

      for j = 1, 10 do
        local item = server.getCharacterItem(self.items[i].object_id, j)

        if item == 23 and g_savedata.players_alert[self.items[i].steam_id].strobe ~= strobe then
          g_savedata.players_alert[self.items[i].steam_id].strobe = strobe
          server.setCharacterItem(self.items[i].object_id, j, 23, strobe, 0, 100)

          if strobe then
            console.notify(string.format("%s's strobe has activated.", self.items[i].name))
          end
        elseif item == 25 and g_savedata.players_alert[self.items[i].steam_id].transponder ~= transponder then
          g_savedata.players_alert[self.items[i].steam_id].transponder = transponder
          server.setCharacterItem(self.items[i].object_id, j, 25, transponder, 0, 100)

          if transponder then
            console.notify(string.format("%s's transponder has activated.", self.items[i].name))
          end
        end
      end
    end
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
  end
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
    interactions:refresh()
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

  if g_savedata.subsystems.mission.timer_tickrate > 0 and (not g_savedata.subsystems.mission.count_limited or missions_less_than_limit()) then
    if g_savedata.subsystems.mission.interval <= 0 then
      random_mission(get_center_transform(), g_savedata.subsystems.mission.range_max, g_savedata.subsystems.mission.range_min)
      g_savedata.subsystems.mission.interval = math.random(1, 5) * 3600
    else
      g_savedata.subsystems.mission.interval = g_savedata.subsystems.mission.interval - tick * g_savedata.subsystems.mission.timer_tickrate
    end
  end

  if g_savedata.subsystems.mission.difficulty_remaining <= 0 then
    g_savedata.subsystems.mission.difficulty_remaining = math.random(g_savedata.subsystems.mission.difficulty_remaining_min, g_savedata.subsystems.mission.difficulty_remaining_max)
    g_savedata.subsystems.mission.difficulty = table.random(get_difficulties())
    console.notify(string.format("Difficulty has changed to %d.", g_savedata.subsystems.mission.difficulty))
  else
    g_savedata.subsystems.mission.difficulty_remaining = g_savedata.subsystems.mission.difficulty_remaining - tick * g_savedata.subsystems.mission.timer_tickrate
  end

  timing = timing + 1

  if timing >= cycle then
    timing = 0
  end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
  command = string.lower(command)

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
      local center = get_center_transform()
      local location = ...

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
      local value = ...
      g_savedata.subsystems.mission.count_limited = set_or_not(g_savedata.subsystems.mission.count_limited, value)
    elseif verb == "range-min" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.range_min = value
      else
        console.log(g_savedata.subsystems.mission.range_min, peer_id)
      end
    elseif verb == "range-max" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.range_max = value
      else
        console.log(g_savedata.subsystems.mission.range_max, peer_id)
      end
    elseif verb == "limit-area" and is_admin then
      local value = ...
      g_savedata.subsystems.mission.area_limited = set_or_not(g_savedata.subsystems.mission.area_limited, value)
    elseif verb == "area-x-min" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.area_x_min = value
      end
    elseif verb == "area-x-max" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.area_x_max = value
      end
    elseif verb == "area-y-min" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.area_y_min = value
      end
    elseif verb == "area-y-max" and is_admin then
      local value = ...
      value = tonumber(value)

      if value ~= nil then
        g_savedata.subsystems.mission.area_y_max = value
      end
    elseif verb == "geologic" and is_admin then
      local geo, value = ...
      local keys = table.keys(g_savedata.subsystems.mission.geologic)

      if geo == nil then
        console.log(string.format("subsystems.mission.geologic.waters: %s", g_savedata.subsystems.mission.geologic.waters))
        console.log(string.format("subsystems.mission.geologic.islands: %s", g_savedata.subsystems.mission.geologic.islands))
        console.log(string.format("subsystems.mission.geologic.mainlands: %s", g_savedata.subsystems.mission.geologic.mainlands))
      elseif table.contains(keys, geo) then
        g_savedata.subsystems.mission.geologic[geo] = set_or_not(g_savedata.subsystems.mission.geologic[geo], value)
      end
    elseif verb == "tracker" and is_admin then
      local obj, value = ...

      if obj == nil or g_savedata.subsystems[obj] == nil then return end

      g_savedata.subsystems[obj].tracker = set_or_not(g_savedata.subsystems[obj].tracker, value)
    elseif verb == "recurrent-cpa" and is_admin then
      local value = ...
      value = tonumber(value)

      if value == nil then return end

      g_savedata.subsystems.rescuee.cpa_recurrence_rate = value
    elseif verb == "gather" and is_admin then
      local mission_id = ...
      mission_id = tonumber(mission_id)
      local transform, is_success = server.getPlayerPos(peer_id)

      for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].type == "character" and g_savedata.objects[i].mission == mission_id then
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
    elseif verb == "ransom" and is_auth then
      local mission, amount = ...
      mission = tonumber(mission)
      amount = tonumber(amount)
      local has_hostage = false

      if mission == nil or amount == nil or amount < 1000000 then
        return
      end

      for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "rescuee" and g_savedata.objects[i].hostage then
          has_hostage = true
        end
      end

      if not has_hostage then
        return
      end

      if transact(amount * -1, string.format("Paid out the ransom for mission#$d.", mission)) then
        for i = 1, #g_savedata.objects do
          if g_savedata.objects[i].tracker == "rescuee" and g_savedata.objects[i].hostage then
            g_savedata.objects[i].hostage = false
          elseif g_savedata.objects[i].tracker == "suspect" then
            g_savedata.objects[i].ransom_paid = true
          end
        end
      end
    end
  elseif command == "?hq" and is_admin then
    if verb == "register" then
      local vehicle_id = ...
      vehicle_id = tonumber(vehicle_id)

      if vehicle_id == nil then return end

      local vehicle = table.find(g_savedata.objects, function(v) return v.type == "vehicle" and v.id == vehicle_id end)

      if vehicle == nil then return end

      vehicle.headquarter = true
      console.notify(string.format("%s#%d has registered as headquarter.", vehicle.type, vehicle.id))
    elseif verb == "delete" then
      local vehicle_id = ...
      vehicle_id = tonumber(vehicle_id)

      if vehicle_id == nil then return end

      local vehicle = table.find(g_savedata.objects, function(v) return v.type == "vehicle" and v.id == vehicle_id end)

      if vehicle == nil then return end

      vehicle.headquarter = false
      console.notify(string.format("%s#%d has deleted from headquarter.", vehicle.type, vehicle.id))
    elseif verb == "list" then
      for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "unit" and g_savedata.objects[i].headquarter then
          console.log(string.format("%s#%d %s", g_savedata.objects[i].type, g_savedata.objects[i].id, g_savedata.objects[i].name))
        end
      end
    end
  elseif (command == "?sniffer" or command == "?s") and is_admin then
    if verb == "init" then
      local name = ...
      local player = players:find(function(x) return x.id == peer_id end)
      local transform = get_player_transform(peer_id)
      spawn_sniffer(player.steam_id, transform, name)
      transact(-2000, string.format("%s has bought a new sniffer.", player.name))
    elseif verb == "search" then
      local player_transform = get_player_transform(peer_id)
      local sniffer = nil
      local sniffer_distance = math.maxinteger

      for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "sniffer" then
          local d = matrix.distance(g_savedata.objects[i].transform, player_transform)

          if d <= 25 and d < sniffer_distance then
            sniffer_distance = d
            sniffer = g_savedata.objects[i]
          end
        end
      end

      if sniffer == nil then
        return
      end

      sniffer.command = "search"
    elseif verb == "clear-all" then
      for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].tracker == "sniffer" then
          despawn_object(g_savedata.objects[i])
        end
      end
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
    local player = players:find(function(x)
      return x.id == peer_id
    end)
    wreck_players_vehicle(player)
  elseif command == "?kill" then
    local player = players:find(function(x)
      return x.id == peer_id
    end)
    local object_id = server.getPlayerCharacterID(peer_id)
    wreck_players_vehicle(player)
    server.killCharacter(object_id)
    transact(-10000, string.format("%s has bought a new life.", player.name))
  elseif command == "?go" then
    local mission_id = tonumber(verb)

    if mission_id == nil then
      return
    end

    local player = players:find(function(x) return x.id == peer_id end)

    g_savedata.players_enroute[player.steam_id] = mission_id
  end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
  -- if peer_id < 0 or name == "Server" then
  --   return
  -- end

  local character_id = server.getPlayerCharacterID(peer_id)
  local transform = server.getPlayerPos(peer_id)

  server.setAICharacterTeam(character_id, 1)

  if interactions:is_in_interaction(transform, "first_spawn") then
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

function onGroupSpawn(group_id, peer_id, x, y, z, cost)
  if spawn_by_foundation then
    return
  end

  local vehicle_ids = server.getVehicleGroup(group_id)
  local data = server.getVehicleData(vehicle_ids[1])
  local owner = nil

  if peer_id >= 0 then
    local player = players:find(function(x)
      return x.id == peer_id
    end)

    if player ~= nil then
      owner = player.steam_id
    else
      owner = nil
    end
  end

  local tags = string.parse_tags(data.tags_full)
  local test = false

  for k, v in pairs(object_trackers) do
    test = test or v.test_type(nil, vehicle_ids[1], "vehicle", data.name, tags, owner, cost)
  end

  if test then
    initialize_object(vehicle_ids[1], "vehicle", data.name, tags, nil, nil, nil, nil, owner, cost)
  end
end

function onVehicleLoad(vehicle_id)
  for i = 1, #g_savedata.objects do
    if is_vehicle(g_savedata.objects[i]) and g_savedata.objects[i].id == vehicle_id then
      loaded_object(g_savedata.objects[i])
    end
  end
end

function onVehicleUnload(vehicle_id)
  for i = 1, #g_savedata.objects do
    if is_vehicle(g_savedata.objects[i]) and g_savedata.objects[i].id == vehicle_id then
      unloaded_object(g_savedata.objects[i])
    end
  end
end

function onVehicleDespawn(vehicle_id, peer_id)
  for i = 1, #g_savedata.objects do
    if is_vehicle(g_savedata.objects[i]) and (g_savedata.objects[i].id == vehicle_id or g_savedata.objects[i].parent_id == vehicle_id) then
      clear_object(g_savedata.objects[i])
    end
  end
end

function onVehicleDamaged(vehicle_id, damage_amount, voxel_x, voxel_y, voxel_z, body_index)
  for i = 1, #g_savedata.objects do
    if is_vehicle(g_savedata.objects[i]) and g_savedata.objects[i].id == vehicle_id then
      damaged_vehicle(g_savedata.objects[i], damage_amount, voxel_x, voxel_y, voxel_z, body_index)
    end
  end
end

function onObjectLoad(object_id)
  for i = 1, #g_savedata.objects do
    if is_object(g_savedata.objects[i]) and g_savedata.objects[i].id == object_id then
      loaded_object(g_savedata.objects[i])
    end
  end
end

function onObjectUnload(object_id)
  for i = 1, #g_savedata.objects do
    if is_object(g_savedata.objects[i]) and g_savedata.objects[i].id == object_id then
      unloaded_object(g_savedata.objects[i])
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
    initialize_object(fire_objective_id, "forest_fire", nil, {}, mission_id, nil, nil, nil, transform)
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
      initialize_object(id, "oil_spill", nil, {}, mission_id, nil, nil, nil, transform, x, z, total)
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

  if is_open then
    landscapes:clear_map_all(peer_id)
    landscapes:map_all(peer_id)
  end
end

function onCreate(is_world_create)
  if is_world_create then
    g_savedata.subsystems.mapping.landscape.markar_id = server.getMapID()
    g_savedata.subsystems.mapping.interaction.markar_id = server.getMapID()
    g_savedata.dlcs.weapon = server.dlcWeapons()
    g_savedata.dlcs.industry = server.dlcArid()
    g_savedata.dlcs.space = server.dlcSpace()
  end

  landscapes:refresh()
  interactions:refresh()
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
  console.notify(string.format("Players: %d", #players.items))
  console.notify(string.format("Locations: %d", #locations.items))
  console.notify(string.format("Landscapes: %d", #landscapes.items))
  console.notify(string.format("Gone missions: %d", #g_savedata.locations_history))
  console.notify(string.format("Active missions: %d", #g_savedata.missions))
  console.notify(string.format("Active objects: %d", #g_savedata.objects))
  console.notify(string.format("Mission area limited: %s", g_savedata.subsystems.mission.area_limited))
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

function get_player_transform(peer_id)
  local transform, ts = server.getPlayerPos(peer_id)

  if not ts then
    transform = matrix.identity()
  end

  local vx, vy, vz, ds = server.getPlayerLookDirection(peer_id)

  if ds then
    transform = matrix.multiply(transform, matrix.rotationToFaceXZ(vx, vz))
  end

  return transform
end

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

function pathfind(location, destination, required_tags, avoided_tags)
  local paths = server.pathfind(location, destination, required_tags, avoided_tags)
  local transforms = {}

  for i = 1, #paths do
    table.insert(transforms, matrix.translation(paths[i].x, 0, paths[i].z))
  end

  return transforms
end

function press_vehicle_button(vehicle_id, button)
  -- server.pressVehicleButton(vehicle_id, 0, 0, 0)
  server.pressVehicleButton(vehicle_id, button.name)
end

function set_vehicle_keypad(vehicle_id, keypad, value)
  server.setVehicleKeypad(vehicle_id, keypad.pos.x, keypad.pos.y, keypad.pos.z, value)
end

function missions_less_than_limit()
  local count = 0

  for i = 1, #g_savedata.missions do
    count = count + g_savedata.missions[i].difficulty
  end

  return count < #players.items * 0.8
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

function get_center_transform()
  local hq = table.find(g_savedata.objects, function(x) return is_headquarter(x) end)

  if g_savedata.subsystems.mission.area_limited then
    local x = math.random(0, g_savedata.subsystems.mission.area_x_max - g_savedata.subsystems.mission.area_x_min) + g_savedata.subsystems.mission.area_x_min
    local y = math.random(0, g_savedata.subsystems.mission.area_y_max - g_savedata.subsystems.mission.area_y_min) + g_savedata.subsystems.mission.area_y_min

    return matrix.translation(x, 0, y)
  elseif hq ~= nil then
    return hq.transform
  else
    return get_start_tile_transform()
  end
end

function get_start_tile_transform()
  local start_tile = server.getStartTile()
  return matrix.translation(start_tile.x, start_tile.y, start_tile.z)
end

console = {
  log = function(text, peer_id)
    if peer_id == nil then
      peer_id = -1
    end

    server.announce("[LOG]", text, peer_id)
  end,
  notify = function(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
      server.announce("[NOTICE]", text, peer_id)
    end
  end,
  error = function(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[ERROR]", text, peer_id)
  end
}

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
