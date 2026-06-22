-- 1. VERÝTABANINI OLUÞTURMA VE SEÇME
USE ETicaretProjesi_Son;
GO

-- 2. BAÐIMSIZ TABLOLARI OLUÞTURMA (Önce bunlar çalýþmalý)
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
    Email VARCHAR(100) UNIQUE NOT NULL,
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

CREATE TABLE KART (
    KartNo VARCHAR(16) PRIMARY KEY,
    SonKullanma VARCHAR(5) NOT NULL,
    CVV VARCHAR(3) NOT NULL
);

-- 3. BAÐIMLI TABLOLARI OLUÞTURMA (Foreign Key içerenler)
CREATE TABLE MUSTERI (
    MusteriID INT PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefon VARCHAR(15) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Mahalle VARCHAR(100),
    Sokak VARCHAR(100),
    Il VARCHAR(50),
    Ilce VARCHAR(50)
);

CREATE TABLE URUN (
    UrunID INT PRIMARY KEY,
    UrunAdi VARCHAR(100) NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL,
    Stok INT NOT NULL,
    SaticiID INT,
    FOREIGN KEY (SaticiID) REFERENCES SATICI(SaticiID)
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
    SiparisID INT,
    FOREIGN KEY (KartNo) REFERENCES KART(KartNo),
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

CREATE VIEW View_UrunKategori AS
SELECT 
    U.UrunAdi, 
    U.Fiyat, 
    K.KategoriAdi
FROM URUN U
INNER JOIN URUN_SINIFLANDIRMA US ON U.UrunID = US.UrunID
INNER JOIN KATEGORI K ON US.KategoriID = K.KategoriID;


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

-- 1. Önce baðýmsýz tablolara (Yeni KART tablosu dahil) örnek veri ekleyelim
INSERT INTO KART (KartNo, SonKullanma, CVV) 
VALUES 
('1111222233334444', '12/28', '123'), 
('5555666677778888', '10/26', '456');

INSERT INTO KATEGORI (KategoriID, KategoriAdi) 
VALUES 
(1, 'Teknoloji'), 
(2, 'Giyim');

-- 2. Sonra Müþteri tablomuza (Ýl ve Ýlçe artýk burada) veri ekleyelim
INSERT INTO MUSTERI (MusteriID, Fname, Lname, Email, Telefon, Password, Mahalle, Sokak, Il, Ilce) 
VALUES 
(1, 'Ahmet', 'Yýlmaz', 'ahmet@mail.com', '5551112233', 'sifre123', 'Atatürk Mah.', 'Gül Sok.', 'Ýstanbul', 'Beþiktaþ'), 
(2, 'Ayþe', 'Kaya', 'ayse@mail.com', '5559998877', 'sifre456', 'Cumhuriyet Mah.', 'Lale Sok.', 'Ankara', 'Çankaya');

-- 3. Þimdi eklediðimiz bu verileri tablo halinde görelim
SELECT * FROM KART;
SELECT * FROM MUSTERI;
SELECT * FROM KATEGORI;

USE ETicaretProjesi_Son;
GO

INSERT INTO SATICI (SaticiID, MagazaAdi, Email, Telefon, VergiNo)
VALUES (1, 'Teknoloji Maðazasý', 'iletisim@magaza.com', '02120001122', '9876543210');

INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID) 
VALUES (1, 'RTX 4090 Ekran Kartý', 85000, 10, 1);





