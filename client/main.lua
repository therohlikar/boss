local isSpawned, isDead, isOpened = false, false, false
local jobName, jobGrade, gradeRank = nil, nil, nil  

local job = nil
local deal = nil 

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")

    if status == "spawned" or status == "dead" then 
        isSpawned = true
        isDead = (status == "dead")

        if jobName == nil then jobName = exports.data:getCharVar("job") local jobGrade = exports.data:getCharVar("job_grade") gradeRank = exports.data:getJobGradeVar(jobName, jobGrade, "rank") end
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated",
    function(status)
        if status == "spawned" or status == "dead" then 
            isSpawned = true
            isDead = (status == "dead")

            if jobName == nil then jobName = exports.data:getCharVar("job") local jobGrade = exports.data:getCharVar("job_grade") gradeRank = exports.data:getJobGradeVar(jobName, jobGrade, "rank") end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated",
    function(job, grade, duty)
        if job ~= jobName then 
            jobName = job 
        end
        if grade ~= jobGrade then 
            jobGrade = grade 
            gradeRank = exports.data:getJobGradeVar(jobName, grade, "rank")
        end
    end
)

RegisterNetEvent("boss:update")
AddEventHandler("boss:update",
    function(jobname, data, oldjob, olddata)
        if isSpawned then 
            if jobname == jobName then 
                job = data 
            end

            if (oldjob ~= nil and oldjob == jobName and olddata ~= nil) then 
                job = olddata
            end
        end
    end
)

RegisterNetEvent("boss:deal")
AddEventHandler("boss:deal",
    function(gotdeal)
        TriggerEvent("chat:close")
        Citizen.Wait(100)
        deal = gotdeal
        SendNUIMessage({
            action = "showdeal",
            content = table.concat(formatDealContent())
        })
        SetNuiFocus(true, true)
    end
)

RegisterNetEvent("boss:dealResult")
AddEventHandler("boss:dealResult",
    function(status)
        if status == true then 
            exports.notify:display({type = "success", title = "Smlouva", text = "Smlouva podepsána.", icon = "fas fa-briefcase", length = 3500})
        else 
            exports.notify:display({type = "error", title = "Smlouva", text = "Podepsání smlouvy odmítnuto.", icon = "fas fa-briefcase", length = 3500})
        end

        deal = nil 
        SendNUIMessage({
            action = "hide"
        })
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback("closepanel",
    function(data, cb)
        SendNUIMessage({
            action = "hide"
        })
        SetNuiFocus(false, false)

        if deal ~= nil then
            TriggerServerEvent("boss:dealResult", deal, false) 
            deal = nil 
        end
    end
)

RegisterNUICallback("signdeal",
    function(data, cb)
        TriggerServerEvent("boss:dealResult", deal, true)
        deal = nil 

        SendNUIMessage({
            action = "hide"
        })
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback("updateform",
    function(data, cb)
        local content, leftmenu = formatContent(job, "updateform", data.data, data.form)
        SendNUIMessage({
            action = "opencontent",
            leftmenu = leftmenu,
            content = content
        })
    end
)

RegisterNUICallback("saveupdateform",
    function(data, cb)
        local att = data.value 
        if data.form == "bank" or data.form == "job_grade" then 
            if type(job.employes[data.data][data.form]) == "number" then 
                att = tonumber(att) 
            end
            job.employes[data.data][data.form] = att 
            TriggerServerEvent("boss:updateJobdata", job.name, "employe", data.data, data.form, att)
        elseif data.form == "editgrade_salary" then 
            att = tonumber(att)
            if att > 0 then 
                TriggerServerEvent("boss:updateJobVar", job.name, "salary", att, {index = tonumber(data.data)})
            end
        elseif data.form == "editgrade_label" then 
            TriggerServerEvent("boss:updateJobVar", job.name, "label", att, {index = tonumber(data.data)})
        elseif data.form == "editjob_bank" then 
            TriggerServerEvent("boss:updateJobVar", job.name, "bank", att)
            Citizen.Wait(500)
        elseif data.form == "fire" then 
            TriggerServerEvent("boss:fire", job.name, data.data)
            job.employes[data.data] = nil 
            Citizen.Wait(500)
        elseif data.form == "newemploye" then 
            SendNUIMessage({
                action = "hide"
            })
            SetNuiFocus(false, false)

            TriggerEvent("util:closestPlayer",{
                radius = 3.0
            }, 
            function(player)
                if player then 
                    deal = {
                        source = player,
                        dealer = GetPlayerServerId(PlayerId()),
                        grade = tonumber(data.value),
                        job = job.name 
                    }

                    TriggerServerEvent("boss:deal", deal)
                end
            end)
        else
            data.form = string.sub(data.form, 5)
            job.employes[data.data]["bossdata"] = {
                note = (data.form == "note" and att or (job.employes[data.data]["bossdata"]["note"]==nil and "-" or job.employes[data.data]["bossdata"]["note"])),
                team = (data.form == "team" and att or (job.employes[data.data]["bossdata"]["team"]==nil and "-" or job.employes[data.data]["bossdata"]["team"]))
            }

            att = job.employes[data.data]["bossdata"]
            data.form = "bossdata"

            TriggerServerEvent("boss:updateJobdata", job.name, "employe", data.data, data.form, att)
        end

        
        
        local content, leftmenu = formatContent(job, "main")
        SendNUIMessage({
            action = "opencontent",
            leftmenu = leftmenu,
            content = content
        })
    end
)

RegisterNUICallback("selectmenu",
    function(data, cb)
        local content, leftmenu = formatContent(job, data.menu, (data.data ~= "none" and data.data or {}))
        SendNUIMessage({
            action = "opencontent",
            leftmenu = leftmenu,
            content = content
        })
    end
)

RegisterNUICallback("refreshvehicle",
    function(data, cb)
        local livery = Config.allowedVehicles[job.name][data.vehiclename]["livery"]
        SendNUIMessage({
            action = "refreshvehicles",
            vehicleimage = "https://gtarp.gamesites.cz/img/vehicles/" .. data.vehiclename .. ((livery == nil or livery == 0) and "" or livery) .. ".png",
            vehicleprice = Config.allowedVehicles[job.name][data.vehiclename]["price"]
        })
    end
)

RegisterNUICallback("ordervehicle",
    function(data, cb)
        local jobBank = exports.data:getJobVar(job.name, "bank")
        TriggerServerEvent("boss:orderveh", jobBank, data, job, Config.allowedVehicles[job.name][data.vehiclename]["price"])
    end
)

RegisterNetEvent("boss:orderveh")
AddEventHandler("boss:orderveh",
    function(status, data)
        if status == "done" then 
            local sentTo = 1
            if Config.allowedVehicles[job.name][data.vehiclename]["type"] == "car" then 
                sentTo = exports.data:getJobVar(job.name, "garageid")
            elseif Config.allowedVehicles[job.name][data.vehiclename]["type"] == "heli" then 
                sentTo = exports.data:getJobVar(job.name, "helipad")
            elseif Config.allowedVehicles[job.name][data.vehiclename]["type"] == "boat" then 
                sentTo = exports.data:getJobVar(job.name, "dock")
            end
    
            TriggerServerEvent("v:addVehicle", {
                ["job"] = {
                    ["type"] = exports.data:getJobVar(job.name, "type")
                }
            }, 
            sentTo, 
            {
                ["model"] = data.vehiclename,
                ["modLivery"] = (Config.allowedVehicles[job.name][data.vehiclename]["livery"] ~= nil and Config.allowedVehicles[job.name][data.vehiclename]["livery"] or 0)
            }, 0)
            exports.notify:display({type = "info", title = "Objednávka firemního vozidla", text = "Platba byla přijata a vaše vozidlo odvezeno do garáže/na helipad. Děkujeme.", icon = "fas fa-dollar-sign", length = 3500})
        else 
            print("BOSS ORDERVEHICLE FAILED: " .. status)
            exports.notify:display({type = "warning", title = "Objednávka firemního vozidla", text = "Bankovní účet je neplatný nebo není dostatečný zůstatek.", icon = "fas fa-dollar-sign", length = 3500})
        end

        Citizen.Wait(500)
        local content, leftmenu = formatContent(job, "main")
        SendNUIMessage({
            action = "opencontent",
            leftmenu = leftmenu,
            content = content
        })
    end
)

function openBossMenu(jobname)
    if gradeRank == "boss" or gradeRank == "secondboss" then 
        TriggerServerEvent("boss:open", jobname)
    end
end

RegisterNetEvent("boss:open")
AddEventHandler("boss:open",
    function(jobname, jobdata)
        if jobdata ~= nil then 
            job = jobdata
            SendNUIMessage({
                action = "show",
            })
            SetNuiFocus(true, true)

            local content, leftmenu = formatContent(jobdata, "main")
            SendNUIMessage({
                action = "opencontent",
                leftmenu = leftmenu,
                content = content
            })
        end
    end
)

RegisterNetEvent("boss:loadActive")
AddEventHandler("boss:loadActive",
    function(jobname, jobdata)
        if jobdata ~= nil then 
            job = jobdata
            SendNUIMessage({
                action = "show",
            })
            SetNuiFocus(true, true)

            local content, leftmenu = formatContent(jobdata, "main")
            SendNUIMessage({
                action = "opencontent",
                leftmenu = leftmenu,
                content = content
            })
        end
    end
)

function formatDealContent()
    local content = {}
    table.insert(content, "<ul>")
    table.insert(content, "<li class='deal-title'>Smlouva o pracovní pozici</li>")
    
    table.insert(content, ("<li class='deal-point'>Společnost %s</li>"):format(exports.data:getJobVar(deal.job, "label")))
    table.insert(content, ("<li class='deal-point'>Osobou zastoupenou: %s</li>"):format(deal.dealername))
    table.insert(content, ("<li class='deal-point'>Ke dni: %s</li>"):format(deal.now))
    table.insert(content, "<li class='deal-subtitle'>Specifikace pracovní pozice</li>")
    table.insert(content, ("<li class='deal-point'>Pracovní pozice: %s</li>"):format(exports.data:getJobGradeVar(deal.job, deal.grade, "label")))
    table.insert(content, ("<li class='deal-point'>Mzda: %s</li>"):format(exports.data:getJobGradeVar(deal.job, deal.grade, "salary")))
    
    table.insert(content, "<li class='deal-point'>- podpisem smlouvy souhlasíte s pravidly a zákony společnosti, stejně tak s mlčenlivostí o pravidlech a zákonech se společností spojené</li>")
    table.insert(content, "<li class='deal-point'>- zároveň souhlasíte s mlčenlivostí své mzdy mezi širokou veřejností nebo svými kolegy</li>")
    table.insert(content, "<li class='deal-point'>- souhlasíte také, že svou práci budete vykonávat poctivě, v opačném případě přijmete trest dle nadřízených</li>")
    table.insert(content, "<li class='deal-point'>- souhlasíte, že veškeré dokumenty, které od vás vyžádala zastupující osoba, nejsou nijak zfalšované a jsou tedy pravdivé</li>")
    table.insert(content, "<li class='deal-subtitle'>Bližší informace o nastupující osobě do zaměstnání</li>")
    table.insert(content, ("<li class='deal-point'>Jméno a přijmení: %s</li>"):format(deal.sourcename))
    table.insert(content, ("<li class='deal-point'>Datum narození: %s</li>"):format(deal.sourcebirth))
    table.insert(content, "</ul>")
    table.insert(content, "<div class='deal-button'" .. ((deal.dealer == GetPlayerServerId(PlayerId())) and "" or 'onclick="signDeal()"') .. ">Podepsat smlouvu</div>")
    return content
end

function formatContent(jobdata, menu, data, submenu)
    local content = {}

    local hasGarage = exports.data:getJobVar(jobdata.name, "garageid")
    if hasGarage == nil then hasGarage = 0 end 
    local hasHelipad = exports.data:getJobVar(jobdata.name, "helipad")
    if hasHelipad == nil then hasHelipad = 0 end 
    
    local leftmenu = "<center><ul>   \
                        <li onclick=\"selectMenu('main')\" class='menu-title'><i class='fas fa-info-circle'></i><br><span class='menu-subtitle'>INFORMACE</span></li> \
                        <li onclick=\"selectMenu('employes')\" class='menu-title'><i class='fas fa-users'></i><br><span class='menu-subtitle'>ZAMĚSTNANCI</span></li> \
                        <li onclick=\"selectMenu('grades')\" class='menu-title'><i class='far fa-id-badge'></i><br><span class='menu-subtitle'>SPRÁVA POZIC</span></li> \
                        <li onclick=\"selectMenu('settings')\" class='menu-title'><i class='fas fa-cogs'></i><br><span class='menu-subtitle'>NASTAVENÍ</span></li> \
                        " .. ( (hasGarage > 0 or hasHelipad > 0) and "<li onclick=\"selectMenu('vehicles')\" class='menu-title'><i class='fas fa-shipping-fast'></i><br><span class='menu-subtitle'>FIREMNÍ VOZY</span></li></ul></center>" or "</ul></center")

    if menu == "main" then 
        table.insert(content, "<ul>")
        table.insert(content, ("<li class='content-title'>%s</li>"):format(
            exports.data:getJobVar(jobdata.name, "label") 
        ))
        table.insert(content, ("<li class='content-subtitle ignore'>Bankovní účet na vydání mezd: <span class='content-text'>%s</span></li>"):format(
            exports.data:getJobVar(jobdata.name, "bank") 
        ))
        local employesCounted = (jobdata.countedEmployes == nil and 0 or jobdata.countedEmployes)
        if employesCounted == 0 then 
            for key, value in pairs(jobdata.employes) do 
                if jobdata.employes[key] ~= nil then 
                    employesCounted = employesCounted + 1
                end
            end
            jobdata.countedEmployes = employesCounted
        end
        table.insert(content, ("<li class='content-subtitle ignore'>Aktuálně zaměstnanců celkem: <span class='content-text'>%s</span><span class='move-it-right'><i class='fas fa-user-plus content-icon' onclick=\"selectMenu('addemploye', 0)\"></i></span></li>"):format(
            jobdata.countedEmployes
        ))
        table.insert(content, ("<li class='content-subtitle'>Aktuálně zaměstnanců ve službě: <span class='content-text'>%s</span><span class='move-it-right'><i class='fas fa-th-list content-icon' onclick=\"selectMenu('active', 0)\"></i></span></li>"):format(
            #jobdata.active
        ))

        table.insert(content, "</ul>")
    elseif menu == "active" then 
        table.insert(content, "<ul>")
        for i=1, #jobdata.active do 
            local empId = jobdata.active[i]
            table.insert(content, ("<li class='content-subtitle ignore'>%s %s<span class='move-it-right content-text'>%s</span></li>"):format(
                jobdata.employes[empId].firstname,
                jobdata.employes[empId].lastname,
                exports.data:getJobGradeVar(jobdata.name, jobdata.employes[empId].job_grade, "label")
            ))
            Citizen.Wait(100)
        end
        table.insert(content, "</ul>")
    elseif menu == "employes" then 
        table.insert(content, "<ul>")
        
        for key, value in pairsByKeys(jobdata.employes) do 
            local employe = jobdata.employes[key]
            local gradeLabel = exports.data:getJobGradeVar(jobdata.name, employe.job_grade, "label")
            table.insert(content, ("<li class='content-subtitle'><span class='make-it-fat'>%s</span> %s %s <span class='move-it-right''><i class='fas fa-user-edit content-icon' onclick=\"selectAction('editemploye', '%s')\"></i></span></li>"):format(
                (gradeLabel ~= nil and gradeLabel or "UNKNOWN"),
                employe.firstname,
                employe.lastname,
                employe.id
            ))
        end
        table.insert(content, "</ul>")
    elseif menu == "editemploye" then 
        local employe = jobdata.employes[tonumber(data)]
        table.insert(content, "<ul>")
        local gradeRank = exports.data:getJobGradeVar(jobdata.name, employe.job_grade, "rank")
        if gradeRank ~= "boss" then 
                gradeRank = ("<i class='fas fa-user-minus content-icon' onclick=\"selectMenu('sure', '%s')\"></i><i class='fas fa-user-tag content-icon' onclick=\"openUpdateForm('job_grade', %s)\"></i><br>"):format(
                    employe.id,
                    employe.id
                )
        else gradeRank = "" end 
        table.insert(content, ("<li class='content-title'>".. gradeRank .."%s<br><span class='content-text'>%s</span></li>"):format(
            employe.firstname .. " " .. employe.lastname,
            exports.data:getJobGradeVar(jobdata.name, employe.job_grade, "label")
        ))
        table.insert(content, "</ul>")

        table.insert(content, "<ul>")
        table.insert(content, ("<li class='content-subtitle ignore'>Datum narození: <span class='content-text'>%s</span></li>"):format(
            employe.birth
        ))
        table.insert(content, ("<li class='content-subtitle'>Účet pro výplaty:<span class='content-text'> %s </span><span class='move-it-right'><i class='fas fa-edit content-icon' onclick=\"openUpdateForm('bank', %s)\"></i></span></li>"):format(
            employe.bank,
            employe.id
        ))
        table.insert(content, ("<li class='content-subtitle'>Osobní poznámka: <span class='content-text'>%s</span><span class='move-it-right'><i class='fas fa-edit content-icon' onclick=\"openUpdateForm('bossnote', %s)\"></i></span></li>"):format(
            (employe.bossdata.note == nil and "-" or employe.bossdata.note),
            employe.id
        ))
        table.insert(content, ("<li class='content-subtitle'>Ve firemní skupině: <span class='content-text'>%s</span><span class='move-it-right'><i class='fas fa-edit content-icon' onclick=\"openUpdateForm('bossteam', %s)\"></i></span></li>"):format(
            (employe.bossdata.team == nil and "-" or employe.bossdata.team),
            employe.id
        ))
        table.insert(content, "</ul>")
    elseif menu == "grades" then 
        table.insert(content, "<ul>")
        local grades = exports.data:getJob(jobdata.name).grades
        for i=1, #grades do 
            table.insert(content, ("<li class='content-subtitle'>%s         <span class='content-text'>$%s</span><span class='move-it-right'><i class='fas fa-edit content-icon' onclick=\"openUpdateForm('editgrade_label', %s)\"></i><i class='fas fa-hand-holding-usd content-icon' onclick=\"openUpdateForm('editgrade_salary', %s)\"></i></span></li>"):format(
                grades[i].label,
                grades[i].salary,
                i,
                i
            ))
        end
        table.insert(content, "</ul>")
    elseif menu == "settings" then 
        table.insert(content, "<ul>")
        table.insert(content, ("<li class='content-subtitle'>bankovní účet pro zaslání mezd a platbu objednávek: <span class='content-text'>%s</span><span class='move-it-right'><i class='fas fa-edit content-icon' onclick=\"openUpdateForm('editjob_bank', 0)\"></i></span></li>"):format(
            exports.data:getJobVar(jobdata.name, "bank")
        ))

        if hasGarage > 0 then 
            table.insert(content, ("<li class='content-subtitle'>pořadní číslo garáže, do které se objednávky vozidel dovezou: <span class='content-text'>%s</span></li>"):format(
                hasGarage
            ))
        end  
        
        if hasHelipad > 0 then 
            table.insert(content, ("<li class='content-subtitle'>pořadní číslo helipadu, na který se objednávky dovezou: <span class='content-text'>%s</span></li>"):format(
                hasHelipad
            ))
        end   
        table.insert(content, "</ul>")
    elseif menu == "vehicles" then 
        table.insert(content, "<ul>")
        table.insert(content, "<li class='content-title'>objednání nového vozu</li>")
        if hasGarage > 0 then 
            table.insert(content, ("<li class='content-subtitle ignore'>vůz bude přivezen do garáže s číslem: <span class='content-text'>%s</span></li>"):format(
                hasGarage
            ))
        end
        if hasHelipad > 0 then 
            table.insert(content, ("<li class='content-subtitle ignore'>vrtulník bude dovezen na helipad s číslem: <span class='content-text'>%s</span></li>"):format(
                hasHelipad
            )) 
        end
        local bankAccount = exports.data:getJobVar(jobdata.name, "bank")
        table.insert(content, "<li class='content-subtitle ignore'>bankovní účet: <span class='content-text'>" .. bankAccount .. "</span></li>")
        
        table.insert(content, "<li class='content-subtitle ignore' style='list-style:none;'>model vozu: <select id='vehicles' class='content-selectlist'>")
        local firstVeh = (type(data)=="text" and data or "")
        local labelname = ""
        for key, value in pairs(Config.allowedVehicles[jobdata.name]) do
            if (Config.allowedVehicles[jobdata.name][key]["type"] == "heli" and hasHelipad > 0) or (Config.allowedVehicles[jobdata.name][key]["type"] == "car" and hasGarage > 0) then 
                labelname = GetLabelText(GetDisplayNameFromVehicleModel(key))
                if labelname == "NULL" then labelname = exports.base_vehicles:getVehicleNameByHash(key) end 
                if firstVeh == "" then firstVeh = key end
                table.insert(content, ("<option value='%s'>%s</option>"):format(
                    key,
                    labelname
                ))
            end
        end
        local livery = Config.allowedVehicles[jobdata.name][firstVeh]["livery"]
        table.insert(content, ("</select><img id='vehicle-image' class='content-image' src='https://gtarp.gamesites.cz/img/vehicles/%s.png' width='200px' height='160px'></li>"):format(
            firstVeh .. ((livery == nil or livery == 0) and "" or livery)
        ))
        table.insert(content, ("<li class='content-subtitle ignore'>cena za model: <span class='content-text'>$<span id='vehicle-price'>%s</span></span>"):format(
            Config.allowedVehicles[jobdata.name][firstVeh]["price"]
        ))

        table.insert(content, "</ul>")
        table.insert(content, "<div class='content-button' onclick=\"orderVehicle()\" style='width: 50%;'>Objednat vůz</div>")
    elseif menu == "sure" then 
        table.insert(content, "<ul>")
        table.insert(content, "<li class='content-title' style='list-style:none; text-align:center;'>Potvrďte výpověď pro zaměstance?</li>")
        table.insert(content, "</ul>")
        table.insert(content, ("<div class='content-button' style='background-color: darkred;' onclick=\"fireEmploye(%s)\">ANO</div>"):format(
            tonumber(data)
        ))
        table.insert(content, ("<div class='content-button' onclick=\"selectAction('editemploye', '%s')\">NE</div>"):format(
            tonumber(data)
        ))
    elseif menu == "addemploye" then 
        table.insert(content, "<ul>")
        table.insert(content, "<li class='content-title' style='list-style:none; text-align:center;'>Příjmutí nového zaměstnance</li>")
        table.insert(content, "<li class='content-subtitle ignore'>Zvolte pozici ve firmě</li>")
        local grades = exports.data:getJobVar(jobdata.name, "grades")
        local gradeOptions = ""
        for i=1, #grades do 
            gradeOptions = gradeOptions .. "<input class='content-radio' type='radio' id='" .. i .. "' value='" .. i .. "' name='grades' " .. (i == 1 and 'checked' or '') .. "><label for='" .. i .. "'>".. grades[i].label .. "</label>"
        end

        table.insert(content, ("<li class='content-text' style='list-style:none; '>%s</li>"):format(
            gradeOptions
        ))
        table.insert(content, "</ul>")
        table.insert(content, "<div class='content-button' onclick=\"saveUpdateForm('newemploye', '0')\">Předat smlouvu k podpisu</div>")
    elseif menu == "updateform" then 
        table.insert(content, "<ul>")
        table.insert(content, ("<li class='content-title' style='list-style:none; text-align:center;'>%s</li>"):format(
            Config.setTitle[submenu]
        ))
        local numeric = false 
        if submenu == "job_grade" then 
            local grades = exports.data:getJobVar(jobdata.name, "grades")
            local gradeOptions = ""
            for i=1, #grades do 
                gradeOptions = gradeOptions .. "<input class='content-radio' type='radio' id='" .. i .. "' name='grades' value='" .. i .. "' " .. (jobdata.employes[data].job_grade == i and "checked" or "") .. "><label for='" .. i .. "'>".. grades[i].label .. "</label>"
            end

            table.insert(content, ("<li class='content-text' style='list-style:none; text-align:center;'>%s</li>"):format(
                gradeOptions
            ))
        else
            local setvalue = ""
            if submenu == "bank" then setvalue = tostring(jobdata.employes[data].bank) 
            elseif submenu == "bossnote" then setvalue = tostring(jobdata.employes[data].bossdata.note)
            elseif submenu == "bossteam" then setvalue = tostring(jobdata.employes[data].bossdata.team)
            elseif submenu == "editgrade_salary" then setvalue = tostring(exports.data:getJobGradeVar(jobdata.name, data, "salary"))
            elseif submenu == "editgrade_label" then setvalue = tostring(exports.data:getJobGradeVar(jobdata.name, data, "label"))
            elseif submenu == "editjob_bank" then setvalue = tostring(exports.data:getJobVar(jobdata.name, "bank"))

            end

            table.insert(content, ("<li class='content-text' style='list-style:none; text-align:center;'><input type='text' class='content-textbox' id='tb_textvar' name='tb_textvar' value='%s'></li>"):format(
                ((setvalue == "nil" or setvalue == "empty" or setvalue == nil) and "" or setvalue)
            ))
        end

        table.insert(content, "</ul>")

        if submenu ~= nil then 
            for i=1, #Config.numeroValue do  
                if Config.numeroValue[i] == submenu then numeric = true break end 
            end
        end

        table.insert(content, ("<div class='content-button' onclick=\"saveUpdateForm('%s', %s, %s)\">uložit</li>"):format(
            submenu,
            data,
            tostring(numeric)
        ))
    end
    return table.concat(content), leftmenu
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n) 
    end

    table.sort(a, function(a, b)
        return t[a].job_grade > t[b].job_grade
    end)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
end
