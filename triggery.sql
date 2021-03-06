CREATE TRIGGER reservationMaxCount
  ON Reservations
  AFTER INSERT, UPDATE
  AS
  IF exists(select *
            from inserted i
            where dbo.conference_day_occupied_seats (i.DayOfConferenceID) >
            (select QuantityOfSeats from DaysOfConference d where d.DayOfConferenceID = i.DayOfConferenceID))
      BEGIN
        raiserror('Za mało wolnych miejsc', -1, 1)
        rollback transaction
      END

CREATE TRIGGER workshopReservationMaxCount
  ON Reservations
  AFTER INSERT, UPDATE
  AS
  IF exists(select *
            from inserted i
            where dbo.workshop_occupied_seats (i.WorkshopID) >
            (select w.QuantityOfSeats from Workshops w where w.WorkshopID = i.WorkshopID))
      BEGIN
        raiserror('Za mało wolnych miejsc', -1, 1)
        rollback transaction
      END

CREATE TRIGGER worshopBadDay
  ON Workshops
  AFTER INSERT
  AS
  IF exists(select *
           from inserted i join DaysOfConference dc
           on i.DayOfconferenceID = dc.DayOfConferenceID
           where (dc.Date < i.StartTime or dc.Date < i.EndTime) and i.DayOfConferenceID = dc.DayOfConferenceID)
      BEGIN
        raiserror ('Zła data warsztatów', -1, 1)
        rollback transaction
      end


 CREATE TRIGGER Cancel_reservation --nie wiem czy tak ma to być
  ON Members
	AFTER INSERT ,UPDATE
	AS
	IF (SELECT * FROM inserted i JOIN DaysOfConference dc ON i.DayOfConferenceID = dc.DayOfConferenceID
		    WHERE (DATEDIFF(day, dc.Date, GETDATE())<7 ) AND Is_paid = 0)
	BEGIN
		CancelMember inserted
	end
