USE ETicaretProjesi_Son;
GO

SELECT * FROM MUSTERI;

-- 1. Müþterinin güncellenen adresini gör
SELECT * FROM MUSTERI WHERE Email = 'feyzademirel2@gmail.com';

-- 2. Yeni eklenen kart bilgisini gör
SELECT * FROM KART;

-- 3. Oluþan ödeme kaydýný gör
SELECT * FROM ODEME;

-- 4. Sistemin otomatik ürettiði kargo bilgisini gör
SELECT * FROM KARGO;

-- KART tablosundaki KartNo alanýnýn uzunluðunu ve içeriðini temizleyelim
DELETE FROM ODEME; -- Önce iliþkili kayýtlarý temizliyoruz
DELETE FROM KART;

-- 1. ADIM: Kategorileri Ekle (Eðer yoksa)
-- Not: KategoriID'ler otomatik artmýyorsa manuel veriyoruz.
INSERT INTO KATEGORI (KategoriID, KategoriAdi) VALUES (2, 'Ýþlemci');
INSERT INTO KATEGORI (KategoriID, KategoriAdi) VALUES (3, 'Anakart');
INSERT INTO KATEGORI (KategoriID, KategoriAdi) VALUES (4, 'Monitor');
INSERT INTO KATEGORI (KategoriID, KategoriAdi) VALUES (5, 'Gaming Ekipman');
GO

-- 2. ADIM: Farklý Kategorilerden Ürünleri Ekle
-- MusteriID'de yaptýðýmýz gibi UrunID'leri manuel takip ediyoruz (5, 6, 7, 8...)
INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID) 
VALUES (5, 'AMD Ryzen 9 7950X3D', 22500.00, 15, NULL);

INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID) 
VALUES (6, 'ASUS ROG Swift 360Hz', 18900.00, 10, NULL);

INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID) 
VALUES (7, 'MSI MPG X670E Carbon WiFi', 14200.00, 20, NULL);

INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID) 
VALUES (8, 'Razer DeathAdder V3 Pro', 4500.00, 50, NULL);
GO

-- 3. ADIM: Ürünleri Kategorilerle Eþleþtir (URUN_SINIFLANDIRMA)
-- Ryzen 9 -> Ýþlemci (KategoriID: 2)
INSERT INTO URUN_SINIFLANDIRMA (KategoriID, UrunID) VALUES (2, 5);

-- ASUS Monitor -> Monitor (KategoriID: 4)
INSERT INTO URUN_SINIFLANDIRMA (KategoriID, UrunID) VALUES (4, 6);

-- MSI Anakart -> Anakart (KategoriID: 3)
INSERT INTO URUN_SINIFLANDIRMA (KategoriID, UrunID) VALUES (3, 7);

-- Razer Mouse -> Gaming Ekipman (KategoriID: 5)
INSERT INTO URUN_SINIFLANDIRMA (KategoriID, UrunID) VALUES (5, 8);
GO

SELECT * FROM URUN;
SELECT * FROM KATEGORI;
SELECT * FROM URUN_SINIFLANDIRMA;

-- 2 numaralý hatalý kategoriyi düzelt
UPDATE KATEGORI SET KategoriAdi = 'Ýþlemci' WHERE KategoriID = 2;

-- Tablolarý kontrol et
SELECT * FROM KATEGORI;

-- Eðer sütun daha önce eklenmediyse ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('YORUM') AND name = 'UrunID')
BEGIN
    ALTER TABLE YORUM ADD UrunID int;
END
GO

-- Kategori ismini düzelt
UPDATE KATEGORI SET KategoriAdi = 'Ýþlemci' WHERE KategoriID = 2;
GO

-- Ürün tablosuna resim yolu sütunu ekle
ALTER TABLE URUN ADD UrunFoto varchar(255);
GO

-- Kontrol etmek için listele
SELECT UrunID, UrunAdi, UrunFoto FROM URUN WHERE UrunID = 5;

USE ETicaretProjesi_Son;
GO

-- 1. ASUS ROG Strix GeForce RTX 4090 Ekran Kartý
UPDATE URUN SET UrunFoto = 'images/ASUSROGEkranKarti.jpg' WHERE UrunID = 1;

-- 5. AMD Ryzen 9 7950X3D Ýþlemci
UPDATE URUN SET UrunFoto = 'images/AMDRyzen9.jpg' WHERE UrunID = 5;

-- 6. ASUS ROG Swift 360Hz Monitör
UPDATE URUN SET UrunFoto = 'images/ASUSMonitor.jpg' WHERE UrunID = 6;

-- 7. MSI MPG X670E Carbon WiFi Anakart
UPDATE URUN SET UrunFoto = 'images/MSIAnakart.jpeg' WHERE UrunID = 7;

-- 8. Razer DeathAdder V3 Pro Mouse
UPDATE URUN SET UrunFoto = 'images/RazerMouse.jpg' WHERE UrunID = 8;

-- 9. ASUS TUF Gaming RTX 4080 Super Ekran Kartý
UPDATE URUN SET UrunFoto = 'images/ASUSTUFgamingEkranKarti.jpg' WHERE UrunID = 9;

-- 10. AMD Ryzen 7 7800X3D Ýþlemci
UPDATE URUN SET UrunFoto = 'images/AMDRyzen7.jpeg' WHERE UrunID = 10;

-- 11. MSI MAG B650 Tomahawk WiFi Anakart
UPDATE URUN SET UrunFoto = 'images/MSImagB659Anakart.jpg' WHERE UrunID = 11;

-- 12. ASUS TUF Gaming VG27AQ Monitör
UPDATE URUN SET UrunFoto = 'images/ASUSTUFgamingMonitor.jpg' WHERE UrunID = 12;

-- 13. Logitech G Pro X Superlight Mouse
UPDATE URUN SET UrunFoto = 'images/LogitechMouse.jpg' WHERE UrunID = 13;

-- 14. MSI GeForce RTX 4060 Ti Ventus Ekran Kartý
UPDATE URUN SET UrunFoto = 'images/MSIGeForceEkranKarti.jpg' WHERE UrunID = 14;

-- 15. AMD Ryzen 5 7600X Ýþlemci
UPDATE URUN SET UrunFoto = 'images/AMDRyzen5.jpg' WHERE UrunID = 15;

-- 16. Razer BlackWidow V4 Klavye
UPDATE URUN SET UrunFoto = 'images/RazerKlavye.webp' WHERE UrunID = 16;

-- 17. ASUS ROG Strix B760-F Anakart
UPDATE URUN SET UrunFoto = 'images/ROGStrixAnakart.jpeg' WHERE UrunID = 17;
GO


UPDATE URUN SET Fiyat = 999999.00 WHERE UrunID = 1;
UPDATE URUN SET Fiyat = 8.00 WHERE UrunID = 8;
UPDATE URUN SET Fiyat = 2.50 WHERE UrunID = 6;
GO


-- Sipariþin hangi müþteriye ait olduðunu bilmek için MusteriID sütununu ekliyoruz
ALTER TABLE SIPARIS ADD MusteriID int;
GO

-- Sipariþ Durumu ve Kargo Kodu sütunlarýný ekliyoruz
ALTER TABLE SIPARIS ADD SiparisDurumu varchar(50);
ALTER TABLE SIPARIS ADD KargoTakipKodu varchar(50);
GO

-- Eski sipariþler boþ kalmasýn diye varsayýlan deðer atýyoruz
UPDATE SIPARIS 
SET SiparisDurumu = 'Hazýrlanýyor', 
    KargoTakipKodu = 'TR-' + CAST(CAST(RAND() * 1000000 AS INT) AS VARCHAR) 
WHERE SiparisDurumu IS NULL;
GO

USE ETicaretProjesi_Son;
GO

ALTER TABLE SEPET ADD MusteriID int;
ALTER TABLE SEPET ADD UrunID int;
ALTER TABLE SEPET ADD Adet int;
GO

USE ETicaretProjesi_Son;
GO

-- 1. TEST: SÝPARÝÞLER TABLOSU
-- En son verdiðin sipariþin sisteme düþüp düþmediðini, kargo kodunu ve durumunu kontrol edelim.
SELECT * FROM SIPARIS ORDER BY SiparisTarihi DESC;

-- 2. TEST: SÝPARÝÞ DETAYLARI
-- Verdiðin sipariþin içindeki ürünlerin adetleri ve fiyatlarý doðru iþlenmiþ mi bakalým.
SELECT * FROM SIPARIS_DETAY ORDER BY SiparisDetayID DESC;

-- 3. TEST: SEPET TEMÝZLÝÐÝ
-- Sipariþi tamamladýktan sonra sepetin veritabanýndan gerçekten silinip silinmediðine bakalým. (Tablonun boþ gelmesi, iþlemin baþarýlý olduðunu gösterir)
SELECT * FROM SEPET;