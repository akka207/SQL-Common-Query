CREATE TABLE Disks(
	Id int IDENTITY(1,1),
	DiscName varchar(100),
	Price decimal(9,2),
	DiscType varchar(100),
	CONSTRAINT PK_Disks PRIMARY KEY (Id)
)

CREATE TABLE Music(
	Id int IDENTITY(1,1),
	MusicName varchar(100),
	Genre varchar(100),
	Artist varchar(100),
	Lang varchar(100),
	CONSTRAINT PK_Music PRIMARY KEY (Id)
)

CREATE TABLE Films(
	Id int IDENTITY(1,1),
	FilmName varchar(100),
	Genre varchar(100),
	Producer varchar(100),
	MainRole varchar(100),
	AgeLimit varchar(5),
	CONSTRAINT PK_Film PRIMARY KEY (Id)
)

CREATE TABLE DiskMusic(
	idDisk int,
	idMusic int,
	CONSTRAINT FK_DiskMusicDisk FOREIGN KEY (idDisk) REFERENCES Disks(Id),
	CONSTRAINT FK_DiskMusicMusic FOREIGN KEY (idMusic) REFERENCES Music(Id)
)

CREATE TABLE DiskFilm(
	idDisk int,
	idFilm int,
	CONSTRAINT FK_DiskFilmDisk FOREIGN KEY (idDisk) REFERENCES Disks(Id),
	CONSTRAINT FK_DiskFilmFilm FOREIGN KEY (idFilm) REFERENCES Films(Id)
)



CREATE TABLE Clients(
	Id int IDENTITY(1,1),
	FirstName varchar(100),
	LastName varchar(100),
	AddressFull varchar(100),
	City varchar(100),
	BirthDay date,
	Sex bit,	--  0-female  1-male
	Child int,
	CONSTRAINT PK_Clients PRIMARY KEY (Id)
)

CREATE TABLE PhoneList(
	Id int IDENTITY(1,1),
	PhoneNumber char(13),
	idClient int,
	CONSTRAINT PK_PhoneList PRIMARY KEY (Id),
	CONSTRAINT FK_PhoneListDisc FOREIGN KEY (idClient) REFERENCES Clients(Id)
)

CREATE TABLE MailList(
	Id int IDENTITY(1,1),
	MailBox varchar(100),
	idClient int,
	CONSTRAINT PK_MailList PRIMARY KEY (Id),
	CONSTRAINT FK_MailListDisc FOREIGN KEY (idClient) REFERENCES Clients(Id)
)

CREATE TABLE PersonalDiscount(
	Id int IDENTITY(1,1),
	idClient int,
	DiscountValue DECIMAL(4,2),
	StartDateTime DATETIME,
	EndDateTime DATETIME,
	CONSTRAINT PK_PersonalDiscount PRIMARY KEY (Id),
	CONSTRAINT FK_PersonalDiscountDisc FOREIGN KEY (idClient) REFERENCES Clients(Id)
)



CREATE TABLE Orders(
	Id int IDENTITY(1,1),
	OperationType varchar(100),
	OperationDateTimeStart DATETIME,
	OperationDateTimeEnd DATETIME,
	idClient int,
	idDisk int,
	CONSTRAINT PK_Orders PRIMARY KEY (Id),
	CONSTRAINT FK_OrdersClients FOREIGN KEY (idClient) REFERENCES Clients(Id),
	CONSTRAINT FK_OrdersDisks FOREIGN KEY (idDisk) REFERENCES Disks(Id)
)


BACKUP DATABASE ekzamen
TO DISK = 'D:\Alex\SQL\exam.bak'


-- DROP ALL
ALTER PROCEDURE DropAll
AS
BEGIN
	drop table Orders
	drop table PersonalDiscount
	drop table MailList
	drop table PhoneList
	drop table Clients
	drop table DiskMusic
	drop table DiskFilm
	drop table Films
	drop table Music
	drop table Disks
END;

EXECUTE DropAll
-- ********


ALTER PROCEDURE ClientsRND
	@Count INT
AS
	BEGIN
		DECLARE @Cities TABLE(
			Id int IDENTITY(1,1) PRIMARY KEY,
			CityName varchar(20)
		)
		INSERT INTO @Cities VALUES
			  ('Vinnytsia'),
			  ('Volyn'),
			  ('Dnipro'),
			  ('Donetsk'),
			  ('Zhytomyr'),
			  ('Zakarpattia'),
			  ('Zaporizhzhia'),
			  ('Ivano-Frankivsk'),
			  ('Kyiv'),
			  ('Kropyvnytskyi'),
			  ('Luhansk'),
			  ('Lviv'),
			  ('Mykolaiv'),
			  ('Odessa'),
			  ('Poltava'),
			  ('Rivne'),
			  ('Sumy'),
			  ('Ternopil'),
			  ('Kharkiv'),
			  ('Kherson'),
			  ('Khmelnytskyi'),
			  ('Cherkasy'),
			  ('Chernivtsi'),
			  ('Chernihiv');
		DECLARE @StartBirthDate DATE = '1970-01-01';
		DECLARE @EndBirthDate DATE = '2010-01-01';

		DECLARE @TriggerCode varchar(max);
		SET @TriggerCode = '
			CREATE TRIGGER TR_Clients_INSERT
			ON Clients
			AFTER INSERT
			AS
			BEGIN
				DECLARE @Count INT = FLOOR(RAND()*2+1)
				WHILE @Count > 0
				BEGIN
					INSERT INTO PhoneList VALUES(
						''+380'' + CAST(FLOOR(RAND()*90000+10000) as varchar) + CAST(FLOOR(RAND()*9000+1000) as varchar),
						(SELECT TOP 1 I.Id FROM INSERTED I ORDER BY I.Id ASC)
					)
					SET @Count -= 1
				END

				SET @Count = FLOOR(RAND()*2+1)
				WHILE @Count > 0
				BEGIN
					INSERT INTO MailList VALUES(
						(SELECT TOP 1 I.FirstName FROM INSERTED I ORDER BY I.FirstName ASC) 
						+ ''_'' + (SELECT TOP 1 I.LastName FROM INSERTED I ORDER BY I.LastName ASC) 
						+ ''_'' + CAST(FLOOR(RAND()*9000+1000) as varchar) + ''@gmail.com'',
						(SELECT TOP 1 I.Id FROM INSERTED I ORDER BY I.Id ASC)
					)
					SET @Count -= 1
				END
			END
		';
		EXECUTE(@TriggerCode);

		WHILE @Count > 0
			BEGIN
				DECLARE @FirstName varchar(100)
				DECLARE @LastName varchar(100)
				DECLARE @AddressFull varchar(100)
				DECLARE @City varchar(100)
				DECLARE @BirthDay DATE
				DECLARE @Sex bit
				DECLARE @Child int
			

				SET @FirstName = 'First' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
				SET @LastName = 'Last' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
				SET @AddressFull = 'Street ' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar) + ', House' + CAST(FLOOR(RAND()*(100-10)+10) as varchar)
				SET @City = (SELECT C.CityName FROM @Cities C WHERE C.Id = FLOOR(RAND()*24+1))
				SET @BirthDay = (SELECT DATEADD(DAY, CAST(RAND() * (DATEDIFF(DAY, @StartBirthDate, @EndBirthDate)) AS INT), @StartBirthDate))
				SET @Sex = CAST(FLOOR(RAND()*2) as bit)
				SET @Child = FLOOR(RAND()*6)

				INSERT INTO Clients VALUES(@FirstName, @LastName, @AddressFull, @City, @BirthDay, @Sex, @Child)

				SET @Count -= 1
			END

		EXECUTE('DROP TRIGGER TR_Clients_INSERT');
	END;


-- TEST ClientRND
EXECUTE ClientsRND @Count = 10

SELECT
	*
FROM
	Clients

SELECT
	C.Id,
	C.FirstName,
	C.LastName,
	P.Id,
	P.Phonenumber,
	M.Id,
	M.MailBox
FROM
	Clients  C
	INNER JOIN PhoneList P
		ON C.Id = P.idClient
	INNER JOIN MailList M
		ON C.Id = M.idClient

SELECT
	C.Id,
	C.FirstName,
	C.LastName,
	D.DiscountValue,
	D.StartDateTime,
	D.EndDateTime
FROM
	Clients  C
	INNER JOIN PersonalDiscount D
		ON C.Id = D.idClient
-- **************


ALTER PROCEDURE DisksRND
	@Count INT
AS
BEGIN
	DECLARE @Genres TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		GenreName varchar(20)
	)
	INSERT INTO @Genres VALUES
			('Pop'), ('Rock'), ('Hip-Hop/Rap'), 
			('Country'), ('R&B/Soul'), ('Electronic/Dance'), 
			('Jazz'), ('Blues'), ('Classical'), ('Reggae');
	
	DECLARE @Artists TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		ArtistName varchar(20)
	)
	INSERT INTO @Artists VALUES
			('Michael Jackson'), ('The Beatles'), 
			('Eminem'), ('Taylor Swift'), ('Beyonce'), 
			('David Bowie'), ('Bob Dylan'), ('Adele'), 
			('Elvis Presley'), ('Queen');

	DECLARE @Languages TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		LanguageName varchar(100)
	)
	INSERT INTO @Languages VALUES
		('English'), ('Spanish'), ('Mandarin'), 
		('French'), ('Arabic'), ('Ukrainian'), 
		('Hindi'), ('Portuguese'), ('Bengali'), 
		('Japanese');

	DECLARE @FilmGenres TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		GenreName varchar(100)
	)
	INSERT INTO @FilmGenres VALUES
		('Action'), ('Comedy'), ('Drama'), 
		('Science Fiction'), ('Thriller'), ('Horror'), 
		('Romance'), ('Adventure'), ('Fantasy'), 
		('Mystery');

	DECLARE @MainRoles TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		ActorName varchar(100)
	)
	INSERT INTO @MainRoles VALUES
		('Tom Hanks'), ('Meryl Streep'), ('Leonardo DiCaprio'), 
		('Scarlett Johansson'), ('Jackie Chan'), ('Charlize Theron'), 
		('Brad Pitt'), ('Jennifer Lawrence'), ('Johnny Depp'), 
		('Natalie Portman');

	DECLARE @AgeLimits TABLE(
		Id int IDENTITY(1,1) PRIMARY KEY,
		Age varchar(100)
	)
	INSERT INTO @AgeLimits VALUES
		('0+'), ('3+'), ('6+'), 
		('12+'), ('16+'), 
		('18+'), ('18+'), ('18+');


	WHILE @Count > 0
	BEGIN
		DECLARE @DiskName varchar(100) = 'Disk' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
		DECLARE @Price varchar(100) = FLOOR(RAND()*(3000-600)+600)
		DECLARE @DiskType varchar(100)

		IF FLOOR(RAND()*2) = 0
			SET @DiskType = 'Music'
		ELSE
			SET @DiskType = 'Film'
		
		DECLARE @DiskId TABLE (Id INT)

		INSERT INTO Disks OUTPUT INSERTED.Id INTO @DiskId(Id) VALUES(
			@DiskName,
			@Price,
			@DiskType
		)

		IF @DiskType LIKE 'Music'
		BEGIN
			DECLARE @MusicName varchar(100) = 'Music' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
			DECLARE @Genre varchar(100) = (SELECT G.GenreName FROM @Genres G WHERE G.Id = FLOOR(RAND()*10+1))
			DECLARE @Artist varchar(100) = (SELECT A.ArtistName FROM @Artists A WHERE A.Id = FLOOR(RAND()*10+1))
			DECLARE @Language varchar(100) = (SELECT L.LanguageName FROM @Languages L WHERE L.Id = FLOOR(RAND()*10+1))
			
			DECLARE @MusicId TABLE (Id INT)
			INSERT INTO Music OUTPUT INSERTED.Id INTO @MusicId(Id) VALUES(
				@MusicName,
				@Genre,
				@Artist,
				@Language
			)

			INSERT INTO DiskMusic VALUES(
				(SELECT MAX(D.Id) FROM @DiskId D), 
				(SELECT MAX(M.Id) FROM @MusicId M)
			)
		END
		ELSE
		BEGIN
			DECLARE @FilmName varchar(100) = 'Film' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
			DECLARE @FilmGenre varchar(100) = (SELECT G.GenreName FROM @FilmGenres G WHERE G.Id = FLOOR(RAND()*10+1))
			DECLARE @Producer varchar(100) = 'Producer' + CAST(FLOOR(RAND()*(1000-100)+100) as varchar)
			DECLARE @MainRole varchar(100) = (SELECT R.ActorName FROM @MainRoles R WHERE R.Id = FLOOR(RAND()*10+1))
			DECLARE @AgeLimit varchar(100) = (SELECT A.Age FROM @AgeLimits A WHERE A.Id = FLOOR(RAND()*8+1))

			DECLARE @FilmId TABLE (Id INT)
			INSERT INTO Films OUTPUT INSERTED.Id INTO @FilmId(Id) VALUES(
				@FilmName,
				@FilmGenre,
				@Producer,
				@MainRole,
				@AgeLimit
			)

			INSERT INTO DiskFilm VALUES(
				(SELECT MAX(D.Id) FROM @DiskId D), 
				(SELECT MAX(F.Id) FROM @FilmId F)
			)
		END
			
		SET @Count -= 1
	END
END;

-- TEST DisksRND
EXECUTE DisksRND @Count = 30

SELECT
	*
FROM
	DiskMusic DM
		INNER JOIN Music M
			ON DM.idMusic = M.Id
		INNER JOIN Disks D
			ON DM.idDisk = D.Id

SELECT
	*
FROM
	DiskFilm DF
		INNER JOIN Films F
			ON DF.idFilm = F.Id
		INNER JOIN Disks D
			ON DF.idDisk = D.Id
-- *************



ALTER PROCEDURE AddOrder
	@ClientId INT,
	@DiskId INT,
	@OperationType varchar(100),
	@OperationDateTime DATETIME
AS
BEGIN
	IF @OperationType LIKE 'Buy'
		INSERT INTO Orders VALUES(
			@OperationType,
			@OperationDateTime,
			@OperationDateTime,
			@ClientId,
			@DiskId
		)
	ELSE IF @OperationType LIKE 'Rent'
		INSERT INTO Orders VALUES(
			@OperationType,
			@OperationDateTime,
			NULL,
			@ClientId,
			@DiskId
		)
	ELSE
	BEGIN
		UPDATE Orders
		SET OperationDateTimeEnd = @OperationDateTime
		WHERE Id = (
			SELECT 
				TOP 1 O.Id 
			FROM 
				Orders O 
				INNER JOIN Clients C 
					ON O.idClient = C.Id
				INNER JOIN Disks D 
					ON O.idDisk = D.Id
			WHERE
				O.OperationDateTimeEnd IS NULL AND O.idClient = @ClientId AND O.idDisk = @DiskId
			)
	END
END



-- TEST AddOrder
SELECT 
	O.Id as 'Order ID',
	O.OperationType,
	O.OperationDateTimeStart,
	O.OperationDateTimeEnd,
	C.Id as 'Client ID',
	C.FirstName + '  ' + C.LastName as 'Full Name',
	D.Id as 'Disk ID',
	D.DiscName,
	D.Price
FROM 
	Orders O 
	INNER JOIN Clients C 
		ON O.idClient = C.Id
	INNER JOIN Disks D 
		ON O.idDisk = D.Id

EXECUTE AddOrder @ClientId = 2, @DiskId = 7, @OperationType = 'Buy', @OperationDateTime = '2010-01-01'
EXECUTE AddOrder @ClientId = 1, @DiskId = 2, @OperationType = 'Rent', @OperationDateTime = '2002-01-01'
EXECUTE AddOrder @ClientId = 2, @DiskId = 3, @OperationType = 'Rent', @OperationDateTime = '2004-01-01'
EXECUTE AddOrder @ClientId = 1, @DiskId = 2, @OperationType = 'Return', @OperationDateTime = '2002-03-05'
-- *************



ALTER PROCEDURE OrdersRND
	@Count INT
AS
BEGIN
	DECLARE @StartDate DATE = '2020-12-31';
	DECLARE @EndDate DATE = '2023-12-31';
	DECLARE @DayStep INT = FLOOR((DATEDIFF(DAY, @StartDate, @EndDate)/1.5) / @Count);

	DECLARE @OperationTypeRND varchar(100);
	DECLARE @ClientIdRND INT;
	DECLARE @DiskIdRND INT;
	DECLARE @OperationDateTimeRND DATETIME;
	DECLARE @OperationDateTimeEndRND DATETIME;



	WHILE @Count > 0
	BEGIN
		SET @ClientIdRND = (SELECT TOP 1 Id FROM Clients ORDER BY NEWID())
		SET @DiskIdRND = (SELECT TOP 1 Id FROM Disks ORDER BY NEWID())
		SET @OperationDateTimeRND = DATEADD(DAY, 
											@DayStep, 
											@StartDate)
		SET @StartDate = @OperationDateTimeRND

		SET @OperationTypeRND = 
		CASE FLOOR(RAND()*3)
			WHEN 0 THEN 'Buy'
			WHEN 1 THEN 'Rent'
			WHEN 2 THEN 'Return'
		END
		
		IF @OperationTypeRND = 'Buy'
			EXECUTE AddOrder @ClientId = @ClientIdRND, 
							@DiskId = @DiskIdRND, 
							@OperationType = 'Buy', 
							@OperationDateTime = @OperationDateTimeRND
		ELSE IF @OperationTypeRND = 'Rent'
			EXECUTE AddOrder @ClientId = @ClientIdRND, 
							@DiskId = @DiskIdRND, 
							@OperationType = 'Rent',
							@OperationDateTime = @OperationDateTimeRND
		ELSE
		BEGIN
			SET @OperationDateTimeEndRND = DATEADD(DAY, FLOOR(RAND()*130+10), @OperationDateTimeRND)

			EXECUTE AddOrder @ClientId = @ClientIdRND, 
							@DiskId = @DiskIdRND, 
							@OperationType = 'Rent', 
							@OperationDateTime = @OperationDateTimeRND

			EXECUTE AddOrder @ClientId = @ClientIdRND, 
							@DiskId = @DiskIdRND, 
							@OperationType = 'Return', 
							@OperationDateTime = @OperationDateTimeEndRND
		END
		
		SET @Count -= 1
	END
END

-- USE ONCE!!!  Generate realistic orders date (divides date interval on @Count and inserts @Count records with normalized dates)
-- Needed for correct trigger work
EXECUTE OrdersRND @Count = 300		



-- TASK 2
CREATE TRIGGER TR_Orders_INSERT
	ON Orders
	AFTER INSERT
AS
BEGIN
	DECLARE @ClientId INT = (SELECT I.idClient FROM INSERTED I)
	DECLARE @NewDiscount DECIMAL(9,2);
	DECLARE @Income DECIMAL(9,2);
	
	SELECT 
		@Income = SUM(
			CASE
				WHEN O.OperationType = 'Buy' THEN D.Price - D.Price * PD.DiscountValue
				WHEN O.OperationType = 'Rent' THEN D.Price * 0.25 - D.Price * 0.25 * PD.DiscountValue
			END)
	FROM
		Orders O 
		INNER JOIN Disks D
			ON O.idDisk = D.Id
		INNER JOIN Clients C
			ON O.idClient = C.Id
		INNER JOIN PersonalDiscount PD
			ON O.idClient = PD.idClient
			AND O.OperationDateTimeStart <= PD.EndDateTime
			AND O.OperationDateTimeEnd >= PD.StartDateTime

	DECLARE @LastDiscountValue DECIMAL(4,2) = (
		SELECT
			TOP 1 PD.DiscountValue
		FROM
			Clients C
			INNER JOIN PersonalDiscount PD
				ON PD.idClient = @ClientId
		ORDER BY
			PD.Id DESC
	)
	DECLARE @LastDiscountId INT = (
		SELECT
			TOP 1 PD.Id
		FROM
			Clients C
			INNER JOIN PersonalDiscount PD
				ON PD.idClient = @ClientId
		ORDER BY
			PD.Id DESC
	)
	IF @Income < 5000
		SET @NewDiscount = 0
	ELSE IF @Income >= 5000 AND @Income < 15000
		SET @NewDiscount = 0.05
	ELSE IF @Income >= 15000 AND @Income < 50000
		SET @NewDiscount = 0.1
	ELSE
		SET @NewDiscount = 0.2

	IF NOT EXISTS(SELECT * FROM Clients C INNER JOIN PersonalDiscount PD ON PD.idClient = @ClientId)
	BEGIN
		INSERT INTO PersonalDiscount VALUES(@ClientId,0,'2000-01-01','2300-01-01')
	END

	IF @LastDiscountValue != @NewDiscount
	BEGIN
		UPDATE PersonalDiscount
		SET EndDateTime = (SELECT I.OperationDateTimeStart FROM INSERTED I)
		WHERE Id = @LastDiscountId

		INSERT INTO PersonalDiscount VALUES
			(@ClientId, @NewDiscount, (SELECT I.OperationDateTimeStart FROM INSERTED I), '2300-01-01')
	END
END



-- TASK 3
SELECT
	O.Id,
	O.OperationType,
	O.OperationDateTimeStart,
	O.OperationDateTimeEnd,
	C.FirstName + ' ' + C.LastName AS 'Name'
FROM
	Orders O
	INNER JOIN Clients C
		ON O.idClient = C.Id
WHERE
	(O.OperationDateTimeEnd IS NULL 
	AND DATEDIFF(DAY, O.OperationDateTimeStart, GETDATE()) > 100)
	OR DATEDIFF(DAY, O.OperationDateTimeStart, O.OperationDateTimeEnd) > 100


-- TASK 4
SELECT
	OpYear AS 'Рік',
	[1] AS '1 квартал',
	[2] AS '2 квартал',
	[3] AS '3 квартал',
	[4] AS '4 квартал'
FROM
(
	SELECT
		YEAR(O.OperationDateTimeStart) AS OpYear,
		DATEPART(QUARTER, O.OperationDateTimeStart) AS OpQuarter,
		D.Price - D.Price * PD.DiscountValue AS Price
	FROM
		Orders O
		INNER JOIN Disks D 
			ON O.idDisk = D.Id
		INNER JOIN Clients C
			ON O.idClient = C.Id
		INNER JOIN PersonalDiscount PD
			ON PD.idClient = C.Id
	WHERE
		PD.StartDateTime <= O.OperationDateTimeStart
		AND PD.EndDateTime >= O.OperationDateTimeStart
) AS SourceTable
PIVOT
(
	SUM(Price)
	FOR OpQuarter IN ([1],[2],[3],[4])
) AS PivotTable


-- TASK 5
WITH 
JackieFilms AS
(
	SELECT
		D.Id
	FROM
		DiskFilm DF
		INNER JOIN Disks D
			ON DF.idDisk = D.Id
		INNER JOIN Films F
			ON DF.idFilm = F.Id
	WHERE
		F.MainRole LIKE 'Jackie Chan'
),
FiltredClients AS
(
	SELECT DISTINCT
		C.Id
	FROM
		Orders O
		INNER JOIN Clients C
			ON C.Id = O.idClient
	WHERE
		C.Sex = 1
		AND C.Child > 0
		AND C.City LIKE 'Zhytomyr'
		AND ABS(DATEDIFF(YEAR, C.BirthDay, GETDATE())) >= 30
),
Purchases AS
(
	SELECT
		D.Id AS Disk,
		C.Id AS Client,
		COUNT(C.Id) AS Purchases
	FROM
		Orders O
		INNER JOIN Clients C
			ON C.Id = O.idClient
		INNER JOIN Disks D
			ON D.Id = O.idDisk
		INNER JOIN FiltredClients FC
			ON C.Id = FC.Id
	GROUP BY
		D.Id,
		C.Id
),
JackiePurchases AS
(
	SELECT
		P.Client AS Client,
		MAX(P.Purchases) AS FilmCount
	FROM
		Purchases P
			INNER JOIN JackieFilms JF
				ON JF.Id = P.Disk
	GROUP BY
		P.Client
),
JackieFans AS
(
	SELECT
		P.Client
	FROM
		Purchases P
			INNER JOIN JackiePurchases JP
				ON JP.FilmCount = P.Purchases AND JP.Client = P.Client
)
SELECT
	TOP 3
	M.Artist,
	COUNT(M.Artist) AS Count
FROM
	Orders O
	INNER JOIN Clients C
		ON O.idClient = C.Id
	INNER JOIN JackieFans JF
		ON JF.Client = C.Id
	INNER JOIN Disks D
		ON O.Id = D.Id
	INNER JOIN DiskMusic DM
		ON DM.idDisk = D.Id
	INNER JOIN Music M
		ON DM.idMusic = M.Id
GROUP BY
	M.Artist
ORDER BY
	Count DESC


-- TASK 6
WITH 
AllFilms AS
(
	SELECT
		YEAR(O.OperationDateTimeStart) AS MonthYear,
		CASE C.Sex
			WHEN 0 THEN 'Ж'
			WHEN 1 THEN 'Ч'
		END AS Sex,
		DATEPART(MONTH, O.OperationDateTimeStart) as Month,
		O.Id AS OID
	FROM
		Orders O
		INNER JOIN Clients C
			ON C.Id = O.idClient
		INNER JOIN Disks D
			ON D.Id = O.idDisk
		INNER JOIN DiskFilm DF
			ON DF.idDisk = D.Id
		INNER JOIN Films F
			ON DF.idFilm = F.Id
),
RatedFilms AS
(
	SELECT
		YEAR(O.OperationDateTimeStart) AS MonthYear,
		CASE C.Sex
			WHEN 0 THEN 'Ж'
			WHEN 1 THEN 'Ч'
		END AS Sex,
		DATEPART(MONTH, O.OperationDateTimeStart) as Month,
		O.Id AS OID
	FROM
		Orders O
		INNER JOIN Clients C
			ON C.Id = O.idClient
		INNER JOIN Disks D
			ON D.Id = O.idDisk
		INNER JOIN DiskFilm DF
			ON DF.idDisk = D.Id
		INNER JOIN Films F
			ON DF.idFilm = F.Id
	WHERE
		F.AgeLimit LIKE '18+'
),
PivotAll AS
(
SELECT
	MonthYear,
	Sex,
	[1],
	[2],
	[3],
	[4],
	[5],
	[6],
	[7],
	[8],
	[9],
	[10],
	[11],
	[12]
FROM
	AllFilms
PIVOT
(
	COUNT(OID)
	FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS ptable
),
PivotRated AS
(
SELECT
	MonthYear,
	Sex,
	[1],
	[2],
	[3],
	[4],
	[5],
	[6],
	[7],
	[8],
	[9],
	[10],
	[11],
	[12]
FROM
	RatedFilms
PIVOT
(
	COUNT(OID)
	FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS ptable
)
SELECT
	A.MonthYear AS 'Рік',
	A.Sex AS 'Стать',
	(CASE A.[1]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[1]  AS float) / CAST(A.[1]  AS float)*100 AS varchar) END) + '%' AS 'Січень',
	(CASE A.[2]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[2]  AS float) / CAST(A.[2]  AS float)*100 AS varchar) END) + '%' AS 'Лютий',
	(CASE A.[3]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[3]  AS float) / CAST(A.[3]  AS float)*100 AS varchar) END) + '%' AS 'Березень',
	(CASE A.[4]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[4]  AS float) / CAST(A.[4]  AS float)*100 AS varchar) END) + '%' AS 'Квітень',
	(CASE A.[5]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[5]  AS float) / CAST(A.[5]  AS float)*100 AS varchar) END) + '%' AS 'Травень',
	(CASE A.[6]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[6]  AS float) / CAST(A.[6]  AS float)*100 AS varchar) END) + '%' AS 'Червень',
	(CASE A.[7]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[7]  AS float) / CAST(A.[7]  AS float)*100 AS varchar) END) + '%' AS 'Липень',
	(CASE A.[8]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[8]  AS float) / CAST(A.[8]  AS float)*100 AS varchar) END) + '%' AS 'Серпень',
	(CASE A.[9]  WHEN 0 THEN '0' ELSE CAST(CAST(R.[9]  AS float) / CAST(A.[9]  AS float)*100 AS varchar) END) + '%' AS 'Вересень',
	(CASE A.[10] WHEN 0 THEN '0' ELSE CAST(CAST(R.[10] AS float) / CAST(A.[10] AS float)*100 AS varchar) END) + '%' AS 'Жовтень',
	(CASE A.[11] WHEN 0 THEN '0' ELSE CAST(CAST(R.[11] AS float) / CAST(A.[11] AS float)*100 AS varchar) END) + '%' AS 'Листопад',
	(CASE A.[12] WHEN 0 THEN '0' ELSE CAST(CAST(R.[12] AS float) / CAST(A.[12] AS float)*100 AS varchar) END) + '%' AS 'Грудень'
FROM
	PivotAll A
	INNER JOIN PivotRated R
		ON A.MonthYear = R.MonthYear AND A.Sex = R.Sex
ORDER BY
	A.MonthYear,
	A.Sex


-- TASK 7
ALTER PROCEDURE ChangeDiskPrice
	@DiscType varchar(100),
	@Value DECIMAL(9,2)
AS
BEGIN
	UPDATE Disks
	SET Price *= @Value
	WHERE Disks.DiscType = @DiscType
END

EXECUTE ChangeDiskPrice @DiscType = 'Film', @Value = 1.1


-- TASK 8
WITH  Income AS
(
	SELECT
		YEAR(O.OperationDateTimeStart) AS MonthYear,
		CASE O.OperationType
			WHEN 'Buy' THEN 'Покупка'
			WHEN 'Rent' THEN 'Оренда'
		END AS OpType,
		DATEPART(MONTH, O.OperationDateTimeStart) as Month,
		D.Price - D.Price*PD.DiscountValue as LocalIncome
	FROM
		Orders O
		INNER JOIN Clients C
			ON C.Id = O.idClient
		INNER JOIN Disks D
			ON D.Id = O.idDisk
		INNER JOIN PersonalDiscount PD
			ON PD.idClient = C.Id
	WHERE
		PD.StartDateTime <= O.OperationDateTimeStart
		AND PD.EndDateTime >= O.OperationDateTimeStart
)
SELECT
	MonthYear,
	OpType,
	[1]	AS 'Січень',
	[2]	AS 'Лютий',
	[3]	AS 'Березень',
	[4]	AS 'Квітень',
	[5]	AS 'Травень',
	[6]	AS 'Червень',
	[7]	AS 'Липень',
	[8]	AS 'Серпень',
	[9]	AS 'Вересень',
	[10] AS 'Жовтень',
	[11] AS 'Листопад',
	[12] AS 'Грудень'
FROM
	Income
PIVOT
(
	SUM(LocalIncome)
	FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS ptable
ORDER BY
	MonthYear
