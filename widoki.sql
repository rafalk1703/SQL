REATE VIEW cancelled_members
	AS SELECT MemberID FROM Members WHERE isCancelled = 1


CREATE VIEW upcoming_workshops
	AS SELECT WorkShopID, WorkshopName FROM Workshops WHERE StartTime > GETDATE()


CREATE VIEW upcoming_and_ongoing_conferences
	AS SELECT c.ConferenceDetailsID, c.ConferenceName FROM ConferenceDetails c JOIN DaysOfConference dc
																												 ON c.ConferenceDetailsID = dc.ConferenceDetailsID WHERE dc.Date > GETDATE()

CREATE VIEW most_popular_conferences
	AS SELECT TOP 5 c.ConferenceDetailsID, c.ConferenceName FROM ConferenceDetails c JOIN DaysOfConference dc
							ON c.ConferenceDetailsID = dc.ConferenceDetailsID JOIN Reservations r
							ON dc.DayOfConferenceId = r.DayOfConferenceID
	   GROUP BY c.ConferenceDetailsID, c.ConferenceName
		 ORDER BY count(r.ReservationID) DESC


CREATE VIEW most_popular_workshops
	AS SELECT TOP 5 w.WorkShopID, w.WorkshopName FROM Workshops w JOIN Reservations r
							ON w.WorkshopID = r.WorkshopID
     GROUP BY w.WorkshopID, w.WorkshopName
     ORDER BY count(r.ReservationID) DESC


CREATE VIEW show_only_companies
	AS SELECT CustomerID, CustomerName, Email, Phone, Address FROM Customers WHERE isCompany = 1


CREATE VIEW show_only_private_clients
	AS SELECT CustomerID, CustomerName, Email, Phone, Address FROM Customers WHERE isCompany = 0


CREATE VIEW show_only_students
	AS SELECT c.CustomerID, CustomerName, Email, Phone, Address FROM Customers c JOIN StudentCards sc
                                                                     ON c.CustomerID = sc.CustomerID WHERE StudentCN IS NOT NULL


CREATE VIEW show_conference_days_with_free_seats
	AS SELECT dc.DayOfConferenceID, dc.QuantityOfSeats - sum(r.QuantityOfSeats) AS wolne_miejsca FROM DaysOfConference dc JOIN Reservations r
							ON dc.DayOfConferenceID = r.DayOfConferenceID
      GROUP BY dc.DayOfConferenceID, dc.QuantityOfSeats
      HAVING sum(r.QuantityOfSeats) < dc.QuantityOfSeats
