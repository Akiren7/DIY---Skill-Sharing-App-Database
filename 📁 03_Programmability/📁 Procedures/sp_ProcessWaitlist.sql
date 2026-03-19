DROP PROCEDURE IF EXISTS sp_ProcessWaitlist;           -- Varsa eski prosed�r� sil
GO

CREATE PROCEDURE sp_ProcessWaitlist                    -- Bekleme listesi prosed�r�
    @WorkshopID INT                                    -- Hangi at�lye i�in �al��acak
AS
BEGIN
    SET NOCOUNT ON;                                    -- Mesaj kirlili�ini �nle
    BEGIN TRANSACTION;                                 -- ��lemi ba�lat (Hepsi ya da hi�biri)

    BEGIN TRY
        DECLARE @CurrentCount INT, @MaxCapacity INT;   -- De�i�kenleri tan�mla
        SELECT @MaxCapacity = Capacity FROM Workshops WHERE WorkshopID = @WorkshopID; -- Kapasiteyi �ek
        SELECT @CurrentCount = COUNT(*) FROM Enrollments WHERE WorkshopID = @WorkshopID AND Status IN ('Enrolled', 'Completed'); -- Mevcut say�y� bul

        IF @CurrentCount >= @MaxCapacity               -- Yer yoksa kontrol�
        BEGIN
            PRINT 'UYARI: Kapasite hala dolu.';        -- Uyar� ver
            COMMIT TRANSACTION;                        -- ��lemi bitir (De�i�iklik yok)
            RETURN;
        END

        DECLARE @NextLearnerID INT;                    -- S�radaki ��renci de�i�keni
        
        SELECT TOP 1 @NextLearnerID = LearnerID        -- �lk ki�iyi se�
        FROM Waitlist 
        WHERE WorkshopID = @WorkshopID
        ORDER BY RequestDate ASC;                      -- Ba�vuru tarihine g�re (�lk gelen)

        IF @NextLearnerID IS NULL                      -- Liste bo�sa kontrol�
        BEGIN
            PRINT 'B�LG�: Bekleme listesi bo�.';       -- Bilgi ver
            COMMIT TRANSACTION;                        -- ��lemi bitir
            RETURN;
        END

        INSERT INTO Enrollments (WorkshopID, LearnerID, Status, Grade) -- Derse kaydet
        VALUES (@WorkshopID, @NextLearnerID, 'Enrolled', NULL);

        DELETE FROM Waitlist                           -- Listeden sil
        WHERE WorkshopID = @WorkshopID AND LearnerID = @NextLearnerID;

        COMMIT TRANSACTION;                            -- De�i�iklikleri onayla ve kaydet
        PRINT 'BA�ARILI: ��renci derse al�nd�.';       -- Ba�ar� mesaj�

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;                          -- Hata varsa her �eyi geri al
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE(); -- Hata mesaj�n� yakala
        RAISERROR('��lem hatas�: %s', 16, 1, @ErrMsg); -- Hatay� kullan�c�ya g�ster
    END CATCH
END;
GO
