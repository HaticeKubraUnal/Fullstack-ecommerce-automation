USE ETicaretProjesi_Son;
GO

-- Önce "Ekran Kartý" kategorisinin ID'sinin 1 olduðundan emin olalým (Genelde öyledir)
-- Deðilse, sorgudaki KategoriID kýsýmlarýný kendi tablona göre düzenleyebilirsin.

-- YENÝ ÜRÜNLERÝN EKLENMESÝ
INSERT INTO URUN (UrunID, UrunAdi, Fiyat, Stok, SaticiID, UrunFoto) VALUES 
(9, 'ASUS TUF Gaming RTX 4080 Super', 55000.00, 8, NULL, 'images/ASUSTUFgamingEkranKarti.jpg'),
(10, 'AMD Ryzen 7 7800X3D', 16500.00, 12, NULL, 'images/ryzen7.jpg'),
(11, 'MSI MAG B650 Tomahawk WiFi', 8900.00, 15, NULL, 'images/anakart-msi.jpg'),
(12, 'ASUS TUF Gaming VG27AQ Monitör', 11200.00, 10, NULL, 'images/monitor-asus.jpg'),
(13, 'Logitech G Pro X Superlight Mouse', 4800.00, 25, NULL, 'images/logitech-mouse.jpg'),
(14, 'MSI GeForce RTX 4060 Ti Ventus', 16500.00, 20, NULL, 'images/rtx4060.jpg'),
(15, 'AMD Ryzen 5 7600X Ýþlemci', 8200.00, 30, NULL, 'images/ryzen5.jpg'),
(16, 'Razer BlackWidow V4 Klavye', 6500.00, 15, NULL, 'images/razer-klavye.jpg'),
(17, 'ASUS ROG Strix B760-F Anakart', 9800.00, 12, NULL, 'images/anakart-asus.jpg');

-- ÜRÜNLERÝN KATEGORÝLERLE EÞLEÞTÝRÝLMESÝ (URUN_SINIFLANDIRMA)
-- KategoriID Tahminleri: 1: Ekran Kartý, 2: Ýþlemci, 3: Anakart, 4: Monitor, 5: Gaming Ekipman
INSERT INTO URUN_SINIFLANDIRMA (KategoriID, UrunID) VALUES 
(1, 9),  -- RTX 4080 (Ekran Kartý)
(2, 10), -- Ryzen 7 (Ýþlemci)
(3, 11), -- MSI B650 (Anakart)
(4, 12), -- ASUS Monitor (Monitor)
(5, 13), -- Logitech Mouse (Gaming Ekipman)
(1, 14), -- RTX 4060 (Ekran Kartý)
(2, 15), -- Ryzen 5 (Ýþlemci)
(5, 16), -- Razer Klavye (Gaming Ekipman)
(3, 17); -- ASUS Anakart (Anakart)
GO


UPDATE KATEGORI SET KategoriAdi = 'Ekran Kartý' WHERE KategoriID = 1;
UPDATE KATEGORI SET KategoriAdi = 'Monitor' WHERE KategoriID = 4;
GO


-- 1 Numaralý Ürün (Sadece RTX 4090 yazýyordu, markasýný ASUS olarak belirliyoruz)
UPDATE URUN SET UrunAdi = 'ASUS ROG Strix GeForce RTX 4090 Ekran Kartý' WHERE UrunID = 1;

-- 5 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'AMD Ryzen 9 7950X3D Ýþlemci' WHERE UrunID = 5;

-- 6 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'ASUS ROG Swift 360Hz Monitör' WHERE UrunID = 6;

-- 7 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'MSI MPG X670E Carbon WiFi Anakart' WHERE UrunID = 7;

-- 8 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'Razer DeathAdder V3 Pro Mouse' WHERE UrunID = 8;

-- 9 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'ASUS TUF Gaming RTX 4080 Super Ekran Kartý' WHERE UrunID = 9;

-- 10 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'AMD Ryzen 7 7800X3D Ýþlemci' WHERE UrunID = 10;

-- 11 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'MSI MAG B650 Tomahawk WiFi Anakart' WHERE UrunID = 11;

-- 12 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'ASUS TUF Gaming VG27AQ Monitör' WHERE UrunID = 12;

-- 13 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'Logitech G Pro X Superlight Mouse' WHERE UrunID = 13;

-- 14 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'MSI GeForce RTX 4060 Ti Ventus Ekran Kartý' WHERE UrunID = 14;

-- 15 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'AMD Ryzen 5 7600X Ýþlemci' WHERE UrunID = 15;

-- 16 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'Razer BlackWidow V4 Klavye' WHERE UrunID = 16;

-- 17 Numaralý Ürün
UPDATE URUN SET UrunAdi = 'ASUS ROG Strix B760-F Anakart' WHERE UrunID = 17;
GO