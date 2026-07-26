# Niş YouTube içeriği damıtma kampanyası — Tasarım

**Tarih:** 2026-07-26
**Durum:** Onaylandı

## Bağlam

`native-yetenek-indeksi.md` (v2.19.0) resmî AKINSOFT eğitim kanalından (1081 video tarandı,
~34 damıtıldı) inşa edilmişti; her satır `📹` (resmî video) veya `≈` (genel bilgi, teyitsiz)
etiketiyle işaretli. Kullanıcı YouTube'da Wolvox arayüzlerini gösteren, resmî kanal dışında,
bayi/danışman/kullanıcı kaynaklı **niş içerik** olduğunu fark etti (örn. **Bilcom Bilgisayar**
kanalı) ve bunların da taranıp damıtılmasını istiyor.

Bu içerik resmî değil: versiyon uyumsuzluğu, kişisel yorum/workaround, yanlış terim riski resmî
kanaldan daha yüksek. Aynı `📹` etiketi altına koymak güvenilirlik farkını gizler — okuyucu
(bir sonraki Claude oturumu veya insan katkıcı) kaynağın resmiyetini ayırt edemez.

Makinede `yt-dlp` kurulu; YouTube arama (`ytsearch:`) ve otomatik altyazı/transkript indirme
için kullanılabilir — resmî kanal kampanyasında muhtemelen aynı yöntem izlenmişti.

## Kapsam

1. **Keşif — sabit sayı hedefi yok, doygunluğa yakın tara:** `Bilcom Bilgisayar` kanalı seed
   olarak taranır (kanalın Wolvox içerikli videoları). Ardından `yt-dlp ytsearch` ile çoklu
   sorgu (Wolvox eğitim / kullanım / ipuçları / stok / cari / fatura / POS / muhasebe /
   e-Dönüşüm modülü anlatımı, Wolvox bayi tanıtım vb.) taranır; resmî AKINSOFT kanalı hariç
   tutulur (zaten kapsandı). **Yabancı dilde** (İngilizce vb.) Wolvox içeriği varsa o da dahil
   edilir. Bu bir metadata-only (başlık/kanal/süre/görüntülenme) ucuz tarama turudur — indirme
   yok.
2. **Filtre:** gerçekten arayüz/özellik/menü gösteren videolar tutulur; reklam-only, alakasız,
   çok düşük sinyalli (görüntülenmesiz, konu dışı) videolar elenir. Sabit üst sınır yok —
   bulunan her gerçekten yararlı kaynak damıtılır.
3. **Derin damıtma:** filtreden geçen videoların (mevcutsa) Türkçe/İngilizce oto-altyazı
   transkripti `yt-dlp` ile indirilir, okunur; menü yolu / özellik anlatımı / ipucu / tuzak
   çıkarılır. `schema-map.md` ve `menu-haritasi.md` ile çapraz kontrol edilir — uydurma/sapan
   terim reddedilir, kanonik isimlendirme korunur.
4. **Yeni güven etiketi `👤`:** "bayi/danışman/kullanıcı videosundan damıtıldı, resmî AKINSOFT
   kaynağı değil" anlamına gelir. Etkilenen dosyalarda (`native-yetenek-indeksi.md`,
   `ozel-ayarlar.md`, uygunsa `sorun-giderme.md` / `vaka-catalogu-100.md`) lejant güncellenir;
   `CONTRIBUTING.md`'deki PR doğrulama-etiketi listesine (`✅` canlı, `📹` resmî video, `📖`
   standart) `👤` eklenir.
5. **Yazım:** damıtılan bilgi, tespit edilen dosyalara mevcut format/tablo yapısı korunarak
   eklenir (yeni bölüm değil, mevcut bölümlere satır/madde). Kaynak kanal adı repo-dışı özel
   nota düşülür (önceki kampanyadaki "video ID'leri repo-dışı özel notta" pratiğiyle tutarlı) —
   repoya kanal/video linki commit edilmez, yalnız damıtılmış bilgi + `👤` etiketi girer.
6. **Doğrulama:** `CHANGELOG.md` girişi + SemVer minor bump; `tools\consistency-check.ps1`
   PASS; KVKK taraması — niş videolarda görünebilecek gerçek müşteri/firma verisi asla
   kopyalanmaz, yalnız genel menü yolu/özellik bilgisi alınır.

## Kapsam dışı

- Video transkriptlerinin ham hâlde repoya eklenmesi — yalnız damıtılmış/özetlenmiş bilgi girer.
- Kanal/video linklerinin repoya commit edilmesi — gitignored özel notta kalır.
- `≈`/`📹` etiketli mevcut satırların bu kampanyada saha-teyitine (`✓`) yükseltilmesi — kapsam
  dışı, ayrı bir iş.
- Doygunluğa kadar sonsuz döngü (loop-until-dry) — tek geniş keşif turu + tam damıtma; yeni bir
  tur istenirse ayrı bir kampanya olarak başlatılır.

## Kabul kriteri

- En az `Bilcom Bilgisayar` kanalı taranmış ve değerlendirilmiş (kapsam dışıysa neden belirtilir).
- Bulunan her yararlı kaynaktan çıkarılan bilgi ilgili `reference/*.md` dosyasına `👤` etiketiyle
  işlenmiş; kanonik terim/menü yolu ihlali yok.
- `native-yetenek-indeksi.md` ve/veya `ozel-ayarlar.md` lejantında `👤` tanımlı;
  `CONTRIBUTING.md` PR kuralları listesi güncel.
- `CHANGELOG.md`'de yeni sürüm girişi; `SKILL.md` sürümü = `CHANGELOG.md` en üst.
- `tools\consistency-check.ps1` exit 0 (PASS).
- Repoda gerçek müşteri verisi, kanal/video linki veya video ID'si yok (KVKK + repo-dışı not
  kuralına uygun).
