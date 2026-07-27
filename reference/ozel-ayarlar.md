# Wolvox 8/9 — Özel Ayarlar Referansı (davranışı yöneten anahtarlar)

> Wolvox'un **davranışını ayarlar belirler.** "Program neden şöyle yapıyor / nasıl yaptırırım" sorularının
> çoğunun cevabı `Özel Ayarlar` altındadır. Bu dosya modül-bazlı **ayar → ne yapar → danışman notu/tuzağı**
> kataloğudur.
>
> **Kaynak:** satırların çoğu **resmî AKINSOFT eğitim videolarındaki (Özel Ayarlar serisi)** ekranlardan
> damıtıldı → `📹`. Akış/sekme yapısı kaynak-teyitli; **etiket sözcükleri oto-altyazı kaynaklı** olduğundan
> ekranda son teyidi yap.
>
> **Tam menü yolu `✓ (8.25 saha-teyitli)`: `Yetkili > Özel Tanımlar > Özel Ayarlar > <Modül> Ayarları`.**
> Kısaca "`Özel Ayarlar > …`" yazarken **yolun başını atlamış olma** — kullanıcı ekranda `Özel Ayarlar`
> diye bir üst menü aramaya kalkar ve bulamaz.
>
> ⚠️ Ayar değişikliği canlı davranışı etkiler → **önce ne yaptığını anlat, sonra müşteriye yaptır**; kritik
> olanlarda (fiyat/döviz/depo) yedek + test refleksi. Kolon/tablo etkisi için → [schema-map](schema-map.md).

---

## Erişim
**Yol:** `Yetkili > Özel Tanımlar > **Özel Ayarlar**` `✓ (8.25)`. Pencerenin sol ağacı modül gruplarına
ayrılır: **Genel · Stok · Cari · Fatura · İrsaliye · Sipariş · Teklif · Çek/Senet · Üretim · Depo ·
Performans · Servis · CRM · Banka · MRP2 · (sektörel: Tıp/Su, Caller ID, Sanal Santral)**. Hangi
grupların göründüğü **edisyona bağlıdır** — `8.25` otomotiv paketinde şunlar vardı: `Genel Ayarlar ·
Performans · Cari · Stok · Depo · Çek/Senet · Fatura · İrsaliye · Teklif · Sipariş · Banka · Caller ID ·
Sanal Santral` (Üretim/Servis/CRM/MRP2 yoktu). Aşağıda **çekirdek ticari sekmeler** (10) video-teyitli.

> ### ⚠️ Bu ağacı `Genel Ayarlar` ağacıyla karıştırma — ikisi ayrı pencere
> | | **Özel Ayarlar** (bu dosya) | **Genel Ayarlar** |
> |---|---|---|
> | Yol | `Yetkili > **Özel Tanımlar**` | `Yetkili > **Tanımlar**` |
> | Kapsam | modül **davranışı** (pencere çıksın mı, hızlı satış, terazi, performans) | firma geneli **veri/varsayılan** (KDV, hassasiyet, oto-kod, depo limitleri, gelişmiş fiyat/iskonto, fiyat loglama) |
> | Butonlar | `Değişiklikleri Kaydet` / `Kaydetmeden Kapat` | `Kaydet` / `Vazgeç` / `Kapat` |
>
> İkisinde de **eş adlı** `Stok Ayarları` / `Fatura Ayarları` / `Cari Ayarları` düğümleri var ama
> **içerikleri farklı**. Ayrıca **her pencerenin büyüteç araması yalnızca kendi ağacını tarar** —
> birinde bulamamak ayarın yok olduğunu göstermez, diğerinde ara. Bir ayarın yerini söylerken
> **hangi ağaç olduğunu belirt**; en hızlı ayırt edici alttaki buton çiftidir.

---

## 1) Genel Ayarlar  `📹`
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| Program tanımı / mesaj tipi | Sol üst köşe başlığı + sistem/özel mesaj | Çok firmalı/şubeli kurulumda hangi firmadasın belli olsun |
| Uyarı penceresi yenileme aralığı + ses | Sağ alt uyarıların kontrol sıklığı (sn) ve sesi | Çok sık = gereksiz yük; sessiz ortamda "yok" |
| Açılışta kısayol çubuğu / yönetici ekranı göster | Program açılışında ne gelsin | — |
| Tema · hesap tablosu türü (Excel/OpenOffice) | Görünüm + rapor dışa aktarım hedefi | Excel yoksa OpenOffice seç yoksa dışa aktarım patlar |
| **Otomatik sürüm kontrolü + gün aralığı** | Güncelleme kontrolü periyodu | Güncelleme **şemayı** etkileyebilir → [dba-performans göç](dba-performans.md); kontrollü yap |
| Rapor mail gönderim sistemi | Raporların e-postayla gönderimi | Zamanlanmış rapor teslimatı için ön koşul |
| Tasarımda stok **tedarikçi** bilgisi çek | Fatura/irsaliye/teklif/sipariş çıktısına tedarikçi bilgisi | — |
| **Varsayılan stok fiyat para birimi (TL / döviz)** | Fatura vb.'de stok fiyatının varsayılan dövizi | Yanlışsa tüm belgeler yanlış kurdan başlar → [schema-map DOVIZ](schema-map.md) |
| **Aramada pasif stokları dahil et** | Barkod/stok kodu aramasına `AKTIF=0` de girsin | Pasif kart yanlışlıkla satılır; veri-kalitesi taramasıyla ilişkili ([P12/P24](cozum-desenleri.md)) |
| **Tarih değişince döviz kuru yeniden aktar sorusu** | Belge tarihi değişince kuru güncelle sorusu | Geriye dönük belgede **yanlış kur** tuzağını önler |
| **Form Başlığı renk ayarları** (başlangıç rengi · bitiş rengi · font rengi) | Form üst başlık çubuğunun rengini özelleştirir | Yukarıdaki "Tema" satırına ek detay |
| **"Varsayılan Ayarları Yükle" butonu** | Bu ekrandaki tüm özel ayarları fabrika değerine döndürür | Deneme/test sırasında güvenli geri dönüş; canlıda dikkatli kullan — geri alınamaz olabilir |
| **Pencere Gösterimi ayarı** ("Pencereleri Ana ekrana sığdır" / "Başlıkları gizle") | Açılan pencerelerin ekrana yerleşim biçimi | Çoklu pencere karmaşasını azaltmak isteyen kullanıcı için |
| Resim kırpma ayarı ("kırpma işlemini uygula") | Yüklenen resimleri otomatik kırpar | `👤` Muhtemelen stok/cari kartı foto girişiyle ilgili — ekranda çapraz-doğrula |
| "Üst erişim menüsünde göster" kutusu | Bir öğeyi üst erişim menüsünde gösterir | `👤` Düşük güven: [menu-haritasi.md](menu-haritasi.md)'deki "Hızlı Erişime Ekle" (sağ tık > ana ekrana iğnele) ile aynı mekanizma olabilir ama kaynakta doğrudan söylenmiyor — teyitsiz varsayım, ekranda birlikte doğrula |

## 2) Stok Ayarları  `📹`
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| Stok listesinde resim çek | Yazdırmada ürün görseli | Büyük listede yavaşlatır |
| Excel'e aktarımda şifre | Dışa aktarılan Excel'i korur | KVKK/fiyat gizliliği için faydalı |
| Paket tanımları: aktarırken miktar sor / paket içi sıralama | Paket ürün faturaya girerken davranış | Paket = birden çok stok tek satırda |
| **Hızlı satış miktar çarpan karakteri** (örn. `5*`barkod → 5 adet) | POS'ta hızlı miktar girişi | Perakende/market kritik; karakteri müşteriyle netleştir |
| Hızlı stok tanımından sonra miktar sor | Yeni hızlı kart açınca miktar iste | — |
| Yeni stok kartı penceresi: tam mı **hızlı stok tanımları** mı | Faturada olmayan barkodda hangi ekran açılır | Yoğun kasa → hızlı tanım |

## 3) Cari Ayarları  `📹`
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| Cari listesinde resim çek | Yazdırmada logo/görsel | — |
| **Kara liste kontrolü** | Cari seçilince kara-liste notu varsa uyarır | Risk yönetimi; [cari kartı Hesap Bilgileri notu](menu-haritasi.md) ile birlikte |
| Kimlik tarama sistemi (+ exe yolu) | Kimlik okuyucu entegrasyonu | Otel/rehin/ÖKC senaryoları |
| Yeni kayıtta ticari unvana/ada konumlan | İmleç davranışı | Hızlı veri girişi |
| **Cari hareket girişinde ödenmemiş taksit uyarısı** | Vadesi geçmiş taksit varsa işlemde uyarı | Tahsilat disiplini; [yaşlandırma P9](cozum-desenleri.md) ile tamamlayıcı |

## 4) Fatura Ayarları  `✓ (8.25)`  ⭐ (reprice tetiği burada)
**Tam yol:** `Yetkili > Özel Tanımlar > Özel Ayarlar > Fatura Ayarları`.
**Sekmeler `✓ (8.25)`:** `Satış Faturası` · **`Alış Faturası`** · `Fatura Genel` · `Masraf Faturası`.
**Satış Faturası `✓`:** "satış faturasında orduevi iç dağıtım sistemini kullan" · `Elektronik Terazi Kullan` · `Hızlı Satış Kullan` · `Ek Sistemler` (açılır liste: **Yok / Petrol / Toptancı…**).
**Alış Faturası — otomatik yeniden fiyatlama `✓ (8.25)`** (ana kutu kapalıyken üç alt seçenek pasiftir):
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| **`Satış fiyatları oluşturma penceresini göster`** `✓` | Alış faturası kaydında "satış fiyatları yeniden oluşturulsun mu?" penceresini açar | **Yerleşik reprice tetiği** — [kurulum-playbook §2](kurulum-playbook.md) · [P1](cozum-desenleri.md). Kullanıcı "alınca satış fiyatı kendi değişiyor/değişmiyor" derse **ilk bakılacak yer burası** |
| **`Alış fiyatlarına KDV ekle`** `✓` | Reprice tabanına KDV dahil edilsin mi | `FIYATI` KDV **hariç** tutulur; bu ayar tabanı değiştirir → tuzak! [schema-map](schema-map.md) |
| **`Alış fiyatlarına ek maliyetleri ekle`** `✓` | Navlun/gümrük gibi ek maliyet tabana binsin | Landed cost; açıksa reprice daha yüksek çıkar. Kardeşi: `Genel Ayarlar > Fatura Ayarları > Alış Faturası > "Ek Maliyetleri Stok Hareketlerine Yansıt"` |
| **`Yeniden oluşturulacak satış fiyatı sayısı`** `✓` | Kaç satış fiyat listesinin (1…n) yeniden üretileceği — sayaç, varsayılan **`1`** | Sadece 1 nolu mu, toptan+perakende mi? Netleştir; `STOK_FIYAT.FIYAT_NO` ile eşleşir |

> ⚠️ Bu yerleşik pencere **simetriktir** (alış düşünce satışı da düşürür). "Yalnızca zam" isteniyorsa asimetrik
> SQL gerekir → [sorgu-recetesi §H](sorgu-recetesi.md) · `tools/reprice-preview.ps1`.

**Fatura Genel:** hareket sıralaması (+ters) · okutulan barkod kayıtlı değilse **stok kaydı sorusu** · ilk
girişte yeni fatura · yazdırırken stok fiyat/bilgi/depo göster · **vade farkı sistemi** (ayrı satır / stok
fiyatına yansıt) · yeni harekette barkod/stok koduna konumlan · **genel müşteri cari kodu** (perakende/isimsiz
müşteri) · seri yazdırma karakter sayısı.
**Hızlı satış:** barkod okutunca aynı stok birleştir mi/ayrı · yeni satır mı miktar sütunu mu.
**Masraf faturası:** döviz kullan.

## 5) İrsaliye Ayarları  `📹`
**Genel:** iç imha/taşıma belgesi oluştur · hızlı satış (birleştir/satır) · elektronik terazi · iç dağıtım
muhasebe sistemi · yazdırırken stok/depo bilgisi · yeni harekette konumlanma · hareket sıralaması.
**Satış / Alış irsaliyesi:** hızlı satış · ek sistemler (Petrol/Toptancı).
**Transfer irsaliyesi:** **stok seçiminde KDV oranı aktarılsın** — depolar arası transferde KDV taşıma tercihi.

## 6) Sipariş Ayarları  `📹`
Hareket sıralaması (+ters) · yeni harekette konumlanma (barkod/stok kodu/yok) · yazdırırken stok resim/bilgi/
depo · hızlı satış (birleştir/satır) · ek sistem (toptancı). → belge zinciri [P6](cozum-desenleri.md).

## 7) Teklif Ayarları  `📹`
Hareket sıralaması (+ters) · konumlanma · yazdırırken stok bilgi/resim/depo. → dönüşüm [P28](cozum-desenleri.md).

## 8) Çek/Senet Ayarları  `📹`
**Aynı evrak numarası girişinde uyarı** — mükerrer çek/senet girişini engeller. → [P14](cozum-desenleri.md).

## 9) Üretim Ayarları  `📹`  (reprice + MRP-lite)
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| Mamul sıralaması (+ters) | Üretim mamul satır sırası | — |
| **Satış fiyatları oluşturma penceresi** (üretimde) | Mamul maliyetinden satış fiyatı türet | Alış-reprice'ın üretim karşılığı ([§4](#4-fatura-ayarları---reprice-tetiği-burada)) |
| **Birim maliyetlere KDV eklenecek** | Reprice tabanına KDV | Aynı KDV-hariç tuzağı |
| Yeniden oluşturulacak satış fiyat sayısı | Hangi satış listeleri üretilsin | — |
| **Eksiye düşen stok otomatik üretilsin** + yenileme aralığı (dk) + depo | Negatife düşen mamulü otomatik üretim emrine al | MRP-lite; [modul-derinlik §1](modul-derinlik.md) — sarf/kapanış tuzaklarına dikkat |
| Stoklar için üretim yapılabilsin | Mamul olmayan stok da üretilebilir işaretle | — |

## 10) Depo Ayarları  `📹`
**Toplu transferde barkod sonrası miktar sor** · **Varsayılan depo** (çok depolu kurulumda hareketlerde otomatik
gelsin). → çok-depo [P24](cozum-desenleri.md), transfer [menu-haritasi](menu-haritasi.md).

---

## Sektörel / niş sekmeler  `📹` (video-damıtıldı; Performans hariç)
Çekirdek 10 sekmenin (§1-10) yanında sektörel/niş sekmeler — çoğu bir alt-modül/lisans gerektirir.

### 11) Banka Ayarları `📹`
| Ayar | Ne yapar |
|---|---|
| **POST tanım sıralaması** | Post (kredi kartı) tanımlarını bir kritere göre sırala (tanıma göre A→Z / Z→A ters) → ekle → kaydet |

### 12) CRM Ayarları `📹`
| Ayar | Ne yapar |
|---|---|
| **CRM ajandayı randevu paneli olarak kullan** | Ajanda sekmesinde "randevu paneline git" butonu aktif olur |
| Sadece aktif personelleri göster · grupları ağaç olarak göster | Ajanda/filtreleme görünümü |
| **Varsayılan aktivite tipi** | Randevu / toplantı / iş / genel hatırlatma |

### 13) Servis Ayarları `📹` (teknik servis davranışı — [modul-derinlik §3](modul-derinlik.md))
| Ayar | Ne yapar |
|---|---|
| Yeni stok hareketinde konumlanma | Barkod / stok kodu |
| Servis cari/ürün arama kriteri | Ürün adı / marka / model / seri no |
| İşlem toplamı → servis hareketine aktarım | Bağımsız hareket / hizmet tanımından / işlem tanımından |
| Teslim alan-eden varsayılan personel | Servis fişinde otomatik gelir |
| Hızlı satış kullan | Barkod okutunca aynı stok birleştir/ayrı; yeni satır / miktar sütunu |
| Seri no tekrar kontrolü · fiş yazdırırken stok bilgisi · genel müşteri otomatik · fiş durumu (işleme girdi/tamam/bekleme) · günlük personel azami iş yükü · hareket sıralama | Servis fiş/randevu davranışı |

### 14) MRP2 Ayarları `📹`
| Ayar | Ne yapar |
|---|---|
| Gantt otomatik oluştur/güncelle | Üretim/iş emri planlamada Gantt bilgisi otomatik |
| İş emri sonuçlandırmada üretim miktarı yuvarla · yeni kayıtta başlama tarihi = sistem tarihi | Üretim emri davranışı |

### 15) Caller ID Ayarları `📹` (arayan numara tanıma)
| Ayar | Ne yapar |
|---|---|
| Ön koşul | Akınsoft **Caller ID Server** programı kurulu olmalı |
| Caller ID kullan + iletişim portu | Port = CID Server portuyla aynı |
| Telefon gelince yapılacak işlem | Cari kart aç / yurtiçi satış faturası / servis fişi aç |
| Arama yaparken işlem · alan kodu · uyarı süresi · aramaları kaydet | Aktivite/müşteri destek kaydı vb. |

### 16) Sanal Santral Ayarları `📹`
| Ayar | Ne yapar |
|---|---|
| Ön koşul | Veri Transferi programında **Sanal Santral lisansı** + ayarları |
| Dahili numara / App linki | Bir PC'yi çok personel kullanıyorsa buraya dahili yaz (yoksa kullanıcı kaydındaki kullanılır) |

### 17) Tıp/Su Ayarları `📹` (sektörel fiş)
| Ayar | Ne yapar |
|---|---|
| Değişim bilgilerini otomatik aktar | Sor / sormadan otomatik / aktarma |
| Fiş açınca "teslim edildi" otomatik · depo bölümü + varsayılan depo | Fiş davranışı |
| Faturalandırmada güncel fiyat kullan | Sor / direkt kullan / kullanma |

> **Performans** sekmesi hâlâ `≈` (önbellek/sorgu davranışı — [dba-performans](dba-performans.md)); altyazısı yok, ekranda teyit.

---

## Danışman refleksi — "program neden X yapıyor?" → Özel Ayarlar'a bak
| Semptom / istek | Bak |
|---|---|
| "Alınca satış fiyatı kendi güncellensin / güncelleniyor" | §4 Alış Faturası + §9 Üretim (reprice pencereleri) |
| "Geçmiş tarihli faturada kur yanlış geliyor" | §1 tarih değişince kur yeniden aktar |
| "Pasif ürün yanlışlıkla satılıyor / aramada çıkıyor" | §1 aramada pasif stok dahil |
| "Riskli/borçlu cariye satışta uyarı istiyorum" | §3 kara liste + ödenmemiş taksit uyarısı |
| "Çok depoluyum, hep yanlış depo geliyor" | §10 varsayılan depo |
| "Kasada hızlı miktar girmek istiyorum (5 adet)" | §2 hızlı satış çarpan karakteri |
| "Negatife düşen mamul otomatik üretilsin" | §9 eksiye düşen stok otomatik üret |
| "Vade farkını ayrı göstereyim/fiyata yansıtayım" | §4 vade farkı sistemi |
| "İsimsiz/perakende müşteriye keseyim" | §4 genel müşteri cari kodu |

> Ayar bir davranışı açıklıyorsa, ilgili **desen** ([cozum-desenleri](cozum-desenleri.md)) ve **kurulum
> adımına** ([kurulum-playbook](kurulum-playbook.md)) bağla; kolon etkisini [schema-map](schema-map.md)'ten doğrula.
