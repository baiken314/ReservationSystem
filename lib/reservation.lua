-- Reservation class
local Reservation = {}

-- Static list of reservations (placeholder for data persistence)
Reservation.reservations = {}

-- Constructor (Initializer)
function Reservation.new(name, room, checkIn, checkOut)
    local self = {}

    -- Properties
    self.name = name
    self.room = room
    self.checkIn = checkIn
    self.checkOut = checkOut

    table.insert(Reservation.reservations, self)

    return self
end

local function areDateRangesOverlapping(range1Start, range1End, range2Start, range2End)
    return range1Start <= range2End and range2Start <= range1End
end

-- Function to validate date format (mm/dd/yyyy or mm-dd-yyyy)
local function isValidDateFormat(dateString)
    if not dateString then return false end
    return dateString:match("^%d%d/%d%d/%d%d%d%d$") ~= nil
end

function Reservation:toString()
    local function formatDate(date)
        return string.format("%04d-%02d-%02d", date.year, date.month, date.day)
    end

    local checkOutStr = self.checkOut and formatDate(self.checkOut) or "N/A" -- If checkOut is nil, display "N/A" instead

    return "Reservation for " .. self.name .. " - Room " .. self.room ..
           ", Check-in: " .. formatDate(self.checkIn) .. ", Check-out: " .. checkOutStr
end

function Reservation:isRoomAvailable(room, checkIn, checkOut)
    if not self.reservations then return true end  -- there are no reservations
    for _, reservation in pairs(self.reservations) do
        if  reservation.room == room 
            and areDateRangesOverlapping(checkIn, checkOut, reservation.checkIn, reservation.checkOut) then
            return false
        end
    end
    return true
end

function Reservation:promptReservation()
    local userInfo = {}

    -- Get user's name
    io.write("Enter your name: ")
    userInfo.name = io.read()

    -- Get room number
    io.write("Enter your room number: ")
    userInfo.room = io.read()

    -- Get check-in date
    io.write("Enter check-in date (mm/dd/yyyy): ")
    local checkInDateInput
    while not checkInDateInput or not isValidDateFormat(checkInDateInput) do
        checkInDateInput = io.read()
        if not isValidDateFormat(checkInDateInput) then
            print("Invalid date format... please try again: ")
        end
    end
    local month, day, year = checkInDateInput:match("(%d+)/(%d+)/(%d+)")
    userInfo.checkInDate = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day)
    }

    -- Get check-out date
    io.write("Enter check-out date (mm/dd/yyyy): ")
    local checkOutDateInput
    while not checkOutDateInput or not isValidDateFormat(checkOutDateInput) do
        checkOutDateInput = io.read()
        if not isValidDateFormat(checkOutDateInput) then
            print("Invalid date format... please try again: ")
        end
    end
    local month, day, year = checkOutDateInput:match("(%d+)/(%d+)/(%d+)")
    userInfo.checkOutDate = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day)
    }

    -- check if reservatin is valid
    if not self.isRoomAvailable(userInfo.room, os.time(userInfo.checkInDate), os.time(userInfo.checkOutDate)) then
        print("Room " .. userInfo.room .. " is not available for this time.")
    end

    -- create reservation
    self.new(userInfo.name, userInfo.room, userInfo.checkInDate, userInfo.checkOutDate)
    print("Your reservation has been created.")
end

return Reservation
