PROJECT = "wifidemo"
VERSION = "1.0.0"

--测试支持硬件：ESP32C3
--测试固件版本：LuatOS-SoC_V0003_ESP32C3[_USB].soc

local sys = require "sys"
require "sysplus"

if http == nil and http2 then
    http = http2
end
--添加硬狗防止程序卡死
if wdt then
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end
--wifi信息
local wifiName,wifiPassword = "CMCC-TMcm","qzen97af"
--地区id，请前往https://api.luatos.org/luatos-calendar/v1/check-city/ 查询自己所在位置的id
--天津
local location = "CH030100"
--天气接口信息，丫丫天气免费key
local key = "k1glbvmh1je4qabr"

local function connectWifi()
    log.info("wlan", "wlan_init:", wlan.init())

    wlan.setMode(wlan.STATION)
    wlan.connect(wifiName,wifiPassword,1)

    -- 等待连上路由,此时还没获取到ip
    result, _ = sys.waitUntil("WLAN_STA_CONNECTED")
    log.info("wlan", "WLAN_STA_CONNECTED", result)
    -- 等到成功获取ip就代表连上局域网了
    result, data = sys.waitUntil("IP_READY")
    log.info("wlan", "IP_READY", result, data)
end

local function eink_init()
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
    local full, spiid, pin_busy, pin_reset, pin_dc, pin_cs = 0, 2, 11, 10, 6, 7
    log.info("refresh start!")
    spi.setup(spiid,nil,0,0,8,20*1000*1000)
    eink.model(eink.MODEL_1in54_V2)
    log.info("eink.setup", eink.setup(full,spiid,pin_busy,pin_reset,pin_dc,pin_cs))
    eink.setWin(200, 200, 3)
    sys.wait(100)
end

local function requestHttp()
    -- local code, headers, body = http.request("GET","http://api.yytianqi.com/forecast7d?city="..location.."&key="..key).wait()
    -- local code, headers, body = http.request("GET","https://api.qweather.com/v7/weather/now?location=101010100&key=f46d0276230a4015b432f1d909ba639b").wait()
    local code, headers, body = http.request("GET","http://t.weather.itboy.net/api/weather/city/101030100").wait()
    if code == 200 then
        return json.decode(body)
    else
        log.info("http get failed",code, headers, body)
        sys.wait(500)
        return ""
    end
end

local function eink_fresh()
    body = requestHttp()
    print(body)
    -- 设置为字体,对之后的print有效
    eink.clear()
    eink.setFont(eink.font_opposansm12_chinese)
    eink.print(0,20,"日期:"..body.date)
    eink.print(0,40,"城市:"..body.cityInfo.city)
    eink.print(0,60,"温度:"..body.data.wendu)
    eink.print(0,80,"空气质量:"..body.data.quality)
    eink.print(0,100,"湿度:"..body.data.shidu)
    eink.show()
end

sys.taskInit(function()
    --先连wifi
    connectWifi()
    eink_init()
    while 1 do
        eink_fresh()
        sys.wait(1000*60*60*8)
    end
end)


-- 用户代码已结束---------------------------------------------
-- 结尾总是这一句
sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
