Config = {}
Config.refreshDuration = 60 * 1000 * 5 -- every 5th minute

Config.updateVars = {
    "job", "job_grade", "duty", "bank", "firstname", "lastname", "bonus", "birth", "sex"
}

Config.numeroValue = {
    "job_grade", "bonus", "bank", "editgrade_salary", "editjob_bank"
}

Config.setTitle = {
    ["job_grade"] = "Změna pracovní pozice",
    ["bank"] = "Změna výplatního účtu",
    ["bonus"] = "Přidat zaměstnanci bonus do výplaty",
    ["bossnote"] = "Nastavit poznámku u zaměstnance",
    ["bossteam"] = "Nastavit tým u zaměstnance",
    ["editgrade_salary"] = "Nastavit pozici mzdu",
    ["editgrade_label"] = "Nastavit název pozice",
    ["editjob_bank"] = "Nastavit výplatní účet společnosti"
}

Config.allowedVehicles = {
    ["redwood"] = {
        ["tiptruck"] = { type = "car", price = 3500 }
    },
    ["taxi"] = {
        ["taxi"] = { type = "car", price = 2500 }
    },
    ["bennys"] = {
        ["towtruck"] = { type = "car", price = 2500 }
    },
    ["gacha"] = {
        ["towtruck"] = { type = "car", price = 2500 }
    },
    ["cliffs"] = {
        ["towtruck"] = { type = "car", price = 2500 }
    },
    ["marlowe"] = {
        ["speedo"] = { type = "car", price = 2600 }
    },
    ["faa"] = {
        ["baller4"] = { type = "car", price = 1250 },
        ["seasparrow"] = { type = "heli", price = 45000 },
        ["mammatus"] = { type = "heli", price = 45000 },
        ["nimbus"] = { type = "heli", price = 45000 },
        ["polmav"] = { type = "heli", livery = 3, price = 45000 }
    },
    ["ems"] = {
        ["fd2"] = { type = "car", price = 1250 },
        ["fd3"] = { type = "car", price = 1250 },
        ["fd9"] = { type = "car", price = 1250 },
        ["fd13"] = { type = "car", price = 1250 },
        ["polmav"] = { type = "heli", livery = 3, price = 45000 }
    },
    ["lspd"] = {
        ["explorer16"] = { type = "car", livery = 1, price = 1250 },
        ["charger14"] = { type = "car", livery = 1, price = 1250 },
        ["chgr14"] = { type = "car", price = 1250 },
        ["tahoe"] = { type = "car", livery = 1, price = 1250 },
        ["policeb"] = { type = "car", price = 600 },
        ["vic"] = { type = "car", livery = 1, price = 1250 },
        ["polmav"] = { type = "heli", price = 45000 }
    },
    ["bcso"] = {
        ["explorer16"] = { type = "car", price = 1250 },
        ["charger14"] = { type = "car", price = 1250 },
        ["chgr14"] = { type = "car", price = 1250 },
        ["tahoe"] = { type = "car", price = 1250 },
        ["vic"] = { type = "car", price = 1250 },
        ["ram"] = { type = "car", livery = 1, price = 1250},
        ["polmav"] = {  livery = 2, type = "heli", price = 45000 }
    },
    ["sahp"] = {
        ["vic11"] = { type = "car", price = 1000 },
        ["explorer20"] = { type = "car", price = 1000 },
        ["charger18"] = { type = "car", price = 1000 },
        ["tahoe20"] = { type = "car", price = 1000 },
        ["bmwbike"] = { type = "car", price = 700 },
        ["ram"] = { type = "car", price = 1000 },
        ["polmav"] = {  livery = 1, type = "heli", price = 45000 }
    }
}