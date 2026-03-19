USE DIY_SKILL_SHARING_APP;
GO

DROP PROCEDURE IF EXISTS sp_SearchWorkshops;
GO

CREATE PROCEDURE sp_SearchWorkshops  -- arama i�in �zellikler
    @Keyword NVARCHAR(50) = NULL,      -- dersin ad�nda ge�en kelime (title)
    @MinPrice DECIMAL(10,2) = NULL,    -- dersin minimum fiyat�
    @MaxPrice DECIMAL(10,2) = NULL,    -- dersin maksimum fiyat�
    @CategoryName NVARCHAR(50) = NULL  -- dersin kategorisi
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        w.WorkshopID,
        w.Title AS [Ders Adi],
        w.Price AS [Ucret],
        w.WorkshopDate AS [Tarih],
        w.Capacity AS [Kontenjan],
        c.CategoryName AS [Kategori],
        CONCAT(u.FirstName, ' ', u.LastName) AS [Egitmen]  -- birle�tirme
    FROM Workshops w
    INNER JOIN Skills s ON w.SkillID = s.SkillID
    INNER JOIN Categories c ON s.CategoryID = c.CategoryID
    INNER JOIN Mentors m ON w.MentorID = m.MentorID
    INNER JOIN Users u ON m.MentorID = u.UserID
    WHERE 

        (@Keyword IS NULL OR w.Title LIKE '%' + @Keyword + '%')  -- anahtar kelime yoksa hepsini getir,varsa ara
        
        -- fiyat filtrelemeleri
        AND (@MinPrice IS NULL OR w.Price >= @MinPrice)
        AND (@MaxPrice IS NULL OR w.Price <= @MaxPrice)
        
        -- i�inde ge�en kelimeye g�re kategori filtrelemesi
        AND (@CategoryName IS NULL OR c.CategoryName LIKE '%' + @CategoryName + '%')
    
    ORDER BY w.WorkshopDate;  -- at�lye tarihine g�re s�ralar
END;
GO
