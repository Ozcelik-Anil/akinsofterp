# Wolvox 8/9 — Perakende Entegrasyonları (ÖKC / Yazar Kasa + e-Ticaret / Pazaryeri)

> Perakende & restoran danışmanlığının çekirdeği: **yeni nesil yazar kasa (ÖKC)** ve **e-Ticaret/pazaryeri**
> entegrasyonu. Akışlar resmî AKINSOFT eğitim videolarından damıtıldı → `📹` (etiket sözcüğü oto-altyazı
> kaynaklı olabilir; ekranda teyit). `👤` işaretli akışlar bayi/danışman/kullanıcı videosundan damıtıldı,
> resmî AKINSOFT kaynağı değil; versiyon/terim sapması riski daha yüksek. Tablo/kolon iddiası yok —
> davranış + kurulum + tuzak odaklı.
> Pazaryeri şema uyarısı için → [modul-derinlik §4](modul-derinlik.md); ayar toggle'ları → [ozel-ayarlar](ozel-ayarlar.md).

---

## 1) Yeni Nesil Yazar Kasa (ÖKC) entegrasyonu  `📹`

Wolvox iki yaygın ÖKC yolunu destekler; **ortak kalıp** aynıdır: *lisans/ücret → Kontrol Paneli'nde aktive →
cihaz tanımı (seri no + IP) → eşleştir → **ödeme tanımı eşleştirme** → satışta otomatik fiş gönderimi.*

### Ortak aktivasyon (her marka)
`Kontrol Paneli > Yetkili Şirket Kayıt İşlemleri > e-Devlet 1` → **"Android yeni nesil (ÖKC) entegrasyonu
kullan"** + ilgili marka seçeneği aktif. **Şube modülü** varsa şube kayıt ekranında da aynı işaretler
(şube başına ÖKC). → [kurulum-playbook §6-A](kurulum-playbook.md).

### a) Pavo N86 (Android) — Hızlı Satış içinden
- **Ön koşul (lisans):** hızlı satış · stok · cari · kasa · fatura · e-Fatura/e-Arşiv.
- `Hızlı Satış > Yetkili > Özel Ayarlar > Entegrasyon Ayarları > Pavo N86` → **cihaz tanımı** (görünen ad,
  **seri no, IP**) → **personel atama**.
- **Cihaz üzerinde:** `Ayarlar > Satış Uygulamaları > Harici Entegrasyonlar > Entegrasyon > "rest"` → tamam.
- Panelde **"cihaz eşleştir"** → satış ekranında ürün + nakit/POS ödeme → işlem **otomatik yazarkasaya** gider.

### b) Ingenico / PAX — Wolvox Yazar Kasa Otomasyonu (ayrı uygulama)
- **Ön koşul:** yazar kasa modülü; e-kasa sisteminde cihaz için **yıllık ücret**; cihaza **parametre yükleme**.
- `Yazar Kasa Otomasyonu > Ingenico Pax entegrasyonu > Ayarla` → **seri no + IP** → **"uygulamayı çalıştır"**
  (servis uygulaması) → **cihaz eşleştir**.
- **Cihazdan al:** KDV bilgileri · kısım bilgileri · banka listesi · yemek kartı listesi.
- **Ödeme eşleştirme:** Wolvox ödeme tanımları ↔ yazarkasa ödeme tanımları (kritik adım).

**Danışman soruları:** hangi marka/model ÖKC? Lisansta yazar kasa/hızlı satış modülü var mı? **Ödeme
tanımları eşleşti mi** (nakit/kredi/yemek kartı)? Şubeli mi (şube başına cihaz)?

**Tipik tuzaklar:**
- **Ödeme tanımı eşleşmezliği** → satış fişi gider ama kasa/cari yanlış ödeme türüne düşer (mutabakat bozulur).
- ÖKC **GİB'e kendi raporlar** (Z raporu/mali hafıza); Wolvox satışıyla ÖKC toplamı **tutmazsa** gün sonu açığı.
- Cihaz IP değişince (DHCP) eşleştirme kopar → **sabit IP** öner.
- Yemek kartı (Sodexo/Multinet/…) ayrı ödeme türü; nakit sanılırsa ciro türü yanlış.

**Tanı sorgusu — gün sonu ödeme-türü mutabakatı** `📖` salt-okunur (ÖKC Z raporuyla karşılaştır):
```sql
-- ⚠️ KASAHR ödeme-türü/tutar kolon adlarını install'da doğrula (nakit/kredi/yemek kartı ayrımı)
SELECT CAST(TARIHI AS date) gun, <ODEME_TURU> tur, SUM(<TUTAR>) wolvox_toplam
FROM KASAHR
WHERE ISNULL(SILINDI,0)=0 AND CAST(TARIHI AS date) = CAST(GETDATE() AS date)
GROUP BY CAST(TARIHI AS date), <ODEME_TURU>;
-- Bu toplam, cihazın Z raporundaki tür-bazlı toplamla TUTMALI. Fark = eşleşmemiş ödeme türü ya da eksik fiş.
```

---

## 2) e-Ticaret / Pazaryeri entegrasyonu  `📹`

İki katman: **AKINSOFT e-Ticaret paneli** (kendi web sitesi) ve **pazaryerleri** (N11/Trendyol/Hepsiburada…).
Pazaryeri tabloları çoğu kez **native Wolvox değildir** → [modul-derinlik §4](modul-derinlik.md) + [schema-map §1](schema-map.md).

### a) AKINSOFT e-Ticaret paneli — fiyat/KDV/etiket
`e-Ticaret paneli > Ayarlar > KDV ve Etiket Ayarları`: **KDV dahil/hariç gösterimi** · üye tipine göre
("+KDV" yazımı) · **fiyat etiket** güncelleme (panel fiyatı → ürün fiyatı) · varsayılan KDV oranı · ürün
detayında KDV oranı/etiketi gösterme. → site fiyat gösterimini yönetir (ERP değil, **panel** tarafı).

### b) Wolvox ERP ↔ e-Ticaret **taksit / online tahsilat** (çift yön)
- **Ön koşul:** e-Ticaret'te **online tahsilat** modülü; Wolvox'ta **banka + taksit takip** modülleri.
- Wolvox'ta cari için **taksitleri oluştur** → e-Ticaret panel `Entegrasyonlar > Ticari Program Yönetimi >
  Entegrasyon Yönetimi` → carinin taksitli borçları görünür, "ödeme yapabilir" işaretle.
- Üye/bayi e-ticaret'e login → `Cari İşlemler > Taksit Ödeme` → taksit seç → **sanal POS** ile öde.
- **Sanal POS taksit tanımları ↔ Wolvox taksit tanımları eşleştirilmeli.** Ödeme sonrası Wolvox'ta cari
  taksit durumu **"ödendi"** güncellenir.

### c) Pazaryeri (N11/Trendyol/HB…) & kargo
- **Kategori bazlı ürün gönderimi** (ör. N11 kategori eşlemesi), **kargo** ekleme/entegrasyonu, kargo
  tamamlayıcı ürün. Ürün **grubu/kategorisi boşsa listeleme bozulur** → [P24](cozum-desenleri.md).

**Danışman soruları:** entegrasyonu **kim sağlıyor** (Akınsoft e-Ticaret mi, 3. parti mi)? Stok/fiyat **hangi
yönde** senkron, çakışmada kim kazanır? Sipariş hangi belgeye düşüyor? **Komisyon/kargo** maliyete giriyor mu?

**Tipik tuzaklar:**
- İki kanal aynı stoğu satar (senkron gecikmesi) → **overselling**.
- Sanal POS taksit tanımı eşleşmezliği → tahsilat Wolvox'a **yanlış/eksik** yansır.
- Pazaryeri komisyonu/kargo maliyete girmez → kanal kârlılığı **yanlış** görünür.
- SKU/barkod eşleşmezliği → yanlış ürün gönderimi.

---

## 3) Wolvox Restoran (adisyon / garson / kurye)  `👤`

> Referansta yalnızca stok kartı `Özel Ayarlar 1 > e-Ticaret ve Restoran` kutusu ve
> [kurulum-playbook](kurulum-playbook.md)'ta edisyon adı olarak geçiyordu; **kullanım akışı burada ilk kez**.
> Bayi videosundan damıtıldı → `👤` (resmî AKINSOFT kaynağı değil; ekranda teyit).

### a) Garson ekranı — iki katmanlı yetkilendirme
Bir garsonu devreye almak **iki ayrı yerde** kayıt gerektirir; biri eksikse garson programa giremez:
1. **ERP tarafı:** `Finans Yönetimi > Tanımlar > Cari Tanımları` > garson için cari kart aç (ad-soyad) >
   **`Özel Bilgiler`** sekmesi (👤 kaynak video "Özel Bilgiler 2" diyor — ekranda teyit et, kanonik ad
   büyük olasılıkla eksiz) > **`Garson`** kutusunu işaretle > **garsona ait şifreyi** ilgili alana
   gir > Kaydet.
2. **Kontrol Paneli tarafı:** `Kullanıcı İşlemleri > Kullanıcı Kayıt İşlemleri` ile kullanıcıyı
   oluştur > `Kullanıcı Yetkilendirme` > önce **`Restoran`**, sonra **`Restoran Programı Kullanımı`**
   işaretle > verilecek yetkileri seç > **`Yetkileri Kaydet`**.

Girişte sırayla: Kontrol Paneli kullanıcı adı/şifresi → **şirket seçimi** → **bölüm seçimi** →
ardından **cari karttaki garson şifresi**. Garson yalnızca yetkisi dahilindeki alanları görür. Ekran
**dokunmatik monitöre tam destek** verir.

### b) Kurye / paket ekranı
Masaya (adisyon) değil, **paket/eve servis** satışlarını izler; self-servis ve eve servis yapan
işletmeler için. Akış adisyonla aynıdır: **`Paket`** butonu > **`Yeni Sipariş`** (her sipariş için
yeni kayıt). Yetki: `Kontrol Paneli > Kullanıcı İşlemleri > Kullanıcı Yetkilendirme > Restoran >
**`Kurye Ekranı Kullanımı`** > `Yetkileri Kaydet`` — bu yetkiyle giren personelin karşısına doğrudan
kurye ekranı gelir. `Menü > Kurye Ekranı`'ndan **kurye giriş/çıkış takibi** yapılır.

### c) Caller ID köprüsü
Caller ID cihazı bağlıysa müşteri aradığında **telefon çağrısı uyarısı** açılır; uyarıya tıklayınca
kayıtlı müşteri için **`Fiş Aç`**, kayıtsız için **`Yeni Cari Kartı Aç`** denerek sipariş doğrudan
alınır. [ozel-ayarlar §15 Caller ID Ayarları](ozel-ayarlar.md)'nın restoran karşılığı — Caller ID'nin
en somut iş değeri burada.

**Danışman soruları:** garson **iki yerde de** (cari kart + Kontrol Paneli) tanımlı mı? Kurye ekranı
yalnızca paket/eve servis siparişleri için mi kullanılıyor, adisyonla karıştırılıyor mu? Caller ID
cihazı fiziksel olarak bağlı ve tanımlı mı?

**Tipik tuzaklar:**
- ⚠️ "Garson giriş yapamıyor" çağrısında **hangi şifreyi** girdiğine bak — iki farklı şifre vardır
  (Kontrol Paneli kullanıcı şifresi ≠ cari karttaki garson şifresi).
- Kontrol Paneli tarafında `Restoran` yetkisi işaretlenmeden `Restoran Programı Kullanımı`
  işaretlenirse garson yine giremeyebilir — sıra **önce Restoran, sonra alt yetki**.
- Kurye ekranı yetkisi olmayan personel paket siparişini adisyon ekranından girmeye çalışır →
  kurye giriş/çıkış takibi eksik kalır.

---

## Perakende danışman refleksi
| Müşteri diyor ki | Bak |
|---|---|
| "Yazarkasaya fiş gitmiyor / ödeme türü yanlış" | §1 (aktivasyon + ödeme eşleştirme) |
| "Gün sonu ÖKC ile Wolvox tutmuyor" | §1 tuzaklar (ÖKC ayrı GİB raporlar) |
| "Sitedeki fiyat/KDV yanlış görünüyor" | §2a (panel KDV/etiket ayarları) |
| "Müşteri taksidini siteden ödeyemiyor / Wolvox'a düşmüyor" | §2b (sanal POS ↔ taksit eşleştirme) |
| "Pazaryerinde ürün listelenmiyor / aynı ürün iki yerde satıldı" | §2c (grup/kategori, overselling) |
| "Garson/kurye programa giremiyor" | §3a/§3b (iki katmanlı yetkilendirme, şifre karışıklığı) |

> Kâr analizi için komisyon/kargo/ÖKC türü ayrımı [rapor-sablonlari](rapor-sablonlari.md) bulgu tablosuna
> girer; kanal bazlı kârlılık **komisyon düşülmüş** hesaplanmalı.
