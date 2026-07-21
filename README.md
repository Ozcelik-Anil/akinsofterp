# akinsofterp — Akınsoft Wolvox 8/9 ERP Uzmanı (Claude Skill)

Bu depo, **Claude'u dünya çapında bir Akınsoft Wolvox 8/9 ERP danışmanına** dönüştüren tek dosyalık bir sistem talimatı (`skill.md`) içerir. Dosyayı herhangi bir Claude yüzeyine yükleyince; MS SQL / Firebird tarafında **salt-okunur, KVKK uyumlu, şema-doğrulamalı** analizler yapan, hem SQL hem Akınsoft arayüz yolları veren bir uzman elde edersiniz.

> Turn Claude into an elite, read-only, KVKK/GDPR-safe Akınsoft Wolvox consultant. Ships as a single `skill.md` (MS SQL **and** Firebird aware).

## ✨ Neler yapar?
- **Yapısal sağlık taraması** — bozuk döviz/para birimi kayıtları, grup kodsuz kartlar, mükerrer barkod, negatif stok.
- **Ticari analiz** — 90+ gün hareketsiz cariler, ölü/yavaş stok, stok devir hızı, dinamik fiyat matrisi.
- **Türkiye uyumluluğu** — e-Dönüşüm (e-Fatura/e-Arşiv/e-İrsaliye/e-Defter) tanıları, KDV/ÖTV/Tevkifat kontrolleri, muhasebe entegrasyonu & mizan.
- **Kullanılmayan özellikler** — kampanya motoru, min/max stok tetikleyicileri, otomatik e-posta/görev planlayıcı.
- **Hızlı kazanımlar** — barkod otomasyonu, terminal bazlı varsayılan depo, 5 dakikalık ayar dokunuşları.

## 🔒 Güvenlik ilkeleri (dosyaya gömülü)
- **Salt-okunur (SELECT-only).** Üretimde asla `UPDATE/DELETE/DROP` çalıştırmaz; düzeltmeleri **inert migration taslağı** (`BEGIN TRAN … ROLLBACK;`) veya **arayüz yolu** olarak sunar.
- **KVKK/GDPR.** Kişisel veriyi (ad, telefon, e-posta, TCKN, VKN, adres) çekmez; kaçınılmazsa sorgu içinde maskeler; agregat veriye odaklanır.
- **Canlı ERP güvenliği.** Kilitlenmeyi önlemek için `READ UNCOMMITTED / NOLOCK`, `db_datareader` login, `SELECT *` yasağı, tercihen yedek kopya üzerinde çalışma.
- **Şema-önce-doğrula.** Kolon uydurmaz; `INFORMATION_SCHEMA` / `RDB$` ile doğrular.
- **Etik/yasal sınırlar.** Lisans kırma, sahte e-fatura, kayıt tahrifi/vergi kaçırma, toplu PII çekimi → reddeder.

## 🚀 Kurulum

> ⚠️ **Referans paketleri her yüzeyde otomatik okunmaz.** `reference/` dosyaları yalnızca **Claude
> Code** kurulumunda ihtiyaç anında okunur. Diğer yüzeylerde onları da elle vermeniz gerekir (aşağıda).

### 1) Claude Code (skill olarak — tam güç, önerilen) 🟢
`.claude/skills/akinsofterp/` klasörüne:
- `skill.md`'yi **`SKILL.md`** adıyla koyun (frontmatter'daki `name`+`description` tetikler),
- **`reference/` klasörünü aynen** yanına kopyalayın (Claude gerektiğinde okur).
SQL/MCP bağlantısı varsa **Mode B (bağlı)** olarak salt-okunur sorguları kendisi çalıştırır. Tüm
referans paketleri (şema, kod sözlüğü, reçete, sorun giderme) devrede → en yüksek yetenek.

### 2) Claude Projects 🟡
1. claude.ai → **Projects** → yeni proje.
2. `skill.md` içeriğini **Project instructions**'a yapıştırın (frontmatter'ı silebilirsiniz).
3. **Referans paketlerini de yükleyin:** `reference/*.md` dosyalarını projenin **knowledge** alanına
   ayrı doküman olarak ekleyin (yoksa Claude yalnızca `skill.md`'deki özet bilgiyle çalışır — yine
   iyidir ama şema/kod detayları eksik kalır).
4. Motor, sürüm ve çalışma yılını ilk mesajda belirtin.

### 3) Custom Instructions 🟠 (kısıtlı)
Karakter limiti vardır ve **dosya ekleyemezsiniz.** `skill.md`'yi (frontmatter'sız) yapıştırın; sığmazsa
**şu çekirdek bölümleri** koruyun: *Pre-Flight Checklist · Universal-vs-This-Install · Read-Only
Contract · Schema-First · CONFIRMED CORE · Output Standards*. Şema/kod detayları için kullanıcı
gerektiğinde `reference/*.md` içeriğini sohbete yapıştırabilir. (Tam güç için 1 veya 2'yi tercih edin.)

## 🧭 İki çalışma modu
- **Mode A — Danışman/Offline:** DB bağlantısı yok. Claude sorguyu üretir, siz çalıştırıp sonucu (maskeli/özet) yapıştırırsınız.
- **Mode B — Bağlı:** Claude Code + shell/SQL client/MCP ile salt-okunur sorguları kendisi çalıştırır.

## 🗂️ Depo içeriği
| Dosya | Açıklama |
|---|---|
| `skill.md` | Ana sistem talimatı (rol, güvenlik, ön-uçuş checklist'i, şema referansı, 5 stratejik sütun, TR uyumluluk, maliyet & devir, Firebird eki, sözlük). |
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
| `reference/ozel-ayarlar.md` | **Özel Ayarlar referansı** — Wolvox davranışını yöneten ayar kataloğu (`Özel Ayarlar > <Modül>`): modül-bazlı *ayar → ne yapar → danışman tuzağı*. `📹` resmî Özel Ayarlar video serisinden (10 çekirdek sekme). Yerleşik **reprice tetiği** (`Fatura Ayarları > Alış Faturası`) burada. "Program neden X / nasıl yaptırırım" sorularının cevabı. |
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

> **Çok-dosyalı skill:** `skill.md` yağsız "beyin/davranış" katmanıdır; `reference/` altındaki
> paketler ihtiyaç anında okunacak doğrulanmış bilgidir. Claude Code skill'inde dosyaları
> `SKILL.md`'nin yanına `reference/` klasörüyle koyun — Claude gerektiğinde okur.

## ⚠️ Sorumluluk reddi
Bu talimat bir **danışmanlık/analiz** aracıdır; resmî mali müşavirlik veya Akınsoft resmî desteği yerine geçmez. Vergi/mevzuat kararlarını daima mali müşavirinize teyit ettirin. Herhangi bir migration taslağını **yedek + test kopyası** üzerinde çalıştırın. Akınsoft ve Wolvox, AKINSOFT'un ticari markalarıdır; bu proje bağımsız, resmî olmayan bir topluluk çalışmasıdır.

## 📄 Lisans
MIT — bkz. `LICENSE`. Katkılara açıktır (PR/issue).
