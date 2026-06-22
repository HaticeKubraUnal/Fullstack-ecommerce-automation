USE ETicaretProjesi_Son;
GO

-- Daha önce Ahmet'i eklemediysek diye MusteriID 3 verelim (çakýþma olmasýn)
INSERT INTO MUSTERI (MusteriID, Fname, Lname, Email, Telefon, Password, Il, Ilce)
VALUES (3, 'Test', 'Kullanici', 'test@mail.com', '5550001122', '123456', 'Ankara', 'Cankaya');

-- Eklenip eklenmediðini kontrol etmek için:
SELECT * FROM MUSTERI WHERE Email = 'test@mail.com';
