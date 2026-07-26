# Danışmanlık Metodolojisi (paketleri bir işe bağlayan akış)

> Diğer paketler bir **kütüphanedir**; bu dosya onları bir **danışmanlık angajmanı** hâline dizer:
> **Keşif → Değerlendirme → Önceliklendirme → Uygulama → Teslimat → Takip.** Her adımda hangi paketi
> açacağını ve hangi disiplini uygulayacağını söyler. Amaç: rastgele soru-cevap değil, **tekrarlanabilir
> bir yöntem**.
>
> **Değişmez zemin (her adımda geçerli):** salt-okunur varsayılan (Mode A) · yazma yetkisi müşteride ·
> her yapısal işlemden önce **yedek** ([kurulum-playbook §6-C](kurulum-playbook.md)) · PII/KVKK maskele ·
> mali/vergi kararı **SMMM** ile · uydurma yok (kolon/kod/menü → şema-first / UI teyit) · güven etiketi
> (✅/📹/📖/⚠️/≈/👤) ile konuş.

---

## 0) Angajman öncesi — kapsam & mod
- **Mod:** Bağlı DB var mı (Mode B) yoksa danışman/tavsiye mi (Mode A)? Varsayılan **Mode A**.
- **Sürüm/edisyon:** Wolvox 8/9? ERP/KOBİ/Restoran/Otel? Motor MSSQL mi Firebird mi? → [schema-map](schema-map.md) diyalekt.
- **Yetki:** salt-okunur `db_datareader`. Yazma yok. Yedek sorumluluğu müşteride.

## 1) Keşif (röntgen) — "ne var, ne kullanılıyor?"
**Amaç:** kuruluma özel gerçeği çıkar (varsayma). **Aç:** [schema-map §1 röntgen](schema-map.md) + [modul-derinlik keşif refleksi](modul-derinlik.md).
- Hangi **DB'ler** (firma/yıl/modül — `_WOLVOX`/`_GMUHASEBE`/`_IKAYNAK`), hangi tablolar **dolu** (kullanılan modül haritası).
- **Native mi, sonradan mı** eklenmiş tablolar (pazaryeri/senkron katmanı) — sahibine sor.
- Çıktı: *kullanılan/kullanılmayan modül listesi + veri hacmi + motor/sürüm.* PII'ye dokunma.

## 2) Değerlendirme — "ne kadar sağlıklı/verimli?"
**Aç:** [verimlilik-skoru](verimlilik-skoru.md) + `tools/utilization-scorecard.ps1`.
- 5 boyutu ölç (benimseme · veri kalitesi · e-Dönüşüm · süreç · raporlama) → **0-100 skor** + boyut kırılımı.
- Veri-kalitesi taraması: grupsuz/pasif/KDV-hatalı/mükerrer-barkod ([P10/P12/P24](cozum-desenleri.md)), askıda e-belge ([turkiye-uyumluluk §5](turkiye-uyumluluk.md)), ölü stok, yaşlandırma.
- **Boş ama lisanslı modül = fırsat** (servis/İK/üretim/e-ticaret — [modul-derinlik](modul-derinlik.md)).
- Çıktı: kanıtlı **bulgu havuzu** (her bulgu bir P# desenine bağlı).

## 3) Önceliklendirme — "önce ne?"
**Aç:** [rapor-sablonlari](rapor-sablonlari.md) (En Kritik 20 Bulgu + 30-60-90).
- Her bulgu: **kanıt → etki (₺/vergi riski/zaman) → aksiyon → efor → sahip**.
- Sırala: **kanamayı durdur** (vergi riski/askıda e-belge/yanlış VKN) → **temizle** (veri kalitesi) →
  **otomatikleştir** (reprice/oto-görev) → **raporla/yönet**.

## 4) Uygulama — "nasıl yapılır?"
**Aç:** [kurulum-playbook](kurulum-playbook.md) (e-Fatura/reprice/devir/stok-cari/**Kontrol Paneli**) ·
[ozel-ayarlar](ozel-ayarlar.md) (davranış anahtarları) · [perakende-entegrasyon](perakende-entegrasyon.md)
(ÖKC/e-ticaret) · [turkiye-uyumluluk](turkiye-uyumluluk.md) (enflasyon/e-Defter/tevkifat/istisna akışları).
- Menü yolu → [menu-haritasi](menu-haritasi.md) (`📹`/`≈` güveniyle). SQL gerekiyorsa → [sorgu-recetesi](sorgu-recetesi.md) + [cozum-desenleri](cozum-desenleri.md) (asimetrik/KDV-hariç/çapraz-DB/inert migration).
- **Yazma gereken her şey:** önce **yedek**, sonra **inert taslak** (`BEGIN TRAN…ROLLBACK`), müşteri çalıştırır.
- "Program neden X" davranışı → **[ozel-ayarlar](ozel-ayarlar.md)** ilk durak.

## 5) Teslimat — "müşteriye ne bırakılır?"
**Aç:** [rapor-sablonlari](rapor-sablonlari.md).
- **Yönetici Sağlık Raporu** (1 sayfa, skor + en kritik 3) · **20 Bulgu tablosu** (teknik ek) · **30-60-90
  aksiyon planı** · gerekiyorsa **Bulgu Kartı**.
- Yöneticiye iş dili (para/risk/zaman), teknisyene SQL/menü dili. **Sayılar müşteriye/özel nota; repoya değil.**

## 6) Takip — "işe yaradı mı?"
- Düzeltmelerden sonra **yeniden ölç** (aynı skor/sorgular) → skoru raporla (Δ).
- **Düzenli sağlık taraması** (aylık) + otomatik yedek/rapor ([Genel Ayarlar rapor mail](ozel-ayarlar.md)).
- Kendi cevabını **kalite-kontrol** et → [altin-cevap-eval](altin-cevap-eval.md); davranış → [dogrulama-testleri](dogrulama-testleri.md).

---

## Tek-bakış: soru → paket yönlendirme
| Danışman ne yapıyor | Birincil paket |
|---|---|
| Sistemi tanı / modül haritası | schema-map · modul-derinlik |
| Ne kadar verimli / sağlık skoru | verimlilik-skoru · tools/ |
| Bulgu → çözüm deseni | cozum-desenleri (P1–P30) · vaka-bankasi |
| Hazır tanı sorgusu | sorgu-recetesi |
| Enum/kod anlamı | kod-sozlugu |
| Menü yeri | menu-haritasi |
| Davranış/ayar ("neden X") | ozel-ayarlar |
| Sıfırdan kur (e-Fatura/reprice/devir/firma/yedek) | kurulum-playbook |
| Mevzuat (KDV/tevkifat/enflasyon/e-Defter/KVKK) | turkiye-uyumluluk |
| POS/ÖKC/e-ticaret/pazaryeri | perakende-entegrasyon |
| Performans/göç | dba-performans |
| Teslimat/rapor | rapor-sablonlari |
| Semptom→çözüm | sorun-giderme |

> **Altın kural:** her non-trivial soruda önce **tuzağı adlandır → doğru pakete yönlen → P# deseni seç →
> ölçen SELECT → UI/inert taslak → varsayımları beyan et.** Yönlendirmeyi atlamak, naif cevabın (uydurma
> kolon, kaçırılan asimetri, PII sızıntısı) geçtiği yerdir.
