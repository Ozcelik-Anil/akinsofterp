# Wolvox 8 — Sorgu Reçete Kitabı (Cookbook)

> Hazır, **salt-okunur** tanı sorguları (jenerik — herhangi bir Wolvox 8 kurulumunda çalışır). Sonuç
> sayıları **kuruluma özeldir**; bu dosya gerçek bir işletmeye ait sayı/sonuç içermez — çalıştırıp
> kendi rakamını üret.
>
> **Kullanım kuralları:**
> - Her sorgu başına `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;` ekle (kilitleme yok).
> - `SILINDI`/`IPTAL` bayraklarını **var oldukları tablolarda** filtrele (bkz. [schema-map §2](schema-map.md)).
> - `✅` = jenerik/güvenli desen · `🔹` = şema-uyumlu, çalıştırmadan oran/kod teyit et.
> - Kişisel veri (PII) çekme — [schema-map §6](schema-map.md) maskeleme kayıt defteri.

---

## A. VERİ SAĞLIĞI (temizlik hedefleri)

### A1 Döviz kullanan ama geçersiz/boş DOVIZ_BIRIMI
Döviz fiyatlı ama para birimi tanımsız kartlar → TL dönüşümü patlar.
````sql
SELECT COUNT(*) AS hatali
FROM STOK
WHERE DOVIZ_KULLAN = 1
  AND (DOVIZ_BIRIMI IS NULL OR LTRIM(RTRIM(DOVIZ_BIRIMI)) = ''
       OR DOVIZ_BIRIMI NOT IN (SELECT DOVIZ_SIMGESI FROM DOVIZ));
````
> *Düzeltme UI:* Stok Kartı → Döviz sekmesi (toplu güncelleme).

### A2 Mükerrer barkod
Aynı barkod birden fazla kartta → terminalde yanlış ürün okutma.
````sql
SELECT BARKODU, COUNT(*) AS kart_sayisi
FROM STOK
WHERE BARKODU IS NOT NULL AND LTRIM(RTRIM(BARKODU)) <> ''
GROUP BY BARKODU HAVING COUNT(*) > 1
ORDER BY kart_sayisi DESC;
````

### A3 Grup kodsuz aktif kart
Gruplama olmadan hiçbir kırılım raporu (ABC, kampanya hedefleme) güvenilir olmaz.
````sql
SELECT COUNT(*) AS grupsuz
FROM STOK
WHERE AKTIF = 1 AND (GRUBU IS NULL OR LTRIM(RTRIM(GRUBU)) = '');
````

### A4 Eski KDV oranı (8/18) taşıyan aktif kart
2023 sonrası oranlar 1/10/20. Eski 8/18 kalmışsa yanlış fatura riski.
````sql
SELECT COUNT(*) AS eski_kdv FROM STOK WHERE AKTIF = 1 AND KDV_ORANI IN (8, 18);
````
> ⚠️ **Asla otomatik değiştirme** — mevzuat + muhasebeci onayı şart.

### A5 Negatif bakiyeli stok kartı
Fiziksel imkânsız; genelde eksik açılış/devir ya da sırasız hareket girişi.
````sql
SELECT COUNT(*) AS negatif FROM (
  SELECT BLSTKODU, SUM(ISNULL(KPB_GMIK,0) - ISNULL(KPB_CMIK,0)) AS bakiye
  FROM STOKHR WHERE ISNULL(SILINDI,0) = 0
  GROUP BY BLSTKODU
  HAVING SUM(ISNULL(KPB_GMIK,0) - ISNULL(KPB_CMIK,0)) < -0.001
) x;
-- Bakiye = giren (KPB_GMIK) - çıkan (KPB_CMIK)
````
> Negatif çıkarsa: açılış/sayım eksikliği; önce devir yapılmış mı doğrula.

### A6 Aktif ama satış fiyatı olmayan kart
Satışta fiyat gelmez → operatör elle girer → tutarsızlık.
````sql
SELECT COUNT(*) AS fiyatsiz
FROM STOK s
WHERE s.AKTIF = 1 AND NOT EXISTS (
  SELECT 1 FROM STOK_FIYAT f
  WHERE f.BLSTKODU = s.BLKODU AND f.ALIS_SATIS = 2 AND ISNULL(f.FIYATI,0) > 0);
````

### A7 Pasif ama son 90 günde hareket görmüş kart
Yanlışlıkla pasife alınmış ama hâlâ satılan ürünler.
````sql
SELECT COUNT(DISTINCT s.BLKODU) AS tutarsiz
FROM STOK s
JOIN STOKHR h ON h.BLSTKODU = s.BLKODU AND ISNULL(h.SILINDI,0) = 0
WHERE s.AKTIF = 0 AND h.TARIHI >= DATEADD(DAY, -90, GETDATE());
````

---

## B. TİCARİ ANALİZ

### B1 Ölü / hareketsiz stok (aktif, son 180 gün hareketsiz)
Sermayeyi bağlayan durgun stok.
````sql
SELECT COUNT(*) AS olu_stok
FROM STOK s
WHERE s.AKTIF = 1 AND NOT EXISTS (
  SELECT 1 FROM STOKHR h
  WHERE h.BLSTKODU = s.BLKODU AND ISNULL(h.SILINDI,0) = 0
    AND h.TARIHI >= DATEADD(DAY, -180, GETDATE()));
-- Listelemek için COUNT yerine: SELECT s.STOKKODU, s.STOK_ADI, s.GRUBU
````
> ⚠️ Eşiği (180 gün) ve maliyet yöntemini beyan et; sezonluk ürünleri ayır. TL karşılığı için bakiye × maliyet.

### B2 Cari bakiye & toplam alacak (agregat — PII yok)
````sql
SELECT
  COUNT(*)                                              AS cari_sayisi,
  SUM(CASE WHEN bak > 0.01 THEN 1 ELSE 0 END)           AS borclu_adet,
  CAST(SUM(CASE WHEN bak > 0 THEN bak ELSE 0 END) AS decimal(18,2)) AS toplam_alacak_kpb
FROM (
  SELECT h.BLCRKODU, SUM(ISNULL(h.KPB_BTUT,0) - ISNULL(h.KPB_ATUT,0)) AS bak
  FROM CARIHR h WHERE ISNULL(h.SILINDI,0) = 0
  GROUP BY h.BLCRKODU
) x;
-- Cari bakiye = Σ borç (KPB_BTUT) - Σ alacak (KPB_ATUT); bak>0 => bize borçlu
````

### B3 En çok satan ürünler (miktar, son 12 ay)
````sql
SELECT TOP 50 h.STOKKODU, h.STOK_ADI,
       SUM(h.MIKTARI)          AS toplam_miktar,
       SUM(h.KPB_TOPLAM_TUTAR) AS toplam_ciro_kpb
FROM FATURAHR h
JOIN FATURA f ON f.BLKODU = h.BLFTKODU
WHERE ISNULL(f.SILINDI,0) = 0 AND ISNULL(f.IPTAL,0) = 0
  AND f.FATURA_TIPI = 1                      -- satış (tipini teyit et)
  AND f.TARIHI >= DATEADD(MONTH, -12, GETDATE())
GROUP BY h.STOKKODU, h.STOK_ADI
ORDER BY toplam_miktar DESC;
````
> 🔹 `FATURA_TIPI` kod eşlemesini (satış/alış/iade) çalıştırmadan teyit et.

### B4 Stok devir hızı (grup bazında, kaba)
````sql
SELECT s.GRUBU,
       COUNT(DISTINCT s.BLKODU) AS kart,
       SUM(cikis.miktar)        AS yil_cikis
FROM STOK s
OUTER APPLY (
  SELECT SUM(ISNULL(h.KPB_CMIK,0)) AS miktar
  FROM STOKHR h
  WHERE h.BLSTKODU = s.BLKODU AND ISNULL(h.SILINDI,0) = 0
    AND h.TARIHI >= DATEADD(MONTH, -12, GETDATE())
) cikis
WHERE s.AKTIF = 1
GROUP BY s.GRUBU
ORDER BY yil_cikis DESC;
````
> Ortalama stok yerine güncel bakiye kullanınca yanılma payını belirt.

---

## C. e-DÖNÜŞÜM

### C1 Askıda / gönderilmemiş e-Fatura
`EFATURA_KULLAN=1` ama gönderim durumu tamamlanmamış faturalar. e-belge durumu **ayrı tabloda değil**,
`FATURA` başlığındadır.
````sql
SELECT COUNT(*) AS askida
FROM FATURA
WHERE ISNULL(SILINDI,0) = 0 AND EFATURA_KULLAN = 1
  AND (EFATURA_DURUM = 1 OR EFATURA_GIB_DURUM IS NULL
       OR LTRIM(RTRIM(CAST(EFATURA_GIB_DURUM AS varchar))) = '');
````
> ⚠️ `EFATURA_DURUM` (1=bekliyor, 2=gönderildi) ve `EFATURA_GIB_DURUM` (sayısal GİB kodu) anlamlarını
> bir örnek faturayı UI'da açıp **teyit et** — kodlar kuruluma/entegratöre göre değişebilir.

### C2 Otomatik gönderim hatası olan faturalar
````sql
SELECT FATURA_NO, TARIHI, LEFT(OTO_GONDERIM_HATA, 120) AS hata
FROM FATURA
WHERE ISNULL(SILINDI,0) = 0
  AND OTO_GONDERIM_HATA IS NOT NULL AND LTRIM(RTRIM(OTO_GONDERIM_HATA)) <> ''
ORDER BY TARIHI DESC;
````

---

## D. BAKIM / SİSTEM

### D1 Şişmiş / standart-dışı tablolar
Bazı kurulumlarda native olmayan büyük tablolar (senkron/bayi katmanı) bulunur.
````sql
SELECT t.name AS tablo, SUM(p.rows) AS satir
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY t.name ORDER BY SUM(p.rows) DESC;
````
> En büyük tabloları incele; native olmayan (İngilizce/camelCase) şişmiş tablo çıkarsa sahibine sor:
> entegrasyon aktif mi, arşivlenebilir mi ([schema-map §5](schema-map.md)).

### D2 Boş tablo envanteri (kullanılmayan modül haritası)
````sql
SELECT t.name AS tablo
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY t.name HAVING SUM(p.rows) = 0
ORDER BY t.name;
````

### D3 Eksik index önerileri (performans — asla otomatik ekleme)
````sql
SELECT TOP 20
  DB_NAME(mid.database_id) AS db, OBJECT_NAME(mid.object_id) AS tablo,
  migs.avg_user_impact AS etki_yuzde, migs.user_seeks AS arama,
  mid.equality_columns, mid.inequality_columns, mid.included_columns
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig ON mig.index_handle = mid.index_handle
JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
WHERE mid.database_id = DB_ID()
ORDER BY migs.avg_user_impact DESC;
-- Tipik aday kolonlar: TARIHI, BLSTKODU, BLCRKODU, BLFTKODU.
````
> DMV verisi servis yeniden başlayınca sıfırlanır; bir süre çalışmış sunucuda anlamlıdır.

---

## E. DENETİM İZİ

### E1 Fiyat değişim geçmişi (bir kartın)
`STOK_FIYAT_DEGISIM_LOG` her fiyat değişimini tutar.
````sql
SELECT l.KAYIT_TARIHI, l.KAYDEDEN, l.ALIS_SATIS, l.FIYAT_NO, l.FIYATI
FROM STOK_FIYAT_DEGISIM_LOG l
JOIN STOK s ON s.BLKODU = l.BLSTKODU
WHERE s.STOKKODU = N'<STOKKODU>'
ORDER BY l.KAYIT_TARIHI DESC;
````

### E2 Genel değişim logu
`DEGISIM_LOG`: `TABLO_ADI`, `BLMASKODU`, `DEGISIM_LOGU`, `KULLANICI`, `MAKINE_ID`, `UYGULAMA`, `TARIHI`.
````sql
SELECT TOP 100 TARIHI, TABLO_ADI, KULLANICI, MAKINE_ID, UYGULAMA, DEGISIM_LOGU
FROM DEGISIM_LOG
WHERE TARIHI >= DATEADD(DAY,-7,GETDATE())
ORDER BY TARIHI DESC;
````
> Kullanıcı adı PII değil (müşteri verisi değil).

---

## F. VARYANT (beden / renk)
`FATURAHR.VARYANT_KODU`/`VARYANT_ACIKLAMA`; tanımlar `BEDEN_TANIM`, `RENK_TANIM`, `MODEL`, `MARKA`.
````sql
SELECT h.VARYANT_ACIKLAMA, SUM(h.MIKTARI) AS toplam_miktar, SUM(h.KPB_TOPLAM_TUTAR) AS ciro
FROM FATURAHR h
JOIN FATURA f ON f.BLKODU = h.BLFTKODU
WHERE ISNULL(f.SILINDI,0)=0 AND ISNULL(f.IPTAL,0)=0
  AND ISNULL(h.VARYANT_KODU,'') <> ''
  AND f.TARIHI >= DATEADD(MONTH,-12,GETDATE())
GROUP BY h.VARYANT_ACIKLAMA
ORDER BY toplam_miktar DESC;
````

---

## G. ÇAPRAZ-YIL (bkz. skill.md → Cross-Database & Multi-Year)
Yıldan-yıla ciro için üç-parçalı adlandırma + `UNION ALL`. Önce `SELECT name FROM sys.databases
WHERE name LIKE 'WOLVOX%'` ile mevcut yıl/firma/modül DB'lerini keşfet. Firma kodu farklı = ayrı
işletme. Genel Muhasebe verisi `_GMUHASEBE` DB'sinde (`YEVMIYE`,`HESAP_PLANI`).

---

## H. OTOMATİK YENİDEN FİYATLAMA (maliyet → satış, alt küme, asimetrik)

**Senaryo:** "Seçili ürünlerde alış maliyeti artınca satış fiyatı otomatik güncellensin" (marj × çarpan,
özel bir yuvarlama/bitiş, ve maliyet düşse bile **indirme**). Yerleşik marj (`STOK_FIYAT.KAR_MARJI`+
`KAYNAK_FIYAT_TIPI`) düz `alış×(1+kâr)` yapar ama **özel bitiş ve asimetrik-sadece-yükselt yapamaz**.

**Yaklaşım kararı:**
- **A — Yerleşik marj:** alışta **anında**, defter-güvenli. *Ama* özel yuvarlama/bitiş yok, asimetrik değil.
- **B — Zamanlanmış toplu betik:** özel formülün **tamamını** uygular; periyodik. Betik salt-okunur okur,
  **migration TASLAĞI üretir**, kullanıcı çalıştırır. **Karmaşık kural = B.**
- **C — DML trigger:** REDDET — canlı üretimde riskli, defter eşlemesini bozar.

> ⚠️ Yeniden fiyatlama bir **yazma** işidir: önce ölçen SELECT (H2), sonra **inert taslak**
> (`BEGIN TRAN … ROLLBACK`) veya **UI toplu güncelleme** (fiyat log'unu korur). Ham UPDATE'i "çalıştır" verme.

### H1 Alt küme seçimi — Özel Kod ile işaretle
Boş bir `OZEL_KODU*` slotunu işaretçi yap; **yazmadan önce doluluk ölç** (dolu slotun üstüne yazma):
````sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT
  SUM(CASE WHEN LTRIM(RTRIM(ISNULL(OZEL_KODU1,'')))<>'' THEN 1 ELSE 0 END) AS OK1,
  SUM(CASE WHEN LTRIM(RTRIM(ISNULL(OZEL_KODU2,'')))<>'' THEN 1 ELSE 0 END) AS OK2,
  SUM(CASE WHEN LTRIM(RTRIM(ISNULL(OZEL_KODU3,'')))<>'' THEN 1 ELSE 0 END) AS OK3,
  COUNT(*) AS aktif
FROM STOK WHERE AKTIF=1;
````
İşaretleme **UI ile** (tercih): *Stok Kartı > Özel Kodlar*; toplu için *Stok > Toplu Güncelleme*.

### H2 Yeniden fiyatlama ÖNİZLEMESİ (asimetrik, salt-okunur)
Uygulamadan önce **her zaman** göster. Kural: `hedef = CEILING(maliyet × ÇARPAN) − 1` (tam TL'ye yukarı
yuvarla, 1 çıkar; ondalıklıda = FLOOR, tam sayıda = x−1). **Asimetrik:** yalnız `hedef > mevcut` yükselt.
> Sayısal doğrulama (çarpan=1 erozyonu, KDV taban tuzağı dâhil) → [hesaplama-ornekleri §1-2](hesaplama-ornekleri.md).
````sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @carpan  float        = 1.50;         -- iş marjı çarpanı (örnek — KENDİ marjınızı girin)
DECLARE @ozelkod nvarchar(20) = N'<OZELKOD>'; -- alt-küme etiketi (örnek — KENDİ özel kodunuz)
WITH sonalis AS (
  SELECT BLSTKODU, KPB_FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY TARIHI DESC, KAYIT_TARIHI DESC) rn
  FROM STOKHR
  WHERE TUTAR_TURU=1 AND ISNULL(IADE,0)=0 AND ISNULL(DEVIR,0)=0
    AND ISNULL(KPB_GMIK,0)>0 AND ISNULL(SILINDI,0)=0 AND KPB_FIYATI>0
),
satis AS (
  SELECT BLSTKODU, FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY FIYAT_DEG_TARIHI DESC) rn
  FROM STOK_FIYAT WHERE ALIS_SATIS=2 AND FIYAT_NO=1 AND KPB_MI=1
)
SELECT s.STOKKODU,
  CAST(a.KPB_FIYATI AS decimal(18,2))                       AS Son_Alis,
  CAST(CEILING(a.KPB_FIYATI*@carpan)-1 AS decimal(18,2))    AS Hedef,
  CAST(sa.FIYATI AS decimal(18,2))                          AS Mevcut,
  CASE WHEN (CEILING(a.KPB_FIYATI*@carpan)-1) > sa.FIYATI THEN 'YUKSELT' ELSE 'DOKUNMA' END AS Karar
FROM STOK s
JOIN sonalis a ON a.BLSTKODU=s.BLKODU AND a.rn=1
JOIN satis   sa ON sa.BLSTKODU=s.BLKODU AND sa.rn=1
WHERE s.AKTIF=1 AND LTRIM(RTRIM(ISNULL(s.OZEL_KODU3,'')))=@ozelkod   -- alt küme (kendi özel kodunuz)
ORDER BY (CEILING(a.KPB_FIYATI*@carpan)-1)-sa.FIYATI DESC;
````
> ⚠️ **Sadece TL** (`KPB_MI=1`); döviz fiyatlıları belge-anı kurla (`STOKHR.DOVIZ_FIYATI`) ayrı ele al.
> Asimetrik kural zaten marjın üstünde satılanlara dokunmaz; `CEILING−1`, tam marjda olanları birkaç
> kuruş altta bırakıp gereksiz fiyat kıpırdanmasını önler.

### H3 Uygulama — inert MIGRATION TASLAĞI (kullanıcı çalıştırır)
Önizleme onaylanınca. **Önce UI toplu güncellemeyi öner** (log korur):
````sql
-- ⚠️ MIGRATION TASLAĞI — YEDEK + TEST KOPYASI + TRANSACTION. Çalıştıran: kullanıcı. Sadece YÜKSELTİR.
BEGIN TRAN;
DECLARE @carpan  float        = 1.50;         -- örnek — KENDİ marjınız
DECLARE @ozelkod nvarchar(20) = N'<OZELKOD>'; -- örnek — KENDİ özel kodunuz
;WITH sonalis AS (
  SELECT BLSTKODU, KPB_FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY TARIHI DESC, KAYIT_TARIHI DESC) rn
  FROM STOKHR
  WHERE TUTAR_TURU=1 AND ISNULL(IADE,0)=0 AND ISNULL(DEVIR,0)=0
    AND ISNULL(KPB_GMIK,0)>0 AND ISNULL(SILINDI,0)=0 AND KPB_FIYATI>0
)
UPDATE sf
  SET sf.FIYATI = CEILING(a.KPB_FIYATI*@carpan)-1, sf.FIYAT_DEG_TARIHI = GETDATE()
FROM STOK_FIYAT sf
JOIN STOK s    ON s.BLKODU=sf.BLSTKODU
JOIN sonalis a ON a.BLSTKODU=sf.BLSTKODU AND a.rn=1
WHERE s.AKTIF=1 AND LTRIM(RTRIM(ISNULL(s.OZEL_KODU3,'')))=@ozelkod
  AND sf.ALIS_SATIS=2 AND sf.FIYAT_NO=1 AND sf.KPB_MI=1
  AND (CEILING(a.KPB_FIYATI*@carpan)-1) > sf.FIYATI;   -- asimetrik
-- Etkilenen satırı doğrula; doğruysa COMMIT, değilse ROLLBACK:
ROLLBACK;  -- güvenlik için varsayılan
````
**B (zamanlanmış):** aynı mantığı PowerShell+SqlClient betiğine koy; önizlemeyi CSV'ye, UPDATE'i
`-- COMMIT bekliyor` başlıklı `.sql`'e yazsın; kullanıcı Görev Zamanlayıcı'ya ekler. Betiğin **yazma
yetkisi olmasın** — sadece taslak üretsin.

---

## §Firebird — diyalekt çevirisi (Wolvox classic, genelde FB 2.5)

Yukarıdaki reçeteler **MSSQL (T-SQL)**. Motor Firebird ise şu eşlemeyi uygula. Wolvox classic **FB 2.5**
taşır — pencere fonksiyonu (`ROW_NUMBER`), CTE davranışı ve bazı fonksiyonlar sürüme bağlı.

| İşlev | MSSQL | Firebird (2.5 / 3+) |
|---|---|---|
| İlk N satır | `SELECT TOP 100 …` | `SELECT FIRST 100 …` · `… ROWS 1 TO 100` |
| Null-coalesce | `ISNULL(x,0)` | `COALESCE(x,0)` (**`ISNULL` yok**) |
| Bugün | `GETDATE()` / `CAST(GETDATE() AS date)` | `CURRENT_DATE` / `CURRENT_TIMESTAMP` |
| Tarih aritmetiği | `DATEADD(DAY,-90,GETDATE())` | `DATEADD(-90 DAY TO CURRENT_DATE)` |
| İki tarih farkı | `DATEDIFF(DAY,a,b)` | `DATEDIFF(DAY FROM a TO b)` |
| String birleştirme | `a + b` / `+ N'***'` | `a \|\| b` / `\|\| '***'` |
| Substring | `LEFT(x,3)` | `LEFT(x,3)` (FB 2.1+) · `SUBSTRING(x FROM 1 FOR 3)` |
| Salt-okunur/kilitsiz | `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;` / `WITH(NOLOCK)` | `SET TRANSACTION READ ONLY READ COMMITTED;` (**hint yok**, MVCC) |
| Şema keşfi | `INFORMATION_SCHEMA.COLUMNS` | `RDB$RELATION_FIELDS` / `RDB$RELATIONS` (`RDB$SYSTEM_FLAG=0`) |
| Tavan/taban | `CEILING(x)` / `FLOOR(x)` | `CEILING(x)` / `FLOOR(x)` (FB 2.1+) |
| En güncel satır | `ROW_NUMBER() OVER(PARTITION BY…)` | FB 3+ aynı; **FB 2.5'te yok** → bağ-sorgu `FIRST 1` veya `MAX(TARIHI)` self-join |

**Örnek — "güncel net satış fiyatı" (A-tipi) FB karşılığı** (FB 2.5, pencere fonksiyonsuz):
```sql
SET TRANSACTION READ ONLY READ COMMITTED;
SELECT s.STOKKODU, s.STOK_ADI,
  (SELECT FIRST 1 sf.FIYATI FROM STOK_FIYAT sf
     WHERE sf.BLSTKODU=s.BLKODU AND sf.ALIS_SATIS=2 AND sf.FIYAT_NO=1
     ORDER BY sf.FIYAT_DEG_TARIHI DESC) AS Net_Fiyat
FROM STOK s WHERE s.AKTIF=1;
```

**Örnek — 90+ gün hareketsiz cari (C-tipi), PII maskeli, FB:**
```sql
SELECT LEFT(c.TICARI_UNVANI,1) || '***' AS Cari_Maskeli, c.BLKODU,
       MAX(h.TARIHI) AS Son_Hareket
FROM CARI c JOIN CARIHR h ON h.BLCRKODU=c.BLKODU AND COALESCE(h.SILINDI,0)=0
GROUP BY c.BLKODU, c.TICARI_UNVANI
HAVING MAX(h.TARIHI) < DATEADD(-90 DAY TO CURRENT_DATE);
```

**Yeniden fiyatlama (§H) FB notu:** `ISNULL→COALESCE`, `GETDATE()→CURRENT_TIMESTAMP`, `ROW_NUMBER`
yoksa son-alışı `(SELECT FIRST 1 … ORDER BY TARIHI DESC)` alt-sorgusuyla al. `CEILING(x*@carpan)-1`
mantığı aynı kalır; parametre yerine FB'de `EXECUTE BLOCK` değişkeni veya doğrudan sabit kullan.
Migration taslağı FB'de de inert: `SET TRANSACTION`; `UPDATE …`; sonra `ROLLBACK;` (isql).

> **Kural:** motoru **Session Bootstrap #1**'de doğrula; emin değilken diyalekte özel sözdizimi yazma.
> Reçeteyi çalıştırmadan önce FB'de kolon/tablo adını `RDB$RELATION_FIELDS` ile teyit et (şema-first).

---

*Reçeteler jeneriktir; sonuç sayıları kuruluma özeldir. Kritik sorgudan önce şema/oran kodlarını teyit
et, salt-okunur çalış, PII maskele.*
