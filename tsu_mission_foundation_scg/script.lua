name = "TSU Mission Foundation SCG"
version = "1.1.5"

-- properties
g_savedata = {
    mode = "prod",
    missions = {},
    objects = {},
    players = {},
    players_map = {},
    locations = {},
    locations_history = {},
    zones = {},
    mission_timer_tickrate = 0,
    mission_interval = 0,
    mission_interval_min = property.slider("New missions occurs at a minimum interval of (minutes)", 0, 30, 1, 10) * 3600,
    mission_interval_max = property.slider("New missions occurs at a maximum interval of (minutes)", 0, 60, 1, 20) * 3600,
    mission_range_min = property.slider("New missions occurs in a minimum range of (km)", 0, 10, 1, 1) * 1000,
    mission_range_max = property.slider("New missions occurs in a maximum range of (km)", 1, 100, 1, 6) * 1000,
    mission_range_limited = true,
    mission_count = 0,
    mission_count_limited = true,
    mission_mapped = true,
    mission_spawn_when_players_x = property.slider("New mission occurs when the number of missions is less than players divided by", 1, 32, 1, 4),
    object_mapped = false,
    location_comparer = "pattern",
    zone_mapped = false,
    zone_marker_id = nil,
    subsystems = {
        rescuees = true,
        fires = true,
        wreckages = true,
        hostiles = true,
        suspects = true,
        splillage = true,
        cpa_recurrence = property.checkbox("CPA is recurrent", true),
        cpa_recurrence_rate = property.slider("Recurrence rate of CPA (%)", 0, 100, 1, 12),
        rescuees_strobe = property.checkbox("Rescuees has strobe", true),
        eot = "END OF TABLE"
    },
    eot = "END OF TABLE"
}

location_properties = {{
    pattern = "^mission:expedition_missing_%d+$",
    tracker = "sar",
    suitable_zones = {"forest", "field", "island", "mountain"},
    is_main_location = true,
    sub_locations = {"^mission:expedition_missing_%d+$", "^mission:raft_%d+$"},
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 1000,
    category = 2,
    notification_type = 0,
    report = "行方不明者\n探検隊との連絡が3日前から途絶している. 要救助者は広範囲にわたり散り散りになっている可能性が高いためこの範囲をくまなく捜索せよ.",
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
    category = 3,
    notification_type = 0,
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
    search_radius = 1000,
    category = 3,
    notification_type = 0,
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
    search_radius = 1000,
    category = 3,
    notification_type = 0,
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
    search_radius = 1000,
    category = 3,
    notification_type = 0,
    report = "救命ボート",
    report_timer = 0,
    note = ""
}, {
    pattern = "^mission:raft_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "shallow"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    search_radius = 1000,
    category = 3,
    notification_type = 0,
    report = "いかだ",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:vessel_fire_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 500,
    category = 2,
    notification_type = 0,
    report = "メーデー\n船内で突然何かが爆発した! もう助からないぞ!",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗組員からの通報"
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
    category = 3,
    notification_type = 0,
    report = "水難事故\nボートが壊れて沈没しそう!",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:vessel_sink_%d+$",
    tracker = "sar",
    suitable_zones = {"offshore", "channel"},
    is_main_location = true,
    sub_locations = {"^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$"},
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 500,
    category = 2,
    notification_type = 0,
    report = "メーデー\n本船は何らかの物体と接触, 浸水し沈没しかかっている. 乗員乗客はほとんど脱出に成功したが漂流している. 至急救援を求む.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "乗組員からの通報"
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
    category = 2,
    notification_type = 0,
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
    category = 3,
    notification_type = 0,
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
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 500,
    category = 1,
    notification_type = 1,
    report = "火災\n操業中の事故により海上油田で爆発が発生. 油井が激しく炎上し, もう我々の手には負えない. 我々は脱出を開始しているが救命艇が足りず, 身一つで海へ飛び込んだ者もいる. 早急な救出が必要だ.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    fire_min = 50,
    fire_max = 100,
    note = "職員からの通報"
}, {
    pattern = "^mission:tunnel_fire$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {"^mission:car_collision_%d+$", "^mission:car_stuck_%d+$"},
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 250,
    category = 1,
    notification_type = 1,
    report = "火災\nトンネルの中が何もかも燃えている! このままではみんな焼け死んでしまう!",
    report_timer_min = 0,
    report_timer_max = 0,
    fire_min = 50,
    fire_max = 100,
    note = "民間人からの通報"
}, {
    pattern = "^mission:car_collision_%d+$",
    tracker = "sar",
    suitable_zones = {"road", "tunnel"},
    is_main_location = false,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = true,
    search_radius = 100,
    category = 3,
    notification_type = 0,
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
    search_radius = 100,
    category = 3,
    notification_type = 0,
    report = "スタックした自動車",
    report_timer_min = 0,
    report_timer_max = 0,
    note = ""
}, {
    pattern = "^mission:aircraft_down_%d+$",
    tracker = "sar",
    suitable_zones = {"field", "mountain"},
    is_main_location = true,
    sub_locations = {"^mission:aircraft_down_%d+$", "^mission:passenger_fallen_land_%d+$"},
    sub_location_min = 2,
    sub_location_max = 3,
    is_unique_sub_location = true,
    search_radius = 500,
    category = 2,
    notification_type = 0,
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
    category = 2,
    notification_type = 0,
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
    sub_location_max = 1,
    is_unique_sub_location = false,
    search_radius = 100,
    category = 2,
    notification_type = 0,
    report = "火災\nキャンプ場で火事, 森林火災に発展する危険がある.",
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
    sub_locations = {"^mission:expedition_missing_%d+$"},
    sub_location_min = 1,
    sub_location_max = 2,
    is_unique_sub_location = false,
    search_radius = 250,
    category = 3,
    notification_type = 0,
    report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を殺害せよ.",
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
    --     category = 0,
    --     notification_type = 0,
    --     report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を殺害せよ.",
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
    sub_location_max = 1,
    is_unique_sub_location = false,
    search_radius = 250,
    category = 3,
    notification_type = 0,
    report = "危険生物\n危険な野生動物を発見. 付近にいる人を避難させ, 危害が生じた場合は当該の動物を殺害せよ.",
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
    search_radius = 200,
    category = 2,
    notification_type = 0,
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
    search_radius = 200,
    category = 2,
    notification_type = 0,
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
    search_radius = 200,
    category = 1,
    notification_type = 1,
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
    category = 2,
    notification_type = 0,
    report = "火災\n爆発性の化学物質が保管されている倉庫から煙が出ている.",
    report_timer_min = 0,
    report_timer_max = 0,
    rescuee_min = 25,
    rescuee_max = 75,
    note = "職員からの通報"
}, {
    pattern = "^mission:air_medevac_%d+$",
    tracker = "sar",
    suitable_zones = {"airfield", "heliport"},
    is_main_location = true,
    sub_locations = {"^mission:air_medevac_%d+$"},
    sub_location_min = 1,
    sub_location_max = 3,
    is_unique_sub_location = false,
    search_radius = 250,
    category = 3,
    notification_type = 0,
    report = "救急搬送\n近隣で発生した救急患者をこの空港に搬送する. 引き継いで病院へ後送せよ.",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "職員からの通報"
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
    landscape = "freight_terminal",
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
    landscape = "plant"
}, {
    landscape = "mine"
}, {
    landscape = "first_spawn"
}, {
    landscape = "respawn"
}}

mission_trackers = {
    sar = {
        init = function(self)
        end,
        clear = function(self)
        end,
        tick = function(self, tick)
            if not self.spawned then
                for i = 1, #self.locations do
                    spawn_location(self.locations[i], self.id)
                end

                local c, x, y, z = 0, 0, 0, 0

                for i = 1, #g_savedata.objects do
                    if g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker ~= nil then
                        local ox, oy, oz = matrix.position(g_savedata.objects[i].transform)
                        c = c + 1
                        x = x + ox
                        y = y + oy
                        z = z + oz
                    end
                end

                x = x / c
                y = y / c
                z = z / c

                self.search_center = matrix.translation(x, y, z)
                self.spawned = true

                console.notify(string.format("Spawned mission #%d.", self.id))
            end

            local rescuee_count = 0
            local fire_count = 0
            local suspect_count = 0
            local wreckage_count = 0
            local hostile_count = 0
            local cpa_count = 0
            local underwater_count = 0
            local radiation_count = 0

            for i = 1, #g_savedata.objects do
                if g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker == "rescuee" then
                    rescuee_count = rescuee_count + 1

                    if g_savedata.objects[i].cpa_count > 0 then
                        cpa_count = cpa_count + 1
                    end
                elseif g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker == "fire" then
                    fire_count = fire_count + 1
                elseif g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker == "wreckage" then
                    wreckage_count = wreckage_count + 1
                elseif g_savedata.objects[i].mission == self.id and g_savedata.objects[i].tracker == "hostile" then
                    hostile_count = hostile_count + 1
                end
            end

            for i = 1, #self.locations do
                if self.locations[i].zone and self.locations[i].zone.landscape == "underwater" then
                    underwater_count = underwater_count + 1
                end
            end

            self.objectives.rescuees = rescuee_count
            self.objectives.fires = fire_count
            self.objectives.suspects = suspect_count
            self.objectives.wreckages = wreckage_count
            self.objectives.hostiles = hostile_count

            if not self.units.sar and self.locations[1].search_radius >= 250 then
                self.units.sar = true
            end

            if not self.units.fire and fire_count >= 5 then
                self.units.fire = true
            end

            if not self.units.med and rescuee_count >= 1 then
                self.units.med = true
            end

            if not self.units.spc and (suspect_count >= 1 or hostile_count >= 1 or underwater_count >= 1) then
                self.units.spc = true
            end
        end,
        complete = function(self)
            local completed = self.spawned

            for k, object in pairs(g_savedata.objects) do
                if object.mission == self.id and object.tracker ~= nil then
                    completed = completed and (object:dispensable() or object:complete())
                end
            end

            return completed or self.terminated
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
            return string.format("#%d " .. self.locations[1].report, self.id)
        end,
        progress = function(self)
            local test = {}

            for k, v in pairs(object_trackers) do
                test[k] = {
                    count = 0,
                    completed = 0
                }
            end

            for k, v in pairs(g_savedata.objects) do
                if v.mission == self.id and v.tracker ~= nil then
                    if v:complete() then
                        test[v.tracker].completed = test[v.tracker].completed + 1
                    end

                    test[v.tracker].count = test[v.tracker].count + 1
                end
            end

            local progresses = {}

            for k, v in pairs(test) do
                if v.count > 0 then
                    table.insert(progresses, string.format("%d\n" .. object_trackers[k].progress, test[k].count))
                end
            end

            return progresses
        end,
        status = function(self)
            local text = self.locations[1].note
            text = text .. "\n\n[カテゴリ]\n"

            if self.category ~= nil then
                text = text .. self.category
            else
                text = text .. "不明"
            end

            text = text .. "\n\n[出動区分]\n"

            local first = true

            for name, available in pairs(self.units) do
                if available then
                    if not first then
                        text = text .. " "
                    else
                        first = false
                    end

                    text = text .. string.upper(name)
                end
            end

            text = text .. "\n\n[進捗]"

            local progresses = self:progress()

            for k, progress in pairs(progresses) do
                text = text .. "\n" .. progress
            end

            return text
        end
    }
}

object_trackers = {
    rescuee = {
        test_type = function(self, id, type, object, component_id, mission_id)
            return object.type == "character" and object.tags.tracker ~= nil and object.tags.tracker == "rescuee"
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
            self.time_admission = 0

            server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, self.vital.ai)
            server.setCharacterTooltip(self.id, string.format("%s\n\nMission ID: %d\nObject ID: %d", self.progress, self.mission, self.id))
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            local transform = self:position()
            local character_vehicle = server.getCharacterVehicle(self.id)
            local on_board = character_vehicle ~= 0
            local vital_update = server.getCharacterData(self.id)
            local is_in_hospital = is_in_landscape(transform, "hospital")
            local is_in_base = is_in_landscape(transform, "base")
            local is_doctor_nearby = is_doctor_nearby(self)
            local is_safe = is_in_hospital or is_doctor_nearby

            if g_savedata.subsystems.cpa_recurrence and not is_safe then
                if not self.vital.incapacitated and vital_update.incapacitated then
                    self.is_cpa_recurrent = self.is_cpa_recurrent or math.random(0, 100) <= g_savedata.subsystems.cpa_recurrence_rate

                    if self.is_cpa_recurrent then
                        self.cpa_count = self.cpa_count + 1
                    end
                end

                vital_update.hp = math.max(vital_update.hp - (self.cpa_count / 2), 0)
            end

            if g_savedata.subsystems.rescuees_strobe then
                local distance = distance_min_to_player(transform)
                local opt = (self.strobe.opt or distance <= 100) and not on_board
                local ir = (self.strobe.ir or distance <= 1000) and not on_board
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

            self.vital = vital_update

            if is_in_hospital or not self.is_cpa_recurrent and is_in_base then
                self.time_admission = self.time_admission + tick
            end

            server.setCharacterData(self.id, self.vital.hp, not self.completed, self.vital.ai)
        end,
        position = function(self)
            return server.getObjectPos(self.id)
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return self.time_admission > 120
        end,
        reward = function(self)
            local value = math.ceil(self.reward_base * (math.floor(self.vital.hp / 25) / 4))

            if g_savedata.subsystems.cpa_recurrence and self.cpa_count >= 2 then
                value = value - self.cpa_count * 1000
            end

            return value
        end,
        status = function(self)
            return string.format("%s\n\nHP: %.00f/100\n心肺停止回数: %.00f回", self.progress, self.vital.hp, self.cpa_count)
            -- return self.progress
        end,
        reward_base = 2000,
        progress = "要救助者を医療機関へ搬送",
        marker_type = 1,
        clear_timer = 300
    },
    fire = {
        test_type = function(self, id, type, object, component_id, mission_id)
            return object.type == "fire"
        end,
        init = function(self)
            self.is_lit = server.getFireData(self.id)
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            self.is_lit = server.getFireData(self.id)
        end,
        position = function(self)
            return server.getObjectPos(self.id)
        end,
        dispensable = function(self)
            return false
        end,
        complete = function(self)
            return not self.is_lit
        end,
        reward = function(self)
            return self.reward_base
        end,
        status = function(self)
            return self.progress
        end,
        reward_base = 500,
        progress = "炎を鎮火",
        marker_type = 5,
        clear_timer = 0
    },
    wreckage = {
        test_type = function(self, id, type, object, component_id, mission_id)
            return object.type == "vehicle" and object.tags.tracker ~= nil and object.tags.tracker == "wreckage"
        end,
        init = function(self)
            self.components_checked = false
            self.completion_timer = 0
            self.initial_transform = server.getVehiclePos(self.id)
            self.transform = server.getVehiclePos(self.id)
            self.mass = 0

            server.setVehicleTooltip(self.id, string.format("%s\n\nMission ID: %d\nVehicle ID: %d", self.progress, self.mission, self.id))
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
            self.transform = server.getVehiclePos(self.id)

            if is_in_landscape(self.transform, "freight_terminal") then
                self.completion_timer = self.completion_timer + tick
            end
        end,
        position = function(self)
            return server.getVehiclePos(self.id)
        end,
        dispensable = function(self)
            return matrix.distance(self.initial_transform, self.transform) <= 25
        end,
        complete = function(self)
            return self.completion_timer >= 300
        end,
        reward = function(self)
            return math.ceil(self.mass * self.reward_base / 100) * 100
        end,
        status = function(self)
            return self.progress
        end,
        reward_base = 2,
        progress = "残骸を回収し貨物ターミナルへ輸送 (オプション)",
        marker_type = 2,
        clear_timer = 7200
    },
    hostile = {
        test_type = function(self, id, type, object, component_id, mission_id)
            return (object.type == "creature" or object.type == "animal") and object.tags.tracker ~= nil and object.tags.tracker == "hostile"
        end,
        init = function(self)
            local pos = self:position()
            local mission = table.find(g_savedata.missions, function(x)
                return x.id == self.mission
            end)
            self.target = table.random(table.find_all(mission.locations, function(x)
                local d = matrix.distance(x.transform, pos)
                return d >= 25 and d < 100
            end))
            self.vital = server.getObjectData(self.id)
            server.setVehicleTooltip(self.id, string.format("%s\n\nMission ID: %d\nVehicle ID: %d", self.progress, self.mission, self.id))
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
                console.notify(string.format("%.00f, %.00f, %.00f", x, y, z))
                local s = server.setCreatureMoveTarget(self.id, self.target.transform)

                if s then
                    self.target = nil
                end
            end

            self.vital = server.getObjectData(self.id)
        end,
        position = function(self)
            return server.getVehiclePos(self.id)
        end,
        dispensable = function(self)
            return true
        end,
        complete = function(self)
            return self.vital.incapacitated or self.vital.dead
        end,
        reward = function(self)
            return self.reward_base
        end,
        status = function(self)
            return self.progress
        end,
        reward_base = 1000,
        progress = "敵性生物を排除 (オプション)",
        marker_type = 2,
        clear_timer = 300
    },
    headquarter = {
        test_type = function(self, id, type, object, component_id, mission_id)
            return object.type == "vehicle" and object.tags.tracker ~= nil and object.tags.tracker == "headquarter"
        end,
        init = function(self)
            self.components_checked = false
            self.alert = nil
            self.mission_datalink = {}
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
                    self.mission_datalink[i] = {}
                    self.mission_datalink[i].id = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_id", i)
                    end)
                    self.mission_datalink[i].x = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_x", i)
                    end)
                    self.mission_datalink[i].y = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_y", i)
                    end)
                    self.mission_datalink[i].r = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_r", i)
                    end)
                    self.mission_datalink[i].rescuees = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_rescuees", i)
                    end)
                    self.mission_datalink[i].fires = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_fires", i)
                    end)
                    self.mission_datalink[i].suspects = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_suspects", i)
                    end)
                    self.mission_datalink[i].wreckages = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_wreckages", i)
                    end)
                    self.mission_datalink[i].hostiles = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_hostiles", i)
                    end)
                    self.mission_datalink[i].sar = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_sar", i)
                    end)
                    self.mission_datalink[i].med = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_med", i)
                    end)
                    self.mission_datalink[i].fire = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_fire", i)
                    end)
                    self.mission_datalink[i].spc = table.find(d.components.buttons, function(d)
                        return string.lower(d.name) == string.format("mission_%d_spc", i)
                    end)
                end

                self.components_checked = true
            end
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
            if self.components_checked then
                for index = 1, math.max(#g_savedata.missions, 6) do
                    if g_savedata.missions[index] ~= nil then
                        local x, y, z = matrix.position(g_savedata.missions[index].locations[1].transform)

                        if self.mission_datalink[index].id ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].id, g_savedata.missions[index].id)
                        end

                        if self.mission_datalink[index].x ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].x, x)
                        end

                        if self.mission_datalink[index].y ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].y, z)
                        end

                        if self.mission_datalink[index].r ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].r, g_savedata.missions[index].search_radius)
                        end

                        if self.mission_datalink[index].rescuees ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].rescuees, g_savedata.missions[index].objectives.rescuees)
                        end

                        if self.mission_datalink[index].fires ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].fires, g_savedata.missions[index].objectives.fires)
                        end

                        if self.mission_datalink[index].suspects ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].suspects, g_savedata.missions[index].objectives.suspects)
                        end

                        if self.mission_datalink[index].wreckages ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].wreckages, g_savedata.missions[index].objectives.wreckages)
                        end

                        if self.mission_datalink[index].hostiles ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].hostiles, g_savedata.missions[index].objectives.hostiles)
                        end

                        if self.mission_datalink[index].sar ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].sar, g_savedata.missions[index].units.sar)
                        end

                        if self.mission_datalink[index].med ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].med, g_savedata.missions[index].units.med)
                        end

                        if self.mission_datalink[index].fire ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].fire, g_savedata.missions[index].units.fire)
                        end

                        if self.mission_datalink[index].spc ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].spc, g_savedata.missions[index].units.spc)
                        end
                    else
                        if self.mission_datalink[index].id ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].id, 0)
                        end

                        if self.mission_datalink[index].x ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].x, 0)
                        end

                        if self.mission_datalink[index].y ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].y, 0)
                        end

                        if self.mission_datalink[index].r ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].r, 0)
                        end

                        if self.mission_datalink[index].rescuees ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].rescuees, 0)
                        end

                        if self.mission_datalink[index].fires ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].fires, 0)
                        end

                        if self.mission_datalink[index].suspects ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].suspects, 0)
                        end

                        if self.mission_datalink[index].wreckages ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].wreckages, 0)
                        end

                        if self.mission_datalink[index].hostiles ~= nil then
                            set_vehicle_keypad(self.id, self.mission_datalink[index].hostiles, 0)
                        end

                        if self.mission_datalink[index].sar ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].sar, false)
                        end

                        if self.mission_datalink[index].med ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].med, false)
                        end

                        if self.mission_datalink[index].fire ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].fire, false)
                        end

                        if self.mission_datalink[index].spc ~= nil then
                            set_vehicle_button(self.id, self.mission_datalink[index].spc, false)
                        end
                    end
                end
            end
        end,
        position = function(self)
            return server.getVehiclePos(self.id)
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
        status = function(self)
            return self.progress
        end,
        reward_base = 0,
        progress = "",
        marker_type = 11,
        clear_timer = 0
    },
    unit = {
        test_type = function(self, id, type, object, component_id, mission_id, owner, cost)
            return object.type == "vehicle" and owner ~= nil and cost ~= nil
        end,
        init = function(self, owner, cost)
            self.owner_steam_id = owner
            self.cost = cost
        end,
        clear = function(self)
        end,
        load = function(self)
        end,
        unload = function(self)
        end,
        tick = function(self, tick)
        end,
        position = function(self)
            return server.getVehiclePos(self.id)
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
        status = function(self)
            return self.progress
        end,
        reward_base = 0,
        progress = "",
        marker_type = 11,
        clear_timer = 0
    }
}

-- main logics
-- missions

function random_mission(center, range_max, range_min)
    local location, e = random_location(center, range_max, range_min, {}, {}, true, true)

    if location == nil then
        return
    end

    initialize_mission(center, range_min, location.tracker, location)
end

function initialize_mission(center, range_min, tracker, location, report_timer)
    local mission = {}
    mission.cleared = false
    mission.id = g_savedata.mission_count + 1
    mission.start_position = center
    mission.tracker = tracker
    mission.locations = {location}
    mission.search_center = nil
    mission.search_radius = mission.locations[1].search_radius
    mission.category = mission.locations[1].category
    mission.reported = false
    mission.report_timer = report_timer or math.random(mission.locations[1].report_timer_min, mission.locations[1].report_timer_max)
    mission.spawned = false
    mission.terminated = false
    mission.marker_id = server.getMapID()
    mission.objectives = {
        rescuees = 0,
        fires = 0,
        suspects = 0,
        wreckages = 0,
        hostiles = 0
    }
    mission.units = {
        sar = false,
        medic = false,
        fire = false,
        specialist = false
    }
    mission.rewards = 0
    setmetatable(mission, mission_trackers[tracker])
    mission:init()

    record_location_history(location)
    table.insert(g_savedata.missions, mission)
    g_savedata.mission_count = g_savedata.mission_count + 1

    local sub_location_count = math.random(mission.locations[1].sub_location_min, mission.locations[1].sub_location_max)

    for i = 1, sub_location_count do
        local sub_location = random_location(mission.locations[1].transform, mission.search_radius, 0, mission.locations[1].sub_locations, {}, false, true)

        if sub_location then
            table.insert(mission.locations, sub_location)
        end
    end

    console.notify(string.format("Initialized mission #%d.", mission.id))
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

    server.notify(-1, string.format("Cleared mission #%d.", mission.id), mission:report(), 4)
    console.notify(string.format("Cleared mission #%d.", mission.id))
end

function tick_mission(mission, tick)
    mission:tick(tick)

    if g_savedata.mission_mapped and mission.search_center then
        local label = mission:report()
        local label_hover = mission:status()
        local x, y, z = matrix.position(mission.search_center)

        for i = 1, #players do
            if players[i].map_open then
                server.removeMapID(players[i].id, mission.marker_id)
                server.addMapObject(players[i].id, mission.marker_id, 0, 8, x, z, 0, 0, nil, nil, label, mission.locations[1].search_radius, label_hover, 255, 0, 255, 255)
            end
        end
    end

    -- mission.report_timer = math.max(mission.report_timer - tick, 0)

    if not mission.reported and mission.report_timer == 0 then
        alert_headquarter()
        server.notify(-1, mission:report(), mission.locations[1].note, mission.locations[1].notification_type)
        mission.reported = true
    end

    if mission:complete() and distance_min_to_player(mission.locations[1].transform) > mission.locations[1].search_radius then
        reward_mission(mission)
        clear_mission(mission)
    end
end

function reward_mission(mission)
    local reward = mission:reward()

    transact(reward, string.format("Cleared mission #%d.", mission.id))
end

function terminate_mission(mission)
    mission.terminated = true
end

-- objects

function initialize_object(id, type, object, component_id, mission_id, ...)
    local params = {...}

    object.id = id
    object.type = type
    object.tracker = nil
    object.marker_id = server.getMapID()
    object.component_id = component_id
    object.mission = mission_id
    object.loaded = false
    object.completed = false
    object.cleared = false
    object.elapsed_clear = 0

    for k, v in pairs(object_trackers) do
        if v:test_type(id, type, object, component_id, mission_id, table.unpack(params)) then
            object.tracker = k
            break
        end
    end

    if object.tracker ~= nil then
        setmetatable(object, object_trackers[object.tracker])
        object:init(table.unpack(params))
    end

    if object.type == "vehicle" and object.tags.keep_active == "true" then
        server.setVehicleTransponder(object.id, true)
    end

    table.insert(g_savedata.objects, object)
    console.notify(string.format("Initialized object %s#%d.", object.type, object.id))
end

function clear_object(object)
    if object.tracker ~= nil then
        object:clear()
    end

    server.removeMapID(-1, object.marker_id)

    object.cleared = true
    console.notify(string.format("Cleared object %s#%d.", object.type, object.id))
end

function despawn_object(object)
    if object.type == "vehicle" then
        server.despawnVehicle(object.id, true)
    else
        server.despawnObject(object.id, true)
        clear_object(object)
    end
end

function tick_object(object, tick)
    if object.tracker == nil then
        return
    end

    -- server.removeMapID(-1, object.marker_id)

    -- if g_savedata.object_mapped then
    --     local transform = object:position()
    --     local x, y, z = matrix.position(transform)
    --     local r, g, b, a = 127, 127, 127, 255
    --     local label = string.format("%s #%d", object.tracker, object.id)
    --     local popup = string.format("X: %.0f\nY: %.0f\nZ: %.0f", x, y, z)
    --     local marker_type = object.marker_type

    --     server.addMapObject(-1, object.marker_id, 0, marker_type, x, z, 0, 0, nil, nil, label, 0, popup, r, g, b, a)
    -- end

    object:tick(tick)

    if object.mission ~= nil and not object.completed and object:complete() then
        for j = 1, #g_savedata.missions do
            if g_savedata.missions[j].id == object.mission then
                local reward = object:reward()
                g_savedata.missions[j].rewards = g_savedata.missions[j].rewards + reward

                console.notify(string.format("Reward: %d", reward))
            end
        end

        server.notify(-1, object:status(), "Objective achieved", 4)
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

function find_parent_object(vehicle_parent_component_id, mission_id)
    local obj = table.find(g_savedata.objects, function(x)
        return x.mission == mission_id and x.component_id == vehicle_parent_component_id
    end)

    if obj == nil then
        obj = table.find(g_savedata.objects, function(x)
            return x.mission == mission_id and x.component_id == vehicle_parent_component_id
        end)
    end

    return obj
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

function is_doctor_nearby(object)
    local is = false

    for i = 1, #g_savedata.objects do
        is = is or g_savedata.objects[i].tracker == "doctor" and matrix.distance(object.transform, g_savedata.objects[i].transform) <= 10
    end

    return is
end

-- locations

function random_location(center, range_max, range_min, location_names, zone_names, is_main_location, check_dupe)
    if #g_savedata.locations == 0 then
        console.error("Mission location does not exist. Check if your add-ons contains valid mission location.")
        return nil
    end

    local location_candidates = {}

    for i = 1, #g_savedata.locations do
        if is_main_location and not g_savedata.locations[i].is_main_location then
            goto continue_location
        end

        if check_dupe and (is_main_location or g_savedata.locations[i].is_unique_sub_location) and is_location_duplicated(g_savedata.locations[i]) then
            goto continue_location
        end

        if #location_names > 0 and not match_location_name(g_savedata.locations[i], location_names) then
            goto continue_location
        end

        local location_candidate = table.copy(g_savedata.locations[i])

        if g_savedata.locations[i].tile == "" then
            local zone_candidate_keys = {}
            local zone_candidate_types = {}

            for j = 1, #g_savedata.zones do
                if #zone_names > 0 and not table.contains(zone_names, g_savedata.zones[j].landscape) then
                    goto continue_zone
                end

                if not table.contains(g_savedata.locations[i].suitable_zones, g_savedata.zones[j].landscape) then
                    goto continue_zone
                end

                if (not is_main_location or g_savedata.mission_range_limited) and not is_zone_in_range(g_savedata.zones[j], center, range_max, range_min) then
                    goto continue_zone
                end

                for k = 1, #g_savedata.missions do
                    for l = 1, #g_savedata.missions[k].locations do
                        if g_savedata.missions[k].locations[l].zone and g_savedata.missions[k].locations[l].zone.id == g_savedata.zones[j].id then
                            goto continue_zone
                        end
                    end
                end

                table.insert(zone_candidate_keys, j)
                table.insert(zone_candidate_types, g_savedata.zones[j].landscape)

                ::continue_zone::
            end

            zone_candidate_types = table.distinct(zone_candidate_types)

            if (#zone_names > 0 and table.contains(zone_names, "offshore")) or (#zone_names == 0 and table.contains(g_savedata.locations[i].suitable_zones, "offshore")) then
                table.insert(zone_candidate_types, "offshore")
            end

            local zone_candidate_type = table.random(zone_candidate_types)

            if zone_candidate_type == "offshore" then
                location_candidate.zone = random_offshore_zone(center, range_max, range_min)

                if location_candidate.zone == nil then
                    goto continue_location
                end
            else
                for j = #zone_candidate_keys, 1, -1 do
                    if g_savedata.zones[zone_candidate_keys[j]].landscape ~= zone_candidate_type then
                        table.remove(zone_candidate_keys, j)
                    end
                end

                if #zone_candidate_keys == 0 then
                    goto continue_location
                end

                local zone_candidate_key = table.random(zone_candidate_keys)

                location_candidate.zone = table.copy(g_savedata.zones[zone_candidate_key])
            end

            location_candidate.transform = location_candidate.zone.transform
        else
            local transform, is_success = server.getTileTransform(center, g_savedata.locations[i].tile, range_max)
            location_candidate.transform = transform

            if not is_success or g_savedata.mission_range_limited and matrix.distance(center, location_candidate.transform) > range_max then
                goto continue_location
            end

        end

        table.insert(location_candidates, location_candidate)

        ::continue_location::
    end

    if #location_candidates == 0 then
        -- console.error("No available locations were found. Either overlap with missions ongoing, or there is no suitable zones within mission range.")

        local text = "No available locations were found with name: "

        for i = 1, #location_names do
            text = text .. location_names[i]

            if i < #location_names then
                text = text .. ", "
            end
        end

        console.error(text)

        return nil
    end

    return table.random(location_candidates)
end

function match_location_name(location, patterns)
    local matched = false

    for i = 1, #patterns do
        matched = matched or string.match(location.name, patterns[i]) ~= nil
    end

    return matched
end

function is_location_free(location, mission)
    return location.id ~= mission.locations[1].id
end

function is_location_duplicated(location)
    local dupe = false
    local l = {}
    local unique = 0

    for i = 1, #g_savedata.missions do
        for j = 1, #g_savedata.missions[i].locations do
            dupe = dupe or (g_savedata.missions[i].locations[j][g_savedata.location_comparer] == location[g_savedata.location_comparer])
        end
    end

    for i = 1, #g_savedata.locations do
        if g_savedata.locations[i].is_main_location then
            l[g_savedata.locations[i][g_savedata.location_comparer]] = true
        end
    end

    for _, v in pairs(l) do
        unique = unique + 1
    end

    local history_back = #g_savedata.locations_history - math.floor(unique * 0.75) + 1

    for i = #g_savedata.locations_history, math.max(history_back, 1), -1 do
        dupe = dupe or g_savedata.locations_history[i][g_savedata.location_comparer] == location[g_savedata.location_comparer]
    end

    return dupe
end

function spawn_location(location, mission_id)
    local vehicles = {}
    local rescuees = {}
    local fires = {}
    local others = {}

    for component_index = 0, location.component_count do
        local data = server.getLocationComponentData(location.addon_index, location.location_index, component_index)

        if data ~= nil then
            data.addon_index = location.addon_index
            data.location_index = location.location_index
            data.component_index = component_index
            data.tags = parse_tags(data.tags_full)

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

    if location.zone then
        console.notify(string.format("Spawning dynamic location %s in zone %s#%d", location.name, location.zone.tags.landscape, location.zone.id))
    else
        console.notify(string.format("Spawning static location %s", location.name))
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
    local obj_types = table.keys(object_trackers)
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

    object.tags = parse_tags(object.tags_full)

    initialize_object(object.id, object.type, object, component.id, mission_id)
end

function load_locations()
    g_savedata.locations = {}

    local addon_count = server.getAddonCount()
    local addon_index = 0

    while addon_index <= addon_count do
        local location_count = (server.getAddonData(addon_index) or {
            location_count = 0
        }).location_count
        local location_index = 0

        while location_index <= location_count do
            local location = server.getLocationData(addon_index, location_index)

            if location and not location.env_mod then
                for i = 1, #location_properties do
                    if string.match(location.name, location_properties[i].pattern) then
                        location.id = #g_savedata.locations + 1
                        location.addon_index = addon_index
                        location.location_index = location_index
                        location.pattern = location_properties[i].pattern or nil
                        location.tracker = location_properties[i].tracker or nil
                        location.suitable_zones = location_properties[i].suitable_zones or {}

                        if location_properties[i].is_main_location ~= nil then
                            location.is_main_location = location_properties[i].is_main_location
                        else
                            location.is_main_location = true
                        end

                        location.sub_locations = location_properties[i].sub_locations or {}
                        location.sub_location_min = location_properties[i].sub_location_min or 0
                        location.sub_location_max = location_properties[i].sub_location_max or 0
                        location.is_unique_sub_location = location_properties[i].is_unique_sub_location or false
                        location.search_radius = location_properties[i].search_radius or 0
                        location.category = location_properties[i].category or nil
                        location.notification_type = location_properties[i].notification_type or 0
                        location.report = location_properties[i].report or ""
                        location.report_timer_min = location_properties[i].report_timer_min or 0
                        location.report_timer_max = location_properties[i].report_timer_max or 0
                        location.rescuee_min = location_properties[i].rescuee_min or 100
                        location.rescuee_max = location_properties[i].rescuee_max or 100
                        location.fire_min = location_properties[i].fire_min or 100
                        location.fire_max = location_properties[i].fire_max or 100
                        location.hostile_min = location_properties[i].hostile_min or 100
                        location.hostile_max = location_properties[i].hostile_max or 100
                        location.note = location_properties[i].note or ""

                        table.insert(g_savedata.locations, location)
                    end
                end
            end

            location_index = location_index + 1
        end

        addon_index = addon_index + 1
    end
end

function list_locations(peer_id)
    for i = 1, #g_savedata.locations do
        server.announce("[Mission Foundation]", g_savedata.locations[i].name, peer_id)
    end

    server.announce("[Mission Foundation]", string.format("%d all locations", #g_savedata.locations), peer_id)
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

function is_zone_out_range(zone, center, range_max)
    return matrix.distance(center, zone.transform) > range_max
end

function is_zone_in_range(zone, center, range_max, range_min)
    local d = matrix.distance(center, zone.transform)
    return d >= range_min and d <= range_max
end

function is_in_landscape(transform, landscape)
    local is = false

    for i = 1, #g_savedata.zones do
        is = is or g_savedata.zones[i].landscape == landscape and is_in_zone(transform, g_savedata.zones[i])
    end

    return is
end

function is_in_zone(transform, zone)
    return server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z)
end

function random_offshore_zone(center, range_max, range_min)
    local transform, is_success = server.getOceanTransform(center, range_min, range_max)

    if not is_success then
        return nil
    end

    local x, y, z = matrix.position(transform)
    local error = matrix.translation(math.random() * 500, 0, math.random() * 500)
    transform = matrix.multiply(transform, error)
    local id = #g_savedata.zones + 1
    local zone = {
        id = id,
        tags_full = "",
        tags = {},
        display_name = "",
        transform = transform,
        size = {
            x = 20,
            y = 20,
            z = 20
        },
        radius = 10,
        type = 0,
        parent_vehicle_id = nil,
        parent_relative_transform = nil,
        mapped = false,
        icon = 0
    }

    return zone
end

function map_zone(zone, peer_id)
    local peer_id = peer_id or -1

    if g_savedata.zone_mapped or zone.mapped then
        local x, y, z = matrix.position(zone.transform)
        local color = zone.icon == 8 and 255 or 0
        local name = zone.name

        if name == "" then
            name = zone.landscape
        end

        server.addMapLabel(peer_id, zone.marker_id, zone.icon, name, x, z, color, color, color, 255)
    end
end

function load_zones()
    for i = 1, #g_savedata.zones do
        server.removeMapID(-1, g_savedata.zones[i].marker_id)
    end

    g_savedata.zones = {}

    local zone_type_ids = table.keys(zone_properties)
    local id = 1

    for _, zone in pairs(server.getZones()) do
        local tags = parse_tags(zone.tags_full)

        for i = 1, #zone_properties do
            if tags.landscape and zone_properties[i].landscape == tags.landscape then
                zone.id = id
                zone.tags = tags
                zone.landscape = zone_properties[i].landscape
                zone.marker_id = server.getMapID()
                zone.mapped = zone_properties[i].mapped or false
                zone.icon = zone_properties[i].icon or 0

                map_zone(zone)
                table.insert(g_savedata.zones, zone)

                id = id + 1
            end
        end
    end
end

-- headquarter

function initialize_headquarter(group_id)
    local vehicle_ids, is_success = server.getVehicleGroup(group_id)
    local hq = {}

    if not is_success or is_headquarter_dupe(group_id) then
        return
    end

    hq.tags_full = "tracker=headquarter"
    hq.tags = parse_tags(hq.tags_full)
    hq.display_name = ""
    hq.type = "vehicle"
    hq.transform = server.getVehiclePos(vehicle_ids[1])
    hq.id = vehicle_ids[1]
    hq.object_id = nil
    hq.group_id = group_id
    hq.vehicle_ids = vehicle_ids
    hq.component_id = nil

    initialize_object(hq.id, hq.type, hq, nil, nil)
end

function alert_headquarter()
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "headquarter" and g_savedata.objects[i].alert ~= nil then
            press_vehicle_button(g_savedata.objects[i].id, g_savedata.objects[i].alert)
        end
    end
end

function is_headquarter_dupe(group_id)
    local is = false

    for i = 1, #g_savedata.objects do
        is = is or g_savedata.objects[i].tracker == "headquarter" and g_savedata.objects[i].group_id == group_id
    end

    return is
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

    server.setCurrency(money)
    server.notify(-1, string.format(text, amount), title, not_type)
end

-- spawn point

function teleport_to_spawn_points(peer_id)
    local spawn_zone_keys = {}

    for i = 1, #g_savedata.zones do
        if g_savedata.zones[i].landscape == "respawn" then
            table.insert(spawn_zone_keys, i)
        end
    end

    if #spawn_zone_keys == 0 then
        return
    end

    local spawn_zone_key = table.random(spawn_zone_keys)

    server.setPlayerPos(peer_id, g_savedata.zones[spawn_zone_key].transform)
end

-- players

players = {}

function is_player_nearby(transform, distance)
    local result = false

    for i = 1, #players do
        local d = matrix.distance(players[i].transform, transform)

        result = result or matrix.distance(players[i].transform, transform) <= distance
    end

    return result
end

function distance_min_to_player(transform)
    local distance = math.huge

    for i = 1, #players do
        distance = math.min(distance, matrix.distance(players[i].transform, transform))
    end

    return distance
end

-- callbacks

cycle = 60
timing = 0

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if timing % 10 == 0 then
        players = server.getPlayers()

        if #players > 0 and players[1].name == "Server" then
            table.remove(players, 1)
        end

        for i = 1, #players do
            players[i].steam_id = tostring(players[i].steam_id)

            local transform, is_success = server.getPlayerPos(players[i].id)

            if is_success then
                players[i].transform = transform
            else
                players[i].transform = matrix.identity()
            end

            if g_savedata.players_map[players[i].id] ~= nil then
                players[i].map_open = g_savedata.players_map[players[i].id]
            else
                players[i].map_open = false
            end
        end
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

    if g_savedata.mission_timer_tickrate > 0 then
        if g_savedata.mission_interval <= 0 and (not g_savedata.mission_count_limited or missions_less_than_limit()) then
            random_mission(start_tile_transform(), g_savedata.mission_range_max, g_savedata.mission_range_min)
            g_savedata.mission_interval = math.random(g_savedata.mission_interval_min, g_savedata.mission_interval_max)
        else
            g_savedata.mission_interval = g_savedata.mission_interval - (tick * g_savedata.mission_timer_tickrate)
        end
    end

    if timing + 1 < cycle then
        timing = timing + 1
    else
        timing = 0
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
    if command == "?mission" then
        if verb == "list" and is_admin then
            list_locations(peer_id)
        elseif verb == "history" then
            list_location_history(peer_id)
        elseif verb == "start" and is_admin then
            g_savedata.mission_timer_tickrate = 1
        elseif verb == "stop" and is_admin then
            g_savedata.mission_timer_tickrate = 0
        elseif verb == "init" and is_admin then
            local location, report_timer = ...
            local report_timer = tonumber(report_timer)
            local center = start_tile_transform()
            location = "^" .. location .. "$"
            local location = random_location(center, g_savedata.mission_range_max, g_savedata.mission_range_min, {location}, {}, true, false)

            if location == nil then
                return
            end

            initialize_mission(center, g_savedata.mission_range_min, location.tracker, location, report_timer)
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
            g_savedata.mission_interval = 0
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
            console.error("'?mission register-hq' removed. Please read to manual for new methods.")
        elseif verb == "prod" and is_admin then
            g_savedata.mode = "prod"
        elseif verb == "debug" and is_admin then
            g_savedata.mode = "debug"
        elseif verb == "map" and is_admin then
            local target = ...

            if target == "mission" then
                g_savedata.mission_mapped = not g_savedata.mission_mapped
            elseif target == "zone" then
                g_savedata.zone_mapped = not g_savedata.zone_mapped

                for i = 1, #g_savedata.zones do
                    server.removeMapID(-1, g_savedata.zones[i].marker_id)
                    map_zone(g_savedata.zones[i])
                end
            elseif target == "object" then
                g_savedata.object_mapped = not g_savedata.object_mapped
            end
        elseif verb == "limit-count" and is_admin then
            g_savedata.mission_count_limited = not g_savedata.mission_count_limited
        elseif verb == "limit-range" and is_admin then
            g_savedata.mission_range_limited = not g_savedata.mission_range_limited
        elseif verb == "gather" and is_admin then
            local mission_id = ...
            mission_id = tonumber(mission_id)
            local transform, is_success = server.getPlayerPos(peer_id)

            for i = #g_savedata.objects, 1, -1 do
                if g_savedata.objects[i].tracker == "rescuee" and g_savedata.objects[i].mission == mission_id then
                    server.setObjectPos(g_savedata.objects[i].id, transform)
                end
            end
        elseif verb == "cpa-recurrence" and is_admin then
            g_savedata.subsystems.cpa_recurrence = not g_savedata.subsystems.cpa_recurrence

            console.notify(string.format("CPA Recurrence: %s", g_savedata.subsystems.cpa_recurrence))
        elseif verb == "clear-history" and is_admin then
            g_savedata.locations_history = {}
        end
    elseif command == "?clear" then
        server.command(string.format("?clpv %d", peer_id))
    elseif command == "?kill" then
        local object_id = server.getPlayerCharacterID(peer_id)
        server.killCharacter(object_id)
        server.command(string.format("?clpv %d", peer_id))
    end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    if peer_id < 0 or name == "Server" then
        return
    end

    for i = 1, #g_savedata.zones do
        map_zone(g_savedata.zones[i], peer_id)
    end

    local transform = server.getPlayerPos(peer_id)

    if is_in_landscape(transform, "first_spawn") then
        teleport_to_spawn_points(peer_id)
    end
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
end

function onPlayerRespawn(peer_id)
    local player = table.find(players, function(p)
        return p.id == peer_id
    end)

    teleport_to_spawn_points(peer_id)
    transact(-10000, string.format("%s bought a new life.", player.name))
end

spawn_by_foundation = false

function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
    if spawn_by_foundation then
        return
    end

    local vehicle_ids = server.getVehicleGroup(group_id)
    local data = server.getVehicleData(vehicle_ids[1])
    local object = {}
    local owner = nil
    local cost = nil

    if peer_id >= 0 then
        local player = table.find(players, function(x)
            return x.id == peer_id
        end)

        if player ~= nil then
            owner = player.steam_id
        else
            owner = nil
        end

        cost = group_cost
    end

    object.tags_full = data.tags_full
    object.tags = parse_tags(object.tags_full)
    object.display_name = ""
    object.type = "vehicle"
    object.transform = server.getVehiclePos(vehicle_ids[1])
    object.id = vehicle_ids[1]
    object.object_id = nil
    object.group_id = group_id
    object.vehicle_ids = vehicle_ids

    local test = false

    for k, v in pairs(object_trackers) do
        test = test or v:test_type(object.id, object.type, object, nil, nil, owner, cost)
    end

    if test then
        initialize_object(object.id, object.type, object, nil, nil, owner, cost)
    end
end

function onVehicleLoad(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id and g_savedata.objects[i].tracker ~= nil then
            loaded_object(g_savedata.objects[i])
        end
    end
end

function onVehicleUnload(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id and g_savedata.objects[i].tracker ~= nil then
            unloaded_object(g_savedata.objects[i])
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
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            clear_object(g_savedata.objects[i])
        end
    end
end

function onToggleMap(peer_id, is_open)
    g_savedata.players_map[peer_id] = is_open
end

function onCreate(is_world_create)
    load_zones()
    load_locations()

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker ~= nil then
            setmetatable(g_savedata.objects[i], object_trackers[g_savedata.objects[i].tracker])
        end
    end

    for i = 1, #g_savedata.missions do
        setmetatable(g_savedata.missions[i], mission_trackers[g_savedata.missions[i].tracker])
    end

    console.notify(string.format("Locations: %d", #g_savedata.locations))
    console.notify(string.format("Zones: %d", #g_savedata.zones))
    console.notify(string.format("Gone missions: %d", #g_savedata.locations_history))
    console.notify(string.format("Active missions: %d", #g_savedata.missions))
    console.notify(string.format("Active objects: %d", #g_savedata.objects))
end

function onEquipmentDrop(object_id_actor, object_id_target, equipment_id)
    local is_npc = false

    for i = #g_savedata.objects, 1, -1 do
        is_npc = is_npc or g_savedata.objects[i].type == "character" and g_savedata.objects[i].id == object_id_actor
    end

    server.despawnObject(object_id_target, is_npc)
end

-- utils

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
    return #g_savedata.missions < math.min(#players / g_savedata.mission_spawn_when_players_x, 48)
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

function parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([%w_-]+)") do
        t[k] = v
    end

    return t
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
        server.announce("[Mission Foundation]", text, peer_id)
    end
end

function console.error(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[Mission Foundation]", text, peer_id)
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
            table.insert(items, selector(value))
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

function string.split(text, sepatator)
    local result = {}

    for sub in string.gmatch(text, "([^" .. sepatator .. "])") do
        table.insert(result, sub)
    end
end

function setmetatable(table1, table2)
    for k, v in pairs(table2) do
        table1[k] = v
    end
end
