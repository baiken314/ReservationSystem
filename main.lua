-- Load the Reservation class
local Reservation = require("lib.reservation")

-- Main program
print(" - Welcome to CakeReserve v1.0 - \n")

Reservation.importCsv()

local HOTEL_NAME = "Rainbow Hotel"
local PRINTER_NAME = "printer_0"
local choice = 0

while choice ~= 4 do
    print("1 - Create a new reservation")
    print("2 - View/Edit a reservation")
    print("3 - View reservations")
    print("4 - Print reservation")
    print("Q - Save and quit")
    
    io.write("\nEnter your choice: ")
    local strChoice = io.read()
    print()

    if strChoice == "1" then
        Reservation.promptReservation()
    elseif strChoice == "2" then
        io.write("Enter reservation number to view: ")
        local intReservationNumber = tonumber(io.read())
        local tblReservation = Reservation.getReservationByConfirmation(intReservationNumber)
        if tblReservation then
            print()
            print(tblReservation:toString())
            print()
            io.write("Would you like to edit? (y/n) ")
            local strChoice = io.read()
            if strChoice ~= "N" or strChoice ~= "n" then
                print()
                print("1 - Close reservation")
                print("2 - Cancel reservation")
                print("3 - Activate reservation")
                print("4 - Edit name")
                print("5 - Edit room")
                print("6 - Edit dates")
                print("Q - Do not edit")

                io.write("\nEnter your choice: ")
                local strEditChoice = io.read()

                if strEditChoice == "1" then
                    tblReservation.status = "Closed"
                    print("Reservation #" .. tblReservation.confirmationNumber .. " has been closed.")
                elseif strEditChoice == "2" then
                    tblReservation.status = "Cancelled"
                    print("Reservation #" .. tblReservation.confirmationNumber .. " has been cancelled.")
                elseif strEditChoice == "3" then
                    tblReservation.status = "Active"
                    print("Reservation #" .. tblReservation.confirmationNumber .. " has been set to active.")
                elseif strEditChoice == "4" then
                    io.write("Enter new name: ")
                    tblReservation.name = io.read()
                    print("Reservation #" .. tblReservation.confirmationNumber .. "'s name has been set to " .. tblReservation.name .. ".")
                elseif strEditChoice == "5" then
                    io.write("Enter new room: ")
                    local strRoom = io.read()
                    if Reservation.isRoomAvailable(strRoom, tblReservation.checkIn, tblReservation.checkOut) then
                        tblReservation.room = strRoom
                        print("Reservation #" .. tblReservation.confirmationNumber .. "'s room has been set to " .. tblReservation.room .. ".")
                    else
                        print(strRoom .. " is not available.")
                    end
                elseif strEditChoice == "6" then
                    Reservation.promptDateChange(intReservationNumber)
                    print("")
                    print(tblReservation:toString())
                end
            end
        end
    elseif strChoice == "3" then
        Reservation.sortByCheckIn()
        print("All reservations:")
        for _, reservation in pairs(Reservation.reservations) do
            print(reservation:toString())
        end
    elseif strChoice == "4" then
        io.write("Enter reservation number to print: ")
        local intReservationNumber = tonumber(io.read())
        local tblReservation = Reservation.getReservationByConfirmation(intReservationNumber)
        if tblReservation then
            local tblPrinter = peripheral.wrap(PRINTER_NAME)

            if not tblPrinter then
                error("Printer not found!")
            end

            if tblPrinter.getPaperLevel() == 0 then
                error("There is no paper in the printer!")
            end
              
            if tblPrinter.getInkLevel() == 0 then
                error("There is no ink in the printer!")
            end

            if tblPrinter.newPage() then
                tblPrinter.setCursorPos(1, 1)
                tblPrinter.write(" -- Reservation -- ")
                
                tblPrinter.setCursorPos(1, 3)
                tblPrinter.write("Confirmation #: " .. tblReservation.confirmationNumber)

                tblPrinter.setCursorPos(1, 4)
                tblPrinter.write("Guest: " .. tblReservation.name)

                tblPrinter.setCursorPos(1, 5)
                tblPrinter.write("Room: " .. tblReservation.room)

                tblPrinter.setCursorPos(1, 7)
                tblPrinter.write("Status: " .. tblReservation.status)

                tblPrinter.setCursorPos(1, 9)
                tblPrinter.write("Check-in: " .. tblReservation.checkIn)
                tblPrinter.setCursorPos(1, 10)
                tblPrinter.write("Check-out: " .. tblReservation.checkOut)

                tblPrinter.setCursorPos(1, 12)
                tblPrinter.write("Thank you for staying")
                tblPrinter.setCursorPos(1, 13)
                tblPrinter.write("with us!")

                tblPrinter.endPage()

                print("Reservation #" .. tblReservation.confirmationNumber .. " has been printed!")
            else
                error("Page could not be created.")
            end
        end
    elseif strChoice == "Q" or strChoice == "q" then
        print("Goodbye! Exiting the menu.")
        break
    else
        print("Invalid choice. Please try again.")
    end

    Reservation.exportCsv()
    print()
end