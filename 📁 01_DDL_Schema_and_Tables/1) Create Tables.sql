CREATE DATABASE DIY_SKILL_SHARING_APP
GO

USE DIY_SKILL_SHARING_APP
GO

CREATE TABLE Users (  -- USER superclass çünkü kullanýcý hem Mentör hem de öðrenci olabilir.
    UserID INT PRIMARY KEY IDENTITY(1,1),  -- id incremented by one after every user
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,  -- Þifre
    CreatedAt DATETIME DEFAULT GETDATE(),  -- Oluþturulma tarihi
    IsActive BIT DEFAULT 1,  -- Hala kullanýlýyor mu
    BirthDate DATE  -- yaþ kýsýtlamasý için
);
GO

CREATE TABLE Mentors (   -- Userý subclass ý
    MentorID INT PRIMARY KEY, -- UserID ile ayný olacak (1:1)
    Bio NVARCHAR(MAX),  -- Mentör biyografisi
    ExpertiseArea NVARCHAR(100),   -- Uzmanlýk alanlý ( verilen kurs )
    IBAN NVARCHAR(34), -- Ödeme için iban
    IsVerified BIT DEFAULT 0,   -- Mentör gerçekten iþinin ehli mi
    CONSTRAINT FK_Mentors_Users FOREIGN KEY (MentorID) REFERENCES Users(UserID)  -- Mentörün ID si kend User Id si
);
GO

CREATE TABLE Learners (    -- Userý subclass ý
    LearnerID INT PRIMARY KEY, -- UserID ile ayný olacak (1:1)
    InterestLevel NVARCHAR(20) CHECK (Status IN ('Enrolled', 'Completed', 'Cancelled'),  -- Sadece Giriþ Orta ve Uzmanlýk seviyeleri
    LearningGoals NVARCHAR(MAX), -- hedefler
    CONSTRAINT FK_Learners_Users FOREIGN KEY (LearnerID) REFERENCES Users(UserID)  -- LearnerID is UserID
);
GO

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),  
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)  -- kategorinin açýklamasý
);
GO


CREATE TABLE Skills (
    SkillID INT PRIMARY KEY IDENTITY(1,1),
    SkillName NVARCHAR(50) NOT NULL,
    CategoryID INT NOT NULL,
    CONSTRAINT FK_Skills_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)  -- Becerinin kategorisi id sinden gelir
);
GO

-- Yeni Tablo: KULLANICI YETENEKLERÝ
CREATE TABLE UserSkills (
    UserSkillID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    SkillID INT NOT NULL,
    ProficiencyLevel NVARCHAR(20) DEFAULT 'Beginner', -- varsayýlan beginner
    AcquiredDate DATETIME DEFAULT GETDATE(),
    
    -- bir kiþi ayný yeteneðe iki kere sahip olamaz 
    CONSTRAINT UQ_User_Skill UNIQUE (UserID, SkillID),
    
    CONSTRAINT FK_US_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_US_Skills FOREIGN KEY (SkillID) REFERENCES Skills(SkillID)
);
GO

CREATE TABLE Workshops (
    WorkshopID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(10, 2) CHECK (Price >= 0),  -- atölye ücreti
    Capacity INT CHECK (Capacity > 0), -- atölyenin kapasitesi
    WorkshopDate DATETIME NOT NULL,  -- tarihleri
    Location NVARCHAR(200),  -- konumu
    MentorID INT NOT NULL,  -- mentörün id
    SkillID INT NOT NULL,
    CONSTRAINT FK_Workshops_Mentors FOREIGN KEY (MentorID) REFERENCES Mentors(MentorID),  -- Workshop mentörü için mentör ID den al
    CONSTRAINT FK_Workshops_Skills FOREIGN KEY (SkillID) REFERENCES Skills(SkillID)  -- Yetenek/Hobi için Skills ID den al
);
GO


CREATE TABLE Enrollments (   -- kayýtlar
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    WorkshopID INT NOT NULL,
    LearnerID INT NOT NULL,
    EnrollmentDate DATETIME DEFAULT GETDATE(),   -- kayýt tarihi
    Grade INT CHECK (Grade BETWEEN 0 AND 100),  -- sonuç 0 ve 100 arasýnda
    Status NVARCHAR(20) DEFAULT 'Enrolled' CHECK (Status IN ('Enrolled', 'Completed', 'Cancelled', 'Failed')),  -- Dersteki kaydolma,tamamlanma,baþarýsýz ve iptal durumlarýný kontrol , varsayýlan kayýt olundu halindedir
    CONSTRAINT FK_Enrollments_Workshops FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID),
    CONSTRAINT FK_Enrollments_Learners FOREIGN KEY (LearnerID) REFERENCES Learners(LearnerID)
);
GO

CREATE TABLE Materials (
    MaterialID INT PRIMARY KEY IDENTITY(1,1),
    MaterialName NVARCHAR(100) NOT NULL,
    UnitCost DECIMAL(10, 2)  -- adet bedeli
);
GO


CREATE TABLE Badges (
    BadgeID INT PRIMARY KEY IDENTITY(1,1),
    BadgeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    RequiredWorkshops INT   -- Rozeti kazanmak için kaç ders bitirilmeli
);
GO

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    WorkshopID INT NOT NULL,
    LearnerID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),  -- derecelendirme
    Comment NVARCHAR(MAX),  -- yorum
    CreatedAt DATETIME DEFAULT GETDATE(),  -- oluþturulma tarihi
    CONSTRAINT FK_Reviews_Workshops FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID),
    CONSTRAINT FK_Reviews_Learners FOREIGN KEY (LearnerID) REFERENCES Learners(LearnerID)
);
GO

CREATE TABLE WorkshopMaterials (
    WorkshopID INT NOT NULL,
    MaterialID INT NOT NULL,
    Quantity INT DEFAULT 1,
    PRIMARY KEY (WorkshopID, MaterialID), -- Composite PK
    CONSTRAINT FK_WM_Workshops FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID),
    CONSTRAINT FK_WM_Materials FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID)
);
GO

CREATE TABLE Waitlist (   -- kapasiteden dolayý kayýt bekleyen öðrenciler
    WaitlistID INT PRIMARY KEY IDENTITY(1,1),
    WorkshopID INT NOT NULL,
    LearnerID INT NOT NULL,
    RequestDate DATETIME DEFAULT GETDATE(),  -- kayýt için request tarihi
    CONSTRAINT FK_Waitlist_Workshops FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID),
    CONSTRAINT FK_Waitlist_Learners FOREIGN KEY (LearnerID) REFERENCES Learners(LearnerID)
);
GO

CREATE TABLE UserBadges (
    UserBadgeID INT PRIMARY KEY IDENTITY(1,1),
    LearnerID INT NOT NULL,
    BadgeID INT NOT NULL,
    AwardedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UB_Learners FOREIGN KEY (LearnerID) REFERENCES Learners(LearnerID),
    CONSTRAINT FK_UB_Badges FOREIGN KEY (BadgeID) REFERENCES Badges(BadgeID)
);
GO
