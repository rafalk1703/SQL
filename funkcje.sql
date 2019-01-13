CREATE FUNCTION conference_day_free_seats
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

CREATE FUNCTION workshop_free_seats
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

CREATE FUNCTION conference_day_occupied_seats
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


CREATE FUNCTION workshop_occupied_seats
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

CREATE FUNCTION day_price_on_date
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

CREATE FUNCTION how_many_cancelled
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
