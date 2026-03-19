USE DIY_SKILL_SHARING_APP;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'PrerequisiteWorkshopID') -- kilitlenmeyi �nlemek i�in
BEGIN
    UPDATE Workshops SET PrerequisiteWorkshopID = NULL;
END
GO

-- [YEN�] Multivalue tablosu temizli�i
IF OBJECT_ID('dbo.UserPhones', 'U') IS NOT NULL
    DELETE FROM UserPhones;

DELETE FROM UserBadges;
DELETE FROM UserSkills;
DELETE FROM WorkshopMaterials;
DELETE FROM Waitlist;
DELETE FROM Enrollments;
DELETE FROM Reviews;
DELETE FROM Workshops; 
DELETE FROM Materials;
DELETE FROM Skills;
DELETE FROM Badges;
DELETE FROM Categories;
DELETE FROM Mentors;
DELETE FROM Learners;
DELETE FROM Users;

-- ID saya�lar�
DBCC CHECKIDENT ('Users', RESEED, 0);
DBCC CHECKIDENT ('Categories', RESEED, 0);
DBCC CHECKIDENT ('Badges', RESEED, 0);
DBCC CHECKIDENT ('Materials', RESEED, 0);
DBCC CHECKIDENT ('Skills', RESEED, 0);
DBCC CHECKIDENT ('Workshops', RESEED, 0);
GO


-- [YEN�] MAPPING A MULTIVALUED ATTRIBUTE (Telefon Numaralar� Tablosu)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserPhones]') AND type in (N'U'))
BEGIN
    CREATE TABLE UserPhones (
        PhoneID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        PhoneNumber NVARCHAR(20) NOT NULL,
        PhoneType NVARCHAR(20) DEFAULT 'Mobile',
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
    );
END
GO


-- Workshops tablosuna Ge�me Notu (MinPassingGrade) ekleme
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'MinPassingGrade')
BEGIN
    ALTER TABLE Workshops ADD MinPassingGrade INT DEFAULT 50;
END

-- Workshops tablosuna Ya� S�n�r� (MinAge) ekleme
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'MinAge')
BEGIN
    ALTER TABLE Workshops ADD MinAge INT DEFAULT 18;
END

-- [YEN�] Composite Attribute Mapping ��in: City ve District
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'City')
BEGIN
    ALTER TABLE Workshops ADD City NVARCHAR(50) DEFAULT '�stanbul';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'District')
BEGIN
    ALTER TABLE Workshops ADD District NVARCHAR(50) DEFAULT 'Merkez';
END

-- Unary Relationship Mapping 
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Workshops') AND name = 'PrerequisiteWorkshopID')
BEGIN
    ALTER TABLE Workshops ADD PrerequisiteWorkshopID INT NULL REFERENCES Workshops(WorkshopID);
END

-- Users tablosunda BirthDate var m�
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'BirthDate')
BEGIN
    ALTER TABLE Users ADD BirthDate DATE;
END
GO




--  KULLANICILAR (USERS)
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, IsActive, BirthDate) VALUES
('Baris', 'Bagbekleyen', 'baris@diy.com', 'Hash_123', 1, '1990-05-20'),   -- ID: 1 (Bar�� Hoca)
('Mert', 'Eser', 'mert@diy.com', 'Hash_456', 1, '1988-11-10'),    -- ID: 2 (Mert Hoca)
('Ege', 'Arican', 'ege@diy.com', 'Hash_789', 1, '2000-06-15'),    -- ID: 3 (Ege - ��renci)
('Bahadir', 'Duran', 'bahadir@diy.com', 'Hash_321', 1, '1999-03-22'),   -- ID: 4 (Bahad�r - ��renci)
('Mert', 'Koksal', 'koksal@diy.com', 'Hash_654', 1, '1995-04-23'),        -- ID: 5 (K�ksal - Hem Hoca Hem ��renci)
('G�kdeniz', 'Demirtas', 'goko@diy.com', 'Hash_987', 1, '2001-12-12'),  -- ID: 6 (G�kdeniz - ��renci)
('Ahmet', 'Yilmaz', 'ahmet.y@diy.com', 'Hash_New1', 1, '1995-01-01'),    -- ID: 7 (Ba�ar�l� ��renci)
('Ayse', 'Kara', 'ayse.k@diy.com', 'Hash_New2', 1, '2005-01-01'),        -- ID: 8 (Gen� ��renci)
('Mehmet', 'Oz', 'mehmet.o@diy.com', 'Hash_New3', 1, '1980-01-01'),      -- ID: 9 (Yeti�kin)
('Fatma', 'Celik', 'fatma.c@diy.com', 'Hash_New4', 1, '1998-09-09'),     -- ID: 10
('Ali', 'Veli', 'ali.v@diy.com', 'Hash_New5', 1, '2012-05-05'),          -- ID: 11 (�ocuk - 13 Ya�)
('Zeynep', 'Demir', 'zeynep.d@diy.com', 'Hash_New6', 1, '1990-01-01'),   -- ID: 12
('Can', 'Canan', 'can.c@diy.com', 'Hash_New7', 1, '1997-01-30'),         -- ID: 13
('Elif', 'Polat', 'elif.p@diy.com', 'Hash_New8', 1, '2000-01-01'),       -- ID: 14
('Burak', 'Sari', 'burak.s@diy.com', 'Hash_New9', 1, '1985-02-28'),      -- ID: 15
('Selin', 'Mavi', 'selin.m@diy.com', 'Hash_New10', 1, '2000-10-10'),     -- ID: 16
('Deniz', 'Gezgin', 'deniz.g@diy.com', 'Hash_New11', 1, '1995-05-05'),   -- ID: 17
('Yagmur', 'Bulut', 'yagmur.b@diy.com', 'Hash_New12', 1, '1998-08-08'),  -- ID: 18
('Cem', 'Tas', 'cem.t@diy.com', 'Hash_New13', 1, '1980-11-11'),          -- ID: 19
('Derya', 'Su', 'derya.s@diy.com', 'Hash_New14', 1, '2002-02-02'),       -- ID: 20
('Kerem', 'Dag', 'kerem.d@diy.com', 'Hash_New15', 1, '2010-01-01'),      -- ID: 21 (Gen�)
('Hakan', 'Yildiz', 'hakan@diy.com', 'Hash_Enr1', 1, '2001-05-20'),      -- ID: 22
('Emel', 'Kaya', 'emel@diy.com', 'Hash_Enr2', 1, '1985-11-10'),          -- ID: 23
('Volkan', 'Demir', 'volkan@diy.com', 'Hash_Enr3', 1, '2002-06-15'),     -- ID: 24
('Asli', 'Sahin', 'asli@diy.com', 'Hash_Enr4', 1, '1990-03-22'),         -- ID: 25
('Murat', 'Koc', 'murat@diy.com', 'Hash_Enr5', 1, '1995-04-23'),         -- ID: 26
('Pelin', 'Su', 'pelin@diy.com', 'Hash_Enr6', 1, '2012-12-12'),          -- ID: 27
('Sinan', 'Can', 'sinan@diy.com', 'Hash_Enr7', 1, '2000-01-01'),         -- ID: 28
('Sema', 'Asci', 'sema@diy.com', 'Hash_M1', 1, '1985-04-15'),            -- ID: 29 (Yeni Ment�r)
('Kemal', 'Tuval', 'kemal@diy.com', 'Hash_M2', 1, '1978-08-30'),         -- ID: 30 (Yeni Ment�r)
('Leyla', 'Esnek', 'leyla@diy.com', 'Hash_M3', 1, '1992-02-14'),         -- ID: 31 (Yeni Ment�r)
('Orhan', 'Devre', 'orhan@diy.com', 'Hash_M4', 1, '1980-11-20');         -- ID: 32 (Yeni Ment�r)
GO


-- TELEFON NUMARASI (HERKESE EKLEND�)
INSERT INTO UserPhones (UserID, PhoneNumber, PhoneType) VALUES
(1, '0532-111-22-33', 'Mobile'), -- Bar�� Hoca
(1, '0212-999-88-77', 'Work'),   -- Bar�� Hoca ��
(2, '0555-444-33-22', 'Mobile'), -- Mert Eser
(3, '0544-555-66-77', 'Mobile'), -- Ege
(4, '0530-123-45-67', 'Mobile'), (5, '0535-987-65-43', 'Mobile'),
(6, '0532-555-11-22', 'Mobile'), (7, '0542-666-33-44', 'Mobile'),
(8, '0533-777-88-99', 'Mobile'), (9, '0555-222-33-44', 'Mobile'),
(10, '0505-111-99-88', 'Mobile'), (11, '0532-333-22-11', 'Mobile'), -- �ocuk (Veli Telefonu)
(12, '0544-888-77-66', 'Mobile'), (13, '0536-444-55-66', 'Mobile'),
(14, '0551-222-11-00', 'Mobile'), (15, '0532-101-20-30', 'Mobile'),
(16, '0542-303-40-50', 'Mobile'), (17, '0533-505-60-70', 'Mobile'),
(18, '0555-707-80-90', 'Mobile'), (19, '0506-909-00-11', 'Mobile'),
(20, '0532-888-77-55', 'Mobile'), (21, '0544-666-55-44', 'Mobile'), -- Gen�
(22, '0535-111-22-99', 'Mobile'), (23, '0542-333-44-88', 'Mobile'),
(24, '0533-555-66-77', 'Mobile'), (25, '0555-777-88-66', 'Mobile'),
(26, '0505-999-00-55', 'Mobile'), (27, '0532-121-23-24', 'Mobile'), -- �ocuk
(28, '0544-343-45-46', 'Mobile'), (29, '0536-565-67-68', 'Mobile'), -- Sema (A���)
(30, '0551-787-89-90', 'Mobile'), -- Kemal (Ressam)
(31, '0532-123-98-76', 'Mobile'), -- Leyla (Yoga)
(32, '0542-987-12-34', 'Work');   -- Orhan (Tamirci - ��)
GO


-- KATEGOR�LER
INSERT INTO Categories (CategoryName, Description) VALUES
('El Sanatlar�', 'Ah�ap, �rg�, seramik , boyama gibi el i�leri'),
('Bilgi Teknolojileri', 'Yaz�l�m, donan�m ve robotik kodlama.'),
('Araba tamiri', 'Araban�n Mekanik ve Elektrik tamiri.'),
('Piyano Kursu','Piyano �almak �steyenler ��in.'),
('Otomobil Sporlar�', 'Drift Atma, Tokyo Drift �zleyip Gaza Gelenler ��in'),
('Mutfak Sanatlar�', 'Yemek pi�irme ve gastronomi.'),
('Sa�l�k ve Ya�am', 'Yoga, meditasyon ve spor.');

-- ROZETLER
INSERT INTO Badges (BadgeName, Description, RequiredWorkshops) VALUES
('Zanaatkar', '�lk at�lye s�nav�n� ge�enlere verilir.', 1),
('Usta ��ra��', '3 at�lyeye kat�l�p ba�ar�l� olan ��rencilere verilir.', 3),
('��leyen Demir I��ldar', '5 at�lye bitiren ��rencilere verilir.', 5),
('��rak Sollar Ustay�', '10 at�lye bitiren sad�k kullan�c�lara verilir.', 10),
('Kumandan','��retti�i becerideki derste,t�m ��rencileri ba�ar�yla ge�mi� ment�re verilir.',1);

-- MATERIALS
INSERT INTO Materials (MaterialName, UnitCost) VALUES
('Ah�ap Blok (Ceviz)', 150.00), ('Oyma B��a�� Seti', 300.00), ('Y�n �plik (Merinos)', 45.00),
('Arduino Uno Seti', 450.00), ('Kaynak Makinesi', 1500.00), ('Tuval ve Boya Malzemeleri' , 200.00),
('Han�n Arabas� (Lastik Dahil)', 50000.00);
GO

-- MENT�RLER
INSERT INTO Mentors (MentorID, Bio, ExpertiseArea, IBAN, IsVerified) VALUES
(1, 'Sanayi Ustas�', 'Arabalarla Alakal� ��ler', 'TR123456789012345678901234', 1), -- bar��
(2, 'Geleneksel motifler �zerine uzman.', 'Tekstil', 'TR987654321098765432109876', 1),  -- mert eser, el sanatlar� kursu 
(5, 'Yaz�l�m m�hendisi, hobi olarak ders veriyor.', 'Yaz�l�m', 'TR112233445566778899001122', 0), -- sertifikas�z , k�ksal
(29, 'Profesyonel A���', 'Gastronomi', 'TR111', 1),
(30, 'Ressam', 'Resim', 'TR222', 1),
(31, 'Yoga E�itmeni', 'Spor', 'TR333', 1),
(32, 'Elektronik Tamircisi', 'Elektronik', 'TR444', 1);

-- LEARNERS
INSERT INTO Learners (LearnerID, InterestLevel, LearningGoals) VALUES
(3, 'Beginner', 'Hobi edinmek ve stresten uzakla�mak.'),   -- ege
(4, 'Advanced', 'Piyano �almay� ��renmek �stiyorum'), -- bahad�r
(5, 'Intermediate', 'Yeni teknolojileri ��renmek.'),   -- k�ksal (Hem hoca hem ��renci)
(6, 'Beginner', 'Drift Atmay� ��renmek'); -- g�kdeniz


INSERT INTO Learners (LearnerID, InterestLevel, LearningGoals)
SELECT UserID, 'Beginner', 'Kendimi geli�tirmek' -- otomatik
FROM Users 
WHERE UserID BETWEEN 7 AND 28;
GO

-- SKILLS
INSERT INTO Skills (SkillName, CategoryID) VALUES
('Kaynak Yapma', 3),    -- ID 1
('Motif Teknikleri', 1), -- ID 2
('Python ile Kodlama', 2), -- ID 3
('Robotik', 2),        -- ID 4
('Drift Atma', 5),    -- ID 5
('�talyan Mutfa��', 6),
('Ya�l� Boya', 1),
('Yoga', 7),
('Telefon Tamiri', 2);
GO

-- WORKSHOPS
INSERT INTO Workshops (Title, Description, Price, Capacity, WorkshopDate, Location, MentorID, SkillID, MinPassingGrade, MinAge, City, District, PrerequisiteWorkshopID) VALUES
('Arabaya Kaynak Yapma', 'Kendi kayna��n� kendin yap.', 250.00, 10, '2023-12-10 14:00:00', 'Haramidere Sanayi', 1, 1, 60, 18, '�stanbul', 'Esenyurt', NULL), -- bar�� hoca
('K��l�k Atk� �rme', 'Yeni ba�layanlar i�in �rg�.', 100.00, 5, '2023-11-20 10:00:00', 'GSB Sanat At�lyesi', 2, 2, 50, 10, '�stanbul', 'Bak�rk�y', NULL),   -- Mert Hoca
('Python Giri�', 'Veri analizine ilk ad�m.', 500.00, 20, '2023-12-15 19:00:00', '�K� Bilgisayar Laboratuvar�', 5, 3, 70, 16, '�stanbul', 'Bak�rk�y', NULL), -- k�ksal Hoca
('Drift 101','Gelin Yanlayal�m.', 1000.00, 5, '2023-12-20 13:00:00', 'F1 Pisti', 1, 5, 80, 21, '�stanbul', 'Tuzla', NULL), -- Bar�� Hoca
('�leri Python', 'Yapay Zeka', 600.00, 10, '2024-05-01', 'Online', 5, 3, 75, 18, 'Online', 'Global', NULL), -- Yeni Ders
('Robotik Kodlama', 'Arduino Temelleri', 300.00, 8, '2024-06-01', 'At�lye', 5, 4, 60, 12, '�stanbul', 'Kad�k�y', NULL), -- Yeni Ders
('�talyan Makarnas� Yap�m�', 'S�f�rdan hamur yap�m�.', 300.00, 8, '2024-07-10', 'Mutfak At�lyesi', 29, 6, 60, 12, '�stanbul', 'Be�ikta�', NULL),
('Manzara Resim Dersi', 'Ya�l� boya teknikleri.', 400.00, 6, '2024-07-12', 'Sanat Evi', 30, 7, 50, 15, '�zmir', 'Konak', NULL),
('Sabah Yogas�', 'G�ne zinde ba�la.', 150.00, 15, '2024-07-15', 'Park', 31, 8, 0, 18, 'Antalya', 'Muratpa�a', NULL),
('Ak�ll� Telefon Tamiri', 'Ekran ve batarya de�i�imi.', 600.00, 5, '2024-07-20', 'Tekno Lab', 32, 9, 70, 16, 'Ankara', '�ankaya', NULL);
GO

-- �n Ko�ul Atamas� (Unary Relationship)
UPDATE Workshops SET PrerequisiteWorkshopID = 3 WHERE WorkshopID = 5;
GO

-- ENROLLMENTS
INSERT INTO Enrollments (WorkshopID, LearnerID, EnrollmentDate, Grade, Status) VALUES
(1, 3, '2023-11-01', 90, 'Completed'),  -- ege bar�� hocan�n arabaya kaynak dersini ald� ve tamamlad�
(2, 4, GETDATE(), NULL, 'Enrolled'),  -- bahad�r mert hocan�n atk� �rme dersine yeni kay�t yapt�
(1, 5, '2023-11-05', NULL, 'Cancelled'),  -- k�ksal kaynak dersine kat�ld� ama sonra iptal etti
(4, 6, '2023-12-05', NULL, 'Enrolled'), -- g�kdeniz drift dersine (4) kay�t oldu

-- [EKSTRA KAYITLAR - TAMAMLANANLAR & BA�ARISIZLAR & YEN�LER]
-- Ders 1 (Kaynak) - Bar�� Hoca
(1, 7, '2023-11-02', 85, 'Completed'),  -- Ahmet (Ge�ti)
(1, 8, '2023-11-03', 45, 'Failed'),     -- Ay�e (Kald� - Notu d���k)

-- Ders 2 (�rg�) - Mert Hoca
(2, 9, '2023-11-21', 95, 'Completed'),  -- Mehmet (Ge�ti - �ok be�endi)
(2, 11, GETDATE(), NULL, 'Enrolled'),   -- Ali (�ocuk - Kay�tl�)

-- Ders 3 (Python) - K�ksal Hoca
(3, 10, '2023-12-16', 75, 'Completed'), -- Fatma (Ge�ti)
(3, 12, '2023-12-16', 65, 'Failed'),    -- Zeynep (Kald� - Baraj 70 idi)

-- Ders 4 (Drift) - Bar�� Hoca
(4, 15, '2023-12-21', 100, 'Completed'), -- Burak (Drift Kral� - Ge�ti)

-- Ders 6 (Robotik) - Yeni
(6, 11, '2024-06-05', 80, 'Completed'),  -- Ali (Robotik dersini ge�ti)

(1, 22, GETDATE(), NULL, 'Enrolled'),
(2, 23, GETDATE(), NULL, 'Enrolled'),
(3, 24, GETDATE(), NULL, 'Enrolled'),
(4, 25, GETDATE(), NULL, 'Enrolled'),
(5, 26, GETDATE(), NULL, 'Enrolled'),
(6, 27, GETDATE(), NULL, 'Enrolled'),
(3, 28, GETDATE(), NULL, 'Enrolled');
GO

-- REVIEWS
INSERT INTO Reviews (WorkshopID, LearnerID, Rating, Comment) VALUES
(1, 3, 5, 'Haramidere sanayinin atmosferi harikayd�, Bar�� usta i�inin ehli'),  -- ege
(1, 7, 4, 'G�zel dersti ama at�lye biraz so�uktu.'), -- Ahmet (Kaynak dersi)
(1, 8, 2, '�ok zordu, hocam biraz h�zl� anlatt� bence.'), -- Ay�e (Kalan ��renci)
(2, 9, 5, 'Mert hoca �ok sab�rl�, �rg� �rmek terapi gibi geldi!'), -- Mehmet (�rg�)
(3, 10, 5, 'Python harika, K�ksal hoca �ok iyi anlat�yor.'), -- Fatma (Python)
(4, 15, 5, 'Lastik yakmak m�thi�ti! Bar�� hoca ile yanlad�k.'), -- Burak (Drift)
(6, 11, 4, 'Robotum �al��t�! �ok mutluyum.'); -- Ali (Robotik - �ocuk)
GO


-- WORKSHOP MATERIALS
INSERT INTO WorkshopMaterials (WorkshopID, MaterialID, Quantity) VALUES
(1, 5, 1),   -- 1 id li ders, kaynak dersi i�in 5 id si yani kaynak makinesi laz�m , 1 tane
(2, 3, 2),  -- atk� �rme dersi i�in 2 tane y�n iplik
(3, 4, 1),  -- python i�in ardunio laz�m
(4, 7, 4);  -- Drift i�in 4 tane lastik (Han�n arabas� malzemesi) laz�m

-- WAITLIST
INSERT INTO Waitlist (WorkshopID, LearnerID, RequestDate) VALUES
(3, 4, GETDATE()),  -- python dersine (3) , bahad�r (4) , s�ra bekliyor getdate
(2, 13, GETDATE()); -- Can �rg� dersine s�ra bekliyor

-- USERBADGES
INSERT INTO UserBadges (LearnerID, BadgeID, AwardedDate) VALUES
(3, 1, GETDATE()); -- ege kaynak dersini ge�ti ve zanaatkar rozetini kazand�


-- enrollments tablosunda 'Completed' olanlara yeteneklerini otomatik olarak ekler.
INSERT INTO UserSkills (UserID, SkillID, ProficiencyLevel, AcquiredDate)
SELECT 
    e.LearnerID, 
    w.SkillID, 
    'Beginner', 
    e.EnrollmentDate
FROM Enrollments e
JOIN Workshops w ON e.WorkshopID = w.WorkshopID
WHERE e.Status = 'Completed';

PRINT '--- BA�ARIYLA TAMAMLANDI  ---';
PRINT 'Kullan�c� Say�s�: 32';
PRINT 'Tamamlanan Ders Say�s�: 10';
PRINT 'Toplam Yorum Say�s�: 7';
GO
