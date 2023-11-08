PROJECT = "project3"
VERSION = "0.0.1"

sys = require"sys"

if wdt then
    --添加硬狗防止程序卡死，在支持的设备上启用这个功能
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end

local LEDA = gpio.setup(5, nil)
local LEDB = gpio.setup(4, nil)
local LEDC = gpio.setup(8, nil)
local LEDD = gpio.setup(9, nil)
local LEDE = gpio.setup(6, nil)

sys.taskInit(function()
    while 1 do
        sys.wait(50)
        print(LEDA(), LEDB(),LEDC(), LEDD(), LEDE())
    end
end)

sys.run()
