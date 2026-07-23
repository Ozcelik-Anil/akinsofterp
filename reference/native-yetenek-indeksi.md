# Wolvox 8/9 — Native Yetenek İndeksi (iş-ihtiyacı → yerleşik özellik)

> **Bu dosyanın işi: "önce native" refleksinin arama tablosu olmak.** Bir kullanıcı bir şey
> yapmak/otomatikleştirmek/düzeltmek istediğinde, SQL veya betik önermeden **ÖNCE burada ara**:
> Wolvox'un bunu zaten yapan bir yerleşik özelliği/ayarı/raporu var mı? Varsa onu ver.
>
> **Doktrin — "native-first ama dürüst":** native yolu her zaman ÖNCE göster; ama sınırını kullanıcının
> kuralına karşı **açıkça söyle** (ör. yerleşik reprice simetriktir, charm yuvarlama yapmaz), sonra
> "native (basit/desteklenen) mi, SQL (birebir kural) mi?" diye kullanıcıya seçtir. Karar hep kullanıcıda.
>
> **Native-first YALNIZ yazma/düzeltme/otomasyon için.** SQL ile **ölçme/teşhis** her zaman birinci
> sınıftır (skill'in asıl gücü) — ne satıyor, ne askıda, hangi kart bozuk gibi soruları SQL ile ölç.
>
> ### Güven etiketi
> - **`≈`** — genel Wolvox bilgisi, canlı ekranla teyit edilmemiş. "Senin sürümünde şuna yakın" diye ver.
> - **`📹`** — resmî AKINSOFT eğitim videosundan damıtılmış; akış teyitli, etiket sözcüğü oto-altyazıdan sapabilir.
> - **`✓`** — canlı ekranda saha-teyitli (sürüm etiketiyle). **Şu an yok**; kullanıcının sistemiyle teyit ettikçe `≈`/`📹`→`✓` yükselt.
>
> ⚠️ Menü sözcükleri sürüme (8 vs 9) ve edisyona göre kayar. Emin olmadığın metni kesin verme; etiketi
> koru, ekranda teyit ettir. İlgili derin paket her satırda köşeli-ayraçla belirtilir.

---

## 1) Fiyatlandırma & Reprice
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| **Alışta satış fiyatı otomatik güncellensin** | Yerleşik reprice penceresi | `Özel Ayarlar > Fatura Ayarları > Alış Faturası > "Satış fiyatları oluşturma penceresini göster"` (+ alış fiyatına KDV ekle · ek maliyet · yeniden oluşturulacak satış fiyat sayısı) | 📹 | **Simetriktir** (maliyet düşünce satışı da düşürür) ve düz marj yuvarlar. Asimetri (sadece-yükselt) veya `⌈×çarpan⌉−1` charm gerekiyorsa → toplu betik. [ozel-ayarlar §4] |
| Üretim maliyetinden satış türet | Yerleşik reprice (üretim) | `Özel Ayarlar > Üretim Ayarları > "Satış fiyatları oluşturma penceresi"` (+ birim maliyete KDV) | 📹 | Aynı KDV-hariç tabanı tuzağı. [ozel-ayarlar §9] |
| Toplu fiyat zam/güncelleme (marj/çarpan/yuvarlama) | Toplu Fiyat Güncelleme | `Stok > Toplu Güncelleme / Toplu Fiyat Güncelleme` | ≈ | 9'da seçenek zengin (marj/çarpan/yuvarlama). Fiyat log'unu korur. [menu-haritasi] |
| Çok fiyat listesi (toptan/perakende/bayi/e-tic.) | Fiyatlar sekmesi (4 satış+4 alış) | `Stok kartı > Fiyatlar sekmesi` (+ `Fiyat Tanımları` sınırsız liste) | 📹 | Müşteriye liste atama aşağıda (Cari). Yeşil tik = yalnız satış fiyatını kaydet. |
| Müşteriye sabit fiyat listesi | Cari'ye fiyat no ata | `Cari kartı > Hesap Bilgileri > fiyat no` (örn. 6 → hep 6. fiyattan sat) | 📹 | `CARI.STOK_FIYATI` = FIYAT_NO. [menu-haritasi Cari] |
| "Son alış" fiyatını görmek | İstatistikler sekmesi | `Stok kartı > İstatistikler > İstatistikleri hesapla` (son/ort/en ucuz-pahalı alış) | 📹 | Reprice'ın "son alış" kaynağı. |
| Fiyat yuvarlama hassasiyeti | Birim fiyat hassasiyeti | `Genel Ayarlar > Stok Ayarları > Stok Kart Ayarları > Birim fiyat hassasiyeti` | 📹 | e-belge yuvarlamasını da etkiler. |

## 2) Stok
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| **Ürün alt-kümesi işaretle** (otomasyon/filtre için) | Özel Kodlar | `Stok kartı > Özel Kodlar` (`OZEL_KODU1/2/3`); toplu → `Stok > Toplu Güncelleme` | 📹 | Boş bir slot seç (dolu olanın üstüne yazma). OZEL_KODU4 yok. |
| Kritik seviyede otomatik uyarı/sipariş | Min/Max stok seviyesi | `Stok kartı > Detay / Sipariş` (`MIKTAR_MINIMUM/MAXIMUM`) | ≈ | Kullanılmayan "goldmine"; tetikleyicisiz kartları tara. |
| Ölü / hareketsiz stok | Native rapor | `Raporlar > Stok > Hareket Görmeyen Stoklar` | ≈ | Eşik tarihini belirt. |
| Çoklu birim (koli=15 → oto ×15) | Birim/Barkod sekmesi | `Stok kartı > Birim/Barkod` (birim + katsayı + çoklu barkod) | 📹 | — |
| Açılış stok miktarı (hareket yokken) | Devir Girişi | `Stok kartı > Stok Durumu > Devir Girişi` | 📹 | Fatura kesmeden eldeki miktarı yükler. |
| Sayım / envanter | Native sayım | `Stok > Sayım` / `Stok > Envanter` | ≈ | — |
| Fiyat değişim geçmişi | Fiyat Geçmişi | `Stok kartı > Fiyat Geçmişi` / `Raporlar > Stok > Fiyat Değişim` | ≈ | Denetim izi. |
| Kullanıcı alanı ekle (örn. SKT) | Özel Tanımlar | `Stok kartı > Özel Tanımlar > Ayar > +` (tarih/metin) | 📹 | DB'ye yazılır; filtre/rapor/tasarımda kullanılır. |

## 3) Fatura / Satış
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Vade farkını ayrı göster / fiyata yansıt | Vade farkı sistemi | `Özel Ayarlar > Fatura Ayarları` (ayrı satır / stok fiyatına yansıt) | 📹 | — |
| İsimsiz / perakende müşteriye kes | Genel müşteri cari kodu | `Özel Ayarlar > Fatura Ayarları > genel müşteri cari kodu` | 📹 | — |
| Kasada hızlı barkod satışı | Hızlı satış | `Özel Ayarlar > Fatura > Hızlı satış` (birleştir/ayrı; miktar sütunu) | 📹 | POS için Stok Ayarları çarpan karakteriyle birlikte. |
| Kampanya / promosyon / indirim motoru | Kampanya tanımı | `Yönetim > Tanımlar > Kampanyalar` veya `Satış > Kampanya` | ≈ | Kullanılmayan goldmine. |

## 4) Cari / Alacak
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Riskli/borçlu cariye satışta uyarı | Kara liste + not/mesaj | `Özel Ayarlar > Cari > kara liste kontrolü` + `Cari kartı > Hesap Bilgileri > not/mesaj` | 📹 | "Durdur müşteri" mesajı her modülde çıkar. |
| Vadesi geçmiş taksitte uyarı | Ödenmemiş taksit uyarısı | `Özel Ayarlar > Cari Ayarları` | 📹 | Tahsilat disiplini. |
| Müşteriye özel iskonto | Özel iskonto % | `Cari kartı > Hesap Bilgileri > özel iskonto %` | 📹 | — |
| Ekstre / hesap özeti | Native ekstre | `Cari > Ekstre` | ≈ | — |
| Vade/yaşlandırma analizi | Yaşlandırma raporu | `Raporlar > Cari > Yaşlandırma` | ≈ | — |
| Toplu cari güncelleme | Toplu Güncelleme | `Cari > Toplu Güncelleme` | ≈ | — |

## 5) e-Dönüşüm (e-Fatura/Arşiv/İrsaliye/Defter/Müstahsil)
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| e-Fatura/e-Arşiv kurulumu | Aktivasyon + Ayarlar paneli | `Kontrol Paneli > Yetkili > e-Devlet 1` + `e-Dönüşüm > e-Fatura Ayarları` (~20 kutu) | 📹 | `Bağlantı Testi Yap` ile doğrula. [kurulum-playbook §1] |
| Kayıtta otomatik gönder | Ayar kutusu | `e-Fatura Ayarları > kayıtta otomatik gönder (onaya bağlı)` | 📹 | — |
| Askıda / hatalı e-belge bul | Native liste | `e-Dönüşüm > Gönderilecekler / Hatalı Belgeler` | ≈ | Ölçme SQL'i de var (FATURA.EFATURA_DURUM/GIB_DURUM). |
| Mükellef listesi güncelle | Ayarlar | `e-Dönüşüm > Ayarlar > Mükellef Listesi` | ≈ | e-Fatura mükellefine kâğıt kesme tuzağı. |
| **Eski veriyi "sil" (KVKK)** | **Yerleşik anonimleştirme aracı** | Wolvox native KVKK anonimleştirme (tarih/imha evrak/yöntem/tablo/rapor) | 📹 | Ham `DELETE` YERİNE bunu kullan. [turkiye-uyumluluk §9] |
| e-İhracat / istisna / müstahsil / tevkifatlı fatura | Native fatura akışları | senaryo/tip + kart otomasyonu | 📹 | [turkiye-uyumluluk §2-3] |

## 6) Genel Muhasebe *(veri ayrı `_GMUHASEBE` DB'sinde)*
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Hareketleri muhasebeye aktar | Muhasebeleştirme | `Genel Muhasebe > Entegrasyon > Muhasebeleştirme` | ≈ | Aktarılmayan = eksik mizan. |
| Mizan / kesin mizan | Native rapor | `Genel Muhasebe > Raporlar > Mizan` | ≈ | — |
| Enflasyon muhasebesi (VUK 298/A) | Yerleşik modül | `Genel Muhasebe > Genel Ayarlar > Ayarlar 2` (Yİ-ÜFE, düzeltme, YMY fişi) | 📹 | Zamana-duyarlı + SMMM. [turkiye-uyumluluk §7] |
| e-Defter / Berat | Kontrol Paneli + e-Defter prog. | Kontrol Paneli e-Defter kaydı → fiş bütünlük kontrolü → berat oluştur-imzala-gönder | 📹 | Erken "gönderildi" işaretleme tuzağı. [turkiye-uyumluluk §8] |
| Dönem sonu kapanış | Dönem Sonu İşlemleri | `Genel Muhasebe > Dönem Sonu İşlemleri` (7A/7B, maliyet, kapanış fişi) | 📹 | [kurulum-playbook §3] |

## 7) POS / Perakende / e-Ticaret
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Yeni nesil yazar kasa (ÖKC) | Aktivasyon + eşleştirme | `Kontrol Paneli > e-Devlet 1` → cihaz seri/IP → **ödeme tanımı eşleştir** → otomatik fiş (Pavo N86 / Ingenico / PAX) | 📹 | ÖKC-GİB gün sonu mutabakatı tuzağı. [perakende-entegrasyon] |
| Kasada "5 adet" hızlı giriş | Çarpan karakteri | `Özel Ayarlar > Stok Ayarları > hızlı satış çarpan karakteri` (örn. `5*`barkod) | 📹 | — |
| e-Ticaret/pazaryeri + taksit | Entegrasyon eşleştirme | AKINSOFT e-Ticaret panel (KDV/etiket) + Wolvox↔e-tic. taksit/sanal POS eşleştir | 📹 | Overselling, komisyon/kargo maliyeti tuzağı. |

## 8) Depo
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Hep doğru depo gelsin | Varsayılan depo | `Özel Ayarlar > Depo Ayarları > Varsayılan depo` | 📹 | Çok-depolu kurulum. |
| Depolar arası transfer | Transfer irsaliyesi | `İrsaliye > Depolar Arası Transfer` | ≈ | KDV aktarımı ayarı: `Özel Ayarlar > İrsaliye`. |

## 9) Üretim
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Ürün ağacı / reçete (BOM) | Reçete Tanımları | `Üretim > Reçete Tanımları` | ≈ | — |
| Negatife düşen mamulü otomatik üret | MRP-lite ayarı | `Özel Ayarlar > Üretim Ayarları > eksiye düşen stok otomatik üretilsin` (+ aralık/depo) | 📹 | Sarf/kapanış tuzakları. |

## 10) Kontrol Paneli / Sistem / Otomasyon
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Yeni firma / şube aç | Şirket Kayıt İşlemleri | `Kontrol Paneli > Yetkili > Şirket Kayıt İşlemleri` (çalışma alanı oluştur = DB yaratır) | 📹 | e-Devlet 1/2, şube+ortak modüller. [kurulum-playbook §6] |
| **Yedekleme & geri yükleme** (rotasyon/bulut) | Veri Tabanı İşlemleri | `Kontrol Paneli > Veri Tabanı İşlemleri` (periyot/rotasyon, manuel, bulut "Akınsoft Yedekleme") | 📹 | Geri yükleme GERİ DÖNDÜRÜLEMEZ uyarısı. "Önce yedek" doktrininin ürün-içi yeri. |
| Kullanıcı / yetki | Kullanıcı Yönetimi | `Yönetim > Kullanıcı Yönetimi` | ≈ | — |
| Yıl sonu devir | Devir İşlemleri | `Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri` → çalışma yılı → ileri → devre başla | 📹 | Yeni yıl DB'sinde açılış fişi. [kurulum-playbook §3] |
| **Zamanlanmış rapor / uyarı e-postası** | Görev/Bildirim Planlayıcı | `Yönetim > Ayarlar > Görev/Bildirim Planlayıcı` (+ `Özel Ayarlar > Genel > rapor mail sistemi`) | ≈ | Kullanılmayan goldmine: ekstre/PDF/düşük-stok otomatik gönder. |

## 11) Servis / İK
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Teknik servis takibi | Servis modülü | `Servis > Servis Fişi` (seri+garanti, işlem kodu+durum, servis aracı) | 📹 | Fiş durumu **kullanıcı-tanımlı** (sabit enum değil). [modul-derinlik §3] |
| PDKS / bordro | İK modülü (`_IKAYNAK`) | vardiya→plan→takvim→mazeret; 4 ücret yöntemi; ihbar/kıdem | 📹 | Muhasebe entegrasyonu ayrı. [modul-derinlik §5] |

## 12) e-Ticaret / Pazaryeri Entegrasyonu (AKINSOFT e-Ticaret)
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| **e-Ticaret sipariş ödemeleri/taksitleri Wolvox'a düşsün** | Ödeme → ERP aktarımı | e-Ticaret panel: **Ayarlar > Sipariş Ayarları > "Yeni siparişe direkt fatura olarak kaydet"** (+ fatura/e-Fatura sayaçları) · **Ayarlar > Ödeme Ayarları > Sanal POS > taksit tanımı > Düzenle > "ticari program eşleştirme"** (İİP sanal POS taksitini eşleştir) · **Entegrasyonlar > Ticari Program Yönetimi > Entegrasyon Yönetimi** (statik IP, **port 3055 + 3056** açık, İİP/Kontrol Paneli yetkili kullanıcı, şirket/şube/çalışma yılı → Kaydet → **Test**) · **"Ödeme bilgisini gönder"** işaretle | 📹 | Ödemeler **Kontrol Paneli üzerinden** gider → Entegrasyon Yönetimi + port 3055/3056 şart. KK ödemesi → ödeme bilgisi düşer; siparişler **doğrudan fatura** olur (kapalı fatura). |
| Ürünleri **Trendyol**'a gönder (ürün bazlı) | Market > Trendyol | **Ürün Katalog > Ürün Listesi** (filtre: ana stok) > **Market > Trendyol** > kategori seç > zorunlu (yıldızlı) özellikler (cinsiyet/yaş) > varyantlıysa renk/beden eşleştir > marka > **Kaydet > Mağazaya Gönder** | 📹 | **Barkod tuzağı:** global (869…) barkod çakışabilir → barkod başına ön-ek ekle. Marka, Trendyol'daki yazılışıyla **birebir** olmalı yoksa eşleştir. |
| Ürünleri **n11 / HepsiBurada**'ya toplu gönder | Market > n11/HB | Genel/Fiyat/Diğer ayarları kontrol > **kategori eşleştirme** > kategori özellikleri (zorunlu: marka/sezon/cinsiyet) > renk/beden ürün kartından otomatik (boş bırak) > **Ürün Aktar** > log takibi | 📹 | Marka listede yoksa **mağaza talep formu** ile eklet. HepsiBurada aynı akış. |
| Vadesi geçmiş **borçlu cariye** e-ticarette satışı durdur | Cari Borç Sorgulama Servisi | Entegrasyon Yönetimi test-başarılı olmalı > İİP'te + e-ticaret tarafında servisi aç; borç limiti + vade + ek tolerans günü tanımla | 📹 | Limit aşılıp tolerans dolunca sipariş **durur**. "Borçlu olsa da sipariş verebilsin" seçeneği var. |
| e-Ticaret'te **havale/EFT + kapıda ödeme** seçeneği | Ödeme yöntemi ayarları | Havale: **Ayarlar > Banka Hesap Numaraları > Yeni Ekle** + **Ayarlar > Sepet ve Sipariş İşlem > "havale ile ödeme" aktif**. Kapıda: **Site İçerikleri > Kargo Firmaları > Ayarlar > "kapıda ödeme"** + ilgili kargo firması > Düzenle > "kapıda ödeme aktif" | 📹 | Kapıda ödeme, sepet ücretsiz-kargo limitinin altındaysa görünmeyebilir. Havale siparişi "ödeme bekliyor" düşer. |
| Site ödemelerini **takip et / eksik düşen siparişi oluştur** | Ödeme Bildirimleri + Ödeme Haritası | **Siparişler > Ödeme Bildirimleri** (tutar/banka/tamamlandı mı/**Wolvox ERP'ye gönderildi mi**) · **Ödeme Haritası** (onaylı/onaysız sipariş logları) | 📹 | Banka onaylı ama sipariş oluşmamışsa → satırdaki mavi buton ile onayla → sipariş sisteme düşer. |
| **Kargo tanımı + entegrasyonu** (oto barkod) | Kargo Firmaları | **Site İçerikleri > Kargo Firmaları > Kargo Ekle**; entegrasyonsuz = durumları manuel · entegrasyonlu = lisansa kargo modülü eklet+aktif → firma verilerini gir → sipariş onayla → kargolama → **otomatik kargo barkodu** | 📹 | Alıcı ödemeli: kargo tanımı > "alıcı ödemeli" aktif. Desi bazlı ücret için **desi tanımı ekle**. |
| **Pazaryeri API bağlantısı** (Trendyol/n11/HepsiBurada) | Sanal Mağaza Entegrasyonları | **Sanal Mağaza Entegrasyonları > [Pazaryeri] > Ayarlar** → pazaryeri panelinden alınan API parametrelerini gir (Trendyol: Hesabım > Entegrasyon Bilgileri; 3 parametre + kargo ismi) → aktif işaretle → geçerli kargo seç | 📹 | Her pazaryerinde Genel/Fiyat/Diğer ayar sekmeleri. Ürün gönderimi için üstteki Trendyol/n11 satırları. |

## 13) Hızlı Satış / POS (Perakende Satış Ekranı)
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Satış **iadesi** al | İade Ekranı | Hızlı Satış > **İade Ekranı > Satışlar** > gün içi satış/cari bul > iade ürününü **Seç > Tamam** > ödeme bilgisi > **İşlem Tamamla** > ödeme türü | 📹 | Gün içi satışlar listelenir; ödeme bilgisi kontrol edilerek iade türü seçilir. |
| Ürün **değişimi** (fiyat farkıyla) | Değişim İşlemi | **Ek İşlemler > Değişim İşlemi** > eski satış/ürünü seç > iade ödeme türü > yeni ürünü seç > **fiyat farkı otomatik** (fark alınır/verilir) | 📹 | İade + satış tek işlemde tamamlanır. |
| **Gün sonu** / kasa kapanış + raporlar | Gün Sonu Ekranı | Hızlı Satış > **Gün Sonu**: fişler · veresiye · cari borç/tahsilat · kasa hareketleri · ürün/grup satışları · satılmayanlar · iptal · personel/pazarlamacı satış · **kredi kartı POS satışları** · grup bazlı iadeler → Kaydet | 📹 | POS çekimlerini gün sonunda buradan **mutabık** yap. |
| Nakit ödemede **para üstü** göster | Görünüm ayarı | **Yetkili > Özel Tanımlar > Özel Ayarlar > Görünüm Ayarları > "nakit ödemelerde hesaplama penceresini aç"** → nakit butonunda hesaplama penceresi | 📹 | Alınan ödeme girilince para üstü hesaplanır. |
| **Veresiye** (ödeme almadan cariye) | Veresiye satış | Hızlı Satış > **Cari Bul** > cari seç > **İşlem Tamamla** (ödeme almadan) → cariye borç düşer | 📹 | Cari seçilmeden veresiye olmaz. |
| Satışı **beklet / askıya al** | Bekleme İşlemi | Ödeme tanımları altı > **Bekleme (Beklet)** > müşteri bilgisi > Tamam → **Bekleme Listesi**'nden geri çağır | 📹 | **"Bekleme listesini DB'de sakla"** aktifse online liste (DB), kapalıysa offline (dosya konumu). |
| POS **kasa işlemleri** (gelir/gider/transfer/sayım) | Kasa Menüsü | Hızlı Satış > **İşlemler > Kasa Hareket**: gelir/gider girişi · kasa-banka / kasa-kasa transfer · kasa toplamları · sayım · rapor | 📹 | — |
| POS'tan **stok / etiket / hizmet** | Stok Menüsü | Hızlı Satış > **İşlemler > Stok**: stok tanımı · **etiket çıktısı** · hızlı satış için hizmet tanımı | 📹 | Etiket çıktısı için **Kartotek modülü** lisansı şart. |
| Satışta **hangi depo/kasa** kullanılsın | Kasa-Depo seçimi | **Özel Ayarlar > Satış/İade Ayarları > aktif depo + aktif kasa** | 📹 | Satış o depodan düşer, ödeme o kasaya girer. |
| Fiş sonrası **para çekmecesini** aç | Çekmece Ayarları | **Özel Ayarlar > Entegrasyon Ayarları > Çekmece Ayarları > "satış öncesi/sonrası çekmece aç"** + çekmece yazıcısı seç | 📹 | Çekmece o yazıcıya bağlı olmalı; fiş yazısıyla tetiklenir. |
| **Market: terazi / yazarkasa (ÖKC)** ürün gönder | Market Otomasyonu | **Market Otomasyonu > Ayarlar**: ürün fiyatına KDV ekle · sıfır-fiyatlıyı gönderme · **kaçıncı fiyattan gönder** · sayaç seçimi · terazi PLU (özel kod 1/2/3'ten) · yabancı ad gönder → cihaz entegrasyonu | 📹 | Her marka terazi/ÖKC (HUGIN/CAS/Profilo/Ingenico/Beko…) **ayrı modül+eşleştirme**; kalıp aynı. |

## 14) Satınalma / Finans / Veri / Doküman (tekil güçlü özellikler)
| İhtiyaç | Native çözüm | Yol | Güv. | Tuzak / not |
|---|---|---|---|---|
| Depoya gireni **kontrollü teslim al** (sipariş/irsaliye/fatura karşılaştır) | Mal Kabul | **Satın Alma Yönetimi > İşlemler / İrsaliyeler > Mal Kabul** > Ekle (tarih/sorumlu/durum/araç) > Kaydet > Ürün Bilgileri: kaynak seç (onaylı sipariş/irsaliye/fatura) > Aktar > sayım (+/−/barkod) > **İrsaliyeleri Oluştur** | 📹 | Sipariş seçmek için sipariş durumu **onaylandı** olmalı. |
| Banka hareketlerini **panele girmeden** Wolvox'a çek | Banka Online Veri Al | Kur: **Kontrol Paneli > Yetkili Şirket Kayıt > Özel Bilgiler > "Banka Online Veri Al"** + **Finans Yönetimi > Tanımlar > Banka Tanımları > Entegrasyon Tanımları > "entegrasyon kullan"** (IBAN TR+26 hane, son işlem zamanı). Kullan: **Finans Yönetimi > İşlemler > Banka İşlemleri > Bankadan Online Veri Al** > hedef modül > **Hareketleri İşle** | 📹 | İki tür: **MT940** (periyodik) / **Webservis** (~15 dk). Cari IBAN'lıysa otomatik eşleşir. Banka başvurusu = Akınsoft bilgi bankası formu. |
| **Şubeler arası kasa transferi** (onaylı) | Kasa Transfer Havuzu | Kaynak: **Finans Yönetimi > İşlemler > Kasa İşlemleri > Kasa Transferi** (kaynak > hedef kasa > tutar > Transferi Uygula). Hedef şube: **Finans Yönetimi > Raporlar > Kasa Raporları > Kasa Transfer Havuzu Al** > seç > **Transferi Onayla** | 📹 | Karşı şube onaylayana dek havuzda bekler. |
| Sözleşme/evrak **doküman + süre uyarısı** takibi | Doküman Takip | **Diğer İşlemler > Doküman Takip > Doküman Kaydı** (no, grup, kayıt/**uyarı tarihi**, durum, özel kod 1/2/3, **cari/stok ilişkilendir**, Dosya sekmesi) > Doküman Listesi | 📹 | Uyarı tarihi ile bitiş öncesi hatırlatır; özel kodla raporlanır. |
| **Excel'den toplu stok/cari içe aktar** | Excel'den Transfer | **Diğer İşlemler > Excel'den Transfer** (cari/stok/kategori) > dosya+sayfa seç, "ilk satır başlık", **eşleştirme stok kodu/barkod**, mevcutsa güncelle/atla, sütun→alan eşle > **Bilgileri Aktar** | 📹 | Excel'de boş/yanlış giriş olmamalı. Sonuç: güncellenen + yeni eklenen sayısı. |
| Eksiye düşen mamulü **manuel toplu üret** | Otomatik Üret | Reçete: **Üretim Yönetimi > Üretim Tanımlar** (stok reçetesi). Üret: **Üretim > İşlemler > Eksiye Düşen Stokları Otomatik Üret** > depo > filtrele > **Otomatik Üret** | 📹 | Arka plan otomatik için → §9 (`Özel Ayarlar > Üretim Ayarları`). |

---

## Refleks kullanımı (özet akış)
1. Kullanıcı bir **eylem/otomasyon/düzeltme** istedi mi? → önce **bu index'te ara**.
2. Native varsa: **önce onu ver**, sınırını kullanıcının kuralına karşı **dürüstçe söyle**.
3. Native yoksa / kuralı tam karşılamıyorsa: ölçme SELECT'i + UI toplu araç **veya** inert migration taslağı; kararı kullanıcıya bırak.
4. Kullanıcı canlı ekranda teyit ettikçe ilgili satırı `≈`/`📹` → **`✓`** yükselt (sürüm etiketiyle).

> **Kapsam notu:** bu index resmî eğitim videolarından + genel Wolvox bilgisinden çekirdeklendi; **her
> özelliği** kapsamıyor. Görülmemiş bir ihtiyaçta: ilgili derin pakete bak, yoksa "yerleşik özelliği ekranda
> birlikte arayalım" de ve teyit edince buraya yeni satır ekle. Bu dosya **büyüyen** bir indekstir.
