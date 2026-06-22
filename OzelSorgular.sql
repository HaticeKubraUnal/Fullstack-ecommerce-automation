-- 1. VERÝTABANI BAÐLANTISI
USE ETicaretProjesi_Son;
GO

-- 2. ÖNCE ESKÝ VIEW VARSA SÝLELÝM (Hata almamak için)
IF OBJECT_ID('View_UrunKategori', 'V') IS NOT NULL DROP VIEW View_UrunKategori;
GO

-- 3. TABLOLARI DOÐRU SIRAYLA OLUÞTURUYORUZ
-- Baðýmsýz Tablolar
IF OBJECT_ID('SEPET', 'U') IS NULL CREATE TABLE SEPET (SepetID INT PRIMARY KEY);
IF OBJECT_ID('KATEGORI', 'U') IS NULL CREATE TABLE KATEGORI (KategoriID INT PRIMARY KEY, KategoriAdi VARCHAR(100) NOT NULL);
IF OBJECT_ID('SATICI', 'U') IS NULL CREATE TABLE SATICI (SaticiID INT PRIMARY KEY, MagazaAdi VARCHAR(100) NOT NULL, Email VARCHAR(100) UNIQUE, Telefon VARCHAR(15), VergiNo VARCHAR(50));
IF OBJECT_ID('KART', 'U') IS NULL CREATE TABLE KART (KartNo VARCHAR(16) PRIMARY KEY, SonKullanma VARCHAR(5), CVV VARCHAR(3));
IF OBJECT_ID('MUSTERI', 'U') IS NULL CREATE TABLE MUSTERI (MusteriID INT PRIMARY KEY, Fname VARCHAR(50), Lname VARCHAR(50), Email VARCHAR(100) UNIQUE, Telefon VARCHAR(15), Password VARCHAR(50), Mahalle VARCHAR(100), Sokak VARCHAR(100), Il VARCHAR(50), Ilce VARCHAR(50));
GO

-- Baðýmlý Tablolar (URUN burada oluþuyor)
IF OBJECT_ID('URUN', 'U') IS NULL 
CREATE TABLE URUN (
    UrunID INT PRIMARY KEY, 
    UrunAdi VARCHAR(100) NOT NULL, 
    Fiyat DECIMAL(10,2) NOT NULL, 
    Stok INT NOT NULL, 
    SaticiID INT REFERENCES SATICI(SaticiID),
    UrunFoto VARCHAR(255) -- Web sitemiz için kritik olan sütun
);

IF OBJECT_ID('URUN_SINIFLANDIRMA', 'U') IS NULL 
CREATE TABLE URUN_SINIFLANDIRMA (
    KategoriID INT REFERENCES KATEGORI(KategoriID), 
    UrunID INT REFERENCES URUN(UrunID), 
    PRIMARY KEY (KategoriID, UrunID)
);
GO

-- 4. ÞÝMDÝ VIEW'I OLUÞTURUYORUZ (Artýk URUN tablosu var!)
CREATE VIEW View_UrunKategori AS
SELECT 
    U.UrunAdi, 
    U.Fiyat, 
    K.KategoriAdi
FROM URUN U
INNER JOIN URUN_SINIFLANDIRMA US ON U.UrunID = US.UrunID
INNER JOIN KATEGORI K ON US.KategoriID = K.KategoriID;
GO

-- 5. TEST EDELÝM
SELECT 'Kurulum Baþarýlý' as Durum;
SELECT * FROM View_UrunKategori;





USE ETicaretProjesi_Son;
GO

-- Önce prosedürü oluþturalým (Eðer daha önce oluþturmadýysan)
CREATE OR ALTER PROCEDURE sp_YeniKategoriEkle
    @p_KategoriID INT,
    @p_KategoriAdi VARCHAR(100)
AS
BEGIN
    INSERT INTO KATEGORI (KategoriID, KategoriAdi)
    VALUES (@p_KategoriID, @p_KategoriAdi);
    PRINT 'Yeni kategori baþarýyla eklendi.';
END;
GO

-- ÞÝMDÝ TEST EDELÝM:
EXEC sp_YeniKategoriEkle @p_KategoriID = 500, @p_KategoriAdi = 'Oyuncu Ekipmanlarý';

-- Kontrol edelim:
SELECT * FROM KATEGORI WHERE KategoriID = 500;





USE ETicaretProjesi_Son;
GO

-- Önce test için bir ürün ve stok ekleyelim (Eðer tablo boþsa)
INSERT INTO SATICI (SaticiID, MagazaAdi, Email, Telefon, VergiNo) VALUES (99, 'Test Maðaza', 't@m.com', '123', '123');
INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID, UrunFoto) VALUES (99, 'Test Klavye', 1000, 20, 99, 'img.jpg');
GO

-- TRÝGGER
CREATE OR ALTER TRIGGER trg_StokDusur
ON SIPARIS_DETAY
AFTER INSERT
AS
BEGIN
    UPDATE URUN
    SET Stok = Stok - i.Adet
    FROM URUN u
    INNER JOIN inserted i ON u.UrunID = i.UrunID;
END;
GO

-- TEST: Stoðu 20 olan üründen 3 tane sipariþ verelim
SELECT 'Satýþ Öncesi Stok' as Durum, Stok FROM URUN WHERE UrunID = 99;

INSERT INTO SIPARIS_DETAY (SiparisDetayID, Adet, BirimFiyat, SiparisID, UrunID) 
VALUES (555, 3, 1000, 1, 99);

SELECT 'Satýþ Sonrasý Stok' as Durum, Stok FROM URUN WHERE UrunID = 99;






USE ETicaretProjesi_Son;
GO

-- Test verisi (Silinecek bir sipariþ ve ödeme yaratalým)
INSERT INTO SEPET (SepetID) VALUES (999);
INSERT INTO MUSTERI (MusteriID, Fname, Lname, Email, Telefon, Password) VALUES (999, 'Test', 'Musteri', 't@test.com', '000', '123');
INSERT INTO SIPARIS (SiparisID, SiparisTarihi, TopTutar, SepetID, MusteriID, SiparisDurumu) 
VALUES (999, GETDATE(), 500, 999, 999, 'Test');
INSERT INTO ODEME (OdemeID, OdemeTuru, OdemeDurumu, SiparisID) VALUES (999, 'Kart', 'Tamamlandý', 999);
GO

-- TRANSACTION BLOÐUNU ÇALIÞTIR
BEGIN TRY
    BEGIN TRANSACTION;
        DELETE FROM ODEME WHERE SiparisID = 999;
        DELETE FROM SIPARIS WHERE SiparisID = 999;
    COMMIT TRANSACTION;
    PRINT 'Sipariþ ve ödeme baþarýyla silindi (Transaction Baþarýlý).';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Bir hata oluþtu, veriler geri alýndý.';
END CATCH;





USE ETicaretProjesi_Son;
GO

-- 1. Önce bu ürüne baðlý olan test sipariþ detayýný silelim (FK hatasý almamak için)
DELETE FROM SIPARIS_DETAY WHERE UrunID = 99;

-- 2. Þimdi "Test Klavye" ürününü asýl tablodan silebiliriz
DELETE FROM URUN WHERE UrunID = 99;

-- 3. Eðer eklediyseniz, test satýcýsýný da silebilirsiniz
DELETE FROM SATICI WHERE SaticiID = 99;

PRINT 'Test verileri baþarýyla temizlendi.';

