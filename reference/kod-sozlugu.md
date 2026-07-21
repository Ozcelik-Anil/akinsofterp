# Wolvox 8 — Kodlanmış Alan Sözlüğü (smallint enum çözümü)

> Wolvox tablolarındaki `smallint` kod alanlarının anlamı. **Wolvox analizinin yarısı budur** —
> "TİP=2 ne demek" bilmeden doğru rapor çıkmaz.
>
> Bu dosya **jenerik ürün bilgisidir** — gerçek işletme dağılımı/sayısı içermez. Kod→anlam eşlemeleri
> sürüm/edisyon/lokalizasyona ve entegratöre göre değişebilir; `📖` işaretliler için **bir örnek kaydı
> UI'da açıp doğrula** ve kendi kurulumunda **dağılıma bak** (bir alanda tek değer varsa yönü ondan çıkarma).
>
> ### Güven & kaynak
> - **`✅` alan-teyitli:** kayıt/UI ile doğrulanmış (ör. `ALIS_SATIS`, `KPB_MI`, `AKTIF`).
> - **`📹` video-teyitli:** resmî AKINSOFT eğitim videosundaki ekran davranışıyla teyitli (ör. STOK KDV yapısı, döviz kullan).
> - **`📖` standart:** isim/desen kalıbından; UI'da örnek kayıtla doğrula.
> - ⚠️ **Kaynaklama sınırı:** Wolvox'un `smallint` enum kodları (durum/tür alanları) Akınsoft'a **özel dahili
>   konvansiyondur** — kamuya açık resmî tablo halinde belgelenmez; en güvenilir "kaynak" **UI'da bir kaydı
>   açıp değeri görmektir**. Buna karşılık **mevzuat kodları** (KDV oranı, tevkifat 601–627, GİB durum,
>   e-Fatura senaryo) resmî kaynaklıdır → [turkiye-uyumluluk.md](turkiye-uyumluluk.md).

---

## Stok

### `STOKHR.TUTAR_TURU` 📖
`0` = **Çıkış** (satış/sarf/çıkan), `1` = **Giriş** (alış/giren).
> Bakiye yönü zaten `KPB_GMIK` (giren) / `KPB_CMIK` (çıkan) kolonlarında; `TUTAR_TURU` ikincil teyit.

### `STOKHR.IADE` / `STOKHR.DEVIR` 📖
`IADE`: `0`=normal, `1`=iade hareketi. `DEVIR`: `1`=açılış/devir hareketi. Maliyet/son-alış hesabında ikisini de dışla.

### `STOK.AKTIF`
`1`=aktif, `0`=pasif. (Stok'ta `SILINDI` yoktur → `AKTIF` kullan.)

### STOK KDV yapısı — **3 ayrı KDV alanı** 📹
Stok kartı Genel Bilgiler sekmesinde **üç KDV oranı** tutulur: **alış · satış (perakende) · satış (toptan)**
(resmî eğitim videosuyla teyitli). Ayrıca **ÖTV** ve **ÖİV** (özel iletişim vergisi) alanları + **istisna
kodu** ve **tevkifat kodu** (büyüteçten seçilir; programda tanımlı). Kolon adlarını install'da
`INFORMATION_SCHEMA` ile doğrula (`KDV_ORANI` + alış/perakende/toptan varyantları). Oran/kod anlamları →
[turkiye-uyumluluk §1-2](turkiye-uyumluluk.md).
> Rapor tuzağı: "KDV_ORANI" tek alan sanıp alış/satış KDV'sini karıştırmak. Perakende ve toptan KDV farklı olabilir.

### `STOK.DOVIZ_KULLAN` 📹
`0`=yalnız TL, `1`=döviz kullan. **Kapalıysa ürün dövizli satılamaz**; açıkken kartta döviz **birimi**
(USD/EUR/...) seçilir ve fiyat aktarımı birim sorar (resmî videoyla teyitli). `STOK_FIYAT.KPB_MI` ile birlikte okunur.

---

## Fatura

### `FATURA.FATURA_TIPI` 📖 (dikkat)
Akınsoft standardında bu alan alış/satış/iade ayrımı taşır; **ancak bazı kurulumlarda tek değere sabittir**
→ o zaman yön bu alandan okunamaz. Alış/satış yönü için ⇒ `STOKHRK_ISLE` + belge modülü.
**Kendi kurulumunda dağılıma bak; tek değerse yönü buradan çıkarma.**

### `FATURA.FATURA_DURUMU` 📖
Birden çok kod bulunur (normal/kesinleşmiş, iade/kapanmış, iptal vb.). Kod→anlam Akınsoft'a özeldir →
bir örnek faturayı UI'da açıp doğrula; kendi kurulumunda dağılıma bak.

### `FATURA.STOKHRK_ISLE` / `CARIHRK_ISLE`
`1`=hareket işlensin, `0`=işlenmesin. `STOKHRK_ISLE=0` genelde **hizmet/masraf faturası** (stok hareketi yok)
→ mal/hizmet ayrımında güçlü sinyal.

### `FATURA.EFATURA_DURUM` 📖
`1`=**Bekliyor/gönderilmedi** (askıda), `2`=Gönderildi.

### `FATURA.EFATURA_GIB_DURUM` 📖
Sayısal GİB yanıt kodları (ör. kabul/onay, hata vb.). **Tam anlamı entegratör/GİB tarafındadır** —
bir örneği UI'da açıp doğrula.

### `FATURA.EFATURA_SENARYO` 📖
`1`=Temel, `2`=Ticari. (Ticari senaryo = alıcı red/kabul/iade yanıtı verebilir.)

---

## Sipariş

### `SIPARIS.SIPARIS_TURU` 📖
`1`=Satış siparişi, `2`=Alış siparişi (diğer kodlar nadir).

### `SIPARIS.SIPARIS_DURUMU` 📖
Açık/yeni · kısmi/bekliyor · kapandı-teslim · iptal/iade gibi durumları taşır. Kod→anlam Akınsoft'a
özel; teslim akışını UI'da bir siparişte izleyip doğrula.

---

## İrsaliye

### `IRSALIYE.IRSALIYE_TIPI` 📖
Standart: sevk/giriş/çıkış/depo-transfer tipleri (bazı kurulumlarda tek değere sabit). Depo transferi
ayrıca `TRS_KAYNAK_DEPO`/`TRS_HEDEF_DEPO` ile ayrışır.

### `IRSALIYE.IRSALIYE_DURUMU` 📖
`1`=Açık/faturalanmadı, `3`=Faturalandı (diğer nadir). `FATURALANDI` bayrağıyla çapraz kontrol et.

---

## Cari

### `CARIHR.ISLEM_TURU` 📖
Cari hareketin kaynağını kodlar. Tipik anlamlar (kurulumda açıklama/korelasyonla doğrula):
| Kod | Muhtemel anlam |
|---|---|
| `9` | Fatura kaynaklı cari hareket (genelde baskın) |
| `3` | Banka tahsilat/ödeme |
| `6` | Kanal/tahsilat |
| `1` | Manuel / açılış |
| `7` / `8` | Çek/senet cirosu (giriş / çıkış) |
| `12` | Virman/mahsup |
| `13` | Masraf/gider |
> Borç/alacak yönü `ISLEM_TURU`'dan değil, `KPB_BTUT` (borç) / `KPB_ATUT` (alacak) tutarlarından okunur.

---

## Çek / Senet

### `CEK_SENET.EVRAK_TURU` 📖
`1`=**Müşteri Çeki** (bize verilen), `2`=**Müşteri Senedi**, `3`=**Kendi Çekimiz** (verdiğimiz), `4`=**Kendi Senedimiz**.

### `CEK_SENET.EVRAK_DURUMU` 📖
İki basamaklı kod: **onlu basamak evrak tipiyle** örtüşür (1x müşteri çeki, 2x müşteri senedi, 3x kendi
çek, 4x kendi senet), **birim basamak = durum** (portföy/tahsil/ciro/karşılıksız vb.). UI'da bir evrakta izle.

---

## Teklif
### `TEKLIF.TEKLIF_DURUMU` 📖
`1`=Açık/beklemede, `3`=Onaylandı, `6`=Reddedildi/iptal.

---

## Genel bayraklar
| Kolon | `0` | `1` |
|---|---|---|
| `SILINDI` | kayıt geçerli | mantıksal silinmiş → filtrele **(kolon varsa)** |
| `IPTAL` (belge) | geçerli | iptal edilmiş |
| `AKTIF` (kart) | pasif | aktif |
| `KPBDVZ` / `DOVIZ_KULLAN` | yerel (TL) | döviz |
| `KPB_MI` (STOK_FIYAT) | — | `1`=TL, `2`=döviz |
| `ALIS_SATIS` (STOK_FIYAT) | — | `1`=Alış, `2`=Satış |

> ⚠️ **`SILINDI` her tabloda YOK.** Tipik olarak **var →** CARI, CARIHR, FATURA, IRSALIYE, SIPARIS,
> STOKHR, KASAHR, CEK_SENET. **yok →** `STOK` (bunun yerine `AKTIF`), `STOK_FIYAT`, `FATURAHR`,
> `DOVIZ`. Satır (`...HR`) tablosunda `SILINDI` yoksa **başlık tablosundan** (`FATURA.SILINDI/IPTAL`)
> filtrele. Kolonu görmeden `SILINDI` ekleme → sorgu hata verir; emin değilsen `INFORMATION_SCHEMA` ile bak.
