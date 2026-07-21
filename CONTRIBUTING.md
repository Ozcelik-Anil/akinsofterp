# Katkı & Kendi Kurulumuna Uyarlama

Bu proje bağımsız, resmî olmayan bir topluluk çalışmasıdır. Katkılar (PR/issue) memnuniyetle karşılanır.

## Kendi Wolvox kurulumuna uyarlama (5 dakikalık hızlı başlangıç)

`reference/schema-map.md` ve `kod-sozlugu.md` **jenerik ürün bilgisidir** (gerçek işletme verisi
içermez). Seninki farklı olabilir (sürüm 8 vs 9, edisyon, kullanılan modüller). Kendi "doğrulanmış
gerçek"ini (kullanılan modüller, sayılar, kodlar) üret:

1. **Bağlan (salt-okunur):** `Server=...;Database=WOLVOX<..>_WOLVOX;Integrated Security=True`
2. **Envanteri çıkar** (hangi tablolar dolu):
   ```sql
   SELECT t.name, SUM(p.rows) FROM sys.tables t
   JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN(0,1)
   GROUP BY t.name HAVING SUM(p.rows)>0 ORDER BY SUM(p.rows) DESC;
   ```
3. **Kardeş modül DB'lerini de listele** (`SELECT name FROM sys.databases WHERE name LIKE 'WOLVOX%'`)
   — Genel Muhasebe `_GMUHASEBE`, İK `_IKAYNAK` ayrı DB'dedir.
4. **Kolonları ve kodları doğrula** (`INFORMATION_SCHEMA.COLUMNS`; `smallint` kod dağılımları).
5. **`reference/` dosyalarını kendi sayılarınla güncelle**; `🏠 THIS-INSTALL` bulgularını değiştir,
   `🌍` evrensel olanlara dokunma.
6. **Doğrula:** `reference/dogrulama-testleri.md`'deki 22 testi bir Claude'a uygula.

> ⚠️ **Asla** gerçek veri/yedek (`.mdf`,`.bak`,`.fdb`, müşteri `.xlsx`) commit'leme — `.gitignore`
> bunları engeller ama sen de dikkat et (KVKK). PR'larda tüm örnekler **maskeli/anonim** olmalı.

## Commit öncesi tutarlılık kontrolü (ZORUNLU)

Repo büyüdükçe en büyük risk **kendi kendini çürütmesidir** (bir gerçeği düzeltip başka dosyada eskisini
bırakmak, sapan kolon adı, kırık link, sürüm uyumsuzluğu, gizlilik sızıntısı). Her düzenlemeden sonra
**mekanik denetçiyi çalıştır:**

```powershell
.\tools\consistency-check.ps1     # exit 0 = geçti, 1 = tutarsızlık var
```

Yakaladıkları (hepsi gerçekte yaşandı): gizlilik/şirket-verisi sızıntısı · **düzeltilmiş bir menü yolunun
geri sızması** · kırık iç link · `skill.md` sürümü ≠ `CHANGELOG` en üst · schema-map dışı **uydurma/sapan
kolon adayı** (uyarı). **Exit 1 ise commit etme.**

Denetçinin göremediği, **elle** doğrulanacaklar:
- **Tek gerçek kaynağı:** kolon adları `schema-map.md`'de tanımlanır; başka dosyada farklı yazım = hata
  (ör. `BLCRKODU` doğru, `BLCARIKODU` yanlış; `TICARI_UNVANI` doğru, `CARI_UNVANI` yanlış).
- **Bir gerçeği düzelttiğinde** repoyu `grep`'le, TÜM kopyalarını güncelle (denetçiye bilinen-yanlış
  string olarak ekle).
- **Sayaç iddiaları** (ör. "22 test", "N referans paketi") gerçek sayıyla uyuşmalı.

## PR kuralları
- Şema/kod iddiası ekliyorsan **nasıl doğruladığını** yaz (`✅` canlı, `📹` resmî video, `📖` standart).
- `skill.md` davranışını değiştiren PR, `dogrulama-testleri.md`'deki 22 senaryonun hâlâ geçtiğini belirtmeli.
- Sürüm: davranış/şema değişikliği → `CHANGELOG.md` + SemVer bump. **`tools\consistency-check.ps1` exit 0 olmalı.**
- Menü yolu ekliyorsan (`menu-haritasi.md`) güven etiketi koy (`≈` genel / `📹` video / `✓` saha-teyitli + 8/9).

## Issue açarken
Sürüm (8/9), edisyon, motor (MSSQL/Firebird) ve — mümkünse — **maskeli** bir örnek belirt.
