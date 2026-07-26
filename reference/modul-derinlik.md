# Wolvox 8/9 — İnce Modül Derinliği (danışman kılavuzu)

> Ana modüller (Stok/Cari/Fatura/Muhasebe/e-Dönüşüm) [schema-map](schema-map.md) ve diğer paketlerde
> derinlemesine işlendi. Bu dosya **daha az kullanılan ama yüksek değerli** modülleri kapsar:
> Üretim/Reçete, Parti-Lot-Seri-SKT, Teknik Servis, Pazaryeri/e-Ticaret entegrasyonu, Bordro/İK.
>
> ⚠️ **Dürüstlük çerçevesi:** Bu modüllerin tablo/kolon adları kurulumda **doğrulanmadan verilmez**.
> Aşağıda kolon adı verilen yerler **📖 standart tahmin** (isim kalıbından); her biri install'da
> [schema-map §1 röntgen](schema-map.md) ile **teyit edilmeli**. Kolon uydurmak, UI yolu uydurmak kadar
> hatalıdır. Değer buradaki **şema listesinde değil, danışmanlık refleksinde**: ne sorulur, hangi tuzak,
> hangi rapor.

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
- **Tanımlar:** Servis · İşlem · **Fiş Durumu** · Marka/Model · Servis Paketi · Servis Grubu · Araç · Ürün.
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
2. **Mazeret izni tanımları** (ücretli ise oran).
3. **Personel kartı > Personel Takip:** varsayılan çalışma planı + **giriş kart numarası** (cihaz/kapı ekranı).
4. **Giriş-çıkış:** elle (Giriş-Çıkış Kayıt) · **cihazdan yükleme** (PDKS) · **kapı ekranı** (anlık).
5. **Personel Giriş-Çıkış Raporu** → hareket + çalışma/ücret. Ücret hesaplama **4 farklı yöntem**
   (`Genel Ayarlar > Personel Takip Ayarları`). Gelmediği güne çift-tık → mazeret ata.

**İhbar / Kıdem Tazminatı** `📹`: personel seç → **son bodrodan otomatik hesap** ("bilgileri bodrodan al");
**Karşılıklar Raporu** ile referans tarihine göre çıkışta alacağı tazminat; İhbar/Kıdem Tazminatı Raporları.

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
