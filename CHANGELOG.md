# Changelog

Bu projenin tüm önemli değişiklikleri burada tutulur.
Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) esaslıdır; sürümleme [SemVer](https://semver.org/lang/tr/).

## [2.21.0] — 2026-07-26
### Eklendi (niş YouTube damıtma kampanyası — resmî kanal dışı kaynaklar)
- **Yeni güven etiketi `👤`** ("bayi/danışman/kullanıcı videosundan damıtıldı, resmî AKINSOFT kaynağı değil; versiyon/terim sapması riski daha yüksek") — `native-yetenek-indeksi.md` ve `menu-haritasi.md` lejantlarına, `CONTRIBUTING.md`'nin iki PR-etiket listesine eklendi.
- **`reference/native-yetenek-indeksi.md` +59 satır:** §1 Fiyatlandırma, §2 Stok, §3 Fatura/Satış, §4 Cari/Alacak, §8 Depo, §9 Üretim, §10 Kontrol Paneli, §13 Hızlı Satış/POS, §14 Satınalma/Finans bölümlerine dağılmış yeni satırlar.
- **`reference/menu-haritasi.md` +14 yol satırı + yeni "Oto-altyazı sözlüğü" bloğu:** YouTube oto-altyazısının sık yanlış-transkribe ettiği Wolvox terimleri/ekran adları için düzeltme sözlüğü.
- **`reference/modul-derinlik.md` §2:** Seri No ↔ Lot ayrımı ve `Seri Lot Giriş Hareketi` ekranı üzerine yeni açıklayıcı not.
- **`reference/kurulum-playbook.md` §6 (D):** yeni alt-bölüm — şube (branch) sistem kapsam kuralları ve offline-erişim tuzakları.
- **`reference/perakende-entegrasyon.md` — yeni §3 "Wolvox Restoran":** garson/kurye/Caller ID akışları — önceden pakette dokümante edilmemiş bir ürün alanı.
- Kaynak: ~35 niş/bayi YouTube kanalı tarandı (bir bayi kanalı tohum olarak kullanıldı + keşfedilen ~26 ek kanal), 35 video transkripti damıtıldı. Video ID'leri/kanal adları KVKK ve kapsam disiplini gereği repoda değil, yalnızca gitignored yerel bir takip dosyasında tutuluyor.
- **Bu turda bilinçli olarak birleştirilmedi:** Wolvox Otel (otel) ürün ailesine dair ~3 bulgu — farklı bir ürün, olası ayrı/özel bir kampanyaya bırakıldı; belirsiz resmî-mi/bağımsız-mı statülü 9 aday kanal — insan kararı bekleniyor, hariç tutuldu.
### Değişti
- Sürüm 2.20.0 → **2.21.0**. `consistency-check.ps1` PASS.

## [2.20.0] — 2026-07-23
### Eklendi (Mode B güvenlik — salt-okunur bağlantı bootstrap'ı)
- **skill.md — "🔒 READ-ONLY LOGIN BOOTSTRAP" (Connection & Production-Safety altında, Mode B'nin zorunlu İLK adımı):** çoğu kurulumda Windows hesabı sysadmin/dbo olduğu için "salt-okunur"un disipline değil **yapıya** dayanması gerektiği vurgulandı. Adımlar: (1) DBA'nın bir kez oluşturduğu ayrı `wolvox_ro` login + HER `WOLVOX%` DB'sinde **yalnız `db_datareader`** (jenerik SQL; asistan çalıştırmaz, DBA'ya verilir), (2) yalnız bu login'le bağlan (Integrated Security bırak), (3) **KANIT testi** — sıfır-satır UPDATE dene → "permission denied" beklenir + `IS_SRVROLEMEMBER('sysadmin')=0` teyidi. Gitignored yerel profil, Firebird eşdeğeri, ASCII şema. SESSION BOOTSTRAP fact #4 bu bootstrap'a yönlendirildi.
### Değişti
- Sürüm 2.19.0 → **2.20.0**. `consistency-check.ps1` PASS.

## [2.19.0] — 2026-07-23
### Eklendi (native kapsam damıtma kampanyası — resmî eğitim videolarından)
- **`native-yetenek-indeksi.md` +3 bölüm (§12-14, ~21 satır):** **§12 e-Ticaret/Pazaryeri** (sipariş ödemeleri→Wolvox ERP + Entegrasyon Yönetimi portları, Trendyol/n11/HepsiBurada ürün gönderimi, pazaryeri API, havale/kapıda ödeme, ödeme haritası, kargo tanım/entegrasyon/desi, cari borç sorgulama); **§13 Hızlı Satış/POS** (iade, değişim, gün sonu + KK POS mutabakat, para üstü, veresiye, bekleme online/offline, kasa/stok menüsü, kasa-depo seçimi, çekmece, Market Otomasyonu terazi/ÖKC); **§14 Satınalma/Finans/Veri/Doküman** (Mal Kabul, Banka Online Veri Al [MT940/webservis], şubeler-arası Kasa Transfer Havuzu, Doküman Takip, Excel'den içe aktarım, eksiye-düşen manuel üretim).
- **`ozel-ayarlar.md` — "Sektörel/niş sekmeler" §11-17 `≈`→`📹`:** Banka, CRM, Servis (zengin), MRP2, Sanal Santral, Caller ID, Tıp/Su ayar sekmeleri video-damıtıldı (Performans hariç, hâlâ ≈). Paketin uzun süredir açık "damıtılmadı" boşluğu kapandı.
- Kaynak: resmî AKINSOFT eğitim kanalı (yeniden tarama: 1081 video; scope = masaüstü ERP boşlukları + e-Ticaret; cloud/tıp/n8n/niş atlandı). ~34 video damıtıldı; tüm satırlar `📹` (canlı ekranla `✓`'e yükseltilecek). Video ID'leri repo-dışı özel notta.
### Değişti
- Sürüm 2.18.0 → **2.19.0**. `consistency-check.ps1` PASS.

## [2.18.0] — 2026-07-23
### Eklendi (native-first ustalık — skill'in asıl amacı)
- **`reference/native-yetenek-indeksi.md` — Native Yetenek İndeksi** (yeni pack): *iş-ihtiyacı → yerleşik Wolvox özelliği → menü yolu → güven (`≈`/`📹`/`✓`) → tuzak*, 11 modül (~50 özellik: fiyatlandırma/reprice, stok, fatura, cari, e-Dönüşüm, muhasebe, POS/perakende, depo, üretim, kontrol paneli, servis/İK). "Önce native" refleksinin arama tablosu; mevcut paketlerden (ozel-ayarlar/menu-haritasi/kurulum-playbook) çekirdeklendi. Büyüyen indeks; canlı ekran teyidiyle `≈`/`📹`→`✓`.
- **skill.md — "ADIM 0: Native-First Kapısı"** (yeni bölüm, PRE-FLIGHT'tan önce): herhangi bir yazma/düzeltme/otomasyon önerisinden ÖNCE yerleşik özelliği ara; **"native-first ama dürüst"** (sınırını kullanıcının kuralına karşı açıkça söyle, kullanıcı seçsin); yalnız EYLEM için (ölçme/teşhis SQL birinci sınıf kalır); öz-denetim/ret deseni. Index reference-listesine + routing tablosuna (STEP 0 satırı) + order-of-operations'a işlendi.
### Değişti
- Sürüm 2.17.3 → **2.18.0**. Kaynak: gerçek bir reprice-otomasyonu vakasının dersi — refleks doğrudan SQL script'e gitti, Wolvox'un yerleşik reprice özelliği ancak kullanıcı "bunu Wolvox içinde yapamaz mıyız?" diye zorlayınca ortaya çıktı.

## [2.17.3] — 2026-07-19
### Değişti
- **LICENSE** telif sahibi: Anıl Özçelik (proje sahibinin tercihi).
- Yayın öncesi **son tam denetim** koşuldu: dosya kodlaması (tümü desen-taramasına uygun), repo genelinde sayı beyaz-liste denetimi, SQL örnek-değer envanteri, tüm "örnek" satırlarının insan-gözü incelemesi — temiz. `consistency-check.ps1` PASS.

## [2.17.2] — 2026-07-19
### Değişti (tam anonimleştirme — hiçbir örnek gerçek bir kurulumdan türetilmez)
- **LICENSE telif satırı** kişisel isimden **"The akinsoft-wolvox8-consultant contributors"**a çevrildi.
- **Tüm örnek yıllar/değerler nötr kurgusal değerlere sabitlendi** (bağlantı dizeleri, sqlcmd, BACKUP/RESTORE, çapraz-DB sorguları, tools örnekleri, "çalışma yılı takvimden geride" senaryoları — skill.md, cozum-desenleri P5/P21, sorun-giderme §6, dogrulama-testleri #8, vaka-catalogu Q84). Örnek değerlerin hiçbiri herhangi bir gerçek kurulumun değerleriyle örtüşmez.

## [2.17.1] — 2026-07-19
### Düzeltildi (yayın öncesi tam gizlilik denetimi — kritik)
- **Bekçinin kendisi sızdırıyordu:** `tools/consistency-check.ps1` içindeki gizlilik desen listesi, korumaya çalıştığı kuruluma-özel değerleri (instance adı, gerçek çarpan, iç proje etiketi) betiğin kendi metninde taşıyordu — ve betik yalnız `.md` taradığı için kendini hiç denetlemiyordu. Desenler iki katmana ayrıldı: jenerik yerleşikler repoda kalır; kuruluma özel desenler `tools/private-patterns.local.txt`'e taşındı (**gitignored** — asla yayınlanmaz; şablon: `private-patterns.sample.txt`).
- **Denetim kapsamı genişletildi:** gizlilik taraması artık `tools/*.ps1` (betiğin kendisi dâhil) ve `tools/*.md` dosyalarını da kapsıyor; diğer bölümler `tools/README.md`'yi de görüyor.
### Değişti
- `.gitignore` → `*.local.txt` eklendi. Sürüm 2.17.0 → **2.17.1**. Yayın öncesi tam tarama (kişisel ad/e-posta, video kimliği, sektör/şube/işletme-sayısı izleri, bağlantı dizeleri, gizli dosyalar) temiz; `consistency-check.ps1` PASS.

## [2.17.0] — 2026-07-19
### Eklendi (D: tanı sorguları — anlatıyı "ölçüm"e çevir)
- **Yeni paketlere salt-okunur tanı sorgusu şablonları** (skilin "ölç, iddia etme" doktrini; kolon uydurmadan, `<placeholder>`+keşif): **e-Defter ön-kontrol** (dengesiz fiş Σborç≠Σalacak + belge-türsüz fiş — turkiye-uyumluluk §8), **enflasyon sıfırlama kontrolü** (522/523/524/570/580/590/591 bakiye — §7), **ÖKC gün-sonu ödeme-türü mutabakatı** (KASAHR vs Z raporu — perakende §1), **"havada" servis fişi** (cari/stok hareketine işlenmemiş — modul-derinlik §3).
### Eklendi (E: sayısal sertleştirme)
- **`reference/hesaplama-ornekleri.md` — çalışılmış örnekler & kenar durumlar** (en pahalı sessiz-hata sınıfı): reprice `CEILING(×çarpan)−1` (çarpan=1 erozyonu + asimetri kapısı), KDV hariç↔dahil (`120×0,80` gibi yanlış-yöntem tuzakları), döviz→TL (JPY yüzde-100 `PARA_ORANI` + bayat kur), enflasyon **reel↔nominal kâr** (nominal 80 vs reel 30). skill.md ref+routing ("sayı üretiyorsan → hesaplama-ornekleri"), README, sorgu-recetesi §H geri-linki.
### Değişti
- Sürüm 2.16.0 → **2.17.0**. `consistency-check.ps1` PASS (exit 0).

## [2.16.0] — 2026-07-19
### Düzeltildi (tutarlılık denetimi — self-contradiction riskini sıfıra indirme)
- **6 iç çelişki bulundu ve düzeltildi:** (a) `reprice tetiği` yolu 4 yerde hâlâ eski **"Fatura Yerleri"** yazıyordu (altin-cevap-eval — **eval'ı yanlış cevaba göre puanlıyordu**, menu-haritasi, skill.md, CHANGELOG v2.10 kaydı) → hepsi **"Fatura Ayarları"**; (b) `BLCARIKODU` (skill.md) → kanonik **`BLCRKODU`**; (c) `CARI_UNVANI` (skill.md FB maskeleme) → kanonik **`TICARI_UNVANI`**. Ayrıca CONTRIBUTING'de bayat "8 test" → **22**.
### Eklendi
- **`tools/consistency-check.ps1` — repo tutarlılık & gizlilik denetçisi.** DB'ye bağlanmaz; repo dosyalarını okuyup **mekanik** olarak yakalar: gizlilik/şirket-verisi sızıntısı, **düzeltilmiş bir menü yolunun geri sızması**, kırık iç link, `skill.md` sürümü ≠ `CHANGELOG` en üst, schema-map dışı uydurma/sapan kolon adayı (uyarı). Exit 0/1 → CI/pre-commit'e uygun. ASCII-only (PS 5.1 encoding-güvenli).
- **CONTRIBUTING.md — "Commit öncesi tutarlılık kontrolü (ZORUNLU)"** bölümü: denetçiyi çalıştır + elle doğrulama (tek gerçek kaynağı = schema-map kolonları; düzeltince grep'le tüm kopyaları; sayaç iddiaları). PR kuralları güncellendi.
### Değişti
- Sürüm 2.15.0 → **2.16.0**. Repo `consistency-check.ps1`'ten **exit 0 (PASS)** geçiyor: gizlilik temiz, bayat string yok, tüm iç link çözülüyor, sürüm eşleşiyor.

## [2.15.0] — 2026-07-19
### Eklendi
- **`reference/danismanlik-metodolojisi.md` — danışmanlık angajman akışı** (yeni pack). Tüm paketleri bir yönteme dizer: Keşif (röntgen) → Değerlendirme (skor) → Önceliklendirme (20 bulgu) → Uygulama (playbook/ayar) → Teslimat (rapor) → Takip; her adımda hangi paket + değişmez disiplin (salt-okunur/yedek/PII/SMMM) + tek-bakış soru→paket tablosu. skill.md referans listesi + routing'e "baştan sona değerlendir → metodoloji" eklendi.
- **`dogrulama-testleri.md` 15 → 22 test:** yeni Bölüm E — reprice-tetiği ayar yeri (#16), enflasyon+SMMM (#17), KVKK anonimleştirme vs ham DELETE (#18), ÖKC gün-sonu mutabakat (#19), yedek-önce disiplini (#20), metodoloji akışı (#21), e-Defter berat denklik (#22). Puanlama /22.
### Değişti
- skill.md sürüm 2.14.0 → **2.15.0**. README metodoloji satırı + dogrulama "22 test" güncellendi.

## [2.14.0] — 2026-07-19
### Eklendi
- **`reference/perakende-entegrasyon.md` — Perakende entegrasyonları** `📹` (yeni pack). (1) **ÖKC / yeni nesil yazar kasa**: ortak kalıp (Kontrol Paneli e-Devlet 1 aktivasyon → cihaz seri/IP → eşleştir → **ödeme tanımı eşleştirme** → otomatik fiş) + Pavo N86 (Hızlı Satış içinden) ve Ingenico/PAX (Yazar Kasa Otomasyonu, cihazdan KDV/kısım/banka/yemek-kartı al). (2) **e-Ticaret/pazaryeri**: AKINSOFT e-Ticaret panel KDV/etiket ayarları, **Wolvox↔e-ticaret taksit/online tahsilat** (sanal POS ↔ taksit tanımı eşleştirme, durum "ödendi"), N11 kategori/kargo. Tuzaklar: overselling, ÖKC-GİB mutabakat, ödeme eşleşmezliği, komisyon/kargo maliyeti. 6 resmî video damıtıldı.
- **modul-derinlik §4** perakende paketine yönlendirildi (bu bölüm şema, o pack kurulum/davranış).
- skill.md referans listesi + routing ("POS/yazarkasa/e-ticaret/pazaryeri/taksit → perakende-entegrasyon"). Sürüm 2.13.0 → **2.14.0**.

## [2.13.0] — 2026-07-19
### Eklendi (kurulum-playbook §6 — Kontrol Paneli; resmî Kontrol Paneli serisi damıtıldı)
- **§6 Kontrol Paneli** `📹` — (A) **Yeni firma/şube kurulumu** (`Yetkili > Şirket Kayıt İşlemleri`: şirket bilgileri, muhasebe tipi/muhasebeci, veri yolu, offline, **çalışma alanı oluştur = DB yaratır**, Özel Bilgiler, e-Devlet 1 [e-Fatura/ÖKC/e-Defter/EADES], e-Devlet 2 [interaktif VD], şube+ortak modüller); (B) **Kullanıcı/yetki**; (C) **Yedekleme & Geri Yükleme** (`Veri Tabanı İşlemleri`: periyot/rotasyon/resim-hariç, manuel yedek, off-site+bulut "Akınsoft Yedekleme" programı, geri yükleme **GERİ DÖNDÜRÜLEMEZ** uyarısı, **DB bakım/güncelleme**). "Önce yedek" doktrininin ürün-içi yeri.
- **dba-performans §3** — Wolvox-native yedek/bakım (Kontrol Paneli > Veri Tabanı İşlemleri) ters referansı; SQL Agent yalnız DBA erişimi varsa.
- kurulum-playbook seçim refleksine firma/şube + yedekleme satırları. Sürüm 2.12.0 → **2.13.0**.

## [2.12.0] — 2026-07-19
### Değişti (modul-derinlik.md — Servis & İK tahminden video-teyitliye + kurulum-playbook §1)
- **§3 Teknik Servis `📖`→`📹`:** resmî Servis Yönetimi serisinden modül yapısı (Tanımlar: Servis/İşlem/Fiş Durumu/Marka-Model/Paket/Grup/Araç/Ürün · İşlemler: Servis Fişi/Randevu/Faturalama/Teslim/Bakım Sözleşmesi · Raporlar) + **Servis Fişi tam akışı** (cari/stok hareket işareti, seri+garanti takip, işlem kodu+durum, servis aracı→personel, dış servis, `Özel Ayarlar>Servis Ayarları` işlem/hizmet/bağımsız aktarım). **Bulgu:** servis **fiş durumu kullanıcı-tanımlıdır** (sabit enum değil) → kod-sozlugu mantığıyla UI'da doğrula.
- **§5 Bordro/İK `📖`→`📹`:** PDKS/giriş-çıkış akışı (vardiya→çalışma planı→takvim→mazeret; cihaz/kapı ekranı; 4 ücret hesap yöntemi), ihbar/kıdem tazminatı (son bodrodan otomatik + karşılık raporları), muhasebe entegrasyonu (tek hesap/departman bazında, Entegrasyon 2=SGK teşvik, ön muhasebe=personel cari "maaş" özel kod).
- **kurulum-playbook §1 e-Fatura** — aktivasyonun doğru yeri eklendi: `Kontrol Paneli > Yetkili Şirket Kayıt > e-Devlet 1` (e-Fatura/e-Arşiv sistemini kullan + EADES adres) + `e-Fatura Ayarları > Kullanıcı Bilgileri > Bağlantı Testi Yap` + **fatura kesme/gönderim akışı** (Yurtiçi Satış Faturası → `?` senaryo/tip → kaydet → e-Fatura Gönderimi > Seçilenleri Gönder). Sürüm 2.11.0 → **2.12.0**.

## [2.11.0] — 2026-07-19
### Eklendi (turkiye-uyumluluk.md derinleştirme — 8 resmî uyumluluk videosu damıtıldı)
- **§7 Enflasyon Muhasebesi (VUK mük. 298/A)** `📹` — `Genel Muhasebe > Genel Ayarlar > Ayarlar 2` aktivasyon, hesap planı düzenleme (enflasyon hesap tipi/düzeltme/fark kodu), sıfırlanacak hesaplar (522/523/524/570/580/590/591), Yİ-ÜFE "webden al", düzeltme yöntemleri (esas/basit-ort/hareketli-ort), YMY fişi, stok+demirbaş enflasyon, 698 kapanış, düzeltilmiş bilanço. Zamana-duyarlı + SMMM/YMM disiplini.
- **§8 e-Defter / Berat** `📹` — Kontrol Paneli e-Defter kaydı (şube/faaliyet kodu/veritabanı/muhasebeci), **fiş bütünlüğü kontrolü** (bakiye-denk + belge türü dolu), fiş sıralama, e-Defter programı imza/mühür, Yeni Defter > Defter Oluştur ve İmzala, **YB/KB berat** oluştur-imzala-gönder (erken "gönderildi" işaretleme tuzağı).
- **§9 KVKK Anonimleştirme (Wolvox yerleşik)** `📹` — native anonimleştirme aracı (tarih/imha evrak/yöntem/tablo seçimi/rapor/kayıt); "eski veri sil" isteğinde ham DELETE yerine bu araca yönlendirme → PII/KVKK doktrininin ürün-içi karşılığı.
- **§2/§3 UI akışları** `📹` — Wolvox'ta tevkifatlı fatura kesme (kart otomasyonu + fatura tipi + teklif/sipariş ayarı), istisna faturası (KDV=0+istisna kodu), **e-İhracat faturası** (IHR sayaç + VKN=2222222222 + İhracat senaryo + GTİP + teslim/taşıma), e-Müstahsil gönderim (Kontrol Paneli aktivasyon + ilk kesintiler + cari ayarı).
### Değişti
- `turkiye-uyumluluk.md` güven etiketine `📹` (video-damıtılmış uygulama akışı) eklendi; kaynaklar bölümü + skill.md compliance routing satırı genişletildi (enflasyon/e-Defter/istisna·ihracat·müstahsil/KVKK anonimleştirme). Sürüm 2.10.0 → **2.11.0**. (Kaynak videolar: resmî AKINSOFT eğitim kanalı; kimlikler repoda tutulmaz, danışman özel notunda.)

## [2.10.0] — 2026-07-19
### Eklendi
- **`reference/ozel-ayarlar.md` — Özel Ayarlar referansı (davranışı yöneten anahtarlar).** Resmî AKINSOFT "Özel Ayarlar" video serisinin **10 çekirdek sekmesi** (Genel/Stok/Cari/Fatura/İrsaliye/Sipariş/Teklif/Çek-Senet/Üretim/Depo) damıtılıp modül-bazlı *ayar → ne yapar → danışman tuzağı* kataloğuna dönüştürüldü (`📹`). "Program neden X yapıyor / nasıl yaptırırım" sorularının tek durağı. Öne çıkanlar: varsayılan döviz + tarih-değişince-kur-yeniden-aktar + aramada-pasif-stok (Genel), kara liste + ödenmemiş taksit uyarısı (Cari), hızlı-satış çarpan karakteri (Stok/POS), vade farkı sistemi + genel müşteri cari kodu (Fatura), transfer KDV aktarımı (İrsaliye), eksiye-düşen-stok-otomatik-üret/MRP-lite (Üretim), varsayılan depo (Depo).
### Değişti
- **Reprice tetiği yolu resmî kaynakla düzeltildi:** `Özel Ayarlar > **Fatura Ayarları** > Alış Faturası > "satış fiyatları oluşturma penceresini göster"` (önceki bayi-videosundan alınan "Fatura Yerleri" yaklaşık adı düzeltildi). Ek olarak yerleşik reprice'ın komşu seçenekleri belgelendi: **alış fiyatına KDV ekle · ek maliyet ekle · yeniden oluşturulacak satış fiyat sayısı**; ayrıca **üretim maliyetinden reprice** (`Üretim Ayarları`) eklendi. `menu-haritasi.md` + `kurulum-playbook.md §2` güncellendi.
- **skill.md** — `ozel-ayarlar.md` referans listesine + Reference Pack Routing'e ("program neden X / nasıl yaptırırım" → ozel-ayarlar) işlendi. Sürüm 2.9.0 → **2.10.0**.
- **Video külliyatı keşfi:** resmî "AKINSOFT Eğitim" kanalında ~670 video haritalandı; yüksek-değerli damıtma hedefleri belirlendi (Servis/İK/Kontrol Paneli/Enflasyon Muhasebesi/KVKK Anonimleştirme/POS-ÖKC) — sonraki turlar için.

## [2.9.0] — 2026-07-19
### Eklendi
- **`reference/kurulum-playbook.md` — implementasyon playbook'ları (danışman "sıfırdan kur" teslimatı):** e-Fatura/e-Arşiv kurulumu (e-Fatura Ayarları panelinin ~20 kutusu), **otomatik reprice** (`Özel Ayarlar > Fatura Ayarları > Alış Faturası > "satış fiyatları oluşturma penceresini göster"` — Wolvox'un yerleşik özelliği; doğru sekme adı v2.10.0'da "Fatura Yerleri" yazılmıştı, sonra düzeltildi), yıl-sonu muhasebe kapanışı + devir (`Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri`), stok/cari asgari kayıt. Adımlar resmî AKINSOFT eğitim videolarından damıtıldı; yedek/SMMM/salt-okunur disipliniyle.
- **`reference/rapor-sablonlari.md` — danışman teslimat şablonları:** yönetici sağlık raporu (1 sayfa), en kritik 20 bulgu tablosu, 30-60-90 aksiyon planı, tek-bulgu kartı. `{…}` yer tutucuları canlı taramadan doldurulur; sayılar repoya girmez.
- **`reference/modul-derinlik.md` — ince modül derinliği:** Üretim/Reçete (BOM/fason/sarf), Parti-Lot-Seri-No/SKT, Teknik Servis, Pazaryeri/e-Ticaret entegrasyonu, Bordro/İK (`_IKAYNAK`). Keşif-önce yaklaşımı (kolon uydurmaz); her modül için danışman soruları + tuzaklar + rapor değeri.
- **`reference/dba-performans.md` — DBA/performans & göç:** DMV teşhisleri (en pahalı sorgu, eksik indeks), sıcak-tablo indeks önerileri (inert DDL), bakım planı, kilit/deadlock, **8→9 ve MSSQL↔Firebird göç** + yıl/firma taşıma. Salt-okunur teşhis; yazma yetkisi müşteride.
- **`reference/altin-cevap-eval.md` — içerik-doğruluğu altın cevap seti (G1–G15):** soru → beklenen uzman anahtar-noktaları → kaçınılacak yanlış cevap. `dogrulama-testleri.md` (davranış) tamamlayıcısı — cevabın *doğru* olup olmadığını ölçer.
- **`tools/` — yt-dlp caption pipeline (repo dışı):** resmî AKINSOFT eğitim videolarından Türkçe altyazı → temiz transkript damıtma iş akışı kanıtlandı; menü/kurulum akışlarının kaynağı. (Araç ve video kimlikleri danışmanın özel notunda; repo genel kalır.)
### Değişti
- **`menu-haritasi.md` — `📹` güven kademesi eklendi** (resmî eğitim videosundan damıtılmış akış; etiket sözcüğü oto-altyazı kaynaklı olabilir). Stok Tanımları (tüm sekmeler + Devir Girişi + reprice tetiği), Cari Tanımları (tüm sekmeler), e-Fatura Ayarları paneli, Yıl-sonu/Devir + Dönem Sonu satırları `≈`→`📹` yükseltildi. Hızlı erişim/arama kutusu refleksi eklendi. Kaynak izlenebilirliği bölümü (video kimlikleri repoda değil).
- **`kod-sozlugu.md`** — Güven & kaynak notu (enum kodları Akınsoft'a özel dahili konvansiyondur, en iyi "kaynak" UI'da kayıt açmaktır; mevzuat kodları resmî → turkiye-uyumluluk). STOK **3 KDV alanı** (alış/perakende/toptan) ve `DOVIZ_KULLAN` video-teyitli (`📹`) eklendi.
- **skill.md** — 6 yeni referans paketi (menu-haritasi, kurulum-playbook, rapor-sablonlari, modul-derinlik, dba-performans, altin-cevap-eval) referans listesine ve Reference Pack Routing tablosuna işlendi.
### Gizlilik
- **Yeniden-fiyatlama örneği tamamen jenerikleştirildi.** Kuruluma özgü örnek çarpan literali nötr bir örnek değere ("kendi marjınız") ve özel-kod etiketi parametre/placeholder'a (`@ozelkod` / `N'<OZELKOD>'` / "kendi özel kodunuz") çevrildi: `sorgu-recetesi §H`, `vaka-catalogu-100`, `kurulum-playbook`, `skill.md`, `tools/reprice-preview.ps1`, `tools/README.md`. Repo artık hiçbir kuruluma özgü çarpan/etiket içermez.

## [2.8.0] — 2026-07-19
### Eklendi
- **`reference/cozum-desenleri.md`** — P1–P30 çözüm desenlerinin **kanonik SQL iskeleti + tuzak (gotcha)** hâli; vaka bankasından bir P# seçince sorgu sıfırdan kurulmaz, buradan alınır. Her desende Firebird farkı notu.
- **`tools/` klasörü — çalıştırılabilir salt-okunur betikler:** `reprice-preview.ps1` (asimetrik yeniden fiyatlama önizleme + inert `BEGIN TRAN…ROLLBACK` `.sql` taslağı üretir, **yazmaz**) ve `utilization-scorecard.ps1` (B1 Modül Benimseme + B2 Veri Kalitesi skorunu salt-okunur üretir). Parametreli, jenerik, `db_datareader` yeterli; hiçbir sunucu/DB/işletme verisi gömülü değil.
- **Firebird paritesi:** `sorgu-recetesi.md`'ye §Firebird diyalekt çeviri tablosu + FB reçete örnekleri; `schema-map.md`'ye `RDB$` introspection; `cozum-desenleri.md`'de her desende FB notu. (Önceden referans paketleri MSSQL-only idi.)
- **skill.md — Reference Pack Routing** doktrini: hangi soru için hangi paket açılır tablosu + "trap → route → P# → SELECT → UI/taslak" işlem sırası. Yeni `cozum-desenleri.md` referans listesine işlendi.
- **skill.md — DISCLAIMER bölümü:** AKINSOFT ile bağlı olmama, mali/hukuki tavsiye olmama, yedek/test-kopyası uyarısı.
### Değişti
- **`dogrulama-testleri.md` 8 → 15 test:** reprice/oto-fiyatlama, verimlilik skoru, P-desen yönlendirme, Mode A SQL-siz fallback ve **gizlilik/KVKK regresyon testleri** (#14–#15: repo somut şirket verisi barındırmamalı) eklendi; eski "örnek install" imalı test jenerikleştirildi.
- **`menu-haritasi.md` derinleştirildi:** reçete/desen çapraz-referans sütunu, kampanya/sadakat & daha çok işlem, "bilinen 8 vs 9 farkları" bölümü; güven etiketi netleşti (`≈` yaklaşık / `✓` saha-teyitli — **henüz `✓` yok**, dürüstlük).
### Düzeltildi
- **Kırık `sorun-giderme.md` linkleri:** dosya repo kökünden `reference/`'e taşındı; skill.md ve README linkleri artık çözülüyor.
- skill.md'de "verified on this install" ifadesi "standard Wolvox 8 naming (verify per install)" olarak jenerikleştirildi.

## [2.7.0] — 2026-07-19
### Eklendi
- **Vaka bankası 1000'e tamamlandı.** `vaka-bankasi.md`'ye domain 6–14 (#451–#1000) eklendi: e-Dönüşüm, KDV/ÖTV/Tevkifat, Genel Muhasebe & çapraz-DB, Sipariş/Tedarik/Depo, Çek-Senet/Banka/Kasa, Çoklu-yıl/Devir/Dönem, Varyant/Üretim/POS, Veri Sağlığı/Anti-pattern/KVKK, Performans/DBA/Güvenlik/Bakım. Toplam **100 tam-çözümlü bayrak vaka + 900 yoğun bank = 1000 vaka**, hepsi P1–P30 çözüm desenlerine bağlı. Doğrulama: 900 soru #101–#1000, boşluk/duplike/geçersiz-referans yok, 14 domain, 30 desen.
- **Tümü jeneriktir** — gerçek işletme verisi/sayısı içermez.

## [2.6.0] — 2026-07-18
### Eklendi
- **`reference/vaka-bankasi.md` — Çözüm Deseni Kütüphanesi (P1–P30) + genişletilmiş vaka bankası.** Vaka sayısını 1000'e taşıma çalışması: 100 tam-çözümlü bayrak vakaya (`vaka-catalogu-100.md`) ek olarak **yoğun formatta yüzlerce komplike soru** (her biri: soru — tuzak — desen referansı). Asıl "öğreten" katman **30 tekrar-kullanılabilir çözüm deseni** (asimetrik güncelleme, KDV hariç/dahil, çapraz-DB, belge-zinciri, maliyet/son-alış, yaşlandırma, PII/KVKK, otomasyon-yöntemi, inert migration, devir, ABC, sepet, reel/enflasyon, performans, etik-sınır …) — model bir soruyu ilgili desene bağlayıp çözer. İlk blok: **desenler + domain 1–5 (#101–#450, fiyatlandırma/stok/maliyet/cari/fatura)**; domain 6–14 (#451–#1000) sonraki sürümlerde eklenecek.
- skill.md referans listesine işlendi; "yeni soru → önce uygun P# desenini seç" yönergesi. **Not:** bu genişletme de tamamen jeneriktir; gerçek işletme verisi içermez.

## [2.5.0] — 2026-07-18
### Eklendi
- **`reference/verimlilik-skoru.md` — "Verimli Kullanım Skoru" taraması.** İşletmenin Wolvox'u ne kadar verimli kullandığını tek **0–100** skoruna indiren, salt-okunur ve tekrarlanabilir bir rubrik: 5 ağırlıklı boyut (Modül Benimseme %25, Veri Kalitesi %25, Özellik Derinliği %20, Süreç Bütünlüğü %20, Bakım/Temizlik %10), her boyutun SQL metrikleri, not bandı (A–E), Mod A/Mod B uygulaması ve **en yüksek getirili aksiyonlar**. Dosya gerçek işletme verisi içermez; skoru kullanıcı kendi kurulumunda üretir.
- skill.md referans listesine işlendi; "verimli kullanıyor muyum / sistem röntgeni" sorularında kullan yönergesi.

## [2.4.0] — 2026-07-18
### Eklendi
- **`reference/vaka-catalogu-100.md` — 100 çözülmüş komplike danışman vakası.** 14 modül-kategorisine (fiyatlama, stok/envanter, maliyet/kârlılık, cari/alacak/risk, fatura/satış, e-Dönüşüm, KDV/ÖTV/tevkifat, genel muhasebe/çapraz-DB, sipariş/tedarik/depo, çek-senet/banka/kasa, çoklu-yıl/devir, varyant/üretim/POS, veri-sağlığı/KVKK, performans/DBA) yayılmış; her vaka **naif cevabın kaçırdığı "tuzağı"** (asimetri, alt-küme, KDV hariç/dahil, döviz-ayrımı, çapraz-DB, devir, PII) + tablo/kolon + UI yolu + beyan edilecek varsayımla çözülmüş. Amaç: skill'in "önce tuzağı gör" uzmanlık refleksini kalıcılaştırmak.
- skill.md referans-paketi listesine katalog işlendi; "önemsiz olmayan analiz/bul/düzelt sorularından önce kataloga bak" yönergesi eklendi.

## [2.3.0] — 2026-07-18
### Eklendi
- **Otomatik Yeniden Fiyatlama** bölümü — skill.md'de doktrin (formül/simetri/kapsam/maliyet-bazı + A yerleşik-marj / B toplu-betik / C trigger-reddi yöntem seçimi) ve `sorgu-recetesi.md` §H'de tam reçete: alt küme işaretleme (Özel Kod), STOKHR'den son-alış, **asimetrik önizleme** (`CEILING(×çarpan)−1`, sadece-yükselt), inert `BEGIN TRAN … ROLLBACK` migration taslağı.
- **Mode A (offline/erişimsiz) güçlendirildi** — varsayılan yüzey olduğu vurgulandı; her bulgu için "kendi kendine yeten kit" (bulgu → kopyala-yapıştır SQL → nerede çalıştırılır → ne geri yapıştırılır → UI düzeltme yolu), paste-back döngüsü, ve **SQL bilmeyen kullanıcı için UI-only fallback**.
- **Şema kolonları (jenerik):** `STOK.OZEL_KODU1/2/3` (genelde 3 slot, OZEL_KODU4 yok), `STOK_FIYAT.KAR_MARJI`/`KAYNAK_FIYAT_TIPI`/`KAYNAK_FIYAT_INDEX`/`ALIS_FIYATI_DEGISTI`, ve yeni **STOKHR** kolon bölümü (`TUTAR_TURU`, `KPB_FIYATI`, `IADE`/`DEVIR`, `DOVIZ_ALIS` + son-alış kalıbı) schema-map'e işlendi. Bir kurulumda yerleşik marjın fiilen kullanılıp kullanılmadığı **install'da taranır** — özel/asimetrik kural gerekiyorsa toplu betik.

## [2.2.0] — 2026-07-18
### Düzeltildi (önemli)
- **"Genel Muhasebe kullanılmıyor" yanılgısına karşı uyarı** — muhasebe verisi ayrı `_GMUHASEBE` veritabanındadır; tek DB'ye bakıp "kullanılmıyor" denmemeli. skill.md, schema-map, sorun-giderme düzeltildi. Kök sebep: DB adındaki `<modül>` parçası veriyi ayrı DB'lere böler.
- **`SILINDI` fazla-genellemesi** (Haiku doğrulama testinin yakaladığı hata): `STOK`/`STOK_FIYAT`/`FATURAHR`/`DOVIZ`'de `SILINDI` yok — ön-uçuş checklist'i ve kod sözlüğü, kolonun var olduğu yerlerde filtrelemeyi öğretecek şekilde düzeltildi.
- Firebird: `ISNULL` yerine `COALESCE` notu eklendi.

### Eklendi
- **Çapraz-DB / çoklu-yıl analizi** bölümü (üç-parçalı adlandırma, `sys.databases` keşfi, modül-DB gerçeği).
- **Maliyet & Kârlılık** ve **Dönem/Devir** bölümleri (2.1.0'da başlamıştı, genişletildi).
- Referans reçeteleri: **denetim izi** (`DEGISIM_LOG`, `STOK_FIYAT_DEGISIM_LOG`), **varyant (beden/renk)**, **eksik-index DMV**, **yedek/restore ile kopyada çalışma**.
- Ön-uçuş sonrası davranış kuralları: **güven etiketi (✅/📖/⚠️)**, **varsayım/eşik şeffaflığı**, **ret (refusal) şablonu**, referans-paketi kullanan **Örnek 3**.
- **Yüzeye özel kurulum** (Claude Code / Projects / Custom Instructions) — referans paketlerinin her yüzeyde nasıl yükleneceği.
- `CONTRIBUTING.md` — katkı + "kendi kurulumuna uyarla" hızlı başlangıç. Çok-fiyat-listesi (`CARI.STOK_FIYATI`) ve `DOVIZ.PARA_ORANI` notları.
- **Doğrulama:** taze Haiku örneğinde 8 davranış testi uygulandı → 7.5/8 (tek defekt yakalandı ve giderildi).

## [2.1.0] — 2026-07-18
### Eklendi
- **Çok-dosyalı referans paketi** (`reference/`):
  - `schema-map.md` — jenerik Wolvox şema haritası (tablo rolleri, anahtar kolonlar, ilişki haritası, KVKK/PII kayıt defteri).
  - `sorgu-recetesi.md` — salt-okunur tanı sorguları (veri sağlığı, ölü stok, cari bakiye, askıda e-fatura).
  - `kod-sozlugu.md` — kodlanmış `smallint` enum alanlarının çözümü (`TUTAR_TURU`, `EVRAK_TURU`, `ISLEM_TURU`, `EFATURA_DURUM`, `SIPARIS_DURUMU`, …).
  - `sorun-giderme.md` — semptom→neden→çözüm sorun giderme playbook'u.
  - `menu-haritasi.md` — UI menü yolu katalogu (YouTube/resmî yardım damıtma iskeleti).
  - `dogrulama-testleri.md` — skill'i herhangi bir Claude'da ölçen 8 davranış testi.
- **Zorunlu ön-uçuş checklist'i** (SILINDI filtresi, kolon doğrulama, PII maskeleme, diyalekt, salt-okunur) — zayıf modelleri bile hizada tutar.
- **"Evrensel gerçek vs bu-install gözlemi"** ayrım kapısı — install-özel bulguların başka DB'lere yanlış uygulanmasını önler.
- **Maliyet & Kârlılık metodolojisi** ve **Dönem/Çalışma Yılı/Devir** bölümleri.

### Düzeltildi
- e-Dönüşüm bölümü hayalî `EFATURA` tablosu yerine gerçek `FATURA.EFATURA_DURUM/GIB_DURUM` modelini öğretiyor.
- PII maskeleme örneği gerçek kolon adlarını kullanıyor (`TICARI_UNVANI`, `E_MAIL`).
- İlişki haritası ve tüm pillar sorguları röntgenle doğrulanmış tablolara güncellendi (`FATURAHR`, `CARIHR`, `STOKHR`; `BLCRKODU`; `KPB_CMIK`; `MIKTAR_MINIMUM`) + `SILINDI=0` filtreleri.

## [2.0.0] — 2026-07-17
### Eklendi
- Çalışma Modları (A/B) + Oturum Açılış Protokolü; Bağlantı & Canlı-ERP güvenliği; Türkiye Uyumluluk Domaini (e-Dönüşüm, KDV/ÖTV/Tevkifat, muhasebe); Sürüm/Edisyon tespiti; örnek diyaloglar; etik/yasal sınırlar; Firebird eki (Appendix A); Türkçe sözlük (Appendix B); config/log tanıları (Appendix C).

## [1.0.0] — 2026-07-17
### Eklendi
- İlk `skill.md`: rol & kimlik, güvenlik, STOK/STOK_FIYAT/DOVIZ şema çekirdeği, 5 stratejik sütun, çıktı standartları.
