# Wolvox 8 — Şema Haritası (Jenerik Referans)

> **Bu dosya jenerik Wolvox 8 şema bilgisidir** — tablo/kolon adları, isimlendirme konvansiyonları,
> ilişkiler ve KVKK/PII kayıt defteri. Herhangi bir gerçek işletmeye ait **veri, satır sayısı, oran
> veya tarama sonucu içermez.** Kolon *isimleri* ürün şemasıdır (veriye ait değil); yine de sürüm/
> edisyon/lokalizasyona göre değişebileceğinden **kritik sorgudan önce `INFORMATION_SCHEMA` ile teyit et.**
>
> Motor: genelde **MS SQL Server** (bazı klasik kurulumlar Firebird). Diyalekt için engine'i doğrula.

---

## 1) Kurulum Profilini Kendin Çıkar (röntgen)
Şema bilgisi jeneriktir; **hangi modüllerin kullanıldığı, satır sayıları, hangi kodların geçtiği**
tamamen **kuruluma özeldir** → her install'da bunları **kendin tara** (salt-okunur). Başlangıç:
```sql
-- Dolu vs boş tablolar (kullanılan modül haritası)
SELECT t.name AS tablo, SUM(p.rows) AS satir
FROM sys.tables t JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN (0,1)
GROUP BY t.name ORDER BY satir DESC;
-- Mevcut firma/yıl/modül veritabanları (çapraz-DB gerçeği)
SELECT name FROM sys.databases WHERE name LIKE 'WOLVOX%' ORDER BY name;
```
> **Firebird ise** (klasik Wolvox, FB 2.5): `sys.*`/`INFORMATION_SCHEMA` yok, sistem tablolarını kullan:
> ```sql
> -- tablolar (kullanıcı tabloları)
> SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG=0 ORDER BY 1;
> -- bir tablonun kolonları (sırayla)
> SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS
> WHERE RDB$RELATION_NAME='STOK' ORDER BY RDB$FIELD_POSITION;
> ```
> Her `.FDB` **ayrı dosya/bağlantıdır** — çapraz-DB `UNION` yok; yıl/modül birleştirmeyi uygulama
> katmanında yap. Kolon **adları** iki motorda da aynıdır; yalnız diyalekt (bkz. [sorgu-recetesi.md](sorgu-recetesi.md) §Firebird) değişir.
> ⚠️ **"Modül boş → kullanılmıyor" sonucunu tek DB'ye bakarak verme.** Veri, DB adındaki `<modül>`
> parçasıyla **ayrı DB'lere** bölünür (bkz. §2). Örn. Genel Muhasebe `_WOLVOX`'ta değil `_GMUHASEBE`
> veritabanındadır. Ayrıca bazı kurulumlarda **standart-dışı, sonradan eklenmiş** tablolar (İngilizce/
> camelCase adlı senkron/bayi-portal katmanları) bulunabilir — bunlar native Wolvox değildir; şema
> doğrulanmadan üzerlerine analiz kurma, sahibine "kim kurdu, aktif mi?" diye sor.

---

## 2) İsimlendirme Konvansiyonları (jenerik — tablo görmeden kolon tahmini sağlar; yine de doğrula)

| Kalıp | Anlamı |
|---|---|
| `BLKODU` | Her tablonun `bigint` surrogate PK'sı |
| `BL<tablo>KODU` | Foreign key. `BLCRKODU`→CARI, `BLSTKODU`→STOK, `BLFTKODU`→FATURA, `BLBNHSKODU`→BANKA_HESAP, `BLHZMKODU`→HIZMET |
| `...HR` soneki | "Hareket" (satır/hareket tabloları): `CARIHR`, `STOKHR`, `KASAHR`, `BANKAHR`, `FATURAHR` |
| `_KPB` / `_DVZ` | Aynı tutarın **yerel para (KPB)** ve **döviz (DVZ)** karşılığı — çift kolon |
| `KPBDVZ` | Belgenin yerel mi (0/1) döviz mi işlendiği bayrağı |
| `DOVIZ_ALIS` / `DOVIZ_SATIS` | Belge anındaki kur (tarihsel — snapshot) |
| `SILINDI` | Mantıksal silme bayrağı (smallint) — **var olduğu tablolarda** filtrele |
| `IPTAL` | Fatura/belge iptal bayrağı |
| `OFFLINE_DURUM` / `OFFLINE_GUID` / `SOURCE_APP` | Mobil/offline senkron izi |
| `EFATURA_*` / `EIRSALIYE_*` / `EDF_*` | e-Dönüşüm alanları |
| `GM_ENTEGRASYON` / `MUH_KODU_*` / `MUHKODU_*` | Genel Muhasebe entegrasyon köprüsü (muhasebe verisi `_GMUHASEBE` DB'sinde) |
| `KAYDEDEN` / `DEGISTIREN` / `DEGISTIRME_TARIHI` | Denetim izi (audit) |
| `SUBE_KODU` | Çoklu şube ayrıştırıcı |

> **DB adlandırma:** `WOLVOX<sürüm>_<firma>_<yıl>_<modül>`. `<yıl>` = **çalışma yılı** (takvimden geri
> olabilir). `<modül>` = `WOLVOX` (stok/cari/fatura), `GMUHASEBE` (muhasebe), `IKAYNAK` (bordro),
> `DOSYA_2` … → veriyi **ayrı DB'lere böler**. Her `<yıl>` de ayrı DB'dir → çok-yıllı analiz **çapraz-DB**.
>
> **Soft-delete kuralı — ama SADECE kolonun olduğu yerde.** Çoğu işlem/master tabloda `SILINDI`
> (belgelerde ayrıca `IPTAL`) vardır; **ama bazılarında YOKTUR — eklersen sorgu patlar:** `STOK`
> (bunun yerine `AKTIF=1`), `STOK_FIYAT` (bayrak yok), `FATURAHR` (üst `FATURA` başlığından filtrele),
> `DOVIZ` (yok). Emin değilsen `INFORMATION_SCHEMA.COLUMNS` ile kontrol et.

---

## 3) Çekirdek Tablo Envanteri (roller — jenerik)
Bir Wolvox kurulumunda bulunan çekirdek tablolar ve rolleri (satır sayıları kuruluma özel → §1 ile
tara). Bu tablo adları/rolları üründe standarttır.

| Tablo | Rol |
|---|---|
| `STOK` / `STOKHR` | Stok kartı / stok hareketleri (giriş-çıkış, maliyet, bakiye) |
| `STOK_FIYAT` | Fiyat listeleri (alış/satış, çoklu liste) |
| `STOK_DEPO` / `STOK_TEDARIKCI` | Depo bazlı miktar / tedarikçi eşleşmeleri |
| `CARI` / `CARIHR` | Müşteri-tedarikçi kartı / borç-alacak hareketleri |
| `FATURA` / `FATURAHR` (+ `FATURA_KDV` / `FATURA_KUR`) | Fatura başlığı / satırları (+ KDV & kur yan tabloları) |
| `SIPARIS` / `SIPARISHR` | Sipariş başlığı / satırları |
| `IRSALIYE` / `IRSALIYEHR` | İrsaliye başlığı / satırları (sevk, depo transfer) |
| `TEKLIF` / `TEKLIFHR` | Teklif başlığı / satırları |
| `KASAHR` / `BANKAHR` / `BANKA_HESAP` | Kasa / banka hareketleri / hesaplar |
| `CEK_SENET` / `CEK_SENET_DT` | Çek/senet portföyü / detay |
| `DOVIZ` / `DOVIZ_HAREKET` | Kur tanımları / döviz hareketleri |
| `GRUP` / `GRUP_ARA` / `GRUP_ALT` | Stok grup hiyerarşisi |
| `MARKA` / `MODEL` / `BEDEN_TANIM` / `RENK_TANIM` | Marka/model + varyant (beden/renk) tanımları |
| `DEGISIM_LOG` / `STOK_FIYAT_DEGISIM_LOG` | Denetim izi (kim-ne-zaman değiştirdi) |
| `AYAR` / `EFATURA_AYAR` / `ZORUNLU_ALANLAR` | Kurulum/ayar tabloları |

> Genel Muhasebe tabloları (`HESAP_PLANI`, `YEVMIYE`, `YEVMIYEHR`) **`_GMUHASEBE` DB'sindedir**, burada değil.

---

## 4) Çekirdek Tabloların Anahtar Kolonları (jenerik, teyitli semantik)

> Wolvox tabloları çok geniştir (CARI/FATURA/IRSALIYE yüzlerce kolon). Aşağıda **analitik olarak
> önemli** kolonlar süzülmüştür. Tam liste için canlı `INFORMATION_SCHEMA.COLUMNS`.

### STOK — stok kartı
PK `BLKODU`. Anahtarlar: `STOKKODU`, `BARKODU`, `STOK_ADI`.
Analitik: `GRUBU`/`ARA_GRUBU`/`ALT_GRUBU`, `AKTIF` (1/0), `KDV_ORANI`, `DOVIZ_KULLAN` (1=döviz),
`DOVIZ_BIRIMI` (simge, serbest metin — hatalı olabilir), `MARKASI`, `MODELI`, `BIRIMI`.
- **Serbest sınıflandırma:** `OZEL_KODU1`, `OZEL_KODU2`, `OZEL_KODU3` (varchar; genelde 3 slot). Bir
  işlemi/otomasyonu **alt küme kartlara** uygulamak için ideal filtre (ör. `WHERE OZEL_KODU3=N'...'`).
  ⚠️ Bir slota yazmadan önce **doluluk oranını install'da ölç** — dolu bir slotun üstüne yazma.
- **Alışa özgü:** `KDV_ORANI_ALIS`, `PAZARLAMACI_KAR_ORANI`, alış iskonto seti (`ALIS_ISKONTO_*`,
  `ALISISK1..3_*`), `TEVKIFAT_KODU_ALIS`, `MUH_ALIS`.

### STOK_FIYAT — fiyatlar (kart başına çok satır)
`BLSTKODU`→STOK.BLKODU. `ALIS_SATIS` (**1=Alış, 2=Satış**), `FIYAT_NO` (fiyat listesi indeksi),
`FIYATI` (**KDV hariç/net**), `KPB_MI` (**1=TL, 2=döviz**), `FIYAT_DEG_TARIHI` (en güncel için DESC).
- **Yerleşik marj-fiyatlama alanları:** `KAR_MARJI` (kâr %), `KAYNAK_FIYAT_TIPI` (kaynak fiyat tipi —
  📖 muhtemelen 1=alış/2=satış, teyit et), `KAYNAK_FIYAT_INDEX` (kaynak `FIYAT_NO`), `ALIS_FIYATI_DEGISTI`
  (bayrak). Bir satış fiyatını bir alış fiyatına marjla **bağlayan** yerleşik mekanizma budur.
  ⚠️ Bu alanlar **kullanılıyor mu install'da ölç** — çoğu kurulum fiyatı statik/elle girer. Yerleşik
  marj **özel yuvarlama/bitiş ve asimetrik-sadece-yükselt yapamaz** → özel kural için toplu betik (§H reçete).

### STOKHR — stok hareketi (maliyet & bakiyenin kaynağı)
`BLSTKODU`→STOK.BLKODU. Miktar: `KPB_GMIK` (giren)/`KPB_CMIK` (çıkan) → **bakiye = Σ(KPB_GMIK−KPB_CMIK)**.
- **Maliyet/tutar:** `TUTAR_TURU` (📖 1=alış — teyit et), `KPB_FIYATI`, `KPB_TUTARI`, döviz eşlenikleri
  `DOVIZ_FIYATI`/`DOVIZ_TUTARI`/`DOVIZ_ALIS` (belge-anı kur snapshot).
- **Ayrıştırıcı bayraklar:** `IADE`, `DEVIR` — maliyet/**son alış** hesabında ikisini de dışla. `SILINDI=0`.
  Tarih: `TARIHI`. **Son alış (KDV hariç, TL):** `TUTAR_TURU=1 AND IADE=0 AND DEVIR=0 AND KPB_GMIK>0
  AND SILINDI=0` içinden `TARIHI DESC` en yeni `KPB_FIYATI`.

### DOVIZ — kurlar
`DOVIZ_SIMGESI`/`DOVIZ_BIRIMI`, `SATIS_FIYATI`/`ALIS_FIYATI`, `PARA_ORANI` (per-100 dövizlerde böl).
⚠️ **`DOVIZ` tablosu sık sık bayattır** → canlı TL dönüşümü için kuru **kullanıcıdan/TCMB'den** teyit et.

### CARI — müşteri/tedarikçi (**PII yoğun → §6**)
`BLKODU` (PK), `CARIKODU`, `SUBE_KODU`; gruplama `GRUBU`/`ARA_GRUBU`/`ALT_GRUBU`/`OZEL_KODU1..3`/`SEKTOR`;
ticari `VADE_GUN`, `ISKONTO_ORAN`, `RISKLI_MUSTERI`, `STOK_FIYATI` (müşterinin gördüğü fiyat listesi);
durum `AKTIF`/`SILINDI`; e-Dönüşüm `EFATURA_KULLAN`/`EFATURA_SENARYO`/`EIRSALIYE_KULLAN`.

### CARIHR — cari hareket
`BLCRKODU`→CARI. Borç/alacak: `KPB_BTUT`/`KPB_ATUT` (+ `DVZ_*`). `TARIHI`, `VADESI`, `ISLEM_TURU`,
`EVRAK_NO`, `SILINDI`. → **Cari bakiye = Σ(KPB_BTUT) − Σ(KPB_ATUT)** (SILINDI=0).

### FATURA — fatura başlığı
`BLKODU`, `FATURA_NO`, `BLCRKODU`→CARI, `SUBE_KODU`; `TARIHI`/`VADESI`/`FATURA_DURUMU`/`FATURA_TIPI`/
`IPTAL`/`SILINDI`; tutarlar `TOPLAM_ARA_KPB`/`TOPLAM_ISK_KPB`/`TOPLAM_KDV_KPB`/`TOPLAM_OTV_KPB`/
`TOPLAM_GENEL_KPB` (+ DVZ eşlenikleri); vergi `HESAPLANAN_KDV_KPB`/`TEVKIFAT_ORANI_1/2`/`OTV_KULLAN`/
`IHRAC_KAYDI`; e-Fatura `EFATURA_KULLAN`/`EFATURA_DURUM`/`EFATURA_GIB_DURUM`/`EFATURA_SENARYO`/
`EFATURA_GUID`/`OTO_GONDERIM_HATA`.

### FATURAHR — fatura satırı
`BLFTKODU`→FATURA, `BLSTKODU`→STOK, `STOKKODU`, `MIKTARI`, `KPB_FIYATI`, `KPB_KDV_HARICFY`,
`KPB_TOPLAM_TUTAR` (+DVZ); vergi `KDV_ORANI`/`OTV_ORANI`/`TEVKIFAT_KODU`/`ISTISNA_KODU`; `DEPO_ADI`,
`VARYANT_KODU`/`VARYANT_ACIKLAMA`. → **Ürün bazlı satış/kâr analizinin ana tablosu.**

### SIPARIS / IRSALIYE / KASAHR / CEK_SENET (özet)
- `SIPARIS`: `SIPARIS_NO`, `SIPARIS_TURU` (alış/satış), `SIPARIS_DURUMU`, `TESLIM_TARIHI`, `STOK_BLOKE`.
- `IRSALIYE`: `IRSALIYE_NO`, `IRSALIYE_DURUMU`, `FATURALANDI`, `TRS_KAYNAK_DEPO`/`TRS_HEDEF_DEPO`
  (depo transfer), e-İrsaliye `EIRSALIYE_DURUM`/`EIRSALIYE_GIB_DURUM`.
- `KASAHR`: `KASA_ADI`, `TARIHI`, `KPB_GLTUT` (gelen)/`KPB_GDTUT` (giden), `BLCRKODU`, `SILINDI`.
- `CEK_SENET`: `EVRAK_TURU`, `EVRAK_DURUMU`, `VADESI`, `KPB_TUTARI`, `KALAN_TUTAR`, `PROTESTO_OLDU`.

---

## 5) Standart-Dışı Alt Sistemlere Dikkat
Bazı kurulumlarda **native Wolvox olmayan**, sonradan eklenmiş tablolar bulunur (İngilizce/camelCase
adlar: `*OrderDetailRecords`, `*Copy`, `SYNCDATA`, `DS_*` vb.) — tipik olarak bir B2B bayi/e-ticaret
sipariş-senkron veya değişiklik-yakalama katmanı. **Yorum:** şema doğrulanmadan bunlara dayanan analiz
yapma; şişmiş olabilirler (bakım/arşiv adayı); sahibine kim kurdu/aktif mi diye sor. Bu tabloların
**varlığı ve boyutu kuruluma özeldir** → §1 ile tara.

---

## 6) KVKK / PII Kayıt Defteri
Aşağıdaki kolonlar **kişisel/ticari sır** içerir → sorguda **çekme veya maskele** (agregat tercih et):

| Tablo | PII kolonları |
|---|---|
| `CARI` | `ADI`, `SOYADI`, `TICARI_UNVANI`, `VERGI_NO`, `TC_KIMLIK_NO`, `TEL1/2`, `CEP_TEL`, `EV_TEL`, `E_MAIL`, `ADRESI_*`, `DOGUM_TARIHI`, `DOGUM_YERI`, `BABA_ADI`, `ANA_ADI`, `BANKA_*_IBAN`, `KEFIL_*`, `HUVIYET_NO` |
| `FATURA` / `IRSALIYE` / `SIPARIS` / `TEKLIF` | `ADI_SOYADI`, `TICARI_UNVANI`, `VERGI_NO`, `TEL1`, `CEP_TEL`, `E_MAIL`, `ADRESI`, `SEVK_ADRESI` |
| `CEK_SENET` | `ODKS_ADI/SOYADI/UNVANI/TEL/ADRESI`, `KEFIL_*` |
| `IRSALIYE` | `SOFOR_ADI_SOYADI`, `SOFOR_TC_KIMLIK_NO`, `ARAC_PLAKA` |

**Maskeleme:** `LEFT(ADI,1)+'***'`, `LEFT(VERGI_NO,3)+'****'`. Bireysel finansal dökümden kaçın;
`GRUBU`/`SEKTOR`/`YASLANDIRMA_GRUBU` gibi agregat kırılımları tercih et.

---

## 7) İlişki Haritası (jenerik)
```
CARI ──BLKODU◄──BLCRKODU── CARIHR / FATURA / IRSALIYE / SIPARIS / TEKLIF / CEK_SENET / KASAHR
STOK ──BLKODU◄──BLSTKODU── STOK_FIYAT / STOK_DEPO / STOK_TEDARIKCI / FATURAHR / STOKHR
FATURA ──BLKODU◄──BLFTKODU── FATURAHR (+ FATURA_KDV / FATURA_KUR)
SIPARIS ──BLKODU◄──BLSPKODU── SIPARISHR   ·   IRSALIYE ──BLKODU◄──BLIRKODU── IRSALIYEHR
BANKA_HESAP ──BLKODU◄──BLBNHSKODU── BANKAHR / KASAHR / CEK_SENET
DOVIZ ──simge── (KPBDVZ=döviz olan belgeler; kur belgede DOVIZ_ALIS/SATIS snapshot)
```
> Tutarları başlık toplamlarından (`TOPLAM_*_KPB`) okumak, satırdan yeniden hesaplamaktan güvenlidir.

---

*Bu harita jenerik ürün bilgisidir; sürüm/edisyona göre değişebilir. Kuruluma özel her şeyi (kullanılan
modüller, sayılar, kodlar) §1 ile kendin tara. Kritik sorgudan önce şema-first + teyit; salt-okunur çalış.*
