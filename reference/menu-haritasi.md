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
> - **`✓`** — belirli bir sürümde (8/9) **saha/canlı ekran teyitli**. **Şu an dosyada `✓` YOK** — hiçbir
>   yol henüz danışmanın kendi canlı ekranında doğrulanmadı; doğruladıkça `📹`/`≈`→`✓` yükselt ve sürüm etiketle.
>
> ⚠️ Menü metinleri **sürüme (8 vs 9) ve edisyona göre değişir**. Emin olmadığın metni kesin verme;
> işareti koru ve kullanıcıdan ekranı teyit etmesini iste. UI yolu uydurmak, kolon uydurmak kadar hatalıdır.
>
> 🔎 **Hızlı erişim refleksi (📹 teyitli):** Wolvox 8'de ana ekranda **arama kutusuna işlem adını yaz**
> (örn. "stok tanımları") → menü doğrudan açılır; sağ tuş → **"Hızlı Erişime Ekle"** ile ana ekrana
> kısayol iğnelenir. Yol bulunamadığında ilk çare budur — kullanıcıya bunu öğret.

---

## Üst menü yapısı (tipik)
`Stok · Cari · Fatura · İrsaliye · Sipariş · Teklif · Kasa · Banka · Çek/Senet · Üretim ·
Genel Muhasebe · e-Dönüşüm · Raporlar · Servis · Yönetim/Ayarlar`

> **8 vs 9 kaba fark:** Wolvox 9'da üst şerit daha modül-sekmeli; e-Dönüşüm 9'da daha görünür/olgun.
> Menü **adları** değişebilir ("Yönetici" ↔ "Yönetim", "Ayarlar" ↔ "Seçenekler"). Aşağıdaki yollar
> 8 temelli; 9'da en yakın karşılığı ara.

---

## Stok
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Stok kartı aç/düzenle | `📹` | `Stok Yönetimi > Stok Tanımları` (ya da ana ekran arama kutusu → "stok tanımları") | — |
| — Genel Bilgiler sekmesi | `📹` | Ürün adı · yurtdışı adı (ihracat/İngilizce) · stok kodu (boşsa oto-kod) · barkod (tip: EAN13 varsayılan) · grup/ara/alt grup (önce Grup Tanımları) · açıklama (~1000 krk) · **3 KDV alanı** (alış · satış perakende · satış toptan) · ÖTV/ÖİV · istisna & tevkifat kodu (büyüteç) · döviz kullan+birim · pazarlamacı prim | turkiye-uyumluluk §1-2 |
| — Birim/Barkod sekmesi (çoklu birim) | `📹` | Birim (adet/koli/kg/lt) · birden çok barkod · **çoklu birim + katsayı** (koli=15 → faturada oto ×15) | — |
| — Fiyatlar sekmesi | `📹` | `Varsayılan tanımları aktar` → 4 satış + 4 alış fiyatı (toptan/perakende/e-tic.) · döviz seçimi (TL/USD/EUR) · sınırsız fiyat (`Fiyat Tanımları`) · **yeşil tik = yalnız satış fiyatını kaydet** | sorgu-recetesi §H · P4 |
| — İstatistikler sekmesi (**son alış!**) | `📹` | `İstatistikleri hesapla` → son alış · ortalama alış · en ucuz/en pahalı alış (TL/USD/EUR) — reprice "son alış" kaynağı | sorgu-recetesi §H · P8 |
| — Özel Tanımlar (kullanıcı alanı, örn. SKT) | `📹` | `Özel Tanımlar > Ayar > +` ile alan aç (tarih/metin) → filtre/fatura/tasarım/raporda kullanılır (DB'ye yazılır) | P26 |
| — Stok Durumu > **Devir Girişi** (açılış sayımı) | `📹` | Hareket yokken eldeki miktarı Stok Durumu sekmesinde `Devir Girişi` ile gir | sorun-giderme §2 · P21 |
| **Reprice tetiği:** alışta satış fiyatını yeniden oluştur | `📹` | `Özel Ayarlar > Fatura Ayarları > Alış Faturası > "Satış fiyatları oluşturma penceresini göster"` (+ alış fiyatına KDV ekle · ek maliyet ekle · yeniden oluşturulacak satış fiyat sayısı) → alış kaydında "satış fiyatları yeniden oluşturulsun mu?" sorulur | ozel-ayarlar §4 · sorgu-recetesi §H · P1 · tools/reprice-preview.ps1 |
| Reprice tetiği (üretim maliyetinden) | `📹` | `Özel Ayarlar > Üretim Ayarları > "Satış fiyatları oluşturma penceresi"` (+ birim maliyete KDV ekle) | ozel-ayarlar §9 |
| Toplu fiyat güncelleme | `≈` | `Stok > Toplu Güncelleme / Toplu Fiyat Güncelleme` | sorgu-recetesi §H3 (UI tercih) · P17 |
| **Özel Kod atama (alt-küme işaretle)** | `📹` | Stok kartı > `Özel Tanımlar`/`Özel Kodlar` (`OZEL_KODU1/2/3`); toplu için `Stok > Toplu Güncelleme` | sorgu-recetesi §H1 · P3 |
| Otomatik barkod ayarı | `≈` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > (barkod/sayaç)` | — |
| Birim fiyat hassasiyeti (yuvarlama basamağı) | `📹` | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > Birim fiyat hassasiyeti` (e-belge yuvarlamasını da etkiler) | turkiye-uyumluluk §5 |
| Min/Max stok seviyesi | `≈` | Stok kartı > `Detay / Sipariş` sekmesi (`MIKTAR_MINIMUM/MAXIMUM`) | skill 5A · P13 |
| Sayım / envanter | `≈` | `Stok > Sayım` veya `Stok > Envanter` | sorun-giderme §2 |
| Depo tanımları | `≈` | `Yönetim > Tanımlar > Depolar` | — |
| Grup/ara/alt grup tanımı | `≈` | `Yönetim > Tanımlar > Stok Grupları` | P24 (grupsuz kart) |
| Ölü / hareket görmeyen stok raporu | `≈` | `Raporlar > Stok > Hareket Görmeyen Stoklar` | sorgu-recetesi (ölü stok) · P10 |
| Mükerrer barkod tespiti | `≈` | *(native rapor belirsiz)* → SQL ile ver | P12 |
| Fiyat değişim geçmişi | `≈` | Stok kartı > `Fiyat Geçmişi` / `Raporlar > Stok > Fiyat Değişim` | P18 (denetim izi) |

## Cari
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Cari kartı aç/düzenle | `📹` | `Finans Yönetimi > Cari Tanımları` (ya da ana ekran arama kutusu) | — |
| — Genel Bilgiler sekmesi | `📹` | Ticari unvan (şahısta ad-soyad) · adres · **ülke/il/ilçe listeden seç** (e-Fatura için kritik) · grup/ara/alt grup · telefon · vergi dairesi · **vergi no (10 hane) / TC (11 hane)** — biri dolu diğeri boş · unvan/vkn'de **boşluk bırakma** (yanlış e-fatura cezası) | turkiye-uyumluluk §3 · P29 |
| — Hesap Bilgileri sekmesi | `📹` | Yönetici **not/mesaj metni** (her modülde uyarı çıkar — "durdur müşteri") · **kamu kurumu** işareti · e-irsaliye devreye al · döviz sistem hesabı · **özel iskonto %** · **fiyat no seç** (örn. 6 → hep 6. fiyattan sat) | P4 · P30 |
| — Yetkililer sekmesi | `📹` | Kişi · dahili · görev · departman · cep → toplu SMS / mutabakat mektubu bu kişilere gider | P7 |
| — Özel Bilgiler sekmesi | `📹` | Banka · e-posta · **Rota grubu/sıra/kod** (sıcak satış saha) · **fatura adresi ≠ sevk adresi** · pazarlamacı sistemini kullan (+şifre) | — |
| — Bakiye/Kredi sekmesi > **Devir Girişi** | `📹` | Açılış bakiyesi (borç/alacak) devir girişiyle işlenir (vergi no zorunlu) | sorun-giderme §6 · P21 |
| — Üst menü: Yeni İşlem / Kopyala | `📹` | `Yeni İşlem` → fatura/teklif/sipariş/servis/tahsilat/ödeme · `İşlemler > Kopyala` (kartı çoğalt) · `Dosya` sekmesi (**Cari II** modülü) | — |
| Ekstre / hesap özeti | `≈` | `Cari > Ekstre` | sorun-giderme §3 · P7 |
| Yaşlandırma (vade analizi) | `≈` | `Raporlar > Cari > Yaşlandırma` | P9 |
| Risk/limit ayarı | `📹` | Cari kartı > `Hesap Bilgileri` (risk/mesaj metni) | — |
| Toplu cari işlem | `≈` | `Cari > Toplu Güncelleme` | P17 |
| 90+ gün hareketsiz cari | `≈` | `Raporlar > Cari > Hareketsiz Cariler` | skill 5C (PII maskeli) · P15 |
| Atanan fiyat listesi | `📹` | Cari kartı > `Hesap Bilgileri` > fiyat no (`STOK_FIYATI` = FIYAT_NO) | P4 (müşteri-doğru fiyat) |

## Fatura / İrsaliye / Sipariş / Teklif
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Satış/Alış faturası | `≈` | `Fatura > Satış Faturası` / `Alış Faturası` | — |
| İrsaliye → faturalama | `≈` | `İrsaliye > Faturalanacak İrsaliyeler` | P6 · P28 |
| Depo transfer irsaliyesi | `≈` | `İrsaliye > Depolar Arası Transfer` | P24 |
| Sipariş → irsaliye/fatura | `≈` | `Sipariş > Sipariş Karşılama` | P6 (belge zinciri) |
| Açık/kapanmamış sipariş | `≈` | `Raporlar > Sipariş > Açık Siparişler` | P6 · P13 |
| Teklif → sipariş | `≈` | `Teklif > Teklif Yönetimi` | P28 (dönüşüm oranı) |

## Kasa / Banka / Çek-Senet
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Kasa işlemleri | `≈` | `Kasa > Kasa Hareketleri` | — |
| Banka hesap/işlem | `≈` | `Banka > Banka Hareketleri` | — |
| Çek/senet portföy | `≈` | `Çek/Senet > Portföy` | P14 (`EVRAK_DURUMU`) |
| Çek/senet giriş (müşteri) | `≈` | `Çek/Senet > Müşteri Çeki/Senedi Girişi` | — |
| Vadesi gelen çek/senet | `≈` | `Raporlar > Çek/Senet > Vade Takip` | P9 |

## e-Dönüşüm  *(9'da daha olgun/görünür)*
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Gönderilecek e-belgeler | `≈` | `e-Dönüşüm > e-Fatura/e-Arşiv > Gönderilecekler` | sorgu-recetesi C1 · P19 |
| Hatalı / askıda belgeler | `≈` | `e-Dönüşüm > Hatalı Belgeler` | sorgu-recetesi C2 · P19 |
| Mükellef listesi güncelle | `≈` | `e-Dönüşüm > Ayarlar > Mükellef Listesi` | sorun-giderme §4 |
| Sertifika / entegratör ayarı | `≈` | `e-Dönüşüm > Ayarlar > Entegratör / Mali Mühür` | sorun-giderme §4 |
| e-İrsaliye | `≈` | `e-Dönüşüm > e-İrsaliye` | P19 |
| Kontör/kontör takibi | `≈` | `e-Dönüşüm > Ayarlar > Kontör` | sorun-giderme §4 |
| **e-Fatura Ayarları paneli** (kurulum) | `📹` | `e-Dönüşüm > e-Fatura Ayarları` — başlıca kutular: ÖTV vergi kodu · fatura notunu e-belgeye ekle · şahısta unvanı Ad-Soyad'a aktar · alıcı adresini açık adrese aktar · gönderim sonrası fatura no güncelle (portal serisi farklıysa) · gönderim sonrası PDF'i Dosya'ya ekle · **kayıtta otomatik gönder (onaya bağlı)** · taslak olarak portala kaydet (EDM) · gönderim bilgisini fatura kartından al · kapalı fatura bilgisi ekle · MEIN (izibiz, e-arşiv) · döviz kuru (güncel/fatura kuru) · **gönderici posta kutusu** (şube başına) · cari kayıtta VKN/mail zorunlu · yazıyla genel toplam · irsaliye/sipariş bağlantı no gönder · cari bakiye/vade/tedarikçi kodu ekle · **fatura hareket sıralaması** | kurulum-playbook §1 · turkiye-uyumluluk §3-4 |

## Genel Muhasebe *(veri ayrı `_GMUHASEBE` DB'sinde — modülün kullanımını install'da doğrula, P5/P21)*
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Muhasebeleştirme (entegrasyon) | `≈` | `Genel Muhasebe > Entegrasyon > Muhasebeleştirme` | sorun-giderme §5 |
| Mizan / Kesin Mizan | `≈` | `Genel Muhasebe > Raporlar > Mizan` | P5 · P11 |
| Hesap planı | `≈` | `Genel Muhasebe > Hesap Planı` | — |
| Entegrasyon şablonları | `≈` | `Genel Muhasebe > Entegrasyon > Şablonlar` | — |

## Üretim / Reçete *(kullanılmıyorsa atla)*
| İşlem | Güv. | Yol |
|---|---|---|
| Reçete (ürün ağacı/BOM) | `≈` | `Üretim > Reçete Tanımları` |
| Üretim emri | `≈` | `Üretim > Üretim Emirleri` |

## Kampanya / Sadakat *(kullanılmayan "goldmine" — skill 5A)*
| İşlem | Güv. | Yol |
|---|---|---|
| Kampanya/promosyon tanımı | `≈` | `Yönetim > Tanımlar > Kampanyalar` veya `Satış > Kampanya` |
| Sadakat/puan | `≈` | `Yönetim > Ayarlar > Sadakat/Puan` |

## Yönetim / Ayarlar / Dönem
| İşlem | Güv. | Yol | İlgili reçete/desen |
|---|---|---|---|
| Genel ayarlar | `📹` | `Özel Ayarlar > Genel Ayarlar` (başlık, döviz varsayılanı, pasif-stok arama, kur yeniden-aktar, sürüm kontrolü…) | ozel-ayarlar §1 |
| **Özel Ayarlar ağacı (davranış anahtarları)** | `📹` | `Özel Ayarlar > {Genel·Stok·Cari·Fatura·İrsaliye·Sipariş·Teklif·Çek-Senet·Üretim·Depo·…}` — modül davranışını yöneten tüm toggle'lar | **ozel-ayarlar.md (tam katalog)** |
| Kullanıcı / yetki | `≈` | `Yönetim > Kullanıcı Yönetimi` | P18 |
| Terminal / varsayılan depo | `≈` | `Yönetim > Ayarlar > Kullanıcı/Terminal Ayarları` | skill 5D |
| Yıl sonu / devir (otomatik) | `📹` | `Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri` → çalışma yılı seç → ileri (stok/kart/ödenecek kartlar dahil et) → devre başla (hedef tarihe kadar). Yeni yıl DB'sinde `Muhasebe > Fiş İşlemleri > Açılış Fişini Oluştur` | kurulum-playbook §3 · sorun-giderme §6 · P21 |
| Dönem sonu (muhasebe kapanış) | `📹` | `Genel Muhasebe > Dönem Sonu İşlemleri`: 7A/7B yansıtma (632 %100) → maliyet fişi (envanter → 621) → kar/zarar (690→590) → **kapanış fişini oluştur** | kurulum-playbook §3 · P5 |
| Yedekleme | `≈` | `Yönetim > Yedekleme` | — |
| Otomatik görev/e-posta planlayıcı | `≈` | `Yönetim > Ayarlar > Görev/Bildirim Planlayıcı` | skill 5A |

---

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
