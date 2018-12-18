CREATE TABLE Customers (
    CustomerID int NOT NULL PRIMARY KEY,
    CustomerName nvarchar(50) NOT NULL,
    isCompany bit NOT NULL DEFAULT 0,
    Email nvarchar(10) NOT NULL,
    Phone varchar(10) NOT NULL,
    Address nvarchar(50) NOT NULL,
    RegistrationDate datetime NOT NULL,
    check (RegistrationDate<=CURRENT_TIMESTAMP),
    check (Email LIKE '%_@__%.__%')
);

CREATE TABLE StudentCards (
    StudentCardID int NOT NULL PRIMARY KEY,
    StudentCN varchar(10) NOT NULL,
    StudentAddCardDate datetime NOT NULL,
    StudentExprDate datetime NOT NULL,
    CustomerID int NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    check (StudentAddCardDate<=StudentExprDate),
);

CREATE TABLE ConferenceDetails (
    ConferenceDetailsID int NOT NULL PRIMARY KEY,
    ConferenceName nvarchar(50) NOT NULL,
    Address nvarchar(50) NOT NULL,
    Phone varchar(10) NOT NULL,
    Fax varchar(10),
    StudentDiscount real NOT NULL,
    check (StudentDiscount BETWEEN 0 AND 1),
);

CREATE TABLE DaysOfConference (
    DayOfConferenceID int NOT NULL PRIMARY KEY,
    ConferenceDetailsID int NOT NULL FOREIGN KEY REFERENCES ConferenceDetails(ConferenceDetailsID),
    QuantityOfSeats int NOT NULL,
    Date datetime NOT NULL,
    Price money NOT NULL,
    check (SIGN(QuantityOfSeats)>=0),
    check (SIGN(Price)>=0),
);


CREATE TABLE Workshops (
    WorkshopID int NOT NULL PRIMARY KEY,
    DayOfConferenceID int NOT NULL FOREIGN KEY REFERENCES DaysOfConference(DayOfConferenceID),
    WorkshopName nvarchar(50) NOT NULL,
    Price real NOT NULL,
    StartTime datetime NOT NULL,
    EndTime datetime NOT NULL,
    QuantityOfSeats int NOT NULL,
    Details nvarchar(50),
    check (SIGN(Price)>=0),
    check (StartTime<=EndTime),
    check (SIGN(QuantityOfSeats)>=0),
);

CREATE TABLE Reservations (
    ReservationID int NOT NULL PRIMARY KEY,
    CustomerID int NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    DayOfConferenceID int NOT NULL FOREIGN KEY REFERENCES DaysOfConference(DayOfConferenceID),
    WorkshopID int FOREIGN KEY REFERENCES Workshops(WorkshopID),
    ReservationDate datetime NOT NULL,
    QuantityOfSeats int NOT NULL,
    QuantityOfStudents int NOT NULL,
    check (ReservationDate<=CURRENT_TIMESTAMP),
    check (SIGN(QuantityOfSeats)>=0),
    check (SIGN(QuantityOfStudents)>=0),
);

CREATE TABLE Members (
    MemberID int NOT NULL PRIMARY KEY,
    CustomerID int NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    DayOfConferenceID int NOT NULL FOREIGN KEY REFERENCES DaysOfConference(DayOfConferenceID),
    ReservationDate datetime NOT NULL,
    ReservationFromID int FOREIGN KEY REFERENCES Reservations(ReservationID),
    isCancelled bit NOT NULL DEFAULT 0,
    check (ReservationDate<=CURRENT_TIMESTAMP),
);


CREATE TABLE WorkshopsMembers (
    WorkshopsMemberID int NOT NULL PRIMARY KEY,
    MemberID int NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
    WorkshopID int NOT NULL FOREIGN KEY REFERENCES Workshops(WorkshopID),
);





CREATE TABLE PriceCaps (
    PriceCapID int NOT NULL PRIMARY KEY,
    DayOfConferenceID int NOT NULL FOREIGN KEY REFERENCES DaysOfConference(DayOfConferenceID),
    Discount real NOT NULL,
    StartDate datetime NOT NULL,
    EndDate datetime NOT NULL,
    check (Discount BETWEEN 0 AND 1),
    check (StartDate<=EndDate),
);


CREATE TABLE Payments (
    PaymentID int NOT NULL PRIMARY KEY,
    MemberID int FOREIGN KEY REFERENCES Members(MemberID),
    ReservationID int FOREIGN KEY REFERENCES Reservations(ReservationID),
    Amount money NOT NULL,
    AccountNumber varchar(10),
    PaymentDetails nvarchar(50),
    Date datetime NOT NULL,
    check (SIGN(Amount)>0),
    check ((MemberID IS NULL) AND (ReservationID IS NULL))
);
