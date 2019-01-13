CREATE PROCEDURE AddConference
	@ConferenceName nvarchar(50),
	@Address nvarchar(50),
	@Phone varchar(10),
	@Fax varchar(10) = null,
	@StudentDiscount real
	AS
	BEGIN
	SET nocount ON
	
	INSERT INTO ConferenceDetails(
		ConferenceName,
		Address,
		Phone,
		Fax,
		StudentDiscount
	) VALUES (
		@ConferenceName,
		@Address,
		@Phone,
		@Fax,
		@StudentDiscount
	)
	END

CREATE PROCEDURE AddConferenceDay
	@ConferenceName int,
	@QuantityOfSeats int,
	@Date datetime,
	@Price money
	AS
	BEGIN
		SET nocount ON
		DECLARE @ConferenceDetailsID int = (SELECT ConferenceDetailsID FROM ConferenceDetails WHERE ConferenceName=@ConferenceName)
		INSERT INTO DaysOfConference (
			ConferenceDetailsID,
			QuantityOfSeats,
			Date,
			Price
		) VALUES (
			@ConferenceDetailsID,
			@QuantityOfSeats,
			@Date,
			@Price
		)
	END


CREATE PROCEDURE AddCustomer
	@CustomerName nvarchar(50),
	@isCompany bit,
	@Email nvarchar(10),
	@Phone varchar(10),
	@Address nvarchar(50),
	@Registrationdate datetime
	AS
	BEGIN
		SET nocount ON
		INSERT INTO Customers (
		CustomerName,
		isCompany,
		Email,
		Phone,
		Address,
		Registrationdate
		) VALUES (
			@CustomerName,
			@isCompany,
			@Email,
			@Phone,
			@Address,
			@Registrationdate
		)
	END


CREATE PROCEDURE AddWorkshop
	@DayOfConferenceID int,
	@WorkshopName nvarchar(50),
	@Price real,
	@StartTime datetime,
	@EndTime datetime,
	@QuantityOfSeats int,
	@Details nvarchar(50) = null
	AS
	BEGIN
		SET nocount on
		INSERT INTO Workshops
		(
			DayOfConferenceID,
			WorkshopName,
			Price,
			StartTime,
			EndTime,
			QuantityOfSeats,
			Details
		) VALUES (
			@DayOfConferenceID,
			@WorkshopName,
			@Price,
			@StartTime,
			@EndTime,
			@QuantityOfSeats,
			@Details
		)
	END

CREATE PROCEDURE AddMember
	@CustomerID int,
	@DayOfConferenceID int,
	@ReservationFromID int = null
	AS
	BEGIN
		SET nocount on
		INSERT INTO Members (
			CustomerID,
			DayOfConferenceID,
			ReservationDate,
			ReservationFromID,
			isCancelled
		) VALUES (
			@CustomerID,
			@DayOfConferenceID,
			CURRENT_TIMESTAMP,
			@ReservationFromID,
			0
		)
	END

CREATE PROCEDURE AddPayment
	@MemberID int,
	@ReservationID int,
	@Amount money,
	@AccountNumber varchar(10) = null,
	@PaymentDetails nvarchar(50) = null
	AS
	BEGIN
		SET nocount ON
		INSERT INTO Payments
		(
			MemberID,
			ReservationID,
			Amount,
			AccountNumber,
			PaymentDetails,
			Date
		) VALUES (
			@MemberID,
			@ReservationID,
			@Amount,
			@AccountNumber,
			@PaymentDetails,
			CURRENT_TIMESTAMP
		)
	END

CREATE PROCEDURE AddReservation
	@CustomerID int,
	@DayOfConferenceID int,
	@WorkshopID int=null,
	@QuantityOfSeats int,
	@QuantityOfStudents int
	AS
	BEGIN
		SET nocount ON
		INSERT INTO Reservations (
			CustomerID,
			DayOfConferenceID,
			WorkshopID,
			ReservationDate,
			QuantityOfSeats,
			QuantityOfStudents
		) VALUES (
			@CustomerID,
			@DayOfConferenceID,
			@WorkshopID,
			CURRENT_TIMESTAMP,
			@QuantityOfSeats,
			@QuantityOfStudents
		)
	END




CREATE PROCEDURE AddWorkshopMember
	@MemberID int,
	@WorkshopID int
	AS
	BEGIN
		SET nocount ON
		INSERT INTO WorkshopsMembers(
			MemberID,
			WorkshopID
		) VALUES (
			@MemberID,
			@WorkshopID
		)
	END


CREATE PROCEDURE AddPriceCap
	@DayOfConferenceID int,
	@Discount real,
	@StartDate datetime,
	@EndDate datetime
	AS
	BEGIN
		SET nocount ON
		INSERT INTO PriceCaps(
			DayOfConferenceID,
			Discount,
			StartDate,
			EndDate
		) VALUES (
			@DayOfConferenceID,
			@Discount,
			@StartDate,
			@EndDate
		)
	END


CREATE PROCEDURE ChangeCustomerData --bad
	@CustomerName nvarchar(50) = null,
	@isCompany bit = null,
	@Email nvarchar(10),
	@Phone varchar(10) = null,
	@Address nvarchar(50) = null
	AS
	BEGIN
		SET nocount ON;
		IF @CustomerName IS NOT NULL
		BEGIN
			UPDATE Customers
			SET CustomerName=@CustomerName
			WHERE Email=@Email
		END
		IF @isCompany IS NOT NULL
		BEGIN
			UPDATE Customers
			SET isCompany=@isCompany
			WHERE Email=@Email
		END
		IF @Phone IS NOT NULL
		BEGIN
			UPDATE Customers
			SET Phone=@Phone
			WHERE Email=@Email
		END
		IF @Address IS NOT NULL
		BEGIN
			UPDATE Customers
			SET Address=@Address
			WHERE Email=@Email
		END
	END

CREATE PROCEDURE CancelMember --dodac error czy sitnieje
	@MemberID int
	AS
	BEGIN
		SET nocount ON
		UPDATE Members
		Set isCancelled = 1
		WHERE MemberID = @MemberID
	END


CREATE PROCEDURE ChangeConferenceQuantityOfSeats --nie sprawdzqa cancelled
	@DayOfConferenceID int,
	@NewLimit int
	AS
	BEGIN
		SET nocount ON
		DECLARE @CurrentlyOccupied AS int
		SET @CurrentlyOccupied = (SELECT SUM(quantityOfSeats) FROM DaysOfConference WHERE DayOfConferenceID=@DayOfConferenceID)
		IF @CurrentlyOccupied<=@NewLimit
		BEGIN
			UPDATE DaysOfConference
			SET QuantityOfSeats = @NewLimit
			WHERE DayOfConferenceID=@DayOfConferenceID
		END
		ELSE
		BEGIN
			RAISERROR ('Nie można zmniejszyć limitu!', -1,-1)
		END
	END


CREATE PROCEDURE ChangeWorkshopQuantityOfSeats
	@WorkshopID int,
	@NewLimit int
	AS
	BEGIN
		SET nocount ON
		DECLARE @CurrentlyOccupied AS int
		SET @CurrentlyOccupied = (SELECT SUM(quantityOfSeats) FROM Workshops WHERE WorkshopID=@WorkshopID)
		IF @CurrentlyOccupied<=@NewLimit
		BEGIN
			UPDATE Workshops
			SET QuantityOfSeats = @NewLimit
			WHERE WorkshopID=@WorkshopID
		END
		else
		BEGIN
			RAISERROR ('Nie można zmniejszyć limitu!', -1,-1)
		END
	END


CREATE PROCEDURE ChangeQuantityOfSeatsInReservation
	@Reservationid int,
	@NewQuantityOfSeats int
	AS 
	BEGIN 
		SET nocount ON
		Update Reservations
		SET QuantityOfSeats = @NewQuantityOfSeats
		WHERE Reservationid = @Reservationid
	END


CREATE PROCEDURE DeleteReservation
	@CustomerID int
	AS
	BEGIN
		SET nocount ON
		if @CustomerID IS NOT NULL
		BEGIN
			DELETE FROM Reservations
			WHERE CustomerID = @CustomerID
		END
	END



CREATE PROCEDURE HowManyFreeConferenceSeats
	@DayOfConferenceID int
	AS
	BEGIN
	SET nocount on
		DECLARE @Quantity AS int
		SET @Quantity = (SELECT QuantityOfSeats FROM DaysOfConference WHERE DayOfConferenceID=@DayOfConferenceID)

		DECLARE @Occupied AS int
		SET @Occupied = (SELECT SUM(QuantityOfSeats) FROM reservations WHERE DayOfConferenceID=@DayOfConferenceID)

		DECLARE @Result AS int
		SET @Result = (@Quantity-@Occupied)

		RETURN @Result
	END


CREATE PROCEDURE HowManyFreeWorkshopSeats
	@WorkshopID int
	AS
	BEGIN
		SET nocount on
		DECLARE @Quantity AS int
		SET @Quantity = (SELECT QuantityOfSeats FROM Workshops WHERE @WorkshopID=@WorkshopID)

		DECLARE @Occupied AS int
		SET @Occupied = (SELECT SUM(QuantityOfSeats) FROM reservations WHERE WorkshopID=@WorkshopID)

		DECLARE @Result AS int
		SET @Result = (@Quantity-@Occupied)

		RETURN @Result
	END










CREATE PROCEDURE ToPayForMember --if canclel to 0
	@MemberID int
	AS
	BEGIN
		SET nocount OFF
		DECLARE @FeeForDay AS int
		DECLARE @FeeForWorkshops AS int
		DECLARE @AlreadyPayed AS int
		SET @FeeForDay = (SELECT SUM(
							(CASE WHEN pc.Discount IS NULL THEN 1 ELSE (1-pc.Discount) END)*
							(CASE WHEN sc.StudentCN IS NULL THEN 1 ELSE (1-cd.StudentDiscount) END)*
							d.price)
						FROM Members AS m
						INNER JOIN Customers AS c
						ON c.CustomerID=m.CustomerID
						INNER JOIN DaysOfConference AS d
						ON m.DayOfConferenceID=d.DayOfConferenceID
						LEFT OUTER JOIN PriceCaps AS pc
						ON m.DayOfConferenceID=pc.DayOfConferenceID AND m.ReservationDate BETWEEN pc.StartDate AND pc.EndDate
						LEFT OUTER JOIN StudentCards AS sc
						ON c.CustomerID=sc.CustomerID AND d.Date BETWEEN sc.StudentAddCardDate AND sc.StudentExprDate
						INNER JOIN ConferenceDetails AS cd
						ON d.ConferenceDetailsID=cd.ConferenceDetailsID
						WHERE m.isCancelled=0
						GROUP BY m.MemberID)
		SET @FeeForWorkshops = (SELECT SUM(w.Price)
								FROM Members AS m
								INNER JOIN WorkshopsMembers AS wm
								ON m.MemberID=wm.MemberID
								INNER JOIN Workshops AS w
								ON w.WorkshopID=wm.WorkshopID
								GROUP BY m.MemberID)
		SET @AlreadyPayed = (SELECT SUM(Amount) FROM Payments WHERE MemberID=@MemberID GROUP BY MemberID)

		RETURN @FeeForDay+@FeeForWorkshops-@AlreadyPayed
	END



CREATE PROCEDURE ToPayForReservation
	@ReservationID int
	AS
	BEGIN
		SET nocount OFF
		DECLARE @ActualID AS int=-1
		DECLARE @MembersQuantity AS int=0
		DECLARE @StudentQuantity AS int=0
		DECLARE @MembersSum AS int=0
		DECLARE @WorkshopID AS int
		DECLARE @WorkshopFee AS int=0
		DECLARE @DayID AS int
		DECLARE @DayFee AS int
		DECLARE @StudentDiscount AS int
		DECLARE @DateDiscount AS int
		DECLARE @AlreadyPayed AS int
		WHILE (1 = 1) 
		BEGIN  --komentarz dlaczego zrobilismy tu petle
			SELECT TOP 1 @ActualID=MemberID
			FROM Members
			WHERE @ActualID<MemberID AND ReservationFromID=@ReservationID
			ORDER BY MemberID
			IF @@ROWCOUNT = 0 BREAK

			SELECT c.CustomerID
			FROM Customers AS c
			INNER JOIN Members AS m
			ON m.CustomerID = c.CustomerID
			INNER JOIN DaysOfConference AS d
			ON m.DayOfConferenceID = d.DayOfConferenceID
			INNER JOIN StudentCards AS sc
			ON c.CustomerID=sc.CustomerID AND d.date BETWEEN sc.StudentAddCardDate AND sc.StudentExprDate
			IF @@ROWCOUNT > 0 
			BEGIN
				SET @StudentQuantity=@StudentQuantity+1
			END
			SET @MembersQuantity=@MembersQuantity+1
			DECLARE @MemberFee int
			EXECUTE @MemberFee = ToPayForMember @ActualID 
			SET @MembersSum=@MembersSum+@MemberFee
		END

		SET @AlreadyPayed = (SELECT SUM(Amount) FROM Payments WHERE MemberID IS NULL AND ReservationID=@ReservationID GROUP BY ReservationID)
		
		SELECT @WorkshopID=WorkshopID
		FROM Reservations
		WHERE WorkshopID IS NOT NULL AND ReservationID=@ReservationID
		IF @@ROWCOUNT > 0 
		BEGIN
			SET @WorkshopFee=(SELECT Price FROM Workshops WHERE WorkshopID=@WorkshopID)
		END 
		SET @DayID = (SELECT DayOfConferenceID FROM Reservations WHERE ReservationID=@ReservationID)
		SET @DateDiscount = (SELECT Discount FROM PriceCaps WHERE DayOfConferenceID=@DayID AND CURRENT_TIMESTAMP BETWEEN StartDate AND EndDate)

		SELECT @DayFee=d.Price, @StudentDiscount=cd.StudentDiscount
		FROM DaysOfConference AS d
		INNER JOIN ConferenceDetails AS cd
		ON d.ConferenceDetailsID=cd.ConferenceDetailsID
		WHERE d.DayOfConferenceID=@DayID
		
		RETURN @MembersSum+@DayFee*(1-@DateDiscount)*((1-@StudentDiscount)*@StudentQuantity+(@MembersQuantity-@StudentQuantity))+@WorkshopFee*@MembersQuantity
	END

CREATE PROCEDURE list_of_attendee_workshop
	@WorkshopID int
	AS
        BEGIN
 	      SELECT c.CustomerName FROM WorkshopsMembers w JOIN Members m 
			   ON w.MemberID = m.MemberID JOIN Customers c 
	                   ON m.CustomerID = c.CustomerID WHERE w.WorkshopID = @WorkshopID AND m.isCancelled = 0
						                        
		              
  end


CREATE PROCEDURE list_of_attendee_day_of_conference
	@DayOfConferenceID int
	AS
        BEGIN
	      SELECT c.CustomerName FROM  Members m JOIN Customers c 
			ON m.CustomerID = c.CustomerID WHERE m.DayOfConferenceID = @DayOfConferenceID AND m.isCancelled = 0   
						                
						                        
		              
  end
												     
												     
												     
