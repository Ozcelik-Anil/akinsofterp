# Hesaplama Doğrulama — Çalışılmış Örnekler & Kenar Durumlar

> En pahalı hata sınıfı **sessiz sayısal hatadır** (yanlış yuvarlama, KDV yönü, bayat kur, nominal↔reel).
> Bu dosya, skildeki formülleri **somut sayılarla** doğrular ve tuzakları örnekle gösterir. Bir hesap
> önermeden önce ilgili örnekle **kendini kontrol et**. Kaynak formüller: reprice → [sorgu-recetesi §H](sorgu-recetesi.md) ·
> KDV → [turkiye-uyumluluk §1](turkiye-uyumluluk.md) · döviz → [schema-map DOVIZ](schema-map.md) · enflasyon → [turkiye-uyumluluk §7](turkiye-uyumluluk.md).

---

## 1) Reprice — `CEILING(maliyet × çarpan) − 1`
Kural: tam TL'ye **yukarı** yuvarla, **1 çıkar**. Yalnız `hedef > mevcut` ise uygula (asimetri).

| Son alış | Çarpan | maliyet×çarpan | CEILING | −1 = **Hedef** |
|--:|--:|--:|--:|--:|
| 100,00 | 1,50 | 150,00 | 150 | **149** |
| 100,01 | 1,50 | 150,015 | 151 | **150** |
| 99,50 | 1,50 | 149,25 | 150 | **149** |
| 100,00 | 1,00 | 100,00 | 100 | **99** ⚠️ |

- **Kenar durum (çarpan=1):** `CEILING−1` **düşürür** (100→99). Zam amaçlıysa bu istenmez → **asimetri kapısı**
  `hedef > mevcut` bunu engeller: mevcut 100 ise 99>100 yanlış → **DOKUNMA**. Kapı olmadan fiyatı erozyona uğratır.
- **Asimetri örneği:** son alış 100, çarpan 1,50 → hedef 149; mevcut satış **155** → 149>155? Hayır → **DOKUNMA**
  (fiyatı düşürmez). Mevcut **140** → 149>140? Evet → **149'a YÜKSELT**.
- **Yuvarlama tuzağı:** tam sayı sonuçta `CEILING(150)=150`, ondalıkta `CEILING(150,015)=151`. Kuruşlu alış
  fiyatları hedefi 1 TL yukarı zıplatabilir — beklenen budur (yukarı yuvarlama).

## 2) KDV hariç ↔ dahil
`dahil = hariç × (1 + oran)` · `hariç = dahil ÷ (1 + oran)`. Wolvox `STOK_FIYAT.FIYATI` **KDV hariç** tutar.

| İşlem | Giriş | Oran | Doğru sonuç | Yaygın YANLIŞ |
|---|--:|--:|--:|---|
| hariç→dahil | 100 | %20 | 100×1,20 = **120** | — |
| dahil→hariç | 120 | %20 | 120÷1,20 = **100** | 120×0,80 = 96 ❌ |
| dahil→hariç | 118 | %18 | 118÷1,18 = **100** | 118−18 = 100 (tesadüfen doğru, yöntem yanlış) |

- **Oran değişince (raf vs net):** hariç **100 sabit** → %18'de raf 118, %20'de raf **120** (raf artar).
  Rafı **120 sabit** tutmak istiyorsan → yeni hariç = 120÷1,20 = **100** (yani net **düşürülür**). Müşteriye
  "raf mı net mi sabit kalsın?" diye sor — ikisi aynı anda olmaz. → [P2](cozum-desenleri.md).
- **Reprice ile karışım tuzağı:** reprice tabanı **alış KDV hariç** olmalı. `Fatura Ayarları > "alış
  fiyatlarına KDV eklenecek"` açıksa taban KDV **dahil**e kayar → hedef satış şişer. → [ozel-ayarlar §4](ozel-ayarlar.md).

## 3) Döviz → TL
`TL = döviz_tutarı × kur ÷ PARA_ORANI`. `PARA_ORANI` çoğu para için **1**, yüzde-100 kotasyonda **100**.

| Döviz | Tutar | Kur | PARA_ORANI | TL |
|---|--:|--:|--:|--:|
| USD | 10 | 32,50 | 1 | **325,00** |
| EUR | 10 | 35,00 | 1 | **350,00** |
| JPY | 1.000 | 22,00 (100 JPY başına) | 100 | 1000÷100×22 = **220,00** |

- **Yüzde-100 tuzağı:** JPY/bazı para birimleri **100 birim** üzerinden kote edilir; `PARA_ORANI`'yı atlarsan
  100× hata yaparsın (220 yerine 22.000). → [schema-map DOVIZ](schema-map.md).
- **Bayat kur tuzağı:** `DOVIZ.KUR` çoğu kurulumda **güncellenmez**. Canlı TL raporu için **güncel kuru**
  (kullanıcı/TCMB) teyit et; belge-anı maliyeti için **hareketteki** kuru (`STOKHR.DOVIZ_FIYATI`) kullan,
  bugünkü kuru geçmişe uygulama.

## 4) Enflasyon düzeltmesi & reel kâr
Düzeltme katsayısı = **dönem-sonu Yİ-ÜFE ÷ işlem-tarihi Yİ-ÜFE**. Düzeltilmiş değer = tutar × katsayı.

**Sabit kıymet örneği:** alış 100.000 TL (endeks 2000), dönem sonu endeks 3000 → katsayı = 3000/2000 = **1,5**
→ düzeltilmiş değer **150.000**, enflasyon farkı **50.000** (**698** Enflasyon Düzeltme Hesabı'na). → [§7](turkiye-uyumluluk.md).

**Reel kâr tuzağı (en sık):** maliyet 100 (endeks 2000), satış 180 (endeks 3000):
- Nominal kâr = 180 − 100 = **80** (yanıltıcı).
- Düzeltilmiş maliyet = 100 × (3000/2000) = **150**.
- **Reel kâr = 180 − 150 = 30.** Nominal 80'i "kâr" sanmak, enflasyon ortamında **fiktif kârı** vergilendirmek/
  dağıtmak demektir. Reel analizde maliyeti güncel endekse taşı. ⚠️ Kesin katsayı/yöntem **SMMM ile**.

---

## Kullanım refleksi
Sayı üreten her cevaptan önce: **hangi taban** (KDV hariç mi dahil mi), **hangi kur** (güncel mi belge-anı mı),
**yuvarlama yönü** (yukarı + −1), **nominal mi reel mi**? Yanlış varsayım sessizce yanlış rakam üretir —
kullanıcıya **varsayımı yazılı beyan et** ve bu örneklerden biriyle çapraz-kontrol et.
