-- 软件名称
addonName = "WCLPerf"
-- 统一颜色
titleColor = "|cff9933ff"
textColor = "|r"
-- 统一开头
noticeTitle = titleColor .. "[" .. addonName .."]" .. textColor
-- 初始化 speech 和保存小地图按钮位置的变量

if type(savedVariables) ~= "table" then
    savedVariables = {}
end

if type(savedVariables.speech) ~= "boolean" then
    savedVariables.speech = true
end


function LoadSettings()
    if savedVariables.speech ~= nil then
        speech = savedVariables.speech
    end
    if savedVariables.minimapPos ~= nil then
        dataObject.minimapPos = savedVariables.minimapPos
    end
end

