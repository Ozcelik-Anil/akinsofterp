# tools/ — Çalıştırılabilir salt-okunur yardımcılar

> Bu klasördeki betikler skill'in **Mode A** felsefesini paketler: kullanıcı **kendi** kurulumunda
> çalıştırır, betik **yalnız okur** ve bir **önizleme + inert taslak** üretir. **Hiçbir betiğin
> yazma yetkisi yoktur** — canlı veriye asla `UPDATE/DELETE` uygulamaz.
>
> **Jeneriktir:** hiçbir sunucu/instance/DB adı, sayı veya işletme verisi gömülü değildir — hepsi
> parametredir. Bir kuruluma özel hiçbir şey içermez.

## Güvenlik sözleşmesi (her betik uyar)
- **Salt-okunur:** yalnız `SELECT`. `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` ile kilitsiz okur.
- **Yazma yok:** reprice betiği bile UPDATE'i **çalıştırmaz** — inert `BEGIN TRAN … ROLLBACK` `.sql`
  **taslağı** dosyaya yazar; kullanıcı inceleyip bilinçli olarak `COMMIT`'e çevirir.
- **PII yok:** çıktılar agregat/teknik; kişisel veri seçilmez.
- **Şema-first:** kolon adları doğrulanmış Wolvox şemasına göre; farklı sürüm/edisyonda çalışmadan
  önce `-WhatIfSchema` ile kolon varlığını teyit et (veya SQL'i elle gözden geçir).
- **En az yetki:** `db_datareader` login ile çalıştır; mesai dışını / yedek kopyayı tercih et.

## Betikler
| Dosya | Ne yapar | Yazar mı? |
|---|---|---|
| `reprice-preview.ps1` | Seçili (Özel Kod) ürünlerde son-alıştan hedef satış fiyatını **asimetrik** hesaplar; CSV önizleme + inert `.sql` taslağı üretir | **Hayır** — sadece taslak |
| `utilization-scorecard.ps1` | 5 boyutlu Verimli Kullanım Skoru'nu (0–100) salt-okunur metriklerle üretir | Hayır |
| `consistency-check.ps1` | **Repo tutarlılık & gizlilik denetçisi** — self-contradiction/drift/sızıntı riskini mekanik yakalar (gizlilik sızıntısı · bayat-yanlış string · kırık iç link · sürüm uyumsuzluğu · uydurma-kolon adayı). DB'ye **bağlanmaz**; repo dosyalarını okur, exit 0/1 verir. Her düzenleme sonrası + commit öncesi çalıştır. | Hayır (repo salt-okunur) |

> **Gizlilik desenleri iki katmandır:** jenerik yerleşikler betiğin içindedir; **kuruluma özel
> desenler** (instance adı, gerçek çarpan, iç proje etiketi…) `tools/private-patterns.local.txt`
> dosyasına yazılır — bu dosya **gitignored'dır, asla yayınlanmaz** (betiğin kendisi de taranır ki
> gizli değer betiğe geri sızamasın). Şablon: [`private-patterns.sample.txt`](private-patterns.sample.txt).

## Gereksinim
- Windows PowerShell 5.1+ (veya PowerShell 7).
- MS SQL Server hedefi. (Firebird için SQL'i `sorgu-recetesi.md §Firebird` diyalektine çevir; bu
  betikler `System.Data.SqlClient` kullanır, MSSQL'e özeldir.)
- `db_datareader` yetkili bir login (Windows auth veya SQL auth).

## Örnek kullanım
```powershell
# Reprice önizleme (yalnız okur, taslak üretir) — çarpanı ve işaret slotunu SEN verirsin
.\reprice-preview.ps1 -Server "SUNUCU\INSTANCE" -Database "WOLVOX8_001_2023_WOLVOX" `
    -Carpan 1.50 -IsaretSlot OZEL_KODU3 -Isaret "REPRICE" -OutDir ".\cikti"

# Verimli Kullanım Skoru
.\utilization-scorecard.ps1 -Server "SUNUCU\INSTANCE" -Database "WOLVOX8_001_2023_WOLVOX"
```
> Parametrelerdeki `SUNUCU\INSTANCE` ve DB adı **örnektir** — kendi kurulumunun değerlerini gir.
