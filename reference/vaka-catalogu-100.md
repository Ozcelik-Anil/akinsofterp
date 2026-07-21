# Wolvox 8 — 100 Komplike Danışman Vakası (Vaka Kataloğu)

> **Amaç:** Gerçek kullanıcılardan gelebilecek, **naif bir cevabın hep kaçırdığı bir "tuzak"**
> barındıran 100 komplike soruyu, uzman yaklaşımıyla çözülmüş biçimde toplar. Otomatik-fiyatlama vakasındaki
> tuzaklar (asimetrik / alt-küme / yuvarlama-bitişi / döviz-ayrımı / yerleşik-vs-betik) gibi, her
> vakanın kalbinde bir **kilit içgörü** var. Bu paket skill'in "önce tuzağı gör" refleksini besler.
>
> **Format:** `→ Kilit:` tuzağın özü · `Yöntem:` tablo/kolon + sorgu iskeleti · `UI:` Akınsoft yolu
> · `⚠️` beyan edilmesi gereken varsayım/eşik. Kolon adları [schema-map](schema-map.md)'ten;
> etiketler: ✅ teyitli · 📖 standart-davranış · ⚠️ varsayım. Sayılar install'a göre değişir —
> **kritik sorgudan önce şema/oran kodlarını teyit et**, salt-okunur çalış, PII maskele.

---

## 1) FİYATLANDIRMA & MARJ

**Q1 — "Seçili ürünlerde alış artınca satış otomatik güncellensin, ama düşünce dokunmasın; sonu tavan−1 olsun."**
→ *Kilit:* Asimetrik (sadece-yükselt) + özel bitiş + alt-küme — yerleşik marj bunu yapamaz.
*Yöntem:* Bkz. tam reçete [sorgu-recetesi §H](sorgu-recetesi.md). `hedef=CEILING(sonalış×çarpan)−1`, `WHERE OZEL_KODU3=<kendi özel kodunuz>`, yalnız `hedef>mevcut`. Son alış = `STOKHR` (`TUTAR_TURU=1`, iade/devir hariç). *UI:* toplu güncelleme fiyat log'unu korur. ⚠️ Yerleşik `KAR_MARJI` çoğu kurulumda kullanılmaz; install'da doğrula.

**Q2 — "Aynı ürünü toptancıya, perakendeye ve bayiye farklı fiyatla satıyorum; hangisi hangi listede kayıp/yanlış?"**
→ *Kilit:* Çoklu fiyat listesi `FIYAT_NO` (1/2/3…) ile ayrılır; müşteri hangi listeyi görür `CARI.STOK_FIYATI`'ndadır — sabit `=1` varsayma. *Yöntem:* `STOK_FIYAT` PIVOT `FIYAT_NO` üstünden; eksik liste = `NOT EXISTS`. *UI:* Stok > Fiyatlar sekmesi; Cari > Fiyat listesi ataması. ⚠️ Liste sayısı `STOK_FIYAT_TANIM`'da tanımlı (install'a göre değişir).

**Q3 — "Perakende fiyatım toptan fiyatımın altına düşmüş ürünler var mı?"**
→ *Kilit:* Liste-içi çapraz tutarsızlık; `FIYAT_NO` bazında self-join gerekir. *Yöntem:* `STOK_FIYAT` p (FIYAT_NO=perakende) JOIN t (FIYAT_NO=toptan) ON BLSTKODU, `WHERE p.FIYATI < t.FIYATI` (ikisi de ALIS_SATIS=2, en güncel satır). *UI:* Fiyat analiz raporu. ⚠️ Döviz/TL karışıksa önce ortak para birimine çevir.

**Q4 — "KDV dahil satış fiyatı 'yuvarlak' (ör. 199,90) olsun; sistemde KDV hariç tutuyorum."**
→ *Kilit:* `STOK_FIYAT.FIYATI` **KDV hariç**; hedef KDV **dahil** psikolojik fiyat → geri hesap: `net = hedef_brut / (1+KDV/100)`. *Yöntem:* `net = 199.90/(1+KDV_ORANI/100.0)`, bunu yaz. *UI:* Stok ayarları > "KDV dahil fiyat gir" seçeneği varsa aç. ⚠️ Yuvarlama KDV **dahil** tarafta yapılmalı, hariç tarafta değil.

**Q5 — "Dövizle aldığım ürünlerin TL satış fiyatı güncel kura göre otomatik güncellensin."**
→ *Kilit:* `DOVIZ` tablosu **bayat** → dönüşümde ona güvenme; kuru kullanıcıdan/TCMB'den al. Maliyet ise **belge-anı** kur (`STOKHR.DOVIZ_ALIS`) ile sabit. *Yöntem:* satış TL = döviz_maliyet × güncel_kur × marj. *UI:* Döviz kur güncelleme ekranı. ⚠️ `PARA_ORANI` (JPY vb. 100'lük) uygula.

**Q6 — "Maliyetin altında satılan (zararına) faturalarım oldu mu?"**
→ *Kilit:* Satır bazında satış < o günkü birim maliyet; maliyet **yöntemi** (son alış vs ort.) sonucu değiştirir. *Yöntem:* `FATURAHR.KPB_FIYATI` vs o tarihe kadarki `STOKHR` giriş ort. maliyeti; `WHERE satış < maliyet`. *UI:* Kârlılık raporu. ⚠️ İskonto/kampanya kaynaklı bilinçli zararı ayır.

**Q7 — "Belirli bir markanın tüm ürünlerine tek seferde %10 zam yapmak istiyorum."**
→ *Kilit:* Toplu zam bir **yazma**; UI toplu güncelleme > ham UPDATE (log/eşleme korur). Alt-küme = `MARKASI`. *Yöntem:* önizleme SELECT (`MARKASI=N'X'`), sonra UI *Stok > Toplu Fiyat Güncelleme* veya inert `BEGIN TRAN…ROLLBACK`. *UI:* Toplu Fiyat Güncelleme sihirbazı. ⚠️ Döviz fiyatlıları ayrı ele al.

**Q8 — "Fiyatı en son ne zaman ve kim değiştirdi? Yetkisiz değişiklik oldu mu?"**
→ *Kilit:* Denetim izi `STOK_FIYAT_DEGISIM_LOG` (68K) + `DEGISIM_LOG`. *Yöntem:* log'da `KAYDEDEN`, `KAYIT_TARIHI`, eski/yeni `FIYATI`; kart bazında en son N değişim. *UI:* Stok kartı > Fiyat geçmişi. ⚠️ `KAYDEDEN` kullanıcı adı PII değil; müşteri verisi değil.

---

## 2) STOK & ENVANTER

**Q9 — "Stok bakiyem neden depo raporuyla tutmuyor?"**
→ *Kilit:* Bakiye `STOK`'ta **saklanmaz**, `STOKHR`'den hesaplanır `Σ(KPB_GMIK−KPB_CMIK)`; depo kırılımı `STOK_DEPO`. Fark = silinmiş/iptal hareket, devir eksiği ya da sırasız giriş. *Yöntem:* STOKHR toplamı vs STOK_DEPO toplamı karşılaştır. *UI:* Stok > Depo durumu / sayım. ⚠️ `SILINDI=0` filtrele.

**Q10 — "Negatif stoğa düşen kartlar hangileri, neden?"**
→ *Kilit:* Fiziksel imkânsız → genelde açılış/devir eksik ya da çıkış-önce-giriş. *Yöntem:* [sorgu-recetesi A5](sorgu-recetesi.md); `HAVING Σ(GMIK−CMIK) < 0`. *UI:* Dönem işlemleri > Devir kontrolü. ⚠️ Devir yapılmamış yıl bunu topluca üretir — önce devri doğrula.

**Q11 — "Sermayemi bağlayan ölü stok ne kadar, TL karşılığı ne?"**
→ *Kilit:* "Ölü" bir **eşik** ister (180 gün) + **maliyetle** TL'lenir (adet değil para). *Yöntem:* [A/B1 recipe] 180 gün çıkışsız kartlar × güncel bakiye × birim maliyet. *UI:* Ölü stok raporu. ⚠️ Sezonluk ürünleri ayır; eşiği ve maliyet yöntemini beyan et.

**Q12 — "Minimum stok seviyesinin altına düşen ama sipariş açılmamış ürünler?"**
→ *Kilit:* İki koşul: bakiye < `STOK_DEPO.MIKTAR_MINIMUM` **ve** açık alış siparişi yok. *Yöntem:* STOKHR bakiye JOIN STOK_DEPO min; `NOT EXISTS` açık `SIPARIS` (SIPARIS_TURU=alış, açık durum). *UI:* Min/max uyarı raporu; otomatik sipariş önerisi. ⚠️ Minimum tanımsız kartlar (%çoğu) bu rapordan düşer — önce onları işaretle.

**Q13 — "Barkodu aynı olan farklı ürünler var mı (terminalde yanlış okutma)?"**
→ *Kilit:* Mükerrer barkod = kasada yanlış ürün. *Yöntem:* [A2] `GROUP BY BARKODU HAVING COUNT(*)>1`; ayrıca `STOK_BARKOD` (çoklu barkod) tablosunu da tara. *UI:* Stok > Barkod yönetimi. ⚠️ Boş/whitespace barkodları hariç tut.

**Q14 — "Hangi ürünlerin hiç satış fiyatı yok (kasada elle giriliyor)?"**
→ *Kilit:* `NOT EXISTS` satış fiyatı = operatör hatası kaynağı. *Yöntem:* [A6]. *UI:* Toplu fiyat tanımlama. ⚠️ Hizmet/sarf kartlarını ayrı değerlendir.

**Q15 — "Depolar arası transferlerim doğru mu, kaybolan miktar var mı?"**
→ *Kilit:* Transfer = `IRSALIYE` `TRS_KAYNAK_DEPO`/`TRS_HEDEF_DEPO`; kaynak çıkış = hedef giriş olmalı. *Yöntem:* transfer irsaliyelerinde kaynak−hedef miktar farkı ≠0 olanlar. *UI:* İrsaliye > Depolar arası transfer. ⚠️ Yolda/bekleyen transferi (faturalanmamış) ayır.

**Q16 — "Sayım sonuçlarım sistemle ne kadar uyumsuz?"**
→ *Kilit:* Sayım farkı `STOK_SAYIM_SONUC(_DT)`; sistem bakiye vs sayılan. *Yöntem:* sayım DT ile STOKHR bakiye karşılaştır; büyük sapmalar. *UI:* Stok > Sayım. ⚠️ Sayım sonrası düzeltme fişi kesilmiş mi kontrol et.

**Q17 — "En çok fire/zayi veren ürünlerim?"**
→ *Kilit:* Fire = özel çıkış türü; `STOKHR` çıkışları içinde `TUTAR_TURU`/`ISLEM_TURU` fire kodu ayrımı. *Yöntem:* fire türü çıkışları grupla. *UI:* Sarf/fire fişi. ⚠️ 📖 fire kodunu bir örnek fişte teyit et (`kod-sozlugu`).

**Q18 — "Tedarikçi bazında hangi ürünü kimden daha ucuza alıyorum?"**
→ *Kilit:* `STOK_TEDARIKCI` (23K) eşleşmeleri + gerçek alış (`STOKHR`/alış faturası). *Yöntem:* ürün başına tedarikçi × son alış fiyatı min. *UI:* Stok > Tedarikçiler. ⚠️ Alış tarihleri farklıysa kur/enflasyon etkisini not et.

**Q19 — "Aynı ürünün mükerrer kartı açılmış mı (farklı stok kodu, aynı isim/barkod)?"**
→ *Kilit:* Mükerrer kart = bölünmüş stok/rapor. *Yöntem:* `STOK_ADI`/`BARKODU` normalize edilip `GROUP BY … HAVING COUNT(*)>1`. *UI:* Kart birleştirme. ⚠️ Varyant (beden/renk) kartlarını mükerrerle karıştırma.

**Q20 — "Stok devir hızım grup bazında ne, hangi grup yavaş dönüyor?"**
→ *Kilit:* Devir = dönem çıkış / ortalama stok; kaba yaklaşım [B4]. *Yöntem:* grup başına 12 ay `Σ KPB_CMIK` / güncel bakiye. *UI:* Devir hızı raporu. ⚠️ Ortalama stok yerine güncel bakiye kullanınca yanılma payını beyan et.

---

## 3) MALİYET & KÂRLILIK

**Q21 — "Gerçek brüt kârım ne — ürün, grup ve müşteri kırılımında?"**
→ *Kilit:* Kâr = satış(KDV hariç) − satılan miktar × **birim maliyet**; maliyetsiz kâr yanıltıcı. *Yöntem:* `FATURAHR.KPB_TOPLAM_TUTAR` − (MIKTARI × maliyet); maliyet = `STOKHR` giriş ort./son alış. *UI:* Kârlılık raporu. ⚠️ Maliyet yöntemini + tarih aralığını + kur kaynağını yaz.

**Q22 — "Maliyet yöntemim ortalama mı FIFO mu, sonucu nasıl değiştiriyor?"**
→ *Kilit:* Yöntem ayarında; ort. vs FIFO aynı üründe farklı kâr verir. *Yöntem:* iki yöntemi paralel hesaplayıp farkı göster. *UI:* Stok ayarları > Maliyet yöntemi. ⚠️ 📖 kurulumun ayarını teyit et; resmi (SMMM) maliyetle çelişebilir.

**Q23 — "Ek maliyetleri (nakliye, gümrük) ürün maliyetine yansıtıyor muyum?"**
→ *Kilit:* Ek maliyet `EK_MALIYET_KPB`/masraf dağıtımı; yansıtılmazsa kâr şişer. *Yöntem:* alış faturalarında ek maliyet dağıtımı yapılmış mı kontrol. *UI:* Fatura > Masraf dağıtımı. ⚠️ Dağıtım anahtarını (miktar/tutar) beyan et.

**Q24 — "Döviz alışlı üründe kur farkı kârımı nasıl etkiliyor?"**
→ *Kilit:* Maliyeti **belge-anı** kurla (`DOVIZ_ALIS`) sabitle, güncel kurla değil; aksi halde kur farkı kâra karışır. *Yöntem:* maliyet = döviz_tutar × belge_kur. *UI:* Döviz fatura. ⚠️ Kur farkını ayrı kalem raporla.

**Q25 — "İskontolar sonrası gerçekte kaça satıyorum (net satış)?"**
→ *Kilit:* Liste fiyatı ≠ net; satır + belge iskontoları düşülmeli. *Yöntem:* `FATURAHR` net tutar (iskonto sonrası) / miktar. *UI:* İskonto analizi. ⚠️ Kademeli iskonto (ISK1..3) hepsini uygula.

**Q26 — "Kampanyalı satışlarım toplam kârı ne kadar aşağı çekti?"**
→ *Kilit:* Kampanya satırlarını ayırt et (iskonto>eşik ya da kampanya kodu). *Yöntem:* kampanyalı vs normal kâr karşılaştır. *UI:* Kampanya modülü (kullanılmıyorsa iskonto oranından türet). ⚠️ Kampanya bayrağı yoksa 📖 heuristik kullandığını belirt.

**Q27 — "Personel/pazarlamacı bazında kârlılık ve prim tabanı ne?"**
→ *Kilit:* `STOK.PAZARLAMACI_KAR_ORANI` + faturada pazarlamacı alanı; prim kârdan mı cirodan mı? *Yöntem:* pazarlamacı × (ciro, kâr). *UI:* Pazarlamacı raporu. ⚠️ Prim tabanını (ciro/kâr) kullanıcıya sor.

**Q28 — "Hangi müşteriye satış aslında zararına (maliyet + vade maliyeti)?"**
→ *Kilit:* Sadece ürün maliyeti değil, **vade finansman maliyeti** de var; geç ödeyen müşteri kârı yer. *Yöntem:* brüt kâr − (ortalama tahsil gün × günlük finansman maliyeti). *UI:* Cari kârlılık + yaşlandırma. ⚠️ Finansman oranını kullanıcıdan al.

---

## 4) CARİ, ALACAK & RİSK

**Q29 — "Toplam alacağım ne, kaç müşteri borçlu, en riskliler kim?"**
→ *Kilit:* Cari bakiye = `Σ(CARIHR.KPB_BTUT−KPB_ATUT)`; PII maskeli sun. *Yöntem:* [B2] + bakiye DESC, unvan maskeli. *UI:* Cari > Bakiye/ekstre. ⚠️ Bakiye>0 = bize borçlu yönünü teyit et; PII maskele.

**Q30 — "Vadesi geçmiş alacaklarım — 30/60/90+ gün yaşlandırması?"**
→ *Kilit:* Yaşlandırma `CARIHR.VADESI` bazlı kova; açık kalemleri (tahsil edilmemiş) eşleştir. *Yöntem:* açık borç kalemleri × (bugün−VADESI) → 0-30/31-60/61-90/90+ kovaları. *UI:* Cari > Yaşlandırma raporu; `CARI_YASL_DONEM`. ⚠️ Kısmi tahsilatı FIFO eşleştir.

**Q31 — "Kredi limitini aşan müşteriler var mı?"**
→ *Kilit:* Bakiye > `CARI` risk/limit alanı; `RISKLI_MUSTERI` bayrağı. *Yöntem:* bakiye vs limit; aşanlar. *UI:* Cari > Risk kontrolü. ⚠️ 📖 limit kolon adını teyit et (`RISK_LIMITI` vb.).

**Q32 — "Çift yönlü cari (hem alıyorum hem satıyorum) net bakiyesi doğru mu?"**
→ *Kilit:* Aynı cari hem müşteri hem tedarikçi → borç/alacak netleşmeli, iki ayrı bakiye değil. *Yöntem:* tek `BLKODU` üstünden net; mahsup edilmemişse uyar. *UI:* Cari mahsup/virman. ⚠️ Farklı şube/cari kodu aynı firmaysa manuel eşleştir.

**Q33 — "90+ gündür hiç hareket görmeyen (uyuyan) müşteriler — geri kazanım listesi?"**
→ *Kilit:* Pazarlama fırsatı; son hareket `MAX(CARIHR.TARIHI)`. *Yöntem:* [pillar C] maskeli unvan + son hareket. *UI:* CRM/hatırlatma. ⚠️ Pasif/kapanmış carileri ayır; PII maskele, toplu pazarlama KVKK.

**Q34 — "Tahsilat performansım: ortalama tahsil süresi (DSO) ne?"**
→ *Kilit:* DSO = alacak / günlük ciro; trend önemli. *Yöntem:* dönem alacak ort. / (ciro/gün). *UI:* Finans raporu. ⚠️ Peşin satışları çıkararak vadeli DSO hesapla.

**Q35 — "Müşteri bazında en çok iade/iptal yapan kim (sorunlu müşteri)?"**
→ *Kilit:* İade faturaları (`FATURA_TIPI` iade) ve iptaller `IPTAL=1` cari kırılımı. *Yöntem:* iade adet/tutar / toplam ciro oranı yüksek cariler. *UI:* İade analizi. ⚠️ İade tipini teyit et; mevsimsel iadeyi ayır.

**Q36 — "Hiç fatura kesmediğim ama kartı açık cariler (ölü kart)?"**
→ *Kilit:* `NOT EXISTS` FATURA + `NOT EXISTS` CARIHR → boş kart temizlik adayı. *Yöntem:* CARI LEFT JOIN hareketler, hepsi boş. *UI:* Cari temizlik. ⚠️ Potansiyel müşteri (`POTANSIYELMUSTERIDURUMU`) olabilir — silmeden önce ayır.

**Q37 — "Sektör/bölge bazında ciro ve alacak dağılımım?"**
→ *Kilit:* Agregat kırılım `CARI.SEKTOR`/`GRUBU` — PII'siz. *Yöntem:* sektör × (ciro, alacak). *UI:* Cari grup raporu. ⚠️ Grupsuz cariler kırılımı bozar — önce grupla.

---

## 5) FATURA & SATIŞ ANALİZİ

**Q38 — "Aylık/ürün bazında satış trendim ne, hangi ay zirve?"**
→ *Kilit:* Başlık toplamı (`TOPLAM_GENEL_KPB`) mı satır mı? Başlık daha güvenli; satış tipini filtrele. *Yöntem:* `FATURA` `SILINDI=0 IPTAL=0 FATURA_TIPI=satış` ay bazında. *UI:* Satış raporu. ⚠️ İade/iptali çıkar; döviz faturayı TL'ye çevir.

**Q39 — "Sepet analizi: birlikte satılan ürünler (çapraz satış)?"**
→ *Kilit:* Aynı `BLFTKODU` içindeki ürün çiftleri → market-basket. *Yöntem:* FATURAHR self-join aynı fatura, ürün çiftleri frekans. *UI:* Yok → SQL. ⚠️ Büyük tabloda maliyetli; tarih aralığı sınırla, NOLOCK.

**Q40 — "Kesilmemiş/taslak kalan faturalar veya numara boşluğu var mı?"**
→ *Kilit:* Fatura numara sırası kırılması = denetim riski. *Yöntem:* `FATURA_NO` sıralı fark; eksik aralıklar. *UI:* Fatura listesi. ⚠️ Seri bazında (her seri kendi sırası) değerlendir.

**Q41 — "Peşin vs vadeli satış oranım, tahsilat riski?"**
→ *Kilit:* Ödeme tipi/vade `FATURA.VADESI` vs tarih; peşin= vade≈tarih. *Yöntem:* vadeli oran, ortalama vade gün. *UI:* Satış özeti. ⚠️ Kısmi peşin/vadeli karışığı ayır.

**Q42 — "En kârlı 20 ürün mü ciroyu taşıyor (Pareto/ABC analizi)?"**
→ *Kilit:* ABC: kümülatif ciro %80'i hangi ürünler. *Yöntem:* ürün ciro DESC, kümülatif %. *UI:* ABC analiz raporu. ⚠️ Ciro mu kâr mı bazlı ABC — ikisini de sun.

**Q43 — "İskonto oranım zamanla arttı mı (marj erozyonu)?"**
→ *Kilit:* Ortalama iskonto trendi = gizli kâr kaybı. *Yöntem:* ay bazında `Σ iskonto / Σ ara toplam`. *UI:* İskonto raporu. ⚠️ Ürün karması değişimini karıştırma.

**Q44 — "Fatura başlığı toplamı ile satır toplamları tutuyor mu (veri bütünlüğü)?"**
→ *Kilit:* `TOPLAM_*_KPB` (başlık) vs `Σ FATURAHR` sapması = bozuk belge. *Yöntem:* başlık−satır farkı >0,01. *UI:* Fatura düzeltme. ⚠️ KDV/iskonto yuvarlama toleransı bırak.

**Q45 — "Hangi kullanıcı/terminal en çok fatura düzeltiyor/siliyor (iç kontrol)?"**
→ *Kilit:* `DEGISIM_LOG` + `IPTAL`/`SILINDI` + `KAYDEDEN/DEGISTIREN`. *Yöntem:* kullanıcı başına iptal/düzeltme sayısı. *UI:* Kullanıcı işlem logu. ⚠️ Kullanıcı adı PII değil; suçlama değil kontrol amaçlı.

---

## 6) e-DÖNÜŞÜM

**Q46 — "GİB'e gitmemiş, askıda kalmış e-Faturalarım hangileri?"**
→ *Kilit:* e-belge durumu **ayrı tabloda değil**, `FATURA.EFATURA_DURUM`/`EFATURA_GIB_DURUM` başlıkta. *Yöntem:* [C1] `EFATURA_KULLAN=1 AND (EFATURA_DURUM=1 OR GIB_DURUM boş)`. *UI:* e-Dönüşüm > Gönderilecekler. ⚠️ 📖 GIB kod anlamını (41/60) bir örnekte teyit.

**Q47 — "e-Fatura mükellefi olduğu halde kağıt/e-Arşiv kestiğim cari var mı?"**
→ *Kilit:* Mükellef listesi vs kesilen belge tipi uyumsuzluğu = red riski. *Yöntem:* `CARI.EFATURA_KULLAN=1` ama faturası e-Arşiv senaryosunda. *UI:* Mükellef sorgulama/güncelleme. ⚠️ GİB mükellef listesini güncel çek.

**Q48 — "Otomatik gönderim hatası alan faturalar ve sebepleri?"**
→ *Kilit:* `OTO_GONDERIM_HATA` metni + entegratör. *Yöntem:* [C2] hata metnine göre grupla (sertifika/imza/şema). *UI:* e-Dönüşüm > Hatalı belgeler. ⚠️ Sertifika süresi/imzayı ayrı kontrol.

**Q49 — "e-İrsaliyelerim faturaya dönüşmüş mü, açık kalan var mı?"**
→ *Kilit:* `IRSALIYE.FATURALANDI` + `EIRSALIYE_DURUM`; sevk var fatura yok = eksik gelir. *Yöntem:* `FATURALANDI=0` ve eski tarihli e-irsaliyeler. *UI:* İrsaliye > Faturalanacaklar. ⚠️ İade/transfer irsaliyesini ayır.

**Q50 — "ETTN/UUID başlık var ama e-belge eşleşmiyor (veya tersi)?"**
→ *Kilit:* `EFATURA_GUID`/`EFATURA_FATURANO` boş ama `EFATURA_KULLAN=1`. *Yöntem:* eşleşmeyen başlıklar. *UI:* e-belge eşleştirme (`EFATURA_ESLESTIRME`). ⚠️ Entegratör tarafı gecikmesi olabilir; tarih penceresi ver.

**Q51 — "e-Arşiv raporumu zamanında iletiyor muyum (GİB süre riski)?"**
→ *Kilit:* e-Arşiv günlük rapor süresi; geciken belge cezai risk. *Yöntem:* e-Arşiv belgelerinde rapor durumu/gün. *UI:* e-Arşiv > Raporlama. ⚠️ 📖 rapor durum alanını teyit.

**Q52 — "e-Deftere aktarılmayan dönem/fiş var mı?"**
→ *Kilit:* e-Defter muhasebe DB'sinde (`_GMUHASEBE`); `_WOLVOX`'ta arama. *Yöntem:* dönem yevmiye vs e-defter beratı. *UI:* Genel Muhasebe > e-Defter. ⚠️ Çapraz-DB; muhasebe SMMM'de olabilir.

**Q53 — "Tevkifatlı e-Faturalarımda tevkifat kodu/oranı eksik olan?"**
→ *Kilit:* Eksik tevkifat kodu = e-Fatura reddi. *Yöntem:* `FATURAHR.TEVKIFAT_KODU` boş ama tevkifatlı hizmet/mal. *UI:* Fatura > Tevkifat. ⚠️ Tevkifat kod/oran tablosunu mevzuatla teyit.

**Q54 — "İptal ettiğim e-Faturaların iptali GİB'e işlenmiş mi?"**
→ *Kilit:* Yerel `IPTAL=1` ama GİB durumu hâlâ geçerli olabilir. *Yöntem:* `IPTAL=1` + `EFATURA_GIB_DURUM` iptal-değil olanlar. *UI:* e-Fatura iptal/itiraz. ⚠️ e-Arşiv iptali ≠ e-Fatura iptali süreç farkı.

---

## 7) KDV / ÖTV / TEVKİFAT

**Q55 — "Eski KDV oranı (8/18) taşıyan aktif kartlar kaldı mı?"**
→ *Kilit:* Oran geçişi (8→10, 18→20) sonrası eski oranlı kart = yanlış fatura. *Yöntem:* [A4] `KDV_ORANI IN (8,18)`. *UI:* Toplu KDV güncelleme. ⚠️ **Asla otomatik değiştirme** — mevzuat + SMMM onayı.

**Q56 — "Alış KDV oranı ile satış KDV oranı farklı olan ürünler (hatalı kurgu)?"**
→ *Kilit:* `KDV_ORANI` vs `KDV_ORANI_ALIS` tutarsızlığı. *Yöntem:* iki alan farklı olanlar. *UI:* Stok > Vergi. ⚠️ Bazı ürünlerde yasal olarak farklı olabilir — kör düzeltme yapma.

**Q57 — "KDV beyanı için dönem hesaplanan/indirilecek KDV özetim?"**
→ *Kilit:* Satış KDV (`FATURA.HESAPLANAN_KDV_KPB`) − alış KDV; `FATURA_KDV` yan tablosu. *Yöntem:* dönem satış vs alış KDV toplamı. *UI:* KDV raporu. ⚠️ Tevkifat/istisna kalemleri ayrı; resmi beyan SMMM'de.

**Q58 — "ÖTV'li ürünlerimin ÖTV kurgusu doğru mu?"**
→ *Kilit:* `OTV_KULLAN`/`OTV_ORANI`/`OTV_TUTARI`; ÖTV matrahı KDV'den önce. *Yöntem:* ÖTV'li kartlarda oran/tutar tutarlılığı. *UI:* Stok > ÖTV. ⚠️ ÖTV maktu mu nispi mi ayrımı.

**Q59 — "Tevkifatlı satışlarımın oran/kod dağılımı ve eksikleri?"**
→ *Kilit:* `FATURA.TEVKIFAT_ORANI_1/2` + `FATURAHR.TEVKIFAT_KODU`; `FATURA_TEVKIFAT_IADE`. *Yöntem:* tevkifat kod × tutar; kodsuz olanlar. *UI:* Tevkifat raporu. ⚠️ Kod-oran eşlemesini güncel tebliğle teyit.

**Q60 — "İhraç kayıtlı satışlarım doğru işaretli mi?"**
→ *Kilit:* `FATURA.IHRAC_KAYDI`; KDV tahsil edilmez ama beyan farklı. *Yöntem:* ihraç kayıtlı faturalarda KDV işlenişi. *UI:* Fatura > İhraç kaydı. ⚠️ İstisna kodu (`ISTISNA_KODU`) uyumu.

**Q61 — "İstisna (KDV'siz) satışlarım hangi istisna koduyla, doğru mu?"**
→ *Kilit:* `FATURAHR.ISTISNA_KODU` boş/yanlışsa e-Fatura reddi. *Yöntem:* KDV=0 satırlarda istisna kodu kontrolü. *UI:* Fatura > İstisna. ⚠️ Kod listesini GİB ile teyit.

---

## 8) GENEL MUHASEBE & MİZAN (Çapraz-DB)

**Q62 — "Muhasebeleşmemiş fatura/kasa/banka fişlerim var mı (eksik mizan)?"**
→ *Kilit:* Muhasebe **ayrı DB** `_GMUHASEBE`; entegrasyon köprüsü `GM_ENTEGRASYON`/`MUHKODU_*`. *Yöntem:* `_WOLVOX` belgeleri vs `_GMUHASEBE.YEVMIYE` eşleşmesi; aktarılmayanlar. *UI:* Genel Muhasebe > Muhasebeleştirme. ⚠️ Çapraz-DB üç-parçalı ad; login iki DB'de datareader.

**Q63 — "Mizanımda ters bakiyeli hesaplar var mı?"**
→ *Kilit:* `_GMUHASEBE.HESAP_PLANI` + `YEVMIYEHR`; normalde borç/alacak yönü. *Yöntem:* hesap bakiyesi beklenen yöne aykırı olanlar. *UI:* Mizan/Kesin Mizan. ⚠️ 📖 hesap tipi-yön kuralını teyit.

**Q64 — "Entegrasyon şablonu eksik cari/stok grupları (muhasebe kodu boş)?"**
→ *Kilit:* `MUH_ALIS`/muhasebe kodu boş kartlar → muhasebeleşmez. *Yöntem:* grup bazında muhasebe kodu boş kart sayısı. *UI:* Entegrasyon şablonları. ⚠️ Hangi belge tipinin hangi hesaba gittiğini teyit.

**Q65 — "Yıllar arası (2022→2023) ciro/kâr trendim ne?"**
→ *Kilit:* Her yıl **ayrı DB** → çapraz-DB `UNION ALL`; nominal TL enflasyonla yanıltıcı. *Yöntem:* [skill Cross-DB]; `sys.databases LIKE 'WOLVOX%'` keşif. *UI:* Yok → SQL. ⚠️ Reel/döviz bazına çevir; firma kodu (001/002) karıştırma.

**Q66 — "Kasa/banka defterim muhasebe defteriyle tutuyor mu?"**
→ *Kilit:* `KASAHR`/`BANKAHR` toplamları vs muhasebe kasa/banka hesabı (`_GMUHASEBE`). *Yöntem:* çapraz-DB bakiye mutabakatı. *UI:* Mutabakat raporu. ⚠️ Zaman aşımı/aktarım gecikmesi.

**Q67 — "Cari bakiyem muhasebedeki 120/320 hesabıyla uyuşuyor mu?"**
→ *Kilit:* `CARIHR` bakiye vs `_GMUHASEBE` 120/320 hesap bakiyesi. *Yöntem:* cari-muhasebe köprü kodu üstünden mutabakat. *UI:* Cari-Muhasebe mutabakat. ⚠️ Muhasebe SMMM'de tutuluyorsa gecikmeli olabilir.

**Q68 — "Açılış devri eksik olan hesaplar (yıl geçişi hatası)?"**
→ *Kilit:* Devir yapılmazsa açılış bakiyeleri sıfır görünür. *Yöntem:* yeni yıl DB'sinde `DEVIR=1` hareket yok ama önceki yıl bakiyesi var. *UI:* Dönem İşlemleri > Devir. ⚠️ Önce devri doğrula, sonra bakiye analizi.

---

## 9) SİPARİŞ, TEDARİK & DEPO

**Q69 — "Açık (teslim edilmemiş) müşteri siparişlerim ve geciken teslimatlar?"**
→ *Kilit:* `SIPARIS.SIPARIS_DURUMU` açık + `TESLIM_TARIHI` geçmiş. *Yöntem:* açık satış siparişleri, teslim tarihi < bugün. *UI:* Sipariş > Açık siparişler. ⚠️ 📖 durum kodlarını (`kod-sozlugu`) teyit; kısmi teslim ayrı.

**Q70 — "Stok bloke eden ama beklemedeki siparişler sermayemi kilitliyor mu?"**
→ *Kilit:* `SIPARIS.STOK_BLOKE`/`STOK_BLOKE` tablosu → satılabilir stok azalır. *Yöntem:* bloke miktar × maliyet, eski bloke siparişler. *UI:* Sipariş > Bloke yönetimi. ⚠️ İptal edilmesi gereken ölü blokeler.

**Q71 — "Sipariş verdiğim ama gelmeyen (açık alış siparişi) ürünler?"**
→ *Kilit:* `SIPARIS_TURU=alış` açık; teslim gecikmesi = stok riski. *Yöntem:* açık alış siparişleri, tedarikçi bazında gecikme. *UI:* Alış sipariş takibi. ⚠️ Kısmi teslim `SIPARIS_TESLIM_DETAY` ile netleştir.

**Q72 — "Tekliflerimin siparişe/faturaya dönüşüm oranı (satış hunisi)?"**
→ *Kilit:* `TEKLIF`→`SIPARIS`→`FATURA` zinciri; `TEKLIF_NO` izi. *Yöntem:* teklif sayısı vs kazanılan (dönüşen). *UI:* Teklif > Durum. ⚠️ Teklif modülü az kullanılıyorsa örneklem küçük — belirt.

**Q73 — "Hangi ürünlerde tedarik süresi uzun, güvenlik stoğu yetersiz?"**
→ *Kilit:* Tedarik süresi = sipariş→teslim gün; güvenlik stoğu buna göre. *Yöntem:* alış sipariş tarihi vs giriş tarihi ort.; min stok ile kıyas. *UI:* Tedarik analizi. ⚠️ Tedarikçi bazında ayrış.

**Q74 — "Depo bazında yanlış terminal→depo eşlemesi var mı (negatif/yanlış depo)?"**
→ *Kilit:* Terminal varsayılan deposu yanlışsa hareket yanlış depoya düşer. *Yöntem:* `STOK_DEPO`/`STOKHR.DEPO_ADI` beklenmedik depo. *UI:* Terminal/kullanıcı ayarları. ⚠️ Çoklu depo kurulumu teyit.

**Q75 — "Konsinye/emanet stoğum kendi stoğumla karışıyor mu?"**
→ *Kilit:* Konsinye ayrı depo/özel işaret olmalı; karışırsa mülkiyet hatası. *Yöntem:* konsinye depo/özel kod ayrımı. *UI:* Depo tanımları. ⚠️ 📖 konsinye kurgusunu (depo mi özel kod mu) teyit.

**Q76 — "Min/max seviyesine göre otomatik sipariş önerisi çıkar."**
→ *Kilit:* Öneri = (max − mevcut) açık sipariş düşülerek; min tanımsız kartlar dışarıda. *Yöntem:* bakiye < min olan kartlar için `max−bakiye−açıksipariş`. *UI:* Otomatik sipariş. ⚠️ Önce min/max tanımlı mı — çoğu boş olabilir.

---

## 10) ÇEK/SENET, BANKA & KASA

**Q77 — "Portföyümdeki çeklerin vade dağılımı, bu ay tahsil edilecekler?"**
→ *Kilit:* `CEK_SENET.EVRAK_DURUMU` portföyde + `VADESI` bu ay. *Yöntem:* durum=portföy, vade ayında; tutar toplamı. *UI:* Çek/Senet > Portföy. ⚠️ 📖 `EVRAK_DURUMU` kodunu (`kod-sozlugu`) teyit; PII (`ODKS_*`, `KEFIL_*`) maskele.

**Q78 — "Karşılıksız/protestolu çek riski taşıyan müşteriler?"**
→ *Kilit:* `PROTESTO_OLDU` + cari geçmişi. *Yöntem:* protestolu çek olan cariler, tekrar risk. *UI:* Çek/Senet > Protesto. ⚠️ PII maskele; kara liste KVKK.

**Q79 — "Cirolanan çeklerim nerede, kime ciro edildi (takip zinciri)?"**
→ *Kilit:* Ciro zinciri `CEK_SENET_DT`/hareket; `EVRAK_DURUMU=ciro`. *Yöntem:* ciro edilen çekler + karşı taraf. *UI:* Çek ciro. ⚠️ Karşı taraf PII maskele.

**Q80 — "Vadesi gelen kendi verdiğim senetler (ödeme planı) — nakit ihtiyacı?"**
→ *Kilit:* Borç senetleri (kendi) vade takvimi = nakit akış. *Yöntem:* verilen senet vade bazında toplam. *UI:* Ödeme planı. ⚠️ Alacak vs borç senedini ayır.

**Q81 — "Kasa açığı/fazlası veren günler (kasa sayım tutarsızlığı)?"**
→ *Kilit:* `KASAHR` günlük `Σ(KPB_GLTUT−KPB_GDTUT)` vs fiziki sayım. *Yöntem:* günlük kasa hareket bakiyesi negatife düşen/atlayan. *UI:* Kasa > Gün sonu. ⚠️ Manuel kasa yerine POS/banka entegrasyonu öner.

**Q82 — "Banka hareketlerim ekstreyle mutabık mı (eksik/çift kayıt)?"**
→ *Kilit:* `BANKAHR` vs banka ekstre; çift/eksik. *Yöntem:* tarih-tutar eşleşmeyen hareketler. *UI:* Banka mutabakat. ⚠️ Ekstre dışı transfer/masraf kalemleri.

**Q83 — "Nakit mi kart mı çek mi — tahsilat kanalı dağılımım?"**
→ *Kilit:* Kanal = kasa/banka/çek modülü kırılımı. *Yöntem:* tahsilat türü × tutar. *UI:* Tahsilat raporu. ⚠️ POS komisyon maliyetini net tahsilata yansıt.

---

## 11) ÇOKLU-YIL, DEVİR & DÖNEM

**Q84 — "Çalışma yılım neden 2023, takvim 2025 — sorun mu?"**
→ *Kilit:* DB adı `<yıl>` = **çalışma yılı**, takvimden geri olabilir; normal **veya** devir yapılmadı işareti. *Yöntem:* `sys.databases` yıl DB'leri; son hareket tarihi hangi DB'de. *UI:* Dönem İşlemleri. ⚠️ **Kullanıcıya sor, varsayma.**

**Q85 — "Yıl sonu devrini yaptığımda hangi bakiyeler taşınır, kontrol listesi?"**
→ *Kilit:* Stok/cari/çek-senet/banka açılış bakiyeleri devreder; `DEVIR=1`. *Yöntem:* devir öncesi bakiye özeti = devir sonrası açılış. *UI:* Yönetim > Devir. ⚠️ Devir öncesi yedek + test.

**Q86 — "Geçen yıl bu döneme göre büyüdüm mü (LFL karşılaştırma)?"**
→ *Kilit:* Çapraz-DB aynı ay penceresi; şema yıllar arası değişebilir. *Yöntem:* iki yıl DB `UNION ALL` aynı ay aralığı. *UI:* Yok → SQL. ⚠️ Enflasyon düzelt; her DB'de schema-first.

**Q87 — "Kapanan yıla ait düzeltme faturası kesebilir miyim, nasıl?"**
→ *Kilit:* Kapalı dönemde geriye dönük belge = mevzuat riski; iade/düzeltme faturası doğru yol. *Yöntem:* — (danışmanlık). *UI:* İade/düzeltme faturası. ⚠️ **Geçmişe tarih atma/sahte belge YASAK** — yasal düzeltmeye yönlendir.

**Q88 — "Birden fazla firma (001/002) verisini konsolide raporlamak istiyorum."**
→ *Kilit:* Farklı `<firma>` = ayrı işletme/ayrı DB; konsolidasyon çapraz-DB + dikkatli eşleştirme. *Yöntem:* firma DB'leri `UNION ALL`, ortak boyutlar. *UI:* Yok → SQL. ⚠️ Firmalar arası cari/stok kod çakışmasını çözmeden birleştirme.

**Q89 — "Hangi yıllara ait DB'lerim var, arşivlenebilir/küçültülebilir olanlar?"**
→ *Kilit:* Eski yıl DB'leri salt-okunura alınıp arşivlenebilir. *Yöntem:* `sys.databases` + boyut; erişilmeyen eski yıllar. *UI:* SQL yönetim. ⚠️ Yasal saklama süresi (Türkiye ~5-10 yıl) — silme değil arşiv.

---

## 12) VARYANT, ÜRETİM/REÇETE & POS

**Q90 — "Hangi beden/renk kombinasyonu daha çok satıyor (asorti planı)?"**
→ *Kilit:* Varyant satış `FATURAHR.VARYANT_KODU`/`VARYANT_ACIKLAMA`; tanımlar `BEDEN_TANIM`/`RENK_TANIM`. *Yöntem:* [F1]. *UI:* Varyant raporu. ⚠️ Varyantsız kartları karıştırma.

**Q91 — "Belirli beden/renkte ölü stok (satılmayan asorti kalıntısı)?"**
→ *Kilit:* Varyant bazında hareketsizlik; ana kart aktif olsa da varyant ölü. *Yöntem:* varyant × son çıkış tarihi. *UI:* Varyant stok. ⚠️ Varyant bazlı bakiye ana karttan ayrı hesap.

**Q92 — "Reçeteli (üretim) ürünlerimin gerçek maliyeti bileşen fiyatlarıyla güncel mi?"**
→ *Kilit:* Reçete/BOM bileşen maliyeti değişince mamul maliyeti eskir. *Yöntem:* reçete bileşenleri × güncel alış vs kayıtlı mamul maliyeti. *UI:* Üretim > Reçete. ⚠️ 📖 reçete tablolarını (kullanılıyorsa) teyit; üretim modülü kullanılmıyorsa danışmanlıkla sınırla.

**Q93 — "Fason işçiliğim maliyete doğru yansıyor mu?"**
→ *Kilit:* Fason = dış işçilik maliyeti; mamul maliyetine eklenmezse kâr şişer. *Yöntem:* fason gider vs üretilen mamul. *UI:* Üretim > Fason. ⚠️ Modül kullanılmıyorsa danışmanlıkla sınırla.

**Q94 — "Hızlı Satış (POS) ekranında en çok satılan ama fiyatsız/yanlış kart?"**
→ *Kilit:* POS'ta fiyatsız kart = kasiyer elle girer → tutarsızlık. *Yöntem:* Hızlı Satış geçmişi × fiyatsız kart. *UI:* Hızlı Satış ayarları; pasif kartları POS'tan gizle. ⚠️ POS ile normal satışı ayır.

**Q95 — "POS'ta pasif ürünler hâlâ görünüyor/satılıyor mu?"**
→ *Kilit:* `AKTIF=0` ama Hızlı Satış listesinde = 5 dakikalık düzeltme. *Yöntem:* pasif kart POS listesinde mi. *UI:* Hızlı Satış > Ürün gizleme. ⚠️ Son 90 gün hareketli pasifleri ([A7]) önce çöz.

---

## 13) VERİ SAĞLIĞI, ANTİ-PATTERN & KVKK

**Q96 — "Sistemimin genel 'sağlık röntgenini' çıkar (tam tarama)."**
→ *Kilit:* Tek soru değil, bir **panel**: boş/dolu tablo, grupsuz kart, negatif stok, ölü stok, askıda e-fatura, eski KDV, mükerrer barkod, bozuk döviz birimi. *Yöntem:* [sorgu-recetesi A-D] toplu koştur. *UI:* — . ⚠️ Bu-install gözlemlerini evrensel sanma; her bulguyu para/adetle nicele.

**Q97 — "Döviz fiyatlı ama para birimi boş/bozuk kartlar (TL listede patlıyor)?"**
→ *Kilit:* `KPB_MI=2`/`DOVIZ_KULLAN=1` ama `DOVIZ_BIRIMI` boş/geçersiz. *Yöntem:* [A1]. *UI:* Stok > Döviz sekmesi toplu düzeltme. ⚠️ Geçerli simge kümesini (`DOVIZ` tablosu) referans al.

**Q98 — "Grup kodsuz kartlar raporlarımı bozuyor — kaç tane, hangi kritik olanlar?"**
→ *Kilit:* `GRUBU` boş kartlar (çoğu kurulumda yüksek oranda) → ABC, kampanya, kırılım hepsi bozulur. *Yöntem:* [A3] + hareketli olanları önceliklendir. *UI:* Toplu grup atama. ⚠️ Hareketsiz kartları sonraya bırak.

**Q99 — "Standart-dışı, İngilizce/camelCase adlı şişmiş tablolarım güvenli mi, temizlenir mi?"**
→ *Kilit:* `*OrderDetailRecords`/`*Copy`/`SYNCDATA` gibi tablolar **native Wolvox değil**, sonradan eklenmiş senkron/change-tracking katmanı olabilir. *Yöntem:* [D1] boyut; sahibine "kim kurdu, aktif mi?" *UI:* — . ⚠️ Şema doğrulanmadan bu tablolara dayanma; arşiv/temizlik DBA + entegratör onayı.

**Q100 — "Müşteri listemi/telefonları toplu dışa aktarmak istiyorum (pazarlama)."**
→ *Kilit:* Toplu PII çıkarımı = **KVKK ihlali** riski; ad/tel/eposta/TC/VKN çekilmez. *Yöntem:* agregat/maskeli kırılım (sektör/grup/bakiye) sun; bireysel PII **verme**. *UI:* — . ⚠️ Meşru amaç + açık rıza + veri minimizasyonu şart; reddet ve uyumlu alternatife yönlendir.

---

## Nasıl kullanılır (danışman refleksi)

Her yeni soruda: **(1)** hangi kategoriye düşüyor, benzer vaka var mı? **(2)** naif cevabın kaçıracağı
**tuzak** ne (asimetri, alt-küme, KDV hariç/dahil, döviz-ayrımı, çapraz-DB, devir, PII)? **(3)** önce
**ölçen SELECT**, sonra UI yolu veya inert taslak. **(4)** varsayım/eşik/para-birimi/kur kaynağını
**yaz**. **(5)** kolon adını teyit et, `SILINDI`/`IPTAL` filtrele, PII maskele, salt-okunur çalış.

> Bu katalog nokta-atışı bir başlangıç kümesidir; kod anlamları ve oranlar install/mevzuat ile
> değişir ve **kuruluma özeldir** — bu dosya gerçek işletme verisi içermez. Kritik işten önce daima
> şema-first + teyit; salt-okunur çalış, PII maskele.
