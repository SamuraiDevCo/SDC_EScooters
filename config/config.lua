SDC = {}

---------------------------------------------------------------------------------
-------------------------------Important Configs---------------------------------
---------------------------------------------------------------------------------
SDC.Framework = "qb-core" --Either "qb-core" or "esx"
SDC.Target = "qb-target" --Either "qb-target" or "ox-target"
SDC.NotificationSystem = "framework" -- ['mythic_old', 'mythic_new', 'tnotify', 'okoknotify', 'print', 'framework', 'none'] --Notification system you prefer to use
SDC.Fuel = "none" --Put your fuel script here, options: ['none', 'LegacyFuel'] (If you have others it should be fine to just put the resource name)

SDC.Identifier = "license" --Can be one of the following: ["license", "steam", "discord", "fivem"] (Used For Syncing Ownership Of Scooters)

SDC.SyncTimer = 5 --How often you want to server to keep updating the client to ensure a full sync (In Seconds)

SDC.PricePerMin = 0.5 --Money per minute (Will round if decimal)
---------------------------------------------------------------------------------
-------------------------------Scooter Configs-----------------------------------
---------------------------------------------------------------------------------
SDC.EScooterModel = "serv_electricscooter" --Electric Scooter Model Used
SDC.SpawnScooterDist = 50 --How close you have to be for it to spawn the localized scooters
SDC.MaxRentTime = { --How long someone can rent for (Suggest keeping it default or lower for better optimization)
    Hours = 2,
    Minutes = 60 
}
SDC.HighlightedColor = {r = 239, g = 245, b = 66, a = 200} --The color used when highlighting the scooter when in menu!

SDC.DrawScooterIcon = {Enabled = true, DistanceToSee = 10} --If you want it to draw the 3D Icon on top of the scooters!

SDC.DrawScooterBlips = {Enabled = false, Sprite = 494, Color = 5, Size = 0.5} --If you want to draw blips for all available scooters!

SDC.ScooterMenuKeybind = 38 --The keybind to open the scooter menu (IF CHANGED MAKE SURE TO CHANGE LANG!) https://docs.fivem.net/docs/game-references/controls/
---------------------------------------------------------------------------------
-------------------------------Spawn Configs-------------------------------------
---------------------------------------------------------------------------------

SDC.Spawnpoints = { --All Scooter Spawnpoints 
    vec4(241.8419, -885.2728, 30.5317, 158.2723),
    vec4(230.3963, -881.3526, 30.5346, 64.2171),
    vec4(279.5954, -592.8565, 43.2464, 246.2332),
    vec4(282.6895, -579.7863, 43.2476, 349.1795),
    vec4(236.2749, -873.5737, 30.6206, 240.7678),
    vec4(200.8399, -849.3732, 30.7199, 81.6269),
    vec4(-1006.6062, -683.2095, 21.7083, 51.0773),
    vec4(-1014.0896, -688.6256, 21.3398, 127.4262),
    vec4(-1001.9346, -678.6621, 21.9979, 298.0887),
    vec4(-480.0173, -246.9505, 35.9162, 285.1170),
    vec4(-473.9165, -227.1300, 36.3373, 12.2042),
    vec4(-546.6675, -275.1103, 35.2361, 107.0277),
    vec4(291.3258, -562.5341, 43.1966, 328.8531),
    vec4(257.8576, -636.0508, 40.6812, 184.6945),
    vec4(254.3983, -647.1673, 39.7614, 137.3624),
    vec4(-591.6978, 23.9737, 43.4788, 70.5566),
    vec4(-610.4555, 23.3264, 42.1444, 113.9848),
    vec4(-630.0325, 22.3781, 40.3179, 64.6640),
    vec4(-350.3904, -32.2980, 47.4211, 215.6756),
    vec4(-336.2121, -38.0604, 47.7966, 289.3040),
    vec4(134.8828, -205.8460, 54.4464, 210.6974),
    vec4(154.0213, -212.4207, 54.2735, 296.0115),
    vec4(183.2415, -221.9108, 54.0215, 233.0902),
    vec4(195.3369, -227.0624, 53.9687, 285.0003),
    vec4(411.9117, -967.3591, 29.4552, 199.0708),
    vec4(418.7862, -964.5440, 29.4195, 294.4885),
    vec4(417.5652, -995.8370, 29.2947, 180.0669),
    vec4(416.3379, -1010.7010, 29.2542, 142.4312),
    vec4(296.5921, -1085.3510, 29.4111, 139.9930),
    vec4(295.3467, -1099.5157, 29.4041, 207.1241),
    vec4(24.6642, -1120.7675, 29.2157, 116.5499),
    vec4(5.8525, -1122.3372, 28.3743, 62.9961),
    vec4(-44.5927, -1124.7053, 26.0529, 100.0383),
    vec4(-57.0575, -1792.1688, 27.5992, 190.8807),
    vec4(-38.2153, -1831.9248, 26.1269, 278.6127),
    vec4(15.0806, -1855.1803, 23.8266, 246.1895),
    vec4(45.6076, -1901.8096, 21.6649, 213.5999),
    vec4(409.5134, -1611.1456, 29.2906, 200.6810),
    vec4(395.8450, -1600.7079, 29.2916, 31.0628),
    vec4(-523.9742, -614.6896, 30.4355, 66.6662),
    vec4(-540.2689, -615.5107, 30.4356, 104.3273),
    vec4(-562.1044, -614.2328, 30.4356, 157.4921),
    vec4(-1019.0232, -2738.9795, 13.7536, 220.5206),
    vec4(-1000.3819, -2746.6033, 13.7566, 268.9282),
    vec4(-1034.8414, -2730.8958, 13.7566, 35.2432),
    vec4(-1054.8853, -2719.6724, 13.7566, 82.4059),
    vec4(-1044.9630, -2730.1724, 20.0898, 181.3472),
    vec4(-1025.7563, -2739.6052, 20.1693, 249.2892),
    vec4(-54.7701, -791.5267, 44.2210, 134.5152),
    vec4(-68.2802, -786.5759, 44.2273, 65.1498)
}