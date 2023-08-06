local RecordManager = require("lib.recordmanager")

local Reservation = {}
Reservation.__index = Reservation

Reservation.recordManager = RecordManager.new()
Reservation.reservations = {}

function Reservation.new(strName, strRoom, strCheckIn, strCheckOut, strStatus, intConfirmationNumber)
    local self = setmetatable({}, Reservation)

    -- Properties
    self.confirmationNumber = intConfirmationNumber or #Reservation.reservations + 1
    self.name = strName
    self.room = strRoom
    self.checkIn = strCheckIn
    self.checkOut = strCheckOut
    self.status = strStatus or "Active"

    table.insert(Reservation.reservations, self)

    return self
end

local function areRangesOverlapping(intA1, intA2, intB1, intB2)
    return intA1 < intB2 and intB1 < intA2
end

local function isValidDateFormat(strDate)
    if not strDate then return false end
    return strDate:match("^%d%d/%d%d/%d%d%d%d$") ~= nil
end

local function convertDateToTable(strDate)
    local month, day, year = strDate:match("(%d+)[/-](%d+)[/-](%d+)")
    if not month or not day or not year then
        error("Invalid date format. Expected mm/dd/yyyy or mm-dd-yyyy.")
    end

    return {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day)
    }
end

local function convertDatetoString(tblDate)
    return string.format("%02d/%02d/%04d", tblDate.month, tblDate.day, tblDate.year)
end

local function convertDatetoInt(strDate)
    return os.time(convertDateToTable(strDate))
end

local function compareByCheckIn(tblReservation1, tblReservation2)
    local tblDate1 = convertDateToTable(tblReservation1.checkIn)
    local tblDate2 = convertDateToTable(tblReservation2.checkIn)

    -- Compare the year
    if tblDate1.year ~= tblDate2.year then
        return tblDate1.year < tblDate2.year
    end

    -- Compare the month
    if tblDate1.month ~= tblDate2.month then
        return tblDate1.month < tblDate2.month
    end

    -- Compare the day
    return tblDate1.day < tblDate2.day
end

function Reservation.isRoomAvailable(strRoom, strCheckIn, strCheckOut)
    if not Reservation.reservations then return true end
    if #Reservation.reservations == 0 then return true end

    local intCheckIn = convertDatetoInt(strCheckIn)
    local intCheckOut = convertDatetoInt(strCheckOut)

    for _, reservation in pairs(Reservation.reservations) do

        local intReservationCheckIn = convertDatetoInt(reservation.checkIn)
        local intReservationCheckout = convertDatetoInt(reservation.checkOut)
        
        if  reservation.room == strRoom 
            and areRangesOverlapping(intCheckIn, intCheckOut, intReservationCheckIn, intReservationCheckout) then
            return false
        end
    end
    return true
end

function Reservation.getReservationByConfirmation(intConfirmationNumber)
    for _, reservation in pairs(Reservation.reservations) do
        if reservation.confirmationNumber == intConfirmationNumber then
            return reservation
        end
    end
    return false
end

function Reservation.sortByCheckIn()
    table.sort(Reservation.reservations, compareByCheckIn)
end

function Reservation:toCsvString()
    return self.confirmationNumber .. "," .. self.name .. "," .. self.room .. "," .. self.checkIn .. "," .. self.checkout .. "," .. self.status
end

function Reservation:toString()
    return "Res #" .. self.confirmationNumber .. " for " .. self.name .. ": " .. self.status .. "\n" ..  
        "Room " .. self.room .. ", " .. self.checkIn .. " to " .. self.checkOut
end

function Reservation.promptReservation()
    local tblUserInfo = {}

    -- Get user's name
    io.write("Enter your name: ")
    tblUserInfo.name = io.read()

    -- Get room number
    io.write("Enter your room number: ")
    tblUserInfo.room = io.read()

    -- Get check-in date
    io.write("Enter check-in date (mm/dd/yyyy): ")
    local strCheckInDateInput
    while not strCheckInDateInput or not isValidDateFormat(strCheckInDateInput) do
        strCheckInDateInput = io.read()
        if not isValidDateFormat(strCheckInDateInput) then
            print("Invalid date format... please try again: ")
        end
    end
    tblUserInfo.checkInDate = strCheckInDateInput

    -- Get check-out date
    io.write("Enter check-out date (mm/dd/yyyy): ")
    local strCheckOutDateInput
    while not strCheckOutDateInput or not isValidDateFormat(strCheckOutDateInput) do
        strCheckOutDateInput = io.read()
        if not isValidDateFormat(strCheckOutDateInput) then
            print("Invalid date format... please try again: ")
        end
    end
    tblUserInfo.checkOutDate = strCheckOutDateInput

    -- check if reservatin is valid
    if not Reservation.isRoomAvailable(tblUserInfo.room, tblUserInfo.checkInDate, tblUserInfo.checkOutDate) then
        print("Room " .. tblUserInfo.room .. " is not available for this time.")
        return false
    end

    -- create reservation
    local tblNewReservation = Reservation.new(tblUserInfo.name, tblUserInfo.room, tblUserInfo.checkInDate, tblUserInfo.checkOutDate)
    print("Your reservation has been created.")
    print()
    print(tblNewReservation:toString())
end

function Reservation.promptDateChange(intConfirmationNumber)
    local tblReservation = Reservation.getReservationByConfirmation(intConfirmationNumber)
    if not tblReservation then return false end

    -- Get check-in date
    io.write("Enter check-in date (mm/dd/yyyy): ")
    local strCheckInDateInput
    while not strCheckInDateInput or not isValidDateFormat(strCheckInDateInput) do
        strCheckInDateInput = io.read()
        if not isValidDateFormat(strCheckInDateInput) then
            print("Invalid date format... please try again: ")
        end
    end

    -- Get check-out date
    io.write("Enter check-out date (mm/dd/yyyy): ")
    local strCheckOutDateInput
    while not strCheckOutDateInput or not isValidDateFormat(strCheckOutDateInput) do
        strCheckOutDateInput = io.read()
        if not isValidDateFormat(strCheckOutDateInput) then
            print("Invalid date format... please try again: ")
        end
    end

    -- check if reservatin is valid
    if not Reservation.isRoomAvailable(tblReservation.room, strCheckInDateInput, strCheckOutDateInput) then
        print("Room " .. tblReservation.room .. " is not available for this time.")
        return false
    end

    tblReservation.checkIn = strCheckInDateInput
    tblReservation.checkOut = strCheckOutDateInput

    print("Dates updated.")

    return true
end

function Reservation.exportCsv()
    Reservation.recordManager.records = {}  -- reload with current information
    for _, reservation in pairs(Reservation.reservations) do
        Reservation.recordManager:addRecord({
            reservation.confirmationNumber,
            reservation.name,
            reservation.room,
            reservation.status,
            reservation.checkIn,
            reservation.checkOut
        })
    end
    Reservation.recordManager:exportCsv("reservations.csv")
end

function Reservation.importCsv()
    -- empty system stored information
    Reservation.reservations = {}
    Reservation.recordManager.records = {}

    -- load file stored information
    Reservation.recordManager:importCsv("reservations.csv")
    for _, record in pairs(Reservation.recordManager.records) do
        Reservation.new(record[2], record[3], record[5], record[6], record[4], record[1])
    end
end

return Reservation
