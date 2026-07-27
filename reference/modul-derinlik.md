# Wolvox 8/9 — İnce Modül Derinliği (danışman kılavuzu)

> Ana modüller (Stok/Cari/Fatura/Muhasebe/e-Dönüşüm) [schema-map](schema-map.md) ve diğer paketlerde
> derinlemesine işlendi. Bu dosya **daha az kullanılan ama yüksek değerli** modülleri kapsar:
> Üretim/Reçete, Parti-Lot-Seri-SKT, Teknik Servis, Pazaryeri/e-Ticaret entegrasyonu, Bordro/İK.
>
> ⚠️ **Dürüstlük çerçevesi:** Bu modüllerin tablo/kolon adları kurulumda **doğrulanmadan verilmez**.
> Aşağıda kolon adı verilen yerler **📖 standart tahmin** (isim kalıbından); her biri install'da
> [schema-map §1 röntgen](schema-map.md) ile **teyit edilmeli**. Kolon uydurmak, UI yolu uydurmak kadar
> hatalıdır. Değer buradaki **şema listesinde değil, danışmanlık refleksinde**: ne sorulur, hangi tuzak,
> hangi rapor. `👤` işaretli notlar bayi/danışman/kullanıcı videosundan damıtıldı, resmî AKINSOFT kaynağı
> değil; versiyon/terim sapması riski daha yüksek.

---

## Modül keşif refleksi (her ince modül için ilk hamle)
```sql
-- Modülün tabloları duruyor mu / dolu mu? (adı tahminle, LIKE ile ara)
SELECT t.name, SUM(p.rows) rows
FROM sys.tables t JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN (0,1)
WHERE t.name LIKE '%URETIM%' OR t.name LIKE '%RECETE%' OR t.name LIKE '%SERVIS%'
   OR t.name LIKE '%SERI%'   OR t.name LIKE '%LOT%'    OR t.name LIKE '%PERSONEL%'
GROUP BY t.name ORDER BY rows DESC;
```
> Boş çıkması "modül yok" demek değil — **lisans var ama kullanılmıyor** olabilir (goldmine) ya da veri
> **ayrı `_<modül>` DB'sinde**. Sahibine "bu modülü aldınız mı, kullanıyor musunuz?" diye sor.

---

## 1) Üretim / Reçete (BOM, fason, sarf)

**Ne yapar:** Ürün ağacı (reçete/BOM) tanımı → üretim emri → yarı mamul/mamul giriş + sarf (hammadde
çıkış). Fason (dış işçilik) senaryosu da bu modülde.

**Danışman soruları:**
- Reçete **sabit mi, sürüm/varyantlı mı?** (aynı mamulün farklı reçeteleri)
- **Sarf otomatik mi** düşülüyor (üretim emri kapanınca) yoksa elle mi? — en sık hata burada.
- **Maliyet** nasıl: reçete standart maliyeti mi, gerçekleşen sarf maliyeti mi? Muhasebe 151/152/620 ile bağı?
- **Fason** varsa: fason çıkış irsaliyesi + fason giriş, işçilik maliyeti nasıl bindiriliyor?

**Tipik tuzaklar:**
- Üretim emri kapatılmadan sarf düşmez → stok mamul artar, hammadde eksilmez → **negatif/şişkin stok**.
- Reçete miktar birimi ≠ stok birimi (kg vs adet katsayısı) → maliyet 1000× sapar.
- Yarı mamul iki kez maliyetlenir (hem sarfta hem mamulde) → çift sayım.

**Şema izi (📖 teyit et):** üretim emri başlık/satır, reçete başlık/satır (`RECETE*`, `URETIM*`); sarf
hareketi büyük olasılıkla `STOKHR`'ye üretim tipli hareket olarak düşer → `TUTAR_TURU`/hareket tipini
install'da doğrula. **Reçete→sarf→STOKHR** zincirini bir üretim emrinde uçtan uca izleyerek çıkar.

**Rapor değeri:** reçete-dışı sarf (fire), planlanan vs gerçekleşen maliyet, yarı mamul yaşlanması.

> **MRP II ≠ bu temel Üretim/Reçete modülü** `📹`: Wolvox'ta `MRP2`, Özel Ayarlar'da **ayrı bir sekme**
> olarak kayıtlıdır ([ozel-ayarlar §14](ozel-ayarlar.md)) ve yukarıdaki temel Üretim/Reçete'den çok daha
> zengin bir paket sunar: online iş merkezi (web/mobil operatör paneli), vardiya/mola/duruş tanımları,
> operasyon+makine bazlı reçete, durum-makineli Üretim Planlama, operasyon bazlı İş Emirleri, ölçüm
> bazlı Kalite Kontrol, Hammadde Giriş Kontrol, üç türlü Fason (Normal/Birleştirme/Parçalama) ve
> Hurda/Yan Ürün değerlendirmesi. Aşağıdaki alt bölümler bu paketi kapsar; ayrı lisans/sekme gerektirir.

### MRP II alt-modülleri (temel Üretim/Reçete'den ayrı, ek lisans/sekme)

**Online İş Merkezi** `📹` (web/mobil operatör paneli): kurulum iki aşamalı — (1) **Kontrol Paneli**'nde
operatöre kullanıcı + **"Online İş Merkezi Operatör"** yetkisi; (2) ERP'de **İş Merkezi Tanımları**'nda
aynı personele iş-merkezi (+ istenirse makine) yetkisi ver. Sonra Kontrol Paneli > Diğer İşlemler > Online
İş Merkezi'nden **"Online İş Merkezi sistemini kullan"** işaretlenir + **web service portu** + **SQL Server
portu** girilir. Operatör `<Server IP>:<port>` adresine kullanıcı adı/şifre + şirket/çalışma yılı ile girer
→ yetkili olduğu iş merkezini seçer → Üretim Listesi'nde bekleyen/tamamlanan operasyonu görür → operasyona
tıklayıp **başlat/bitir/durdur** (saat-tarih otomatik yazılır); aynı ekran % tamamlanma izleme panosu
olarak da kullanılabilir. ⚠️ Çok şirketli kurulumda tarayıcı girişindeki şirket/yıl seçimi yanlış şirkete
giriş riski taşır; port ayarları [native-index §10 WebConnect](native-yetenek-indeksi.md)'ten
**ayrıdır** — farklı port çifti, farklı amaç (yalnız üretim/iş emri).

**Fason İşlemleri — Normal / Birleştirme / Parçalama** `📹`: üç ekran da aynı iskelet — cari (fasoncu) seç
> Kaynak Stok(lar) (miktar + fire miktarı + maliyet tipi) > Hedef Stok(lar) > **Durum = Üretimde**'ye çek
> bu adımda **irsaliye oluştur** (stoktan düşüş + irsaliye eşzamanlı) > üretim bitince Geliş/Giriş
Bilgileri gir > **Durum = Tamamlandı** > **Stok Entegrasyonu** çalıştır (üretilen ürünün stok hareketine
gerçek anlamda işlenmesi için zorunlu son adım). **Normal** = 1 kaynak:1 hedef, "bir yarı mamul miktarı"
alanı katsayı görevi görür (kaynak miktar × katsayı = hedef miktar, otomatik hesaplanır). **Birleştirme** =
çoklu kaynak → tek hedef (hedef miktar değişirse kaynak miktarları otomatik yeniden hesaplanır).
**Parçalama** = tek kaynak → çoklu hedef, ayrıca **maliyet yüzdeleri dağıtımı** adımı gerekir (birden fazla
hedef mamul arasında maliyet paylaştırma — yalnız Parçalama'ya özgü, atlanırsa çıkan mamullerin maliyeti
nasıl bölüştürülür belirsiz kalır). ⚠️ **Durum değişikliği kendi başına stoktan düşürmez** — asıl tetik
"irsaliye oluştur" adımıdır; **Stok Entegrasyonu atlanırsa üretilen ürün hiç stoğa girmez** ("üretim
yaptım ama mamul stokta yok" şikâyetinin bu ekrandaki karşılığı). Bu, §1'in "sarf otomatik mi düşülüyor"
sorusuna MRP II Fason tarafındaki cevabı: **hayır, elle iki ayrı onay adımı** (irsaliye + Stok
Entegrasyonu) gerekir.

**Kalite Kontrol** `📹`: tanım stok kartında (`Stok kartı > Kalite Kontrol`) — ölçüm tipi **Toleranslı**
(standart değer ± tolerans, ör. 50–70 mm) veya **Evet/Hayır** (gözle kontrol). İşlem: `Üretim Emirleri >
İş Emirleri > Kalite Kontrol` > **Kalite Kontrol Oluştur** > kontrol edilecek operasyonları seç >
**Aktif Kaydı Düzenle** > (Toleranslı ise) üretilen miktar + ölçüm miktarı + **Maksimum Red Miktarı** gir →
program onaylanan/reddedilen miktarı **otomatik** hesaplar, tolerans içindeyse **"Parti Kabul"**e otomatik
çeker. Ölçüm tipi **kart bazında** tanımlanır — kart açılışında bu sekmenin doldurulup doldurulmadığı
denetlenmeli (yoksa standart-dışı üründe kontrolsüz geçiş riski var). **Kalite Kontrol Raporu** ile geçmiş
ölçümler izlenir — §1'in rapor değerine yeni bir veri kaynağı ekliyor.

**Hammadde Giriş Kontrol** `📹`: tedarikçiden gelen hammaddeyi kabul öncesi miktar+kalite kontrolünden
geçirir — kontrol tarihi/saati + geliş tarihi/saati + Stok + Tedarikçi + **Sipariş Miktarı** (tedarikçiye
verilen sipariş) + **Gelen Miktar** (fiilen gönderilen) + **Ölçüm Miktarı** + **Maksimum Red Miktarı** +
**Onaylanmayan Miktar** (elle) → **Onaylanan Miktar otomatik hesaplanır**, tolerans içindeyse
**"Parti Kabul"**e otomatik döner. ⚠️ Bu, [native-index §14](native-yetenek-indeksi.md)'teki
**Mal Kabul** ekranından farklı bir katman: Mal Kabul sipariş/irsaliye/fatura karşılaştırıp irsaliye
oluşturur; Hammadde Giriş Kontrol miktar+kalite red oranını ölçüp partiyi kabul/red eder — muhtemelen Mal
Kabul'den önce veya bağımsız çalışan bir kalite kapısı, sırası/entegrasyonu install'da teyit edilmeli.
**Hammadde Giriş Raporu** ile geçmiş kontroller izlenir.

**Üretim Emri → İş Emirleri** `📹`: üretim emri oluşturulduktan sonra **İş Emirleri**'nden **makine
vardiyasına göre** veya **saatlik** iş emri türetilir > **Makine İş Emirleri**'nden aktif iş emirleri
sonuçlandırılır (Online İş Merkezi de bu amaçla kullanılabilir) > üretim sırasında veya bitince **Stok
Entegrasyonu** çalıştırılır (üretim tamamlanmadıysa **kısmi** Stok Entegrasyonu da yapılabilir) > **İş
Emri Sonuçlandırma** ekranında üretilen miktar + Kalite Kontrol onay/onaylanmayan miktarı görünür (onay
miktarı değişirse onaylanmayan miktar otomatik güncellenir; onaylanmayan miktar **Yan Ürün** bölümünde
görünür — bkz. aşağıda). Genel Ayarlar'da (muhtemelen MRP2 Ayarları — kesin ekran adı install'da teyit
edilmeli) **"iş emri operasyon bazında kapat"** kaldırılabilir; kapatılırsa tüm üretim tek adımda (normal
veya özel kapatma) sonuçlandırılabilir — operasyon bazlı iş takibi istemeyen küçük atölyeler için kısayol.

**Üretim Planlama** `📹`: MRP II'nin çekirdek planlama ekranı — **Reçete seçimi** (zorunlu ön koşul) +
**Başlama Tarihi** (zorunlu) + bitiş/teslim tarihi > Kaydet → satın alma ve diğer maliyetler otomatik
aktarılır > `Sipariş Bul` panelinden ilgili satış siparişi plana çekilebilir > **Üretim Reçetesi**
sekmesinde üretilecek ürünlerde düzenleme yapılabilir > **Üretim Bilgileri** sekmesinde **Üretim Durumu**:
`Beklemede` → `Planlamada` → `Üretimde` — **Üretimde'ye çekilince iş emirleri otomatik oluşturulur** >
**Satın Alma** sekmesinde reçetede "tedarik" (dışarıdan alınacak) işaretli kalemler görünür. ⚠️ Bu ekran,
yukarıdaki temel "reçeteden fiili üretim yap" ekranıyla **karıştırılmamalı** — durum `Üretimde`'ye
çekilmeden iş emri oluşmaz, planlama aşamasında kalan kayıtlar üretime yansımaz (aktif/pasif planları
ayırt etmek için durum alanı raporlarda filtre olarak kullanılmalı).

**Reçete Tanımları (MRP II)** `📹`: temel §1 reçetesinden çok daha zengin — **Üretim Bilgileri** sekmesi
(üretim kodu+adı+miktarı+diğer maliyetler) > **Üretim Reçetesi** sekmesi: mamul seç > yarı mamul(ler)i tek
tek/çoklu ekle (yarı mamul **başka bir reçeteden de içe aktarılabilir** — iç içe/çok-seviyeli BOM) >
hammadde(ler) ekle; reçete listesinde her satır için miktar · fire oranı · fire miktarı · depo · maliyet
tipi > **Operasyonlar**: operasyon + makine seç + birim işleme süresi; operasyon türüne göre **tedarik /
fason / kendi üretimimiz** seçilir; **Proto operasyon**'dan teknik resim yüklenebilir; operasyonda sabit
bir geri dönüş varsa **dönüşüm tanımı** girilir (bu, Hurda/Yan Ürün'ün veri kaynağıdır — aşağıda) >
**Ürün Ağacı** görünümünde kullanılan tüm ürün+operasyonlar hiyerarşik izlenir > **Maliyet** alanında
seçilen maliyet tipine göre birim maliyet hesaplanır. §1'in "reçete sabit mi, sürüm/varyantlı mı"
sorusuna kısmi cevap: en azından **çok-seviyeli/iç içe** reçete native olarak destekleniyor.

**MRP II Tanımlar** `📹` (kapasite/OEE'nin temel sözlükleri): **Vardiya ve Mola Tanımları** (mesai grubu
oluştur → **mesai kopyalama** ile ileri tarihe hızlı çoğalt) > **Mola Tanımları** (yemek/çay gibi) >
**Duruş Tanımları** (makinenin "neden durduğu" nedenleri — parça değişimi, doğalgaz/elektrik kesintisi
vb.) > **İş Merkezi Tanımları** (makine/bölüm tanımı + Online İş Merkezi için personel yetkilendirmesi
buradan yapılır) > **Operasyon Tanımları** (hammadde/yarı mamulün üretim aşamaları; türe göre **tedarikçi
/ iç operasyon / fason** seçimi) > **Makine Tanımları** (iş merkezi bağlantısı + hangi mesaide kullanıldığı
+ elektrik tüketimi + personel yetkilendirmesi + işlenebilen stoklar + makine personelleri + **Makine
Bakım Bilgileri** — periyodik günlük/aylık bakım tanımı + takibi). ⚠️ Vardiya+Duruş+Makine tanımları
birlikte kullanılırsa makine duruş süresi/nedeni analizi (OEE'ye yakın bir rapor değeri) native olarak
mümkün görünüyor, ama rapor ekranı gösterilmedi — sadece veri kaynağının var olduğu not ediliyor.
**Personel yetkilendirmesi hem İş Merkezi Tanımları'nda hem Makine Tanımları'nda geçiyor** — hangisinin
birincil/zorunlu olduğu net değil, ikisi de doldurulmalı gibi görünüyor (install'da teyit).

**Hurda / Yan Ürün** `👤`: İş Emri Sonuçlandırma ekranından **Hurda/Yan Ürün** menüsüne gir > en üstteki
aktarım butonu Kalite Kontrol'de reddedilen stok miktarını buraya çağırır > ikinci aktarım butonu
reçetenin Operasyon kısmında tanımlanan **dönüşüm tanımı** (geri dönüşüm sabitleri) çeker > **Geri Dönüş
Stok** kısmında miktar/satış fiyatı gerekirse elle değiştirilebilir > **Stok Entegrasyonu** butonuyla bu
miktarlar stok hareketlerine **giriş** olarak işlenir. Kalite-red edilen miktarları çöpe atmak yerine yan
ürün/hurda stoğu olarak değerlendirmenin native yolu — reçetede tanımlı sabit geri dönüşle (fire/scrap
yield) birleşiyor. Resmî AKINSOFT kanalında bu ekranın karşılığı bulunamadı (yalnız bayi videosu) — terim
ve tam menü yolu install'da teyit edilmeli.

---

## 2) Parti / Lot / Seri No / SKT (izlenebilirlik)

**Ne yapar:** Stok hareketini **seri no** (tekil, örn. elektronik/beyaz eşya) veya **parti/lot + SKT**
(gıda/ilaç/kimya) bazında izler. Geri çağırma (recall) ve tüketim-sırası (FEFO) için kritik.

**Danışman soruları:**
- Ürün kartında **"seri takip" / "parti-lot takip"** açık mı? (kart bazında ayar — [menu-haritasi Stok](menu-haritasi.md))
- **SKT** yerleşik alan mı yoksa **Özel Tanımlar** ile mi açılmış? (`📹` Stok kartı Özel Tanımlar > tarih alanı — çok yaygın pratik)
- FEFO/FIFO çıkış zorlanıyor mu, yoksa operatör elle mi seçiyor?

**Seri No ↔ Lot farkı ve giriş ekranı** `👤`: seri no **bir ürüne (tekil birime) özel**dir; lot numarası
**aynı üründen birden çok adede** verilebilir. Pratik sonucu: izleme tipi **Seri No** olan bir kartta
`Seri Lot Giriş Hareketi` ekranında **`Miktar` alanı pasif gelir** (her hareket 1 birim sayılır) ve
yerine **`Toplu Giriş`** butonu aktifleşir — çok adetli seri girişi oradan yapılır.

Ekran `Seri Lot Giriş Hareketi` (👤 tam menü yolu install'da doğrulanmalı — kaynak video yalnızca ekran
adını gösteriyor): `Stok Bul` > Seri/Lot · Cari Kodu · Miktar · Depo · **daha önce seri no'suz yapılmış
bir stok hareketiyle eşleştirme** · Özel Kod · İşlem Tarihi · **Garanti Tarihi** · **Son Kullanma
Tarihi** · Açıklama > Kaydet. Üstte **`Bakiye`** (seri/lot bakiyeleri) · **`Eski Hareketler`** ·
**`Etiket`** (etiket çıktısı ekranına yönlendirir). Giriş/çıkış ayrıca **alış faturası · gelen irsaliye ·
satış faturası · giden irsaliye** üzerinden de yapılabilir — modülden bağımsız tek nokta yoktur, ikisi
de aynı bakiyeyi besler.

→ Bu, yukarıdaki "SKT yerleşik alan mı yoksa Özel Tanımlar ile mi açılmış?" sorusunu netleştirir:
seri/lot modülü kullanılıyorsa **SKT yerleşik alandır** (Özel Tanımlar'a gerek yok).

**Tipik tuzaklar:**
- Seri/lot **girişte** tutulup **çıkışta** eşleştirilmiyor → izlenebilirlik zinciri kopuk.
- SKT Özel Tanımlar'daysa **raporlanabilir ama uyarı vermez** (satışta "son 30 gün" alarmı yok) → süresi geçmiş satış.
- Aynı lot iki depoda; transferde lot taşınmıyor.

**Şema izi (📖 teyit et):** seri/lot tabloları hareketle (`STOKHR`) ilişkilidir (`*SERI*`, `*LOT*`,
`*PARTI*`). SKT Özel Tanımlar'daysa değer stok kartının özel-alan tablosunda/kolonunda; adını install'da bul.

**Rapor değeri:** SKT'ye X gün kalan stok, hareketsiz lot, seri no ile garanti/servis sorgusu ([§3](#3--teknik-servis)).

---

## 3) Teknik Servis  `📹` (resmî Servis Yönetimi serisi)

**Ne yapar:** Servise gelen ürünün süreç takibi: **Servis Fişi** → işlem/parça + personel + garanti → **faturalama/teslim**. Cari ve seri no ([§2](#2--parti--lot--seri-no--skt-izlenebilirlik)) ile bağlı.

**Modül yapısı** (`Servis Yönetimi`):
- **Tanımlar:** Servis · İşlem · **Hizmet** · **Fiş Durumu** · Marka/Model · Servis Paketi · Servis Grubu · Araç · Ürün.
- **İşlemler:** **Servis Fişi** · Randevu Kaydı · Fiş Faturalama · Fiş Teslim · **Bakım Sözleşmesi**.
- **Raporlar:** Araç iş yükü · Fiş raporu · Servis raporu · **Personel iş yükü** · Servis analizi · Bakım sözleşme listesi · Randevu listesi · Servis özel rapor.

**Servis Fişi akışı** `📹` (`Servis Yönetimi > Servis Fişi`): cari seç + servise gelen ürünü stok ekle →
**cari hareket / stok hareket işaretle** (yoksa muhasebeye/stoğa yansımaz) → fiş bilgileri (özel kod, grup,
**fiş durumu**, KDV) → **seri no + garanti takip** (garantiye gönder/al, garanti evet/hayır, marka/model, ek
parça, **bakım sözleşmesi** seç) → arıza (müşteri arızası + sorumlu görüşü) → **servis işlemleri: işlem kodu +
durum (yapılacak/yapıldı/iptal)** → personel (servis aracı seç → aracına ekli personel otomatik, ya da elle) →
**dış servis** carisi (başka servise gönderim) → iskonto/pazarlama/fiyat değiştirme → `İşlemler > fatura/irsaliye aktar`.

**Kritik ayar** `📹`: `Özel Ayarlar > Servis Ayarları` — yapılan işlemlerin toplamı servis hareketine
**işlem tanımından mı / hizmet tanımından mı / bağımsız hareket olarak mı** aktarılsın. → [ozel-ayarlar](ozel-ayarlar.md).

### Servis Fişi — sekme detayı

Yukarıdaki akış cümlesi üst özettir; aşağıda her sekmenin alan/buton düzeyi (round 2, resmî Servis
Yönetimi serisi, 13 video):

- **Genel Bilgiler** `📹`: cari/stok seçiminin yanında **Tanıma** alanı (cari karttaki adres
  tanımlarından seç — birden fazla adres için **Cari II modülü** gerekir, Fatura/Teklif'teki aynı
  kısıtla tutarlı). Cari/stok hareket işaretinin **varsayılan işaretli gelmesi** ayrı bir ayardır:
  `Yetkili > Genel Ayarlar > Servis Ayarları` > cari/stok hareket ayarlarını varsayılan seçili getir.
  **Ek Bilgi** alanı bir buton ile stok adını otomatik doldurur (veya manuel yazılır).
- **Bağlantılar** (§3'te önceden hiç yoktu) `📹`: **teklifi doğrudan servis fişine dönüştürür** —
  `Satış Yönetimi > İşlemler > Teklifler ▸ > Teklif Servise Aktarım` > teklifi seç > **"Servise
  Aktar"**. Servis Fişi açılınca Bağlantılar sekmesinde kaynak teklifin bilgileri otomatik dolar,
  butonla kaynak teklif formuna gidilir — Fatura'daki `Bağlantılar` bölümünün (native-index §3)
  servis tarafındaki eşdeğeri. Belge zinciri: **Teklif → Servis Fişi** de mümkün.
- **Fiyat Değiştirme** `📹`: oran gir > **İşleme Uygula**; ayrıca **Cari Vade Oranına Aktar** ve stok
  kartı alış/satış fiyatını aktarma — Fatura/Teklif'teki Fiyat Değiştirme sekmesiyle (native-index
  §3) **aynı UI kalıbı**.
- **Pazarlama** `📹`: ön koşul cari kartı `Özel Bilgiler 2 > "Pazarlama Sistemini Kullan"`. **Fiş
  bazında** (tek pazarlamacı, cari kartından gelen oranlar) veya **satır bazında** (her harekete ayrı
  pazarlamacı + "Aktar" ile tüm hareketlere tek personeli yayma). Pazarlama modülü lisansı gerekir.
- **İskontolar** `📹`: **Cari İskontosu** + **Aktar**. KDV öncesi iskonto **3 kademelidir** (1.'den
  kalana 2., ondan kalana 3. — sırayla kümülatif); **Stok İskontosu** ayrı (stok kartından); **KDV
  sonrası iskonto** ayrı bir alan (toplam yuvarlama). Teklif Formu'nda da birebir aynı mantık.
- **Dış Servis** (§3'ün "dış servis carisi" notunu somutlaştırır) `📹`: gönderim yapılan firma (cari) ·
  gidiş/dönüş tarihi+evrak no · **ödenen ücret** · **müşteriye yansıtılacak ücret** · açıklama > Kaydet
  → ekran **ücret farkını (yansıtılan − ödenen) otomatik gösterir**. **Aktar** butonu bu farkı fişin
  hareketlerine yansıtır — atlanırsa dış servis maliyeti faturaya/cariye düşmez (cari/stok hareket
  işareti unutulması tuzağının dış-servis özel hali).
- **Servis İşlemleri** `📹`: işlem seç (`Tanımlar > İşlem Tanımları`) veya **Hizmet Tanımları**'ndan +
  süre/saatlik ya da sabit ücret + tarih-saat + personel. Toplamın harekete aktarım tipi (bağımsız/
  hizmet tanımından/işlem tanımından) yukarıdaki "Kritik ayar"a bağlıdır. **Personel aktarma butonu**
  servis aracına atanmış personeli otomatik hareketlere çeker.
- **Arıza** `📹`: müşteri arıza tarifi + **Sorumlu Görüşü** — §3'teki tanımla teyit. Bu alanlar
  **varsayılan fiş çıktısında görünmez**, Aktif Rapor tasarımına elle (Metin Ekle + Veri Alanı Ekle)
  eklenmesi gerekir.
- **Ürün Bilgileri** `📹`: cari kartı **Servis Bilgileri** sekmesindeki kayıtlı ürün otomatik doldurur;
  `Tanımlar > Ürün Tanımları`'ndan da seçilebilir. **Seri No Garanti Takip** ayrı bir buton/ekran —
  ayrı modül/lisans gerektirebilir ("garanti modülünüz var ise" — kurulumda teyit et); garanti
  **evet/hayır elle işaretlenir**, seri no'dan otomatik türetilmez. İkinci alt-sekmede ek parça + bakım
  sözleşmesi bağlama (seç veya yeni oluştur).
- **Fiş Bilgileri** `📹`: özel kod · fiş no (oto: `Genel Ayarlar > Servis Ayarları`) · **Grup**
  (`Tanımlar > Servis Grubu Tanımları`) · **Fiş Durumu** · KDV (+ toplu aktar) · geçerlilik/geliş
  tarihi · **Teslim Eden** (adres tanımından) · **Teslim Alan** (servis personeli) · döviz · evrak
  tarih/no (fatura/irsaliyeye aktarınca oto). **Fiş Durumu fabrika varsayılanı 5 değerdir:**
  `Beklemede · İşleme Girdi · İşlem Tamam · Teslim Edildi · İptal` — kullanıcı `Tanımlar > Fiş Durumu`
  ekle butonuyla genişletebilir (kod-sozlugu'ndaki "install'a özel, sabit enum varsayma" uyarısıyla
  çelişmez, yalnızca fabrika setini somutlaştırır). **Teslim Alan**'ın servis personeli sayılması için
  cari kartı `Özel Bilgiler 2 > "Servis Personeli"` işaretli olmalı (Pazarlama'daki bayrakla aynı yer).
- **Servis Bakım Sözleşmesi** `📹` (§3'te adı geçen ama akışı önceden gösterilmemiş özellik):
  `Servis Yönetimi > İşlemler > Servis Bakım Sözleşmesi` > cari + kayıt/başlangıç tarihi + **periyodik
  aralık** (gün/hafta/ay/yıl) + sözleşme no (oto) + **sonraki bakım tarihi** + sorumlu/teknik personel +
  bakım ücreti + işlem kodu + kapsamdaki ürünler. **Sonraki bakım tarihine göre otomatik randevu**
  oluşturmak için ayrıca `Yetkili > Uyarıcı/Hatırlatıcı Ayarları > Servis Bakım sekmesi >
  "periyodik bakım için servis hatırlatma kaydını otomatik oluştur"` işaretlenmeli — sözleşme kapsamı
  + otomatik hatırlatma birlikte kurulmazsa hem kapsam-dışı faturalama hem kaçırılan randevu riski
  birleşir. **Verilen Hizmetler** alanı sözleşme kapsamında bugüne kadar verilen servisleri listeler
  (kapsam ihlali denetimi burada yapılır).
- **Servis Randevu Kaydı** `📹`: `Servis Yönetimi > İşlemler > Servis Randevu Kayıt` > cari (Cari II
  gerektiren çoklu adres) > Servis İşlem Bilgileri > **Servis Randevu Bilgileri** (tarih/saat + randevu
  durumu + fiş no oto) > Arıza Bilgisi ve Sorumlu Görüşü > Servis İşlem Personelleri > Ürün Bilgileri
  (+ Ürün Özel Bilgileri). Hatırlatma ayrı kurulur (`Yetkili > Uyarıcı/Hatırlatıcı Ayarları > Servis
  Randevu`). **"Randevu kaydınızı Servise Aktar dediğinizde ilgili bilgiler servis fişine gidecektir"**
  — Randevu → Servis Fişi de belge-zinciri gibi çalışır (Bağlantılar sekmesinin muhtemel bir diğer
  kaynağı, bu videoda "Bağlantılar" adı geçmedi — teyit gerek).
- **Servis Fiş Faturalandırma** (§3'teki "fatura/irsaliye aktar" adımının somut ekran karşılığı)
  `📹`: kaydet > `İşlemler` > **Faturayı Aktar** (veya **İrsaliyeyi Aktar**) > fişi filtrele/seç >
  faturalandırma işlemi > belge türü seç > Kaydet. Teklif Formu'ndaki `Teklif İrsaliyelendir` /
  `Teklif Faturalandırma` (aşağıya bkz.) **aynı UI ailesi**.
- **CRM sekmesi** (CRM modülü lisanslıysa) `📹`: Servis Fişi formunda ayrı bir **CRM** sekmesi bulunur
  — buradan fişi bir **bağlı proje/satış kodu**na ve/veya bir **bağlı kampanya kodu**na bağlayabilirsin.
  Yeni proje/satış veya kampanya tanımı gerekiyorsa aynı sekmedeki "Tanımlar" kısayolundan doğrudan
  oluşturulabilir — forma çıkmadan tanım eklenebiliyor. CRM modülü lisansı yoksa bu sekme muhtemelen
  görünmez (diğer form-videolarıyla aynı desen). → [native-index §15 CRM Modülü](native-yetenek-indeksi.md).
- **Tanımlar tam listesi** `👤`: Hizmet Tanımı · Ürün Tanımı · İşlem Tanımı · Fiş Durum Tanımı · Paket
  Tanımı · Araç Tanımı · Servis Grubu Tanımı. **İşlemler > Dosya** (servis formuna dosya/görsel ekleme,
  DB'de saklanır — Fatura'daki aynı özelliğin servis karşılığı, native-index §3). **Raporlar dalı**:
  Servis Fiş Raporu · Personel İş Yükü · Araç İş Yükü · Servis Randevu Listesi (mevcut Raporlar
  listesiyle tutarlı, teyit). "Servis işleminde kullanılan ürünü otomatik cariye ekle" diye bir
  Genel Ayarlar maddesi anılıyor ama hangi ayar ağacında olduğu **belirsiz** — install'da ara.

**Danışman soruları:**
- Servis fişinde **cari/stok hareket kutuları işaretli mi?** İşaretsizse fiş muhasebeye/stoğa yansımaz — "servis var ama ciro/stok yok" şikâyetinin 1 numaralı sebebi.
- **Fiş durumu** iş akışını yansıtıyor mu? (Tanımlar > Fiş Durumu — **kullanıcı-tanımlı**; her durum "personel iş yüküne katılsın" işaretiyle rapora girer.)
- **Garanti** seri no ile mi belirleniyor? Garanti içi/dışı ayrımı faturayı belirler.
- İşçilik **hizmet tanımı/işlem tanımı** üzerinden mi geliyor (Servis Ayarları'na göre), yoksa bağımsız mı?

**Tipik tuzaklar:**
- Cari/stok hareket işareti unutulur → fiş "havada" kalır (ciro/maliyet eksik).
- Fiş durumu iş yüküne katılacak şekilde işaretlenmemiş → **personel iş yükü raporu eksik** çıkar.
- Açık (yapılmadı/teslim edilmedi) fişler kapanmaz → "bitmemiş servis" birikir.
- Bakım sözleşmesi kapsamındaki işi ayrıca faturalamak.

**Şema izi (📖 teyit et):** servis fişi başlık+satır (`SERVIS*`), cariye + seri no'ya + bakım sözleşmesine
bağ; parça satırları STOKHR'ye (cari/stok hareket işaretliyse) düşer. **Fiş durumu kodu install'a özeldir**
(kullanıcı tanımlar) → [kod-sozlugu](kod-sozlugu.md) mantığıyla UI'da doğrula, sabit enum varsayma.

**Rapor değeri:** personel/araç iş yükü, ortalama çözüm süresi, garanti-içi maliyet, tekrar-arıza (aynı seri),
açık fiş yaşı, bakım sözleşmesi kapsam takibi.

**Tanı sorgusu — "havada" servis fişleri** `📖` (cari/stok hareketine işlenmemiş → ciro/maliyet eksik):
```sql
-- ⚠️ SERVIS* tablo/kolon adlarını install'da keşfet (LIKE '%SERVIS%'); işaret kolonları sürüme göre
SELECT FIS_NO, TARIHI, <FIS_DURUMU>
FROM <SERVIS_FIS>
WHERE ISNULL(<CARI_HAREKET_ISLE>,0)=0 OR ISNULL(<STOK_HAREKET_ISLE>,0)=0;   -- işaretsiz = havada
-- + uzun süre açık kalan (kapanmamış) fişler: <FIS_DURUMU> hâlâ "yapılacak/teslim edilmedi" olanlar
```

---

## 4) Pazaryeri / e-Ticaret entegrasyonu (Trendyol, Hepsiburada, N11, ...)

> **Not:** ÖKC/yazar kasa + e-Ticaret/pazaryeri **kurulum & davranış akışları** artık ayrı, video-kaynaklı
> pakette: [perakende-entegrasyon.md](perakende-entegrasyon.md). Bu bölüm **şema/veri** açısından tamamlar.

**Ne yapar:** Pazaryeri/e-ticaret siparişlerini Wolvox'a çeker, stok/fiyatı iter. **Çoğu kurulumda native
Wolvox değil** — Akınsoft e-ticaret modülü veya **3. parti entegratör** (ayrı, çoğu İngilizce/camelCase adlı tablolar).

**Danışman soruları:**
- Entegrasyonu **kim sağlıyor** (Akınsoft mı, 3. parti mi)? Tablolar native mi, sonradan eklenmiş mi?
  → [schema-map §1 uyarısı](schema-map.md): standart-dışı tabloların üstüne şema doğrulamadan analiz kurma.
- Stok/fiyat **hangi yönde** senkron (Wolvox→pazaryeri mi, çift yön mü)? Çakışmada kim kazanır?
- Sipariş **hangi belgeye** düşüyor (sipariş mi, doğrudan fatura mı)? Kargo/komisyon nasıl işleniyor?
- **Grup/kategori eşlemesi** var mı? (Stok grubu boşsa e-ticaret listelemesi bozulur — [P24](cozum-desenleri.md))

**Tipik tuzaklar:**
- İki kanal aynı stoğu satar (senkron gecikmesi) → **overselling**.
- Pazaryeri komisyonu/kesintisi maliyete girmez → kârlılık yanlış.
- SKU/barkod eşleşmezliği → yanlış ürün gönderimi.

**Şema izi:** entegrasyon tabloları genelde **native değildir**; adlarını install'da keşfet, sahibine
kaynağını sor. Native Akınsoft e-ticaret ise Stok grup/foto/`WEB görünüm` alanlarına dayanır (`📹` Stok
kartı çoklu foto = Stok II).

**Rapor değeri:** kanal bazlı satış/kâr (komisyon düşülmüş), senkron sapması, listelenememiş (grupsuz) ürün.

---

## 5) Bordro / İnsan Kaynakları (`_IKAYNAK` DB)  `📹` (resmî İK serisi)

**Ne yapar:** Personel kartı, **puantaj (giriş-çıkış/PDKS)**, vardiya/çalışma planı, izin, bordro, **ihbar/
kıdem tazminatı**, muhasebe entegrasyonu. Verisi genelde **ayrı `WOLVOX<..>_<..>_<yıl>_IKAYNAK` DB'sinde** →
[schema-map §2 çapraz-DB](schema-map.md).

**Puantaj / Giriş-Çıkış (PDKS) akışı** `📹`:
1. **Tanımlar > Personel Takip:** **Vardiya** (çalışma saatleri; hafta sonu/resmî tatil için ayrı vardiya +
   mesai oranları) → **Çalışma Planı** (birden çok) → **Çalışma Takvimi**'nde aylık planlama (toplu vardiya).
   Vardiya tanımının alan listesi: **başlama saati · mola başlama/bitiş saati · mesai bitiş saati**; ek
   mesai varsa ayrıca **ek mesai başlama/bitiş saatleri**; **normal mesai katsayısı** + **ek mesai
   katsayısı** (maaş hesabının doğruluğu bunlara bağlı); ayrıca **tatil ve resmi tatil vardiyası**
   (hafta sonu/resmi tatil için farklı yüzdesel mesai katsayısı — kesin oranlar oto-altyazıda bozuk
   geldi, standart mesai zam yüzdeleri olması muhtemel, install'da teyit et).
2. **Mazeret izni tanımları** (ücretli ise oran).
3. **Personel kartı > Personel Takip:** varsayılan çalışma planı + **giriş kart numarası** (cihaz/kapı ekranı).
4. **Giriş-çıkış:** elle (Giriş-Çıkış Kayıt) · **cihazdan yükleme** (PDKS) · **kapı ekranı** (anlık).
5. **Personel Giriş-Çıkış Raporu** → hareket + çalışma/ücret. Ücret hesaplama **4 farklı yöntem**
   (`Genel Ayarlar > Personel Takip Ayarları`). Gelmediği güne çift-tık → mazeret ata.

**İhbar / Kıdem Tazminatı** `📹`: personel seç → **son bodrodan otomatik hesap** ("bilgileri bodrodan al");
**Karşılıklar Raporu** ile referans tarihine göre çıkışta alacağı tazminat; İhbar/Kıdem Tazminatı Raporları.

**İK 360 Derece Performans Yönetim Sistemi** `👤` (yeni alt-modül, §5'te önceden hiç geçmiyordu):
İK (`_IKAYNAK`) programı içinde ayrı bir performans-değerlendirme bölümü. Tanımlama: **Durumu**
(Beklemede → Planlamada → Aktif → Tamamlandı/Pasif/İptal, elle ilerletilir) + başlama/bitiş tarihi +
işyeri kodu + min/max puan aralığı + opsiyonel **ağırlıklı puanlama** (kullan işaretlenirse *personel
sayısı × sistemdeki katsayı = azami puan*, ör. 5 personel × 8 katsayı = 45). **Kural Tanımı > Kural
Detayı**: kimin kimi değerlendirebileceğini **departmana göre** ve/veya **statüye göre** (VE/VEYA
bağlacıyla) kısıtlar; aynı yerde personel bazlı **ağırlık/etki yüzdesi** tanımlanabilir. **Soru
Başlıkları/Grupları** + her grubun **Hedef Kitle**siyle departman bazlı soru ayrımı. Katılım: **İK
yönetim paneli** (web/uzaktan erişim) > admin > "Personel Seçimi"/"Personel Puanlama" yetkisi ver →
ERP tarafında Durum=Planlamada'yken **"Personel Seç" > Gönder** ile atama → Durum=Aktif'e çekilince
yetkili personel **"Katıl"** diyerek puanlar (min/max dışı girişte uyarır) → Kaydet+Gönder ile puanlar
İK programına iletilir. ⚠️ Bu, ERP'nin `Özel Ayarlar > Performans Ayarları` (ozel-ayarlar'da `≈`
işaretli) ile **aynı şey olmayabilir** — İK programının kendi web paneli, ERP'nin Performans
Ayarları'yla ilişkisi install'da teyit edilmeli. Buton/menü adları oto-altyazıda ağır bozuk geldi,
ekranda kanonik adları doğrula.

**Muhasebe entegrasyonu** `📹`: bordro oluştuktan sonra `İK > Muhasebe Entegrasyonu` (Wolvox Genel Muhasebe'ye):
**tüm personel tek hesaba** veya **departman bazında** (İşyeri Kayıtları > Departman > borç/alacak kodları) →
ay + açıklama → uygula. **Entegrasyon 2** = SGK teşviklerini gelir olarak yazar. **Ön muhasebe entegrasyonu:**
bağlı cari kart seç → personel cari hareketine **özel kod "maaş"** ile aktarır. → [P5 çapraz-DB muhasebe](cozum-desenleri.md).

**Danışman soruları:**
- Bordro **Wolvox'ta mı** hesaplanıyor yoksa harici mi (Wolvox'a sadece muhasebe fişi mi geliyor)?
- Puantaj kaynağı elle mi, **PDKS cihaz/kapı ekranı** mı? Ücret hesap yöntemi (4'ten hangisi) doğru mu?
- Muhasebe entegrasyonu **tek hesap mı departman bazında mı**? Teşvik (Entegrasyon 2) işleniyor mu?

**Tipik tuzaklar:**
- Bordro parametreleri (asgari ücret, SGK tavan/oran) **yıl başında güncellenmez** → yanlış tahakkuk.
  **Zamana duyarlı** — [turkiye-uyumluluk](turkiye-uyumluluk.md) mantığı; SMMM ile teyit.
- Vardiya/tatil vardiyası eksik tanımlı → fazla mesai/hafta tatili yanlış hesaplanır.
- Departman muhasebe kodları boş → entegrasyon tek hesaba yığar (departman maliyeti kaybolur).
- İK verisi **en hassas PII** → sorgularda maskele; gerçek TC/maaş gösterme (→ KVKK [Anonimleştirme](turkiye-uyumluluk.md)).

**Şema izi (📖 teyit et):** personel/puantaj/vardiya/bordro/tazminat tabloları `_IKAYNAK` DB'sinde
(`PERSONEL*`, `PUANTAJ*`, `VARDIYA*`, `BORDRO*`); adları install'da doğrula.

**Rapor değeri (PII maskeli):** departman bazlı maliyet, fazla mesai trendi, izin bakiyesi, devir/çıkış oranı,
ihbar/kıdem **karşılık** yükü (referans tarihli).

---

## Ortak disiplin (tüm ince modüller)
1. **Önce keşif SQL'i** (yukarıdaki refleks) — modül var mı, dolu mu, hangi DB'de.
2. **Kolon adı verirken 📖/⚠️ işaretle**, install'da `INFORMATION_SCHEMA`/`RDB$` ile teyit et.
3. **Boş modül = fırsat** (lisans var, kullanılmıyor) — skoru düşürür ama hızlı kazanç ([verimlilik-skoru](verimlilik-skoru.md)).
4. **Native mi, sonradan mı** — standart-dışı tabloya kör güvenme.
5. Bulguyu bir **desene** ([cozum-desenleri.md](cozum-desenleri.md)) ve gerekiyorsa **playbook**a
   ([kurulum-playbook.md](kurulum-playbook.md)) bağla; PII'yi maskele.
