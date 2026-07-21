# Çözüm Desenleri — Kanonik SQL İskeletleri (P1–P30)

> [vaka-bankasi.md](vaka-bankasi.md)'ndaki 1000 vaka bu **30 tekrar-kullanılabilir desene** bağlanır.
> Orada desenler tek satırlık özet; **burada her desen = ne zaman · kanonik SQL iskeleti · tuzak (gotcha)**.
> Amaç: modelin bir soruyu görünce doğru iskeleti hatırlayıp doğru tuzaktan kaçınması.
>
> **Kurallar:** Tüm iskeletler **salt-okunur** ve **jeneriktir** (gerçek veri yok) — kolon/eşik/kod
> **kuruluma özeldir, install'da doğrula**. Kod adlarını uydurma; `INFORMATION_SCHEMA`/`RDB$` ile teyit et.
> MSSQL varsayılan; Firebird farkı olan yerde **FB:** notu var (tam diyalekt için [sorgu-recetesi.md](sorgu-recetesi.md) §Firebird).
> `@param` = kullanıcıya sorulacak/beyan edilecek değer (çarpan, eşik, tarih, kur).

---

## P1 — Asimetrik güncelleme (sadece-yükselt / sadece-azalt)
**Ne zaman:** "fiyatı güncelle ama düşürme", "sadece eksikleri tamamla". Simetrik UPDATE değeri geri de çeker.
```sql
-- ÖNİZLEME: yeni değer mevcudu gerçekten aşıyor mu? (yalnız aşanlar güncellenir)
SELECT s.BLKODU, f.FIYATI AS mevcut,
       CEILING(sonalis.maliyet * @carpan) - 1 AS yeni
FROM STOK s
JOIN STOK_FIYAT f ON f.BLSTKODU = s.BLKODU AND f.ALIS_SATIS = 2  -- satış
JOIN (/* P8 son-alış */) sonalis ON sonalis.BLSTKODU = s.BLKODU
WHERE CEILING(sonalis.maliyet * @carpan) - 1 > f.FIYATI;          -- ASİMETRİ kapısı
```
**Tuzak:** Asimetriyi `WHERE yeni > mevcut` ile kur — `GREATEST` MSSQL'de yok. Maliyet düşerse satırı **hiç** listeleme, "0 değişti" doğru sonuçtur. Yazma için → P17.

## P2 — KDV hariç ↔ dahil dönüşümü
**Ne zaman:** hedef raf fiyatı KDV **dahil** verilir ama `STOK_FIYAT.FIYATI` KDV **hariç** tutulur.
```sql
SELECT s.BLKODU,
       @brut_dahil / (1 + s.KDV_ORANI/100.0)            AS net_haric,     -- dahil→hariç
       f.FIYATI * (1 + s.KDV_ORANI/100.0)               AS brut_dahil     -- hariç→dahil
FROM STOK s JOIN STOK_FIYAT f ON f.BLSTKODU = s.BLKODU;
```
**Tuzak:** Yuvarlama / psikolojik bitiş (…9, −1) **dahil** tarafta yapılır, sonra hariçe geri çevrilir. `KDV_ORANI` tam sayı → `100.0` ile böl (integer bölme hatası). KDV oranı kart bazında değişir, sabit sanma.

## P3 — Alt-küme filtresi (tüm karta değil, işaretliye)
**Ne zaman:** "seçili ürünlere", "şu markaya/gruba/özel koda" işlem.
```sql
WHERE s.OZEL_KODU3 = @isaret          -- veya GRUBU / MARKASI / OZEL_KODU1/2
  AND s.AKTIF = 1;
```
**Tuzak:** `OZEL_KODU4` **yoktur** (yalnız 1/2/3). Hangi slotun boş/temiz olduğunu install'da tara — dolu bir slotu işaret olarak seçmek mevcut veriyi ezer. Slot dağılımını önce `GROUP BY` ile ölç.

## P4 — En güncel satır (snapshot)
**Ne zaman:** son fiyat / son kur / son bakiye anı; bir anahtara ait çok satırdan **en yenisi**.
```sql
SELECT * FROM (
  SELECT t.*, ROW_NUMBER() OVER (PARTITION BY t.BLSTKODU ORDER BY t.TARIHI DESC, t.BLKODU DESC) rn
  FROM STOK_FIYAT_DEGISIM_LOG t
) x WHERE rn = 1;
```
**Tuzak:** `ORDER BY tarih` tek başına tie bırakır → PK'yı ikinci sıraya ekle. **FB:** `ROW_NUMBER() OVER(...)` FB 3+ var; FB 2.5'te bağ-sorgu/`FIRST 1` ile çöz.

## P5 — Çapraz-DB birleştirme
**Ne zaman:** çok yıl / muhasebe (`_GMUHASEBE`) / firma karşılaştırma; veri **ayrı DB'lerde**.
```sql
SELECT '2022' yil, * FROM [WOLVOX8_001_2022_WOLVOX].dbo.STOKHR
UNION ALL
SELECT '2023', * FROM [WOLVOX8_001_2023_WOLVOX].dbo.STOKHR;
```
**Tuzak:** DB adındaki `<modül>` veriyi böler — muhasebe `_GMUHASEBE`'de, her `<yıl>` ayrı DB. Tek DB'ye bakıp "yok/kullanılmıyor" deme (→ P21). **FB:** çapraz-DB yok; her dosya ayrı bağlantı, uygulama katmanında birleştir.

## P6 — Belge-zinciri kapanışı
**Ne zaman:** teklif→sipariş→irsaliye→fatura akışında **açık/eksik halka** (kayıp gelir).
```sql
SELECT sip.BLKODU
FROM SIPARIS sip
WHERE sip.FATURALANDI = 0                 -- kapanmamış (kolon adını teyit et)
  AND NOT EXISTS (SELECT 1 FROM FATURA f WHERE f.BLSIPKODU = sip.BLKODU);
```
**Tuzak:** "kapandı" bayrağı ile gerçek bağlı-belge **ikisini de** kontrol et; kısmi sevk/kısmi fatura zinciri yarım bırakır. İptal/iade halkalarını hariç tut.

## P7 — Bakiye toplamı (hareketten)
**Ne zaman:** stok/cari bakiyesi. Hazır "bakiye" kolonuna güvenme.
```sql
-- Stok:  SUM(KPB_GMIK - KPB_CMIK)   Cari: SUM(KPB_BTUT - KPB_ATUT)
SELECT BLSTKODU, SUM(KPB_GMIK - KPB_CMIK) AS bakiye
FROM STOKHR WHERE SILINDI = 0 GROUP BY BLSTKODU;
```
**Tuzak:** `SILINDI=0` filtresi (kolon **varsa**; `...HR`'de olmayabilir → P27). Depo bazlı istenirse `DEPO_KODU` ekle — depo toplamı ≠ genel toplam çünkü transferler. Devir hareketi yoksa bakiye eksik (→ P21).

## P8 — Maliyet / son-alış
**Ne zaman:** kârlılık, yeniden fiyatlama tabanı, negatif marj. Girdi = **alış** hareketi.
```sql
SELECT h.BLSTKODU, h.KPB_FIYATI AS son_alis
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY TARIHI DESC, BLKODU DESC) rn
      FROM STOKHR
      WHERE TUTAR_TURU = 1 AND IADE = 0 AND DEVIR = 0 AND SILINDI = 0) h  -- saf alış
WHERE h.rn = 1;
```
**Tuzak:** İade (`IADE=1`) ve devir (`DEVIR=1`) hareketlerini **dışla** yoksa son-alış çöp. Döviz maliyetinde belge-anı kur (`DOVIZ_ALIS`) kullan, **güncel kur değil**. Ortalama mı son mu → beyan et (→ P29).

## P9 — Yaşlandırma (aging)
**Ne zaman:** vadesi geçmiş alacak; 0-30/31-60/61-90/90+ kovaları.
```sql
SELECT CASE WHEN DATEDIFF(DAY, VADESI, @bugun) <= 0  THEN 'guncel'
            WHEN DATEDIFF(DAY, VADESI, @bugun) <= 30 THEN '1-30'
            WHEN DATEDIFF(DAY, VADESI, @bugun) <= 60 THEN '31-60'
            ELSE '60+' END AS kova, SUM(kalan) tutar
FROM (/* açık kalemler */) a GROUP BY ...;
```
**Tuzak:** Kısmi tahsilatı FIFO ile açık kaleme eşleştir — brüt borç değil **kalan** yaşlanır. `@bugun` install saati; **FB:** `DATEDIFF(DAY, VADESI, CURRENT_DATE)`.

## P10 — Eşik / pencere beyanı
**Ne zaman:** "ölü/yavaş/riskli/eski" — hepsi bir sayısal eşik ister.
```sql
DECLARE @olu_gun INT = 180;   -- BEYAN ET, sabit sanma
WHERE son_hareket < DATEADD(DAY, -@olu_gun, @bugun);
```
**Tuzak:** Eşiği kullanıcıya **söyle** ("180 günü ölü saydım"); sektöre göre değişir. Hareketsizlik = **satış** hareketsizliği mi tüm hareket mi, ayırt et (sayım/transfer hareket sayılmamalı).

## P11 — Anomali / mutabakat
**Ne zaman:** başlık `TOPLAM_*` vs satır toplamı; sistem bakiye vs sayım; iki liste çelişkisi.
```sql
SELECT f.BLKODU, f.GENELTOPLAM, SUM(hr.TUTAR) hesap
FROM FATURA f JOIN FATURAHR hr ON hr.BLFTKODU = f.BLKODU
GROUP BY f.BLKODU, f.GENELTOPLAM
HAVING ABS(f.GENELTOPLAM - SUM(hr.TUTAR)) > @tolerans;   -- kuruş toleransı
```
**Tuzak:** Ondalık yuvarlama için `> @tolerans` kullan, `<>` değil (kuruş farkı sahte pozitif üretir). İskonto/KDV başlığa nasıl yansıyor, satır formülünü ona göre kur.

## P12 — Mükerrer / tekillik
**Ne zaman:** çift barkod, çift kart, çift fatura no, çift cari.
```sql
SELECT BARKODU, COUNT(*) FROM STOK
WHERE BARKODU IS NOT NULL AND BARKODU <> '' AND AKTIF = 1
GROUP BY BARKODU HAVING COUNT(*) > 1;
```
**Tuzak:** Boş/`NULL` barkodu mükerrer sayma (hepsi eşleşir). Büyük/küçük harf ve baştaki sıfır/boşluk normalizasyonu — `LTRIM(RTRIM())`.

## P13 — Eksik-kayıt (NOT EXISTS)
**Ne zaman:** fiyatsız kart, grupsuz kart, hareketsiz cari, faturalanmamış irsaliye, muhasebeleşmemiş belge.
```sql
SELECT s.BLKODU FROM STOK s
WHERE s.AKTIF = 1
  AND NOT EXISTS (SELECT 1 FROM STOK_FIYAT f
                  WHERE f.BLSTKODU = s.BLKODU AND f.ALIS_SATIS = 2 AND f.FIYATI > 0);
```
**Tuzak:** `NOT IN` + NULL = sonuç kaybı → `NOT EXISTS` kullan. "Fiyatsız" tanımı: satır yok mu, satır var ama 0 mı — ikisini de yakala.

## P14 — Kod → anlam çözümü
**Ne zaman:** `smallint` enum alanı (`TUTAR_TURU`, `EVRAK_TURU`, `EFATURA_DURUM`, `SIPARIS_DURUMU`…).
```sql
SELECT ALANI, COUNT(*) FROM TABLO GROUP BY ALANI ORDER BY 2 DESC;  -- dağılımı gör
```
**Tuzak:** [kod-sozlugu.md](kod-sozlugu.md)'na bak **ama** dağılıma göre bir örneği UI'da teyit et; alan tek değer içeriyorsa yönü ondan çıkarma. Kod anlamı sürüme göre kayabilir.

## P15 — PII / KVKK
**Ne zaman:** cari ad/telefon/VKN/TCKN/e-posta/adres istenince.
```sql
SELECT LEFT(TICARI_UNVANI, 3) + '***' AS unvan_maskeli,  -- maskele
       GRUBU, SEKTOR, SUM(bakiye) tutar                   -- veya agregata çevir
FROM CARI GROUP BY GRUBU, SEKTOR, LEFT(TICARI_UNVANI,3);
```
**Tuzak:** Ham PII **çekme**; toplu PII dışa aktarma **reddet**. **FB:** birleştirme `||` (`LEFT(x,3) || '***'`). Maskeli bile olsa gerekçesiz kişi listesi verme.

## P16 — Otomasyon yöntemi seçimi
**Ne zaman:** "fiyatı otomatik güncellensin". Yöntem soruya göre değişir.
- Basit "hep marj/alışta güncelle" → **yerleşik** (`KAYNAK_FIYAT_TIPI`/marj alanı) yeter.
- Özel bitiş (−1/…9) / asimetrik / alt-küme → **zamanlanmış toplu betik** (dışarıdan, salt-okunur önizleme + onaylı çalıştırma).
- DB trigger ile otomatik yazma → **reddet** (canlı ERP'de gizli yan etki, muhasebe/log kopar).

**Tuzak:** Kurulumda yerleşik marjın fiilen kullanılıp kullanılmadığını **tara**; kullanılıyorsa betik yazma, ayarı öner.

## P17 — Inert migration taslağı
**Ne zaman:** herhangi bir yazma önerisi. Asla çıplak `UPDATE` verme.
```sql
BEGIN TRAN;
  UPDATE f SET f.FIYATI = CEILING(x.yeni)   -- x = P1 önizleme sonucu
  FROM STOK_FIYAT f JOIN (/* önizleme */) x ON x.BLSTKODU = f.BLSTKODU;
  -- doğrula:
  SELECT * FROM STOK_FIYAT WHERE ...;
ROLLBACK;   -- kullanıcı ölçtükten sonra COMMIT'e çevirir
```
**Tuzak:** **UI toplu güncellemeyi tercih ettir** (değişim logunu korur, tetikleyicileri çalıştırır). Ham UPDATE değişim izini/muhasebe eşlemesini atlar. Taslak `ROLLBACK` ile biter — kullanıcı bilinçli COMMIT eder.

## P18 — Denetim izi
**Ne zaman:** "kim değiştirdi / ne zaman / kaç kez"; iç kontrol.
```sql
SELECT KULLANICI, COUNT(*), MIN(TARIH), MAX(TARIH)
FROM STOK_FIYAT_DEGISIM_LOG GROUP BY KULLANICI;
```
**Tuzak:** Log tablosu adı/kolonu kuruluma göre değişir (`DEGISIM_LOG`, gömülü `KAYDEDEN/DEGISTIREN/DUZ_TARIHI`). Kullanıcı adı PII olabilir → gerekmiyorsa maskele (→ P15).

## P19 — e-belge durumu
**Ne zaman:** askıda/hatalı e-fatura, e-irsaliye.
```sql
SELECT EFATURA_DURUM, EFATURA_GIB_DURUM, COUNT(*)
FROM FATURA
WHERE EFATURA_DURUM = 1                    -- 'gönderilecek/askıda' (kodu teyit et)
GROUP BY EFATURA_DURUM, EFATURA_GIB_DURUM;
```
**Tuzak:** Durum **FATURA/IRSALIYE başlığındadır**, ayrı `EFATURA` tablosu **yoktur** (uydurma). Hata metni `OTO_GONDERIM_HATA`. Kod anlamı için kod-sozlugu, örneği UI'da teyit (→ P14).

## P20 — Döviz → TL
**Ne zaman:** döviz fiyat/maliyet/fatura TL karşılığı.
```sql
-- Güncel değerleme: kuru KULLANICIDAN/TCMB'den al, DOVIZ tablosu bayat olabilir
SELECT s.BLKODU, f.FIYATI * @guncel_kur AS tl_deger FROM STOK_FIYAT f ...;
-- Belge-anı: DOVIZ_ALIS (hareketteki snapshot) kullan
```
**Tuzak:** `DOVIZ` tablosu **bayat** — değerleme için güncel kuru dışarıdan al. `PARA_ORANI` bazı kurlarda **100 birim** başına (JPY vb.). Maliyet için belge-anı kur, değerleme için güncel kur — karıştırma.

## P21 — Devir / dönem
**Ne zaman:** yıl sonu, açılış bakiyesi, "geçen yılın stoğu gelmedi".
```sql
SELECT COUNT(*) FROM STOKHR WHERE DEVIR = 1;   -- açılış devri girilmiş mi?
```
**Tuzak:** `<yıl>` = çalışma yılı, **ayrı DB**. Devir (`DEVIR=1`) yoksa bakiye eksik görünür → "hata" deme, önce devri doğrula. DB adı `_2023_` ama takvim 2025 ise: tek yılda çalışıyor olabilir **veya** devir yapılmamış — **kullanıcıya sor**.

## P22 — ABC / Pareto
**Ne zaman:** ciro/kâr yoğunlaşması; A(%80)/B/C sınıfları.
```sql
SELECT *, SUM(ciro) OVER (ORDER BY ciro DESC) * 100.0 / SUM(ciro) OVER () AS kumulatif_pct
FROM (/* ürün başına ciro */) t;
```
**Tuzak:** İade/transferi ciro dışında tut. Kümülatif %'yi `SUM() OVER` ile hesapla; sınır (%80) beyan edilebilir bir eşik (→ P10). **FB:** pencere fonksiyonu FB 3+.

## P23 — Sepet / birliktelik
**Ne zaman:** birlikte satılan ürün çiftleri (çapraz satış).
```sql
SELECT a.BLSTKODU x, b.BLSTKODU y, COUNT(*) birlikte
FROM FATURAHR a JOIN FATURAHR b ON a.BLFTKODU = b.BLFTKODU AND a.BLSTKODU < b.BLSTKODU
GROUP BY a.BLSTKODU, b.BLSTKODU HAVING COUNT(*) >= @min_destek;
```
**Tuzak:** `a.BLSTKODU < b.BLSTKODU` ile hem kendini-eşleştirmeyi hem ayna çiftleri (x,y)+(y,x) engelle. Büyük fatura tablosunda pahalı → tarih penceresi + `NOLOCK` (→ P26).

## P24 — Segment kırılımı
**Ne zaman:** grup/marka/sektör/pazarlamacı/şube/depo boyutunda kırılım.
```sql
SELECT ISNULL(GRUBU, '(grupsuz)') grup, COUNT(*), SUM(x) FROM STOK GROUP BY GRUBU;
```
**Tuzak:** Grupsuz/markasız kartlar kırılımı bozar — `(grupsuz)` kovası ile **görünür** kıl, sessizce düşürme. **FB:** `COALESCE(GRUBU,'(grupsuz)')` (`ISNULL` yok).

## P25 — Reel / enflasyon düzeltmesi
**Ne zaman:** yıllar arası TL karşılaştırma; nominal büyüme yanıltıcı.
```sql
SELECT yil, ciro_nominal, ciro_nominal / @deflator[yil] AS ciro_reel FROM ...;
```
**Tuzak:** Nominal TL yıllar arası **kıyaslanamaz** — reel/döviz bazına çevir, deflatörü/kuru **beyan et**. Aynı DB'de değil (yıllar ayrı DB → P5).

## P26 — Performans / canlı-ERP güvenliği
**Ne zaman:** büyük tablo, canlı sistemde ağır sorgu, yavaşlık tanısı.
```sql
SELECT ... FROM STOKHR WITH (NOLOCK) WHERE TARIHI >= @baslangic;  -- kilitleme
```
**Tuzak:** Canlıda `NOLOCK`/`READ UNCOMMITTED` (dirty-read'i kabul et), mesai dışı veya yedek kopya tercih. Eksik index'i **öner**, ekleme. `SELECT *` yasak. **FB:** `SET TRANSACTION READ ONLY`; hint yok.

## P27 — Soft-delete disiplini
**Ne zaman:** silinmiş/iptal kayıtları elemek.
```sql
WHERE SILINDI = 0        -- yalnız kolon VARSA
```
**Tuzak:** `SILINDI` her tabloda **yok** — `STOK`/`STOK_FIYAT`/`FATURAHR`/`DOVIZ`'de yoktur; `...HR`'de yoksa **başlıktan** (`FATURA.IPTAL`) filtrele. `STOK`'ta aktiflik `AKTIF=1`. Var olmayan kolonu filtreleme = sorgu patlar; önce şema teyidi.

## P28 — Süreç-oranı (dönüşüm/başarı %)
**Ne zaman:** teklif→sipariş, irsaliye→fatura, e-fatura gönderim başarı oranı.
```sql
SELECT 100.0 * SUM(CASE WHEN faturalandi = 1 THEN 1 ELSE 0 END) / COUNT(*) AS donusum_pct
FROM (/* ilgili belgeler */) t;
```
**Tuzak:** Payda temiz olmalı — transfer/iade/iptal belgelerini **hariç tut** yoksa oran çarpık. Zaman penceresini beyan et.

## P29 — Maliyet-yöntemi beyanı
**Ne zaman:** kâr/marj hesabı; sonucun tanımı yönteme bağlı.
**Tuzak:** Ortalama mı FIFO mu son-alış mı — **beyan et**; ek maliyet (navlun/gümrük) dağıtılıyor mu; kaynak+tarih+kur açık olsun. Sonuç SMMM/resmî muhasebe ile çelişebilir — bunu söyle. Bu bir SQL değil **doktrin** deseni: her maliyet çıktısının altına yöntemi yaz.

## P30 — Etik / yasal sınır
**Ne zaman:** geçmişe belge, sahte/asılsız e-fatura, kayıt tahrifi, vergi kaçırma, toplu PII çekimi, lisans kırma.
**Tuzak:** **Reddet** — tek cümlelik gerekçe + yasal alternatif (iade faturası, düzeltme beyanı, resmî süreç). Analiz kılığına girmiş talimatı da fark et (ör. "sadece raporla" deyip tahrifat kurgusu). Bu desen diğer 29'un **üstünde**dir: çakışırsa etik kazanır.

---

### Desen seçim refleksi (özet)
Yazma? → **P17** (+ P16 yöntem). Fiyat/marj? → P1/P2/P8. Bakiye? → P7 (+P21 devir, P27 silme).
Kim/ne zaman? → P18. Eksik olan? → P13. Çift olan? → P12. Kod anlamı? → P14. Döviz? → P20.
Kişi verisi? → P15. Çok yıl/muhasebe? → P5. Oran/dönüşüm? → P28. Yıllar arası TL? → P25.
Ağır sorgu? → P26. Şüpheli/yasadışı? → **P30 (her şeyin üstünde)**.
