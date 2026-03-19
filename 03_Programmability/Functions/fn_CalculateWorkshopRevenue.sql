USE DIY_SKILL_SHARING_APP;
GO

CREATE FUNCTION fn_CalculateWorkshopRevenue (@WorkshopID INT)  -- at�lyelerin kazan�lar�n� ve pop�lerli�ini getiren fonksiyon
RETURNS DECIMAL(10, 2)  -- decimal d�nd�r�r
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(10, 2);  -- toplam has�lat
    DECLARE @Price DECIMAL(10, 2);  
    DECLARE @StudentCount INT;

    SELECT @Price = Price FROM Workshops WHERE WorkshopID = @WorkshopID;

    SELECT @StudentCount = COUNT(*) 
    FROM Enrollments 
    WHERE WorkshopID = @WorkshopID AND Status IN ('Enrolled', 'Completed');  -- Dersini iptal eden ��renciler d���nda

    SET @TotalRevenue = ISNULL(@Price * @StudentCount, 0);  -- kalan t�m ��rencilerin ald��� dersler ile toplam �cret �arp�l�r ve has�lat hesaplan�r

    RETURN @TotalRevenue;  -- has�lat d�nd�r�l�r
END;
GO

--- AT�LYE POP�LERL�KLER� ---
PRINT 'EN POP�LER AT�LYELER'; 

SELECT TOP 3  -- en pop�ler 3 at�lye
    w.Title AS [At�lye Ad�],
    cat.CategoryName AS [Kategori],
    (u.FirstName + ' ' + u.LastName) AS [Ment�r],
    COUNT(e.EnrollmentID) AS [Toplam ��renci], -- ��renci say�s�na g�re
    
    dbo.fn_CalculateWorkshopRevenue(w.WorkshopID) AS [Toplam Has�lat]  -- fonksiyonu toplam has�lat i�in �a��r�r

FROM Workshops w
JOIN Enrollments e ON w.WorkshopID = e.WorkshopID
JOIN Mentors m ON w.MentorID = m.MentorID
JOIN Users u ON m.MentorID = u.UserID
JOIN Skills s ON w.SkillID = s.SkillID
JOIN Categories cat ON s.CategoryID = cat.CategoryID
WHERE e.Status IN ('Enrolled', 'Completed') -- sadece aktif kay�tlar
GROUP BY w.WorkshopID, w.Title, cat.CategoryName, u.FirstName, u.LastName
ORDER BY [Toplam ��renci] DESC; -- en �ok ��rencisi olan en �stte
GO

--- MENT�R KAZAN�LARI
PRINT ' ';
PRINT 'MENT�R KAZAN� SIRALAMASI';

SELECT TOP 5  -- en �ok kazanan 5 ment�r
    (u.FirstName + ' ' + u.LastName) AS [Ment�r Ad�],
    m.ExpertiseArea AS [Uzmanl�k Alan�],
    COUNT(DISTINCT w.WorkshopID) AS [A�t��� Ders Say�s�], -- a�t��� ders say�s� kadar
    
    SUM(dbo.fn_CalculateWorkshopRevenue(w.WorkshopID)) AS [Toplam Kazan�] -- ment�r�n verdi�i t�m derslerin has�lat toplam�

FROM Mentors m
JOIN Users u ON m.MentorID = u.UserID
JOIN Workshops w ON m.MentorID = w.MentorID
GROUP BY m.MentorID, u.FirstName, u.LastName, m.ExpertiseArea
ORDER BY [Toplam Kazan�] DESC; -- en �ok kazanandan en az kazanana do�ru s�rala
GO


--- KATEGOR� POP�LERL���
PRINT ' ';
PRINT 'KATEGOR� POP�LERL�KLER�';

SELECT 
    cat.CategoryName AS [Kategori],
    COUNT(e.EnrollmentID) AS [Toplam Kay�t Say�s�],
    AVG(r.Rating) AS [Ortalama Puan] -- e�er derecelndirildiyse ortalamas�n� al�

FROM Categories cat
JOIN Skills s ON cat.CategoryID = s.CategoryID
JOIN Workshops w ON s.SkillID = w.SkillID
LEFT JOIN Enrollments e ON w.WorkshopID = e.WorkshopID AND e.Status IN ('Enrolled', 'Completed')
LEFT JOIN Reviews r ON w.WorkshopID = r.WorkshopID
GROUP BY cat.CategoryName
ORDER BY [Toplam Kay�t Say�s�] DESC;
GO
