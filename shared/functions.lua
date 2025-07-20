FindJobInTable = function(job)
    for index, data in pairs(Config.SharedJobs) do
        for job2, data2 in pairs(data) do
            if job == job2 then
                return index
            end
        end
    end

    return false
end