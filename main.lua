local frame = CreateFrame("FRAME", "WCLPerfFrame");
frame:RegisterEvent("PLAYER_LOGIN");
local partyMembers = {}

-- 获取玩家基础信息
local function GetInfo()
    -- 获取当前玩家所在的地区ID
    local regionID = GetCurrentRegion()
    -- 当前所在地区的缩写, 1: us, 2: kr, 3: eu, 4: tw, 5: cn
    local country = ({ "us", "kr", "eu", "tw", "cn" })[regionID]
    -- 获取当前玩家所在的服务器名称
    local realmName = GetRealmName()
    -- 获得玩家名称
    local playerName = UnitName("player")

    return realmName, country, playerName
end


-- 获得WCL上该玩家的信息
local function GetWCLInfo(targetPlayerName)
    if type(WP_Database) ~= "table" then
		return nil
	end
    local info = WP_Database[targetPlayerName]
    if type(info) ~= "table" then
        return nil
    end
    return info
end

-- 获得WCL上自己的信息
local function GetSelfWCLInfo()
    local realmName, country, playerName = GetInfo()
    local info = GetWCLInfo(playerName)
    local message = "当前服务器名称: " .. realmName .. "。玩家名称: " .. playerName
    if type(info) ~= "table" then
        message = message .. ".未在WCL上找到该玩家的信息"
        DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. message)
        return nil
    end
    local best = info[1]
    local serverRank = info[2]
    if best then
        message = message .. ". Best: " .. best .. "% "
    end
    if serverRank then
        message = message .. "服务器排名: " .. serverRank
    end
    DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. message)
    return best, serverRank
end

-- 检查是否有新的团队成员加入
local function CheckNewPartyMembers()
    local numMembers = GetNumGroupMembers()
    for i = 1, numMembers do
        local name = GetRaidRosterInfo(i)
        -- 获得这个目标的info
        if not partyMembers[name] then
            partyMembers[name] = true
            local info = GetWCLInfo(name)
            -- 向团队发送新成员加入的信息
            local message = name
            local groupType = IsInRaid() and "RAID" or "PARTY"
            if info then
                if info[1] then
                    message = message .. " Best: " .. info[1] .. "% "
                end
                if info[2] then
                    message = message .. "本服务器职业（天赋）排名: " .. info[2]
                end
            end
            -- 如果 speech 为 true，则向团队发送信息,如果为false，则发送信息到自己的聊天框
            if speech then
                SendChatMessage("欢迎" ..name.. "加入团队。" .. message, groupType)
            else
                DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. message)
            end
        end
    end
end

local function OnPlayerLogin()
    -- 打印插件加载信息
    local message = "WCLPerf插件已加载"
    DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. message)
    -- Register slash command to trigger printing region information
    SLASH_WCLPERF1 = "/wcl"
    SlashCmdList["WCLPERF"] = GetSelfWCLInfo
    -- 打印服务器名称
    GetSelfWCLInfo()

end

local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. "生命烈焰 - 《 長樂 》	欢迎你们加入！")
        -- 加载设置
        LoadSettings() 
        -- 登录后的操作
        OnPlayerLogin()

        -- 在玩家登录时注册监听团队加入事件
        frame:RegisterEvent("GROUP_JOINED")
        frame:RegisterEvent("GROUP_LEFT")
        local numMembers = GetNumGroupMembers()
        for i = 1, numMembers do
            local name = GetRaidRosterInfo(i)
            partyMembers[name] = true
        end
        C_Timer.NewTicker(5, CheckNewPartyMembers) -- 每5秒检查一次团队成员
    elseif event == "GROUP_JOINED" then
        -- 监听到玩家加入了团队，开始检测新成员加入情况
        local playerName = GetUnitName("player")
        DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. playerName .. "已加入团队，开始监听新成员加入情况")
        -- 此处可以编写逻辑来监测新成员加入情况
        -- 每隔一段时间检查团队成员
        local numMembers = GetNumGroupMembers()
        for i = 1, numMembers do
            local name = GetRaidRosterInfo(i)
            partyMembers[name] = true
        end
    elseif event == "GROUP_LEFT" then
        -- 清空partyMembers表
        wipe(partyMembers)
    end
end

frame:SetScript("OnEvent", OnEvent);
frame:RegisterEvent("GROUP_JOINED"); -- 注册团队加入事件