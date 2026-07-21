# Wolvox 8/9 — Perakende Entegrasyonları (ÖKC / Yazar Kasa + e-Ticaret / Pazaryeri)

> Perakende & restoran danışmanlığının çekirdeği: **yeni nesil yazar kasa (ÖKC)** ve **e-Ticaret/pazaryeri**
> entegrasyonu. Akışlar resmî AKINSOFT eğitim videolarından damıtıldı → `📹` (etiket sözcüğü oto-altyazı
> kaynaklı olabilir; ekranda teyit). Tablo/kolon iddiası yok — davranış + kurulum + tuzak odaklı.
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

## Perakende danışman refleksi
| Müşteri diyor ki | Bak |
|---|---|
| "Yazarkasaya fiş gitmiyor / ödeme türü yanlış" | §1 (aktivasyon + ödeme eşleştirme) |
| "Gün sonu ÖKC ile Wolvox tutmuyor" | §1 tuzaklar (ÖKC ayrı GİB raporlar) |
| "Sitedeki fiyat/KDV yanlış görünüyor" | §2a (panel KDV/etiket ayarları) |
| "Müşteri taksidini siteden ödeyemiyor / Wolvox'a düşmüyor" | §2b (sanal POS ↔ taksit eşleştirme) |
| "Pazaryerinde ürün listelenmiyor / aynı ürün iki yerde satıldı" | §2c (grup/kategori, overselling) |

> Kâr analizi için komisyon/kargo/ÖKC türü ayrımı [rapor-sablonlari](rapor-sablonlari.md) bulgu tablosuna
> girer; kanal bazlı kârlılık **komisyon düşülmüş** hesaplanmalı.
