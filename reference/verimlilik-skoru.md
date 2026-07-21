# Wolvox 8 — Verimli Kullanım Skoru (Utilization / ERP-Olgunluk Taraması)

> **Amaç:** "Akınsoft'u ne kadar verimli kullanıyorum?" sorusunu tek bir **0–100 skoru** + boyut
> kırılımı + en yüksek getirili aksiyonlarla yanıtlar. Salt-okunur; her install'da tekrarlanabilir.
> "Tablo boş → modül kullanılmıyor" gibi kaba bakışın ötesine geçer: **benimseme genişliğini**,
> **veri kalitesini**, **özellik derinliğini**, **süreç bütünlüğünü** ve **bakım disiplinini** ayrı
> ölçüp ağırlıklı birleştirir. Yüksek benimseme + düşük derinlik gibi gerçek profilleri ayırt eder.
>
> **Mod A (offline):** her metriğin SQL'ini kullanıcıya ver, sonucu geri iste, aşağıdaki ağırlıklarla
> topla. **Mod B (bağlı):** §Uygulama'daki tek PowerShell taraması metrikleri çekip skoru üretir.
> Salt-okunur, `READ UNCOMMITTED`, PII yok (hepsi agregat sayı).

---

## Skor Modeli (5 boyut, ağırlıklı)

| Boyut | Ağırlık | Ölçtüğü |
|---|--:|---|
| 1. Modül Benimseme | 25% | Çekirdek modüllerden kaçı **anlamlı** veri taşıyor / gerçekten kullanılıyor |
| 2. Veri Kalitesi | 25% | Ana veri temizliği (gruplama, fiyat, KDV, döviz, barkod, negatif stok) |
| 3. Özellik Derinliği | 20% | Otomasyon/ileri özellik kullanımı (min-max, otomatik fiyat, çoklu liste, özel kod, varyant) |
| 4. Süreç Bütünlüğü | 20% | Belge zincirleri kapanıyor mu (e-fatura gönderim, irsaliye→fatura, muhasebeleşme) |
| 5. Bakım / Temizlik | 10% | Ölü stok, atıl kart, şişmiş/standart-dışı tablo, devir disiplini |

**Genel skor** = `0.25·B1 + 0.25·B2 + 0.20·B3 + 0.20·B4 + 0.10·B5`.
**Not bandı:** ≥85 **A** (mükemmel) · 70–84 **B** (iyi) · 55–69 **C** (orta) · 40–54 **D** (zayıf) · <40 **E** (kritik).

> **Ağırlıklar bir başlangıç varsayımıdır** — sektöre göre ayarla (ör. perakendede Özellik Derinliği,
> imalatta Süreç Bütünlüğü ağırlığını artır) ve raporda ağırlıkları **beyan et**.

---

## Boyut 1 — Modül Benimseme (25%)
Her çekirdek modül bir **ağırlık** taşır; **anlamlı kullanım eşiğini** geçiyorsa "benimsenmiş" sayılır.
Skor = `Σ(benimsenen ağırlık) / Σ(toplam ağırlık)`.

| Modül | Ağırlık | Benimseme testi (satır/kullanım) |
|---|--:|---|
| Stok | 3 | `STOKHR` > 0 |
| Cari | 3 | `CARIHR` > 0 |
| Fatura | 3 | `FATURA` > 0 |
| e-Dönüşüm | 3 | `FATURA WHERE EFATURA_KULLAN=1` > 0 |
| Genel Muhasebe | 3 | `[..._GMUHASEBE].dbo.YEVMIYE` > 0 (**çapraz-DB**) |
| Sipariş | 2 | `SIPARIS` > 0 |
| İrsaliye | 2 | `IRSALIYE` > 0 |
| Kasa | 1 | `KASAHR` > 0 |
| Banka | 1 | `BANKAHR` > 0 |
| Çek/Senet | 1 | `CEK_SENET` > 0 |
| Teklif | 1 | `TEKLIF` ≥ 500 (düşük hacim = fiilen kullanılmıyor) |
| Çoklu Depo | 1 | `DEPO` > 1 |
| Varyant | 1 | `FATURAHR WHERE VARYANT_KODU<>''` > 0 |

> ⚠️ Muhasebe **`_WOLVOX`'ta değil `_GMUHASEBE` DB'sinde** — burada arama; yoksa "muhasebe kullanılmıyor"
> yanılgısına düşersin. POS/Üretim gibi tablo izi net olmayan modülleri eşiğini teyit ederek ekle.

## Boyut 2 — Veri Kalitesi (25%)
Altı "temizlik oranı"nın ortalaması (her biri `1 − kirli/toplam`, 0–1):
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- grup_temiz:   1 - grupsuz/aktif
SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND (GRUBU IS NULL OR LTRIM(RTRIM(GRUBU))='');
-- fiyat_temiz:  1 - satis_fiyatsiz/aktif
SELECT COUNT(*) FROM STOK s WHERE s.AKTIF=1 AND NOT EXISTS
  (SELECT 1 FROM STOK_FIYAT f WHERE f.BLSTKODU=s.BLKODU AND f.ALIS_SATIS=2 AND ISNULL(f.FIYATI,0)>0);
-- kdv_temiz:    1 - eski_kdv(8/18)/aktif
SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND KDV_ORANI IN (8,18);
-- doviz_temiz:  1 - bozuk_doviz_birimi/doviz_kart
SELECT COUNT(*) FROM STOK WHERE DOVIZ_KULLAN=1 AND (DOVIZ_BIRIMI IS NULL
  OR LTRIM(RTRIM(DOVIZ_BIRIMI))='' OR DOVIZ_BIRIMI NOT IN (SELECT DOVIZ_SIMGESI FROM DOVIZ));
-- barkod_temiz: 1 - mukerrer_barkod_kart/barkodlu
-- negatif_temiz:1 - negatif_bakiyeli_kart/hareketli_kart   (bkz. sorgu-recetesi A5)
```

## Boyut 3 — Özellik Derinliği (20%)
Otomasyon/ileri özelliklerin kullanım oranı (0–1, ortalama). **En sık "verimsizlik" burada saklanır.**
```sql
-- minmax:      min stok tetikleyicisi tanimli kart / aktif
SELECT COUNT(DISTINCT BLSTKODU) FROM STOK_DEPO WHERE ISNULL(MIKTAR_MINIMUM,0)>0;
-- oto_fiyat:   yerlesik marj-fiyatlama kullanan satir / satis fiyat satiri
SELECT COUNT(*) FROM STOK_FIYAT WHERE ISNULL(KAYNAK_FIYAT_TIPI,0)<>0 OR ISNULL(KAR_MARJI,0)>0;
-- coklu_liste: 2./3. satis fiyat listesi kullanimi
SELECT COUNT(*) FROM STOK_FIYAT WHERE ALIS_SATIS=2 AND FIYAT_NO>1 AND ISNULL(FIYATI,0)>0;
-- ozel_kod:    serbest siniflandirma kullanimi / aktif
SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND LTRIM(RTRIM(ISNULL(OZEL_KODU1,'')))<>'';
-- varyant:     FATURAHR VARYANT_KODU kullanimi (0/1)
```

## Boyut 4 — Süreç Bütünlüğü (20%)
Belge zincirlerinin kapanma oranı (0–1, ortalama):
```sql
-- efatura_basari: 1 - askida/toplam_efatura
SELECT COUNT(*) FROM FATURA WHERE EFATURA_KULLAN=1 AND (EFATURA_DURUM=1 OR EFATURA_GIB_DURUM IS NULL);
-- irsaliye_donus: faturalanmis/toplam irsaliye  (⚠️ transfer & iade irsaliyelerini dis; aksi halde dusuk cikar)
SELECT COUNT(*) FROM IRSALIYE WHERE ISNULL(FATURALANDI,0)=1;
-- (ileri) muhasebelesme_orani: _GMUHASEBE yevmiye vs _WOLVOX belge sayisi — capraz-DB, opsiyonel
```

## Boyut 5 — Bakım / Temizlik (10%)
```sql
-- canli_stok: 1 - olu_stok(180g)/aktif   (bkz. sorgu-recetesi B1)
-- bloat:      native olmayan (Ingilizce/camelCase adli) sismis tablolar varsa ceza
SELECT TOP 10 t.name AS tablo, SUM(p.rows) AS satir
FROM sys.tables t JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN(0,1)
GROUP BY t.name ORDER BY SUM(p.rows) DESC;   -- en buyuk tablolari incele; native disi katman var mi?
-- aktif_disiplin: aktif/toplam stok (pasiflestirme hijyeni)
```

---

## Skoru Nasıl Yorumlarsın (jenerik profiller — gerçek veri değil)

Tarama sonrası çıkan boyut kırılımını **profil** olarak oku; en düşük boyut genelde en yüksek getirili
aksiyondur. Aşağıdakiler **temsilî (uydurma) örneklerdir** — herhangi bir işletmeye ait değildir,
yalnızca yorum mantığını gösterir:

- **Profil "geniş ama yüzeysel":** Benimseme yüksek (modüllerin çoğu kullanımda), Kalite orta-iyi, ama
  **Özellik Derinliği çok düşük** (otomatik fiyat/min-max/çoklu liste/varyant ~%0) ve **ölü stok ağır**.
  → Genel skor "C" bandına düşer. **Aksiyon:** önce derinlik (otomasyonu aç) + ölü stok tasfiyesi.
- **Profil "temiz ama dar":** Az modül kullanılıyor (Benimseme düşük) ama kullanılanlar temiz ve derin.
  → **Aksiyon:** eksik modülleri (sipariş/irsaliye/e-Dönüşüm/muhasebe entegrasyonu) devreye al.
- **Profil "hacimli ama dağınık":** Benimseme ve hacim yüksek, ama Kalite düşük (grupsuz kart, negatif
  stok, bozuk döviz) ve Süreç açık (askıda e-fatura, faturalanmamış irsaliye). → **Aksiyon:** veri
  hijyeni + belge zincirlerini kapat.

**Yorum kuralı:** her boyutun en zayıf 1–2 alt-metriğini isimlendir, **para/adetle** nicele, ve "bu
tek düzeltme genel skoru ~kaç puan taşır" diye tahmini etkiyi ver. Sayıları **kullanıcının kendi
taramasından** al — bu dosya örnek rakam barındırmaz.

---

## Uygulama (Mod B — tek salt-okunur tarama)
Aşağıdaki desen tüm metrikleri çeker ve skoru hesaplar (PowerShell + SqlClient, `ApplicationIntent=ReadOnly`);
her metrik kendi `try/catch`'inde olmalı ki biri patlarsa skor kısmi de olsa çıksın. Eksik (null)
metrik, ait olduğu boyutun ortalamasından **çıkarılarak** yeniden normalize edilir.
```text
skor = 0.25·Benimseme + 0.25·Kalite + 0.20·Derinlik + 0.20·Süreç + 0.10·Bakım
  Benimseme = Σ(benimsenen ağırlık)/Σ(ağırlık)
  diğer boyutlar = alt-metriklerin (her biri 0–1) ortalaması × 100
```
> ⚠️ Mod A'da aynı SQL'leri kullanıcıya verip sonuçları bir tabloya toplat, ağırlıklarla çarp.
> Sayı üretmeden önce **her metriğin varsayımını** (eşik, hariç tutulanlar, tarih penceresi) beyan et.

*Skor nokta-atışı bir gözlemdir; ağırlıklar ve eşikler sektöre/mevzuata göre ayarlanır. Kritik
işten önce şema-first + teyit; salt-okunur çalış.*
