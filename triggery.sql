create trigger reservation_max_count
  on Reservations
  after insert,update
  as
  if exists(select *
            from inserted i
            where dbo.conference_day_occupied_seats (i.DayOfConferenceID) >
            (select QuantityOfSeats from DaysOfConference d where d.DayOfConferenceID = i.DayOfConferenceID))
      begin
        raiserror('Za mało wolnych miejsc', -1, 1)
        rollback transaction
      end

create trigger workshop_reservation_max_count
  on Reservations
  after insert,update
  as
  if exists(select *
            from inserted i
            where dbo.workshop_occupied_seats (i.WorkshopID) >
            (select w.QuantityOfSeats from Workshops w where w.Workshops.WorkshopID = i.WorkshopID))
      begin
        raiserror('Za mało wolnych miejsc', -1, 1)
        rollback transaction
      end
