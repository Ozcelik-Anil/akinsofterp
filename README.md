# akinsofterp

Akınsoft Wolvox 8/9 ERP Expert / Uzmanı — Claude Skill

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**English** | [Türkçe](#türkçe)

---

## English

This repo ships a single-file system instruction (`SKILL.md`) that turns Claude into an **elite, read-only, KVKK/GDPR-safe, schema-verified Akınsoft Wolvox 8/9 ERP consultant**. Load it into any Claude surface and you get an expert that performs read-only, schema-validated analysis on MS SQL Server or Firebird, and gives you both the SQL query and the equivalent Akınsoft UI path.

> Turkish note: the skill's own domain content (SQL, ERP terminology, Turkish tax/compliance rules) is intentionally written in Turkish, since that matches the Akınsoft Wolvox product itself. This README (repo documentation) is bilingual.

### What it does
- **Native-first reflex.** Before proposing any SQL write / fix / automation, checks whether Wolvox already has a built-in feature for it (`reference/native-yetenek-indeksi.md` — 15 modules, need → built-in feature → menu path → confidence → trap), now including e-Commerce/marketplace, quick-sale/POS, purchasing/finance/documents, and CRM.
- **Structural health scan** — broken currency records, cards without a group code, duplicate barcodes, negative stock.
- **Commercial analysis** — customers/vendors inactive 90+ days, dead/slow-moving stock, stock turnover rate, dynamic price matrix.
- **Turkish compliance** — e-Transformation (e-Invoice/e-Archive/e-Waybill/e-Ledger) diagnostics, VAT/excise/withholding checks, accounting integration & trial balance.
- **Unused features** — campaign engine, min/max stock triggers, automatic email/task scheduler.
- **Quick wins** — barcode automation, terminal-based default warehouse, 5-minute setting tweaks.

### Safety principles (baked into the file)
- **Read-only (SELECT-only).** Never runs `UPDATE/DELETE/DROP` in production; fixes are offered as an **inert migration draft** (`BEGIN TRAN … ROLLBACK;`) or a **UI walkthrough**.
- **Read-only login bootstrap (Mode B).** Before any connected-mode work, walks through creating a dedicated `wolvox_ro` login with only `db_datareader` and proves it with a zero-row `UPDATE` that must fail — read-only by construction, not by discipline.
- **KVKK/GDPR.** Never pulls personal data (name, phone, email, national ID, tax ID, address); masks it in-query when unavoidable; focuses on aggregates.
- **Live-ERP safety.** Uses `READ UNCOMMITTED / NOLOCK` to avoid locking, a `db_datareader` login, bans `SELECT *`, and prefers running against a backup copy.
- **Schema-first, verify-first.** Never invents column names; validates against `INFORMATION_SCHEMA` / `RDB$`.
- **Ethical/legal limits.** Refuses license cracking, fake e-invoices, record tampering/tax evasion, and bulk PII extraction.

### Quick install

Pick the snippet for your shell — each downloads the repo straight into your Claude Code skills folder. No manual file renaming needed; `SKILL.md` and `reference/` are already laid out correctly in the repo.

**macOS / Linux / WSL (bash, git):**
```bash
git clone https://github.com/Ozcelik-Anil/akinsofterp.git ~/.claude/skills/akinsofterp
```

**Windows (PowerShell, git):**
```powershell
git clone https://github.com/Ozcelik-Anil/akinsofterp.git "$env:USERPROFILE\.claude\skills\akinsofterp"
```

**No git available (bash, tarball download):**
```bash
mkdir -p ~/.claude/skills && \
curl -L https://github.com/Ozcelik-Anil/akinsofterp/archive/refs/heads/master.tar.gz \
  | tar -xz -C ~/.claude/skills/ && \
mv ~/.claude/skills/akinsofterp-master ~/.claude/skills/akinsofterp
```

**No git available (PowerShell, zip download):**
```powershell
$dest = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri "https://github.com/Ozcelik-Anil/akinsofterp/archive/refs/heads/master.zip" -OutFile "$env:TEMP\akinsofterp.zip"
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

> **Reference packs aren't auto-read on every surface.** The files under `reference/` are only pulled in on demand by a **Claude Code** install. On other surfaces you need to supply them yourself (see below).

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

### Two operating modes
- **Mode A — Advisor/Offline:** No DB connection. Claude writes the query; you run it and paste back the (masked/summarized) result.
- **Mode B — Connected:** Claude Code + a shell/SQL client/MCP runs the read-only queries itself, after the read-only login bootstrap above.

### Repo contents
| File | Description |
|---|---|
| `SKILL.md` | Main system instruction — role, safety, read-only login bootstrap, native-first gate, schema reference, Turkish compliance, Firebird appendix. |
| `reference/native-yetenek-indeksi.md` | Native Capability Index — need → built-in Wolvox feature → menu path → confidence (`≈`/`📹`/`✓`) → trap, across 15 modules. |
| `reference/danismanlik-metodolojisi.md` | Consulting methodology — one engagement flow (Discovery → Assessment → Prioritization → Implementation → Delivery → Follow-up) mapped to which pack to use. |
| `reference/schema-map.md` | Generic Wolvox 8 schema map — table roles, key columns, naming codes, relationships, KVKK/PII register. No real business data. |
| `reference/sorgu-recetesi.md` | Read-only diagnostic query recipes (data health, dead stock, customer balance, pending e-invoices). |
| `reference/kod-sozlugu.md` | Code glossary — decodes `smallint` enum fields (`TUTAR_TURU`, `EVRAK_TURU`, `EFATURA_DURUM`…). |
| `reference/vaka-catalogu-100.md` | 100 solved cases across 14 module categories, each with its trap, table/column, and UI path. |
| `reference/vaka-bankasi.md` | Extended case bank — 900 more questions + a Solution Pattern Library (P1–P30). 1,000 cases total. |
| `reference/hesaplama-ornekleri.md` | Worked examples for the costliest silent-error classes: reprice rounding, VAT-inclusive math, FX conversion, inflation profit. |
| `reference/cozum-desenleri.md` | Canonical SQL for Solution Patterns P1–P30, with Firebird differences. |
| `reference/verimlilik-skoru.md` | Utilization Score — a 0–100 rubric for how efficiently a business uses Wolvox. |
| `tools/` | Read-only executable scripts: repricing preview, utilization scorecard, and a repo consistency/privacy auditor. No write access. |
| `reference/sorun-giderme.md` | Troubleshooting playbook — symptom → cause → diagnosis → fix. |
| `reference/menu-haritasi.md` | UI menu map with confidence tiers (`≈` general · `📹` video-sourced · `✓` field-verified). |
| `reference/turkiye-uyumluluk.md` | Turkish compliance reference — VAT/withholding matrix, e-Invoice logic, GİB status codes, inflation accounting, KVKK anonymization. |
| `reference/ozel-ayarlar.md` | Custom Settings catalog across 17 tabs — setting → effect → consultant trap, including the built-in reprice trigger. |
| `reference/kurulum-playbook.md` | Setup/implementation playbooks — e-Invoice, automatic repricing, year-end rollover, minimum records. |
| `reference/rapor-sablonlari.md` | Consultant deliverable templates — health report, top-20 findings, 30-60-90 action plan. |
| `reference/modul-derinlik.md` | Deep dives on niche modules — Manufacturing/BOM, Batch-Lot-Serial, Technical Service, Payroll/HR. |
| `reference/perakende-entegrasyon.md` | Retail integrations — POS/cash registers, e-commerce/marketplace payment and shipping flows. |
| `reference/dba-performans.md` | DBA/performance & migration — DMV diagnostics, index recommendations, 8→9 and MSSQL↔Firebird migration. |
| `reference/altin-cevap-eval.md` | Golden answer set (G1–G15) — expected expert key points vs. the wrong answer to avoid. |
| `reference/dogrulama-testleri.md` | 22 behavioral tests verifying the skill's schema, safety, and privacy behavior. |
| `CHANGELOG.md` | Version history (SemVer). |
| `CONTRIBUTING.md` | Contribution rules and a quick start for adapting this to your own install. |
| `.gitignore` | Keeps data/backup/secret files out of the repo (KVKK). |
| `LICENSE` | MIT. |

> **Multi-file skill:** `SKILL.md` is the lean "brain/behavior" layer; the packs under `reference/` are verified information read on demand. In a Claude Code skill install, keep the files next to `SKILL.md` with the `reference/` folder alongside it — Claude reads them when it needs to.

### Disclaimer
This instruction set is a **consulting/analysis** tool; it does not replace a licensed accountant or Akınsoft's official support. Always confirm tax/regulatory decisions with your CPA. Run any migration draft against a **backup + test copy** first. Akınsoft and Wolvox are trademarks of AKINSOFT; this project is an independent, unofficial community effort.

### License
MIT — see `LICENSE`. Contributions welcome (PRs/issues).

---

[English](#english) | **Türkçe**

## Türkçe

Bu depo, **Claude'u dünya çapında bir Akınsoft Wolvox 8/9 ERP danışmanına** dönüştüren tek dosyalık bir sistem talimatı (`SKILL.md`) içerir. Dosyayı herhangi bir Claude yüzeyine yükleyince; MS SQL / Firebird tarafında **salt-okunur, KVKK uyumlu, şema-doğrulamalı** analizler yapan, hem SQL hem Akınsoft arayüz yolları veren bir uzman elde edersiniz.

> Türkçe not: skill'in kendi alan içeriği (SQL, ERP terminolojisi, Türk vergi/uyumluluk kuralları) kasıtlı olarak Türkçe yazılmıştır, çünkü Akınsoft Wolvox ürününün kendisi de öyledir. Bu README (repo dokümantasyonu) iki dillidir.

### Neler yapar?
- **Native-first refleks.** Herhangi bir SQL yazma/düzeltme/otomasyon önerisinden önce Wolvox'ta bunun için zaten yerleşik bir özellik olup olmadığını kontrol eder (`reference/native-yetenek-indeksi.md` — 14 modül, iş-ihtiyacı → yerleşik özellik → menü yolu → güven → tuzak); artık e-ticaret/pazaryeri, hızlı satış/POS ve satınalma/finans/doküman'ı da kapsıyor.
- **Yapısal sağlık taraması** — bozuk döviz/para birimi kayıtları, grup kodsuz kartlar, mükerrer barkod, negatif stok.
- **Ticari analiz** — 90+ gün hareketsiz cariler, ölü/yavaş stok, stok devir hızı, dinamik fiyat matrisi.
- **Türkiye uyumluluğu** — e-Dönüşüm (e-Fatura/e-Arşiv/e-İrsaliye/e-Defter) tanıları, KDV/ÖTV/Tevkifat kontrolleri, muhasebe entegrasyonu & mizan.
- **Kullanılmayan özellikler** — kampanya motoru, min/max stok tetikleyicileri, otomatik e-posta/görev planlayıcı.
- **Hızlı kazanımlar** — barkod otomasyonu, terminal bazlı varsayılan depo, 5 dakikalık ayar dokunuşları.

### Güvenlik ilkeleri (dosyaya gömülü)
- **Salt-okunur (SELECT-only).** Üretimde asla `UPDATE/DELETE/DROP` çalıştırmaz; düzeltmeleri **inert migration taslağı** (`BEGIN TRAN … ROLLBACK;`) veya **arayüz yolu** olarak sunar.
- **Salt-okunur login bootstrap (Mode B).** Bağlı moddaki her işten önce ayrı bir `wolvox_ro` login'in yalnız `db_datareader` yetkisiyle kurulmasından geçer ve bunu sıfır-satır bir `UPDATE` denemesiyle kanıtlar (başarısız olması beklenir) — salt-okunuşluk disipline değil **yapıya** dayanır.
- **KVKK/GDPR.** Kişisel veriyi (ad, telefon, e-posta, TCKN, VKN, adres) çekmez; kaçınılmazsa sorgu içinde maskeler; agregat veriye odaklanır.
- **Canlı ERP güvenliği.** Kilitlenmeyi önlemek için `READ UNCOMMITTED / NOLOCK`, `db_datareader` login, `SELECT *` yasağı, tercihen yedek kopya üzerinde çalışma.
- **Şema-önce-doğrula.** Kolon uydurmaz; `INFORMATION_SCHEMA` / `RDB$` ile doğrular.
- **Etik/yasal sınırlar.** Lisans kırma, sahte e-fatura, kayıt tahrifi/vergi kaçırma, toplu PII çekimi → reddeder.

### Kurulum

Kabuğunuza uygun parçayı seçin — her biri repoyu doğrudan Claude Code skills klasörünüze indirir. Elle dosya yeniden adlandırmaya gerek yok; `SKILL.md` ve `reference/` repoda zaten doğru yerleşimde.

**macOS / Linux / WSL (bash, git):**
```bash
git clone https://github.com/Ozcelik-Anil/akinsofterp.git ~/.claude/skills/akinsofterp
```

**Windows (PowerShell, git):**
```powershell
git clone https://github.com/Ozcelik-Anil/akinsofterp.git "$env:USERPROFILE\.claude\skills\akinsofterp"
```

**Git yoksa (bash, tarball indirme):**
```bash
mkdir -p ~/.claude/skills && \
curl -L https://github.com/Ozcelik-Anil/akinsofterp/archive/refs/heads/master.tar.gz \
  | tar -xz -C ~/.claude/skills/ && \
mv ~/.claude/skills/akinsofterp-master ~/.claude/skills/akinsofterp
```

**Git yoksa (PowerShell, zip indirme):**
```powershell
$dest = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri "https://github.com/Ozcelik-Anil/akinsofterp/archive/refs/heads/master.zip" -OutFile "$env:TEMP\akinsofterp.zip"
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

> **Referans paketleri her yüzeyde otomatik okunmaz.** `reference/` dosyaları yalnızca **Claude Code** kurulumunda ihtiyaç anında okunur. Diğer yüzeylerde onları da elle vermeniz gerekir (aşağıda).

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

### İki çalışma modu
- **Mode A — Danışman/Offline:** DB bağlantısı yok. Claude sorguyu üretir, siz çalıştırıp sonucu (maskeli/özet) yapıştırırsınız.
- **Mode B — Bağlı:** Claude Code + shell/SQL client/MCP, yukarıdaki salt-okunur login bootstrap'ından sonra sorguları kendisi çalıştırır.

### Depo içeriği
| Dosya | Açıklama |
|---|---|
| `SKILL.md` | Ana sistem talimatı — rol, güvenlik, salt-okunur login bootstrap, native-first kapısı, şema referansı, TR uyumluluk, Firebird eki. |
| `reference/native-yetenek-indeksi.md` | Native Yetenek İndeksi — iş-ihtiyacı → yerleşik Wolvox özelliği → menü yolu → güven (`≈`/`📹`/`✓`) → tuzak, 14 modül boyunca. |
| `reference/danismanlik-metodolojisi.md` | Danışmanlık metodolojisi — tüm paketleri bir angajman akışına dizer (Keşif→Değerlendirme→Önceliklendirme→Uygulama→Teslimat→Takip). |
| `reference/schema-map.md` | Jenerik Wolvox 8 şema haritası — tablo rolleri, anahtar kolonlar, isimlendirme kodları, ilişkiler, KVKK/PII kayıt defteri. Gerçek veri yok. |
| `reference/sorgu-recetesi.md` | Salt-okunur tanı sorguları (veri sağlığı, ölü stok, cari bakiye, askıda e-fatura). |
| `reference/kod-sozlugu.md` | Kod sözlüğü — `smallint` enum alanlarının çözümü (`TUTAR_TURU`, `EVRAK_TURU`, `EFATURA_DURUM`…). |
| `reference/vaka-catalogu-100.md` | 14 modül-kategorisinde 100 çözülmüş vaka, her biri tuzak + tablo/kolon + UI yoluyla. |
| `reference/vaka-bankasi.md` | Genişletilmiş vaka bankası — 900 soru daha + Çözüm Deseni Kütüphanesi (P1–P30). Toplam 1.000 vaka. |
| `reference/hesaplama-ornekleri.md` | En pahalı sessiz-hata sınıfları için çalışılmış örnekler: reprice yuvarlama, KDV dahil/hariç, döviz çevrimi, enflasyon kârı. |
| `reference/cozum-desenleri.md` | Çözüm Desenleri (P1–P30) için kanonik SQL, Firebird farklarıyla. |
| `reference/verimlilik-skoru.md` | Verimli Kullanım Skoru — işletmenin Wolvox'u ne kadar verimli kullandığını gösteren 0–100 rubrik. |
| `tools/` | Salt-okunur çalıştırılabilir betikler: yeniden fiyatlama önizleme, verimlilik skoru, repo tutarlılık/gizlilik denetçisi. Yazma yetkisi yok. |
| `reference/sorun-giderme.md` | Sorun giderme playbook'u — semptom → neden → tanı → çözüm. |
| `reference/menu-haritasi.md` | Güven kademeli UI menü haritası (`≈` genel · `📹` video-kaynaklı · `✓` saha-teyitli). |
| `reference/turkiye-uyumluluk.md` | Türkiye uyumluluk referansı — KDV/tevkifat matrisi, e-Fatura mantığı, GİB kodları, enflasyon muhasebesi, KVKK anonimleştirme. |
| `reference/ozel-ayarlar.md` | 17 sekme boyunca Özel Ayarlar kataloğu — ayar → etki → danışman tuzağı, yerleşik reprice tetiği dahil. |
| `reference/kurulum-playbook.md` | Kurulum/implementasyon playbook'ları — e-Fatura, otomatik reprice, yıl-sonu devir, asgari kayıtlar. |
| `reference/rapor-sablonlari.md` | Danışman teslimat şablonları — sağlık raporu, en kritik 20 bulgu, 30-60-90 aksiyon planı. |
| `reference/modul-derinlik.md` | Niş modüllerde derinlemesine inceleme — Üretim/Reçete, Parti-Lot-Seri, Teknik Servis, Bordro/İK. |
| `reference/perakende-entegrasyon.md` | Perakende entegrasyonları — ÖKC/yazar kasa, e-ticaret/pazaryeri ödeme ve kargo akışları. |
| `reference/dba-performans.md` | DBA/performans & göç — DMV teşhisleri, indeks önerileri, 8→9 ve MSSQL↔Firebird göçü. |
| `reference/altin-cevap-eval.md` | Altın cevap seti (G1–G15) — beklenen uzman anahtar-noktaları vs. kaçınılacak yanlış. |
| `reference/dogrulama-testleri.md` | Skill'in şema, güvenlik ve gizlilik davranışını doğrulayan 22 davranış testi. |
| `CHANGELOG.md` | Sürüm geçmişi (SemVer). |
| `CONTRIBUTING.md` | Katkı kuralları ve kendi kurulumuna uyarlama için hızlı başlangıç. |
| `.gitignore` | Veri/yedek/gizli dosyaları repo dışında tutar (KVKK). |
| `LICENSE` | MIT. |

> **Çok-dosyalı skill:** `SKILL.md` yağsız "beyin/davranış" katmanıdır; `reference/` altındaki paketler ihtiyaç anında okunacak doğrulanmış bilgidir. Claude Code skill'inde dosyaları `SKILL.md`'nin yanına `reference/` klasörüyle koyun — Claude gerektiğinde okur.

### Sorumluluk reddi
Bu talimat bir **danışmanlık/analiz** aracıdır; resmî mali müşavirlik veya Akınsoft resmî desteği yerine geçmez. Vergi/mevzuat kararlarını daima mali müşavirinize teyit ettirin. Herhangi bir migration taslağını **yedek + test kopyası** üzerinde çalıştırın. Akınsoft ve Wolvox, AKINSOFT'un ticari markalarıdır; bu proje bağımsız, resmî olmayan bir topluluk çalışmasıdır.

### Lisans
MIT — bkz. `LICENSE`. Katkılara açıktır (PR/issue).
