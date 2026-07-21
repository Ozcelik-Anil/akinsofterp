# Wolvox 8/9 — Kurulum / Implementasyon Playbook'ları

> Danışmanın **"sıfırdan kur"** teslimatı. Her playbook: *amaç · ön koşul · adım sırası · doğrulama ·
> tuzaklar*. Adımların `📹` işaretli olanları **resmî AKINSOFT eğitim videolarından** damıtıldı
> (akış kaynak-teyitli; etiket sözcüğü oto-altyazı kaynaklı olabilir — ekranda son teyidi yap).
> `≈` olanlar genel Wolvox bilgisidir. Menü konumu için → [menu-haritasi.md](menu-haritasi.md).
>
> ⚠️ **Değişmez disiplin:** (1) Her yapısal işlemden **önce yedek** al. (2) Mali/vergi kararlarını
> **SMMM/entegratör** ile teyit et — bu playbook uygulama akışıdır, mali danışmanlık değil. (3) Danışman
> **yazmaz**; ayarları müşteriye adım adım yaptırır, canlı ekranda birlikte doğrular.

---

## §1 — e-Fatura / e-Arşiv sıfırdan kurulum  `📹`

**Amaç:** Mükellefin e-belge gönderebilir hale gelmesi.
**Ön koşul:** GİB e-Fatura başvurusu onaylı · mali mühür/e-imza · entegratör hesabı (EDM/izibiz/...) ·
kontör. Bunlar **program dışı**; eksikse önce onları tamamlat.

**Adımlar**
1. **Sistemi aktive et (Kontrol Paneli):** `📹` `Kontrol Paneli > Yetkili Şirket Kayıt İşlemleri > e-Devlet 1`
   sekmesi → **"e-Fatura sistemini kullan"** + **"e-Arşiv sistemini kullan"** aktif; e-Faturada ticari unvan
   altında çıkacak **adres bilgilerini (EADES)** doldur → kaydet.
2. **Entegratör bağlantısı (ERP):** `📹` `e-Fatura Ayarları > Kullanıcı Bilgileri` → **entegratör firmayı seç**
   + entegratörün verdiği **portal/web servis bilgilerini** gir → **"Bağlantı Testi Yap"** → *"entegratör
   bağlantısı başarılı"* almadan devam etme.
3. **e-Fatura Ayarları panelini** geçir (`e-Dönüşüm > e-Fatura Ayarları`): `📹`
   - **ÖTV vergi kodu** (ÖTV'li satış varsa) — panelin en üstünde.
   - **Fatura notunu e-belgeye ekle** (nakış notların tasarımda çıkması için).
   - Şahıs firmalarında **unvanı Ad-Soyad alanına aktar** (adı-soyad zorunlu).
   - **Alıcı adresini** carinin açık adresine aktar.
   - **Gönderim sonrası fatura no güncelle** — programdaki seri ≠ portal serisi ise portal numarasını geri yaz.
   - **Gönderim sonrası PDF'i Dosya bölümüne ekle** (arşiv için).
   - **Kayıt esnasında otomatik gönder (onaya bağlı)** — fatura/irsaliye/müstahsil için ayrı ayrı.
   - **Taslak olarak portala kaydet** (yalnız EDM entegratöründe): portalda kontrol edip sonra gönder.
   - **Gönderim bilgisini fatura kartından al** (cari karttaki değil, fatura üstündeki bilgi geçerli olsun).
   - **Kapalı fatura bilgilerini ekle** · **MEIN** (izibiz, e-arşiv) · **döviz kuru** (güncel mi / fatura kuru mu).
   - **Gönderici posta kutusu** — şube sistemi varsa her şubeye ayrı posta kutusu.
   - **Cari kayıtta VKN/mail zorunlu** (hatalı carinin önüne geçer).
   - **Yazıyla genel toplam** · **irsaliye/sipariş bağlantı no gönder** · cari bakiye/vade/tedarikçi kodu ekle.
   - **Fatura hareket sıralaması** (e-belgede stokların sırası) · **fiyat yuvarlama** = `Genel Ayarlar > Stok Ayarları > birim fiyat hassasiyeti` basamağı kadar.
4. **Mükellef listesi** güncelle: `e-Dönüşüm > Ayarlar > Mükellef Listesi` — kim e-Fatura kim e-Arşiv
   otomatik ayrışsın (cari VKN doğruysa program senaryoyu kendi seçer). → [turkiye-uyumluluk §4](turkiye-uyumluluk.md).
5. **Cari kartları e-belgeye hazırla:** her cari için VKN(10)/TC(11), **ülke/il/ilçe listeden**, unvan/VKN'de
   boşluksuz. → §5 Cari kurulum.
6. **Senaryo seçimi doğru mu:** TEMELFATURA vs TICARIFATURA; kamu ise cari kartta **kamu kurumu** işaretli.
   → [turkiye-uyumluluk §3](turkiye-uyumluluk.md).

**Fatura kesme & gönderim akışı** `📹`: `Satış Yönetimi > İşlemler > Faturalar > Yurtiçi Satış Faturası` →
**cari bul** (cari e-Fatura/e-Arşiv mükellefi mi ekranda görünür) → `?` butonundan **senaryo / fatura tipi**
(normal/tevkifat/istisna) seç → stok+miktar+fiyat+KDV → **kaydet** → "e-fatura gönderimi yapılsın mı?"
(hemen = Evet; sonra = Hayır). Sonra göndermek için `e-Dönüşüm > e-Fatura Gönderimi` → faturayı seç →
**"Seçilenleri Gönder"**.

**Doğrulama:** 1 test faturası (küçük tutar) kes ve gönder → GİB durum kodu **1300** (başarıyla tamamlandı)
gelene kadar izle (1200 = GİB kabul ama alıcıya ulaşmadı, 1230 = hata). → [turkiye-uyumluluk §5](turkiye-uyumluluk.md).

**Tuzaklar**
- Cari VKN'sinde/unvanında **boşluk** → yanlış mükellefe fatura → ceza. Boşlukları temizle.
- e-Arşiv faturayı e-Fatura sanıp bekletmek: mükellef olmayan alıcı **e-Arşiv**'tir.
- "Otomatik gönder" açıkken taslak kontrolü atlanır; kurulum döneminde **onaya bağlı** bırak.

---

## §2 — Otomatik satış fiyatı (alışta yeniden oluştur) kurulumu  `📹`

**Amaç:** Alış faturası kaydedilince satış fiyatlarının kâr marjıyla otomatik güncellenmesi.
**Bu, Wolvox'un yerleşik özelliğidir** — harici script gerektirmez.

**Adımlar**
1. **Özelliği aç:** `Özel Ayarlar > Fatura Ayarları > Alış Faturası > "Satış fiyatları oluşturma
   penceresini göster"` işaretle. `📹` Aynı bölümdeki yardımcı ayarlar: **alış fiyatlarına KDV eklenecek**
   (reprice tabanı KDV dahil mi hariç mi — tuzak!), **ek maliyet eklenecek** (navlun/gümrük tabana binsin),
   **yeniden oluşturulacak satış fiyat sayısı** (hangi satış listeleri 1-4 hangi alıştan üretilsin). → [ozel-ayarlar §4](ozel-ayarlar.md).
2. **Kâr marjını tanımla:** Stok kartı > `Fiyatlar` sekmesinde her satış fiyatı için `KAR_MARJI` (örn. 1
   nolu alış değişince üzerine %X ekleyip 1 nolu satışı güncelle). `📹`
   > **Üretim karşılığı:** mamulü maliyetinden yeniden fiyatlamak için `Özel Ayarlar > Üretim Ayarları >
   > "satış fiyatları oluşturma penceresi"` (+ birim maliyete KDV ekle). → [ozel-ayarlar §9](ozel-ayarlar.md).
3. **Kullanım:** Alış faturası aç → ürünü ekle → yeni alış fiyatını gir → kaydet → **"satış fiyatları
   yeniden oluşturulsun mu?"** penceresinde kontrol et / onayla. Stok kartında satış fiyatı güncellenir. `📹`

**Alternatif — asimetrik/koşullu reprice (yalnızca yükselt, alt-küme):** Wolvox'un standart penceresi her
seferinde sorar ve tüm marjı uygular. Danışman **kontrollü toplu** reprice isterse (örn. yalnız
`OZEL_KODU='<OZELKOD>'` ile işaretli alt-küme, `yeni = CEILING(son_alış×çarpan)−1`, **sadece mevcut fiyattan yüksekse**):
- **Önizleme:** `tools/reprice-preview.ps1` — CSV önizleme + **inert** `.sql` taslağı üretir, **asla yazmaz**.
- Formül/desen: [sorgu-recetesi §H](sorgu-recetesi.md) · [cozum-desenleri.md P1](cozum-desenleri.md).
- Uygulama kararı ve yazma yetkisi **müşteride**; danışman taslağı verir, müşteri çalıştırır.

**Doğrulama:** 1 ürüne bilinen alış gir → beklenen satış = `CEILING(alış×çarpan)−1` mı? Fiyat düşüyorsa ve
"yalnız yükselt" isteniyorsa standart pencere bunu yapmaz → toplu/asimetrik yol gerekir.

**Tuzaklar**
- Standart pencere **simetriktir** (düşüşte de düşürür). "Sadece zam" kuralı istiyorsan asimetrik SQL şart.
- Döviz kullanan kartta fiyat aktarımı **birim (TL/USD/EUR) seçimi** ister — yanlış birim yanlış fiyat.
- KDV: `FIYATI` **KDV hariç** tutulur; çarpanı KDV dahil/hariç karıştırma. → [schema-map](schema-map.md).

---

## §3 — Yıl sonu kapanış + devir  `📹`

**Amaç:** Dönemi kapatıp ertesi yıl DB'sine açılış devri.
**Ön koşul:** Tüm fişler girilmiş · **yedek alınmış** · envanter/sayım tamam · SMMM onayı.

**A) Muhasebe kapanışı** (`Genel Muhasebe > Dönem Sonu İşlemleri`) `📹`
1. **7A/7B yansıtma:** gider hesaplarını yansıt (örn. 632'yi %100 yansıt) → yansıtma fişini oluştur (F8).
2. **Maliyet hesaplama:** dönem sonu envanteri → mal mevcudu → **621** satılan ticari mal maliyetine aktar → maliyet fişi.
3. **Kâr/zarar:** 600'lü gelirler + 621 + genel yönetim giderleri hesaplanır → **690** dönem kâr/zarar → **590**'a aktarılıp kapatılır.
4. **Kapanış fişini oluştur** → tüm hesapların kapanışı otomatik yapılır.
   > Not: **Kurumlar Vergisi** hesabı otomatik atılmaz — 590'ı kaparken KV oranını **SMMM ile** manuel işle.

**B) Devir** (`Kontrol Paneli > Yetkili İşlemleri > Devir İşlemleri`) `📹`
1. Çalışma yılını seç (kaynak → hedef, örn. 2022 → 2023).
2. **İleri** → devredilecekleri seç (stoklar, cari kartlar, ödenecek/tahsil edilecek kartlar...).
3. **Devre başla** → hedef tarihe kadar bakiyeleri taşır. (Her yıl **ayrı DB** — devir yeni yıl DB'sini besler; → [schema-map](schema-map.md) çok-yıl.)
4. **Yeni yıl DB'sinde:** `Genel Muhasebe > Fiş İşlemleri > Açılış Fişini Oluştur` → mizanla doğrula.

**Doğrulama:** Yeni dönem mizanı = eski dönem kapanış bakiyeleri. Stok/cari açılış devirleri tutuyor mu?

**Tuzaklar**
- Yedeksiz devir = geri dönüşsüz. **Önce yedek.**
- KV otomasyonu yok — atlanırsa 590 yanlış kapanır.
- Ara/eksik fiş varken kapanış → maliyet ve K/Z hatalı. Önce fiş bütünlüğü.

---

## §4 — Stok kartı asgari kayıt (veri-kalitesi tabanı)  `📹`

**Amaç:** Rapor/e-belge/entegrasyonun çalışacağı temiz stok kartı.

**Asgari alanlar (Genel Bilgiler):** ürün adı · **grup/ara/alt grup** (önce `Grup Tanımları`) · barkod
(EAN13 varsayılan) · **3 KDV alanı** (alış/perakende/toptan) · gerekiyorsa istisna/tevkifat kodu ·
döviz satılacaksa **"döviz kullan" + birim** · birim (adet/koli + katsayı).
**Fiyat:** `Fiyatlar > Varsayılan tanımları aktar` → 4 satış/4 alış · ilgili fiyatları gir.
**Açılış stoğu:** `Stok Durumu > Devir Girişi` ile eldeki miktar (alış hareketi yerine).
**Özel alan gerekiyorsa** (örn. SKT): `Özel Tanımlar > Ayar > +` ile alan aç → filtre/rapor/tasarımda kullan.

**Doğrulama / veri-kalitesi kontrolü:** grupsuz kart, KDV=0 (istisna değilse), barkodsuz/mükerrer barkod →
`tools/utilization-scorecard.ps1` B2 metrikleri. → [cozum-desenleri.md P12/P24](cozum-desenleri.md).

**Tuzaklar:** Grup önce tanımlanmadan seçilemez (elle yazılmaz). Döviz kapalıysa dövizli satış olmaz.

---

## §5 — Cari kartı asgari kayıt (e-belgeye hazır)  `📹`

**Amaç:** e-Fatura/e-İrsaliye'nin doğru gideceği cari.

**Asgari alanlar (Genel Bilgiler):** ticari unvan (şahısta **ad-soyad**) · **ülke/il/ilçe listeden seç**
(elle yazma — e-belge için kritik) · **vergi dairesi + VKN(10) / TC(11)** (biri dolu diğeri boş) ·
unvan/VKN'de **boşluk yok** · telefon/e-posta.
**Hesap Bilgileri:** gerekiyorsa **özel iskonto %** · **fiyat no** (örn. 6 → hep 6. fiyattan) · **kamu
kurumu** işareti (kamuysa) · e-irsaliye devreye al · döviz sistem hesabı (dövizliyse).
**İsteğe bağlı:** Yetkililer (SMS/mutabakat için) · Özel Bilgiler > fatura≠sevk adresi, rota · **Bakiye/Kredi
> Devir Girişi** (açılış borç/alacak).

**Doğrulama:** Test e-Fatura carinin senaryosunu (Temel/Ticari) doğru seçiyor mu? VKN GİB'de kayıtlı mı?

**Tuzaklar:** VKN/unvan boşluğu → yanlış mükellef → **ceza**. İl/ilçe elle yazımı → e-belge adres reddi.
Yönetici notu (Hesap Bilgileri) her modülde uyarı çıkarır — "riskli/durdur" carileri burada işaretle.

---

## §6 — Kontrol Paneli: firma kurulum · yedekleme · DB bakım  `📹`

Kontrol Paneli, ERP dışındaki **yönetim katmanıdır** (verinin tutulduğu server makinesinde çalışır).

**A) Yeni firma/şirket kurulumu** (`Kontrol Paneli > Yetkili > Şirket Kayıt İşlemleri`)
1. Şirket kodu · kısa ad · ticari unvan · yetkili · vergi dairesi/kodu · VKN · (resim).
2. Genel Muhasebe varsa: **şirket tipi · muhasebe tipi · muhasebeci**. Rapor dizini / **veri yolu** (varsayılan dışıysa).
3. **Offline modülü** varsa "bu şirket için offline kullanıma izin ver" (şube/uzak veri al-gönder).
4. Kaydet → **çalışma alanı yaz + oluştur** ← bu adım firmanın **DB'sini yaratır** ([schema-map DB adı](schema-map.md)).
5. **Özel Bilgiler:** banka hesap (e-Fatura+kamu için) · mail sunucu · otomatik mail/SMS · banka online.
6. **e-Devlet 1:** e-Fatura/e-Müstahsil kullan · hızlı satış/restoran otomatik e-Fatura/e-İrsaliye · **yeni
   nesil yazar kasa (ÖKC)** · **e-Defter** (aktivasyon için genel merkezle irtibat) · özel mali yıl · **e-adres (EADES)**.
7. **e-Devlet 2:** gelen kutusu → interaktif Vergi Dairesi portal bilgileri.
8. **Şube İşlemleri** (şube modülü): şube kaydı · personel/terminal ata · şubede ÖKC · **ortak modüller**
   (cari/döviz tüm şubelerde ortak); ERP'ye önceden veri girildiyse "şubeye aktar".

**B) Kullanıcı / yetki** (`Kontrol Paneli > Yetkili > Kullanıcı İşlemleri`) — kullanıcı aç, modül/işlem
yetkileri ata. → denetim izi [P18](cozum-desenleri.md).

**C) Yedekleme & Geri Yükleme** (`Kontrol Paneli > Veri Tabanı İşlemleri`) ⭐ **danışman güvenlik temeli**
- **Yedekleme Ayarları:** dizin · otomatik · periyot (saatlik/günlük, hangi saatler) · **maksimum yedek
  dosyası** (rotasyon; ör. 10 → son 10 tutulur, `0`=sınırsız disk dolar) · **resim/dosya DB'sini hariç tut**
  (şişmeyi azaltır) / "sadece değişen DB'ler".
- **Manuel yedek:** `Yedekleme > Yedekle` → son yılların yedeği; son yedek zamanı gösterilir.
- **Off-site:** yedek klasörünü (C:/D: `AS Yedek`) flash/başka diske kopyala; **Akınsoft Yedekleme programı**
  (ayrı, ücretsiz) ile **bulut** (Google Drive/OneDrive/Yandex/Dropbox) + zip+şifre + zamanlama.
- **Geri Yükleme:** `Yedekleme ve Geri Yükleme > dizin > Listele > şirket/çalışma yılı/tarih seç > sisteme
  geri yükle`. ⚠️ **GERİ DÖNDÜRÜLEMEZ.** Emin değilsen **yapma** — yetkili Akınsoft bayisi/DBA desteği al.
- **Veri Tabanı Bakımı / Güncelleme:** data seç → "bakım işlemlerine başla" (reindex/onarım) · sürüm
  yükseltmesi sonrası **DB güncelleme** (→ [dba-performans göç §5a](dba-performans.md)).

> **Danışman doktrini bağı:** "her yapısal işlemden önce yedek" kuralının **ürün-içi yeri** burasıdır.
> Reprice/toplu güncelleme/devir öncesi müşteriye **bu ekrandan manuel yedek** aldır; geri yüklemeyi
> **asla danışman körlemesine yapmaz** (geri döndürülemez).

## Playbook seçim refleksi
| Müşteri diyor ki | Playbook |
|---|---|
| "e-Faturaya geçiyoruz / gönderemiyoruz" | §1 (+ [sorun-giderme §4](sorun-giderme.md), [turkiye-uyumluluk](turkiye-uyumluluk.md)) |
| "Alınca satış fiyatı kendi güncellensin" | §2 |
| "Yıl kapanışı / yeni yıla nasıl geçerim" | §3 |
| "Stok kartlarım karışık / rapor tutmuyor" | §4 (+ scorecard) |
| "e-Fatura yanlış cariye gidiyor / adres hatası" | §5 |
| "Yeni firma/şube açacağım / kullanıcı yetkisi" | §6-A/B (Kontrol Paneli) |
| "Yedek nasıl alınır / geri yükleme / DB bakım" | §6-C (Kontrol Paneli) + [dba-performans §3](dba-performans.md) |

> Kurulum sonrası **sağlık kontrolü** için → [rapor-sablonlari.md](rapor-sablonlari.md) (yönetici sağlık raporu).
