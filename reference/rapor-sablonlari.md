# Danışman Teslimat Şablonları (rapor & sunum)

> Danışmanın müşteriye **bıraktığı somut çıktılar**. Her şablon doldurulabilir iskelettir: `{…}`
> yer tutucularını canlı veriyle doldur. Sayılar **install'a özgüdür** → repoda örnek yok; danışman
> kendi taramasından (`tools/utilization-scorecard.ps1`, [verimlilik-skoru](verimlilik-skoru.md)) doldurur.
>
> **Ton:** yöneticiye iş dilinde (para/risk/zaman), teknisyene SQL/menü diliyle. Bulguları **kanıt +
> etki + aksiyon** üçlüsüyle ver. PII → maskele ([skill privacy doktrini]).

---

## Şablon 1 — Yönetici Sağlık Raporu (1 sayfa)

```
AKINSOFT WOLVOX — SİSTEM SAĞLIK RAPORU
Müşteri: {firma}          Tarih: {tarih}          Hazırlayan: {danışman}
Kapsam: {DB adı / yıl / modüller}     Sürüm: Wolvox {8/9}

VERİMLİ KULLANIM SKORU: {0–100} ({A/B/C/D/F})     Önceki: {skor} ({Δ})
────────────────────────────────────────────────────────────
Boyut                         Ağırlık   Skor    Durum
Modül Benimseme               25%       {..}    {🟢/🟡/🔴}
Veri Kalitesi                 25%       {..}    {…}
e-Dönüşüm Olgunluğu           20%       {..}    {…}
Süreç Otomasyonu              15%       {..}    {…}
Raporlama/Analitik Kullanımı  15%       {..}    {…}
────────────────────────────────────────────────────────────
EN KRİTİK 3 BULGU (para/risk sırasıyla)
1. {bulgu} → etki: {₺/risk} → aksiyon: {tek cümle}
2. …
3. …

HIZLI KAZANIMLAR (bu hafta, düşük efor):  {2–3 madde}
STRATEJİK (bu çeyrek):                      {2–3 madde}
```
> Skor rubriği ve boyut tanımları → [verimlilik-skoru.md](verimlilik-skoru.md). Skoru **elde tutturma**;
> her boyutu ölçen sorgu/kaynağı göster (savunulabilirlik).

---

## Şablon 2 — En Kritik 20 Bulgu Tablosu (teknik ek)

Her satır: **kanıt (sorgu/sayı) → etki → aksiyon → efor → sahip**. Önem'e göre sırala.

```
# | Kategori        | Bulgu                          | Kanıt (sorgu/sayı)         | Etki        | Aksiyon                    | Efor | Öncelik
--|-----------------|--------------------------------|----------------------------|-------------|----------------------------|------|--------
1 | Veri Kalitesi   | {n} grupsuz stok kartı         | P24 sorgusu → {n}          | Rapor/e-tic | Grup ata (toplu)           | S    | Yüksek
2 | e-Dönüşüm       | {n} askıda/hatalı e-belge      | sorgu-recetesi C2 → {n}    | Vergi riski | Hataları çöz + yeniden gön.| S    | Kritik
3 | Nakit           | {n} vadesi geçmiş cari, ₺{tut} | P9 yaşlandırma             | Nakit akışı | Tahsilat + risk notu       | M    | Yüksek
4 | Ölü Stok        | {n} kalem {ay}+ hareketsiz     | P10 → ₺{bağlı sermaye}     | Sermaye     | Kampanya/iade/imha         | M    | Orta
5 | Fiyat           | {n} kartta marj tanımsız       | P4/P17                     | Kâr kaybı   | Marj/oto-fiyat kur (§2)    | S    | Yüksek
… (20'ye kadar; kullanılmayan modüller, mükerrer barkod P12, min/max stok P13, otomasyon boşlukları…)
```
> Bulgu havuzu → [cozum-desenleri.md](cozum-desenleri.md) (P1–P30) ve [vaka-catalogu-100.md] /
> [vaka-bankasi.md]. Efor: S(aat) / M(gün) / L(hafta). Her bulgu bir **desene** (Pn) bağlanmalı.

---

## Şablon 3 — Aksiyon Planı / Yol Haritası (müşteriye)

```
30-60-90 GÜN PLANI — {firma}
[0–30 gün · "durdur kanamayı"]
  □ {kritik bulgu} → {aksiyon} → sahip {kişi} → ölçüt {tamam kriteri}
[30–60 gün · "temizle & otomatikleştir"]
  □ Veri kalitesi düzeltmeleri (grup/barkod/KDV) — hedef skor {..}→{..}
  □ Oto-fiyat / otomasyon kurulumları (kurulum-playbook §2)
[60–90 gün · "raporla & yönet"]
  □ Yönetici rapor seti + düzenli sağlık taraması (aylık)
Yeniden ölçüm tarihi: {tarih}   Hedef skor: {..}
```

---

## Şablon 4 — Bulgu Kartı (tek bulgu, derin)

Bir bulguyu tek başına savunman gerektiğinde:
```
BULGU: {başlık}
Kanıt:     {SQL + dönen sayı/örnek (PII maskeli)}
Neden önemli: {iş etkisi — ₺ / vergi riski / zaman}
Kök neden:  {süreç/ayar/veri}
Aksiyon:    {adım adım — menü yolu (menu-haritasi) + gerekiyorsa SQL taslağı}
Doğrulama:  {düzeltme sonrası hangi sorgu neyi göstermeli}
Sahip / süre: {kişi} / {tarih}
Güven:      {✅ doğrulanmış / 📖 standart / ⚠️ varsayım}
```

---

## Kullanım notları
- **Önce ölç, sonra yaz:** hiçbir sayıyı tahminle doldurma; kaynağını (sorgu/menü) yanına koy.
- **Read-only:** rapor üretimi salt-okunur; hiçbir şablon veri değiştirmez.
- **Genel repo, özel veri:** doldurulmuş rapor **müşteriye/özel nota** gider, repoya **girmez**.
- Sağlık taraması otomasyonu → `tools/utilization-scorecard.ps1`; bulgu→desen eşlemesi →
  [cozum-desenleri.md](cozum-desenleri.md); kurulum düzeltmeleri → [kurulum-playbook.md](kurulum-playbook.md).
