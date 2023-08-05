local Reservation = require("lib.reservation")

--Reservation:promptReservation()

Reservation.new("Player1", 101, {year = 2023, month = 8, day = 10}, {year = 2023, month = 8, day = 15})
Reservation.new("Player2", 102, {year = 2023, month = 8, day = 12}, {year = 2023, month = 8, day = 14})

for _, reservation in pairs(Reservation.reservations) do
    print(reservation:toString())
end