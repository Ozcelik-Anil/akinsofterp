# Wolvox 8/9 — Özel Ayarlar Referansı (davranışı yöneten anahtarlar)

> Wolvox'un **davranışını ayarlar belirler.** "Program neden şöyle yapıyor / nasıl yaptırırım" sorularının
> çoğunun cevabı `Özel Ayarlar` altındadır. Bu dosya modül-bazlı **ayar → ne yapar → danışman notu/tuzağı**
> kataloğudur.
>
> **Kaynak:** satırların çoğu **resmî AKINSOFT eğitim videolarındaki (Özel Ayarlar serisi)** ekranlardan
> damıtıldı → `📹`. Akış/sekme yapısı kaynak-teyitli; **etiket sözcükleri oto-altyazı kaynaklı** olduğundan
> ekranda son teyidi yap. Menü yolu: **`Özel Ayarlar > <Modül> Ayarları`** (ana ekran arama kutusundan da açılır).
>
> ⚠️ Ayar değişikliği canlı davranışı etkiler → **önce ne yaptığını anlat, sonra müşteriye yaptır**; kritik
> olanlarda (fiyat/döviz/depo) yedek + test refleksi. Kolon/tablo etkisi için → [schema-map](schema-map.md).

---

## Erişim
`Özel Ayarlar` penceresi modül sekmelerine ayrılır: **Genel · Stok · Cari · Fatura · İrsaliye · Sipariş ·
Teklif · Çek/Senet · Üretim · Depo · Performans · Servis · CRM · Banka · MRP2 · (sektörel: Tıp/Su, Caller ID,
Sanal Santral)**. Aşağıda **çekirdek ticari sekmeler** (10) video-teyitli; sektörel/niş sekmeler sonda listeli.

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

## 4) Fatura Ayarları  `📹`  ⭐ (reprice tetiği burada)
**Satış Faturası:** iç dağıtım sistemi · elektronik terazi · hızlı satış · ek sistemler (**Petrol / Toptancı / yok**).
**Alış Faturası — otomatik yeniden fiyatlama:**
| Ayar | Ne yapar | Danışman notu |
|---|---|---|
| **"Satış fiyatları oluşturma penceresini göster"** | Alış faturası kaydında "satış fiyatları yeniden oluşturulsun mu?" penceresini açar | **Yerleşik reprice tetiği** — [kurulum-playbook §2](kurulum-playbook.md) · [P1](cozum-desenleri.md) |
| **Alış fiyatlarına KDV eklenecek** | Reprice tabanına KDV dahil edilsin mi | `FIYATI` KDV **hariç** tutulur; bu ayar tabanı değiştirir → tuzak! [schema-map](schema-map.md) |
| **Alış fiyatlarına ek maliyet eklenecek** | Navlun/gümrük gibi ek maliyet tabana binsin | Landed cost; açıksa reprice daha yüksek çıkar |
| **Yeniden oluşturulacak satış fiyat sayısı / hangi alış** | Hangi satış listeleri (1-4) hangi alıştan üretilsin | Sadece 1 nolu mu, toptan+perakende mi? Netleştir |

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

## Sektörel / niş sekmeler (henüz video-damıtılmadı — kurulumda teyit)
`≈` Performans (önbellek/sorgu davranışı — [dba-performans](dba-performans.md) ile ilişkili) · Servis (teknik
servis davranışı — [modul-derinlik §3](modul-derinlik.md)) · CRM · Banka · MRP2 · Tıp/Su · Caller ID · Sanal
Santral. Bir sonraki damıtma turunda `📹`'a yükseltilebilir.

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
