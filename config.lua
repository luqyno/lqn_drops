Config = {}
Config.Language = 'en'

Config.Settings = {
    SearchRadius = 5.0, -- Range for searching fallen objects (5.0 recommended) do not change to avoid bugs.
	CleanupDistance = 20.0  -- How far you have to be for the objects to automatically clean up. (20.0 recommended)
}

Config.Locales = {
    cs = {
        pickup_hat = "Sebrat čepici",
        pickup_glasses = "Sebrat brýle",
        picking_up = "Sbíráš předmět...",
    },
    en = {
        pickup_hat = "Pick up hat",
        pickup_glasses = "Pick up glasses",
        picking_up = "Picking up...",
    }
}

function _L(key)
    return Config.Locales[Config.Language][key] or key
end