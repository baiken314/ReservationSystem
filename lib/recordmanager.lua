local RecordManager = {}
RecordManager.__index = RecordManager

function RecordManager.new()
    local self = setmetatable({}, RecordManager)
    self.records = {}
    return self
end

function RecordManager:addRecord(record)
    table.insert(self.records, record)
end

function RecordManager:editRecord(index, updatedRecord)
    if index > 0 and index <= #self.records then
        self.records[index] = updatedRecord
    else
        print("Invalid index!")
    end
end

function RecordManager:deleteRecord(index)
    if index > 0 and index <= #self.records then
        table.remove(self.records, index)
    else
        print("Invalid index!")
    end
end

function RecordManager:importCsv(filename)
    local file = io.open(filename, "r")
    if not file then
        print("File not found!")
        return
    end
    
    for line in file:lines() do
        local record = {}
        for value in line:gmatch("[^,]+") do
            table.insert(record, value)
        end
        self:addRecord(record)
    end
    
    file:close()
end

function RecordManager:exportCsv(filename)
    local file = io.open(filename, "w")
    if not file then
        print("File could not be created!")
        return
    end
    
    for _, record in ipairs(self.records) do
        local line = table.concat(record, ",")
        file:write(line.."\n")
    end
    
    file:close()
end

function RecordManager:viewRecords()
    return self.records
end

return RecordManager
