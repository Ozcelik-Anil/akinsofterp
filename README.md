# akinsofterp — Akınsoft Wolvox 8/9 ERP Expert (Claude Skill)

This repo ships a single-file system instruction (`SKILL.md`) that turns Claude into an **elite, read-only, KVKK/GDPR-safe, schema-verified Akınsoft Wolvox 8/9 ERP consultant**. Load it into any Claude surface and you get an expert that performs read-only, schema-validated analysis on MS SQL Server or Firebird, and gives you both the SQL query and the equivalent Akınsoft UI path.

> Turkish note: the skill's own domain content (SQL, ERP terminology, Turkish tax/compliance rules) is intentionally written in Turkish, since that matches the Akınsoft Wolvox product itself. This README (repo documentation) is in English.

## ✨ What it does
- **Structural health scan** — broken currency records, cards without a group code, duplicate barcodes, negative stock.
- **Commercial analysis** — customers/vendors inactive 90+ days, dead/slow-moving stock, stock turnover rate, dynamic price matrix.
- **Turkish compliance** — e-Transformation (e-Invoice/e-Archive/e-Waybill/e-Ledger) diagnostics, VAT/excise/withholding checks, accounting integration & trial balance.
- **Unused features** — campaign engine, min/max stock triggers, automatic email/task scheduler.
- **Quick wins** — barcode automation, terminal-based default warehouse, 5-minute setting tweaks.

## 🔒 Safety principles (baked into the file)
- **Read-only (SELECT-only).** Never runs `UPDATE/DELETE/DROP` in production; fixes are offered as an **inert migration draft** (`BEGIN TRAN … ROLLBACK;`) or a **UI walkthrough**.
- **KVKK/GDPR.** Never pulls personal data (name, phone, email, national ID, tax ID, address); masks it in-query when unavoidable; focuses on aggregates.
- **Live-ERP safety.** Uses `READ UNCOMMITTED / NOLOCK` to avoid locking, a `db_datareader` login, bans `SELECT *`, and prefers running against a backup copy.
- **Schema-first, verify-first.** Never invents column names; validates against `INFORMATION_SCHEMA` / `RDB$`.
- **Ethical/legal limits.** Refuses license cracking, fake e-invoices, record tampering/tax evasion, and bulk PII extraction.

## 🚀 Quick install

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

### 1) Claude Code (as a skill — full power, recommended) 🟢
Use one of the quick-install snippets above. If you'd rather do it by hand, copy into `.claude/skills/akinsofterp/`:
- `SKILL.md` (the frontmatter's `name`+`description` is what triggers it),
- the **`reference/` folder as-is** next to it (Claude reads it on demand).

If a SQL/MCP connection is available, **Mode B (connected)** lets Claude run the read-only queries itself. With all reference packs in place (schema, code glossary, query recipes, troubleshooting) you get the highest-capability setup.

### 2) Claude Projects 🟡
1. claude.ai → **Projects** → new project.
2. Paste the contents of `SKILL.md` into **Project instructions** (you can strip the frontmatter).
3. **Also upload the reference packs:** add each `reference/*.md` file to the project's **knowledge** area as a separate document (without them, Claude only has the summary in `SKILL.md` — still useful, but missing schema/code detail).
4. State the engine, version, and fiscal year in your first message.

### 3) Custom Instructions 🟠 (limited)
There's a character limit and **you can't attach files.** Paste `SKILL.md` (without the frontmatter); if it doesn't fit, keep at least these core sections: *Pre-Flight Checklist · Universal-vs-This-Install · Read-Only Contract · Schema-First · CONFIRMED CORE · Output Standards*. For schema/code detail, paste the relevant `reference/*.md` content into the chat as needed. (Prefer option 1 or 2 for full power.)

## 🧭 Two operating modes
- **Mode A — Advisor/Offline:** No DB connection. Claude writes the query; you run it and paste back the (masked/summarized) result.
- **Mode B — Connected:** Claude Code + a shell/SQL client/MCP runs the read-only queries itself.

## 🗂️ Repo contents
| File | Description |
|---|---|
| `SKILL.md` | Main system instruction (role, safety, pre-flight checklist, schema reference, 5 strategic pillars, Turkish compliance, cost & turnover, Firebird appendix, glossary). |
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
| `reference/ozel-ayarlar.md` | **Custom Settings reference** — the settings catalog that drives Wolvox behavior (`Custom Settings > <Module>`): per-module *setting → what it does → consultant trap*. Sourced from `📹` the official Custom Settings video series (10 core tabs). Includes the built-in **reprice trigger** (`Invoice Settings > Purchase Invoice`). The answer to "why does the program do X / how do I make it do X". |
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

## ⚠️ Disclaimer
This instruction set is a **consulting/analysis** tool; it does not replace a licensed accountant or Akınsoft's official support. Always confirm tax/regulatory decisions with your CPA. Run any migration draft against a **backup + test copy** first. Akınsoft and Wolvox are trademarks of AKINSOFT; this project is an independent, unofficial community effort.

## 📄 License
MIT — see `LICENSE`. Contributions welcome (PRs/issues).
