# Altın Cevap Seti (içerik-doğruluğu eval)

> [dogrulama-testleri.md](dogrulama-testleri.md) skill'in **davranış/disiplinini** test eder (salt-okunur mu,
> PII maskeliyor mu, uydurmuyor mu). Bu dosya **içerik doğruluğunu** test eder: skill soruya **uzman-doğru**
> cevap veriyor mu? Her madde: **Soru → beklenen cevabın anahtar noktaları (puanlama) → sık yapılan YANLIŞ**.
>
> **Kullanım:** Soruyu skill'e sor; cevabı anahtar noktalarla eşle. Eksik/yanlış nokta = boşluk → ilgili
> referansı güçlendir. "YANLIŞ" satırı skill'in **düşmemesi gereken** tuzaktır. ✅=doğrulanmış · 📖=standart · ⚠️=install'da teyit.

---

## A) Şema & sorgu doğruluğu

**G1. "Bir ürünün son alış fiyatını nasıl bulurum?"**
- Anahtar: `STOKHR`'den, `TUTAR_TURU=1` (alış) ✅, `IADE=0` **ve** `DEVIR=0` filtreli ✅, ürün başına
  `ROW_NUMBER() ... ORDER BY TARIHI DESC` (veya MAX tarih) ile son kayıt 📖; fiyat `KPB_FIYATI`/`KPB_GMIK` ⚠️(install teyit);
  KDV hariç/dahil ayrımını belirt. → [cozum-desenleri P8](cozum-desenleri.md).
- YANLIŞ: iade ve devir hareketlerini dahil etmek (son "alış" iade olabilir) → yanlış son alış.

**G2. "STOK_FIYAT'ta satış fiyatı hangisi, KDV dahil mi?"**
- Anahtar: `ALIS_SATIS=2` satış / `=1` alış ✅; `FIYATI` **KDV hariç** tutulur ✅; `KPB_MI` 1=TL/2=döviz ✅;
  `KAR_MARJI` alış→satış türetiminde. → [schema-map](schema-map.md).
- YANLIŞ: `FIYATI`'yı KDV dahil sanmak; ALIS_SATIS'ı ters okumak.

**G3. "Ölü stok (hareketsiz) nasıl listelenir?"**
- Anahtar: `STOK` LEFT JOIN son hareket (`STOKHR` MAX(TARIHI)); N gün/ay eşiği; `AKTIF=1`; bağlı sermaye =
  miktar×maliyet; grupsuz/pasif ayrımı. → [cozum-desenleri P10](cozum-desenleri.md).
- YANLIŞ: yalnız `STOK` bakiyesine bakıp hareket tarihine bakmamak; iadeyi hareket saymak.

**G4. "OZEL_KODU4 ile ürün işaretleyeyim mi?"**
- Anahtar: **`OZEL_KODU4` yoktur** ✅ — Wolvox'ta `OZEL_KODU1/2/3` vardır (dörtüncü yok). Alt-küme için 1/2/3'ten biri.
- YANLIŞ: var sayıp sorgu yazmak (uydurma kolon).

---

## B) Reprice / fiyat mantığı

**G5. "Alışta satış fiyatı otomatik güncellensin, nasıl?"**
- Anahtar: Wolvox **yerleşik** özelliği — `Özel Ayarlar > Fatura Ayarları > Alış Faturası > "satış fiyatları
  oluşturma penceresini göster"` `📹`; kâr marjı Stok Fiyatlar sekmesinde. Harici script şart değil.
  → [kurulum-playbook §2](kurulum-playbook.md).
- YANLIŞ: "SQL trigger yazmak gerekir" demek (yerleşik özelliği atlamak).

**G6. "Sadece zam yönlü, seçili ürünlerde reprice istiyorum (yeni=CEILING(alış×çarpan)−1)."**
- Anahtar: Standart pencere **simetriktir** (düşüşte düşürür) → "yalnız yükselt" için **asimetrik** mantık:
  `WHERE yeni_fiyat > mevcut_fiyat` ✅; alt-küme `OZEL_KODU`='...' ✅; formül `CEILING(son_alış×çarpan)−1`;
  KDV hariç tabanda; **önizleme + inert .sql**, yazma müşteride. → [cozum-desenleri P1](cozum-desenleri.md) · `tools/reprice-preview.ps1`.
- YANLIŞ: koşulsuz UPDATE (düşürür de); KDV tabanını karıştırmak; doğrudan canlıda çalıştırmak.

---

## C) Türkiye uyumluluk (zamana duyarlı — SMMM teyit)

**G7. "Güncel KDV oranları?"**
- Anahtar: **%1 / %10 / %20** ✅; %8→%10 ve %18→%20 değişimi **10.07.2023** (Resmi Gazete 32241) 📖;
  **zamana duyarlı, SMMM ile teyit** uyarısı. → [turkiye-uyumluluk §1](turkiye-uyumluluk.md).
- YANLIŞ: hâlâ %8/%18 vermek; tarih/uyarı vermeden kesin konuşmak.

**G8. "Tevkifatlı hizmette hangi kod/oran?"**
- Anahtar: kod aralığı **601–627** (hizmet 601–616, teslim 617–627) 📖; oran koda göre (ör. 9/10, 7/10, 5/10,
  2/10...); kodu **işleme göre** seç, SMMM teyit. → [turkiye-uyumluluk §2](turkiye-uyumluluk.md).
- YANLIŞ: tek sabit oran vermek; kodu uydurmak.

**G9. "e-Fatura kestim, GİB durumu 1200 — teslim oldu mu?"**
- Anahtar: **1200 = zarf işlendi / GİB kabul ama alıcıya teslim edilmedi** ✅; teslim/başarı **1300** 📖;
  1230=başarısız, 1220=alıcı kutusunda. Beklenen aksiyon: durum akışını izle. → [turkiye-uyumluluk §5](turkiye-uyumluluk.md).
- YANLIŞ: 1200'ü "teslim edildi/tamamlandı" sanmak.

**G10. "Alıcı e-Fatura mükellefi değil, ne keserim?"**
- Anahtar: **e-Arşiv** (e-Fatura değil) ✅; mükellef listesi/VKN ile program senaryoyu seçer;
  cari VKN doğru olmalı. → [turkiye-uyumluluk §4](turkiye-uyumluluk.md) · [kurulum-playbook §1](kurulum-playbook.md).
- YANLIŞ: mükellef olmayana e-Fatura kesmeye çalışmak.

---

## D) Modül derinliği & mimari

**G11. "Genel Muhasebe verisi neden STOK ile aynı sorguda yok?"**
- Anahtar: **ayrı DB** — `..._GMUHASEBE` vs `..._WOLVOX` ✅; her yıl/modül ayrı DB; çapraz-DB birleştirme
  MSSQL'de `DB.dbo.TABLO`, **Firebird'de yok** (uygulama katmanı). → [schema-map §2](schema-map.md).
- YANLIŞ: tek DB varsayıp "tablo yok" demek; modülü "kullanılmıyor" ilan etmek.

**G12. "Üretimde hammadde stoktan düşmüyor, neden?"**
- Anahtar: sarf çoğu kez **üretim emri kapanınca** düşer; kapanmamış emir → hammadde eksilmez, mamul artar;
  reçete birim-katsayı hatası maliyeti saptırır. → [modul-derinlik §1](modul-derinlik.md).
- YANLIŞ: "stok hatası" deyip üretim emri durumunu sormamak.

**G13. "Pazaryeri entegrasyonu tablolarını görüyorum ama tuhaf adlı — güveneyim mi?"**
- Anahtar: çoğu entegrasyon **native Wolvox değil** (3. parti, İngilizce/camelCase) ✅; şema doğrulamadan
  analiz kurma; sahibine kaynağını sor; overselling/komisyon tuzakları. → [modul-derinlik §4](modul-derinlik.md) · [schema-map §1](schema-map.md).
- YANLIŞ: standart-dışı tabloyu native şema gibi kullanmak.

---

## E) DBA / performans

**G14. "Ekstre ekranı çok yavaş, ne yaparım?"**
- Anahtar: önce **ölç** (DMV: en pahalı sorgu / eksik indeks) ✅; muhtemel `CARIHR(CARI_BLKODU,TARIHI)`
  non-clustered indeks önerisi (DMV+ekranla doğrula); istatistik güncelle; **inert DDL taslağı**, yazma
  müşteride, güncellemede düşebilir uyarısı. → [dba-performans §1-2](dba-performans.md).
- YANLIŞ: körlemesine indeks eklemek; tablo/kolon değiştirmeyi önermek; canlıda çalıştırmak.

**G15. "Wolvox 8'den 9'a geçince sorgularım/raporlarım bozulur mu?"**
- Anahtar: şema **büyük ölçüde uyumlu** (kolon adları aynı) ✅; risk UI/menü + native-olmayan eklentiler +
  özel alanlar; **test kopyasında** yükselt, 8/9 rapor karşılaştır. → [dba-performans §5a](dba-performans.md) · [menu-haritasi 8vs9](menu-haritasi.md).
- YANLIŞ: "hiç fark yok" veya "her şey bozulur" gibi uçlar; test/karşılaştırma adımını atlamak.

---

## Puanlama rehberi
- **Tam (2):** tüm anahtar noktalar + doğru güven etiketi + "YANLIŞ" tuzağına düşmemiş.
- **Kısmi (1):** ana nokta doğru ama bir teyit/etiket/uyarı eksik.
- **Başarısız (0):** YANLIŞ tuzağına düşmüş, kolon/kod/oran uydurmuş ya da salt-okunur/PII/SMMM disiplinini ihlal etmiş.
- Herhangi bir maddede tekrarlı 0 → o konunun referans paketini güçlendir (ilgili dosyayı revize et).
