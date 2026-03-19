USE DIY_SKILL_SHARING_APP;
GO

-- LOGIN Olu�turma

CREATE LOGIN [AtolyeYonetici] WITH PASSWORD = 'StrongPass!123'; -- �ifreler
CREATE LOGIN [AtolyeAsistan] WITH PASSWORD = 'WeakPass!123'; 
GO

CREATE USER [YoneticiUser] FOR LOGIN [AtolyeYonetici];  -- veritaban� kullan�c�lar�,y�netici
CREATE USER [AsistanUser] FOR LOGIN [AtolyeAsistan]; -- asistan
GO

GRANT EXECUTE TO [YoneticiUser];   -- y�netici her �eyi yapabilir
GRANT SELECT, INSERT, UPDATE, DELETE TO [YoneticiUser];

GRANT SELECT ON vw_SystemGeneralReport TO [AsistanUser];  -- asistan sadece rapor view okuyabilir

DENY DELETE ON Enrollments TO [AsistanUser];  -- asistan�n kayd� silmesini engelle

PRINT 'G�venlik ayarlar� tamamland�.';
GO
