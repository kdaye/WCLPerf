-- 在你的插件初始化代码中
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

function SaveSettings()
    savedVariables.speech = speech
    -- 保存当前小地图按钮的位置
    savedVariables.minimapPos = LDBIcon:GetMinimapButton(addonName).minimapPos
end



-- 检查是否成功加载了库
if LDB and LDBIcon then
    local icon = "Interface\\Icons\\INV_EGG_03" -- 初始化图标变量

    local dataObject = LDB:NewDataObject(addonName, {
        type = "launcher",
        text = addonName, -- 按钮上显示的文本
        icon = icon, -- 按钮上显示的图标
        OnClick = function(clickedframe, button)
            if button == "LeftButton" then
                -- 处理左键点击事件的逻辑
                -- 点击切换 speech = true or false
                speech = not speech
                if speech then
                    DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. "团队通报已开启")
                else
                    DEFAULT_CHAT_FRAME:AddMessage(noticeTitle .. "团队通报已关闭")
                end
                SaveSettings() -- 保存 speech
            elseif button == "RightButton" then
                -- 处理右键点击事件的逻辑
            end
        end,
        OnTooltipShow = function(tooltip)
            -- 设置鼠标悬停提示信息
            tooltip:SetText(addonName)
            tooltip:AddLine("点击切换通报开关")
            tooltip:Show()
        end,
    })

    -- 将按钮添加到LibDBIcon
    LDBIcon:Register(addonName, dataObject, {
        hide = false, -- 是否隐藏按钮，默认为false
        -- position = "LEFT", -- 按钮在小地图上的位置，默认为"LEFT"
        minimapPos = dataObject.minimapPos or 180, -- 按钮在小地图上的角度，默认为180
        onClick = dataObject.OnClick, -- 点击事件处理函数
        OnTooltipShow = dataObject.OnTooltipShow -- 鼠标悬停提示函数
    })

end
