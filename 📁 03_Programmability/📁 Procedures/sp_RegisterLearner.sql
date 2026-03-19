USE DIY_SKILL_SHARING_APP;
GO

DROP PROCEDURE IF EXISTS sp_RegisterLearner;
GO

CREATE PROCEDURE sp_RegisterLearner
    @LearnerID INT,
    @WorkshopID INT
AS
BEGIN
    SET NOCOUNT ON; 

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ��renci kay�t ederken kay�t ve kontenjan durumu kontrol� --
        IF NOT EXISTS (SELECT 1 FROM Learners WHERE LearnerID = @LearnerID)  -- e�er girilen id de bir ��renci yok ise
        BEGIN
            THROW 51000, 'Hata: ��renci bulunamad�.', 1;  -- hata uyar�s�
        END
            
        IF NOT EXISTS (SELECT 1 FROM Workshops WHERE WorkshopID = @WorkshopID)  -- e�er at�lye yok ise
        BEGIN
            THROW 51000, 'Hata: At�lye bulunamad�.', 1; -- at�lye bulunamaz
        END

      -- gerekli tarih ve ya� s�n�r� al�n�r
        DECLARE @UserBirthDate DATE;    
        DECLARE @WorkshopDate DATETIME;
        DECLARE @RequiredMinAge INT; -- dersin ya� s�n�r�
        
        SELECT @UserBirthDate = BirthDate FROM Users WHERE UserID = @LearnerID; -- ��rencinin do�um tarihi al�n�r
        
        SELECT @WorkshopDate = WorkshopDate, @RequiredMinAge = MinAge -- at�lyenin ya� s�n�r� belirlenir 
        FROM Workshops WHERE WorkshopID = @WorkshopID; 

        IF @UserBirthDate IS NULL OR DATEDIFF(YEAR, @UserBirthDate, GETDATE()) < @RequiredMinAge  -- e�er ald���m�z do�um tarihi ya�a g�re bak�ld���nda, ya� s�n�r�ndan k���kse
        BEGIN
            
            DECLARE @AgeErrorMsg NVARCHAR(100) = 'Hata: ��rencinin bu at�lyeye kat�lmas� i�in  en az ' + CAST(@RequiredMinAge AS NVARCHAR(5)) + ' ya��nda olmal�s�n�z.'; -- ya� uyar�s� verilir
            THROW 51000, @AgeErrorMsg, 1;
        END

        IF EXISTS (  -- e�er bir ��renci zaten dersi oldu�u bir saatteki derse kaydolmaya �al���rsa
            SELECT 1 
            FROM Enrollments e
            JOIN Workshops w ON e.WorkshopID = w.WorkshopID
            WHERE e.LearnerID = @LearnerID 
              AND e.Status = 'Enrolled' -- �uan kay�tl� oldu�u derslerden
              AND w.WorkshopDate = @WorkshopDate -- ayn� tarih ve saatte olan
              AND w.WorkshopID <> @WorkshopID  -- kendisi hari�
        )
        BEGIN
            THROW 51000, 'Hata: Se�ilen tarihte zaten ba�ka bir dersiniz var! Kay�t Ba�ar�s�z.', 1; -- kay�t ba�ar�s�z hatas� verilir
        END

        DECLARE @MentorID INT;
        SELECT @MentorID = MentorID FROM Workshops WHERE WorkshopID = @WorkshopID; -- ment�r i�in

        IF @MentorID = @LearnerID  -- e�er bir ment�r ayn� zamanda ��renci ise 
        BEGIN
            THROW 51000, 'Hata: Ment�r kendi dersine ��renci olarak kaydolamaz!', 1; -- kendi dersine kay�t olamaz
        END

        IF EXISTS (SELECT 1 FROM Enrollments WHERE LearnerID = @LearnerID AND WorkshopID = @WorkshopID AND Status IN ('Enrolled', 'Completed'))  -- ��renci ve at�lyeler zaten e�le�iyor ise
        BEGIN
            THROW 51000, 'Hata: Bu ��renci zaten bu derse kay�tl�.', 1;  -- o ��renci zaten derse kay�tl�d�r
        END

    ----- Kontenjan Doluluk Durumunu Kontrol Etmek -----

        DECLARE @CurrentCount INT; -- saya�
        DECLARE @MaxCapacity INT;  -- kapasite
        
        SELECT @MaxCapacity = Capacity FROM Workshops WHERE WorkshopID = @WorkshopID;  -- Workshop id ye g�re o at�lyenin kapasitesini al ve MaxCapacity e ata
        SELECT @CurrentCount = COUNT(*) FROM Enrollments WHERE WorkshopID = @WorkshopID AND Status IN ('Enrolled', 'Completed');  -- �uanki ��renci sayac�n�, at�lyenin kay�t olmu� ve tamamlam�� olan kay�tl� ��rencilerinden alarak ba�lat.

        IF @CurrentCount >= @MaxCapacity  -- e�er kay�tl� veya tamamlam�� ��renci say�s�, maximum kapasiteye e�it veya fazla ise
        BEGIN

            IF NOT EXISTS (SELECT 1 FROM Waitlist WHERE LearnerID = @LearnerID AND WorkshopID = @WorkshopID) -- bekleme listesinde o ��renci yok ise
            BEGIN
                INSERT INTO Waitlist (WorkshopID, LearnerID) VALUES (@WorkshopID, @LearnerID);  -- o ��renci beklemesi i�in waitlist tablosuna al�n�r
                
                COMMIT TRANSACTION;  -- i�lemi onayla
                PRINT 'Kontenjan dolu. ��renci Bekleme Listesine eklendi.'; -- kullan�c�y� bilgilendir
            END
            ELSE
            BEGIN

                COMMIT TRANSACTION;
                PRINT 'Uyar�: ��renci zaten bekleme listesinde.';   -- zaten listede ise uyar� verilir
            END
            
            RETURN;
        END  -- bitir

        INSERT INTO Enrollments (WorkshopID, LearnerID, Status, Grade)  -- kontenjan var ise ��renciyi derse ekle
        VALUES (@WorkshopID, @LearnerID, 'Enrolled', NULL);  -- eklenmi� durumuna getir (Grade NULL ba�lar)

        COMMIT TRANSACTION; -- i�lemi onayla
        PRINT 'Ba�ar�l�: Kay�t i�lemi tamamland�.';  -- kullan�c�y� bilgilendir

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;  -- hata olursa , her �eyi geri al
        END

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'HATA OLU�TU: ' + @ErrorMessage;
        
        THROW; 
    END CATCH

END; 
GO
