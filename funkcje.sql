CREATE FUNCTION conference_day_free_seats --sprawdza ile wolnych miejsc na danej konferencji
	(
	@DayOfConferenceID int
	)
	RETURNS int
	AS
	BEGIN
		DECLARE @allSeats int = (SELECT QuantityOfSeats FROM DaysOfConference WHERE DayOfConferenceID = @DayOfConferenceID)
		DECLARE @occupiedSeats int = (SELECT sum(QuantityOfSeats) FROM Reservations WHERE DayOfConferenceID = @DayOfConferenceID)
		DECLARE @isCancelled int = (SELECT COUNT(DayOfConferenceID) FROM DaysOfConference WHERE DayOfConferenceID = @DayOfConferenceID AND isCancelled = 1)
		DECLARE @freeSeats int = @allSeats - @occupiedSeats + @isCancelled
		IF @allSeats IS NULL
        SELECT @freeSeats = 0
    RETURN @freeSeats
  end

CREATE FUNCTION workshop_free_seats --sprawdza ile wolnych miejsc na danych warsztatach
	(
	@WorkshopID int
	)
  RETURNS int
	AS
	BEGIN
		DECLARE @allSeats int = (SELECT QuantityOfSeats FROM Workshops WHERE WorkshopID = @WorkshopID)
		DECLARE @occupiedSeats int = (SELECT sum(QuantityOfSeats) FROM Reservations WHERE WorkshopID = @WorkshopID)
		DECLARE @isCancelled int = (SELECT COUNT(WorkshopID) FROM Workshops WHERE WorkshopID = @WorkshopID AND isCancelled = 1)
		DECLARE @freeSeats int = @allSeats - @occupiedSeats + @isCancelled

		IF @allSeats IS NULL
        SELECT @freeSeats = 0
    RETURN @freeSeats
	end

CREATE FUNCTION conference_day_occupied_seats --sprawdza ile zajetych miejsc na danej konferencji
	(
	@DayOfConferenceID int
	)
	RETURNS int
	AS
	BEGIN
		DECLARE @occupiedSeats int = (SELECT ISNULL(sum(QuantityOfSeats),0) FROM Reservations WHERE DayOfConferenceID = @DayOfConferenceID)
		DECLARE @isCancelled int = (SELECT COUNT(DayOfConferenceID) FROM DaysOfConference WHERE DayOfConferenceID = @DayOfConferenceID AND isCancelled = 1)
    RETURN @occupiedSeats - @isCancelled
  end


CREATE FUNCTION workshop_occupied_seats --sprawdza ile miejsc zajętych na danych warsztatach
	(
	@WorkshopID int
	)
  RETURNS int
	AS
	BEGIN
		DECLARE @occupiedSeats int = (SELECT ISNULL(sum(QuantityOfSeats),0) FROM Reservations WHERE WorkshopID = @WorkshopID)
		DECLARE @isCancelled int = (SELECT COUNT(WorkshopID) FROM Workshops WHERE WorkshopID = @WorkshopID AND isCancelled = 1)
    RETURN @occupiedSeats - @isCancelled
	end

CREATE FUNCTION day_price_on_date --sprawdza ile trzeba zapłacić za daną konferencje w danym czasie
	(
	@DayOfConferenceID int,
	@Date date
	)
	RETURNS int
	AS
	BEGIN
		DECLARE @discount real = ( SELECT TOP 1 Discount FROM PriceCaps
					    WHERE DayOfConferenceID = @DayOfConferenceID AND @Date <= EndDate
					    ORDER BY EndDate)
		DECLARE @price money = ( SELECT Price FROM DaysOfConference WHERE DayOfConferenceID = @DayOfConferenceID)
		RETURN @price * (1 - @discount)
	end

CREATE FUNCTION how_many_cancelled --Sprawdza ile uczetników usuniętych z nia konferencji
	(
	@DayOfConferenceID int
	)
  RETURNS int
  AS
	BEGIN
		DECLARE @isCancelled int = (SELECT count(*) FROM Members
					     WHERE isCancelled = 1 AND DayOFConferenceID = @DayOfConferenceID)
		RETURN @isCancelled
	end
	
	
	
CREATE FUNCTION Is_paid --sprawdza czy opłacona rezerwacja
  (
    @ReservationID int
  )
  RETURNS BIT
  AS
  BEGIN 
    DECLARE @payments_to_pay money

    SELECT @payments_to_pay = SUM(p.Amount) FROM Payments p WHERE p.ReservationID = @ReservationID

    IF (dbo.ToPayForReservation (@ReservationID) <= @payments_to_pay)
      RETURN 1

    RETURN 0
  END 
