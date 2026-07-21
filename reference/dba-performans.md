# Wolvox 8/9 — DBA / Performans & Göç Rehberi

> Danışmanın **teknik derinlik** teslimatı: yavaşlık teşhisi, indeks/bakım önerileri, kilit/deadlock,
> ve göç (8→9, MSSQL↔Firebird, yıl/firma taşıma). Motor genelde **MS SQL Server** (bazı klasik kurulumlar
> **Firebird 2.5**). Diyalekt için → [sorgu-recetesi §Firebird](sorgu-recetesi.md).
>
> ⚠️ **Doktrin:** (1) Danışman **salt-okunur** teşhis eder; indeks/bakım **DDL yazma yetkisi müşteride**.
> (2) Öneriler **inert taslak** olarak verilir (`-- öneri:` yorumlu), müşteri **yedek + test kopyası**nda
> dener. (3) Wolvox **paketli üründür** — şemaya indeks eklemek çoğu kez güvenli ama **tablo/kolon
> değiştirme yasak** (güncelleme bozar). Yalnız **non-clustered indeks** ve **istatistik/bakım** öner.
> (4) Native tabloya index eklemenin Akınsoft güncellemesinde **düşebileceğini** söyle; kayıt tut.

---

## 1) Yavaşlık teşhisi (salt-okunur, önce ölç)

**Sıcak tabloları bul** (satır + I/O):
```sql
SELECT t.name, SUM(p.rows) rows,
       SUM(a.total_pages)*8/1024 AS mb
FROM sys.tables t
JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN (0,1)
JOIN sys.allocation_units a ON p.partition_id=a.container_id
GROUP BY t.name ORDER BY rows DESC;   -- tipik ilk sıralar: STOKHR, CARIHR, FATURA_*, STOK
```
**En pahalı sorgular** (plan cache — hangi ekran yavaş):
```sql
SELECT TOP 20 qs.total_worker_time/qs.execution_count AS avg_cpu,
       qs.total_logical_reads/qs.execution_count AS avg_reads,
       qs.execution_count, SUBSTRING(st.text,1,200) AS sorgu
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_reads DESC;
```
**Eksik indeks önerileri** (DMV — körü körüne uygulama, değerlendir):
```sql
SELECT migs.avg_user_impact, mid.statement AS tablo,
       mid.equality_columns, mid.inequality_columns, mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle=migs.group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle=mid.index_handle
ORDER BY migs.avg_user_impact DESC;
```
> **Firebird:** DMV yok. `MON$` tablolarını kullan (`MON$STATEMENTS`, `MON$IO_STATS`); plan için
> `SET PLAN ON`. Yavaşlık çoğu kez eski **istatistik** (`SET STATISTICS INDEX ...`) veya düşük **page buffer**.

---

## 2) İndeks önerileri (sıcak tablolar — inert taslak)

> Aşağıdakiler **tipik erişim desenine** göre önerilerdir; **her biri DMV + gerçek sorguyla doğrulanmalı**,
> körlemesine eklenmemeli (yazma maliyeti + güncelleme riski). Adları install şemasıyla teyit et.

```sql
-- STOKHR: "son alış" / hareket sorguları stok+tarih+tür filtreler (P8/P10)
-- öneri: CREATE NONCLUSTERED INDEX IX_STOKHR_stok_tarih ON STOKHR (BLKODU, TARIHI)
--        INCLUDE (TUTAR_TURU, KPB_FIYATI, IADE, DEVIR);
-- CARIHR: ekstre/yaşlandırma cari+tarih (P7/P9)
-- öneri: CREATE NONCLUSTERED INDEX IX_CARIHR_cari_tarih ON CARIHR (CARI_BLKODU, TARIHI)
--        INCLUDE (KPB_BTUT, KPB_ATUT);
-- FATURA: e-belge durum taramaları (P19) — durum + tarih
-- öneri: CREATE NONCLUSTERED INDEX IX_FATURA_efatura ON FATURA (EFATURA_DURUM, TARIHI);
-- STOK: alt-küme/özel kod filtreleri (P3) — genelde aktif+özelkod
-- öneri: CREATE NONCLUSTERED INDEX IX_STOK_ozelkod ON STOK (AKTIF, OZEL_KODU3);
```
**Karar kuralı:** indeksi ancak (a) DMV yüksek impact veriyorsa **ve** (b) ilgili ekran ölçülü yavaşsa
**ve** (c) tablo yazma-yoğun değilse öner. Her indeks **INSERT/UPDATE'i yavaşlatır** — sayısını sınırlı tut.

---

## 3) Bakım planı (öneri — müşteri kurar)

| İş | Sıklık | Not |
|---|---|---|
| İndeks reorganize/rebuild | Haftalık (fragmentasyon >%10 reorg, >%30 rebuild) | `sys.dm_db_index_physical_stats` ile ölç |
| İstatistik güncelleme | Günlük/haftalık | Yavaş sorgunun 1 numaralı sebebi bayat istatistik |
| Yedek (full + log) | Full günlük, log saatlik (recovery=FULL ise) | **Göç/devir öncesi ekstra full** |
| DBCC CHECKDB | Haftalık | Bozulma erken yakala |
| Log dosyası kontrolü | — | Şişme → recovery model + log yedek stratejisi |
> **Wolvox-native:** çoğu müşteri SQL erişimi istemez — yedek/rotasyon/bulut ve reindex/onarım **Kontrol
> Paneli > Veri Tabanı İşlemleri** ekranından yapılır (+ ayrı "Akınsoft Yedekleme" programı). Önce bunu
> öğret; SQL Agent job'ı ancak DBA erişimi varsa öner. → [kurulum-playbook §6-C](kurulum-playbook.md).
> **Firebird:** düzenli **backup/restore (gbak)** = hem yedek hem **bakım** (garbage collection, indeks
> yeniden inşa). Şişen `.FDB` için gbak döngüsü. `SIMPLE` benzeri kavram yok; FB kendi MVCC'sini gbak'la toparlar.

---

## 4) Kilit / deadlock / blocking

**Anlık blocking:**
```sql
SELECT blocking_session_id, session_id, wait_type, wait_time, text
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
WHERE blocking_session_id <> 0;
```
**Yaygın Wolvox senaryoları:**
- Uzun **rapor** sorgusu yazan ekranı bloklar → raporda **salt-okunur/`READ COMMITTED SNAPSHOT`** veya
  `WITH (NOLOCK)` (kirli-okuma toleransıyla, yalnız raporda). Danışman sorgularında zaten [NOLOCK reçetesi](sorgu-recetesi.md).
- **Devir/dönem sonu** sırasında herkes girişteyse geniş kilit → devri **mesai dışı**, tek kullanıcı yap.
- Aynı fatura/stok kartına eşzamanlı düzenleme → uygulama kilidi; süreç kuralıyla çöz.
> **Firebird:** yazar-yazar çakışması `deadlock/update conflict` verir (MVCC). Uzun transaction'dan kaçın;
> raporları `READ ONLY READ COMMITTED` snapshot'ta çalıştır.

---

## 5) Göç senaryoları

### 5a) Wolvox 8 → 9 yükseltme
- **Şema büyük ölçüde uyumlu** (kolon adları aynı); fark ağırlıkla **UI/menü + e-Dönüşüm olgunluğu**
  ([menu-haritasi 8vs9](menu-haritasi.md)). Yine de: **test kopyasında** yükselt, kritik raporları 8 ve 9'da
  karşılaştır (satış/mizan/stok bakiye tutuyor mu).
- **Özel Tanımlar/özel alanlar** ve **native olmayan eklenti tabloları** ([schema-map §1](schema-map.md))
  yükseltmede en kırılgan noktalardır — envanterini çıkar, göç sonrası doğrula.
- Sıra: yedek → test kopyasında yükselt → doğrula → kullanıcı eğitimi (menü değişikliği) → canlı.

### 5b) MSSQL ↔ Firebird diyalekt farkı (sorgu taşıma)
Danışman sorgularını iki motora taşırken: → tam tablo [sorgu-recetesi §Firebird](sorgu-recetesi.md).
Özet: `TOP`→`FIRST/ROWS`, `ISNULL`→`COALESCE`, `GETDATE()`→`CURRENT_DATE`, `+`(string)→`||`,
`INFORMATION_SCHEMA`→`RDB$`, `WITH(NOLOCK)`→`READ ONLY` transaction.

### 5c) Yıl / firma taşıma (çok-DB)
- Her **yıl** ve bazen her **firma/modül** ayrı DB (`WOLVOX<sürüm>_<firma>_<yıl>_<modül>`) → [schema-map §2](schema-map.md).
- Yıl geçişi = **devir** (uygulama içi, [kurulum-playbook §3](kurulum-playbook.md)), elle DB kopyalama **değil**.
- Çapraz-yıl/çapraz-firma analiz: MSSQL'de `DB.dbo.TABLO` ile birleştir; **Firebird'de çapraz-DB yok** →
  uygulama katmanında birleştir.

---

## 6) Danışman teslim formatı (performans bulgusu)
Her performans bulgusunu [rapor-sablonlari Bulgu Kartı](rapor-sablonlari.md) ile ver:
**kanıt (DMV/ölçüm) → etki (hangi ekran, ne kadar yavaş) → öneri (inert DDL taslağı) → risk (güncellemede
düşebilir) → doğrulama (öncesi/sonrası ölçüm)**. DDL'i **müşteri**, yedek+test kopyasında uygular.
