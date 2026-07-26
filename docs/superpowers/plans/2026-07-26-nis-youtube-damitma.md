# Niş YouTube İçeriği Damıtma Kampanyası — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** YouTube'daki niş (resmî AKINSOFT kanalı dışı — bayi/danışman/kullanıcı) Wolvox içeriğini bulup damıtarak `akinsofterp` skill'inin `reference/` paketlerine yeni `👤` güven etiketiyle işlemek.

**Architecture:** `yt-dlp` ile üç aşamalı huni: (1) ucuz metadata-only keşif (arama + Bilcom Bilgisayar kanal listesi), (2) filtrelenmiş adaylardan otomatik altyazı/transkript indirme, (3) transkript → damıtılmış bilgi → mevcut `reference/*.md` dosyalarına kanonik terimlerle satır ekleme. Kanal/video kimlikleri repoya girmez, yalnız gitignored özel nota düşülür.

**Tech Stack:** `yt-dlp` (CLI, kurulu — v2026.07.04), Bash, mevcut `tools/consistency-check.ps1` (PowerShell).

## Global Constraints

- Repoya ham transkript, video linki veya video ID'si commit edilmez — yalnız damıtılmış bilgi + `👤` etiketi (spec §Kapsam dışı).
- Menü yolu / kolon adı / terim iddiası yalnız `reference/schema-map.md` ve `reference/menu-haritasi.md` ile tutarlıysa yazılır; uydurma/sapan terim reddedilir (CONTRIBUTING.md "Tek gerçek kaynağı" kuralı).
- Gerçek müşteri/firma verisi (video ekranında görünse bile) asla kopyalanmaz — yalnız genel menü/özellik bilgisi (spec §Doğrulama, KVKK).
- Her `reference/*.md` değişikliğinden sonra `tools\consistency-check.ps1` exit 0 olmalı; değilse commit edilmez (CONTRIBUTING.md "ZORUNLU").
- Sürüm: davranış/içerik değişikliği → `CHANGELOG.md` girişi + SemVer bump; `SKILL.md` sürümü `CHANGELOG.md` en üstüyle eşleşmeli.
- Scratch/ara dosyalar yalnız `C:\Users\ANLPC~1\AppData\Local\Temp\claude\...\scratchpad` altında tutulur, repoya girmez.

---

### Task 1: Bilcom Bilgisayar kanal keşfi (seed)

**Files:**
- Create (scratchpad): `bilcom_all.txt`, `bilcom_candidates.txt`
- Create (repo, gitignored): `docs/video-kaynaklari.local.txt`

**Interfaces:**
- Consumes: yok (ilk adım)
- Produces: `docs/video-kaynaklari.local.txt` içinde `## Bilcom Bilgisayar` bölümü — sonraki task'lar bu dosyaya ekleme yapar.

- [ ] **Step 1: Kanalın tüm videolarını listele**

Doğrulanmış komut (kanal URL'si zaten tespit edildi: `UC0bQ5Cri4TCGzjanM_K6ecA`):

```bash
yt-dlp "https://www.youtube.com/channel/UC0bQ5Cri4TCGzjanM_K6ecA/videos" \
  --flat-playlist --print "%(id)s|%(title)s" --playlist-end 500 \
  > "<scratchpad>/bilcom_all.txt" 2>&1
```

Beklenen: dosyada ~111 satır (`id|title` formatında).

- [ ] **Step 2: Wolvox geçen başlıkları filtrele**

```bash
grep -i wolvox "<scratchpad>/bilcom_all.txt" > "<scratchpad>/bilcom_candidates.txt"
wc -l "<scratchpad>/bilcom_candidates.txt"
```

Beklenen: ~42 satır.

- [ ] **Step 3: Başlıkları incele, arayüz/özellik gösteren olmayanları ele**

`bilcom_candidates.txt`'i oku. Şu kriterle tut/ele:
- **Tut:** başlık somut bir modül/işlem adı içeriyor (ör. "Stok Marka Tanımı", "Cari Hesap Ekstre", "Fatura Kesme") — bunlar arayüz/adım anlatımı vaat eder.
- **Ele:** genel tanıtım/reklam başlıkları ("AKINSOFT ile Tanışın" gibi, işlem adımı yok), Wolvox dışı ürün videoları (Bilcom başka yazılımlar da anlatıyor olabilir — başlıkta "Wolvox" geçmeyen zaten Step 2'de elendi, ama "Wolvox Otel/Hotel" gibi farklı bir Wolvox edisyonu ise not düş, elemene gerek yok).

- [ ] **Step 4: Tutulanları özel nota yaz**

`docs/video-kaynaklari.local.txt` dosyasını oluştur (yoksa), şu formatta ekle:

```
## Bilcom Bilgisayar (https://www.youtube.com/channel/UC0bQ5Cri4TCGzjanM_K6ecA)
- <video_id> | <başlık> | durum: bekliyor
- <video_id> | <başlık> | durum: bekliyor
...
```

- [ ] **Step 5: gitignore doğrula ve commit dışı olduğunu teyit et**

```bash
cd "/c/Users/Anıl pc/.claude/skills/akinsofterp/" && git check-ignore -v docs/video-kaynaklari.local.txt
```

Beklenen: `.gitignore:7:*.local.txt` eşleşmesi basılır (dosya ignore ediliyor).

---

### Task 2: Geniş sorgu taraması (diğer niş kanallar + yabancı dil)

**Files:**
- Create (scratchpad): `search_raw.txt`, `search_candidates.txt`
- Modify: `docs/video-kaynaklari.local.txt`

**Interfaces:**
- Consumes: Task 1'in ürettiği `docs/video-kaynaklari.local.txt` (aynı dosyaya ekleme yapılır, kanal başına ayrı bölüm)
- Produces: dosyada `## <Kanal adı>` bölümleri (Bilcom dışındaki her bulunan kanal için biri)

- [ ] **Step 1: Çoklu sorguyla metadata-only tara**

Doğrulanmış komut kalıbı (Step 0'da `ytsearch5:Wolvox eğitim` ile test edildi, "AKINSOFT Wolvox 8 Cari, Fatura, Stok Eğitimi" gibi sonuçlar + "Akinsoft Bayi" kanalını buldu):

```bash
for q in "Wolvox eğitim" "Wolvox kullanım anlatım" "Wolvox ipuçları" \
         "Wolvox stok modülü" "Wolvox cari modülü" "Wolvox fatura kesme" \
         "Wolvox POS hızlı satış" "Wolvox muhasebe entegrasyon" \
         "Wolvox e-Fatura ayarları" "Wolvox bayi tanıtım" \
         "Wolvox ERP tutorial" "Wolvox ERP demo"; do
  yt-dlp "ytsearch15:$q" --flat-playlist \
    --print "%(id)s|%(title)s|%(channel)s|%(channel_url)s" \
    >> "<scratchpad>/search_raw.txt" 2>&1
done
```

Not: son iki sorgu (`Wolvox ERP tutorial`, `Wolvox ERP demo`) İngilizce — yabancı kanal taraması için.

- [ ] **Step 2: Resmî kanalı ve tekrarları ele**

```bash
grep -vi "AKINSOFT Eğitim" "<scratchpad>/search_raw.txt" \
  | sort -t'|' -k1,1 -u > "<scratchpad>/search_candidates.txt"
wc -l "<scratchpad>/search_candidates.txt"
```

(`AKINSOFT Eğitim` = önceki kampanyada taranmış resmî kanal; `sort -u` video-id'ye göre dedupe eder.)

- [ ] **Step 3: Kanala göre grupla, alaka değerlendir**

`search_candidates.txt`'i kanal adına göre grupla (`sort -t'|' -k3,3`), her kanal için Task 1 Step 3'teki aynı tut/ele kriterini uygula. Ayrıca:
- Aynı konuyu anlatan birden çok video varsa (aynı kanal, benzer başlık) → 1 temsilci yeter, gerisini "durum: atlandı (tekrar)" olarak nota düş.
- Çok düşük sinyal (görüntülenme verisi yoksa veya alaka şüpheliyse) → "durum: düşük öncelik" olarak nota düş, yine de listeye ekle (kapsam dışı bırakma, önceliklendir).

- [ ] **Step 4: Özel nota ekle**

Her yeni kanal için `docs/video-kaynaklari.local.txt`'e Task 1 Step 4'teki formatla yeni `## <Kanal adı> (<channel_url>)` bölümü ekle.

---

### Task 3: Final aday listesi ve öncelik sırası

**Files:**
- Modify: `docs/video-kaynaklari.local.txt`

**Interfaces:**
- Consumes: Task 1 + Task 2'nin ürettiği tüm `## <Kanal>` bölümleri
- Produces: dosya başına eklenen `## Öncelik Sırası` bölümü — Task 4 bu sırayı takip eder

- [ ] **Step 1: Tüm "durum: bekliyor" satırlarını gözden geçir, önceliklendir**

Kriter: (a) somut bir işlem/modül adı taşıyan, (b) "düşük öncelik" işaretli olmayan, (c) mevcut `reference/native-yetenek-indeksi.md` ve `reference/ozel-ayarlar.md`'de **zaten `📹`/`≈` ile kapsanmamış** konular öncelikli (dosyaları `Grep` ile tara — aynı özellik zaten varsa yeni video onu doğrulamaktan öte katkı sağlamaz, düşük öncelik).

- [ ] **Step 2: Sıralı listeyi dosyaya yaz**

`docs/video-kaynaklari.local.txt` başına:

```
## Öncelik Sırası
1. <video_id> — <neden öncelikli, 1 cümle>
2. <video_id> — ...
...
```

---

### Task 4: Transkript indirme

**Files:**
- Create (scratchpad): `transcripts/<video_id>.tr.srt` (veya `.en.srt`)

**Interfaces:**
- Consumes: Task 3'ün `## Öncelik Sırası` listesi
- Produces: her video için scratchpad'de bir `.srt` dosyası (varsa) veya "altyazı yok" notu

- [ ] **Step 1: Her öncelikli video için oto-altyazı indir**

```bash
mkdir -p "<scratchpad>/transcripts"
yt-dlp "https://www.youtube.com/watch?v=<video_id>" \
  --write-auto-sub --skip-download --sub-lang tr,en --convert-subs srt \
  -o "<scratchpad>/transcripts/%(id)s.%(ext)s"
```

- [ ] **Step 2: Altyazısız videoları işaretle**

İndirme "no subtitles" ile başarısız olursa, `docs/video-kaynaklari.local.txt`'te o satırı `durum: altyazı yok` yap (damıtma dışı bırak — transkriptsiz doğru içerik çıkarımı güvenilir değil).

- [ ] **Step 3: Başarıyla indirilenleri işaretle**

Başarılı olanları `durum: transkript indirildi` yap.

---

### Task 5: Transkript okuma ve damıtma

**Files:**
- Create (scratchpad): `damitma-taslak.md`

**Interfaces:**
- Consumes: Task 4'ün ürettiği `.srt` dosyaları + `reference/schema-map.md`, `reference/menu-haritasi.md` (kanonik terim kontrolü için)
- Produces: `damitma-taslak.md` — Task 6'nın kaynağı (her satır: hedef dosya, hedef bölüm, önerilen tablo satırı/madde, `👤` etiketi)

- [ ] **Step 1: Her `.srt`'yi oku, işlem adımlarını çıkar**

Her transkript için: hangi menü yoluna gidildi, hangi ayar/alan gösterildi, hangi tuzak/ipucu söylendi. Oto-altyazı Wolvox terimlerini yanlış yazabilir (ör. "vol voks", "kari" gibi) — bağlamdan doğru terimi çıkar.

- [ ] **Step 2: Kanonik terimle çapraz kontrol et**

```bash
grep -i "<çıkarılan terim>" reference/schema-map.md reference/menu-haritasi.md
```

Eşleşme yoksa terimi **ekleme** — ya kanonik karşılığını bul ya da o bulguyu at (spec: "uydurma/sapan terim reddedilir").

- [ ] **Step 3: Taslağa yaz**

`damitma-taslak.md`'ye her bulgu için:

```
### <video_id> — <kaynak kanal>
Hedef dosya: reference/native-yetenek-indeksi.md (§<bölüm no>)
Satır: | <İhtiyaç> | <Native çözüm> | <Yol> | 👤 | <Tuzak/not> |
```

---

### Task 6: `native-yetenek-indeksi.md` ve `ozel-ayarlar.md` güncelleme

**Files:**
- Modify: `reference/native-yetenek-indeksi.md`
- Modify: `reference/ozel-ayarlar.md` (yalnız damıtılan bulgu o dosyanın kapsamındaysa)

**Interfaces:**
- Consumes: `damitma-taslak.md`
- Produces: güncellenmiş `reference/*.md` dosyaları — Task 9'un doğrulayacağı içerik

- [ ] **Step 1: Güven etiketi lejantını güncelle**

`reference/native-yetenek-indeksi.md` başındaki "Güven etiketi" bloğuna (satır ~14-17) yeni satır ekle:

```
> - **`👤`** — bayi/danışman/kullanıcı videosundan damıtıldı, resmî AKINSOFT kaynağı değil; versiyon/terim sapması riski daha yüksek. Canlı ekranla teyit edilince `👤`→`✓`.
```

- [ ] **Step 2: Taslaktaki her satırı ilgili tabloya ekle**

`damitma-taslak.md`'deki her `Hedef dosya`/`Satır` çiftini o dosyanın ilgili `##` bölümündeki tabloya yeni satır olarak ekle (mevcut tablo formatını birebir koru — sütun sırası: İhtiyaç | Native çözüm | Yol | Güv. | Tuzak/not).

- [ ] **Step 3: Aynı özellik zaten `📹`/`≈` ile varsa ekleme, geç**

Eğer taslaktaki bulgu mevcut bir satırla aynı özelliği anlatıyorsa (Task 3 Step 1'de önceliklendirilmiş olsa da örtüşme kalmış olabilir) — yeni satır açma, gerekiyorsa mevcut satırın "Tuzak/not" hücresine ek bilgi ekle, kaynağı belirtme (`+👤 doğrulandı` notu yeterli).

---

### Task 7: `CONTRIBUTING.md` PR etiket listesi güncelleme

**Files:**
- Modify: `CONTRIBUTING.md`

**Interfaces:**
- Consumes: yok
- Produces: güncellenmiş PR kuralları bölümü

- [ ] **Step 1: Etiket listesine `👤` ekle**

`CONTRIBUTING.md`'deki şu satırı:

```
- Şema/kod iddiası ekliyorsan **nasıl doğruladığını** yaz (`✅` canlı, `📹` resmî video, `📖` standart).
```

şuna değiştir:

```
- Şema/kod iddiası ekliyorsan **nasıl doğruladığını** yaz (`✅` canlı, `📹` resmî video, `👤` niş/bayi/danışman videosu, `📖` standart).
```

---

### Task 8: `CHANGELOG.md` girişi + sürüm bump

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `SKILL.md` (frontmatter `version:` alanı)

**Interfaces:**
- Consumes: Task 6'da yapılan gerçek değişiklik özeti (kaç satır, hangi dosyalar, kaç video kaynak)
- Produces: `CHANGELOG.md` en üstü = `SKILL.md` sürümü (consistency-check bunu doğrular)

- [ ] **Step 1: Mevcut sürümü oku**

```bash
grep "^version:" SKILL.md
head -5 CHANGELOG.md
```

- [ ] **Step 2: SemVer minor bump uygula, CHANGELOG girişi yaz**

`CHANGELOG.md`'ye üste (mevcut format — bkz. v2.19.0 girişi) yeni bölüm ekle:

```markdown
## [<yeni_sürüm>] — 2026-07-26
### Eklendi (niş YouTube damıtma kampanyası — resmî kanal dışı kaynaklar)
- **Yeni güven etiketi `👤`** (bayi/danışman/kullanıcı videosu, resmî değil) — `native-yetenek-indeksi.md` lejantına ve `CONTRIBUTING.md` PR kurallarına eklendi.
- **`native-yetenek-indeksi.md` +N satır / `ozel-ayarlar.md` +N satır:** <kısa özet — hangi modüller>. Kaynak: <N> niş kanal (Bilcom Bilgisayar dahil), <M> video damıtıldı. Video ID'leri repo-dışı özel notta.
### Değişti
- Sürüm <eski> → **<yeni>**. `consistency-check.ps1` PASS.
```

- [ ] **Step 3: `SKILL.md` frontmatter sürümünü güncelle**

`SKILL.md` içindeki `version: <eski>` satırını `version: <yeni>` yap.

---

### Task 9: Doğrulama (consistency-check + KVKK)

**Files:**
- (okuma) `tools/consistency-check.ps1`

**Interfaces:**
- Consumes: Task 6, 7, 8'in tüm değişiklikleri
- Produces: PASS/FAIL sonucu — FAIL ise Task 6/8'e geri dön

- [ ] **Step 1: Mekanik denetçiyi çalıştır**

```powershell
cd "C:\Users\Anıl pc\.claude\skills\akinsofterp"
.\tools\consistency-check.ps1
```

Beklenen: exit 0 (PASS). Değilse hatayı oku (kırık link / sürüm uyumsuzluğu / gizlilik / sapan kolon) ve ilgili task'a dönüp düzelt.

- [ ] **Step 2: KVKK/gizlilik elle son kontrol**

`git diff` ile değişen satırları oku; gerçek firma adı/telefon/adres/fiyat, video linki veya video ID'si var mı diye tara. Varsa temizle.

- [ ] **Step 3: `docs/video-kaynaklari.local.txt`'in commit dışı kaldığını doğrula**

```bash
git status --porcelain | grep video-kaynaklari
```

Beklenen: **boş çıktı** (dosya ignore edildiği için `git status`'ta hiç görünmemeli).

---

### Task 10: Commit

**Files:**
- (yok — yalnız git işlemi)

**Interfaces:**
- Consumes: Task 9'un PASS sonucu
- Produces: yeni commit

- [ ] **Step 1: Değişen dosyaları stage'le**

```bash
cd "/c/Users/Anıl pc/.claude/skills/akinsofterp/" && \
git add reference/native-yetenek-indeksi.md reference/ozel-ayarlar.md \
        CONTRIBUTING.md CHANGELOG.md SKILL.md
git status
```

Beklenen: yalnız bu dosyalar staged; `docs/video-kaynaklari.local.txt` listede yok.

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat: niş YouTube içeriği damıtma kampanyası — yeni 👤 güven etiketi

Bilcom Bilgisayar ve diğer bayi/danışman kanallarından damıtılan
native yetenek bilgisi eklendi (resmî kanal dışı kaynak).
EOF
)"
git log --oneline -1
```

---

## Self-Review Notu

- **Spec kapsaması:** Kapsam §1-6 → Task 1-2 (keşif), Task 3 (filtre), Task 4-5 (damıtma), Task 6-7 (etiket+yazım), Task 8-9 (doğrulama). Kabul kriterinin tamamı bir task'a haritalanıyor.
- **Placeholder taraması:** Task 5/6'daki "bulgu sayısı" (N/M) doğası gereği keşif sonucuna bağlı — bu bir placeholder değil, değişken girdi; komutlar ve format şablonları tamdır.
- **Tutarlılık:** `docs/video-kaynaklari.local.txt` adı ve formatı Task 1'den Task 9'a kadar sabit kullanıldı; `👤` etiketi her task'ta aynı sembol.
