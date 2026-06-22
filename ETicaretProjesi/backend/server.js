const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Resimlerin dışarıya açılması
app.use('/images', express.static('frontend/images'));

// Veritabanı Bağlantı Ayarları
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER, 
    database: process.env.DB_DATABASE,
    port: 1433,
    options: { encrypt: false, trustServerCertificate: true }
};

const poolPromise = new sql.ConnectionPool(dbConfig).connect().then(pool => {
    console.log('MSSQL Bağlantısı Başarılı!');
    return pool;
}).catch(err => { 
    console.log('Hata: ', err); process.exit(1); 
});

// ==========================================
// KULLANICI İŞLEMLERİ
// ==========================================
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('email', sql.VarChar, email)
            .input('password', sql.VarChar, password)
            .query('SELECT * FROM MUSTERI WHERE Email = @email AND Password = @password');

        if (result.recordset.length > 0) res.json({ success: true, user: result.recordset[0] });
        else res.status(401).json({ success: false, message: 'Hatalı e-posta veya şifre' });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

app.post('/api/register', async (req, res) => {
    const { fname, lname, email, telefon, password } = req.body;
    try {
        const pool = await poolPromise;
        let mId = await pool.request().query('SELECT ISNULL(MAX(MusteriID), 0) + 1 as maxId FROM MUSTERI');
        await pool.request()
            .input('id', sql.Int, mId.recordset[0].maxId)
            .input('fname', sql.VarChar, fname)
            .input('lname', sql.VarChar, lname)
            .input('email', sql.VarChar, email)
            .input('telefon', sql.VarChar, telefon)
            .input('pass', sql.VarChar, password)
            .query('INSERT INTO MUSTERI (MusteriID, Fname, Lname, Email, Telefon, Password) VALUES (@id, @fname, @lname, @email, @telefon, @pass)');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// ==========================================
// ÜRÜN İŞLEMLERİ
// ==========================================
app.get('/api/products', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query(`
            SELECT u.*, k.KategoriAdi 
            FROM URUN u
            LEFT JOIN URUN_SINIFLANDIRMA us ON u.UrunID = us.UrunID
            LEFT JOIN KATEGORI k ON us.KategoriID = k.KategoriID
        `);
        res.json(result.recordset);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

app.get('/api/products/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, req.params.id)
            .query(`
                SELECT u.*, k.KategoriAdi 
                FROM URUN u
                LEFT JOIN URUN_SINIFLANDIRMA us ON u.UrunID = us.UrunID
                LEFT JOIN KATEGORI k ON us.KategoriID = k.KategoriID
                WHERE u.UrunID = @id
            `);
        res.json(result.recordset[0]);
    } catch (err) { res.status(500).send(err.message); }
});

// ==========================================
// YORUM İŞLEMLERİ
// ==========================================
app.get('/api/products/:id/comments', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().input('id', sql.Int, req.params.id)
            .query('SELECT y.*, m.Fname, m.Lname FROM YORUM y JOIN MUSTERI m ON y.MusteriID = m.MusteriID WHERE y.UrunID = @id ORDER BY y.Tarih DESC');
        res.json(result.recordset);
    } catch (err) { res.status(500).send(err.message); }
});

app.post('/api/add-comment', async (req, res) => {
    const { musteriId, urunId, puan, metin } = req.body;
    try {
        const pool = await poolPromise;
        let yId = await pool.request().query('SELECT ISNULL(MAX(YorumID), 0) + 1 as maxId FROM YORUM');
        await pool.request()
            .input('id', sql.Int, yId.recordset[0].maxId)
            .input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId).input('puan', sql.Int, puan).input('txt', sql.Text, metin)
            .query('INSERT INTO YORUM (YorumID, Puan, YorumMetni, Tarih, MusteriID, UrunID) VALUES (@id, @puan, @txt, GETDATE(), @mid, @uid)');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

app.delete('/api/comments/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        await pool.request().input('id', sql.Int, req.params.id).input('mid', sql.Int, req.body.musteriId)
            .query('DELETE FROM YORUM WHERE YorumID = @id AND MusteriID = @mid');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

app.put('/api/comments/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        await pool.request().input('id', sql.Int, req.params.id).input('mid', sql.Int, req.body.musteriId).input('puan', sql.Int, req.body.puan).input('txt', sql.Text, req.body.metin)
            .query('UPDATE YORUM SET Puan = @puan, YorumMetni = @txt, Tarih = GETDATE() WHERE YorumID = @id AND MusteriID = @mid');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

// ==========================================
// SEPET İŞLEMLERİ (VERİTABANI BAĞLANTILI)
// ==========================================

// Sepetten Ürün Adedini Azalt
app.post('/api/cart/decrease', async (req, res) => {
    const { musteriId, urunId } = req.body;
    try {
        const pool = await poolPromise;
        const check = await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
            .query('SELECT Adet FROM SEPET WHERE MusteriID = @mid AND UrunID = @uid');

        if (check.recordset.length > 0) {
            if (check.recordset[0].Adet > 1) {
                // Adet 1'den büyükse 1 azalt
                await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
                    .query('UPDATE SEPET SET Adet = Adet - 1 WHERE MusteriID = @mid AND UrunID = @uid');
            } else {
                // Adet 1 ise ürünü tamamen sil
                await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
                    .query('DELETE FROM SEPET WHERE MusteriID = @mid AND UrunID = @uid');
            }
        }
        res.json({ success: true });
    } catch(err) { res.status(500).json({ success: false }); }
});

app.get('/api/cart/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().input('mid', sql.Int, req.params.id).query(`
            SELECT s.SepetID, s.Adet, u.UrunID as id, u.UrunAdi as ad, u.UrunFoto as foto, u.Fiyat as fiyat
            FROM SEPET s JOIN URUN u ON s.UrunID = u.UrunID WHERE s.MusteriID = @mid
        `);
        res.json(result.recordset);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

app.post('/api/cart/add', async (req, res) => {
    const { musteriId, urunId } = req.body;
    try {
        const pool = await poolPromise;
        const check = await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
            .query('SELECT * FROM SEPET WHERE MusteriID = @mid AND UrunID = @uid');

        if(check.recordset.length > 0) {
            await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
                .query('UPDATE SEPET SET Adet = Adet + 1 WHERE MusteriID = @mid AND UrunID = @uid');
        } else {
            let sIdRes = await pool.request().query('SELECT ISNULL(MAX(SepetID), 0) + 1 as maxId FROM SEPET');
            await pool.request()
                .input('id', sql.Int, sIdRes.recordset[0].maxId).input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId).input('adet', sql.Int, 1)
                .query('INSERT INTO SEPET (SepetID, MusteriID, UrunID, Adet) VALUES (@id, @mid, @uid, @adet)');
        }
        res.json({ success: true });
    } catch(err) { res.status(500).json({ success: false, message: err.message }); }
});

app.post('/api/cart/remove', async (req, res) => {
    const { musteriId, urunId } = req.body;
    try {
        const pool = await poolPromise;
        await pool.request().input('mid', sql.Int, musteriId).input('uid', sql.Int, urunId)
            .query('DELETE FROM SEPET WHERE MusteriID = @mid AND UrunID = @uid');
        res.json({ success: true });
    } catch(err) { res.status(500).json({ success: false }); }
});

// ==========================================
// SİPARİŞ VE PROFİL İŞLEMLERİ
// ==========================================
app.post('/api/checkout', async (req, res) => {
    const { musteriId, sepet, kartNo, sonKullanma, cvv } = req.body;
    try {
        const pool = await poolPromise;
        let topTutar = sepet.reduce((total, urun) => total + (urun.fiyat * urun.adet), 0);

        let sIdRes = await pool.request().query('SELECT ISNULL(MAX(SiparisID), 0) + 1 as maxId FROM SIPARIS');
        let siparisId = sIdRes.recordset[0].maxId;

        let takipKodu = 'TR-' + Math.floor(100000 + Math.random() * 900000);
        let durum = 'Hazırlanıyor';

        // 🌟 YENİ: KART NUMARASINI MASKELEME (İlk 12 haneyi yıldıza çeviriyoruz)
        let maskeliKartNo = kartNo;
        if (kartNo && kartNo.length >= 4) {
            maskeliKartNo = "************" + kartNo.slice(-4);
        }

        // KART BİLGİSİNİ EKLERKEN 'maskeliKartNo' KULLANIYORUZ
        if (maskeliKartNo && sonKullanma && cvv) {
            await pool.request()
                .input('kno', sql.VarChar, maskeliKartNo)
                .input('sk', sql.VarChar, sonKullanma)
                .input('cvv', sql.VarChar, cvv)
                .query(`
                    IF NOT EXISTS (SELECT 1 FROM KART WHERE KartNo = @kno)
                    BEGIN
                        INSERT INTO KART (KartNo, SonKullanma, CVV) VALUES (@kno, @sk, @cvv)
                    END
                `);
        }

        // Ana Siparişi Ekle
        await pool.request()
            .input('sid', sql.Int, siparisId)
            .input('tarih', sql.DateTime, new Date())
            .input('tutar', sql.Decimal(10,2), topTutar)
            .input('mid', sql.Int, musteriId)
            .input('durum', sql.VarChar, durum)
            .input('kargo', sql.VarChar, takipKodu)
            .query('INSERT INTO SIPARIS (SiparisID, SiparisTarihi, TopTutar, MusteriID, SiparisDurumu, KargoTakipKodu) VALUES (@sid, @tarih, @tutar, @mid, @durum, @kargo)');

        let sdIdRes = await pool.request().query('SELECT ISNULL(MAX(SiparisDetayID), 0) as maxId FROM SIPARIS_DETAY');
        let siparisDetayId = sdIdRes.recordset[0].maxId;

        for (let urun of sepet) {
            siparisDetayId++;
            // Sipariş Detayını Ekle
            await pool.request()
                .input('sdid', sql.Int, siparisDetayId)
                .input('adet', sql.Int, urun.adet)
                .input('fiyat', sql.Decimal(10,2), urun.fiyat)
                .input('sid', sql.Int, siparisId)
                .input('uid', sql.Int, urun.id)
                .query('INSERT INTO SIPARIS_DETAY (SiparisDetayID, Adet, BirimFiyat, SiparisID, UrunID) VALUES (@sdid, @adet, @fiyat, @sid, @uid)');

            // Stoğu Düşür
            await pool.request()
                .input('uid', sql.Int, urun.id)
                .input('adet', sql.Int, urun.adet)
                .query('UPDATE URUN SET Stok = Stok - @adet WHERE UrunID = @uid');
        }

        // ÖDEME TABLOSUNA DA 'maskeliKartNo' EKLİYORUZ
        if (maskeliKartNo) {
            let oIdRes = await pool.request().query('SELECT ISNULL(MAX(OdemeID), 0) + 1 as maxId FROM ODEME');
            let odemeId = oIdRes.recordset[0].maxId;

            await pool.request()
                .input('oid', sql.Int, odemeId)
                .input('tur', sql.VarChar, 'Kredi Kartı')
                .input('durum', sql.VarChar, 'Başarılı')
                .input('kno', sql.VarChar, maskeliKartNo)
                .input('sid', sql.Int, siparisId)
                .query('INSERT INTO ODEME (OdemeID, OdemeTuru, OdemeTarihi, OdemeDurumu, KartNo, SiparisID) VALUES (@oid, @tur, GETDATE(), @durum, @kno, @sid)');
        }

        // İŞLEM BİTTİ: Sepeti temizle
        await pool.request().input('mid', sql.Int, musteriId).query('DELETE FROM SEPET WHERE MusteriID = @mid');

        res.json({ 
            success: true, 
            message: 'Sipariş başarıyla oluşturuldu.',
            kargo: { 
                durumu: durum, 
                takipKodu: takipKodu, 
                tahminiTeslim: "3-5 İş Günü İçerisinde" 
            }
        });

    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

app.get('/api/user/:id/orders', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().input('mid', sql.Int, req.params.id).query(`
            SELECT s.SiparisID, s.SiparisTarihi as Tarih, s.SiparisDurumu, s.KargoTakipKodu, 
                   u.UrunID, u.UrunAdi, u.UrunFoto, sd.BirimFiyat as Fiyat, sd.Adet
            FROM SIPARIS s JOIN SIPARIS_DETAY sd ON s.SiparisID = sd.SiparisID JOIN URUN u ON sd.UrunID = u.UrunID
            WHERE s.MusteriID = @mid ORDER BY s.SiparisTarihi DESC
        `);
        res.json(result.recordset);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

app.get('/api/user/:id/comments', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().input('mid', sql.Int, req.params.id)
            .query('SELECT y.YorumID, y.Puan, y.YorumMetni, y.Tarih, u.UrunID, u.UrunAdi, u.UrunFoto FROM YORUM y JOIN URUN u ON y.UrunID = u.UrunID WHERE y.MusteriID = @mid ORDER BY y.Tarih DESC');
        res.json(result.recordset);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

// Sunucuyu Başlat
app.listen(5000, () => {
    console.log("Sunucu 5000 portunda çalışıyor...");
});