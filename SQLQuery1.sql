-- 1. VERÝTABANINI OLUÞTURMA VE SEÇME
CREATE DATABASE ETicaretProjesi;
GO

USE ETicaretProjesi;
GO

-- 2. BAÐIMSIZ TABLOLARI OLUÞTURMA (Önce bunlar çalýþmalý)
CREATE TABLE IL (
    IlID INT PRIMARY KEY,
    IlAdi VARCHAR(50) NOT NULL
);

CREATE TABLE SEPET (
    SepetID INT PRIMARY KEY
);

CREATE TABLE KATEGORI (
    KategoriID INT PRIMARY KEY,
    KategoriAdi VARCHAR(100) NOT NULL
);

CREATE TABLE SATICI (
    SaticiID INT PRIMARY KEY,
    MagazaAdi VARCHAR(100) NOT NULL,
    Gmail VARCHAR(100) UNIQUE NOT NULL,
    Telefon VARCHAR(15) UNIQUE NOT NULL,
    VergiNo VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE KARGO (
    KargoID INT PRIMARY KEY,
    TahminiTeslim DATE,
    TakipKodu VARCHAR(50) UNIQUE,
    Durumu VARCHAR(50),
    GonderimTarihi DATE
);

-- 3. BAÐIMLI TABLOLARI OLUÞTURMA (Foreign Key içerenler)
CREATE TABLE ILCE (
    IlceID INT PRIMARY KEY,
    IlceAdi VARCHAR(50) NOT NULL,
    IlID INT,
    FOREIGN KEY (IlID) REFERENCES IL(IlID)
);

CREATE TABLE URUN (
    UrunID INT PRIMARY KEY,
    UrunAdi VARCHAR(100) NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL,
    Stok INT NOT NULL,
    SaticiID INT,
    FOREIGN KEY (SaticiID) REFERENCES SATICI(SaticiID)
);

CREATE TABLE MUSTERI (
    MusteriID INT PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    Gmail VARCHAR(100) UNIQUE NOT NULL,
    Telefon VARCHAR(15) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Mahalle VARCHAR(100),
    Sokak VARCHAR(100),
    IlceID INT,
    FOREIGN KEY (IlceID) REFERENCES ILCE(IlceID)
);

CREATE TABLE SIPARIS (
    SiparisID INT PRIMARY KEY,
    SiparisTarihi DATETIME,
    TopTutar DECIMAL(10,2),
    SepetID INT,
    FOREIGN KEY (SepetID) REFERENCES SEPET(SepetID)
);

CREATE TABLE SIPARIS_DETAY (
    SiparisDetayID INT PRIMARY KEY,
    Adet INT NOT NULL,
    BirimFiyat DECIMAL(10,2) NOT NULL,
    SiparisID INT,
    UrunID INT,
    KargoID INT,
    FOREIGN KEY (SiparisID) REFERENCES SIPARIS(SiparisID),
    FOREIGN KEY (UrunID) REFERENCES URUN(UrunID),
    FOREIGN KEY (KargoID) REFERENCES KARGO(KargoID)
);

CREATE TABLE YORUM (
    YorumID INT PRIMARY KEY,
    Puan INT CHECK (Puan >= 1 AND Puan <= 5),
    YorumMetni TEXT,
    Tarih DATETIME,
    MusteriID INT,
    SiparisDetayID INT,
    FOREIGN KEY (MusteriID) REFERENCES MUSTERI(MusteriID),
    FOREIGN KEY (SiparisDetayID) REFERENCES SIPARIS_DETAY(SiparisDetayID)
);

CREATE TABLE ODEME (
    OdemeID INT PRIMARY KEY,
    OdemeTuru VARCHAR(50) NOT NULL,
    OdemeTarihi DATETIME,
    OdemeDurumu VARCHAR(50) NOT NULL,
    KartNo VARCHAR(16),
    SonKullanma VARCHAR(5),
    CVV VARCHAR(3),
    SiparisID INT,
    FOREIGN KEY (SiparisID) REFERENCES SIPARIS(SiparisID)
);

-- 4. ÇOKA ÇOK (N:M) ÝLÝÞKÝ TABLOLARI
CREATE TABLE SIPARIS_KARGOSU (
    SiparisID INT,
    KargoID INT,
    PRIMARY KEY (SiparisID, KargoID),
    FOREIGN KEY (SiparisID) REFERENCES SIPARIS(SiparisID),
    FOREIGN KEY (KargoID) REFERENCES KARGO(KargoID)
);

CREATE TABLE URUN_SINIFLANDIRMA (
    KategoriID INT,
    UrunID INT,
    PRIMARY KEY (KategoriID, UrunID),
    FOREIGN KEY (KategoriID) REFERENCES KATEGORI(KategoriID),
    FOREIGN KEY (UrunID) REFERENCES URUN(UrunID)
);

CREATE TABLE SATIN_ALMA (
    MusteriID INT,
    SepetID INT,
    UrunID INT,
    PRIMARY KEY (MusteriID, SepetID, UrunID),
    FOREIGN KEY (MusteriID) REFERENCES MUSTERI(MusteriID),
    FOREIGN KEY (SepetID) REFERENCES SEPET(SepetID),
    FOREIGN KEY (UrunID) REFERENCES URUN(UrunID)
);

CREATE VIEW View_MusteriAdresBilgileri AS
SELECT 
    M.Fname AS Ad, 
    M.Lname AS Soyad, 
    M.Gmail, 
    I.IlceAdi, 
    IL.IlAdi
FROM MUSTERI M
INNER JOIN ILCE I ON M.IlceID = I.IlceID
INNER JOIN IL IL ON I.IlID = IL.IlID;

CREATE PROCEDURE sp_YeniKategoriEkle
    @p_KategoriID INT,
    @p_KategoriAdi VARCHAR(100)
AS
BEGIN
    INSERT INTO KATEGORI (KategoriID, KategoriAdi)
    VALUES (@p_KategoriID, @p_KategoriAdi);
    
    PRINT 'Yeni kategori baþarýyla eklendi.';
END;

CREATE TRIGGER trg_StokDusur
ON SIPARIS_DETAY
AFTER INSERT
AS
BEGIN
    -- Eklenen sipariþ detayýndaki ürünün IDsini ve adetini alýp stoðu güncelliyoruz
    UPDATE URUN
    SET Stok = Stok - i.Adet
    FROM URUN u
    INNER JOIN inserted i ON u.UrunID = i.UrunID;
END;

BEGIN TRY
    BEGIN TRANSACTION;
        -- Önce alt tablo olan Ödeme kaydýný siliyoruz (Örnek SipariþID: 1)
        DELETE FROM ODEME WHERE SiparisID = 1;
        
        -- Sonra üst tablo olan Sipariþ kaydýný siliyoruz
        DELETE FROM SIPARIS WHERE SiparisID = 1;
        
    -- Ýkisi de baþarýlý olursa iþlemleri kalýcý yap:
    COMMIT TRANSACTION;
    PRINT 'Sipariþ ve ödeme baþarýyla silindi.';
END TRY
BEGIN CATCH
    -- Eðer yukarýdaki iþlemlerin herhangi birinde hata çýkarsa, her þeyi geri al:
    ROLLBACK TRANSACTION;
    PRINT 'Bir hata oluþtu, iþlem iptal edildi.';
END CATCH;

-- Örnek veriler ekleyelim
INSERT INTO IL (IlID, IlAdi) VALUES (34, 'Ýstanbul'), (6, 'Ankara');
INSERT INTO ILCE (IlceID, IlceAdi, IlID) VALUES (1, 'Beþiktaþ', 34), (2, 'Çankaya', 6);
INSERT INTO KATEGORI (KategoriID, KategoriAdi) VALUES (1, 'Teknoloji'), (2, 'Moda');

-- Þimdi bu verileri tablo halinde görelim
SELECT * FROM IL;
SELECT * FROM ILCE;
SELECT * FROM KATEGORI;