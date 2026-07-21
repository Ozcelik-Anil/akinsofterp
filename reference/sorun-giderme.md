# Wolvox 8/9 — Sorun Giderme Playbook (semptom → neden → çözüm)

> Sahadan sık gelen şikâyetler ve destek-masası refleksleri. Her madde: **semptom → olası neden →
> tanı (salt-okunur) → çözüm (UI tercih, gerekiyorsa inert SQL taslağı)**. Hiçbir çözüm üretimde
> doğrudan yazma içermez; migration'lar `BEGIN TRAN … ROLLBACK;` taslağıdır.

---

## 1. Bağlantı / Altyapı

### "Programa giremiyorum / veritabanına bağlanamıyor"
- **Neden:** SQL Server servisi durmuş; yanlış sunucu IP/instance; port kapalı (MSSQL 1433 / Firebird 3050); firewall; süresi dolmuş `.mdf`/alias.
- **Tanı:** `Get-Service MSSQL*` (servis ayakta mı); `Test-NetConnection sunucu -Port 1433`; istemcideki bağlantı ayarını (Wolvox giriş ekranı → sunucu adı) kontrol et.
- **Çözüm:** Servisi başlat; tüm terminaller **aynı sunucu\instance + DB**'yi göstermeli; firewall'da portu aç. Asla "yeniden kur" ile başlama — önce servis+port+alias üçlüsü.

### "Bir terminal bağlanıyor, diğeri bağlanamıyor"
- **Neden:** İstemcilerin farklı sunucu/DB'ye bakması; sürüm uyuşmazlığı (client vs server build).
- **Çözüm:** Tüm istemcilerde Wolvox sürümünü ve bağlantı hedefini eşitle.

---

## 2. Stok

### "Stok bakiyesi tutmuyor / yanlış"
- **Neden:** Açılış/devir hareketi girilmemiş; negatif satış (stoksuz çıkış); sayım farkı işlenmemiş; iade yanlış yön; depo bazında bakılmıyor.
- **Tanı:** Bakiye = `Σ(KPB_GMIK − KPB_CMIK)` (STOKHR, `SILINDI=0`). Negatif kartlar için [sorgu-recetesi A5](sorgu-recetesi.md). Devir hareketi var mı: `STOKHR.DEVIR=1` kontrolü.
- **Çözüm (UI):** *Stok > Sayım / Envanter* ile fiili sayım gir; eksik devir için yıl açılışını kontrol et. Ham tabloya elle dokunma (maliyet/muhasebe eşlemesi bozulur).

### "Satışta ürün fiyatı gelmiyor / sıfır geliyor"
- **Neden:** Kartta satış fiyatı tanımsız; yanlış `FIYAT_NO`; döviz fiyat + boş `DOVIZ_BIRIMI`; pasif kart.
- **Tanı:** [sorgu-recetesi A6](sorgu-recetesi.md) (fiyatsız aktif kart) ve [A1](sorgu-recetesi.md) (bozuk döviz birimi).
- **Çözüm (UI):** *Stok > Toplu Fiyat Güncelleme*; döviz birimini düzelt.

### "Barkod okutunca yanlış/başka ürün geliyor"
- **Neden:** Mükerrer barkod ([sorgu-recetesi A2](sorgu-recetesi.md)).
- **Çözüm:** Çakışan barkodları tekilleştir; barkod üretimini otomatiğe al.

---

## 3. Cari / Tahsilat

### "Cari bakiyesi yanlış / ekstre tutmuyor"
- **Neden:** Açılış devri eksik; çift kayıt; virman/mahsup yanlış; iade fatura ters işlenmiş; tahsilat yanlış cariye.
- **Tanı:** Bakiye = `Σ KPB_BTUT − Σ KPB_ATUT` (CARIHR, `SILINDI=0`). Şüpheli hareketleri `ISLEM_TURU` ([kod-sozlugu](kod-sozlugu.md)) ve `TARIHI` ile süz.
- **Çözüm (UI):** *Cari > Ekstre* ile mutabakat; yanlış fişi ilgili modülden düzelt (ham CARIHR'a dokunma — muhasebe/kasa eşlemesi kopar).

---

## 4. e-Dönüşüm (en sık destek konusu)

### "e-Fatura gönderilmiyor / GİB'e ulaşmıyor"
- **Neden:** Mali mühür/sertifika süresi dolmuş; entegratör bağlantısı/oturumu düşmüş; zorunlu alan boş (VKN/TCKN, adres, senaryo); kontör bitmiş; alıcı posta kutusu yanlış.
- **Tanı:** Askıda faturalar → [sorgu-recetesi C1](sorgu-recetesi.md) (`EFATURA_DURUM=1`); hata metni → `FATURA.OTO_GONDERIM_HATA` ([C2](sorgu-recetesi.md)).
- **Çözüm (UI):** *e-Dönüşüm > Gönderilecekler / Hatalı Belgeler*; sertifika ve entegratör bağlantısını kontrol et; zorunlu alanları tamamla → yeniden gönder. Kod anlamları için [kod-sozlugu: EFATURA_GIB_DURUM](kod-sozlugu.md).

### "Müşteri e-Fatura mükellefi ama kağıt/e-Arşiv kesmişiz"
- **Neden:** `CARI.EFATURA_KULLAN` / senaryo güncellenmemiş; GİB mükellef listesi eşitlenmemiş.
- **Çözüm (UI):** Mükellef listesini güncelle; carinin e-Fatura bayrağını/senaryosunu düzelt.

---

## 5. Muhasebe (ayrı `_GMUHASEBE` DB'sinde)

### "Mizan tutmuyor / fişler muhasebeye düşmemiş"
- **Neden:** Entegrasyon şablonu eksik grup; muhasebeleştirme çalıştırılmamış; ters bakiye.
- **Tanı:** `_WOLVOX.FATURA.GM_ENTEGRASYON` bayrağı 0 kalan belgeler; muhasebe verisi ise **ayrı DB'de**: `WOLVOX8_<firma>_<yıl>_GMUHASEBE` (`YEVMIYE`, `YEVMIYEHR`, `HESAP_PLANI`). Mizan analizini o DB'de yap.
- **Çözüm (UI):** *Genel Muhasebe > Entegrasyon > Muhasebeleştirme*; eksik şablonları tanımla.
- ⚠️ **Not:** "Muhasebe kullanılmıyor" sonucunu `_WOLVOX`'a bakarak verme — tablolar `_GMUHASEBE` DB'sindedir. Modülün kullanımını o DB'de (`YEVMIYE` satır sayısı) doğrula.

---

## 6. Dönem / Yıl Sonu

### "Yeni yıla geçemiyorum / geçen yılın stoğu gelmedi"
- **Neden:** Çalışma yılı devri (açılış) yapılmamış; yeni yıl DB'si (`WOLVOX<sürüm>_<firma>_<yeniyıl>_...`) oluşturulmamış.
- **Belirti:** DB adı hâlâ eski yılı gösterir (ör. `_2023_` iken takvim 2025) → devir yapılmamış olabilir **veya** bilinçli olarak tek yılda çalışılıyordur. **Kullanıcıya sor, varsayma.**
- **Çözüm (UI):** *Yönetim / Dönem İşlemleri > Devir / Yıl Sonu* ile açılış; stok, cari, çek/senet, banka bakiyeleri devreder.

---

## 7. Performans

### "Program yavaşladı / raporlar geç geliyor"
- **Neden:** Şişmiş log/senkron tabloları; eksik index (`TARIHI`, `BLSTKODU`, `BLCRKODU`); mesai saatinde ağır rapor; DB bakımı (index rebuild/istatistik) yapılmamış.
- **Tanı:** Büyük tablolar → [sorgu-recetesi D1/D2](sorgu-recetesi.md). Native olmayan (İngilizce/camelCase adlı) şişmiş tablolar bakım/arşiv adayı olabilir; sahibine kim kurdu/aktif mi diye sor.
- **Çözüm:** Şişmiş standart-dışı tabloları (varsa) sahibiyle arşivle; index öner (asla otomatik ekleme); ağır raporları mesai dışına/yedek kopyaya al; düzenli index bakımı planla.

---

*Bu playbook genel Wolvox davranışına dayanır; menü adları sürüme (8/9) ve edisyona göre değişebilir.
Çözümden önce ilgili tanıyı çalıştır — "önce ölç, sonra reçete."*
