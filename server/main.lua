local jobdata = {}

MySQL.ready(function()
    Wait(5)
    MySQL.Async.fetchAll(
        "SELECT firstname, lastname, birth, bank, job, job_grade, duty, bonus, bossdata, sex, identifier, id FROM characters ORDER BY job_grade DESC",
        {},
        function(result)
            for i=1, #result do 
                if jobdata[result[i].job] == nil then print("BOSS: LOADED JOB: " .. result[i].job) jobdata[result[i].job] = {} end 

                jobdata[result[i].job][result[i].id] = result[i]
                jobdata[result[i].job][result[i].id].bossdata = json.decode(jobdata[result[i].job][result[i].id].bossdata)
            end
        end
    )
end)


RegisterServerEvent("boss:open")
AddEventHandler("boss:open",
    function(job)
        local _source = source 
        local activeInJob = {}
        local users = exports.data:getUsers()
        for index, identifier in ipairs(users) do
            local userData = exports.data:getUserByIdentifier(identifier)
            if userData.character ~= nil then 
                if userData.character.job == job then 
                    if (userData.status == "spawned" or userData.status == "dead") and userData.character.duty then 
                        table.insert(activeInJob, userData.character.id)
                    end
                end
            end
        end 
        TriggerClientEvent("boss:open", _source, job, {
            name = job,
            employes = jobdata[job],
            active = activeInJob
        })
    end
)

RegisterServerEvent("boss:updateJobdata")
AddEventHandler("boss:updateJobdata", 
    function(job, subject, charid, var, att, save)
        if subject == "employe" then 
            local users = exports.data:getUsers()
            for index, identifier in ipairs(users) do
                local userData = exports.data:getUserByIdentifier(identifier)
                if userData.character ~= nil then 
                    if userData.character.job == job and userData.character.id == charid then 
                        if userData.status == "spawned" or userData.status == "dead" then 
                            exports.data:updateCharVar(userData.source, var, att)
                            return
                        end
                    end
                end
            end

            jobdata[job][charid][var] = att
            local istable = (type(jobdata[job][charid][var]) == "table")
            if istable then 
                att = json.encode(att)
            end

            MySQL.Async.execute(
                "UPDATE characters SET " .. var .. "=@att WHERE id=@charid AND job=@job",
                {
                    ["@charid"] = charid,
                    ["@job"] = job,
                    ["@att"] = att
                }
            )
        end
    end
)

RegisterServerEvent("boss:fire")
AddEventHandler("boss:fire", 
    function(job, charid)
        local users = exports.data:getUsers()
        for index, identifier in ipairs(users) do
            local userData = exports.data:getUserByIdentifier(identifier)
            if userData.status == "spawned" or userData.status == "dead" then 
                if userData.character.job == job and userData.character.id == charid then 
                    exports.data:updateCharVar(userData.source, "job", "city")
                    exports.data:updateCharVar(userData.source, "job_grade", 1)
                    exports.data:updateCharVar(userData.source, "duty", true)
                    exports.data:updateCharVar(userData.source, "bank", "")
                    return 
                end
            end
        end

        jobdata["city"][charid] = jobdata[job][charid]
        jobdata[job][charid] = nil 

        MySQL.Async.execute(
            "UPDATE characters SET job='city', job_grade='1', duty='1', bank='' WHERE id=@charid ",
            {
                ["@charid"] = charid
            }
        )
    end
)

RegisterServerEvent("boss:orderveh")
AddEventHandler("boss:orderveh", 
    function(sourceAccount, data, job, price)
        local _source, done = source, "missingAccount"
        done = exports.bank:checkFunds(sourceAccount, price, true, true)
        TriggerClientEvent("boss:orderveh", _source, done, data)
    end
)

RegisterServerEvent("boss:deal")
AddEventHandler("boss:deal", 
    function(deal)
        deal.sourcename = exports.data:getCharVar(deal.source, "firstname") .. " " .. exports.data:getCharVar(deal.source, "lastname")
        deal.sourcebirth = exports.data:getCharVar(deal.source, "birth")
        deal.dealername = exports.data:getCharVar(source, "firstname") .. " " .. exports.data:getCharVar(source, "lastname")
        deal.now = os.date("%X %x", os.time())

        TriggerClientEvent("boss:deal", deal.source, deal)
        TriggerClientEvent("boss:deal", deal.dealer, deal)
    end
)

RegisterServerEvent("boss:dealResult")
AddEventHandler("boss:dealResult", 
    function(deal, result)
        if result then 
            exports.data:updateCharVar(deal.source, "job", deal.job)
            exports.data:updateCharVar(deal.source, "job_grade", deal.grade)
            exports.data:updateCharVar(deal.source, "duty", false)
        end

        TriggerClientEvent("boss:dealResult", deal.source, result)
        TriggerClientEvent("boss:dealResult", deal.dealer, result)
    end
)

RegisterServerEvent("data:charUpdated")
AddEventHandler("data:charUpdated", 
    function(_source, character, changedvar, oldatt)
        if isVariableInUpdateNeed(changedvar) then 
            if jobdata[character.job] == nil then jobdata[character.job] = {} end 
            
            if jobdata[character.job][character.id] ~= nil then 
                if changedvar == "job" then 
                    if oldatt ~= character.job then 
                        jobdata[character.job][character.id] = jobdata[oldatt][character.id]
                        jobdata[oldatt][character.id] = nil 
                    end
                else 
                    jobdata[character.job][character.id][changedvar] = character[changedvar]
                end
            else 
                jobdata[character.job][character.id] = character
            end
        end
    end
)

RegisterServerEvent("boss:updateJobVar")
AddEventHandler("boss:updateJobVar",
    function(job, var, att, data)
        if var == "salary" or var == "label" or var == "rank" then 
            local grades = exports.data:getJobVar(job, "grades")
            grades[data.index][var] = att 

            att = grades

            exports.data:updateJobVar(job, "grades", att)
        elseif var == "bank" then 
            exports.data:updateJobVar(job, "bank", att)
        end
    end
)


function isVariableInUpdateNeed(var)
    for i=1, #Config.updateVars do 
        if Config.updateVars[i] == var then 
            return true 
        end
    end
end