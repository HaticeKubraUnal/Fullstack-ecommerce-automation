document.addEventListener('DOMContentLoaded', () => {
    const productGrid = document.getElementById('product-grid');
    const userAction = document.querySelector('.action-item i.fa-user')?.parentElement;
    const currentUser = localStorage.getItem('user');
    
    let allProducts = []; // Veritabanından gelen tüm ürünler burada duracak

    // --- MODERN BİLDİRİM (TOAST) FONKSİYONU ---
    window.showToast = function(message, type = 'success') {
        let container = document.getElementById('toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toast-container';
            document.body.appendChild(container);
        }

        const toast = document.createElement('div');
        toast.className = `toast-msg ${type}`;
        
        const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
        toast.innerHTML = `<i class="fas ${icon}"></i> <span>${message}</span>`;
        
        container.appendChild(toast);

        // 3 saniye sonra kaybolma animasyonunu başlat
        setTimeout(() => {
            toast.style.animation = 'slideOut 0.4s forwards';
            setTimeout(() => { toast.remove(); }, 400); // DOM'dan temizle
        }, 3000);
    }

    // 1. ÜST BAR KULLANICI KONTROLÜ
    if (userAction) {
        if (currentUser) {
            const user = JSON.parse(currentUser);
            userAction.innerHTML = `
                <div style="display:flex; align-items:center;">
                    <div onclick="window.location.href='profile.html'" style="cursor:pointer; display:flex; align-items:center; gap:8px; transition:0.3s;" onmouseover="this.style.color='#2ecc71'" onmouseout="this.style.color='white'">
                        <i class="fas fa-user"></i> <span style="font-weight:bold;">${user.Fname}</span>
                    </div>
                    <i class="fas fa-sign-out-alt" id="logout-btn" style="margin-left:15px; color:#e74c3c; cursor:pointer; font-size:18px;" title="Çıkış Yap"></i>
                </div>
            `;
            document.getElementById('logout-btn').onclick = (e) => { 
                e.stopPropagation();
                localStorage.clear(); 
                window.location.reload(); 
            };
        } else {
            userAction.onclick = () => window.location.href = 'login.html';
        }
    }

    // 2. SEPET SAYACINI GÜNCELLEME (VERİTABANINDAN ÇEKİYORUZ)
    window.updateCartBadge = async function() {
        const cartBadge = document.getElementById('cart-count');
        if (!cartBadge || !currentUser) return;
        
        try {
            const user = JSON.parse(currentUser);
            const res = await fetch(`http://localhost:5000/api/cart/${user.MusteriID}`);
            const sepet = await res.json();
            // Sepetteki toplam ürün adedini hesapla ve rozete yaz
            cartBadge.innerText = sepet.reduce((toplam, urun) => toplam + urun.Adet, 0);
        } catch (error) { 
            console.error("Sepet sayısı alınamadı."); 
        }
    }
    updateCartBadge();

    // 3. ÜRÜNLERİ API'DEN GETİR
    async function fetchProducts() {
        if (!productGrid) return; // Sayfa ürünlerin listelendiği sayfa değilse çalışma
        try {
            const response = await fetch('http://localhost:5000/api/products');
            allProducts = await response.json();
            renderProducts(allProducts); 
        } catch (error) {
            productGrid.innerHTML = '<p style="grid-column: 1/-1; text-align:center;">Sunucu bağlantı hatası! Lütfen daha sonra tekrar deneyin.</p>';
        }
    }

    // 4. EKRANA YAZDIRMA FONKSİYONU
    function renderProducts(products) {
        if (!productGrid) return;

        // EĞER ÜRÜN YOKSA:
        if (products.length === 0) {
            productGrid.innerHTML = `
                <div style="grid-column: 1/-1; text-align:center; padding: 50px; background:#1a1a1a; border-radius:10px; border:1px solid #333;">
                    <i class="fas fa-box-open" style="font-size: 50px; color: #555; margin-bottom: 15px;"></i>
                    <h2 style="color: #888;">Ürün bulunamadı!</h2>
                    <p style="color: #666;">Arama kriterlerinize veya seçtiğiniz filtrelere uygun ürün stoklarımızda mevcut değil.</p>
                </div>
            `;
            return;
        }

        productGrid.innerHTML = products.map(product => `
            <div class="product-card">
                <div class="product-image" onclick="window.location.href='product-detail.html?id=${product.UrunID}'" style="cursor:pointer">
                    <img src="${product.UrunFoto ? product.UrunFoto : 'https://via.placeholder.com/250'}" alt="${product.UrunAdi}">
                </div>
                <div class="product-info">
                    <h3 onclick="window.location.href='product-detail.html?id=${product.UrunID}'" style="cursor:pointer">${product.UrunAdi}</h3>
                    <div class="price-container">
                        <span class="current-price">${product.Fiyat.toLocaleString('tr-TR')} ₺</span>
                    </div>
                    <button class="add-to-cart-btn" 
                        data-id="${product.UrunID}" 
                        data-name="${product.UrunAdi}" 
                        data-price="${product.Fiyat}">
                        <i class="fas fa-shopping-cart"></i> SEPETE EKLE
                    </button>
                </div>
            </div>
        `).join('');
    }

    // 5. YAN MENÜ FİLTRELEME SİSTEMİ (Senin Tasarımın)
    function applyFilters() {
        const searchInput = document.getElementById('search-input');
        
        if(searchInput && searchInput.value !== "") {
            searchInput.value = "";
        }

        const selectedCats = Array.from(document.querySelectorAll('.cat-filter:checked')).map(cb => cb.value.toLowerCase());
        const selectedBrands = Array.from(document.querySelectorAll('.brand-filter:checked')).map(cb => cb.value.toLowerCase());

        const filtered = allProducts.filter(p => {
            const urunAdi = (p.UrunAdi || "").toLowerCase();
            const kategoriAdi = (p.KategoriAdi || "").toLowerCase();

            let catMatch = selectedCats.length === 0;
            if (!catMatch) {
                catMatch = selectedCats.some(cat => {
                    const normCat = cat.replace('ö', 'o'); 
                    return kategoriAdi.includes(cat) || 
                           kategoriAdi.includes(normCat) || 
                           (cat === 'ekran kartı' && urunAdi.includes('rtx')); 
                });
            }

            let brandMatch = selectedBrands.length === 0;
            if (!brandMatch) {
                brandMatch = selectedBrands.some(brand => urunAdi.includes(brand));
            }

            return catMatch && brandMatch;
        });

        renderProducts(filtered);
    }

    document.querySelectorAll('.cat-filter, .brand-filter').forEach(checkbox => {
        checkbox.addEventListener('change', applyFilters);
    });

    // 6. GELİŞMİŞ ARAMA ÇUBUĞU ENTEGRASYONU (Senin Tasarımın)
    const searchInput = document.getElementById('search-input');
    const searchBtn = document.getElementById('search-btn');

    function performSearch() {
        if (!searchInput) return;
        const term = searchInput.value.toLowerCase().trim();
        
        if (term === "") {
            applyFilters(); 
            return;
        }

        document.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false);

        const searchedProducts = allProducts.filter(p => {
            const urunAdi = (p.UrunAdi || "").toLowerCase();
            const kategoriAdi = (p.KategoriAdi || "").toLowerCase();
            
            return urunAdi.includes(term) || kategoriAdi.includes(term);
        });

        renderProducts(searchedProducts);
    }

    if (searchInput) {
        searchInput.addEventListener('input', performSearch);
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault(); 
                performSearch();
            }
        });
    }

    if (searchBtn) {
        searchBtn.addEventListener('click', performSearch);
    }

    // İlk açılışta ürünleri çek
    fetchProducts();

    // 7. SEPETE EKLEME MANTIĞI (VERİTABANINA BAĞLANDI)
    document.addEventListener('click', async (e) => {
        const btn = e.target.closest('.add-to-cart-btn');
        if (btn) {
            if (!currentUser) {
                showToast("Satın alma işlemi için giriş yapmalısınız!", "error");
                setTimeout(() => { window.location.href = 'login.html'; }, 1500);
                return;
            }
            
            const user = JSON.parse(currentUser);
            const urunId = btn.dataset.id;
            
            try {
                // Veritabanına Ekle
                const res = await fetch('http://localhost:5000/api/cart/add', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ musteriId: user.MusteriID, urunId: urunId })
                });

                if((await res.json()).success) {
                    updateCartBadge(); // Veritabanından yeni sayıyı çek
                    showToast("Ürün sepete başarıyla eklendi!", "success");
                }
            } catch (err) {
                showToast("Sunucuya bağlanılamadı!", "error");
            }
        }
    });
});