-- TABLE-VALUED FUNCTION

CREATE FUNCTION fn_GetMentorSchedule (@MentorID INT)  -- bir ment�r�n birden fazla ders veriyorsa ders program�n� d�nd�r�r
RETURNS TABLE
AS
RETURN (
    SELECT 
        w.Title AS Ders_Adi,
        w.WorkshopDate AS Tarih,
        w.Capacity AS Kontenjan,
        w.Price AS Ucret
    FROM Workshops w
    WHERE w.MentorID = @MentorID
);
GO


SELECT * FROM fn_GetMentorSchedule(1);  -- id si 1 olan hocan�n derslerini getirir,sorgu i�inde tablo gibi
