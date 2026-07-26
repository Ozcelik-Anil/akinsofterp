# Wolvox 8/9 — Menü / Arayüz Haritası (UI path katalogu)

> "Dual output"un **UI yarısı**: her işlemin Akınsoft arayüzündeki yeri. Danışman SQL kadar
> menü yolunu da vermeli. İlgili SQL reçetesi olan satırlarda **reçete referansı** verilir.
>
> ### Güven etiketi (her satır bu işaretlerden birini taşır)
> - **`≈`** — genel Wolvox bilgisine dayanır, **canlı ekranla teyit edilmemiş**. Kullanıcıya
>   "senin sürümünde şuna yakın" diye ver, ekranda birlikte doğrulayın.
> - **`📹`** — **resmî AKINSOFT eğitim videosundan** damıtılmış akış (Wolvox 8). Adım sırası ve sekme
>   yapısı kaynak-teyitli; ancak etiket sözcükleri **oto-altyazı** kaynaklı olabileceğinden ufak
>   sapma taşıyabilir. `≈`'den güçlü, `✓`'dan zayıf: akışa güven, sözcüğü ekranda teyit et.
> - **`✓`** — belirli bir sürümde (8/9) **saha/canlı ekran teyitli**. İlk saha koşusu **25.07.2026**'da
>   **Wolvox 8 ERP s8.25.23 (sektörel/otomotiv paketi)** üzerinde salt-okunur yapıldı; o koşuda görülen
>   satırlar `✓ (8.25)` etiketlidir. Doğruladıkça `📹`/`≈`→`✓` yükselt ve sürüm etiketle.
> - **`👤`** — bayi/danışman/kullanıcı videosundan damıtıldı, resmî AKINSOFT kaynağı değil; versiyon/terim
>   sapması riski daha yüksek. Canlı ekranla teyit edilince `👤`→`✓`.
>
> ⚠️ **Saha koşusunun en önemli çıktısı: üst menü yapısı `📹` varsayımından farklı.** Wolvox 8'de
> `Fatura`, `İrsaliye`, `Sipariş`, `Çek/Senet`, `e-Dönüşüm` diye **bağımsız üst menüler yoktur**.
> Belgeler **alış/satış eksenine** bölünür (`Satın Alma Yönetimi` vs `Satış Yönetimi`), finans tek
> çatı altındadır (`Finans Yönetimi`), e-Fatura ise her modülün `Faturalar` alt menüsünün içindedir.
> Aşağıdaki `✓ (8.25)` satırlar bu koşudan; `≈`/`📹` satırlar hâlâ teyit bekliyor.
>
> ⚠️⚠️ **İKİ AYRI AYAR AĞACI VAR — karıştırma, aradığın ayarı bulamazsın:**
> | Ağaç | Yol `✓ (8.25)` | Ne yönetir |
> |---|---|---|
> | **Genel Ayarlar** | `Yetkili > **Tanımlar** > Genel Ayarlar` | Firma geneli **veri/varsayılan** kuralları: KDV, hassasiyet, otomatik kod/barkod, depo & limitler, gelişmiş fiyat/iskonto sistemi, fiyat loglama |
> | **Özel Ayarlar** | `Yetkili > **Özel Tanımlar** > Özel Ayarlar` | Modül **davranış** anahtarları: reprice penceresi, hızlı satış, elektronik terazi, performans, Caller ID/sanal santral |
>
> Skill'in "Özel Ayarlar > …" diye verdiği yollar **doğrudur** — sadece tam yolun başı
> `Yetkili > Özel Tanımlar >` şeklindedir. İkisinde de `Stok Ayarları` / `Fatura Ayarları` adlı
> **eş adlı ama farklı içerikli** düğümler bulunur; bir ayarı bulamıyorsan **diğer ağaca bak**.
>
> ⚠️ Menü metinleri **sürüme (8 vs 9) ve edisyona göre değişir**. Emin olmadığın metni kesin verme;
> işareti koru ve kullanıcıdan ekranı teyit etmesini iste. UI yolu uydurmak, kolon uydurmak kadar hatalıdır.
>
> 🔎 **Hızlı erişim refleksi (📹 teyitli):** Wolvox 8'de ana ekranda **arama kutusuna işlem adını yaz**
> (örn. "stok tanımları") → menü doğrudan açılır; sağ tuş → **"Hızlı Erişime Ekle"** ile ana ekrana
> kısayol iğnelenir. Yol bulunamadığında ilk çare budur — kullanıcıya bunu öğret.

---

## Üst menü yapısı — `✓ (8.25)` saha-teyitli
```
Stok Yönetimi · Satın Alma Yönetimi · Satış Yönetimi · Finans Yönetimi ·
Diğer İşlemler · Yetkili · Pencere · Yardım
```
**Her modül menüsü aynı üç dala ayrılır: `İşlemler` · `Tanımlar` · `Raporlar`.** Yol ararken önce
"bu iş bir işlem mi, bir tanım mı, bir rapor mu?" diye sor — üçlü kalıp tüm modüllerde geçerli.

Modül eşlemesi (nerede ne var):
| Aradığın | Gerçek yeri `✓ (8.25)` |
|---|---|
| Stok kartı, depo, envanter, ölü stok | **Stok Yönetimi** |
| Alış teklifi/siparişi/irsaliyesi/faturası, e-Fatura (alış) | **Satın Alma Yönetimi** |
| Satış teklifi/siparişi/irsaliyesi/faturası, e-Fatura (satış), mobil satış | **Satış Yönetimi** |
| Cari, kasa, banka, çek/senet, tahsilat/tediye, döviz | **Finans Yönetimi** |
| Genel Muhasebe köprüsü, Excel transfer, SMS, özel raporlar, araçlar | **Diğer İşlemler** |
| Genel Ayarlar, anonimleştirme, log, sayaç, kullanıcı/personel | **Yetkili** |

> ❌ **Var olmayan menüler (skill'in eski varsayımı):** üst düzeyde `Fatura`, `İrsaliye`, `Sipariş`,
> `Teklif`, `Kasa`, `Banka`, `Çek/Senet`, `e-Dönüşüm`, `Raporlar`, `Yönetim`/`Ayarlar` **yoktur**.
> Bunlara bu adlarla yol verme; yukarıdaki tabloya göre çevir.

> **8 vs 9 kaba fark:** Wolvox 9'da üst şerit daha modül-sekmeli; e-Dönüşüm 9'da daha görünür/olgun.
> Menü **adları** değişebilir. Aşağıdaki yollar 8 temelli; 9'da en yakın karşılığı ara.

> 🔎 **Ayar bulma refleksi `✓ (8.25)`:** **her iki** ayar penceresinin de sağ üstünde **büyüteç =
> ayar arama motoru** vardır. Ayar adının parçasını yaz → **Enter** → sonuç listesi "ayar adı |
> hangi ayar grubunda" olarak gelir; satıra **çift tıkla** doğrudan o sekmeye gider. (Kutu başlangıçta
> `Arama...` metnini gerçek içerik olarak taşır; önce `Ctrl+A` ile temizle.)
> ⚠️ **Arama yalnızca açık olduğun ağacı tarar** — `Genel Ayarlar`da arayıp bulamamak, ayarın
> **yok** olduğu anlamına gelmez; `Özel Ayarlar`da tekrar ara. (Bu tuzak ilk saha koşusunda
> "reprice ayarı yok" diye yanlış bir sonuca yol açtı.)

---

## Stok Yönetimi
Dal yapısı `✓ (8.25)`:
- **İşlemler:** Stok Giriş Hareketi · Stok Çıkış Hareketi · Toplu Stok Hareketi · Depo İşlemleri ▸ · Stok Sayımı ve Düzenleme · Stok Tanım Birleştirme
- **Tanımlar:** Stok Tanımları · Hızlı Stok Tanımı · Hizmet Tanımları · Paket Tanımları · Depo ▸ · Stok Birim Tanımları · **Fiyat Tanımları** · E-Ticaret Özellik Tanımları · Stok Ek Özellik Tanımları · Marka/Model · Renk · Beden · **Stok Grup Tanımları** · Stok Kategori Tanımları · Hizmet Grup Tanımları
- **Raporlar:** Tanım Listeleri ▸ · İşlem Raporları ▸ · Envanterler ▸ · Analizler ▸

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Stok kartı aç/düzenle | `✓ (8.25)` | `Stok Yönetimi > Tanımlar > Stok Tanımları` | — |
| **Stok kartı sekme sırası** | `✓ (8.25)` | Genel Bilgiler · Birim/Barkod · Fiyatlar · **Muhasebe** · İstatistikler · **Depo** · **Özel Ayarlar 1** · **Özel Ayarlar 2** · Özel Tanımlar · Alternatifler · Alt Ürünler · Tedarikçiler · **Stok Durumu** (sekme şeridi taşar; sağdaki ◄► okuyla kaydır) | — |
| — Genel Bilgiler sekmesi | `✓ (8.25)` | Stok Adı · Stok Adı Y.Dışı · Stok Kodu · Barkod Tipi + Barkodu · Grubu/Ara Grubu/Alt Grubu · **Özel Kodu 1/2/3 (burada!)** · Açıklama 1/2/3 · **3 KDV alanı: `KDV Alış %` · `KDV Satış Prk.%` · `KDV Satış Tpt.%`** · ÖTV (Birim Fiyatı) · ÖTV-ÖİV % · **Satış Tevkifat Kodu/Oranı** + **Alış Tevkifat Kodu/Oranı** · Özel Matrah Kodu · İstisna Kodu · `85 Nolu KDV Kanununa Tabi` · Vade Günü · **Döviz Hesabı Kullan** · Pazarlamacı Prim Oranı/Tutarı · sağda Ana Stok/Asorti/Marka/Model/Renk/Beden | turkiye-uyumluluk §1-2 |
| — Birim/Barkod sekmesi (çoklu birim) | `📹` | Birim (adet/koli/kg/lt) · birden çok barkod · **çoklu birim + katsayı** (koli=15 → faturada oto ×15) | — |
| — Fiyatlar sekmesi | `✓ (8.25)` | Alt sekmeler **`Satış Fiyatları` / `Alış Fiyatları`**; grid kolonları: Fiyat No · Hesap · Tanımı · Barkodu · Birimi · **Fiyatı** · **Kaynak Fiyat** · **Kaynak Fiyat No** · **Kar Marjı**; altta buton **`Varsayılan Fiyat Tanımlarını Aktar`**. (Kaynak Fiyat + Kar Marjı = yerleşik marj-tabanlı fiyatlama; `STOK_FIYAT.KAYNAK_FIYAT_TIPI`/`KAR_MARJI` kolonlarının UI karşılığı) | sorgu-recetesi §H · P4 |
| — İstatistikler sekmesi (**son alış!**) | `✓ (8.25)` | Para birimi seçici (TL/…) + **`İstatistikleri Hesapla`** → *En son · Ortalama · **Ortalama ağırlıklı** · En ucuz · En pahalı* — hem **alış** hem **satış** fiyatı için. Reprice'ta "son alış" tabanının UI kaynağı; "ağırlıklı ortalama" maliyet yöntemi de burada hazır | sorgu-recetesi §H · P8 |
| — **Depo sekmesi = Min/Max'in gerçek yeri** | `✓ (8.25)` | `Depo Bilgileri` grid: Depo Adı · Koridor No · Raf No · Yer No · **Min.Miktar · Maks.Miktar** · Sipariş Listesine Ekle. Altta `Depo Bakiyeleri`: Miktar **Devir/Giren/Çıkan/Kalan/Termin/Bloke/Kull.bilir**. ⚠️ Min/max **kart genelinde değil, depo satırı bazında** tutulur (`STOK_DEPO`) — "Detay/Sipariş sekmesi" yolu **yanlıştı** | skill 5A · P13 |
| — Özel Ayarlar 1 sekmesi | `✓ (8.25)` | Alış/Satış İskontoları (1/2/3 + Stok %) · **Stok Bakiye Uyarıları: `Uyarma` / `Stok (-) eksiye düşerse uyar` / `Limitler dışına çıkarsa uyar`** · Kalite · Üretici Firma · Geçerli Depo · e-Ticaret ve Restoran (`WEB de Görünsün`, Özellik Tanımı, Resim Yolu) · `İade Edilemez Ürün` | P24 |
| — Özel Tanımlar (kullanıcı alanı, örn. SKT) | `✓ (8.25)` | Alt sekmeler (kuruluma göre, ör. `ÜRETİCİ` / `TAKIM MALİYET`) + altta **`Ayar`** butonu ile yeni alan aç → filtre/fatura/tasarım/raporda kullanılır | P26 |
| — Stok Durumu > **Devir Girişi** (açılış sayımı) | `✓ (8.25)` | `Temel Birim Bakiyeleri` / `Diğer Birimler` / `Asorti Bakiyeleri` grid'leri + altta **Şube** seçici · `Bakiyeleri Yenile` · **`Devir Girişi`** | sorun-giderme §2 · P21 |
| **Reprice tetiği:** alışta satış fiyatını yeniden oluştur | `✓ (8.25)` | **`Yetkili > Özel Tanımlar > Özel Ayarlar > Fatura Ayarları > `Alış Faturası` sekmesi`** → ana kutu **`Satış fiyatları oluşturma penceresini göster`**; işaretlenince altındaki üç seçenek açılır: `Alış fiyatlarına KDV ekle` · `Alış fiyatlarına ek maliyetleri ekle` · **`Yeniden oluşturulacak satış fiyatı sayısı`** (sayaç, varsayılan `1`). Kapalıyken alış kaydında pencere hiç çıkmaz. ⚠️ Bu ayar **`Genel Ayarlar` ağacında değildir** — orada arayan bulamaz | ozel-ayarlar §4 · sorgu-recetesi §H · P1 · tools/reprice-preview.ps1 |
| Alış fiyatının kendisini otomatik güncelle (farklı ayar!) | `✓ (8.25)` | `Yetkili > Tanımlar > Genel Ayarlar > **Stok Ayarları > Stok Hareket Ayarları** > "Stok alış fiyatını otomatik değiştir"` (açılır liste, varsayılan `Değiştirme`; "işlemleri yavaşlatabilir" uyarısı). Bu **satış** fiyatını değil, kartın **alış** fiyatını tazeler — reprice tetiğiyle karıştırma | P1 · P8 |
| Reprice tetiği (üretim maliyetinden) | `📹` | `Özel Ayarlar > Üretim Ayarları > "Satış fiyatları oluşturma penceresi"` (üretim modülü bu pakette yok — teyit edilemedi) | ozel-ayarlar §9 |
| **Kural-tabanlı fiyatlandırma motoru** (kullanılmayan hazine) | `✓ (8.25)` | `Yetkili > Tanımlar > Genel Ayarlar > Stok Ayarları > Genel > **Gelişmiş Satış Fiyatı Sistemini Kullan**` — cari kodu/grup/ara grup/alt grup/**Özel Kodu 1**/ülke/il/ilçe kırılımlarına **puan** verip fiyat seçtirir; `Çakışma Durumunda Seçilecek Fiyat` (ör. En Ucuz Fiyat). Yanında **`Gelişmiş İskonto Sistemi`** (+ miktar aralığına göre iskonto) | P4 · skill 5A |
| Toplu fiyat güncelleme | `≈` | (`8.25` menüsünde ayrı "Toplu Güncelleme" görülmedi) `Stok Yönetimi > İşlemler > Toplu Stok Hareketi` ve `Tanımlar > Fiyat Tanımları` üzerinden ilerle — ekranda teyit et | sorgu-recetesi §H3 · P17 |
| **Özel Kod atama (alt-küme işaretle)** | `✓ (8.25)` | Stok kartı > **`Genel Bilgiler` > Özel Kodu 1/2/3** (`OZEL_KODU1/2/3`, her biri büyüteçli seçim). ⚠️ "Özel Tanımlar sekmesi" **yanlıştı** — orası kullanıcı-tanımlı ek alanlar içindir | sorgu-recetesi §H1 · P3 |
| Otomatik barkod / stok kodu ayarı | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > `Stok Kodunu Otomatik Ver` / `Barkodu Otomatik Ver`` (paket barkodu için ayrıca `Stok Ayarları > Genel > Stok Paket Tanımları`) | — |
| Birim fiyat hassasiyeti (yuvarlama basamağı) | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > **Birim Fiyat Hassasiyeti**` (ör. `2 Basamak`); yanında `Miktar Hassasiyeti`, `2.Birim Hassasiyeti` | turkiye-uyumluluk §5 |
| **Min stok → otomatik sipariş** (kullanılmayan hazine) | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > **Otomatik Sipariş Oluştur**`: `Sipariş Listesine Ekle` · "Stok Miktarı … in altına düştüğünde" · "Sipariş Listesine otomatik ekle" · bloke miktarları dahil et. Ayrıca `Depo Bölümünü Kullan` + `Varsayılan Depo` + **`Stok limit ve uyarıları depo bazında kullan`** | skill 5A · P13 |
| Sayım / envanter | `✓ (8.25)` | `Stok Yönetimi > İşlemler > Stok Sayımı ve Düzenleme`; raporu `Raporlar > Envanterler > Stok Envanteri / (Birimli) / (Depo Bakiyeli)` | sorun-giderme §2 |
| Depo tanımları | `✓ (8.25)` | `Stok Yönetimi > Tanımlar > Depo ▸` (depo hareketleri: `İşlemler > Depo İşlemleri ▸`) | — |
| Grup/ara/alt grup tanımı | `✓ (8.25)` | `Stok Yönetimi > Tanımlar > Stok Grup Tanımları` (+ `Stok Kategori Tanımları`, hizmet için `Hizmet Grup Tanımları`) | P24 (grupsuz kart) |
| **Ölü / hareket görmeyen stok raporu** | `✓ (8.25)` | `Stok Yönetimi > Raporlar > Analizler > **İşlem Görmeyen Stoklar**` (komşuları: Stok Kar/Zarar Raporu · (Basit) · (Özel) · Dönemsel Giriş/Çıkış · **Stok Yeterlilik Raporu** · Stok Özel Rapor · Stok Hareket Analizi · (Aylık)) | sorgu-recetesi (ölü stok) · P10 |
| Mükerrer barkod tespiti | `≈` | *(native rapor yok)* → SQL ile ver | P12 |
| **Fiyat değişim geçmişi — önce loglamayı aç** | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Genel > **Stok Fiyat Loglama**` (`Loglama Türü` + `Loglama Süresi … Gün`). ⚠️ Varsayılan **`Hayır`** olabilir — kapalıysa **geçmiş hiç tutulmaz**; "fiyatı kim değiştirdi" sorusuna cevap istiyorsan önce bunu açtır (ileriye dönük çalışır, geçmişi geri getirmez) | P18 (denetim izi) |
| Lokasyon (raf/koridor) tanımı ve hareketi | `👤` | Tanım: `Stok Yönetimi > Tanımlar > Depo ▸ > depo > **Lokasyon Bilgileri** > Alt Lokasyon Ekle`; hareket: `Stok Yönetimi > İşlemler > **Depo İşlemleri ▸**` | native-index §8 |
| Depo kartı sekmeleri | `👤` | `Stok Yönetimi > Tanımlar > Depo ▸` > adı/yetkilisi/iletişim · `Aktif` (pasife alma) · **`Terminal Yetkileri`** · **`Kullanıcı Yetkileri`** · üstte **`Eşitle`** (deposuz geçmiş hareketleri bu depoya bağla) | native-index §8 |

## Finans Yönetimi (Cari · Kasa · Banka · Çek/Senet)
Dal yapısı `✓ (8.25)`:
- **İşlemler:** Tahsilatlar ▸ · Tediyeler ▸ · Kasa İşlemleri ▸ · Banka İşlemleri ▸ · Döviz İşlemleri ▸ · **Toplu Cari Hareket** · **Cari Virman** · **Cari Tanım Birleştirme** · Para Sayma · Seri Senet Basımı · Teminat Çeki/Senedi · **Çek/Senet İşlemleri**
- **Tanımlar:** **Cari Tanımları** · Kasa Tanımları · Banka Tanımları · **Döviz Tanımları** · Departman Tanımları · Resmi Tatiller · Cari Grup Tanımları · Kasa Grup Tanımları
- **Raporlar:** Tanım Listeleri ▸ · İşlem Raporları ▸ · **Bakiye Raporları ▸** (Bakiyeler Listesi · KPB Esaslı Bakiyeler Listesi · **Hareketli Bakiyeler Listesi** · Pazarlamacı Bakiyeler Listesi) · Pazarlamacı Raporları ▸ · Kasa Raporları ▸ · Çek/Senet Raporları ▸ · Banka Raporları ▸ · Döviz Raporları ▸ · **Analizler ▸** (İşlem Türü Raporu · Dönemsel Hareket Raporu · Cari Özel Rapor · Cari Hareket Analizi · (Aylık) · Cari Analizi · **Finansal Analiz ▸** [Detaylı · Periyodik Rapor · Kontrol · **Otomatik Talimat Kontrol** · **Zamanlı Hesaplar** · Ayarları] · Gün Sonu ▸ · **Yönetici Ekranı** · **Şube İzleme Ekranı**)

> 💡 `Yönetici Ekranı` ve `Şube İzleme Ekranı` = hazır yönetim panosu; "bana bir gösterge paneli lazım"
> diyen kullanıcıya SQL yazmadan önce bunları göster (STEP 0 native-first).

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Cari kartı aç/düzenle | `✓ (8.25)` | `Finans Yönetimi > Tanımlar > Cari Tanımları` | — |
| — Genel Bilgiler sekmesi | `📹` | Ticari unvan (şahısta ad-soyad) · adres · **ülke/il/ilçe listeden seç** (e-Fatura için kritik) · grup/ara/alt grup · telefon · vergi dairesi · **vergi no (10 hane) / TC (11 hane)** — biri dolu diğeri boş · unvan/vkn'de **boşluk bırakma** (yanlış e-fatura cezası) | turkiye-uyumluluk §3 · P29 |
| — Hesap Bilgileri sekmesi | `📹` | Yönetici **not/mesaj metni** (her modülde uyarı çıkar — "durdur müşteri") · **kamu kurumu** işareti · e-irsaliye devreye al · döviz sistem hesabı · **özel iskonto %** · **fiyat no seç** (örn. 6 → hep 6. fiyattan sat) | P4 · P30 |
| — Yetkililer sekmesi | `📹` | Kişi · dahili · görev · departman · cep → toplu SMS / mutabakat mektubu bu kişilere gider | P7 |
| — Özel Bilgiler sekmesi | `📹` | Banka · e-posta · **Rota grubu/sıra/kod** (sıcak satış saha) · **fatura adresi ≠ sevk adresi** · pazarlamacı sistemini kullan (+şifre) | — |
| — Bakiye/Kredi sekmesi > **Devir Girişi** | `📹` | Açılış bakiyesi (borç/alacak) devir girişiyle işlenir (vergi no zorunlu) | sorun-giderme §6 · P21 |
| — Bakiye/Kredi sekmesi > **Kredi Limitleri** | `👤` | `Bakiyeler` (TL + döviz) · **`Kredi Limitleri`** (açık hesap / sipariş / irsaliye / çek-senet ayrı ayrı + `Kredi Aşımında Uyar`) · **`Çek/Senet Limitleri`** | native-index §4 |
| — **Bonus** sekmesi (Bonus Sistemi açıksa) | `👤` | Bonus tanımı seçimi + bonus bakiyesi | native-index §4 · Kampanya/Sadakat tablosu |
| — Üst menü: Yeni İşlem / Kopyala | `📹` | `Yeni İşlem` → fatura/teklif/sipariş/servis/tahsilat/ödeme · `İşlemler > Kopyala` (kartı çoğalt) · `Dosya` sekmesi (**Cari II** modülü) | — |
| Ekstre / hesap özeti | `≈` | `Finans Yönetimi > Raporlar > İşlem Raporları ▸` (ekstre burada; ekranda teyit et) | sorun-giderme §3 · P7 |
| Yaşlandırma (vade analizi) | `≈` | `8.25` menüsünde "Yaşlandırma" adıyla **görülmedi**; en yakınları `Raporlar > Bakiye Raporları > Bakiyeler Listesi` ve `Analizler > Cari Analizi` / `Finansal Analiz > Detaylı`. Vade kırılımı yoksa SQL ile ver | P9 |
| Risk/limit ayarı | `📹` | Cari kartı > `Hesap Bilgileri` (risk/mesaj metni) | — |
| Toplu cari işlem | `✓ (8.25)` | `Finans Yönetimi > İşlemler > **Toplu Cari Hareket**`; mükerrer kart temizliği için `İşlemler > **Cari Tanım Birleştirme**`; hesaplar arası aktarım `İşlemler > **Cari Virman**` | P17 |
| 90+ gün hareketsiz cari | `✓ (8.25)` | Native karşılığı: `Raporlar > Bakiye Raporları > **Hareketli Bakiyeler Listesi**` (hareket tarihine göre filtre) — "Hareketsiz Cariler" adlı ayrı rapor **yok** | skill 5C (PII maskeli) · P15 |
| Atanan fiyat listesi | `📹` | Cari kartı > `Hesap Bilgileri` > fiyat no (`STOK_FIYATI` = FIYAT_NO) | P4 (müşteri-doğru fiyat) |
| Taksit planı kur / taksit tahsil et | `👤` | `Finans Yönetimi > İşlemler > **Taksit İşlemleri** ▸ Yeni Taksit Girişi` — `8.25` saha dal listesinde görülmedi, **edisyon/lisansa bağlı** olabilir | native-index §4 |

## Belge zinciri: Satın Alma Yönetimi vs Satış Yönetimi
⚠️ **Tek bir `Fatura`/`İrsaliye`/`Sipariş`/`Teklif` menüsü yoktur.** Aynı dört belge tipi **iki ayrı
modülde** yaşar; hangisini kullanacağını **yön** belirler (alış mı satış mı).

| Modül | İşlemler dalı `✓ (8.25)` |
|---|---|
| **Satın Alma Yönetimi > İşlemler** | Teklifler ▸ · Siparişler ▸ · İrsaliyeler ▸ · **Faturalar ▸** |
| **Satış Yönetimi > İşlemler** | Teklifler ▸ · Siparişler ▸ · İrsaliyeler ▸ · **Faturalar ▸** · **Mobil Satış ▸** |

**Faturalar ▸ içeriği `✓ (8.25)`**
- *Satın Alma:* `Alış Faturası` · `Alıştan İadeler` · **`Masraf Faturası`** · `Toplu Masraf Faturası` · `Fatura Kopya Oluşturma` · **`e-Fatura ▸`**
- *Satış:* **`Yurt İçi Satış Faturası`** · `Yurt İçi Satıştan İadeler` · **`Yurt Dışı Satış Faturası`** (ihracat) · `Yurt Dışı Satıştan İadeler` · `Toplu Fatura Basımı` · `Fatura Kopya Oluşturma` · **`e-Fatura ▸`**

> İhracat faturası ayrı bir menü öğesidir (`Yurt Dışı Satış Faturası`) — e-Fatura **İHRACAT senaryosu**
> ve stok kartındaki `Stok Adı Y.Dışı` alanı bununla eşleşir (turkiye-uyumluluk §3).

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Satış/Alış faturası | `✓ (8.25)` | `Satış Yönetimi > İşlemler > Faturalar > Yurt İçi Satış Faturası` / `Satın Alma Yönetimi > İşlemler > Faturalar > Alış Faturası` | — |
| İrsaliye → faturalama | `≈` | `<Satış\|Satın Alma> Yönetimi > İşlemler > İrsaliyeler ▸` (alt öğeleri ekranda teyit et) | P6 · P28 |
| Depo transfer irsaliyesi | `≈` | `Stok Yönetimi > İşlemler > Depo İşlemleri ▸` (transfer burada; irsaliye tarafında değil) | P24 |
| Sipariş → irsaliye/fatura | `≈` | `<Satış\|Satın Alma> Yönetimi > İşlemler > Siparişler ▸` | P6 (belge zinciri) |
| Açık/kapanmamış sipariş | `≈` | `<Satış\|Satın Alma> Yönetimi > Raporlar >` (ana ekran kısayolu: **`Sipariş Raporu`**) | P6 · P13 |
| Teklif → sipariş | `≈` | `<Satış\|Satın Alma> Yönetimi > İşlemler > Teklifler ▸` | P28 (dönüşüm oranı) |
| Satın alma talebi (siparişin üst akışı) | `👤` | `Satın Alma Yönetimi > … > **Satın Alma Talep Ekranı**` (+ `Satın Alma Talep Listesi` > `Satın Alma` > `Satın Alma Emri Ver`) | native-index §14 |

## Kasa / Banka / Çek-Senet
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Kasa işlemleri | `✓ (8.25)` | `Finans Yönetimi > İşlemler > Kasa İşlemleri ▸` (tanım: `Tanımlar > Kasa Tanımları`) | — |
| Banka hesap/işlem | `✓ (8.25)` | `Finans Yönetimi > İşlemler > Banka İşlemleri ▸` (tanım: `Tanımlar > Banka Tanımları`) | — |
| Tahsilat / ödeme | `✓ (8.25)` | `Finans Yönetimi > İşlemler > **Tahsilatlar ▸** / **Tediyeler ▸**`. `👤`: bazı kurulumlarda alt öğe adı `Cari Ödeme` yerine **`Cari Tediye`** görünür — sürüme/kuruluma göre değişir | — |
| Çek/senet portföy & giriş | `✓ (8.25)` | `Finans Yönetimi > İşlemler > **Çek/Senet İşlemleri**` (teminat için ayrıca `Teminat Çeki/Senedi`, basım için `Seri Senet Basımı`) | P14 (`EVRAK_DURUMU`) |
| Vadesi gelen çek/senet | `✓ (8.25)` | `Finans Yönetimi > Raporlar > **Çek/Senet Raporları ▸**` | P9 |
| Döviz kuru girişi/takibi | `✓ (8.25)` | `Finans Yönetimi > Tanımlar > **Döviz Tanımları**`; hareket `İşlemler > Döviz İşlemleri ▸`; rapor `Raporlar > Döviz Raporları ▸` | `DOVIZ` tablosu (bayat kur tuzağı) |
| Banka kartı sekmeleri | `👤` | `Finans Yönetimi > Tanımlar > Banka Tanımları` > **`Alt Hesaplar`** · **`POS`** · **`Kredi Kartı`** · **`Çek`** (satır kaydı için sekmenin **küçük** `Kaydet`i, kart için alttaki **büyük** `Kaydet`) | native-index §14 |

## e-Dönüşüm  *(8'de ayrı üst menü YOK — belgenin altında yaşar)*
⚠️ **`e-Dönüşüm` diye bir üst menü yoktur.** e-Fatura, ilgili modülün fatura dalının içindedir:
`<Satış | Satın Alma> Yönetimi > İşlemler > Faturalar > **e-Fatura ▸**` `✓ (8.25)`

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Gönderilecek e-belgeler | `✓ (8.25)` | `… > Faturalar > e-Fatura > **e-Fatura Gönderimi**` | sorgu-recetesi C1 · P19 |
| Hatalı / askıda belge · GİB durumu | `✓ (8.25)` | `… > Faturalar > e-Fatura > **e-Fatura Durum Sorgula**` (gönderilenler: **`Gönderilmiş e-Faturalar`**). "Hatalı Belgeler" adlı ayrı ekran **yok** — askıdakileri durum sorgulama ile yakala (`FATURA.EFATURA_DURUM` / `EFATURA_GIB_DURUM` / `OTO_GONDERIM_HATA`) | sorgu-recetesi C2 · P19 |
| Entegratör portalına git | `✓ (8.25)` | `… > Faturalar > e-Fatura > **e-Fatura Portal**` | sorun-giderme §4 |
| Mükellef listesi · sertifika · kontör | `≈` | Hepsi **`e-Fatura Ayarları`** panelinin içinde aranmalı (ayrı menü öğeleri değil) | sorun-giderme §4 |
| e-İrsaliye | `≈` | `İrsaliyeler ▸` dalının altında aynı kalıpla ara (`8.25`'te teyit edilmedi) | P19 |
| **e-Fatura Ayarları paneli** (kurulum) | `✓ (8.25)` yol / `📹` içerik | Yol: `<Satış\|Satın Alma> Yönetimi > İşlemler > Faturalar > e-Fatura > **e-Fatura Ayarları**`. Başlıca kutular (`📹`, ekranda teyit et): ÖTV vergi kodu · fatura notunu e-belgeye ekle · şahısta unvanı Ad-Soyad'a aktar · alıcı adresini açık adrese aktar · gönderim sonrası fatura no güncelle (portal serisi farklıysa) · gönderim sonrası PDF'i Dosya'ya ekle · **kayıtta otomatik gönder (onaya bağlı)** · taslak olarak portala kaydet (EDM) · gönderim bilgisini fatura kartından al · kapalı fatura bilgisi ekle · MEIN (izibiz, e-arşiv) · döviz kuru (güncel/fatura kuru) · **gönderici posta kutusu** (şube başına) · cari kayıtta VKN/mail zorunlu · yazıyla genel toplam · irsaliye/sipariş bağlantı no gönder · cari bakiye/vade/tedarikçi kodu ekle · **fatura hareket sıralaması** | kurulum-playbook §1 · turkiye-uyumluluk §3-4 |

## Genel Muhasebe *(veri ayrı `_GMUHASEBE` DB'sinde — modülün kullanımını install'da doğrula, P5/P21)*
✅ **`8.25` saha teyidi, modül-ayrımı iddiasını doğruluyor:** ERP içinde Genel Muhasebe'nin yalnızca
**köprüsü** vardır; asıl uygulama **ayrı bir programdır** (menüden başlatılır) ve verisi ayrı DB'dedir.
Bu yüzden `_WOLVOX` DB'sine bakıp "muhasebe kullanılmıyor" demek **yanlış sonuçtur** (test #9).

**ERP'deki köprü `✓ (8.25)`:** `Diğer İşlemler > G.Muhasebe ▸`
→ `Hesap Planı Ara` · `Çek/Senet Hesap Kodları` · **`Entegrasyon Dosyası Oluştur`** · **`Genel Muhasebe`** (ayrı uygulamayı açar)

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| ERP → muhasebe aktarımı | `✓ (8.25)` | `Diğer İşlemler > G.Muhasebe > **Entegrasyon Dosyası Oluştur**` | sorun-giderme §5 |
| Hesap kodu arama (ERP içinden) | `✓ (8.25)` | `Diğer İşlemler > G.Muhasebe > `Hesap Planı Ara`` / `Çek/Senet Hesap Kodları` | — |
| Muhasebe entegrasyon ayarları | `✓ (8.25)` | `Yetkili > Tanımlar > Genel Ayarlar > **Genel Muhasebe**` | — |
| Stok/cari kartın muhasebe kodu | `✓ (8.25)` | Stok kartı > **`Muhasebe`** sekmesi (cari kartta da muadili) | P5 |
| Mizan · yevmiye · dönem sonu | `≈` | **Ayrı Genel Muhasebe uygulamasında** (`Diğer İşlemler > G.Muhasebe > Genel Muhasebe` ile aç) | P5 · P11 |

## Üretim / Reçete *(edisyona bağlı — yoksa üst menüde hiç görünmez)*
⚠️ `8.25` saha koşusundaki sektörel pakette **Üretim üst menüsü yoktu**. Üretim modülünün varlığı
**edisyona göre değişir**; "Üretim > …" yolunu vermeden önce kullanıcının menüsünde olup olmadığını sor.
| İşlem | Güv. | Yol |
|---|---|---|
| Reçete (ürün ağacı/BOM) | `≈` | `Üretim > Reçete Tanımları` (modül varsa) |
| Üretim emri | `≈` | `Üretim > Üretim Emirleri` (modül varsa) |

## Kampanya / Sadakat *(kullanılmayan "goldmine" — skill 5A)*
⚠️ `8.25`'te `Kampanya`/`Sadakat` adlı ayrı menü **görülmedi**. Bu paketteki gerçek karşılıkları
**iskonto/fiyat motorları**dır — kampanya sorusunda önce bunları göster:
| İşlem | Güv. | Yol |
|---|---|---|
| Kural-tabanlı fiyat/iskonto (kampanya muadili) | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Genel > **Gelişmiş Satış Fiyatı Sistemi** / **Gelişmiş İskonto Sistemi**` (+ miktar aralığına göre iskonto) |
| Müşteriye özel iskonto/fiyat listesi | `📹` | Cari kartı > `Hesap Bilgileri` > özel iskonto % + fiyat no |
| Kart bazlı iskonto | `✓ (8.25)` | Stok kartı > `Özel Ayarlar 1` > Alış/Satış İskontoları |
| Kampanya/promosyon · sadakat/puan modülü | `≈` | Bu pakette **yok**; edisyona bağlı — kullanıcının menüsünde ara |
| **Bonus (sadakat) tanımları** | `👤` | `Finans Yönetimi > Tanımlar > **Bonus Tanımları**` — `8.25` saha listesinde görülmedi, edisyona bağlı olabilir (native-index §4) |
| Bonus sistemi anahtarı + matrah + ödeme türü | `👤` | `Yetkili > Tanımlar > Genel Ayarlar > **Cari Ayarları > Cari Kart Ayarları**` > `Bonus Sistemi Kullan` · fatura bonus matrahı · bonus ödeme türü (native-index §4) |

## Yetkili (yönetim · ayarlar · KVKK · log)
Dal yapısı `✓ (8.25)` — **`Yönetim` / `Ayarlar` adlı bir üst menü yoktur, hepsi `Yetkili` altındadır:**
`Oturumu Kapat` · **`Şirket Seçimi` (Shift+F1)** · **`SQL Monitör`** · **`Sistem Logları`** ·
**`Anonimleştirme ▸`** · `Tanımlar ▸` · `Sayaç İşlemleri ▸` · **`Veri Değişim Log ▸`** ·
`Özel Tanımlar ▸` · `Personel Kontrol ▸` · **`Aktif Tabloda Ara` (Ctrl+Alt+F)** · `Aktif Nesne İsmini Göster`

> 🛠️ `Aktif Nesne İsmini Göster` + `SQL Monitör` = **şema keşfinin UI kestirmesi**: ekrandaki alanın
> hangi tabloya/kolona bastığını canlı gösterir. "Bu alan DB'de ne?" sorusunda `INFORMATION_SCHEMA`
> taramasından önce bunu kullandır (kolon uydurmaya karşı en iyi panzehir).

| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| **① Genel Ayarlar** (veri/varsayılan kuralları) | `✓ (8.25)` | **`Yetkili > Tanımlar > Genel Ayarlar`** → sol ağaç: `Cari Ayarları` · `Kasa Hareket Ayarları` · `Stok Ayarları` · `Fatura Ayarları` · `İrsaliye Ayarları` · `Teklif Ayarları` · `Sipariş Ayarları` · `Çek/Senet Ayarları` · `Banka Hareket Ayarları` · `Genel Muhasebe` · `Parasal Ayarlar` · `Program Ayarları`. Butonlar: `Kaydet` / `Vazgeç` / `Kapat` | — |
| — ① Fatura Ayarları sekmeleri | `✓ (8.25)` | `Satış Faturası` · `Alış Faturası` · `Fatura Sabitleri` · `Ek Kesintiler` · `Masraf Faturası` (varsayılan iskonto/KDV/vade/döviz/numaralandırma) | — |
| — ① Stok Ayarları sekmeleri | `✓ (8.25)` | `Stok Kart Ayarları` · `Stok Hareket Ayarları` · `Genel` | — |
| — ① Cari Ayarları sekmeleri | `✓ (8.25)` | `Cari Kart Ayarları` · `Cari Hareket Ayarları` (alt sayfa 1/2) | — |
| Seri/Lot izleme tipi + maliyet eşleştirme | `👤` | `Yetkili > Tanımlar > Genel Ayarlar > **Stok Ayarları > Seri/Lot**` > İzleme Tipi · **Maliyetlerde eşleştirme yöntemini kullan** · zorunlu seri/lot girişi · satışta SKT kontrolü | native-index §2 |
| Sipariş stok rezervasyonu | `👤` | `Yetkili > Tanımlar > Genel Ayarlar > **Sipariş Ayarları** > Stok Bloke` (varsayılan `Hayır`) → `SIPARIS.STOK_BLOKE` | native-index §3 |
| Cari limit kontrolleri (fiilen bloke etme) | `👤` | `Yetkili > Tanımlar > Genel Ayarlar > **Cari Ayarları > Cari Hareket Ayarları**` > limit aşımına izin verme · ciro edilen çek/senet kuralı + opsiyon gün · vadesinde ödenmeyen bakiye kontrolü + tolerans günü | native-index §4 |
| Fatura numarası/açıklama otomasyonu | `👤` | `Yetkili > Tanımlar > Genel Ayarlar > **Fatura Ayarları**` > `fatura numarasını otomatik ver` · açıklama `otomatik oluştur` | native-index §3 |
| **② Özel Ayarlar** (modül davranış anahtarları) | `✓ (8.25)` | **`Yetkili > Özel Tanımlar > Özel Ayarlar`** → sol ağaç: `Genel Ayarlar` · **`Performans Ayarları`** · `Cari Ayarları` · `Stok Ayarları` · **`Depo Ayarları`** · `Çek/Senet Ayarları` · **`Fatura Ayarları`** · `İrsaliye Ayarları` · `Teklif Ayarları` · `Sipariş Ayarları` · `Banka Ayarları` · **`Caller ID`** · **`Sanal Santral`**. Butonlar: **`Değişiklikleri Kaydet`** / **`Kaydetmeden Kapat`** (bu ikili, hangi ağaçta olduğunun en hızlı işareti) | **ozel-ayarlar.md (tam katalog)** |
| — ② Fatura Ayarları sekmeleri | `✓ (8.25)` | `Satış Faturası` · **`Alış Faturası`** (← reprice tetiği burada) · `Fatura Genel` · `Masraf Faturası` | ozel-ayarlar §4 |
| — ② Genel Ayarlar sayfası | `✓ (8.25)` | Program Tanımı · mesaj tipi · form başlığı/tema · uyarı penceresi (yenileme aralığı, uyarı sesi) · `Açılışta Yönetici Ekranını Göster` · pencere gösterimi · **Otomatik Sürüm Kontrol** · PDF otomatik adlandırma · POP3 · "stok fiyatı para birimi" · "barkod/stok kodu aramasında pasif stokları dahil et" · "tarih değişince döviz kurlarını yeniden aktar" | ozel-ayarlar §1 |
| — ② Stok Ayarları sayfası | `✓ (8.25)` | Stok listesi yazdırma/Excel şifresi · paket tanımları (miktar sor, sıralama) · **Hızlı Satış miktar çarpan karakteri** · hızlı stok tanımından sonra miktar sor · "yeni stok kartı oluşturma penceresi" | ozel-ayarlar §2 |
| **KVKK anonimleştirme (yerleşik!)** | `✓ (8.25)` | `Yetkili > **Anonimleştirme** ▸` → `Anonimleştirme İşlemleri` · `Anonimleştirme Kayıt` · `Anonimleştirme Raporu`. Ham `DELETE` yerine **daima bu** (test #18); işlem geri alınamaz, önce yedek | turkiye-uyumluluk (KVKK) |
| **Veri değişim denetim izi** | `✓ (8.25)` | `Yetkili > **Veri Değişim Log** ▸` (+ `Sistem Logları`). "Bu kaydı kim değiştirdi?" sorusunun native cevabı | P18 |
| Zorunlu alan / veri kalitesi dayatma | `✓ (8.25)` | `Yetkili > Tanımlar > **Zorunlu Alanlar**` — boş VKN/grup kodu gibi kalite sorunlarını **kaynağında** kapatır (SQL ile temizlemekten önce bunu öner) | P29 · veri kalitesi |
| **Uyarı / hatırlatıcı otomasyonu** (kullanılmayan hazine) | `✓ (8.25)` | `Yetkili > Tanımlar > **Uyarıcı/Hatırlatıcı Ayarları**` | skill 5A |
| Belge onay akışı | `✓ (8.25)` | `Yetkili > Tanımlar > **Belge Onay Tanımları**` | P18 |
| Hesaplanan alan / formül | `✓ (8.25)` | `Yetkili > Tanımlar > **Formül Tanımları**` | — |
| Ekran metinlerini özelleştir | `✓ (8.25)` | `Yetkili > Tanımlar > `Metin Özelleştirme`` (+ `Ülke Tanımları`) | — |
| Şirket / çalışma yılı değiştir | `✓ (8.25)` | `Yetkili > **Şirket Seçimi** (Shift+F1)` — aktif şirket & yıl üst şeritte `Şirket : <yıl> - <ad> (<kod>)` olarak görünür (çalışma yılı teyidi buradan) | Devir · P21 |
| Kullanıcı / yetki / personel | `≈` | `Yetkili > `Personel Kontrol ▸`` ve `Sayaç İşlemleri ▸`; kullanıcı yönetimi **Kontrol Paneli**'nde olabilir | P18 |
| Terminal / varsayılan depo | `✓ (8.25)` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > `Varsayılan Depo`` (+ kart bazında `Özel Ayarlar 1 > Geçerli Depo`) | skill 5D |
| Excel'e/den aktarım · SMS · özel rapor | `✓ (8.25)` | `Diğer İşlemler > `Excel Transfer ▸` / `SMS ▸` / `Özel Raporlar ▸` / `Notlar ▸`` | P7 |
| Yardımcı araçlar | `✓ (8.25)` | `Diğer İşlemler > Araçlar ▸`: Telefon-Adres · Caller ID Arama Listesi · Takvim · Araçlar Menüsünü Düzenle · **WordMaker (F10)** · Saat (F11) · Hesap Makinesi (F12) · Dil Editörü | — |
| Yıl sonu / devir (otomatik) | `📹` | `Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri` → çalışma yılı seç → ileri (stok/kart/ödenecek kartlar dahil et) → devre başla (hedef tarihe kadar). Yeni yıl DB'sinde `Muhasebe > Fiş İşlemleri > Açılış Fişini Oluştur` | kurulum-playbook §3 · sorun-giderme §6 · P21 |
| Dönem sonu (muhasebe kapanış) | `📹` | `Genel Muhasebe > Dönem Sonu İşlemleri`: 7A/7B yansıtma (632 %100) → maliyet fişi (envanter → 621) → kar/zarar (690→590) → **kapanış fişini oluştur** | kurulum-playbook §3 · P5 |
| Yedekleme | `≈` | ERP menüsünde **yok** (`8.25` teyidi) → ayrı **Kontrol Paneli** uygulaması (`Veri Tabanı İşlemleri`) | — |
| Otomatik görev/e-posta planlayıcı | `≈` | ERP'de bu adla **yok**; yerine `Yetkili > Tanımlar > **Uyarıcı/Hatırlatıcı Ayarları**` ve `Finans > Raporlar > Analizler > Finansal Analiz > **Otomatik Talimat Kontrol**` | skill 5A |

---

## Oto-altyazı sözlüğü (`👤` bayi videolarını okurken)
> 🔤 Bu kampanyada (niş/bayi YouTube kaynakları) tekrar eden oto-altyazı bozulmaları — bir bayi
> videosundan yol çıkarırken bu listeyi kontrol et, kanonik adı kullan:
> `Fatura Yerleri` → **Fatura Ayarları** · `volvoks / wallwox / bolbox` → **Wolvox** ·
> `stop / sok / soku` → **stok** ·
> `kek / koça` → **çek / koçan** · `incir ulanan` → **ciro edilen** · `Atlas/akla (terazi)` → **Aclas** ·
> `telep/telef` → **talep**.

## Bilinen 8 vs 9 farkları (genel bilgi — kurulumda teyit et)
> Bunlar ürün-genel gözlemlerdir, sürüm-teyitli değildir; kullanıcının ekranıyla doğrula.
- **e-Dönüşüm** 9'da ayrı, olgun bir üst modül; 8'de daha dağınık/eklenti hissi verebilir.
- **Menü sözcükleri:** "Yönetici/Yönetim", "Ayarlar/Seçenekler", "Toplu Güncelleme" konumu sürümler
  arası kayar. Yol bulunamazsa **arama/hızlı erişim** kutusunu kullandır.
- **Toplu Fiyat Güncelleme** ekranının seçenek zenginliği 9'da daha fazladır (marj/çarpan/yuvarlama).
- **Rapor ağacı** 9'da yeniden düzenlenmiştir; "Raporlar >" altındaki alt-başlıklar 8'den farklı olabilir.
- Kolon **adları (DB)** iki sürümde büyük ölçüde aynı; asıl değişiklik **UI etiketleri ve menü konumu**.

## Nasıl `✓`'a yükseltilir (damıtma yöntemi)
1. **Seçici ol.** Değerin ~%80'i ~25-30 temel akıştadır: Stok, Fatura, Cari, e-Dönüşüm, Muhasebe,
   Sipariş, Dönem/Devir.
2. **Yapılandırılmış çıkar:** *işlem adı → tam menü yolu → ayar/kutu adı → hangi sürümde görüldü*.
3. **Teyit kaynağı:** canlı ekran / resmî yardım / eğitim; satırı `≈`→`📹`→`✓` yükselt, sürüm etiketle (8/9).
4. Kaynağı dipnotla (izlenebilirlik). Doğrulanmadan `✓` koyma — dürüstlük etiketinin anlamı budur.

---

## Kaynaklar (`📹` satırların izlenebilirliği)
Aşağıdaki `📹` satırlar **resmî AKINSOFT eğitim videolarından** (Wolvox 8) damıtıldı. Akış/sekme
yapısı kaynak-teyitli; etiket sözcükleri oto-altyazı kaynaklı olduğundan ekranda son teyidi yapın.
- **Stok Tanımları** (Genel Bilgiler / Birim-Barkod / Fiyatlar / İstatistikler / Özel Tanımlar / Devir Girişi) — "Akınsoft Wolvox 8'de Stoklar Nasıl Tanımlanır?"
- **Stok > Fiyatlar sekmesi + reprice tetiği** (Özel Ayarlar > Fatura Ayarları > Alış Faturası) — "Stok Kartı Fiyatlar Sekmesi"
- **Cari Tanımları** (tüm sekmeler + Devir Girişi + Yeni İşlem/Kopyala) — "Akınsoft Wolvox 8'de Cari Nasıl Tanımlanır?"
- **e-Fatura Ayarları paneli** — "AKINSOFT Wolvox ERP — e-Fatura Ayarları"
- **Yıl sonu/devir + dönem sonu** — "Akınsoft Dönem Sonu İşlemleri" (Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri)
- **Özel Ayarlar serisi** (Genel/Stok/Cari/Fatura/İrsaliye/Sipariş/Teklif/Çek-Senet/Üretim/Depo) — resmî "AKINSOFT Wolvox Erp — Özel Ayarlar" video serisi → tam katalog [ozel-ayarlar.md](ozel-ayarlar.md). **Düzeltme:** reprice tetiğinin doğru yolu `Özel Ayarlar > **Fatura Ayarları** > Alış Faturası` (önceki bayi-videosu "Fatura Yerleri" yaklaşık adıydı).

> Not: video kimlikleri/URL'leri **repoya değil**, danışmanın özel notlarına yazılır (repo genel kalır).

---

## Saha koşusu kaydı (`✓` satırların izlenebilirliği)

**25.07.2026 — 1. saha koşusu.** Ortam: **Wolvox 8 ERP s8.25.23**, sektörel paket (otomotiv),
tek şirket/tek çalışma yılı. Yöntem: **salt-okunur ekran gezintisi** — menü ağaçları açıldı, Stok
Tanımları boş kayıt üzerinde sekmeler gezildi, her iki ayar penceresi okundu. **Hiçbir kayıt
açılmadı/değiştirilmedi, hiçbir onay kutusu tıklanmadı; `Genel Ayarlar`da `Kaydet` hiç aktifleşmedi,
`Özel Ayarlar` `Kaydetmeden Kapat` ile kapatıldı.** Şirket/kullanıcı adı ve hiçbir iş verisi bu
dosyaya yazılmadı (gizlilik testi #14).

> 🎓 **Koşunun kendi metodoloji dersi:** "ilgili ekranda ayar yok" sonucuna, **yalnızca bir ayar
> ağacına ve o ağacın kendi aramasına** bakarak varıldı → yanlış çıktı. Kullanıcı ikinci ağacı
> gösterdi. **Kural: bir native özelliğin yokluğunu ilan etmek için tek ekran/tek arama yetmez;**
> eş adlı ikinci bir ayar ağacı, edisyon farkı veya farklı menü dalı olabilir. Yokluk iddiası,
> varlık iddiasından **daha fazla** kanıt ister — emin olamıyorsan "bulamadım, birlikte teyit
> edelim" de, "yok" deme.

`📹`→`✓` yükseltilenler ve **düzeltilen yanlışlar**:
| Konu | Eski (yanlış) | Yeni `✓ (8.25)` |
|---|---|---|
| Üst menü | `Fatura`/`İrsaliye`/`Sipariş`/`Kasa`/`Çek-Senet`/`e-Dönüşüm`/`Raporlar`/`Yönetim` | 8 menü: Stok/Satın Alma/Satış/Finans Yönetimi · Diğer İşlemler · Yetkili · Pencere · Yardım |
| Ayar ağacı | `Özel Ayarlar > …` (yolun başı eksik) | **İki ağaç:** `Yetkili > Özel Tanımlar > **Özel Ayarlar**` (davranış) **ve** `Yetkili > Tanımlar > **Genel Ayarlar**` (veri/varsayılan). Skill'in yolları ①. ağaca aitti ve **doğruydu** |
| Stok kartı yolu | `Stok Yönetimi > Stok Tanımları` | `Stok Yönetimi > **Tanımlar** > Stok Tanımları` |
| Özel Kod 1/2/3 | `Özel Tanımlar` sekmesi | **`Genel Bilgiler`** sekmesi |
| Min/Max stok | kart > `Detay/Sipariş` sekmesi | **`Depo`** sekmesi, **depo satırı bazında** |
| Ölü stok raporu | `Raporlar > Stok > Hareket Görmeyen Stoklar` | `Stok Yönetimi > Raporlar > Analizler > **İşlem Görmeyen Stoklar**` |
| Hareketsiz cari | `Raporlar > Cari > Hareketsiz Cariler` | `Finans > Raporlar > Bakiye Raporları > **Hareketli Bakiyeler Listesi**` |
| e-Fatura | ayrı `e-Dönüşüm` menüsü | `… > Faturalar > **e-Fatura ▸**` (Gönderimi · Durum Sorgula · Gönderilmiş · Portal · Ayarları) |
| Reprice tetiği | `Özel Ayarlar > Fatura Ayarları > Alış Faturası > "satış fiyatları oluşturma penceresini göster"` | ✅ **Aynen doğrulandı** (tam yol: `Yetkili > Özel Tanımlar > Özel Ayarlar > …`), üç alt seçeneğiyle birlikte |
| KVKK silme | (yol yoktu) | `Yetkili > **Anonimleştirme ▸**` (İşlemleri/Kayıt/Raporu) |

Koşuda **yeni keşfedilen, skill'de hiç geçmeyen** yetenekler (hepsi native, `STEP 0` için değerli):
`Gelişmiş Satış Fiyatı Sistemi` (puanlamalı fiyat motoru) · `Gelişmiş İskonto Sistemi` ·
`Stok Fiyat Loglama` · `Otomatik Sipariş Oluştur` (min-stok tetikli) · `Zorunlu Alanlar` ·
`Belge Onay Tanımları` · `Formül Tanımları` · `Uyarıcı/Hatırlatıcı Ayarları` · `Veri Değişim Log` ·
`SQL Monitör` + `Aktif Nesne İsmini Göster` (canlı şema keşfi) · `Yönetici/Şube İzleme Ekranı` ·
`Cari Tanım Birleştirme` / `Stok Tanım Birleştirme` (mükerrer kart temizliği) · `Muadil Alış Fiyatı`.

**Sonraki koşuda kapatılacak boşluklar:** Cari Tanımları sekmeleri · İrsaliye/Sipariş/Teklif alt
menüleri · **`Özel Ayarlar` ağacının kalan grupları** (Performans · Cari · Depo · Çek-Senet ·
İrsaliye · Teklif · Sipariş · Banka) · `Genel Ayarlar`ın kalan grupları (İrsaliye/Sipariş/Teklif/
Çek-Senet/Banka/Parasal/Program) · Kontrol Paneli (yedek + devir) · ayrı Genel Muhasebe uygulaması.
