PROJECT = "test"
VERSION = "1.0.0"

local sys = require "sys"

--添加硬狗防止程序卡死
if wdt then
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end

sys.taskInit(function()
    for index, value in ipairs(fonts.list(tp)) do
        print(index, value)
    end
end)

sys.run()
