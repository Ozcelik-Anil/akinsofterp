# Niş YouTube İçeriği Damıtma Kampanyası — Round 2 — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Round 1'de "belirsiz statülü" diye ayrılan 9 kanal + yeni bulunan 5 bağımsız kanal + 2 muhtemel resmî alt-kanalı (AKINSOFT Eğitim, AKINSOFT Global) tarayıp damıtarak `akinsofterp` skill'ine işlemek. Kullanıcı 2 kanalı resmî kabul etti (`📹`), geri kalan 14 kanalı bağımsız/niş kabul etti (`👤`).

**Architecture:** Round 1 ile aynı üç aşamalı huni: (1) ucuz metadata-only keşif, (2) filtrelenmiş adaylardan transkript indirme, (3) transkript → damıtılmış bilgi → `reference/*.md`'ye kanonik terimlerle satır ekleme. **Tek fark:** keşif/takip dosyası bu sefer worktree İÇİNDE değil, **ana repo kökünde** (worktree dışı, mutlak yol) tutulur — round 1'de worktree silinirken bu dosya (hiç commit edilmediği için) kalıcı olarak kayboldu; bu round'da aynı hata tekrarlanmayacak.

**Tech Stack:** `yt-dlp` (CLI, kurulu — v2026.07.04), Bash, mevcut `tools/consistency-check.ps1` (PowerShell).

## Kanal Listesi (round 1 taramasından, kullanıcı onaylı)

**`📹` Resmî kabul edilen (2):**
- AKINSOFT Eğitim — `https://www.youtube.com/@AKINSOFTEgitim` (95+ Wolvox videosu)
- AKINSOFT Global — `https://www.youtube.com/@AKINSOFTGlobal`

**`👤` Bağımsız/belirsiz kabul edilen (9, önceki "belirsiz statülü" liste):**
- AKINSOFT İstanbul Eğitim — `https://www.youtube.com/@akinsoftistanbulegitim5283`
- Akinsoft Bayi — `https://www.youtube.com/@akinsoftbayi9400`
- Akınsoft Bayii — `https://www.youtube.com/@aknsoftbayii5069`
- AKINSOFT Kocaeli Bölge Müdürlüğü — `https://www.youtube.com/@akinsoftkocaeli`
- Akınsoft Antalya — `https://www.youtube.com/@AkinsoftAntalya`
- AKINSOFT RED EĞİTİM — `https://www.youtube.com/@akinsoftredegitim4224`
- AKINSOFT Bilgi Kanalı — `https://www.youtube.com/@akinsoftbilgikanal5593`
- Akınsoft Script (ismail BARAN) — `https://www.youtube.com/@pascalscript`
- Akınsoft Wolvox Eğitimi Teknik Destek Danışmanlık (Ufuk Aydın) — `https://www.youtube.com/@ufukaydinerp`

**`👤` Yeni bulunan bağımsız (5):**
- EGÜNCEL BİLİŞİM A.Ş.
- BahçaSoft Bilişim
- Lila Bilişim
- Sentez Yazılım
- Muhammet Hoca ile Kolay Muhasebe

(Bu 5 kanalın URL'si henüz teyit edilmedi — Task 1 Step 1'de `yt-dlp "ytsearch:<kanal adı> Wolvox"` ile bulunacak.)

## Global Constraints

- **Durable tracking dosyası worktree dışında tutulur:** `docs/video-kaynaklari.local.txt` bu round'da mutlak yolla **ana repoda** yazılır: `C:\Users\Anıl pc\.claude\skills\akinsofterp\docs\video-kaynaklari.local.txt` (worktree yolu değil — `.worktrees\nis-youtube-damitma-r2\docs\...` DEĞİL). Bu dosya zaten `.gitignore`'daki `*.local.txt` deseniyle ignore edilir, hangi checkout'ta olursa olsun commit edilmez; ama worktree silindiğinde ana repodaki kopyası etkilenmez.
- Repoya ham transkript, video linki veya video ID'si commit edilmez — yalnız damıtılmış bilgi + `📹`/`👤` etiketi.
- Menü yolu / kolon adı / terim iddiası yalnız `reference/schema-map.md` ve `reference/menu-haritasi.md` ile tutarlıysa yazılır; uydurma/sapan terim reddedilir.
- Gerçek müşteri/firma verisi (video ekranında görünse bile) asla kopyalanmaz — yalnız genel menü/özellik bilgisi (KVKK).
- Her `reference/*.md` değişikliğinden sonra `tools\consistency-check.ps1` exit 0 olmalı; değilse commit edilmez.
- Sürüm: davranış/içerik değişikliği → `CHANGELOG.md` girişi + SemVer bump; `SKILL.md` sürümü `CHANGELOG.md` en üstüyle eşleşmeli.
- Scratch/ara dosyalar (transkriptler, ham arama çıktıları) yalnız scratchpad altında tutulur, repoya girmez.
- **Kapsam sınırlaması yok:** kullanıcı talimatı — "yararlı olabilecek her şeyi damıt", 10-15 gibi bir hedef sayı yok. Bulunan her somut/yararlı bulgu değerlendirilir.
- 2 resmî kanaldan (`AKINSOFT Eğitim`, `AKINSOFT Global`) gelen bulgular `📹` etiketiyle, diğer 14 kanaldan gelenler `👤` etiketiyle yazılır — round 1'deki etiket lejantı zaten her iki sembolü de tanımlıyor, yeni lejant girişi gerekmez.

---

### Task 1: 16 kanalın tam keşfi + filtre

**Files:**
- Create (scratchpad): `r2_channel_raw/<kanal>.txt` (kanal başına ham liste)
- Create (ana repo, gitignored, worktree DIŞI mutlak yol): `docs/video-kaynaklari.local.txt`

**Interfaces:**
- Consumes: yok (ilk adım)
- Produces: `docs/video-kaynaklari.local.txt` içinde her 16 kanal için bir `## <Kanal> (<url>) [📹|👤]` bölümü

- [ ] **Step 1: Her kanalın video listesini çek**

Bilinen 11 kanal için (2 resmî + 9 belirsiz), URL'ler yukarıdaki listede verildi:

```bash
for ch in "AKINSOFTEgitim" "AKINSOFTGlobal" "akinsoftistanbulegitim5283" \
          "akinsoftbayi9400" "aknsoftbayii5069" "akinsoftkocaeli" \
          "AkinsoftAntalya" "akinsoftredegitim4224" "akinsoftbilgikanal5593" \
          "pascalscript" "ufukaydinerp"; do
  yt-dlp "https://www.youtube.com/@$ch/videos" \
    --flat-playlist --print "%(id)s|%(title)s" --playlist-end 500 \
    > "<scratchpad>/r2_channel_raw/$ch.txt" 2>&1
done
```

5 yeni bağımsız kanal için önce URL bul, sonra aynı şekilde listele:

```bash
for name in "EGÜNCEL BİLİŞİM" "BahçaSoft Bilişim" "Lila Bilişim" \
            "Sentez Yazılım" "Muhammet Hoca ile Kolay Muhasebe"; do
  yt-dlp "ytsearch5:$name Wolvox" --flat-playlist \
    --print "%(channel)s|%(channel_url)s" 2>&1 | sort -u
done
```

Bulunan her kanal URL'si için yukarıdaki gibi `--flat-playlist` ile tam liste çek.

- [ ] **Step 2: Wolvox geçen başlıkları filtrele**

Her kanalın ham dosyasında:

```bash
grep -i wolvox "<scratchpad>/r2_channel_raw/<kanal>.txt" \
  > "<scratchpad>/r2_channel_raw/<kanal>_candidates.txt"
```

(Bir kanalda Wolvox dışı ürün videoları da olabilir — AKINSOFT çoklu ürün satıyor, örn. Wolvox Otel/Restaurant/ERP farklı edisyonlar; hepsi "Wolvox" geçtiği için Step 2'den geçer, edisyon farkını Step 3'te değerlendir.)

- [ ] **Step 3: Başlıkları incele, arayüz/özellik gösteren olmayanları ele**

Round 1 Task 1 Step 3 ile aynı kriter: somut modül/işlem adı taşıyan başlıkları tut, genel tanıtım/reklam başlıklarını ele. Wolvox Otel/Restaurant videolarını da tut (farklı edisyon notu ile) — round 1'de bu tür bulgular Wolvox Otel için "gelecek kampanyaya ertelendi" diye ayrılmıştı, bu round'da da aynı ayrım geçerli olabilir; Task 3'te netleştirilecek.

- [ ] **Step 4: Tutulanları ana repodaki özel nota yaz**

`C:\Users\Anıl pc\.claude\skills\akinsofterp\docs\video-kaynaklari.local.txt` dosyasını oluştur (yoksa), her kanal için:

```
## <Kanal adı> (<channel_url>) [📹 veya 👤]
- <video_id> | <başlık> | durum: bekliyor
...
```

- [ ] **Step 5: gitignore doğrula**

```bash
cd "/c/Users/Anıl pc/.claude/skills/akinsofterp/" && git check-ignore -v docs/video-kaynaklari.local.txt
```

Beklenen: `.gitignore:7:*.local.txt` eşleşmesi (ana repoda, worktree'de DEĞİL).

---

### Task 2: Öncelik sırası

**Files:**
- Modify (ana repo, mutlak yol): `docs/video-kaynaklari.local.txt`

**Interfaces:**
- Consumes: Task 1'in ürettiği tüm `## <Kanal>` bölümleri
- Produces: dosya başına eklenen `## Öncelik Sırası` bölümü

- [ ] **Step 1: Tüm "durum: bekliyor" satırlarını gözden geçir, önceliklendir**

Round 1 Task 3 Step 1 ile aynı kriter: (a) somut işlem/modül adı, (b) mevcut `reference/*.md` dosyalarında henüz kapsanmamış konular öncelikli — `Grep` ile tara. Ek olarak: **📹 kanallardan gelenler eşit önem taşıyan bulgularda `👤` kanallara göre öncelik alır** (resmî kaynak daha güvenilir → önce işlensin).

- [ ] **Step 2: Sıralı listeyi dosyaya yaz**

```
## Öncelik Sırası
1. <video_id> — <kanal> [📹/👤] — <neden öncelikli, 1 cümle>
2. ...
```

---

### Task 3: Transkript indirme (ilk dalga — öncelik 1-60)

**Files:**
- Create (scratchpad): `transcripts/<video_id>.tr.srt` (veya `.en.srt`)

**Interfaces:**
- Consumes: Task 2'nin `## Öncelik Sırası` listesinin ilk 60 satırı
- Produces: her video için scratchpad'de bir `.srt` dosyası veya "altyazı yok" notu

- [ ] **Step 1: Öncelikli video için oto-altyazı indir**

```bash
mkdir -p "<scratchpad>/transcripts"
yt-dlp "https://www.youtube.com/watch?v=<video_id>" \
  --write-auto-sub --skip-download --sub-lang tr,en --convert-subs srt \
  -o "<scratchpad>/transcripts/%(id)s.%(ext)s"
```

- [ ] **Step 2: Sonucu ana repodaki nota işle**

Başarılı → `durum: transkript indirildi`. Altyazısız → `durum: altyazı yok` (damıtma dışı).

---

### Task 4: Transkript indirme (ikinci dalga — kalan öncelikli videolar)

**Files:**
- Create (scratchpad): `transcripts/<video_id>.tr.srt`

**Interfaces:**
- Consumes: Task 2'nin listesinde 60. satırdan sonrası
- Produces: Task 3 ile aynı format, kalan videolar için

- [ ] **Step 1-2: Task 3 ile aynı adımlar, kalan liste için**

---

### Task 5: Transkript okuma ve damıtma — 📹 resmî kanallar

**Files:**
- Create (scratchpad): `damitma-taslak-r2-resmi.md`

**Interfaces:**
- Consumes: AKINSOFT Eğitim + AKINSOFT Global'e ait `.srt` dosyaları + `reference/schema-map.md`, `reference/menu-haritasi.md`
- Produces: `damitma-taslak-r2-resmi.md` — Task 7'nin kaynağı

- [ ] **Step 1-3: Round 1 Task 5 ile aynı yöntem**

Her transkript için işlem adımlarını çıkar, kanonik terimle çapraz kontrol et (`grep -i "<terim>" reference/schema-map.md reference/menu-haritasi.md`, eşleşme yoksa ekleme), taslağa yaz. **Etiket: `📹`** (resmî kanal kaynaklı).

```
### <video_id> — AKINSOFT Eğitim/Global
Hedef dosya: reference/<dosya>.md (§<bölüm>)
Satır: | <İhtiyaç> | <Native çözüm> | <Yol> | 📹 | <Tuzak/not> |
```

---

### Task 6: Transkript okuma ve damıtma — 👤 bağımsız/niş kanallar

**Files:**
- Create (scratchpad): `damitma-taslak-r2-nis.md`

**Interfaces:**
- Consumes: 14 bağımsız kanala ait `.srt` dosyaları + `reference/schema-map.md`, `reference/menu-haritasi.md`
- Produces: `damitma-taslak-r2-nis.md` — Task 7'nin kaynağı

- [ ] **Step 1-3: Round 1 Task 5 ile aynı yöntem, etiket `👤`**

---

### Task 7: `reference/*.md` güncelleme (round 1'de dokunulan 5 dosya + gerekirse yenisi)

**Files:**
- Modify: `reference/native-yetenek-indeksi.md`, `reference/menu-haritasi.md`, `reference/modul-derinlik.md`, `reference/kurulum-playbook.md`, `reference/perakende-entegrasyon.md`
- Modify (gerekirse): damıtılan bulgu mevcut 5 dosyanın kapsamı dışındaysa, en yakın uygun `reference/*.md` dosyasını belirle (örn. Wolvox Otel bulguları için ayrı bir bölüm/dosya gerekebilir — controller karar verir)

**Interfaces:**
- Consumes: `damitma-taslak-r2-resmi.md` + `damitma-taslak-r2-nis.md`
- Produces: güncellenmiş `reference/*.md` dosyaları

- [ ] **Step 1: Her iki taslaktaki satırı ilgili tabloya ekle**

Mevcut tablo formatını birebir koru. `📹` satırları resmî kaynaklı, `👤` satırları niş kaynaklı — round 1'deki lejant zaten her ikisini tanımlıyor, değişiklik gerekmez.

- [ ] **Step 2: Aynı özellik zaten varsa ekleme, geç**

Round 1 Task 6 Step 3 ile aynı kural.

---

### Task 8: `CHANGELOG.md` girişi + sürüm bump

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `SKILL.md` (frontmatter `version:`)

**Interfaces:**
- Consumes: Task 7'de yapılan gerçek değişiklik özeti
- Produces: `CHANGELOG.md` en üstü = `SKILL.md` sürümü

- [ ] **Step 1: Mevcut sürümü oku, SemVer minor bump uygula**

```bash
grep "^version:" SKILL.md
head -5 CHANGELOG.md
```

- [ ] **Step 2: CHANGELOG girişi yaz**

```markdown
## [<yeni_sürüm>] — 2026-07-26
### Eklendi (niş YouTube damıtma kampanyası round 2 — resmî alt-kanallar + ek bağımsız kaynaklar)
- **`native-yetenek-indeksi.md` +N / `menu-haritasi.md` +N / ...:** <kısa özet>. Kaynak: 2 resmî alt-kanal (`📹`) + 14 bağımsız/niş kanal (`👤`), <M> video damıtıldı. Video ID'leri/kanal adları repo-dışı özel notta.
### Değişti
- Sürüm <eski> → **<yeni>**. `consistency-check.ps1` PASS.
```

- [ ] **Step 3: `SKILL.md` sürümünü güncelle**

---

### Task 9: Doğrulama (consistency-check + KVKK)

**Files:**
- (okuma) `tools/consistency-check.ps1`

**Interfaces:**
- Consumes: Task 7, 8'in tüm değişiklikleri
- Produces: PASS/FAIL — FAIL ise ilgili task'a geri dön

- [ ] **Step 1: Mekanik denetçiyi çalıştır**

```powershell
cd "C:\Users\Anıl pc\.claude\skills\akinsofterp"
.\tools\consistency-check.ps1
```

- [ ] **Step 2: KVKK/gizlilik + kanal adı/video ID sızıntısı elle son kontrol**

`git diff` ile değişen satırları oku; gerçek firma adı/telefon/adres/fiyat, video linki, video ID'si VEYA kanal adı (round 1'de bu kaçmıştı — CHANGELOG'a özel kanal adı yazılmıştı, jenerik ifadeye çevrilmişti) var mı diye tara.

- [ ] **Step 3: `docs/video-kaynaklari.local.txt`'in commit dışı kaldığını doğrula**

```bash
git status --porcelain | grep video-kaynaklari
```

Beklenen: boş çıktı.

---

### Task 10: Whole-branch final review + Commit

**Files:**
- (yok — yalnız git işlemi)

**Interfaces:**
- Consumes: Task 9'un PASS sonucu
- Produces: yeni commit(ler)

- [ ] **Step 1: Değişen dosyaları stage'le, commit et**

```bash
cd "/c/Users/Anıl pc/.claude/skills/akinsofterp/.worktrees/nis-youtube-damitma-r2" && \
git add reference/*.md CONTRIBUTING.md CHANGELOG.md SKILL.md
git status
git commit -m "$(cat <<'EOF'
feat: niş YouTube içeriği damıtma kampanyası round 2 — resmî alt-kanallar + ek bağımsız kaynaklar

AKINSOFT Eğitim/Global (📹) ve 14 bağımsız/niş kanaldan (👤)
damıtılan native yetenek bilgisi eklendi.
EOF
)"
```

- [ ] **Step 2: Whole-branch review**

`superpowers:requesting-code-review`'ın code-reviewer şablonuyla tüm branch diff'ini incele, Critical/Important bulguları düzelt, tekrar doğrula.

---

## Self-Review Notu

- **Kapsam:** Round 1'in aynı 5 dosyası + gerekirse yeni bölüm; 16 kanal, kapsam sınırı yok.
- **Worktree-dışı durable dosya:** Task 1'den Task 9'a kadar `docs/video-kaynaklari.local.txt` her yerde **mutlak ana-repo yolu** ile referanslandı — round 1'in kayıp nedenini tekrarlamamak için.
- **Tutarlılık:** `📹`/`👤` etiket ayrımı Task 1'den Task 8'e kadar aynı kanal listesiyle sabit tutuldu.
