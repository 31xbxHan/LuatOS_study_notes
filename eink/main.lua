PROJECT = "eink154"
VERSION = "1.0.0"

-- sys库是标配
_G.sys = require("sys")
image = require("image")
--添加硬狗防止程序卡死
if wdt then
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end

--[[
显示屏为GDEY0154D67,200x200,快刷屏
硬件接线
显示屏SPI   -->  ESP32C3 SPI2
BUSY                11          纸忙信号
RES                 10          复位信号（低电平有效
D/C                 06          数据1/命令0
CS                  07          片选（低电平有效
SCK                 02          SPI时钟
SDI                 03          SPI数据
]]

full, spiid, pin_busy, pin_reset, pin_dc, pin_cs = 0, 2, 11, 10, 6, 7
num = 1
str = ""
for i = 1, #image do
    str = str..string.char(image[i])
end

sys.taskInit(function()
    log.info("refresh start!")
    spi.setup(spiid,nil,0,0,8,20*1000*1000)
    eink.model(eink.MODEL_1in54_V2)
    log.info("eink.setup", eink.setup(full,spiid,pin_busy,pin_reset,pin_dc,pin_cs))
    eink.setWin(200, 200, 3)
    -- eink.setFont(eink.font_opposansm32_chinese)
    sys.wait(100)
    -- eink.clear()
    eink.drawXbm(0, 0, 200, 200, str)
    eink.show()
end

)
sys.run()
