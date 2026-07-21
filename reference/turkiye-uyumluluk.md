# Türkiye Uyumluluk — Sert Gerçekler (KDV · Tevkifat · e-Fatura · GİB Kodları)

> Genel SQL bilenlerin bilmediği, **bir Türkiye ERP danışmanının ezbere bildiği** mevzuat sabitleri.
> Bunlar **işletme verisi değil, kamu-mevzuat gerçekleridir** → repo'ya girmesi gizliliği bozmaz,
> aksine "kurulumda tara" hedging'ini gerçek bilgiyle değiştirir.
>
> ⚠️ **ZAMANA DUYARLI.** Oranlar/kodlar mevzuatla değişir. Bu paket **2026-07'de** kamuya açık resmî/
> yarı-resmî kaynaklardan derlendi. **Bir mükellefe kesin oran/kod söylemeden önce güncelini teyit et**
> (GİB + mali müşavir). Güven etiketi: `✅` = resmî/çoklu-kaynak doğrulandı · `📹` = resmî Wolvox eğitim
> videosundan damıtılmış **uygulama akışı** (adım/menü kaynak-teyitli; etiket sözcüğü oto-altyazı kaynaklı) ·
> `📖` = yerleşik uygulama · `⚠️` = değişken/teyit gerek.

---

## 1) KDV Oranları  `✅`
Türkiye'de üç KDV oranı vardır. **10.07.2023**'ten beri (Resmi Gazete 32241, Cumhurbaşkanı Kararı 7346):

| Oran | Kapsam (özet) | Not |
|--:|---|---|
| **%1** | Temel gıda (I sayılı liste), bazı tarım, gazete/dergi, cenaze | Değişmedi |
| **%10** | II sayılı liste (eski **%8**) — birçok gıda, tekstil, ilaç, konaklama vb. | 08→10 (10.07.2023) |
| **%20** | Genel oran (eski **%18**) — listelerde olmayan her şey | 18→20 (10.07.2023) |

- **Danışman refleksi:** Wolvox'ta `STOK.KDV_ORANI` hâlâ **8 veya 18** taşıyan aktif kartlar =
  güncellenmemiş olabilir → **raporla, otomatik değiştirme** (mevzuat + SMMM onayı; bazı ürünler
  gerçekten %1/%10 olabilir). Bkz. skill.md "KDV/ÖTV/Tevkifat" ve `sorgu-recetesi`.
- **Tuzak:** KDV oranı değişince **KDV hariç net fiyat sabitse brüt (raf) değişir**; raf fiyatını sabit
  tutmak isteyen net fiyatı düşürmeli (bkz. P2 KDV hariç↔dahil). Hangisini istediğini kullanıcıya sor.
- 08.2023'te sabun/deterjan/ıslak mendil/tuvalet kâğıdı/peçete %8'den **%20**'ye taşındı (II. listeden çıktı). `⚠️`
- **Sabit sanma:** yeni bir Cumhurbaşkanı Kararı oranları yine değiştirebilir → tarih damgasıyla teyit et.

## 2) KDV Tevkifatı — Kod/Oran Matrisi  `✅` (2024 dönemi; oranlar değişebilir)
"Sorumlu sıfatıyla KDV": alıcı, KDV'nin bir kısmını satıcıya ödemeyip doğrudan vergi dairesine öder.
Oran `x/10` = tevkif edilen pay. e-Faturada **tevkifat kodu + oranı** zorunlu alandır.

### Hizmet tevkifatı
| Kod | Hizmet | Oran |
|--:|---|--:|
| 601 | Yapım işleri + mühendislik-mimarlık, etüt-proje (yapıma bağlı) | 4/10 |
| 602 | Etüt, plan-proje, danışmanlık, denetim vb. | 9/10 |
| 603 | Makine/teçhizat/demirbaş/taşıt tadil-bakım-onarım | 7/10 |
| 604 | Yemek servis hizmeti | 5/10 |
| 605 | Organizasyon hizmeti | 5/10 |
| 606 | İşgücü temin hizmeti | 9/10 |
| 607 | Özel güvenlik hizmeti | 9/10 |
| 608 | Yapı denetim hizmeti | 9/10 |
| 609 | Fason tekstil/konfeksiyon/çanta/ayakkabı dikim | 7/10 |
| 610 | Turistik mağazalara müşteri bulma/götürme | 9/10 |
| 611 | Spor kulüplerinde yayın/reklam/isim hakkı | 9/10 |
| 612 | Temizlik hizmeti | 9/10 |
| 613 | Çevre/bahçe bakım hizmeti | 9/10 |
| 614 | Servis (personel) taşımacılığı | 5/10 |
| 615 | Her türlü baskı/basım hizmeti | 7/10 |
| 616 | 5018'e ekli idarelere yapılan diğer hizmetler | 5/10 |

### Teslim (mal) tevkifatı
| Kod | Mal | Oran |
|--:|---|--:|
| 617 | Hurda metalden külçe teslimi | 7/10 |
| 618 | Hurda dışı bakır/çinko/alüminyum/kurşun külçe | 7/10 |
| 619 | Bakır/çinko/alüminyum/kurşun ürün teslimi | 7/10 |
| 620 | İstisnadan vazgeçenlerin hurda/atık teslimi | 7/10 |
| 621 | Metal/plastik/lastik/kauçuk/kâğıt/cam hurda-atık | 9/10 |
| 622 | Pamuk, tiftik, yün-yapağı, ham post/deri | 9/10 |
| 623 | Ağaç ve orman ürünleri | 5/10 |
| 624 | Yük taşımacılığı | 2/10 |
| 625 | Ticari reklam hizmeti | 3/10 |
| 626 | Diğer teslimler (demir-çelik dışı belirlenen) | 2/10 |
| 627 | Demir-çelik ürünleri teslimi | 5/10 |

- **Danışman refleksi:** tevkifatlı satışta oran/kod boş veya yanlışsa **e-Fatura GİB'de reddedilir**
  veya alıcıyla uyuşmazlık çıkar. Wolvox'ta tevkifat kartta/işlemde tanımlanır; eksik tanımı **tespit et**.
- **Tuzak:** 2023 düzenlemesiyle birçok hizmet **9/10**'a çıktı (temizlik, danışmanlık, güvenlik…);
  eski oranla (ör. 7/10 temizlik) kurulu kartlar **eski** olabilir → oranı yürürlük tarihine göre teyit et. `⚠️`
- **Sınır:** tevkifat, belge bazında bir **alt sınırın** üstünde uygulanır (yıllık güncellenen tutar) —
  kesin tutarı yıl bazında GİB'den doğrula. `⚠️`

**Wolvox'ta tevkifatlı fatura kesme akışı** `📹`
1. Fatura > Cari bul → hareketler alanına stoğu ekle → satırda **tevkifat oranı + tevkifat kodu** gir
   (alanlar görünmüyorsa ilgili butondan aç).
2. **Otomasyon:** Stok kartında **satış tevkifat kod/oranı** (ve alış için ayrı) tanımlıysa faturaya
   **otomatik** gelir — her faturada elle girmekten kurtarır; eksik tanımı tespit et.
3. Fatura tamamlanınca e-Fatura/e-Arşiv `?` butonundan **fatura tipi = Tevkifat Faturası** seç → kaydet.
4. **Teklif/Sipariş'te** tevkifat: `Genel Ayarlar > Program Ayarları > "teklif ve sipariş modüllerinde
   tevkifat sistemini kullan"` işaretle. → [ozel-ayarlar](ozel-ayarlar.md).

## 3) e-Fatura Senaryoları (EFATURA_SENARYO)  `✅`
Senaryo = belgenin hangi iletişim modelinde gittiği ve kabul/red mekanizması.

| Senaryo | Ne zaman | Kabul/Red |
|---|---|---|
| **TEMELFATURA** | En yaygın; gönderilince alıcı sistemde **otomatik kabul** sayılır | Alıcı **sistemsel RED edemez** (itiraz haricî: KEP/noter/iade) |
| **TICARIFATURA** | B2B, itiraz hakkı istenen satış | Alıcı 8 gün içinde **kabul/red** edebilir |
| **IHRACAT** | Yurt dışına satış; GTB/gümrük süreci | Özel; gümrük onayı akışı |
| **YOLCUBERABERFATURA** | Tax-free (yolcu beraberi eşya) | Özel |
| **KAMU** | Kamuya (merkezî yönetim) fatura | Özel |
| **HKS / EARSIVBELGE** vb. | Hâl kayıt sistemi / e-Arşiv belge senaryoları | Kuruluma/uygulamaya göre |

- **Danışman refleksi:** "Fatura gitti ama karşı taraf görmedi" şikâyetinde **senaryoya bak** —
  TEMEL'de red yoktur, TİCARİ'de red/itiraz akışı vardır. Wolvox alanı `FATURA.EFATURA_SENARYO`
  (adı sürümde değişebilir → şema-first teyit).
- **Temel vs Ticari seçim kuralı:** itiraz/red hakkı gerekiyorsa **TİCARİ**; hız/otomasyon isteniyorsa
  **TEMEL**. Yanlış senaryo, mutabakat/iade sürecini bozar.

**Wolvox'ta özel senaryo faturaları kesme akışı** `📹`
- **İstisna faturası** (KDV yok / kanunî istisna): hareket satırında **KDV=0** yap → **istisna kodunu**
  butondan seç (kod stok kartına kayıtlıysa otomatik gelir) → `?` > **fatura tipi = İstisna Faturası**.
  İstisna kodları programda tanımlıdır; [Stok kartı istisna/tevkifat büyüteci](menu-haritasi.md).
- **e-İhracat faturası:** (a) `Yetkili > Sayaç İşlemleri`'nden **e-ihracat no sayacı** oluştur, **şablon
  kodu = IHR**; (b) cari kartı: **ülke yurtdışı**, **VKN = `2222222222`** (GİB'in yurtdışı alıcı kriteri),
  Hesap Bilgileri > e-Fatura kullan, **senaryo = İhracat**, döviz hesabı aktif + varsayılan döviz; (c) stok
  kartı `Özel Ayarlar 2 > GTİP numarası`; (d) faturaya eklenince **teslim/ödeme ülkesi-ilçesi + taşıma
  şekli** doldurulur. Sonra e-İhracat olarak gönderilir.
- **e-Müstahsil (e-MM)** (çiftçiden/müstahsilden alım, stopajlı): (a) `Kontrol Paneli > e-devlet >
  "e-Müstahsil sistemi kullan"`; (b) `Fatura Ayarları > İlk Kesintiler > "varsayılan e-müstahsil
  kesintilerini yükle"` (kesinti oran/sabit tutarları — uluslararası kod otomatik); (c) cari Hesap
  Bilgileri > **e-Müstahsil kullanımı = Evet**; (d) alış faturasına cari+ürün ekle → "kesintileri
  sabitlerden güncelle" → gönder. → müstahsil = **alış** tarafı belgesi.

## 4) e-Fatura mı e-Arşiv mi? Karar mantığı  `📖`
- **Alıcı e-Fatura mükellefi mi?** → EVET ise **e-Fatura** kesilir (zorunlu). Wolvox: `CARI.EFATURA_KULLAN=1`
  ve GİB mükellef listesi eşitlemesi. HAYIR ise:
- **Sen e-Arşiv mükellefi misin?** → EVET ise mükellef olmayana/nihai tüketiciye **e-Arşiv** kesilir.
- **Nihai tüketici + belirli tutar üstü** → e-Arşiv zorunlu olabilir (yıllık sınır; GİB'den teyit `⚠️`).
- **Tuzak:** alıcı e-Fatura mükellefi olduğu hâlde **kâğıt/e-Arşiv** kesmek **usulsüzdür** → mükellef
  listesini güncel tut; eşitlenmemiş liste en sık hatadır (bkz. `sorun-giderme` §4).

## 5) GİB e-Belge Durum Kodları  `✅`
Wolvox'ta `FATURA.EFATURA_GIB_DURUM` (sayısal) bu GİB zarf/işlem kodlarını taşır. Anlamları:

| Kod | Anlam | Sınıf |
|--:|---|---|
| 1000 | Zarf kuyruğa eklendi | ⏳ beklemede |
| 1100 | Zarf işleniyor | ⏳ beklemede |
| 1110 | ZIP formatı değil | ❌ hata |
| 1111 | Zarf ID uzunluğu 32 değil | ❌ hata |
| 1120 | Arşivden kopya alınamadı | ❌ hata |
| 1130 | ZIP açılamadı | ❌ hata |
| 1150 | Schematron kontrol hatası | ❌ hata |
| 1160 | XML şema kontrolü başarısız | ❌ hata |
| 1163 | Daha önce kayıtlı faturanın tekrar gönderimi | ❌ hata |
| 1170 | Yetki kontrol edilemedi | ❌ hata |
| **1200** | **Zarf başarıyla işlendi** (GİB kabul; teslim henüz bitmedi) | ✅ başarı(ara) |
| 1210 | Adrese gönderilemedi, yeniden deneniyor | ⏳ beklemede |
| 1215 | 4 denemeden sonra başarısız, gönderim sonlandı | ❌ hata |
| 1220 | Alıcıdan yanıt bekleniyor (kutusunda) | ⏳ beklemede |
| 1230 | Alıcıdan **başarısız** sistem yanıtı geldi (aynı ID ile tekrar gönderilebilir) | ❌ hata |
| **1300** | **Başarıyla tamamlandı** (alıcı sistemine ulaştı ve işlendi) | ✅ başarı |

- **Danışman refleksi:** "askıda/gitmedi" analizi = `EFATURA_DURUM=1` **veya** `EFATURA_GIB_DURUM`
  ∉ {1200,1300} olanlar. **1200 ≠ teslim tamam** — nihai başarı **1300**'dür; 1220 alıcı kutusunda bekliyor.
  Hata kümesi {1110…1170,1215,1230} → kök sebep + yeniden gönderim. Bkz. `sorgu-recetesi` C1/C2, P19.
- **Tuzak:** kod anlamları **entegratör/GİB sürümüne göre** ek/ara kodlar içerebilir → bir örneği
  UI'da (*e-Dönüşüm > Belge Durumu*) teyit et (`📖`), tek koddan genelleme yapma.

## 6) Diğer e-Dönüşüm belgeleri (kısa)  `📖`
- **e-Arşiv:** e-Fatura mükellefi olmayana/nihai tüketiciye; rapor GİB'e günlük gönderilir.
- **e-İrsaliye:** sevk belgesi; Wolvox `IRSALIYE.EIRSALIYE_DURUM/EIRSALIYE_GIB_DURUM` (P19 mantığı aynı).
- **e-SMM** (serbest meslek makbuzu), **e-MM** (müstahsil), **e-Defter/Berat** (aylık, YMM ile),
  **e-Waybill/e-Adisyon** sektörel. Wolvox edisyonuna göre modül mevcudiyeti değişir → teyit et.

## 7) Enflasyon Muhasebesi (VUK mük. 298/A)  `📹`  ⚠️ zamana-duyarlı + SMMM
2023 sonundan itibaren şartları tutan mükellefler için **enflasyon düzeltmesi** zorunlu hâle geldi
(yüksek endeks eşiği). Wolvox Genel Muhasebe bunu modül olarak destekler. **Uygulama adımları ≠ mali karar**
— düzeltme yapılıp yapılmayacağı, yöntem ve dönem **SMMM/YMM** ile belirlenir.

**Kurulum & akış** (`Genel Muhasebe`):
1. **Aç:** `Genel Muhasebe > Genel Ayarlar > Ayarlar 2 > "Enflasyon muhasebe sistemi kullan"` aktif et.
2. **Hesap planı düzenleme:** ilgili hesaplara **enflasyon hesap tipi · düzeltme hesap kodu · fark hesap
   kodu** gir; "Enflasyon İşlemi" bölümünden **varsayılan hesap tipi/kodlarını aktar**.
3. **Sıfırlanacak hesaplar** (düzeltme öncesi): **522, 523, 524, 570, 580, 590, 591** → dönem sonu
   yansıtma veya enflasyon modülünde "hesapların kapatılması".
4. **Yİ-ÜFE oranları:** düzeltme tablosunda **"Webden al"** → önceki yıllarla birlikte otomatik aktarılır.
5. **Düzeltme:** hesap koduna "düzeltme ekle"; yöntem = **esas / basit ortalama / hareketli ortalama** →
   **YMY (düzeltme) fişi oluştur**.
6. **Stok:** "stok topla enflasyon hesaplama". **Demirbaş:** Demirbaş kaydında **"enflasyon muhasebesi
   uygula"** işaretli olmalı + düzenleme/fark/amortisman-düzenleme/amortisman-fark hesap kodları; toplu
   enflasyon hesapla → kayıtlar oluştur.
7. **Kapanış:** son adım **698 Enflasyon Düzeltme Hesabı** kâr/zarara aktarım → "hesapların kapatılması";
   bakiye listesi > dönem aralığı > hesapla > YMY fişi.
8. **Çıktı:** ayrıntılı/özet bilançoda **"enflasyon fişleri dahil"** seçeneğiyle **düzeltilmiş bilanço**.

> Danışman notu: rakamsal formüller/eşikler yıla göre değişir; **kesin uygulama SMMM ile**. Bu akış
> operasyonel rehberdir, vergi görüşü değildir.

**Tanı sorgusu — sıfırlanması gereken hesaplarda bakiye var mı?** `📖` salt-okunur, `_GMUHASEBE` DB'sinde:
```sql
-- ⚠️ kolon adlarını install'da doğrula. Adım 3'teki hesaplar düzeltme öncesi SIFIR olmalı
SELECT HESAP_KODU, SUM(BORC)-SUM(ALACAK) AS bakiye
FROM <MUH_HAREKET>
WHERE LEFT(HESAP_KODU,3) IN ('522','523','524','570','580','590','591')
GROUP BY HESAP_KODU
HAVING SUM(BORC)-SUM(ALACAK) <> 0;   -- dönen hesaplar önce kapatılmalı (dönem sonu yansıtma / modül)
```

## 8) e-Defter / Berat (aylık, YMM onaylı)  `📹`
Yevmiye ve kebir defterlerinin elektronik oluşturulup **beratının GİB'e** gönderilmesi. Wolvox'ta iki ayak:
**Kontrol Paneli kaydı** + **Genel Muhasebe fiş bütünlüğü** + **e-Defter programı imza/berat**.

1. **Kayıt:** `Kontrol Paneli > Yetkili Şirket Kayıt İşlemleri > e-Defter (e-devlet)` — başlangıç tarihi,
   **şube no/adı, faaliyet kodu, son madde no, veritabanı, yönetici adı** (fişlerin hangi isimle
   aktarılacağı); Özel Bilgiler > mail + web; **Yetkili Muhasebeci Kayıt** (sözleşme+bilgiler) → şirket
   kaydında muhasebeci seç.
2. **Fiş bütünlüğü kontrolü (kritik):** `Genel Muhasebe > Eski Fişler` — (a) **fiş bakiyesi verenleri
   filtrele → hiçbir fiş bakiye vermemeli** (denk olmalı); (b) **belge türü boş** olanları topluca
   güncelle; (c) tarih aralığı ile filtrele.
3. **Fiş sıralama:** aylık ya da tarih aralığı; gönderilecek ay seç; önceki ay gönderildiyse **son fiş
   numarasından devam**; "sıralanmaya başla".
4. **e-Defter programı > Ayarlar:** çıktı dizini; **e-imza / mali mühür**; (yedekleme için entegratör).
5. **Yeni Defter Ekle** (yevmiye/kebir, başlangıç-bitiş) > kaydet > **Defter Oluştur ve İmzala** (mühür takılı).
6. **Berat oluştur ve imzala:** **YB (yevmiye berat) + KB (kebir berat)**; "gidip gönder" klasörü oluşur →
   GİB'e yükle. ⚠️ **Tamamen gönderilmeden "gidip gönderildi" butonuna BASMA.** Gönderim sonrası onaylı
   beratları defterler klasöründe ilgili aya yapıştır + zipten çıkar.

> Danışman notu: e-Defter **aylık** ritimdir ve **YMM/SMMM** onayı gerektirir; en sık hata **denksiz fiş**
> (adım 2) ve **eksik berat gönderiminde erken "gönderildi" işaretlemek**.

**Tanı sorgusu — e-Defter ön-kontrol (denksiz + belge-türsüz fiş)** `📖` salt-okunur, `_GMUHASEBE` DB'sinde:
```sql
-- ⚠️ tablo/kolon adlarını install'da doğrula (INFORMATION_SCHEMA); adlar sürüme göre değişir
-- 1) DENGESİZ fişler: her fişte Σborç = Σalacak olmalı; değilse e-Defter reddedilir
SELECT FIS_NO, FIS_TARIHI, SUM(BORC) borc, SUM(ALACAK) alacak, SUM(BORC)-SUM(ALACAK) fark
FROM <MUHASEBE_FIS_SATIR>
GROUP BY FIS_NO, FIS_TARIHI
HAVING SUM(BORC) <> SUM(ALACAK);
-- 2) Belge türü boş fişler (GİB zorunlu alan → berat öncesi topluca doldur)
SELECT COUNT(*) FROM <MUHASEBE_FIS> WHERE ISNULL(BELGE_TURU,'') = '';
```
> Sıfır satır dönmeli. Dönenler **berat almadan önce** düzeltilecek fiş listesidir (skilin "önce ölç" refleksi).

## 9) KVKK Anonimleştirme (Wolvox yerleşik)  `📹`
Wolvox'ta **kişisel verileri geri döndürülemez biçimde anonimleştiren** yerleşik araç var — ERP/Restoran/
Otel/Genel Muhasebe/İnsan Kaynakları'nda çalışır. KVKK'nın "kimliği belirlenemez hâle getirme" tanımını uygular.

- **Akış:** anonimleştirme ekranı → **başlangıç/bitiş tarihi** (başlangıç opsiyonel; boşsa bitişe kadar tüm
  uygun kayıtlar), **imha evrak ismi, imha etme yöntemi, açıklama, ilgili tabloların seçimi**, işlemi yapan
  kişi/birim/özel kod → "anonimleştirme işlemine başla". Anonimleştirilen kayıt tekrar işlenmez.
- **İz/kanıt:** **Anonimleştirme Raporu** (yapılan işlemlerin listesi) + **Anonimleştirme Kayıt** (manuel
  imha kayıt formu — denetim için).
- **Danışman refleksi:** müşteri "eski müşteri verilerini KVKK gereği silmeliyim" derse **native
  Anonimleştirme aracına** yönlendir — ham `DELETE` **önerme** (referans bütünlüğü + yasal kayıt/rapor
  gereği). Bu, skill'in PII/KVKK doktrininin **ürün-içi karşılığıdır**; danışman **çalıştırmaz**, müşteriye
  gösterir. → [dogrulama-testleri gizlilik](dogrulama-testleri.md).

---

## Wolvox kolonlarına bağlama (hızlı harita)
| Mevzuat kavramı | Wolvox alanı (şema-first teyit) |
|---|---|
| KDV oranı | `STOK.KDV_ORANI`, `FATURAHR.KDV_ORANI` |
| Tevkifat kod/oran | Fatura/işlem tevkifat alanları (sürüme göre; kartta tanımlı) |
| e-Fatura mükellefi | `CARI.EFATURA_KULLAN` + GİB mükellef listesi |
| Senaryo | `FATURA.EFATURA_SENARYO` |
| e-Belge durumu | `FATURA.EFATURA_DURUM` (1=bekliyor/gönderilmedi, 2=gönderildi) |
| GİB yanıt kodu | `FATURA.EFATURA_GIB_DURUM` (§5 tablosu) |
| Gönderim hatası | `FATURA.OTO_GONDERIM_HATA` (serbest metin) |

> **Doğruluk sözleşmesi:** bu paketteki her oran/kod **derleme anındaki** mevzuata dayanır. Bir mükellefe
> **kesin** rakam vermeden önce (a) yürürlük tarihini, (b) GİB güncel listesini, (c) mali müşavir onayını
> teyit et. Bu bir **danışmanlık aracıdır, resmî mali görüş değildir** (bkz. skill.md DISCLAIMER).

### Kaynaklar (2026-07 derleme)
- KDV oran değişikliği: Resmi Gazete 07.07.2023/32241, Cumhurbaşkanı Kararı 7346 (yürürlük 10.07.2023) —
  PwC, KPMG Vergi, TÜRMOB özetleri.
- Tevkifat kod/oran: GİB "KDV'de kısmi tevkifat" listesi; atlashal/ISMMMO/Denge Akademi derlemeleri.
- e-Fatura senaryoları: birfatura, Paraşüt, eLogo, TÜRMOB SSS.
- GİB durum kodları: Paraşüt, DİA Akademi, Sovos/GİB detaylı durum kodları dokümanları.
- **Uygulama akışları (§2-3 UI, §7-9)** `📹`: resmî AKINSOFT eğitim videoları — Tevkifatlı/İstisna/e-İhracat
  Faturası oluşturma, e-Müstahsil Gönderim, **Enflasyon Muhasebesi**, **e-Defter Oluşturma**, **Anonimleştirme
  İşlemleri**. (Video kimlikleri repoda değil; danışman özel notunda.) Mevzuat rakamları yine yukarıdaki
  resmî kaynaklardan + SMMM teyidiyle; videolar yalnız **Wolvox içi uygulama adımlarını** kaynaklar.
