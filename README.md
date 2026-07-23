# akinsofterp — Akınsoft Wolvox 8/9 ERP Expert / Uzmanı (Claude Skill)

**English** | [Türkçe](#türkçe)

---

## English

This repo ships a single-file system instruction (`SKILL.md`) that turns Claude into an **elite, read-only, KVKK/GDPR-safe, schema-verified Akınsoft Wolvox 8/9 ERP consultant**. Load it into any Claude surface and you get an expert that performs read-only, schema-validated analysis on MS SQL Server or Firebird, and gives you both the SQL query and the equivalent Akınsoft UI path.

> Turkish note: the skill's own domain content (SQL, ERP terminology, Turkish tax/compliance rules) is intentionally written in Turkish, since that matches the Akınsoft Wolvox product itself. This README (repo documentation) is bilingual.

### ✨ What it does
- **Native-first reflex.** Before proposing any SQL write / fix / automation, checks whether Wolvox already has a built-in feature for it (`reference/native-yetenek-indeksi.md` — 14 modules, need → built-in feature → menu path → confidence → trap), now including e-Commerce/marketplace, quick-sale/POS, and purchasing/finance/documents.
- **Structural health scan** — broken currency records, cards without a group code, duplicate barcodes, negative stock.
- **Commercial analysis** — customers/vendors inactive 90+ days, dead/slow-moving stock, stock turnover rate, dynamic price matrix.
- **Turkish compliance** — e-Transformation (e-Invoice/e-Archive/e-Waybill/e-Ledger) diagnostics, VAT/excise/withholding checks, accounting integration & trial balance.
- **Unused features** — campaign engine, min/max stock triggers, automatic email/task scheduler.
- **Quick wins** — barcode automation, terminal-based default warehouse, 5-minute setting tweaks.

### 🔒 Safety principles (baked into the file)
- **Read-only (SELECT-only).** Never runs `UPDATE/DELETE/DROP` in production; fixes are offered as an **inert migration draft** (`BEGIN TRAN … ROLLBACK;`) or a **UI walkthrough**.
- **Read-only login bootstrap (Mode B).** Before any connected-mode work, walks through creating a dedicated `wolvox_ro` login with only `db_datareader` and proves it with a zero-row `UPDATE` that must fail — read-only by construction, not by discipline.
- **KVKK/GDPR.** Never pulls personal data (name, phone, email, national ID, tax ID, address); masks it in-query when unavoidable; focuses on aggregates.
- **Live-ERP safety.** Uses `READ UNCOMMITTED / NOLOCK` to avoid locking, a `db_datareader` login, bans `SELECT *`, and prefers running against a backup copy.
- **Schema-first, verify-first.** Never invents column names; validates against `INFORMATION_SCHEMA` / `RDB$`.
- **Ethical/legal limits.** Refuses license cracking, fake e-invoices, record tampering/tax evasion, and bulk PII extraction.

### 🚀 Quick install

Pick the snippet for your shell — each downloads the repo straight into your Claude Code skills folder. No manual file renaming needed; `SKILL.md` and `reference/` are already laid out correctly in the repo.

**macOS / Linux / WSL (bash, git):**
```bash
git clone https://github.com/smurfspec/akinsofterp.git ~/.claude/skills/akinsofterp
```

**Windows (PowerShell, git):**
```powershell
git clone https://github.com/smurfspec/akinsofterp.git "$env:USERPROFILE\.claude\skills\akinsofterp"
```

**No git available (bash, tarball download):**
```bash
mkdir -p ~/.claude/skills && \
curl -L https://github.com/smurfspec/akinsofterp/archive/refs/heads/master.tar.gz \
  | tar -xz -C ~/.claude/skills/ && \
mv ~/.claude/skills/akinsofterp-master ~/.claude/skills/akinsofterp
```

**No git available (PowerShell, zip download):**
```powershell
$dest = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri "https://github.com/smurfspec/akinsofterp/archive/refs/heads/master.zip" -OutFile "$env:TEMP\akinsofterp.zip"
Expand-Archive -Path "$env:TEMP\akinsofterp.zip" -DestinationPath $dest -Force
Rename-Item "$dest\akinsofterp-master" "akinsofterp"
```

**Update an existing install (git):**
```bash
cd ~/.claude/skills/akinsofterp && git pull
```
```powershell
cd "$env:USERPROFILE\.claude\skills\akinsofterp"; git pull
```

That's it for Claude Code — Claude picks the skill up automatically via `SKILL.md`'s frontmatter (`name` + `description`). For other surfaces, see below.

> ⚠️ **Reference packs aren't auto-read on every surface.** The files under `reference/` are only pulled in on demand by a **Claude Code** install. On other surfaces you need to supply them yourself (see below).

#### 1) Claude Code (as a skill — full power, recommended) 🟢
Use one of the quick-install snippets above. If you'd rather do it by hand, copy into `.claude/skills/akinsofterp/`:
- `SKILL.md` (the frontmatter's `name`+`description` is what triggers it),
- the **`reference/` folder as-is** next to it (Claude reads it on demand).

If a SQL/MCP connection is available, **Mode B (connected)** lets Claude run the read-only queries itself. With all reference packs in place (schema, code glossary, query recipes, troubleshooting) you get the highest-capability setup.

#### 2) Claude Projects 🟡
1. claude.ai → **Projects** → new project.
2. Paste the contents of `SKILL.md` into **Project instructions** (you can strip the frontmatter).
3. **Also upload the reference packs:** add each `reference/*.md` file to the project's **knowledge** area as a separate document (without them, Claude only has the summary in `SKILL.md` — still useful, but missing schema/code detail).
4. State the engine, version, and fiscal year in your first message.

#### 3) Custom Instructions 🟠 (limited)
There's a character limit and **you can't attach files.** Paste `SKILL.md` (without the frontmatter); if it doesn't fit, keep at least these core sections: *Pre-Flight Checklist · Universal-vs-This-Install · Read-Only Contract · Schema-First · CONFIRMED CORE · Output Standards*. For schema/code detail, paste the relevant `reference/*.md` content into the chat as needed. (Prefer option 1 or 2 for full power.)

### 🧭 Two operating modes
- **Mode A — Advisor/Offline:** No DB connection. Claude writes the query; you run it and paste back the (masked/summarized) result.
- **Mode B — Connected:** Claude Code + a shell/SQL client/MCP runs the read-only queries itself, after the read-only login bootstrap above.

### 🗂️ Repo contents
| File | Description |
|---|---|
| `SKILL.md` | Main system instruction (role, safety, read-only login bootstrap, native-first gate, pre-flight checklist, schema reference, 5 strategic pillars, Turkish compliance, cost & turnover, Firebird appendix, glossary). |
| `reference/native-yetenek-indeksi.md` | **Native Capability Index** — need → built-in Wolvox feature → menu path → confidence (`≈`/`📹`/`✓`) → trap, across 14 modules (pricing/reprice, stock, invoicing, customer/vendor, e-Transformation, accounting, POS/retail, warehouse, manufacturing, control panel, service/HR, e-commerce/marketplace, quick-sale/POS, purchasing/finance/documents). The lookup table behind the "native-first" reflex. |
| `reference/danismanlik-metodolojisi.md` | **Consulting methodology** — strings every pack into one engagement flow (Discovery→Assessment→Prioritization→Implementation→Delivery→Follow-up); each step lists which pack to use + the non-negotiable discipline (read-only/backup/PII/CPA sign-off). Starting point for broad "assess everything" requests. |
| `reference/schema-map.md` | **Schema map** — generic Wolvox 8 table roles, key columns, naming codes, relationship map, and a KVKK/PII data register. Contains no real business data; scan your own install for anything install-specific (modules in use, counts, codes). |
| `reference/sorgu-recetesi.md` | **Query recipe book** — read-only diagnostic queries (data health, dead stock, customer balance, pending e-invoices). |
| `reference/kod-sozlugu.md` | **Code glossary** — decodes `smallint` enum fields (`TUTAR_TURU`, `EVRAK_TURU`, `ISLEM_TURU`, `EFATURA_DURUM`, `SIPARIS_DURUMU`…). |
| `reference/vaka-catalogu-100.md` | **100 solved complex cases** — realistic consultant questions across 14 module categories; each one flags the "trap" a naive answer would miss, plus table/column, UI path, and the resolved assumption. Reuse the approach when a similar question comes up. |
| `reference/vaka-bankasi.md` | **Extended case bank** — 900 dense questions (#101–#1000, 14 domains) + a **Solution Pattern Library (P1–P30)**. Together with the 100 flagship cases: **1000 cases total**. Map a new question to its pattern and solve it. (Generic; no real data.) |
| `reference/hesaplama-ornekleri.md` | **Calculation verification** — worked examples + edge cases for the costliest silent-error classes: reprice `CEILING(×multiplier)−1` rounding+asymmetry, VAT-exclusive↔inclusive (wrong-method traps), FX→TRY (100%-`PARA_ORANI`+stale rate), inflation real↔nominal profit. Cross-check before producing a number. |
| `reference/cozum-desenleri.md` | **Solution Patterns (P1–P30) — canonical SQL** — for each pattern: *when to use it · ready-made mini-SQL skeleton · gotcha* + Firebird differences. Once you pick a P# from the case bank, start here instead of building the query from scratch. |
| `reference/verimlilik-skoru.md` | **Utilization Score** — a read-only rubric that reduces "how efficiently is this business using Wolvox" to a single 0–100 score (5 weighted dimensions + SQL metrics + grade band + actions). Use for "am I using this efficiently / give me a system X-ray" questions. |
| `tools/` | **Executable, read-only scripts** — `reprice-preview.ps1` (asymmetric repricing preview + inert `.sql` draft), `utilization-scorecard.ps1` (the B1+B2 utilization score), and `consistency-check.ps1` (repo consistency/privacy auditor — catches self-contradiction/drift/leaks, never connects to a DB). Parameterized, generic; no write access. |
| `reference/sorun-giderme.md` | **Troubleshooting playbook** — symptom → cause → diagnosis → fix (connection, stock, customer/vendor, e-Transformation, fiscal period, performance). |
| `reference/menu-haritasi.md` | **UI menu map** — a catalog of operation → Akınsoft menu path. Confidence tiers: `≈` general · **`📹` distilled from an official training video** (Stock/Customer-Vendor/e-Invoice Settings/Year-end rollover) · `✓` field-verified. |
| `reference/turkiye-uyumluluk.md` | **Turkish compliance hard facts (sourced)** — VAT rates, withholding code/rate matrix (601–627), e-Invoice scenarios, e-Invoice↔e-Archive decision logic, GİB status codes (1000–1300); **+ inflation accounting, e-Ledger/Berat, KVKK anonymization, withholding/exemption/e-Export/e-Müstahsil invoicing flows** (`📹` official video). Time-sensitive → confirm the current rate + get CPA sign-off. |
| `reference/ozel-ayarlar.md` | **Custom Settings reference** — the settings catalog that drives Wolvox behavior (`Custom Settings > <Module>`): per-module *setting → what it does → consultant trap*. Sourced from `📹` the official Custom Settings video series, now covering 17 tabs including Bank/CRM/Service/MRP2/Virtual PBX/Caller ID/Medical settings. Includes the built-in **reprice trigger** (`Invoice Settings > Purchase Invoice`). The answer to "why does the program do X / how do I make it do X". |
| `reference/kurulum-playbook.md` | **Setup/implementation playbooks** — e-Invoice/e-Archive, automatic repricing, year-end close+rollover, minimum stock/customer-vendor records. `📹` video-sourced steps + backup/CPA/read-only discipline. |
| `reference/rapor-sablonlari.md` | **Consultant deliverable templates** — executive health report, top-20 critical findings, 30-60-90 action plan, finding card. `{…}` placeholders get filled from a live scan; no numbers ship in the repo. |
| `reference/modul-derinlik.md` | **Deep-dive on niche modules** — Manufacturing/BOM, Batch-Lot-Serial/expiry, Technical Service (`📹`), marketplace, Payroll/HR (`📹`). Discover-before-assume (never invents a column); per-module questions + traps + reporting. |
| `reference/perakende-entegrasyon.md` | **Retail integrations** (`📹`) — POS/new-generation cash registers (Pavo N86, Ingenico/PAX: activation, device pairing, **payment matching**) + e-Commerce/marketplace (panel VAT/labeling, Wolvox↔e-commerce installments/online payment + virtual POS, N11/shipping). Overselling/commission/POS-GİB reconciliation traps. |
| `reference/dba-performans.md` | **DBA/performance & migration** — DMV diagnostics, index recommendations (inert DDL), maintenance plan, deadlocks, 8→9 & MSSQL↔Firebird migration. Read-only diagnosis; the client applies any writes. |
| `reference/altin-cevap-eval.md` | **Content-accuracy golden answer set (G1–G15)** — question → expected expert key points → the wrong answer to avoid. The content counterpart to the behavioral tests (`dogrulama-testleri.md`). |
| `reference/dogrulama-testleri.md` | **Verification tests** — **22 behavioral tests** that check the skill behaves correctly on any Claude surface (core schema/safety + reprice + score + patterns + Mode A + **privacy/KVKK regression** + settings/setup/compliance/retail/methodology). |
| `CHANGELOG.md` | Version history (SemVer). |
| `CONTRIBUTING.md` | Contribution rules + a "adapt this to your own install" quick start. |
| `.gitignore` | Keeps data/backup/secret files out of the repo (KVKK). |
| `README.md` | This file. |
| `LICENSE` | MIT. |

> **Multi-file skill:** `SKILL.md` is the lean "brain/behavior" layer; the packs under `reference/` are verified information read on demand. In a Claude Code skill install, keep the files next to `SKILL.md` with the `reference/` folder alongside it — Claude reads them when it needs to.

### ⚠️ Disclaimer
This instruction set is a **consulting/analysis** tool; it does not replace a licensed accountant or Akınsoft's official support. Always confirm tax/regulatory decisions with your CPA. Run any migration draft against a **backup + test copy** first. Akınsoft and Wolvox are trademarks of AKINSOFT; this project is an independent, unofficial community effort.

### 📄 License
MIT — see `LICENSE`. Contributions welcome (PRs/issues).

---

[English](#english) | **Türkçe**

## Türkçe

Bu depo, **Claude'u dünya çapında bir Akınsoft Wolvox 8/9 ERP danışmanına** dönüştüren tek dosyalık bir sistem talimatı (`SKILL.md`) içerir. Dosyayı herhangi bir Claude yüzeyine yükleyince; MS SQL / Firebird tarafında **salt-okunur, KVKK uyumlu, şema-doğrulamalı** analizler yapan, hem SQL hem Akınsoft arayüz yolları veren bir uzman elde edersiniz.

> Türkçe not: skill'in kendi alan içeriği (SQL, ERP terminolojisi, Türk vergi/uyumluluk kuralları) kasıtlı olarak Türkçe yazılmıştır, çünkü Akınsoft Wolvox ürününün kendisi de öyledir. Bu README (repo dokümantasyonu) iki dillidir.

### ✨ Neler yapar?
- **Native-first refleks.** Herhangi bir SQL yazma/düzeltme/otomasyon önerisinden önce Wolvox'ta bunun için zaten yerleşik bir özellik olup olmadığını kontrol eder (`reference/native-yetenek-indeksi.md` — 14 modül, iş-ihtiyacı → yerleşik özellik → menü yolu → güven → tuzak); artık e-ticaret/pazaryeri, hızlı satış/POS ve satınalma/finans/doküman'ı da kapsıyor.
- **Yapısal sağlık taraması** — bozuk döviz/para birimi kayıtları, grup kodsuz kartlar, mükerrer barkod, negatif stok.
- **Ticari analiz** — 90+ gün hareketsiz cariler, ölü/yavaş stok, stok devir hızı, dinamik fiyat matrisi.
- **Türkiye uyumluluğu** — e-Dönüşüm (e-Fatura/e-Arşiv/e-İrsaliye/e-Defter) tanıları, KDV/ÖTV/Tevkifat kontrolleri, muhasebe entegrasyonu & mizan.
- **Kullanılmayan özellikler** — kampanya motoru, min/max stok tetikleyicileri, otomatik e-posta/görev planlayıcı.
- **Hızlı kazanımlar** — barkod otomasyonu, terminal bazlı varsayılan depo, 5 dakikalık ayar dokunuşları.

### 🔒 Güvenlik ilkeleri (dosyaya gömülü)
- **Salt-okunur (SELECT-only).** Üretimde asla `UPDATE/DELETE/DROP` çalıştırmaz; düzeltmeleri **inert migration taslağı** (`BEGIN TRAN … ROLLBACK;`) veya **arayüz yolu** olarak sunar.
- **Salt-okunur login bootstrap (Mode B).** Bağlı moddaki her işten önce ayrı bir `wolvox_ro` login'in yalnız `db_datareader` yetkisiyle kurulmasından geçer ve bunu sıfır-satır bir `UPDATE` denemesiyle kanıtlar (başarısız olması beklenir) — salt-okunuşluk disipline değil **yapıya** dayanır.
- **KVKK/GDPR.** Kişisel veriyi (ad, telefon, e-posta, TCKN, VKN, adres) çekmez; kaçınılmazsa sorgu içinde maskeler; agregat veriye odaklanır.
- **Canlı ERP güvenliği.** Kilitlenmeyi önlemek için `READ UNCOMMITTED / NOLOCK`, `db_datareader` login, `SELECT *` yasağı, tercihen yedek kopya üzerinde çalışma.
- **Şema-önce-doğrula.** Kolon uydurmaz; `INFORMATION_SCHEMA` / `RDB$` ile doğrular.
- **Etik/yasal sınırlar.** Lisans kırma, sahte e-fatura, kayıt tahrifi/vergi kaçırma, toplu PII çekimi → reddeder.

### 🚀 Kurulum

Kabuğunuza uygun parçayı seçin — her biri repoyu doğrudan Claude Code skills klasörünüze indirir. Elle dosya yeniden adlandırmaya gerek yok; `SKILL.md` ve `reference/` repoda zaten doğru yerleşimde.

**macOS / Linux / WSL (bash, git):**
```bash
git clone https://github.com/smurfspec/akinsofterp.git ~/.claude/skills/akinsofterp
```

**Windows (PowerShell, git):**
```powershell
git clone https://github.com/smurfspec/akinsofterp.git "$env:USERPROFILE\.claude\skills\akinsofterp"
```

**Git yoksa (bash, tarball indirme):**
```bash
mkdir -p ~/.claude/skills && \
curl -L https://github.com/smurfspec/akinsofterp/archive/refs/heads/master.tar.gz \
  | tar -xz -C ~/.claude/skills/ && \
mv ~/.claude/skills/akinsofterp-master ~/.claude/skills/akinsofterp
```

**Git yoksa (PowerShell, zip indirme):**
```powershell
$dest = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri "https://github.com/smurfspec/akinsofterp/archive/refs/heads/master.zip" -OutFile "$env:TEMP\akinsofterp.zip"
Expand-Archive -Path "$env:TEMP\akinsofterp.zip" -DestinationPath $dest -Force
Rename-Item "$dest\akinsofterp-master" "akinsofterp"
```

**Mevcut kurulumu güncelleme (git):**
```bash
cd ~/.claude/skills/akinsofterp && git pull
```
```powershell
cd "$env:USERPROFILE\.claude\skills\akinsofterp"; git pull
```

Claude Code için bu kadar — Claude, skill'i `SKILL.md`'nin frontmatter'ı (`name` + `description`) üzerinden otomatik tanır. Diğer yüzeyler için aşağıya bakın.

> ⚠️ **Referans paketleri her yüzeyde otomatik okunmaz.** `reference/` dosyaları yalnızca **Claude Code** kurulumunda ihtiyaç anında okunur. Diğer yüzeylerde onları da elle vermeniz gerekir (aşağıda).

#### 1) Claude Code (skill olarak — tam güç, önerilen) 🟢
Yukarıdaki hızlı kurulum parçalarından birini kullanın. Elle yapmak isterseniz `.claude/skills/akinsofterp/` klasörüne kopyalayın:
- `SKILL.md` (frontmatter'daki `name`+`description` tetikler),
- **`reference/` klasörünü aynen** yanına (Claude gerektiğinde okur).

SQL/MCP bağlantısı varsa **Mode B (bağlı)** olarak salt-okunur sorguları kendisi çalıştırır. Tüm referans paketleri (şema, kod sözlüğü, reçete, sorun giderme) devrede → en yüksek yetenek.

#### 2) Claude Projects 🟡
1. claude.ai → **Projects** → yeni proje.
2. `SKILL.md` içeriğini **Project instructions**'a yapıştırın (frontmatter'ı silebilirsiniz).
3. **Referans paketlerini de yükleyin:** `reference/*.md` dosyalarını projenin **knowledge** alanına ayrı doküman olarak ekleyin (yoksa Claude yalnızca `SKILL.md`'deki özet bilgiyle çalışır — yine iyidir ama şema/kod detayları eksik kalır).
4. Motor, sürüm ve çalışma yılını ilk mesajda belirtin.

#### 3) Custom Instructions 🟠 (kısıtlı)
Karakter limiti vardır ve **dosya ekleyemezsiniz.** `SKILL.md`'yi (frontmatter'sız) yapıştırın; sığmazsa **şu çekirdek bölümleri** koruyun: *Pre-Flight Checklist · Universal-vs-This-Install · Read-Only Contract · Schema-First · CONFIRMED CORE · Output Standards*. Şema/kod detayları için kullanıcı gerektiğinde `reference/*.md` içeriğini sohbete yapıştırabilir. (Tam güç için 1 veya 2'yi tercih edin.)

### 🧭 İki çalışma modu
- **Mode A — Danışman/Offline:** DB bağlantısı yok. Claude sorguyu üretir, siz çalıştırıp sonucu (maskeli/özet) yapıştırırsınız.
- **Mode B — Bağlı:** Claude Code + shell/SQL client/MCP, yukarıdaki salt-okunur login bootstrap'ından sonra sorguları kendisi çalıştırır.

### 🗂️ Depo içeriği
| Dosya | Açıklama |
|---|---|
| `SKILL.md` | Ana sistem talimatı (rol, güvenlik, salt-okunur login bootstrap, native-first kapısı, ön-uçuş checklist'i, şema referansı, 5 stratejik sütun, TR uyumluluk, maliyet & devir, Firebird eki, sözlük). |
| `reference/native-yetenek-indeksi.md` | **Native Yetenek İndeksi** — iş-ihtiyacı → yerleşik Wolvox özelliği → menü yolu → güven (`≈`/`📹`/`✓`) → tuzak, 14 modül boyunca (fiyatlandırma/reprice, stok, fatura, cari, e-Dönüşüm, muhasebe, POS/perakende, depo, üretim, kontrol paneli, servis/İK, e-ticaret/pazaryeri, hızlı satış/POS, satınalma/finans/doküman). "Native-first" refleksinin arkasındaki arama tablosu. |
| `reference/danismanlik-metodolojisi.md` | **Danışmanlık metodolojisi** — tüm paketleri bir angajman akışına dizer (Keşif→Değerlendirme→Önceliklendirme→Uygulama→Teslimat→Takip); her adımda hangi paket + değişmez disiplin (salt-okunur/yedek/PII/SMMM). Geniş "baştan sona değerlendir" istekleri için başlangıç noktası. |
| `reference/schema-map.md` | **Şema haritası** — jenerik Wolvox 8 tablo rolleri, anahtar kolonlar, isimlendirme kodları, ilişki haritası ve KVKK/PII kayıt defteri. Gerçek işletme verisi içermez; kuruluma özel her şeyi (kullanılan modüller, sayılar, kodlar) kendi kurulumunuzda tarayın. |
| `reference/sorgu-recetesi.md` | **Sorgu reçete kitabı** — salt-okunur tanı sorguları (veri sağlığı, ölü stok, cari bakiye, askıda e-fatura). |
| `reference/kod-sozlugu.md` | **Kod sözlüğü** — `smallint` enum alanlarının çözümü (`TUTAR_TURU`, `EVRAK_TURU`, `ISLEM_TURU`, `EFATURA_DURUM`, `SIPARIS_DURUMU`…). |
| `reference/vaka-catalogu-100.md` | **100 çözülmüş komplike vaka** — 14 modül-kategorisinde gerçekçi danışman soruları; her biri naif cevabın kaçırdığı "tuzak" + tablo/kolon + UI yolu + varsayımla çözülmüş. Benzer soru geldiğinde yaklaşımı yeniden kullan. |
| `reference/vaka-bankasi.md` | **Genişletilmiş vaka bankası** — 900 yoğun soru (#101–#1000, 14 domain) + **Çözüm Deseni Kütüphanesi (P1–P30)**. 100 bayrak vaka ile birlikte **1000 vaka**. Yeni bir soruyu ilgili desene bağlayıp çöz. (Jenerik; gerçek veri yok.) |
| `reference/hesaplama-ornekleri.md` | **Hesaplama doğrulama** — en pahalı sessiz-hata sınıfı için çalışılmış örnekler + kenar durumlar: reprice `CEILING(×çarpan)−1` yuvarlama+asimetri, KDV hariç↔dahil (yanlış-yöntem tuzakları), döviz→TL (yüzde-100 `PARA_ORANI`+bayat kur), enflasyon reel↔nominal kâr. Sayı üretmeden önce çapraz-kontrol. |
| `reference/cozum-desenleri.md` | **Çözüm Desenleri (P1–P30) — kanonik SQL** — her desen için *ne zaman · hazır mini-SQL iskeleti · tuzak (gotcha)* + Firebird farkları. Vaka bankasından bir P# seçince sorguyu sıfırdan kurma, buradan al. |
| `reference/verimlilik-skoru.md` | **Verimli Kullanım Skoru** — işletmenin Wolvox'u ne kadar verimli kullandığını tek 0–100 skoruna indiren salt-okunur rubrik (5 ağırlıklı boyut + SQL metrikleri + not bandı + aksiyonlar). "Verimli kullanıyor muyum / sistem röntgeni" sorularında kullan. |
| `tools/` | **Çalıştırılabilir salt-okunur betikler** — `reprice-preview.ps1` (asimetrik yeniden fiyatlama önizleme + inert `.sql` taslağı), `utilization-scorecard.ps1` (B1+B2 verimlilik skoru) ve `consistency-check.ps1` (repo tutarlılık/gizlilik denetçisi — self-contradiction/drift/sızıntı yakalar, DB'ye bağlanmaz). Parametreli, jenerik; yazma yetkisi yok. |
| `reference/sorun-giderme.md` | **Sorun giderme playbook'u** — semptom → neden → tanı → çözüm (bağlantı, stok, cari, e-Dönüşüm, dönem, performans). |
| `reference/menu-haritasi.md` | **UI menü haritası** — işlem → Akınsoft menü yolu katalogu. Güven kademesi: `≈` genel · **`📹` resmî eğitim videosundan damıtılmış** (Stok/Cari/e-Fatura Ayarları/Devir) · `✓` saha-teyitli. |
| `reference/turkiye-uyumluluk.md` | **Türkiye uyumluluk sert-gerçekleri (kaynaklı)** — KDV oranları, tevkifat kod/oran matrisi (601–627), e-Fatura senaryoları, e-Fatura↔e-Arşiv kararı, GİB durum kodları (1000–1300); **+ Enflasyon Muhasebesi, e-Defter/Berat, KVKK Anonimleştirme, tevkifat/istisna/e-İhracat/e-Müstahsil fatura kesme akışları** (`📹` resmî video). Zamana-duyarlı → güncel oran + SMMM teyidi. |
| `reference/ozel-ayarlar.md` | **Özel Ayarlar referansı** — Wolvox davranışını yöneten ayar kataloğu (`Özel Ayarlar > <Modül>`): modül-bazlı *ayar → ne yapar → danışman tuzağı*. `📹` resmî Özel Ayarlar video serisinden, artık Banka/CRM/Servis/MRP2/Sanal Santral/Caller ID/Tıp ayarları dahil 17 sekmeyi kapsıyor. Yerleşik **reprice tetiği** (`Fatura Ayarları > Alış Faturası`) burada. "Program neden X / nasıl yaptırırım" sorularının cevabı. |
| `reference/kurulum-playbook.md` | **Kurulum/implementasyon playbook'ları** — e-Fatura/e-Arşiv, otomatik reprice, yıl-sonu kapanış+devir, stok/cari asgari kayıt. `📹` video-kaynaklı adımlar + yedek/SMMM/salt-okunur disiplini. |
| `reference/rapor-sablonlari.md` | **Danışman teslimat şablonları** — yönetici sağlık raporu, en kritik 20 bulgu, 30-60-90 aksiyon planı, bulgu kartı. `{…}` canlı taramadan doldurulur; sayı repoya girmez. |
| `reference/modul-derinlik.md` | **İnce modül derinliği** — Üretim/Reçete, Parti-Lot-Seri/SKT, Teknik Servis (`📹`), pazaryeri, Bordro/İK (`📹`). Keşif-önce (kolon uydurmaz); modül başına soru + tuzak + rapor. |
| `reference/perakende-entegrasyon.md` | **Perakende entegrasyonları** (`📹`) — ÖKC/yeni nesil yazar kasa (Pavo N86, Ingenico/PAX: aktivasyon, cihaz eşleştirme, **ödeme eşleştirme**) + e-Ticaret/pazaryeri (panel KDV/etiket, Wolvox↔e-ticaret taksit/online tahsilat + sanal POS, N11/kargo). Overselling/komisyon/ÖKC-GİB mutabakat tuzakları. |
| `reference/dba-performans.md` | **DBA/performans & göç** — DMV teşhisleri, indeks önerileri (inert DDL), bakım planı, deadlock, 8→9 & MSSQL↔Firebird göç. Salt-okunur teşhis; yazma müşteride. |
| `reference/altin-cevap-eval.md` | **İçerik-doğruluğu altın cevap seti (G1–G15)** — soru → beklenen uzman anahtar-noktaları → kaçınılacak yanlış. Davranış testlerinin (dogrulama-testleri) içerik tamamlayıcısı. |
| `reference/dogrulama-testleri.md` | **Doğrulama testleri** — skill'in herhangi bir Claude'da doğru davrandığını ölçen **22 davranış testi** (çekirdek şema/güvenlik + reprice + skor + desen + Mode A + **gizlilik/KVKK regresyonu** + ayar/kurulum/uyumluluk/perakende/metodoloji). |
| `CHANGELOG.md` | Sürüm geçmişi (SemVer). |
| `CONTRIBUTING.md` | Katkı kuralları + "kendi kurulumuna uyarla" hızlı başlangıç. |
| `.gitignore` | Veri/yedek/gizli dosyaları repo dışında tutar (KVKK). |
| `README.md` | Bu dosya. |
| `LICENSE` | MIT. |

> **Çok-dosyalı skill:** `SKILL.md` yağsız "beyin/davranış" katmanıdır; `reference/` altındaki paketler ihtiyaç anında okunacak doğrulanmış bilgidir. Claude Code skill'inde dosyaları `SKILL.md`'nin yanına `reference/` klasörüyle koyun — Claude gerektiğinde okur.

### ⚠️ Sorumluluk reddi
Bu talimat bir **danışmanlık/analiz** aracıdır; resmî mali müşavirlik veya Akınsoft resmî desteği yerine geçmez. Vergi/mevzuat kararlarını daima mali müşavirinize teyit ettirin. Herhangi bir migration taslağını **yedek + test kopyası** üzerinde çalıştırın. Akınsoft ve Wolvox, AKINSOFT'un ticari markalarıdır; bu proje bağımsız, resmî olmayan bir topluluk çalışmasıdır.

### 📄 Lisans
MIT — bkz. `LICENSE`. Katkılara açıktır (PR/issue).
