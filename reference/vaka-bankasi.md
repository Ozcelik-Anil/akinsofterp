# Wolvox 8 — Genişletilmiş Vaka Bankası (900 soru) + Çözüm Desenleri

> **Amaç:** [vaka-catalogu-100.md](vaka-catalogu-100.md)'daki 100 tam-çözümlü bayrak vakayı, **900 ek
> komplike soruyla** 1000'e tamamlar. Burada her soru **yoğun** yazılır (soru — *tuzak* — desen), asıl
> çözüm gücü aşağıdaki **Çözüm Deseni Kütüphanesi (P1–P30)**'ndedir: model soruyu ilgili desene bağlayıp
> çözer. Bu, uzmanlığı sayı yerine **aktarılabilir yöntemle** ölçekler.
>
> **Kullanım:** her soruda → kategori/benzer vaka? → **tuzak** ne (asimetri, KDV hariç/dahil, döviz,
> çapraz-DB, devir, PII…)? → hangi **P#** deseni? → önce ölçen SELECT, sonra UI/inert taslak → varsayım
> beyan et → şema-first, `SILINDI`/`IPTAL` (kolon varsa), PII maskele, salt-okunur. Sayılar/kodlar
> **kuruluma özeldir** — bu dosya gerçek işletme verisi içermez; her şeyi install'da tara.

---

## ÇÖZÜM DESENİ KÜTÜPHANESİ (P1–P30)

> **Kanonik SQL iskeleti + tuzak** her desen için [cozum-desenleri.md](cozum-desenleri.md)'nde. Aşağısı hızlı-hatırlatma özetidir; bir soruyu çözerken ilgili P#'in tam iskeletini oradan al.

- **P1 — Asimetrik güncelleme:** sadece yükselt/azalt; koşullu `WHERE hedef > (veya <) mevcut`. Maliyet düşse dokunma.
- **P2 — KDV hariç↔dahil:** `net = brüt/(1+KDV/100)`; `STOK_FIYAT.FIYATI` **hariç**. Yuvarlama/psikolojik bitiş **dahil** tarafta.
- **P3 — Alt-küme filtre:** işlemi tüm karta değil işaretliye uygula (`OZEL_KODU1/2/3`, `GRUBU`, `MARKASI`); boş slotu install'da doğrula.
- **P4 — En güncel satır:** `ROW_NUMBER() OVER (PARTITION BY anahtar ORDER BY tarih DESC)=1` (fiyat, kur, bakiye snapshot).
- **P5 — Çapraz-DB birleştirme:** üç-parçalı ad `[WOLVOX8_<firma>_<yıl>_<modül>].dbo.TBL` + `UNION ALL`; muhasebe `_GMUHASEBE`, her yıl ayrı DB.
- **P6 — Belge-zinciri kapanışı:** teklif→sipariş→irsaliye→fatura; açık/kapalı durum + `FATURALANDI`; eksik halka = kayıp gelir/işlem.
- **P7 — Bakiye toplamı:** stok = `Σ(STOKHR.KPB_GMIK−KPB_CMIK)`; cari = `Σ(CARIHR.KPB_BTUT−KPB_ATUT)`; `SILINDI=0`.
- **P8 — Maliyet/son-alış:** `STOKHR` giriş (`TUTAR_TURU=1`, `IADE=0`,`DEVIR=0`); döviz maliyet belge-anı kur (`DOVIZ_ALIS`), güncel değil.
- **P9 — Yaşlandırma:** açık kalemi `VADESI` ile 0-30/31-60/61-90/90+ kovala; kısmi tahsilatı FIFO eşleştir.
- **P10 — Eşik/pencere:** "ölü/yavaş/riskli" bir eşik ister (gün/tutar); eşiği **beyan et**, sabit sanma.
- **P11 — Anomali/mutabakat:** başlık(`TOPLAM_*`) vs satır; sistem bakiye vs sayım; defter vs ekstre → fark>tolerans.
- **P12 — Mükerrer/tekillik:** `GROUP BY alan HAVING COUNT(*)>1` (barkod, kart, cari, fatura no).
- **P13 — Eksik-kayıt (NOT EXISTS):** fiyatsız/gruplu olmayan/hareketsiz/faturalanmamış/muhasebeleşmemiş.
- **P14 — Kod→anlam:** [kod-sozlugu](kod-sozlugu.md); dağılıma bak, **bir örneği UI'da teyit et**, tek değerse yönü ondan çıkarma.
- **P15 — PII/KVKK:** ad/tel/VKN/TCKN çekme; maskele (`LEFT+***`) veya `GRUBU`/`SEKTOR` agregatı; toplu PII dışa aktarma **reddi**.
- **P16 — Otomasyon yöntemi:** basit "hep marj"→yerleşik; özel bitiş/asimetrik→zamanlanmış betik; DML trigger **reddet**.
- **P17 — Inert migration:** `BEGIN TRAN … ROLLBACK` taslağı, kullanıcı çalıştırır; **UI toplu güncelleme tercih** (log korur). Ham UPDATE verme.
- **P18 — Denetim izi:** `DEGISIM_LOG`, `STOK_FIYAT_DEGISIM_LOG`, gömülü `KAYDEDEN/DEGISTIREN` → kim-ne-zaman.
- **P19 — e-belge durumu:** `FATURA`/`IRSALIYE` **başlığında** (`EFATURA_DURUM`/`EFATURA_GIB_DURUM`/`EIRSALIYE_*`); ayrı tablo değil.
- **P20 — Döviz→TL:** `DOVIZ` tablosu **bayat** → güncel kuru kullanıcıdan/TCMB'den al; per-100 için `PARA_ORANI`.
- **P21 — Devir/dönem:** `<yıl>`=çalışma yılı ayrı DB; `DEVIR=1` açılış; devir eksikse bakiye hatalı → önce devri doğrula.
- **P22 — ABC/Pareto:** ciro/kâr DESC, kümülatif %; A(%80)/B/C sınıfı.
- **P23 — Sepet/birliktelik:** aynı `BLFTKODU` içi ürün çiftleri (market-basket).
- **P24 — Segment kırılım:** `GRUBU`/`SEKTOR`/`MARKASI`/pazarlamacı/şube boyutları; grupsuz kart kırılımı bozar.
- **P25 — Reel/enflasyon:** yıllar arası nominal TL yanıltıcı → reel/döviz bazına çevir.
- **P26 — Performans:** `WITH(NOLOCK)`/dirty-read; eksik-index DMV (öner, ekleme); mesai dışı/yedek kopya; büyük tabloda `TOP`.
- **P27 — Soft-delete disiplini:** `SILINDI`/`IPTAL` **yalnız kolon varsa**; `...HR`'de yoksa başlıktan filtrele; STOK'ta `AKTIF`.
- **P28 — Süreç-oranı:** dönüşüm/başarı % (teklif→sipariş, irsaliye→fatura, e-fatura gönderim); transfer/iade **hariç tut**.
- **P29 — Maliyet-yöntemi beyanı:** ort/FIFO farkı; ek maliyet dağıtımı; kaynak+tarih+kur beyan et; SMMM ile çelişebilir.
- **P30 — Etik/yasal sınır:** geçmişe belge/sahte e-fatura/toplu PII → **reddet**, tek cümle + yasal alternatif (iade/düzeltme).

---

## 1) FİYATLANDIRMA & MARJ (#101–#160)

101. Belirli bir gruba tek seferde sabit tutar (TL) zam yap. — *T:* döviz fiyatlıları ayrı; yazma=UI/taslak · P3,P17
102. Maliyete göre hedef marj altında kalan tüm satış fiyatlarını raporla. — *T:* asimetrik; döviz ayrı · P8,P1
103. Aynı ürünün 2. ve 3. fiyat listesi boş kalanları bul. — *T:* `FIYAT_NO` bazında NOT EXISTS · P13
104. Müşteriye atanan fiyat listesi ile fatura fiyatı uyuşmayanlar. — *T:* `CARI.STOK_FIYATI` vs fatura · P4,P11
105. KDV dahil 199,90 hedefine göre KDV hariç net fiyatı geri hesapla. — *T:* yuvarlama dahil tarafta · P2
106. Son 6 ayda hiç fiyat güncellenmemiş aktif kartlar (enflasyon erozyonu). — *T:* `FIYAT_DEG_TARIHI` eşiği · P10,P4
107. Döviz alışlı ürünlerin TL satışını güncel kurla yeniden fiyatla. — *T:* DOVIZ bayat; maliyet belge-anı kur · P20,P8
108. Fiyatı maliyetinin altına düşmüş (negatif marj) kartlar. — *T:* maliyet yöntemi beyanı · P8,P29
109. Kampanya/iskonto sonrası efektif satış fiyatı liste fiyatının altındakiler. — *T:* kademeli iskonto ISK1..3 · P11
110. Aynı ürüne farklı depoda/şubede farklı fiyat var mı? — *T:* şube/depo boyutu · P24,P11
111. Fiyatı yuvarlak olmayan (kuruşlu) perakende kartlarını ...9'a çek. — *T:* KDV dahil tarafta yuvarla · P2,P17
112. Toptan fiyatı perakende fiyatının üstünde kalan ürünler (ters fiyat). — *T:* liste self-join · P11
113. Pazarlamacı kâr oranı tanımsız aktif kartlar. — *T:* `PAZARLAMACI_KAR_ORANI` boş · P13
114. Son alış artmış ama satış güncellenmemiş kartlar (gecikmiş zam). — *T:* STOKHR son alış vs fiyat tarihi · P8,P4
115. Bir markanın tüm ürünlerine %X zam — önizleme + taslak. — *T:* alt-küme MARKASI; UI tercih · P3,P17
116. Fiyatı son 30 günde 3+ kez değişen kartlar (oynak fiyatlama). — *T:* değişim log frekansı · P18
117. Yetkisiz kullanıcının değiştirdiği fiyatlar (iç kontrol). — *T:* `KAYDEDEN` denetim · P18,P15
118. Aynı barkodun farklı kartlarında farklı fiyat (kasada tutarsızlık). — *T:* mükerrer barkod · P12
119. Alış iskontosu tanımlı ama satış marjına yansımayan kartlar. — *T:* `ALIS_ISKONTO_*` net maliyet · P8
120. Fiyat listesi 1 dolu ama 2/3 (bayi) hiç kullanılmıyor mu? — *T:* özellik derinliği · P13
121. KDV oranı değişen ürünlerde KDV dahil fiyat sabit tutulmuş mu? — *T:* net yeniden hesap · P2
122. Belirli bir tedarikçiden gelen ürünlere maliyet+marj otomatik fiyat. — *T:* alt-küme tedarikçi; asimetrik · P3,P16
123. Fiyatı 0 veya boş olan aktif satış kartları. — *T:* fiyatsız operatör hatası · P13
124. Döviz simgesi bozuk kartların TL fiyatı yanlış çıkıyor. — *T:* geçersiz `DOVIZ_BIRIMI` · P20
125. Minimum satış fiyatı (taban) altında kesilen faturalar. — *T:* satır fiyat vs taban · P11
126. En çok iskonto verilen 20 ürün (gizli marj kaybı). — *T:* ort iskonto trendi · P22
127. Fiyat artışının ciroya etkisi (elastikiyet kaba tahmin). — *T:* fiyat×miktar önce/sonra · P11,P25
128. Sezon sonu indirim adayı yavaş dönen kartlar. — *T:* devir + ölü eşik · P10
129. Aynı ürünün alış fiyatı satış fiyatından yüksek (veri hatası). — *T:* alış vs satış · P11
130. Otomatik fiyatlamada "−1/…9" bitişini uygulayan toplu betik. — *T:* CEILING−1; asimetrik; alt-küme · P1,P16,P17
131. Fiyat listesi tanımları (`STOK_FIYAT_TANIM`) ile fiili kullanım uyumu. — *T:* tanım vs veri · P13
132. Vadeli satışta vade farkı fiyata yansıtılıyor mu? — *T:* peşin vs vadeli fiyat · P11
133. Kur farkından doğan fiyat güncelleme ihtiyacı (eşik %). — *T:* kur değişim eşiği · P20,P10
134. Fiyatı el ile girilen (liste dışı) satış satırları. — *T:* fatura fiyat vs liste · P11
135. Grup bazında ortalama marj kırılımı. — *T:* maliyet yöntemi; grupsuz · P24,P29
136. Belirli özel kodlu ürünlerde sabit fiyat kilidi (güncelleme dışı). — *T:* alt-küme hariç tutma · P3
137. Fiyat değişiminin fatura kârına yansıma gecikmesi. — *T:* fiyat tarihi vs fatura · P4
138. Perakende vs toptan satış oranı ve marj farkı. — *T:* FIYAT_NO segment · P24
139. Yeni açılan kartlarda fiyat tanımlanmamış olanlar (son 30 gün). — *T:* eksik fiyat + tarih · P13,P10
140. İthal ürünlerde döviz+navlun+gümrük dahil gerçek maliyet marjı. — *T:* ek maliyet dağıtımı · P29,P8
141. Fiyat listesini Excel'e döküp toplu güncelleme için hazırla. — *T:* KDV hariç + TL kolon; salt-okunur çıkış · P2
142. Aynı üründe zamanla marj daralması (trend). — *T:* reel/enflasyon · P25
143. Kampanya motoru kullanılmıyorsa iskontodan kampanya türet. — *T:* heuristik; bayrak yok · P14
144. Fiyat onay sürecinde bekleyen değişiklikler var mı? — *T:* durum alanı; kuruluma özel · P14
145. Ürün paketlerinde (`STOK_PAKET`) bileşen fiyat toplamı vs paket fiyatı. — *T:* paket bütünlüğü · P11
146. Fiyatı negatif/absürt (veri girişi hatası) kartlar. — *T:* aralık kontrolü · P11
147. Müşteri özel iskonto oranı ile fatura iskontosu uyuşmayanlar. — *T:* `CARI.ISKONTO_ORAN` vs fatura · P11
148. Döviz kuru snapshot'ı olmayan döviz faturalar (kur boş). — *T:* `DOVIZ_ALIS` boş · P20,P13
149. Fiyat artışını e-posta/bülten ile bildirme listesi (segment). — *T:* PII/KVKK; agregat · P15
150. Belirli fiyat aralığındaki ürünlerin satış performansı. — *T:* fiyat bandı segment · P24
151. Alış faturası girişinde satış fiyatının otomatik güncellenmesi (native mi?). — *T:* `KAYNAK_FIYAT_TIPI` kullanımı · P16
152. Fiyatı olan ama stoğu hiç olmayan (hayalet) kartlar. — *T:* bakiye=0 + fiyat · P7,P13
153. Kdv hariç girilen fiyatların brüt karşılığını rapora ekle. — *T:* +KDV kolon · P2
154. Marka bazında fiyat konumlandırma (premium/ekonomik). — *T:* marka segment · P24
155. Fiyat değişim logundan aylık ortalama zam yüzdesi. — *T:* log trend · P18,P25
156. Bir kartın tüm fiyat listelerini tek satırda pivotla. — *T:* FIYAT_NO pivot · P4
157. Alışta iskonto+vade farkı sonrası net maliyet ve doğru marj. — *T:* net maliyet bileşenleri · P8,P29
158. İki tarih arasında fiyatı düşürülmüş kartlar (kim, ne kadar). — *T:* log delta · P18
159. Fiyat listesi ile POS/Hızlı Satış fiyatı tutuyor mu? — *T:* kanal tutarlılığı · P11
160. Yeni maliyetle güncellenmesi gereken kartların TL etki özeti. — *T:* etki niceleme · P8,P11

---

## 2) STOK & ENVANTER (#161–#245)

161. Depo bazlı stok raporu ile toplam bakiye neden tutmuyor? — *T:* STOKHR vs STOK_DEPO; SILINDI · P7,P11
162. Negatif bakiyeye düşen kartlar ve ilk negatife düştüğü tarih. — *T:* devir/sıra · P7,P21
163. Ölü stok TL karşılığı (180 gün hareketsiz × maliyet). — *T:* eşik + maliyet · P10,P8
164. Min stok altına düşmüş ama açık siparişi olmayan ürünler. — *T:* bakiye<min + NOT EXISTS sipariş · P13,P7
165. Aynı barkod birden çok kartta (yanlış okutma). — *T:* mükerrer · P12
166. Satış fiyatı olmayan aktif kartlar. — *T:* NOT EXISTS satış fiyat · P13
167. Pasif ama son 90 günde hareketli kartlar. — *T:* durum tutarsızlığı · P11
168. Depolar arası transferde kaybolan/eşleşmeyen miktar. — *T:* kaynak vs hedef · P11,P6
169. Sayım sonucu ile sistem bakiyesi sapan kartlar. — *T:* sayım vs STOKHR · P11
170. En çok fire/zayi veren ürünler. — *T:* fire türü kodu teyit · P14
171. Aynı ürünün mükerrer kartı (isim/barkod normalize). — *T:* varyantla karıştırma · P12
172. Grup bazında stok devir hızı; yavaş dönen grup. — *T:* devir kaba yaklaşım · P22,P24
173. Maksimum stok üstüne çıkan (aşırı stok) kartlar. — *T:* bakiye>max · P7,P10
174. Hiç girişi olmayan ama satılmış (negatif kaynak) kartlar. — *T:* çıkış-önce-giriş · P7
175. Seri/lot takipli ürünlerde açık seri bakiyesi. — *T:* lot boyutu; kullanılıyorsa · P14
176. Raf/lokasyon tanımsız (`KORIDOR_NO/RAF_NO`) depo kartları. — *T:* eksik lokasyon · P13
177. Minimum/maksimum seviyesi tanımsız aktif kartlar. — *T:* tetikleyici yok · P13
178. Konsinye/emanet stok kendi stoğuyla karışıyor mu? — *T:* depo/özel kod ayrımı · P3
179. 12 ay hiç satılmayan ama alınmaya devam eden ürünler. — *T:* alış var satış yok · P6,P10
180. ABC analizi: cironun %80'ini taşıyan ürünler. — *T:* kümülatif % · P22
181. Stok değeri (envanter) toplamı — maliyetle. — *T:* bakiye×maliyet; yöntem · P8,P29
182. Hızlı tükenen (yüksek devir) kritik ürünlerde güvenlik stoğu. — *T:* devir + tedarik süresi · P10
183. Barkodsuz aktif kartlar (terminalde okutulamaz). — *T:* boş barkod · P13
184. Aynı ürün farklı birimlerle (adet/koli) tutarsız mı? — *T:* `STOK_BIRIMLERI` çarpanı · P11
185. Varyantlı üründe ana kart bakiyesi vs varyant toplamı. — *T:* varyant ayrı hesap · P7,P11
186. Uzun süredir hareketsiz ama yüksek değerli (bağlı sermaye) kartlar. — *T:* ölü×değer önceliklendir · P10,P8
187. Stok bloke miktarının satılabilir stoğa etkisi. — *T:* `STOK_BLOKE` · P7
188. Depo bazında negatif stok (yanlış terminal→depo). — *T:* depo bazlı bakiye · P7
189. Son giriş tarihi çok eski ama bakiyesi olan (donuk) stok. — *T:* giriş tarihi eşiği · P10
190. Ürün gamı şişkinliği: hiç satmayan aktif kart oranı. — *T:* katalog sağlığı · P10,P13
191. Kritik stok uyarısı için otomatik e-posta/görev kurulmuş mu? — *T:* özellik derinliği · P13
192. Sayım açığı/fazlası TL etkisi ve düzeltme fişi kesilmiş mi? — *T:* fark×maliyet; fiş var mı · P11,P6
193. İade edilen ürünlerin stoğa doğru girip girmediği. — *T:* `IADE` yönü · P8,P14
194. Tedarikçi bazında aynı ürünün en ucuz kaynağı. — *T:* `STOK_TEDARIKCI` + son alış · P8
195. Stokta olup e-ticaret/bayi senkronunda görünmeyenler. — *T:* standart-dışı katman · P11
196. Ürün başına ortalama raf ömrü/duruş süresi. — *T:* giriş→çıkış gün · P10
197. Aynı grupta çok benzer isimli kartlar (birleştirme adayı). — *T:* isim benzerliği · P12
198. Depo kapasitesi/doluluk (miktar × hacim) tahmini. — *T:* veri varsa · P24
199. Stok hareketlerinde tarih dışı/gelecek tarihli kayıtlar. — *T:* tarih anomalisi · P11
200. Belirli dönemde en çok giriş yapılan (aşırı alım) ürünler. — *T:* dönem giriş · P10
201. Hiç depo ataması olmayan stok kartları. — *T:* `STOK_DEPO` NOT EXISTS · P13
202. Ölü stok için tasfiye/indirim senaryosu (nakit etkisi). — *T:* değer + indirim · P8
203. Stok kartı özel kod dağılımı (sınıflandırma kullanımı). — *T:* OZEL_KODU doluluk · P3
204. Miktarı negatife düşmeden ön uyarı (satılabilir<talep). — *T:* bakiye−açık sipariş · P7,P6
205. Reçeteli mamulün bileşen stok yeterliliği (üretilebilir mi?). — *T:* BOM patlatma; modül var mı · P14
206. Fiziksel sayım için ABC bazlı sayım planı. — *T:* değer sınıfı · P22
207. Aynı ürünün farklı KDV oranıyla iki kartı. — *T:* mükerrer + KDV · P12
208. Stok yaşlandırma (FIFO parti bazında bekleme). — *T:* parti tarih · P9
209. Satıştan çok iade gören ürünler (kalite sorunu). — *T:* iade/satış oranı · P28
210. Depo transfer sıklığı ve en çok taşınan ürünler. — *T:* transfer irsaliye · P6
211. Envanter doğruluğu skoru (sayım sapma oranı). — *T:* sapma agregası · P11
212. Stok kartı açılış devri eksik olanlar (yıl geçişi). — *T:* `DEVIR=1` yok · P21
213. Ürünlerin depo bazında minimum altı kalma sıklığı. — *T:* min ihlal frekansı · P10
214. Barkodu olan ama `STOK_BARKOD` çoklu barkodda çakışan. — *T:* çoklu barkod · P12
215. Satış hızına göre yeniden sipariş noktası önerisi. — *T:* devir + lead time · P10
216. Hareketsiz kartları pasifleştirme adayı listesi. — *T:* ölü + öneri · P10
217. Aynı fiziksel ürünü temsil eden farklı ölçü kartları. — *T:* birim mükerrer · P12
218. Stok maliyeti ani sıçrayan ürünler (alış anomalisi). — *T:* maliyet delta · P8,P11
219. Depoya girmiş ama faturası gelmemiş mal (irsaliyeli). — *T:* irsaliye faturasız · P6,P28
220. Ürün bazlı stok kayıp oranı (fire+sayım açığı). — *T:* toplam kayıp · P11
221. Kritik/A sınıfı ürünlerde stoksuz kalma (out-of-stock) günleri. — *T:* bakiye=0 süre · P10
222. Aynı barkodun aktif+pasif iki kartta olması. — *T:* durum+mükerrer · P12
223. Stok kartı açıklamalarında tutarsız/eksik bilgi (veri kalitesi). — *T:* boş alanlar · P13
224. Ölçü birimi dönüşümü hatalı (koli↔adet) satırlar. — *T:* çarpan · P11
225. Depoya göre ölü stok dağılımı (hangi depo şişkin). — *T:* depo×ölü · P24,P10
226. Yeni ürün devreye alma süresi (açılış→ilk satış). — *T:* ilk hareket gecikme · P10
227. Stok kartı sayısının makul mü, katalog sadeleştirme fırsatı. — *T:* aktif/ölü oran · P10
228. Belirli tedarikçinin geç teslimatının stoğa etkisi. — *T:* sipariş→giriş gün · P6
229. Aynı ürünün fiyatlı-fiyatsız iki kartı (bölünmüş). — *T:* mükerrer · P12
230. Stok bakiyesi ile muhasebe stok hesabı mutabakatı. — *T:* çapraz-DB · P5,P11
231. Hangi ürünler hiç sayıma girmemiş (sayım kapsamı). — *T:* sayım NOT EXISTS · P13
232. Yüksek devirli ürünlerde min stok yetersizliği (stockout riski). — *T:* devir vs min · P10
233. Ürün ağacı olmayan mamul kartları (üretim eksik kurgu). — *T:* reçete yok · P13
234. Stok giriş fiyatları arasında aşırı sapma (aynı ürün). — *T:* maliyet varyans · P8
235. İthal ürünlerde döviz stok değeri (belge-anı kur). — *T:* DVZ bakiye · P8,P20
236. Kampanya için uygun (yüksek stok + yavaş devir) ürünler. — *T:* stok×devir · P22
237. Depolar arası fiyat/stok kartı senkron kopukluğu (çoklu şube). — *T:* şube DB'leri · P5,P24
238. Stok hareketi çok yoğun günler (yoğunluk analizi). — *T:* günlük hacim · P26
239. Miktarı büyük ama tutarı küçük (birim hatası) hareketler. — *T:* miktar×fiyat tutarsız · P11
240. Ürünlerin ortalama stok gün sayısı (DOI). — *T:* bakiye/günlük çıkış · P10
241. Aktif satışta olması gereken ama pasif kalmış çok satan ürünler. — *T:* pasif+hareketli · P11
242. Yeni sezon öncesi tasfiye edilmemiş eski sezon stoğu. — *T:* özel kod/sezon · P3,P10
243. Bir ürünün tüm depolardaki dağılımı ve dengesizlik. — *T:* depo dağılım · P24
244. Stok değer değişimi (dönem başı vs sonu) köprüsü. — *T:* devir + hareket · P21,P7
245. Barkod/ölçü/grup üçlüsü eksik "yarım" kartlar. — *T:* veri tamlığı · P13

---

## 3) MALİYET & KÂRLILIK (#246–#310)

246. Ürün/grup/müşteri kırılımında gerçek brüt kâr. — *T:* maliyet yöntemi + kur beyanı · P29,P8
247. Ortalama mı FIFO mu — iki yöntemin kâr farkı. — *T:* yöntem ayarı · P29
248. Ek maliyet (nakliye/gümrük) ürüne dağıtılmış mı? — *T:* `EK_MALIYET`; dağıtım anahtarı · P29
249. Döviz alışta kur farkının kâra etkisi. — *T:* belge-anı vs güncel kur · P8,P20
250. İskonto sonrası net satış ve gerçek marj. — *T:* kademeli iskonto · P11
251. Kampanyalı satışların toplam kâra etkisi. — *T:* kampanya ayrımı · P28
252. Pazarlamacı bazında kârlılık ve prim tabanı. — *T:* prim ciro mu kâr mı · P24
253. Vade finansman maliyeti düşülünce hangi müşteri zararına? — *T:* tahsil gün × oran · P9,P29
254. Maliyeti olmayan (hiç alışı yok) kartlarda kâr hesaplama. — *T:* "maliyet yok" işaretle · P8,P13
255. En kârlı 20 vs en zararlı 20 ürün. — *T:* kâr ABC · P22
256. Grup bazında marj erozyonu trendi (yıllar). — *T:* reel · P25
257. Zararına kesilen faturalar (bilinçli vs hata). — *T:* iskonto/kampanya ayır · P11
258. İade edilen satışların kârı geri alması (net kâr). — *T:* iade düş · P28
259. Fason işçilik mamul maliyetine yansıyor mu? — *T:* fason gider · P29
260. Reçete bileşen maliyeti güncel mi (mamul maliyeti eskimiş)? — *T:* BOM güncel alış · P8
261. Nakliye/kargo geliri-gideri neti. — *T:* gelir-gider eşleştir · P11
262. Müşteri kârlılığı: iskonto+iade+vade dahil. — *T:* çok bileşenli · P29,P9
263. Kanal (POS/toptan/bayi) bazında kâr marjı. — *T:* kanal segment · P24
264. Aylık kâr trendi ve mevsimsellik. — *T:* dönem; enflasyon · P25
265. Maliyet altında stok değerleme (net gerçekleşebilir değer). — *T:* maliyet vs piyasa · P8
266. Tedarikçi bazında satın alma maliyeti değişimi. — *T:* alış trend · P8,P25
267. Ürün bazlı katkı payı (contribution margin). — *T:* değişken maliyet · P29
268. Kârın yüzde kaçını kaç ürün taşıyor (kâr yoğunlaşması). — *T:* Pareto · P22
269. Döviz bazlı kâr (TL enflasyonundan arındırılmış). — *T:* döviz baz · P25,P20
270. Satış primli personelin net getiri/maliyet dengesi. — *T:* prim vs kâr · P24
271. Aynı ürünün farklı müşterilere kârlılık farkı. — *T:* müşteri×ürün · P24
272. Stok tutma maliyeti (bağlı sermaye × oran). — *T:* ölü stok × finansman · P10
273. Fire/zayi maliyetinin kâra etkisi. — *T:* fire × maliyet · P11
274. İskonto politikası optimizasyonu (hangi iskonto kârı yiyor). — *T:* iskonto vs marj · P11
275. Ürün paketlerinin (bundle) kârlılığı vs tekil. — *T:* paket maliyet toplamı · P11
276. En çok ciro ≠ en çok kâr (yanıltıcı ürünler). — *T:* ciro vs kâr ayrımı · P22
277. Maliyet güncellemesi gecikmiş ürünlerde gerçek kâr sapması. — *T:* eski maliyet · P8
278. Vergi öncesi/sonrası kâr köprüsü (KDV/ÖTV etkisi). — *T:* vergi ayrı · P29
279. Zarar eden şube/depo (dağıtılmış giderle). — *T:* şube segment · P24,P5
280. Sezon bazında kârlılık (özel kod/tarih). — *T:* sezon segment · P3,P24
281. Kârlılık raporunun SMMM resmi maliyetiyle farkı. — *T:* fiili vs resmi · P29
282. Ürün iadesi yüksek olanların gizli maliyeti. — *T:* iade işlem maliyeti · P28
283. Alış vade farkının maliyete etkisi. — *T:* net maliyet · P8
284. Ölü stok yazımının (değer düşüklüğü) kâra etkisi. — *T:* değer düşüklüğü · P8
285. Marj hedefine göre fiyatlanması gereken kartların listesi. — *T:* hedef marj vs mevcut · P1,P8
286. Kâr marjı negatif ama çok satan ürünler (zarar lokomotifi). — *T:* miktar × negatif marj · P22
287. Tedarikçi iskontosunun (hacim) gerçek kazanca yansıması. — *T:* kademeli alış iskonto · P8
288. Maliyet yöntemine göre dönem sonu stok değeri farkı. — *T:* yöntem etkisi · P29
289. Ürün yaşam döngüsü kârlılığı (giriş→tasfiye). — *T:* dönemsel · P10
290. Kur riski taşıyan (döviz maliyetli TL satan) ürünler. — *T:* döviz maliyet TL fiyat · P20
291. Hizmet/masraf faturalarının maliyet dışı ayrımı. — *T:* `STOKHRK_ISLE=0` · P14
292. Ortalama sepet kârı (fatura başına). — *T:* fatura kâr agregası · P22
293. Kampanya ROI (kampanya cirosu vs marj kaybı). — *T:* kampanya net · P28
294. Aynı ürünün alış-satış makasının zamanla daralması. — *T:* makas trend · P25
295. Maliyetsiz (bedelsiz/numune) çıkışların ayrıştırılması. — *T:* çıkış türü · P14
296. Kârlılık dashboard'u için temel KPI seti. — *T:* KPI tanımı; varsayım · P29
297. Ürün grubu bazında hedef marj tutturma oranı. — *T:* hedef vs fiili · P24
298. En yüksek stok değeri bağlayan ama düşük kâr getiren ürünler. — *T:* değer vs kâr · P22
299. Döviz alış + TL satışta gerçek TL maliyet (belge-anı). — *T:* kur snapshot · P8
300. Kâr artışının kaynağı: fiyat mı hacim mi karma mı? — *T:* fiyat/hacim/karma ayrıştır · P25
301. İskontosuz satış yapılabilecek düşük-elastik ürünler. — *T:* iskonto vs talep · P11
302. Ürün başına ortalama kâr ve standart sapma. — *T:* dağılım · P24
303. Maliyet güncelleme sıklığı yetersiz kalemler. — *T:* güncelleme tarihi · P8
304. Zararına iade/değişim döngüsü olan ürünler. — *T:* iade maliyeti · P28
305. Brüt kârdan net kâra köprü (operasyonel gider tahmini). — *T:* gider dağıtım · P29
306. En kârlı müşteri segmenti (sektör/grup). — *T:* segment · P24,P15
307. Fiyat/maliyet uyumsuzluğu en yüksek kalemler. — *T:* marj sapma · P8
308. Ürün bazlı break-even hacmi. — *T:* sabit/değişken · P29
309. Döviz kuru senaryosuna göre marj duyarlılığı. — *T:* kur duyarlılık · P20
310. Kârlılık raporunda maliyet-yöntemi + tarih + kur varsayımı beyanı. — *T:* şeffaflık · P29

---

## 4) CARİ, ALACAK & RİSK (#311–#380)

311. Toplam alacak, borçlu müşteri sayısı, en riskliler (PII maskeli). — *T:* bakiye yönü; maskele · P7,P15
312. 30/60/90+ gün alacak yaşlandırması. — *T:* açık kalem FIFO; VADESI · P9
313. Kredi limitini aşan müşteriler. — *T:* bakiye vs limit alanı · P7
314. Çift yönlü cari (alış+satış) net bakiyesi doğru mu? — *T:* tek BLKODU net · P7
315. 90+ gün hareketsiz (uyuyan) müşteriler — geri kazanım. — *T:* son hareket; KVKK · P10,P15
316. Ortalama tahsil süresi (DSO) ve trendi. — *T:* vadeli ayrı · P9
317. En çok iade/iptal yapan müşteriler (sorunlu). — *T:* iade/ciro oranı · P28
318. Hiç fatura kesilmemiş açık cari kartları (ölü kart). — *T:* NOT EXISTS; potansiyel ayır · P13
319. Sektör/bölge bazında ciro ve alacak. — *T:* agregat; grupsuz · P24,P15
320. Vadesi bugün gelen tahsilatlar (günlük liste). — *T:* vade=bugün · P9
321. Riskli müşteri bayrağı ile fiili gecikme uyumu. — *T:* `RISKLI_MUSTERI` vs veri · P11
322. Tahsilat performansı: söz verilen vs gerçekleşen. — *T:* vade vs ödeme tarihi · P9
323. En yüksek bakiyeli 20 müşteri (konsantrasyon riski). — *T:* bakiye DESC; maskele · P7,P15
324. Alacak sigortası/teminat kapsamı dışı riskli bakiye. — *T:* teminat vs bakiye · P7
325. Cari ekstre mutabakatı için dönem hareketleri. — *T:* dönem; PII · P15
326. Müşteri bazında ortalama vade ve fiili ödeme farkı. — *T:* vade sapma · P9
327. Aynı firmanın farklı cari kartları (mükerrer cari). — *T:* VKN/unvan · P12,P15
328. Bakiyesi sıfır ama hareketli (kapanmış) cariler. — *T:* denge=0 · P7
329. Tedarikçilere borç yaşlandırması (ödeme planı). — *T:* borç yönü; vade · P9
330. Cari bakiye ile muhasebe 120/320 uyumu. — *T:* çapraz-DB · P5,P11
331. Vadesi geçmiş ama takip başlamamış alacaklar. — *T:* gecikme + aksiyon yok · P9
332. Peşin çalışan vs vadeli çalışan müşteri segmenti. — *T:* vade profili · P24
333. Müşteri kârlılığı vs risk matrisi. — *T:* kâr×risk · P24
334. Cari hareket açıklamalarından tahsilat kanalı çıkarımı. — *T:* `ISLEM_TURU` kod · P14
335. Ödeme alışkanlığı bozulan (yavaşlayan) müşteriler. — *T:* trend · P9,P25
336. Yeni müşteri kazanımı vs kayıp (churn) oranı. — *T:* ilk/son hareket · P10
337. Alacakların döviz kompozisyonu ve kur riski. — *T:* DVZ bakiye · P20
338. Kefil/teminat bilgisi eksik riskli cariler. — *T:* `KEFIL_*` boş; PII · P13,P15
339. Tahsil edilemeyen (şüpheli) alacak adayları. — *T:* çok gecikmiş · P9
340. Müşteri bazında ortalama sepet ve sıklık (RFM). — *T:* recency/frequency/monetary · P24
341. Cari grup bazında vade politikası tutarlılığı. — *T:* grup vade · P24
342. Aynı cari hem müşteri hem tedarikçi — mahsup fırsatı. — *T:* borç/alacak netleş · P7
343. En hızlı ödeyen (iskonto hak eden) müşteriler. — *T:* ödeme hızı · P9
344. Bakiye limiti tanımsız (kontrolsüz) cariler. — *T:* limit boş · P13
345. Müşteri iletişim bilgisi eksik/hatalı (operasyonel). — *T:* eksik alan; PII · P13,P15
346. Cari kart açılış devri eksik olanlar. — *T:* `DEVIR` yok · P21
347. Vade farkı uygulanması gereken geç ödemeler. — *T:* gecikme × oran · P9
348. Şube bazında alacak dağılımı ve tahsilat performansı. — *T:* şube segment · P24,P5
349. Cari risk skorlaması (bakiye+gecikme+iade). — *T:* çok faktörlü; PII · P15
350. Potansiyel müşteri (`POTANSIYEL`) dönüşüm oranı. — *T:* durum → fatura · P28
351. En çok çek/senet veren (nakit-dışı) müşteriler. — *T:* evrak sayısı · P24
352. Karşılıksız çek geçmişi olan riskli cariler. — *T:* `PROTESTO_OLDU`; PII · P15
353. Cari bakiyesinde ani sıçrama (anomali/hata). — *T:* hareket delta · P11
354. Ekstre gönderimi otomatikleştirilmiş mi (özellik). — *T:* otomasyon · P13
355. Müşteri başına ortalama gecikme günü (segment). — *T:* gecikme agregası · P9
356. Alacakların tahsilat olasılığına göre sınıflaması. — *T:* yaş → olasılık · P9
357. Tedarikçi ödeme vadesi ile müşteri tahsil vadesi makası (nakit döngüsü). — *T:* CCC · P9
358. Cari kartlarda grup/sektör kodsuz olanlar. — *T:* segment eksik · P24,P13
359. Bakiyesi olan pasif cariler (kapatılamayan hesap). — *T:* pasif+bakiye · P7
360. Müşteri yaşam boyu değeri (CLV kaba). — *T:* toplam kâr/süre · P24
361. Aynı VKN/TCKN farklı unvanla (veri hatası/mükerrer). — *T:* kimlik; PII · P12,P15
362. Tahsilatların tarihsel dağılımı (ay içi paterni). — *T:* gün paterni · P9
363. Cari hareketlerde SILINDI=1 ama bakiyeye yansıyan kayıt. — *T:* soft-delete disiplini · P27
364. Müşteri segmentine göre ürün tercih farkı (çapraz satış). — *T:* segment×ürün · P23,P24
365. Vadesinde ödemeyip sonra ödeyen (kronik geç) müşteriler. — *T:* tekrar gecikme · P9
366. Alacak toplamının ciroya oranı (sağlık göstergesi). — *T:* alacak/ciro · P9
367. En çok mahsup/virman işlemi olan cariler (karmaşık hesap). — *T:* `ISLEM_TURU=12` · P14
368. Tahsilat sonrası açık kalan kuruş bakiyeler (temizlik). — *T:* küçük bakiye · P7
369. Cari bazında borç/alacak dengesi görsel özet. — *T:* net bakiye · P7
370. Müşteriye özel fiyat listesi ile risk ilişkisi. — *T:* fiyat vs risk · P24
371. Yeni açılan cari kartların ilk sipariş süresi. — *T:* açılış→ilk işlem · P10
372. Bir müşterinin tüm belge geçmişi (360° görünüm, PII maskeli). — *T:* çok tablo; maskele · P15
373. Alacak devrinin (yıl geçişi) doğru taşındığı. — *T:* devir bakiye · P21
374. Tahsilatların banka/kasa/çek kırılımı. — *T:* kanal · P24
375. Riskli bölgeler/sektörlerde yoğunlaşma. — *T:* segment risk · P24
376. Cari kart temizliği: 2+ yıl işlemsiz kapatılabilir hesaplar. — *T:* eşik; yasal saklama · P10
377. Toplu SMS/e-posta hatırlatma listesi (KVKK uyumlu). — *T:* rıza; PII reddi · P15,P30
378. Ortalama fatura-tahsilat gecikmesi ürün grubuna göre değişiyor mu? — *T:* grup×DSO · P24,P9
379. Cari ekstresi ile fiili belge sayısı tutuyor mu? — *T:* mutabakat · P11
380. Şüpheli alacak karşılığı ayrılması gereken tutar (öneri). — *T:* yaş → karşılık; SMMM · P9,P30

---

## 5) FATURA & SATIŞ ANALİZİ (#381–#450)

381. Aylık/ürün bazında satış trendi ve zirve dönem. — *T:* başlık toplam; iade/iptal düş · P27,P25
382. Sepet analizi: birlikte satılan ürünler. — *T:* aynı fatura ürün çifti · P23,P26
383. Kesilmemiş/taslak fatura veya numara boşluğu. — *T:* seri bazında sıra · P12
384. Peşin vs vadeli satış oranı ve tahsilat riski. — *T:* vade profili · P9
385. ABC/Pareto: ciroyu taşıyan ürünler. — *T:* kümülatif % · P22
386. İskonto oranı zamanla arttı mı (marj erozyonu). — *T:* trend; karma etkisi · P25
387. Başlık toplamı ile satır toplamı tutuyor mu (bütünlük). — *T:* yuvarlama toleransı · P11
388. En çok fatura düzelten/silen kullanıcı (iç kontrol). — *T:* `DEGISIM_LOG`/IPTAL · P18
389. Saat/gün bazında satış yoğunluğu (POS planlama). — *T:* zaman paterni · P26
390. En çok satan 50 ürün (miktar+ciro). — *T:* satış tipi filtre · P28
391. İade faturalarının ürün/müşteri kırılımı. — *T:* `FATURA_TIPI` iade · P14,P28
392. Ortalama fatura tutarı ve sepet büyüklüğü trendi. — *T:* dönem · P25
393. Faturasız sevk (irsaliye) bekleyen satışlar. — *T:* `FATURALANDI=0` · P6,P28
394. Belirli ürünün müşteri bazında satış dağılımı. — *T:* ürün×müşteri · P24
395. Satış kanalı (POS/toptan/e-ticaret) kırılımı. — *T:* kanal ayrımı · P24
396. Faturalarda en sık uygulanan iskonto oranları. — *T:* iskonto dağılım · P24
397. İptal edilen faturaların sebep/kullanıcı analizi. — *T:* IPTAL; denetim · P18,P27
398. Aynı müşteriye aynı gün mükerrer fatura (hata). — *T:* mükerrer belge · P12
399. Mevsimsel ürünlerin satış sezonu haritası. — *T:* dönem×ürün · P24
400. Fatura tipi (satış/alış/iade) dağılımı ve doğru kodlama. — *T:* tek değerse yön çıkarma · P14
401. En kârlı satış günleri/kampanya dönemleri. — *T:* kâr×dönem · P22
402. Ürün bazlı satış büyüme/daralma (YoY). — *T:* çapraz-DB; reel · P5,P25
403. Faturalarda vergisel tutar bütünlüğü (KDV+ÖTV+tevkifat). — *T:* toplam kontrol · P11
404. Satış iadesi oranı yüksek dönemler/ürünler. — *T:* iade/satış · P28
405. Müşteri ilk alım → tekrar alım dönüşümü. — *T:* recency · P10
406. Boş/sıfır tutarlı fatura satırları (veri hatası). — *T:* tutar=0 · P11
407. Belirli ürün grubunun toplam satış payı. — *T:* grup payı · P24
408. Faturalarda eksik cari/stok bilgisi (entegrasyon riski). — *T:* eksik FK · P13
409. En yüksek indirimli satışların kâr etkisi. — *T:* iskonto vs kâr · P28
410. Satış tahmini için son 12 ay trend + mevsimsellik. — *T:* dönem; varsayım · P25
411. Fatura başına ortalama kalem sayısı (çapraz satış göstergesi). — *T:* satır/başlık · P23
412. Hizmet/masraf faturalarının ayrıştırılması. — *T:* `STOKHRK_ISLE=0` · P14
413. Satışların şube/depo bazında dağılımı. — *T:* şube segment · P24,P5
414. Bir kampanyanın satış artışına net etkisi. — *T:* önce/sonra; baz · P28,P25
415. Faturada uygulanan fiyatın liste fiyatından sapması. — *T:* fiyat vs liste · P11
416. En sadık (en sık alan) müşteriler. — *T:* frequency · P24
417. Satış ekibi/pazarlamacı performans karşılaştırması. — *T:* pazarlamacı segment · P24
418. Faturaların ödeme tipine göre dağılımı. — *T:* ödeme kanalı · P24
419. Ürün çıkışı ile fatura kesimi tarih uyumu. — *T:* STOKHR vs fatura tarih · P11
420. İade sonrası düzeltme faturası kesildi mi (yasal). — *T:* iade→düzeltme · P30
421. En çok geri dönen (iade) müşteri-ürün ikilileri. — *T:* iade çifti · P28
422. Satışların gün-hafta-ay bazlı büyüme oranı. — *T:* dönem trend · P25
423. Fatura kesme hızı (sipariş→fatura süresi). — *T:* zincir süre · P6
424. Belirli fiyatın üstü/altı satışların segmenti. — *T:* fiyat bandı · P24
425. Satış vergisi (KDV) toplamı dönem beyanına hazır mı. — *T:* `HESAPLANAN_KDV` · P11
426. Faturalarda tevkifatlı satış oranı. — *T:* tevkifat kod · P14
427. Aynı ürünün fiyatının müşteriye göre değişkenliği. — *T:* fiyat varyans · P24
428. Satış kaybı: teklif verilip faturaya dönmeyen. — *T:* teklif→fatura dönüşüm · P28
429. En çok stoksuz kalınan (kaçan satış) ürünler. — *T:* bakiye=0 talep · P10
430. Fatura iptal oranının zaman içinde değişimi. — *T:* IPTAL trend · P27
431. Ürün bazında ortalama satış fiyatı (ASP) trendi. — *T:* ASP; reel · P25
432. Büyük tutarlı tek seferlik satışlar (anomali/fırsat). — *T:* tutar aykırı · P11
433. Satışların coğrafi/bölgesel dağılımı. — *T:* bölge; PII agregat · P24,P15
434. Faturalarda sık birlikte gelen indirim+ürün paterni. — *T:* birliktelik · P23
435. e-Fatura ile kağıt fatura oranı (dönüşüm olgunluğu). — *T:* EFATURA_KULLAN · P19
436. Satış hedefi vs gerçekleşen (dönemsel). — *T:* hedef varsa; varsayım · P24
437. Faturalarda negatif satır (hatalı iade girişi). — *T:* negatif miktar · P11
438. En çok ciro yapan ama en çok iskonto alan müşteriler. — *T:* ciro vs iskonto · P24
439. Ürün lansmanı sonrası satış eğrisi. — *T:* ilk satış→trend · P10
440. Satışların ödeme vadesine göre nakit akış projeksiyonu. — *T:* vade → nakit · P9
441. Faturada birden çok KDV oranı olan karma belgeler. — *T:* satır KDV dağılımı · P11
442. Belirli müşterinin fiyat/iskonto ayrıcalığı makul mu. — *T:* özel koşul vs kâr · P24
443. Satış dönüşleri sonrası net ciro (brüt−iade). — *T:* iade netleştir · P28
444. Faturalarda açıklama/masraf merkezi eksikleri. — *T:* eksik alan · P13
445. En hızlı büyüyen ürün kategorileri. — *T:* YoY grup · P5,P25
446. Satış yoğun dönemde stok yeterliliği (kaçan fırsat). — *T:* talep vs stok · P10
447. Fatura başına kârlılık dağılımı (zararlı fatura oranı). — *T:* fatura kâr · P22
448. Kanal bazında iade oranı farkı. — *T:* kanal×iade · P28,P24
449. Satış verisinden müşteri segmentasyonu (kümeleme kaba). — *T:* RFM segment · P24
450. Dönemsel satış raporunu döviz bazına çevirerek reel büyüme. — *T:* reel; kur · P25,P20

---

## 6) e-DÖNÜŞÜM (#451–#520)

451. GİB'e gitmemiş, askıda e-Faturalar. — *T:* durum başlıkta; `EFATURA_DURUM=1`/GIB boş · P19
452. Otomatik gönderim hatası alan faturalar ve hata tipine göre gruplama. — *T:* `OTO_GONDERIM_HATA` · P19
453. e-Fatura mükellefi olduğu halde e-Arşiv/kağıt kesilen cariler. — *T:* mükellef vs senaryo · P19,P11
454. e-İrsaliyeler faturaya dönüşmüş mü, açık kalan var mı? — *T:* `FATURALANDI`+`EIRSALIYE_DURUM` · P6,P19
455. ETTN/GUID boş ama `EFATURA_KULLAN=1` olan başlıklar. — *T:* eşleşme eksik · P19,P13
456. e-Arşiv günlük raporu geciken belgeler (cezai risk). — *T:* rapor durumu/gün · P19,P10
457. e-Deftere aktarılmamış dönem/fiş (çapraz-DB). — *T:* `_GMUHASEBE` berat · P5,P19
458. Tevkifatlı e-Faturada tevkifat kodu/oranı eksik (red riski). — *T:* `TEVKIFAT_KODU` boş · P14,P19
459. İptal edilen e-Faturaların GİB'de iptali işlenmiş mi? — *T:* yerel IPTAL vs GIB durum · P19,P27
460. e-Fatura GİB yanıt kodu (numeric) dağılımı ve anlamı. — *T:* kod→anlam entegratör · P14,P19
461. Ticari senaryo (`EFATURA_SENARYO=2`) faturalarda alıcı yanıtı bekleyenler. — *T:* red/kabul akışı · P19
462. e-Fatura numara sırası kırılması (denetim). — *T:* seri bazında sıra · P12
463. e-Arşiv vs e-Fatura yanlış seçilmiş belgeler. — *T:* alıcı mükellefiyeti · P19,P11
464. Entegratör/mali mühür sertifikası süresi dolmak üzere. — *T:* sertifika tarihi · P19,P10
465. e-İrsaliyede şoför/plaka bilgisi eksik gönderimler. — *T:* `SOFOR_*`/`ARAC_PLAKA`; PII · P13,P15
466. İstisna kodlu (KDV'siz) e-Faturalarda istisna kodu eksik. — *T:* `ISTISNA_KODU` boş · P14,P19
467. e-Fatura gönderim başarı oranı (askıda / toplam). — *T:* süreç oranı · P28,P19
468. İhracat e-Faturaları doğru senaryo/GTIP ile mi? — *T:* ihracat senaryo · P19
469. Aynı belgenin hem e-Fatura hem kağıt kesilmesi (mükerrer). — *T:* mükerrer belge · P12
470. e-SMM (serbest meslek) kullanılıyorsa eksik/askıda olanlar. — *T:* modül var mı · P19,P14
471. e-Fatura reddedilen/itiraz edilen belgeler ve sebepleri. — *T:* red durumu · P19
472. Mükellef listesi güncel mi (yeni geçen mükellefler kaçırılmış). — *T:* liste vs cari · P11
473. e-Belge ile fatura başlık tutarları uyuşmuyor. — *T:* GUID vs tutar · P11,P19
474. e-Arşiv faturalarında internet satışı işaretlemesi doğru mu? — *T:* satış tipi · P19
475. Gönderilemeyen belgelerin dönem/tutar özeti (gelir riski). — *T:* askıda × tutar · P19,P10
476. e-İrsaliye→e-Fatura eşleşme kopukluğu. — *T:* belge zinciri · P6,P19
477. e-Fatura gönderim gecikmesi (kesim→gönderim gün). — *T:* tarih farkı · P19,P28
478. Tevkifat iadesi (`FATURA_TEVKIFAT_IADE`) kayıtlarının tutarlılığı. — *T:* iade eşleştir · P28
479. e-Belge arşiv/saklama süresi (yasal) kontrolü. — *T:* saklama süresi · P30
480. e-Fatura senaryosu yanlış (Temel/Ticari) belgeler. — *T:* senaryo vs cari · P19
481. GİB'den gelen gelen-fatura (alış e-faturaları) işlenmiş mi? — *T:* gelen belge · P19,P6
482. e-Arşiv iptal süreci ile e-Fatura iptal farkı doğru uygulanmış mı? — *T:* süreç farkı · P19,P30
483. Belge bazında entegratör/GİB portal tutarsızlığı. — *T:* iki kaynak · P11
484. e-Fatura kullanmayan aktif cari sayısı (dönüşüm fırsatı). — *T:* `EFATURA_KULLAN=0` · P13
485. e-Dönüşüm otomasyonu (oto-gönderim) açık mı? — *T:* ayar/özellik · P13
486. Vergi numarası/TCKN hatalı e-Fatura alıcıları. — *T:* kimlik doğrulama; PII · P15
487. e-Fatura tutarları ile KDV beyanı uyumu. — *T:* toplam mutabakat · P11
488. e-İrsaliyede taşıyıcı/araç bilgisi zorunlu alan eksikleri. — *T:* zorunlu alan · P13
489. e-Belge gönderiminde tekrar deneme (retry) gereken kuyruk. — *T:* hata durumu · P19
490. e-Fatura ortalama onay süresi (GİB yanıt gecikmesi). — *T:* durum tarih · P19,P28
491. Kamu kurumuna kesilen faturalarda özel senaryo. — *T:* `KAMU_KURUMU` · P19
492. e-Arşiv raporu dışında kalmış (rapor edilmemiş) belgeler. — *T:* rapor kapsamı · P19
493. İade/düzeltme e-Faturalarının orijinalle bağı. — *T:* referans belge · P6,P30
494. Sık hata veren cariler (alıcı kaynaklı gönderim sorunu). — *T:* cari×hata · P19
495. e-Fatura zarf/uygulama yanıtı bekleyen belgeler. — *T:* zarf durumu · P19
496. Dönem bazında e-Fatura/e-Arşiv adet ve tutar özeti. — *T:* dönem agregat · P24,P19
497. e-Defter beratı alınmamış aylar. — *T:* çapraz-DB berat · P5,P19
498. e-Fatura kesiminde yuvarlama/kuruş farkı hataları. — *T:* tutar bütünlüğü · P11
499. e-Belge saklama/yedekleme durumu (arşiv bütünlüğü). — *T:* arşiv · P30
500. e-Dönüşüm olgunluk skoru (dönüşüm oranı + hata oranı). — *T:* birleşik metrik · P28
501. Gönderilen ama GİB onayı gelmeyen (belirsiz) belgeler. — *T:* durum boşluğu · P19
502. e-Fatura ile stok/muhasebe entegrasyonu kopuk belgeler. — *T:* entegrasyon bayrağı · P5
503. Yanlış vergi dairesi/mükellef bilgisiyle kesilenler. — *T:* cari bilgi doğrulama · P11
504. e-İrsaliye iptal/itiraz durumundakiler. — *T:* irsaliye durum · P19
505. e-Fatura hacmine göre entegratör paket/kontör yeterliliği. — *T:* hacim tahmini · P24
506. Test/gerçek ortam karışması (yanlış ortamda kesim). — *T:* ortam bayrağı · P19
507. Alıcının reddettiği ticari faturalara yanıt verilmiş mi? — *T:* yanıt süresi · P19
508. e-Fatura numaralarında yıl/seri geçiş tutarlılığı. — *T:* seri geçiş · P12,P21
509. Belge tipine göre (satış/iade/tevkifat) e-Fatura dağılımı. — *T:* tip segment · P24
510. Gönderim hatası kronik olan belge tipleri (kök neden). — *T:* hata paterni · P19
511. e-Arşiv internet satışı ödeme/kargo bilgisi eksikleri. — *T:* zorunlu alan · P13
512. e-Fatura → muhasebe fişi otomatik oluşmuş mu? — *T:* çapraz-DB entegrasyon · P5
513. Mükellef olmayana e-Arşiv yerine e-Fatura kesme hatası. — *T:* senaryo yanlış · P19
514. Dönemsel e-Fatura kesim yoğunluğu (kapasite planlama). — *T:* zaman paterni · P26
515. e-Belge imza/mühür hatası alan kesimler. — *T:* imza hatası · P19
516. Uzun süredir askıda kalan en eski belgeler (öncelik). — *T:* askıda + yaş · P10,P19
517. İptal edilmiş ama muhasebeye düşmüş e-Fatura. — *T:* iptal vs muhasebe · P5,P27
518. e-Fatura alıcı yanıt oranı (ticari senaryo). — *T:* yanıt oranı · P28
519. Yıl sonu e-Defter kapanış beratı eksik mi? — *T:* dönem berat · P21,P5
520. e-Dönüşüm hata loglarının kök-neden dağılımı. — *T:* log paterni · P19,P26

## 7) KDV / ÖTV / TEVKİFAT (#521–#570)

521. Eski KDV oranı (8/18) taşıyan aktif kartlar. — *T:* asla otomatik değiştirme · P30
522. Alış KDV oranı ≠ satış KDV oranı olan ürünler. — *T:* `KDV_ORANI` vs `KDV_ORANI_ALIS` · P11
523. Dönem hesaplanan/indirilecek KDV özeti. — *T:* `FATURA_KDV`; tevkifat ayrı · P11
524. ÖTV'li ürünlerin ÖTV kurgusu (matrah/oran) doğru mu? — *T:* ÖTV KDV'den önce · P11
525. Tevkifatlı satış oran/kod dağılımı ve eksikleri. — *T:* kod eşleme · P14
526. İhraç kayıtlı satışlar doğru işaretli mi? — *T:* `IHRAC_KAYDI`; KDV işleyiş · P30
527. İstisna (KDV'siz) satışlarda istisna kodu doğruluğu. — *T:* `ISTISNA_KODU` · P14
528. KDV beyanı ile Wolvox KDV toplamı mutabakatı. — *T:* çapraz-DB; SMMM · P5,P30
529. Tevkifat kod-oran eşlemesi güncel tebliğe uygun mu? — *T:* mevzuat teyidi · P30
530. Karma KDV oranlı faturalarda satır bazında doğru dağılım. — *T:* satır KDV · P11
531. KDV dahil/hariç fiyat girişinde tutarsızlık. — *T:* KDV yönü · P2,P11
532. Tevkifatlı faturada alıcının tevkifat yükümlülüğü doğru mu? — *T:* alıcı türü · P14
533. ÖTV maktu mu nispi mi — doğru uygulanmış mı? — *T:* ÖTV tipi · P14
534. KDV oranı 0 olan ama istisna kodsuz satırlar. — *T:* KDV0 + kod yok · P13
535. İade faturalarında KDV düzeltmesi doğru mu? — *T:* iade KDV · P28
536. Tevkifat iadesi talep edilebilecek tutarlar. — *T:* tevkifat iade; SMMM · P30
537. Dönemler arası KDV devreden/ödenecek geçişi. — *T:* dönem devir · P21
538. Yanlış KDV oranıyla kesilmiş (mevzuat dışı) belgeler. — *T:* oran vs ürün · P11,P30
539. ÖTV'ye tabi olmayana ÖTV, tabi olana eksik ÖTV. — *T:* ÖTV kapsam · P11
540. Tevkifat kodu ürün/hizmet tipiyle uyumlu mu? — *T:* kod-tip eşleşme · P14
541. KDV oran değişikliğinin geçmiş fiyatlara etkisi (rapor). — *T:* asla geriye değiştir · P30
542. Vergisiz (istisna) müşteri satışlarının doğruluğu. — *T:* müşteri istisna · P11
543. Faturada KDV tutarı ile oran×matrah tutmuyor. — *T:* hesap bütünlüğü · P11
544. Tevkifatlı e-Faturaların GİB uyumu (red riski). — *T:* tevkifat + e-fatura · P14,P19
545. ÖTV+KDV birlikte olan ürünlerde hesap sırası. — *T:* ÖTV→KDV sıra · P11
546. KDV istisnası olan ihracat/serbest bölge satışları. — *T:* istisna kod · P14
547. Vergi kodları eksik/yanlış cariler (fatura reddi). — *T:* cari vergi bilgi · P11
548. Dönem KDV yükü trendi (efektif KDV oranı). — *T:* KDV/ciro · P25
549. Tevkifat oranı 1/2 alanlarının doğru kullanımı. — *T:* `TEVKIFAT_ORANI_1/2` · P14
550. Tevkifata tabi hizmet satışlarında eksik uygulama. — *T:* hizmet tevkifat · P14
551. KDV matrahına dahil edilmeyen unsurlar (navlun vb.). — *T:* matrah bileşen · P11
552. ÖTV beyanına esas ürün hareketleri. — *T:* ÖTV ürün · P11
553. İndirilecek KDV'nin belgeli olması (alış faturası eşleşme). — *T:* alış KDV belge · P6
554. Yıl içi KDV oran değişikliği olan ürünlerin belge tutarlılığı. — *T:* tarih×oran · P21
555. Vergi dairesi/mükellef değişikliği geç yansıyan cariler. — *T:* güncelleme gecikme · P11
556. Fatura iptalinin KDV beyanına etkisi. — *T:* iptal KDV · P27
557. Tevkifatlı alışlarda karşı tevkifat kaydı. — *T:* alış tevkifat · P14
558. ÖTV'li stok hareketlerinin maliyete etkisi. — *T:* ÖTV maliyet · P8
559. KDV'siz satışın kâr raporunda doğru yansıması. — *T:* KDV0 kâr · P29
560. Dönem sonu KDV mahsup/iade pozisyonu. — *T:* devreden KDV · P21
561. Belge bazında vergi kodları tutarlılık taraması. — *T:* toplu vergi kontrol · P11
562. Yanlış istisna koduyla e-Fatura reddi alanlar. — *T:* istisna→red · P14,P19
563. Tevkifat oranı değişen dönemlerde eski oran kalması. — *T:* oran güncelliği · P30
564. ÖTV oranı güncel mevzuata uygun mu (akaryakıt vb.). — *T:* mevzuat · P30
565. KDV tevkifatının cari bakiyeye etkisi (tahsil edilmeyen KDV). — *T:* tevkifat bakiye · P7
566. Vergisel toplamların (KDV/ÖTV/tevkifat) belge geneli tutarlılığı. — *T:* toplam kontrol · P11
567. Muhtasar/damga gibi diğer vergilerin izi (varsa). — *T:* diğer vergi · P14
568. Yıllık KDV yükü ve efektif oran karşılaştırması (YoY). — *T:* çapraz-DB · P5,P25
569. Vergi istisnası kötüye kullanım kontrolü (denetim). — *T:* anomali · P11,P30
570. Vergi raporlarında SMMM verisiyle mutabakat. — *T:* fiili vs resmi · P5,P30

## 8) GENEL MUHASEBE & ÇAPRAZ-DB (#571–#625)

571. Muhasebeleşmemiş fatura/kasa/banka fişleri. — *T:* `GM_ENTEGRASYON`; ayrı DB · P5,P13
572. Mizanda ters bakiyeli hesaplar. — *T:* `_GMUHASEBE.HESAP_PLANI` yön · P5,P14
573. Entegrasyon şablonu eksik cari/stok grupları. — *T:* `MUH_*` boş · P13,P5
574. Yıllar arası ciro/kâr trendi. — *T:* çapraz-DB UNION; reel · P5,P25
575. Kasa/banka defteri muhasebe hesabıyla mutabık mı? — *T:* çapraz-DB mutabakat · P5,P11
576. Cari bakiye 120/320 hesabıyla uyuşuyor mu? — *T:* köprü kod mutabakat · P5,P11
577. Açılış devri eksik hesaplar (yıl geçişi). — *T:* `DEVIR=1` yok · P21,P5
578. Hangi yıl/firma/modül DB'leri mevcut? — *T:* `sys.databases` keşif · P5
579. Muhasebeleştirme hataları (eşleşmeyen fiş). — *T:* belge vs yevmiye · P5,P11
580. Hesap planı boşlukları/eksik hesaplar. — *T:* plan tamlığı · P5
581. Yevmiye ile yardımcı defter tutarlılığı. — *T:* `YEVMIYE`/`YEVMIYEHR` · P5,P11
582. Dönemsel gelir tablosu (kaba) çapraz-DB. — *T:* gelir/gider hesap · P5
583. Bilanço hesaplarının dönem geçiş tutarlılığı. — *T:* devir · P21,P5
584. Farklı firma (001/002) verilerini karıştırmadan konsolidasyon. — *T:* firma ayrı işletme · P5
585. Muhasebe kur değerleme (dönem sonu döviz hesap). — *T:* kur değerleme · P20,P5
586. KDV hesaplarının (191/391) beyanla uyumu. — *T:* hesap vs beyan · P5,P11
587. Masraf merkezleri bazında gider dağılımı. — *T:* masraf merkezi · P24,P5
588. Amortisman kayıtlarının düzenliliği (varsa). — *T:* demirbaş modül · P5,P14
589. Ters kayıt/düzeltme fişi yoğunluğu (iç kontrol). — *T:* düzeltme frekansı · P18,P5
590. Muhasebeleşmiş ama iptal edilmiş belge tutarsızlığı. — *T:* iptal vs fiş · P27,P5
591. Yıl sonu kapanış/açılış fişi eksikliği. — *T:* kapanış · P21,P5
592. Çek/senet muhasebe hesaplarıyla portföy mutabakatı. — *T:* `GM_CEKSENET` · P5,P11
593. Personel bordro entegrasyonu (`_IKAYNAK` DB). — *T:* modül DB · P5
594. Muhasebe entegrasyon şablonlarının güncelliği. — *T:* şablon vs güncel plan · P5
595. Enflasyon düzeltmesi gereken hesaplar (varsa). — *T:* reel · P25,P5
596. Alış/satış faturalarının muhasebeleşme oranı. — *T:* süreç oranı · P28,P5
597. Banka kredisi/faiz hesaplarının takibi. — *T:* kredi hesap · P5
598. Dönem karşılaştırmalı mizan (bu yıl vs geçen yıl). — *T:* çapraz-DB · P5,P25
599. Muhasebe fişi olmayan büyük tutarlı belgeler. — *T:* eksik fiş · P13,P5
600. Hesap bazında hareket yoğunluğu (anomali). — *T:* hareket dağılım · P5,P11
601. Cari-muhasebe köprüsünde eşleşmeyen kayıtlar. — *T:* köprü kod · P5,P11
602. Stok maliyet muhasebesi (150/620) tutarlılığı. — *T:* stok hesap · P5,P8
603. Gelir/gider tahakkuk-tahsil farkı. — *T:* tahakkuk esası · P5
604. Yıllar arası aynı hesabın bakiye evrimi. — *T:* çapraz-DB hesap · P5,P25
605. Muhasebeleştirmede tarih uyumsuzluğu (belge vs fiş). — *T:* tarih farkı · P5,P11
606. Vergi karşılıkları ve peşin ödenen vergiler. — *T:* karşılık hesap · P5
607. Kasa hesabı ile fiili kasa mutabakatı. — *T:* çapraz-DB kasa · P5,P11
608. Şüpheli alacak karşılığı muhasebe kaydı. — *T:* karşılık; SMMM · P5,P30
609. Muhasebe hesap planı derinliği/kullanımı. — *T:* plan kullanım · P5
610. Dönem sonu döviz hesaplarının değerleme farkı. — *T:* kur farkı · P20,P5
611. Entegrasyonsuz manuel fişlerin oranı. — *T:* manuel vs oto · P5,P28
612. Muhasebe ile stok değerinin dönem sonu uyumu. — *T:* stok vs 153 · P5,P8
613. Farklı yıl DB'lerinde şema farkı (kolon eklenmiş). — *T:* schema-first her DB · P5
614. Banka kredisi geri ödeme planı takibi. — *T:* kredi taksit · P5,P9
615. Muhasebe dışı kalan gelir/gider kalemleri. — *T:* eksik kayıt · P13,P5
616. Sabit kıymet alım/satış muhasebesi. — *T:* demirbaş · P5
617. Dönemsel nakit akış tablosu (kaba, çapraz-DB). — *T:* kasa+banka+çek · P5,P9
618. Hesap mutabakatı için yıl-sonu çalışma kağıdı. — *T:* mutabakat seti · P5
619. Muhasebeleştirme kuyruğunda bekleyen belge yaşı. — *T:* bekleme + yaş · P10,P5
620. Yanlış hesaba kaydedilen (kod hatası) fişler. — *T:* hesap kod hatası · P5,P11
621. Firma bazında ayrı mizan ve konsolide görünüm. — *T:* firma ayrımı · P5
622. Muhasebe verisi SMMM'de tutuluyorsa senkron gecikmesi. — *T:* dış muhasebe · P5
623. Yıllık amortisman ve yeniden değerleme etkisi. — *T:* reel; demirbaş · P25,P5
624. Dönem kârının muhasebe vs operasyonel farkı. — *T:* fiili vs resmi · P29,P5
625. Muhasebe entegrasyon hatalarının log analizi. — *T:* hata log · P5,P26

## 9) SİPARİŞ, TEDARİK & DEPO (#626–#695)

626. Açık (teslim edilmemiş) müşteri siparişleri ve geciken teslimatlar. — *T:* durum kodu; teslim tarihi · P14,P6
627. Stok bloke eden bekleyen siparişler (kilitli sermaye). — *T:* `STOK_BLOKE` · P7,P6
628. Açık alış siparişleri ve gelmeyen ürünler. — *T:* alış türü; gecikme · P6,P14
629. Teklif→sipariş→fatura dönüşüm oranı (huni). — *T:* zincir dönüşüm · P28,P6
630. Tedarik süresi uzun, güvenlik stoğu yetersiz ürünler. — *T:* lead time vs min · P10,P6
631. Yanlış terminal→depo eşlemesi (hareket yanlış depoda). — *T:* varsayılan depo · P24
632. Konsinye/emanet stok karışması. — *T:* depo/özel kod ayrımı · P3
633. Min/max seviyeye göre otomatik sipariş önerisi. — *T:* max−bakiye−açık sipariş · P10,P7
634. Kısmi teslim edilmiş siparişlerin kalanı. — *T:* `SIPARIS_TESLIM_DETAY` · P6
635. Sipariş vs fatura miktar/fiyat sapması. — *T:* sipariş vs fatura · P11,P6
636. En çok sipariş iptali olan müşteri/ürün. — *T:* iptal oranı · P28
637. Tedarikçi teslimat performansı (söz vs gerçek). — *T:* teslim tarihi sapma · P6
638. Sipariş karşılama oranı (fill rate). — *T:* teslim/sipariş · P28
639. Bekleyen siparişlerin nakit/stok etkisi. — *T:* açık sipariş değeri · P7
640. Aynı ürün için birden çok açık tedarik siparişi (mükerrer). — *T:* mükerrer sipariş · P12
641. Teslim tarihi geçmiş açık siparişler (gecikme yaşı). — *T:* gecikme + yaş · P10,P6
642. Sipariş→sevk→fatura zinciri kopuk olanlar. — *T:* eksik halka · P6
643. Tedarikçi bazında ortalama tedarik süresi. — *T:* sipariş→giriş · P6
644. Sezonluk talep için erken sipariş planı. — *T:* dönem talep · P10
645. Depo transfer talepleri karşılanmayanlar. — *T:* transfer durum · P6
646. Sipariş bloke süresi çok uzayan ölü blokeler. — *T:* eski bloke · P10,P7
647. Müşteri siparişi karşılamak için stok yeterliliği. — *T:* talep vs bakiye · P7,P6
648. Tedarikçi fiyat teklifleri karşılaştırması. — *T:* alış teklif · P24
649. Sipariş durumları kod dağılımı ve anlamı. — *T:* durum kod teyit · P14
650. Otomatik satın alma önerisinin doğruluğu (min tanımlı mı?). — *T:* min yoksa öneri eksik · P13,P10
651. Depo bazında sipariş karşılama kapasitesi. — *T:* depo stok · P24
652. Tedarik zincirinde darboğaz ürünler (sık stoksuz). — *T:* stockout frekans · P10
653. Sipariş öncelik/aciliyet yönetimi (VIP müşteri). — *T:* öncelik · P24
654. Faturalanmamış sevk (irsaliyeli teslimat). — *T:* `FATURALANDI=0` · P6,P28
655. Depolar arası transfer dengesizliği (bir depo hep verici). — *T:* transfer akış · P24
656. Sipariş iptallerinin sebep analizi. — *T:* iptal sebep · P14
657. Tedarikçi bazında iade/red oranı. — *T:* alış iade · P28
658. Kritik ürünlerde çift tedarikçi (risk azaltma) var mı? — *T:* tek kaynak riski · P24
659. Sipariş teslim süresinin müşteri memnuniyetine etkisi (proxy). — *T:* teslim gün · P6
660. Depo doluluk/kapasite dengesi. — *T:* depo miktar · P24
661. Bekleyen alış siparişlerinin nakit çıkış projeksiyonu. — *T:* açık sipariş vade · P9,P6
662. Sipariş büyüklüğü optimizasyonu (EOQ kaba). — *T:* sipariş/tutma maliyeti · P29
663. Ürün bazlı sipariş sıklığı ve miktar paterni. — *T:* sipariş paterni · P24
664. Tedarikçi teslimat eksikliği (kısmi gelen). — *T:* sipariş vs giriş · P6
665. Depo transfer maliyeti/sıklığı optimizasyonu. — *T:* transfer analiz · P24
666. Sipariş onay sürecinde bekleyenler. — *T:* `BELGE_ONAY_DURUMU` · P14
667. Mevsimsel ürünlerde erken/geç sipariş riski. — *T:* dönem × sipariş · P10
668. Stok bloke edilen ama sonra iptal olan siparişler. — *T:* bloke israfı · P7
669. Tedarikçi ödemeleri ile teslimat ilişkisi (ödeme koşulu). — *T:* ödeme vs teslim · P9
670. Açık sipariş yaşlandırması (30/60/90 gün). — *T:* sipariş yaşı · P9,P6
671. Ürün bazında sipariş karşılama süresi trendi. — *T:* teslim trend · P25
672. Sevk edilen ama teslim onayı gelmeyen. — *T:* teslim durum · P6
673. Depo lokasyon optimizasyonu (hızlı ürün ön rafa). — *T:* devir × lokasyon · P22
674. Sipariş miktarı ile fiili satış tutarlılığı (aşırı/eksik sipariş). — *T:* sipariş vs satış · P11
675. Bayi/şube sipariş senkron kopukluğu (standart-dışı katman). — *T:* native-dışı · P11
676. Tedarikçi bağımlılık riski (tek tedarikçiye yoğunlaşma). — *T:* konsantrasyon · P24
677. Sipariş → üretim → sevk zinciri (üretim varsa). — *T:* modül var mı · P6,P14
678. Depo sayımı ile sipariş bekleyen stok tutarlılığı. — *T:* sayım vs bloke · P11
679. Geç teslim eden tedarikçilerin stoksuzluğa etkisi. — *T:* gecikme→stockout · P6,P10
680. Sipariş öncesi stok kontrolü yapılıyor mu (mükerrer alım)? — *T:* aşırı stok · P7
681. Müşteri sipariş geçmişinden talep tahmini. — *T:* geçmiş → tahmin · P25
682. Depo bazında hareket yoğunluğu ve personel planlama. — *T:* hareket paterni · P26
683. Açık siparişlerin döviz/kur riski (ithal sipariş). — *T:* döviz sipariş · P20
684. Sipariş iptali sonrası stok blokesi kalkmış mı? — *T:* bloke temizliği · P7
685. Tedarik maliyeti (nakliye dahil) karşılaştırması. — *T:* toplam tedarik maliyeti · P29
686. En uzun teslim süreli (bottleneck) ürünler. — *T:* lead time sıralama · P6
687. Sipariş büyüklüğü ile iskonto ilişkisi (hacim indirimi). — *T:* miktar iskonto · P8
688. Depo transfer sonrası bakiye tutarlılığı. — *T:* transfer denge · P7,P11
689. Sevk irsaliyesi kesildi ama fatura süresi aşıldı. — *T:* irsaliye→fatura süre · P6,P28
690. Ürün bazlı sipariş karşılanamama (lost sales) tahmini. — *T:* talep−stok · P10
691. Tedarikçi puanlama (fiyat+teslim+kalite). — *T:* çok faktör · P24
692. Sipariş verilerinden mevsimsel talep haritası. — *T:* dönem talep · P25
693. Depo min/max ayarlarının fiili tüketimle uyumu. — *T:* ayar vs gerçek · P10
694. Bloke stokun yaşı ve serbest bırakma önerisi. — *T:* bloke yaş · P10,P7
695. Sipariş-tedarik döngüsünün nakit döngüsüne (CCC) etkisi. — *T:* döngü süresi · P9

---

## 10) ÇEK/SENET, BANKA & KASA (#696–#755)

696. Portföydeki çeklerin vade dağılımı, bu ay tahsil edilecekler. — *T:* `EVRAK_DURUMU`; PII maskele · P14,P15
697. Karşılıksız/protestolu çek riski taşıyan müşteriler. — *T:* `PROTESTO_OLDU`; KVKK · P15
698. Cirolanan çeklerin takip zinciri (kime ciro). — *T:* ciro durumu; karşı taraf PII · P14,P15
699. Vadesi gelen kendi senetlerimiz (nakit ihtiyacı). — *T:* borç senedi vade · P9
700. Kasa açığı/fazlası veren günler. — *T:* günlük `KPB_GLTUT−KPB_GDTUT` · P7,P11
701. Banka hareketleri ekstreyle mutabık mı (eksik/çift). — *T:* tarih-tutar eşleşme · P11
702. Tahsilat kanalı dağılımı (nakit/kart/çek). — *T:* kanal; POS komisyon · P24
703. Çek/senet portföy toplamı ve likidite projeksiyonu. — *T:* vade takvimi · P9
704. Bankada bekleyen ama deftere işlenmemiş hareketler. — *T:* ekstre vs defter · P11
705. Kasa bakiyesi negatife düşen anlar (imkânsız). — *T:* sıra/eksik kayıt · P7,P11
706. Çek tahsil edilemedi (karşılıksız) sonrası muhasebe düzeltmesi. — *T:* karşılıksız süreç · P14
707. Manuel kasa yerine banka entegrasyonu fırsatı. — *T:* kanal otomasyon · P13
708. Verilen çeklerin banka bakiyesine etkisi (vade sonu). — *T:* borç çek vade · P9
709. Banka komisyon/masraf kayıtları eksik mi? — *T:* masraf kalemi · P11
710. Çek/senet vade yaşlandırması (tahsil olasılığı). — *T:* vade kova · P9
711. Kasa devir hızı (günlük giriş/çıkış dengesi). — *T:* günlük net · P7
712. Aynı çekin mükerrer kaydı (çift giriş). — *T:* mükerrer evrak · P12
713. Banka kredisi taksit ödemeleri takvimi. — *T:* kredi taksit · P9
714. Çek ciro zincirinde kopukluk (kayıp evrak). — *T:* ciro zinciri · P14
715. Tahsil edilen çeklerin banka hesabına yansıması. — *T:* çek→banka · P6
716. Kasa sayımı ile sistem bakiyesi farkı. — *T:* sayım vs sistem · P11
717. Vadeli çeklerin nakit akışına katkısı (projeksiyon). — *T:* vade nakit · P9
718. Protesto sonrası hukuki takibe geçen evraklar. — *T:* durum; PII · P15
719. Banka hesapları arası virman tutarlılığı. — *T:* virman eşleşme · P11
720. Çek/senet teminata verilenler (kullanılabilir mi). — *T:* `TEMINAT_MI` · P14
721. Kasa fişlerinde açıklama/karşı hesap eksikleri. — *T:* eksik alan · P13
722. Ödeme aracı bazında maliyet (POS komisyon, çek tahsil masrafı). — *T:* net tahsilat · P24
723. Gün sonu kasa kapanışı yapılmayan günler. — *T:* kapanış eksik · P11
724. Bankadaki bloke/teminat tutarları. — *T:* bloke bakiye · P7
725. Çek portföyünün müşteri bazında yoğunlaşması (risk). — *T:* konsantrasyon; PII · P15,P24
726. Vadesi geçmiş tahsil edilmemiş senetler. — *T:* geçmiş vade · P9
727. Nakit tahsilatların bankaya yatırılma gecikmesi. — *T:* kasa→banka gün · P6
728. Banka bakiyesi ile muhasebe 102 hesabı uyumu. — *T:* çapraz-DB · P5,P11
729. Çek/senet ciro ile cari bakiye etkisi. — *T:* ciro→bakiye · P7
730. Döviz kasası/banka hesabı kur değerleme. — *T:* döviz değerleme · P20
731. Kredi kartı POS tahsilatları ile banka yansıması. — *T:* POS→banka; komisyon · P6
732. Kasa/banka arası tutarsız transfer kayıtları. — *T:* transfer eşleşme · P11
733. Ödenmemiş kendi çeklerimizin nakit riski (vade yoğunluğu). — *T:* borç çek yığılma · P9
734. Tahsilat tahmini (portföy vade + tahsil olasılığı). — *T:* vade × olasılık · P9
735. Banka ekstresi otomatik içe aktarımı kullanılıyor mu? — *T:* otomasyon · P13
736. Kasa hareketlerinde olağandışı büyük tutarlar (anomali). — *T:* tutar aykırı · P11
737. Çek/senet bordro (`CEK_SENET_BORDRO`) tutarlılığı. — *T:* bordro vs portföy · P11
738. Vadesinde tahsil edilen vs edilmeyen çek oranı. — *T:* tahsil oranı · P28
739. Banka hesapları arası bakiye dağılımı ve atıl nakit. — *T:* hesap bakiye · P24
740. Kasa çıkışlarının onaysız/belgesiz olanları. — *T:* belge eksik · P13
741. Vadeli senet portföyünün iskontoya uygunluğu (finansman). — *T:* vade iskonto · P9
742. Çek/senet reeskont hesabı (dönem sonu). — *T:* reeskont · P5
743. Nakit döngüsü (tahsilat vadesi − ödeme vadesi). — *T:* CCC · P9
744. Bankada eksik/yanlış IBAN kayıtları. — *T:* IBAN; PII · P15,P13
745. Çeklerin banka durumu (`BANKA_DURUMU`) takibi. — *T:* durum kod · P14
746. Kasa personeli bazında işlem yoğunluğu (iç kontrol). — *T:* kullanıcı; denetim · P18
747. Ödeme planı vs fiili ödeme uyumu (tedarikçi). — *T:* plan vs gerçek · P9
748. Portföydeki en yüksek tutarlı evraklar (öncelik izleme). — *T:* tutar sıralama · P24
749. Çek/senet karşılıksız oranı trendi (risk artışı). — *T:* karşılıksız trend · P25
750. Banka masraflarının gider olarak muhasebeleşmesi. — *T:* masraf→muhasebe · P5
751. Kasa fazlası nakit bankaya değerlendirme (atıl nakit). — *T:* kasa fazlası · P7
752. Vade tarihine göre nakit akış takvimi (tahsil+ödeme). — *T:* birleşik takvim · P9
753. Çek girişi ile satış faturası eşleşmesi. — *T:* çek→fatura · P6
754. Banka/kasa mutabakat farkı raporu. — *T:* mutabakat · P11
755. Ödeme/tahsilat işlemlerinde çift kayıt taraması. — *T:* mükerrer işlem · P12

## 11) ÇOKLU-YIL, DEVİR & DÖNEM (#756–#800)

756. Çalışma yılı takvimden geri — sorun mu, normal mi? — *T:* çalışma yılı ≠ takvim; kullanıcıya sor · P21
757. Yıl sonu devrinde taşınan bakiyeler kontrol listesi. — *T:* stok/cari/çek/banka devir · P21
758. Geçen yıla göre büyüme (LFL, aynı ay). — *T:* çapraz-DB; enflasyon · P5,P25
759. Kapanan yıla düzeltme faturası (yasal yol). — *T:* geçmişe belge yasak · P30
760. Çok firmalı (001/002) konsolide rapor. — *T:* firma ayrı işletme · P5
761. Hangi yıl DB'leri arşivlenebilir/küçültülebilir? — *T:* yasal saklama · P30,P5
762. Açılış devri eksik hesaplar (bakiye sıfır görünüyor). — *T:* `DEVIR=1` yok · P21
763. Devir hareketlerinin analiz dışı bırakılması. — *T:* `DEVIR=1` filtre · P21
764. Yıllar arası şema değişikliği (kolon eklenmiş/silinmiş). — *T:* her DB schema-first · P5
765. Dönem karşılaştırmalı ciro/kâr (reel bazda). — *T:* enflasyon düzelt · P25
766. Devir sonrası stok bakiyesi tutarlılığı. — *T:* devir denge · P21,P7
767. Cari açılış bakiyesi ile önceki yıl kapanışı uyumu. — *T:* kapanış=açılış · P21
768. Çek/senet portföyünün yıl geçişinde taşınması. — *T:* portföy devir · P21
769. Yıllar arası enflasyon etkisiyle nominal ciro yanılgısı. — *T:* reel/döviz · P25
770. Dönem kilitleme (kapalı döneme kayıt) kontrolü. — *T:* kapalı dönem · P30
771. Devir yapılmadan yeni yıla geçiş riski. — *T:* devir eksik uyarı · P21
772. Yıl bazında müşteri kazanım/kayıp trendi. — *T:* çapraz-DB churn · P5
773. Aynı ürünün yıllar arası fiyat/maliyet evrimi. — *T:* çapraz-DB; reel · P5,P25
774. Dönemsel KDV/vergi yükü karşılaştırması. — *T:* çapraz-DB · P5
775. Yıl sonu stok değerlemesi (maliyet yöntemi). — *T:* yöntem beyanı · P29,P21
776. Devreden/ödenecek KDV'nin yıl geçişi. — *T:* KDV devir · P21
777. Çok yıllı trend için tarih hizalama (aynı gün pencere). — *T:* pencere hizalama · P5,P25
778. Kapanış fişleri eksik yıllar. — *T:* kapanış · P21,P5
779. Firma kodu farklı DB'leri yanlışlıkla birleştirme riski. — *T:* firma ayrımı · P5
780. Devir bakiyeleri ile açılış mizanı uyumu. — *T:* çapraz-DB devir · P21,P5
781. Yıllar arası personel/bordro trendi (`_IKAYNAK`). — *T:* modül DB · P5
782. Sezonluk döngünün yıldan yıla tutarlılığı. — *T:* mevsim trend · P25
783. Eski yıl verisine erişim performansı (arşiv DB). — *T:* arşiv salt-okunur · P26,P5
784. Dönem sonu döviz değerleme farkının taşınması. — *T:* kur değerleme · P20,P21
785. Yıl içi ürün gamı değişimi (giren/çıkan ürünler). — *T:* katalog evrimi · P10
786. Çok yıllı kârlılık trendi (reel). — *T:* çapraz-DB kâr; reel · P5,P25,P29
787. Devir sırasında oluşan bakiye tutarsızlıkları. — *T:* devir hata · P21,P11
788. Yıl bazında iade/iptal oranı değişimi. — *T:* çapraz-DB · P5,P28
789. Kapanmış dönemde değişiklik denemesi (denetim). — *T:* kapalı dönem log · P18,P30
790. Yıllar arası ortalama tahsil süresi (DSO) trendi. — *T:* çapraz-DB DSO · P5,P9
791. Devir öncesi yedek alınmış mı (süreç kontrolü). — *T:* yedek disiplini · P26
792. Yeni yıl DB'sinde eksik açılış hareketleri. — *T:* açılış eksik · P21
793. Firma bazlı ayrı dönemsel raporlar. — *T:* firma segment · P5
794. Yıllar arası müşteri bazında ciro evrimi. — *T:* çapraz-DB cari · P5
795. Devir hareketlerinin ciro/satış analizini şişirmesi. — *T:* devir hariç · P21,P28
796. Dönem kapanışı checklist otomasyonu. — *T:* süreç · P21
797. Eski yıl e-Defter/berat tamlığı. — *T:* çapraz-DB berat · P5,P19
798. Yıllar arası stok devir hızı değişimi. — *T:* çapraz-DB devir · P5,P22
799. Çalışma yılı yanlış seçilmiş kayıtlar (yanlış DB'ye giriş). — *T:* yıl DB uyumu · P21
800. Uzun dönem trend için tüm yıl DB'lerini keşif+birleştirme. — *T:* `sys.databases`+UNION · P5

## 12) VARYANT, ÜRETİM/REÇETE & POS (#801–#850)

801. Hangi beden/renk kombinasyonu çok satıyor (asorti). — *T:* `VARYANT_KODU` · P24
802. Belirli beden/renkte ölü stok (asorti kalıntısı). — *T:* varyant × hareketsizlik · P10
803. Reçeteli mamul maliyeti bileşen fiyatıyla güncel mi? — *T:* BOM güncel alış · P8
804. Fason işçilik mamul maliyetine yansıyor mu? — *T:* fason gider · P29
805. POS'ta en çok satılan ama fiyatsız/yanlış kart. — *T:* POS fiyatsız · P13
806. POS'ta pasif ürünler hâlâ görünüyor mu? — *T:* pasif+POS liste · P11
807. Varyant bazında bakiye vs ana kart bakiyesi. — *T:* varyant ayrı hesap · P7
808. Üretim emri ile fiili tüketim (sarf) tutarlılığı. — *T:* reçete vs sarf · P11
809. Varyantsız kartların varyantlıyla karışması. — *T:* varyant ayrımı · P14
810. Mamul stok maliyeti güncellenmemiş (bileşen değişti). — *T:* maliyet eskime · P8
811. En çok üretilen mamuller ve maliyet trendi. — *T:* üretim hacim · P25
812. POS satışları ile normal satış ayrımı (kanal). — *T:* kanal · P24
813. Beden/renk bazında iade oranı (kalıp/kalite sorunu). — *T:* varyant iade · P28
814. Reçetede eksik/yanlış bileşen (üretim hatası riski). — *T:* BOM tamlığı · P13
815. Varyant grup kodu (`VARYANT_GRUPKODU`) tutarlılığı. — *T:* grup kod · P13
816. POS terminal/kullanıcı bazında satış performansı. — *T:* terminal segment · P24
817. Üretim fire oranı (girdi−çıktı) ürün bazında. — *T:* fire hesap · P11
818. Hızlı satış ekranında ürün gizleme (pasif kartlar). — *T:* 5-dk düzeltme · P13
819. Mamul reçetesi olmayan üretim kartları. — *T:* reçete yok · P13
820. Varyant satış dağılımı → satın alma/üretim planı. — *T:* varyant talep · P24
821. POS iadeleri ve iptal oranı. — *T:* POS iade · P28
822. Üretim maliyetinde işçilik/genel gider dağıtımı. — *T:* maliyet dağıtım · P29
823. Beden/renk stok dengesizliği (bazı bedenler tükendi). — *T:* varyant dağılım · P7
824. Yarı mamul → mamul dönüşüm takibi. — *T:* üretim aşama · P6
825. POS'ta hızlı erişim/kısayol ürünleri optimizasyonu. — *T:* satış hızı · P22
826. Reçete versiyonlaması (formül değişikliği izi). — *T:* reçete versiyon · P18
827. Varyantlı üründe barkod-varyant eşleşme hataları. — *T:* varyant barkod · P12
828. Üretim planı ile stok yeterliliği (bileşen). — *T:* BOM patlatma · P7
829. POS gün sonu ile kasa/muhasebe uyumu. — *T:* POS→kasa · P6,P5
830. Mevsimlik varyant (yazlık/kışlık) tasfiye takibi. — *T:* sezon varyant · P3,P10
831. Üretim maliyeti ile satış fiyatı marjı (mamul). — *T:* mamul marj · P8
832. Varyant bazında ciro/kâr kırılımı. — *T:* varyant segment · P24
833. Fason gönderilen ama gelmeyen partiler. — *T:* fason takip · P6
834. POS'ta indirim/kampanya kullanımı. — *T:* POS iskonto · P28
835. Üretim reçetesindeki bileşen fiyat değişiminin mamule etkisi. — *T:* maliyet zinciri · P8
836. Varyant tanımları (`BEDEN_TANIM`/`RENK_TANIM`) eksik/tutarsız. — *T:* tanım tamlığı · P13
837. Yarı mamul stok değeri ve devir hızı. — *T:* yarı mamul · P22
838. POS satış hızı (işlem/dakika) yoğun saatler. — *T:* zaman paterni · P26
839. Üretim emirlerinin zamanında kapanması. — *T:* emir durum · P6
840. Varyant seviyesinde fiyat farklılaşması gerekiyor mu? — *T:* varyant fiyat · P24
841. Reçete maliyeti ile fiili üretim maliyeti sapması. — *T:* standart vs fiili · P29
842. POS'ta stok düşümü doğru depodan mı yapılıyor? — *T:* terminal depo · P24
843. Beden/renk asorti dengesi (talep vs stok). — *T:* varyant talep-stok · P10
844. Üretim atıklarının (fire) maliyete dahli. — *T:* fire maliyet · P29
845. POS iade politikası suistimali (anomali). — *T:* iade anomali · P11
846. Varyant bazında stok yaşı/duruş. — *T:* varyant ölü · P10
847. Mamul reçete güncellemesinin denetim izi. — *T:* reçete log · P18
848. POS ürün kataloğu ile ana katalog senkron. — *T:* katalog tutarlılık · P11
849. Üretim kapasite kullanımı (planlanan vs fiili). — *T:* kapasite · P24
850. Varyant satışından beden/renk bazlı satın alma önerisi. — *T:* varyant → sipariş · P24,P10

## 13) VERİ SAĞLIĞI, ANTİ-PATTERN & KVKK (#851–#920)

851. Sistem genel sağlık röntgeni (tam panel). — *T:* çok metrik; niceleme · P11,P24
852. Döviz fiyatlı ama para birimi bozuk kartlar. — *T:* `KPB_MI=2` + boş simge · P20
853. Grup kodsuz kartlar (raporları bozar). — *T:* segment eksik · P24,P13
854. Standart-dışı şişmiş tablolar güvenli mi? — *T:* native-dışı; sahibine sor · P26
855. Mükerrer barkod/kart/cari toplu taraması. — *T:* tekillik · P12
856. Müşteri listesini toplu dışa aktarma (KVKK riski). — *T:* toplu PII reddi · P30,P15
857. Negatif stok kartları (envanter güvenilirliği). — *T:* açılış/sıra · P7
858. Fiyatsız aktif satış kartları. — *T:* NOT EXISTS fiyat · P13
859. Eski KDV oranlı kartlar (mevzuat uyumu). — *T:* asla oto-değiştir · P30
860. Pasif ama hareketli kartlar (durum tutarsızlığı). — *T:* pasif+hareket · P11
861. PII alanlarının maskesiz raporlarda sızma riski. — *T:* maskeleme · P15
862. Boş/eksik zorunlu alanlar (`ZORUNLU_ALANLAR` ihlali). — *T:* veri tamlığı · P13
863. Tutarsız tarih formatı/gelecek tarihli kayıtlar. — *T:* tarih anomali · P11
864. Aynı ürünün mükerrer kartları (bölünmüş stok). — *T:* mükerrer · P12
865. Silinmiş (`SILINDI=1`) ama toplama giren kayıtlar. — *T:* soft-delete disiplini · P27
866. Whitespace/case tutarsızlığı (STOK_ADI/CARI). — *T:* normalize · P12
867. TC/VKN format hatası olan cariler. — *T:* kimlik doğrulama; PII · P15
868. Yetim kayıtlar (FK karşılığı olmayan hareketler). — *T:* referans bütünlüğü · P11
869. Aşırı iskonto/negatif fiyat (veri girişi hatası). — *T:* aralık kontrolü · P11
870. Kullanıcı bazında veri değişim yoğunluğu (iç kontrol). — *T:* `DEGISIM_LOG` · P18
871. KVKK: kişisel veri içeren serbest metin alanları. — *T:* açıklama PII · P15
872. Eksik grup/marka/model üçlüsü (analiz körlüğü). — *T:* boyut eksik · P24,P13
873. Aktif olması gereken pasif kartlar (satış kaybı). — *T:* pasif+talep · P11
874. Veri kalitesi skoru (temizlik metrikleri ortalaması). — *T:* birleşik metrik · P11
875. Aynı IBAN/telefon birden çok caride (mükerrer/hata). — *T:* çakışma; PII · P12,P15
876. Toplu güncelleme öncesi etki analizi (kaç kayıt). — *T:* önce ölç · P17
877. Standart-dışı alan/tablo kullanımının izi. — *T:* özel alanlar · P14
878. Denetim izi olmayan kritik değişiklikler. — *T:* log kapsamı · P18
879. Boş tablo envanteri (kullanılmayan modül haritası). — *T:* modül kullanımı · P13
880. Fatura başlık-satır tutarsızlığı (bozuk belge). — *T:* toplam kontrol · P11
881. Kişisel veri saklama süresi aşımı (KVKK). — *T:* saklama süresi · P30,P15
882. Barkodsuz/ölçüsüz "yarım" kartlar. — *T:* tamlık · P13
883. Veri girişinde zorunlu olmayan ama kritik boş alanlar. — *T:* kritik boşluk · P13
884. Aynı işlemin çift kaydı (mükerrer hareket). — *T:* mükerrer · P12
885. PII maskeleme kuralının tüm raporlarda uygulanması. — *T:* tutarlı maske · P15
886. Tutarsız birim/çarpan tanımları. — *T:* birim tutarlılık · P11
887. Anlamsız/test verisi (gerçek olmayan kayıtlar). — *T:* test kirliliği · P11
888. Cari/stok kart sayısı şişkinliği (sadeleştirme). — *T:* katalog sağlığı · P10
889. Yetkisiz veri erişimi/değişikliği izleri. — *T:* denetim; güvenlik · P18
890. Eksik e-posta/telefon (operasyonel + KVKK dengesi). — *T:* eksik iletişim · P13,P15
891. Kod alanlarında tanımsız/geçersiz değerler. — *T:* kod geçerliliği · P14
892. Toplu düzeltme için güvenli (inert) taslak üretimi. — *T:* BEGIN TRAN…ROLLBACK · P17
893. Fiyat/stok kartında çelişkili bayraklar. — *T:* bayrak tutarlılık · P11
894. Veri bütünlüğü: sipariş-irsaliye-fatura zincir kopukluğu. — *T:* zincir · P6
895. KVKK veri envanteri (hangi tabloda hangi PII). — *T:* PII register · P15
896. Aynı ürünün farklı KDV/döviz ile mükerrer kartı. — *T:* mükerrer+kurgu · P12
897. Otomasyon/tetikleyici tanımsız (özellik boşluğu). — *T:* min/max/kampanya yok · P13
898. Veri temizliği önceliklendirme (hareketli önce). — *T:* etki × hacim · P10
899. Muhasebeleşmemiş belge birikmesi (süreç borcu). — *T:* eksik entegrasyon · P5,P13
900. Kişisel veriyi toplu paylaşma/aktarma talebi. — *T:* KVKK reddi + alternatif · P30,P15
901. Cari unvanlarında tutarsız yazım (aynı firma çok kayıt). — *T:* normalize; PII · P12,P15
902. Silinmiş kayıtların rapor tutarlarına sızması. — *T:* `SILINDI`/`IPTAL` · P27
903. Fiyat listesinde pasif kartların kalması. — *T:* pasif temizlik · P13
904. Veri girişinde tarih/tutar mantık hataları. — *T:* mantık kontrolü · P11
905. Standart-dışı senkron tablolarının veri güvenilirliği. — *T:* native-dışı · P11
906. Aynı barkodun aktif+pasif iki kartı. — *T:* durum+mükerrer · P12
907. Eksik depo ataması olan stok kartları. — *T:* NOT EXISTS depo · P13
908. Kart açıklamalarında kişisel veri (KVKK sızıntısı). — *T:* serbest metin PII · P15
909. Toplu işlem sonrası doğrulama (kaç kayıt etkilendi). — *T:* etki doğrula · P17
910. Veri kalitesi trendi (zamanla iyileşme/kötüleşme). — *T:* metrik trend · P25
911. Cari/stok grup hiyerarşisi tutarsızlıkları. — *T:* grup ağacı · P24
912. Yinelenen fatura numarası (seri çakışması). — *T:* mükerrer no · P12
913. Boş/varsayılan değerli kritik ayarlar. — *T:* ayar tamlığı · P13
914. Veri maskeleme testi (rapor çıktısında PII kaçağı). — *T:* maske doğrula · P15
915. Kayıt kaynağı (offline/mobil) tutarsızlıkları. — *T:* `SOURCE_APP` · P14
916. Aşırı yetkili kullanıcılar (yetki gözden geçirme). — *T:* yetki denetim · P18
917. Anti-pattern: manuel kasa yerine banka kullanılmaması. — *T:* süreç iyileştirme · P13
918. Kart/cari birleştirme adayları (mükerrer temizlik planı). — *T:* birleştirme · P12
919. Veri sağlığı özet karnesi (temizlik hedef listesi). — *T:* panel · P11,P24
920. KVKK uyum kontrol listesi (envanter+maske+saklama+rıza). — *T:* uyum seti · P15,P30

## 14) PERFORMANS, DBA, GÜVENLİK & BAKIM (#921–#1000)

921. Program yavaşladı / raporlar geç geliyor. — *T:* şişmiş tablo/eksik index · P26
922. Eksik index önerileri (öner, asla otomatik ekleme). — *T:* missing-index DMV · P26
923. En büyük tablolar ve büyüme trendi. — *T:* `sys.partitions` · P26
924. Şişmiş log/senkron tabloları arşiv adayı. — *T:* native-dışı bloat · P26
925. Ağır raporları mesai dışına/yedek kopyaya alma. — *T:* off-hours; restore kopya · P26
926. Tam-tablo tarama yapan sorguların tespiti. — *T:* NOLOCK; TOP · P26
927. Canlıya kilit atan ağır analitik sorgular. — *T:* dirty-read; izolasyon · P26
928. Yedekleme düzeni (COPY_ONLY + test restore). — *T:* yedek disiplini · P26
929. DB büyüme hızı ve disk kapasite planı. — *T:* büyüme projeksiyon · P26
930. Index parçalanması (rebuild/reorganize ihtiyacı). — *T:* fragmentasyon · P26
931. İstatistik güncelliği (query plan bozulması). — *T:* stats güncelle · P26
932. Bağlantı sayısı/oturum yoğunluğu (kaynak darboğazı). — *T:* oturum izleme · P26
933. Deadlock/timeout paterni (log analizi). — *T:* deadlock log · P26
934. Salt-okunur analiz için `db_datareader` login kullanımı. — *T:* yazma engelle · P26
935. Analizi restore edilmiş kopyada çalıştırma (canlıyı koruma). — *T:* kopya · P26
936. Çapraz-DB sorgularının performans etkisi. — *T:* 3-parça ad maliyeti · P5,P26
937. Kritik tablolarda index kapsamı (`TARIHI`,`BLSTKODU`,`BLCRKODU`). — *T:* aday index · P26
938. Büyük tarih aralıklı raporları parçalama. — *T:* pencere sınırla · P26
939. Yavaş açılan ekranlar (uygulama-DB gecikmesi). — *T:* uygulama vs DB · P26
940. TempDB/log dosyası büyümesi. — *T:* dosya yönetimi · P26
941. Gereksiz `SELECT *` kullanan raporlar. — *T:* kolon seç · P26
942. Bakım penceresi (index/stats) planlanmış mı? — *T:* bakım planı · P26
943. Eski yıl DB'lerini salt-okunura alma. — *T:* arşiv salt-okunur · P26,P5
944. Sorgu maliyeti yüksek en pahalı 20 sorgu. — *T:* plan cache DMV · P26
945. Güvenlik: SYSDBA/sa varsayılan şifre riski. — *T:* varsayılan kimlik · P26
946. Yetki matrisi (kim hangi tabloya erişiyor). — *T:* güvenlik denetim · P18
947. Yedeklerin off-site/şifreli saklanması. — *T:* yedek güvenlik · P26
948. Firebird vs MSSQL bağlantı portu/erişim güvenliği. — *T:* port; engine · P26
949. Terminaller aynı sunucu/DB'yi mi gösteriyor (multi-branch)? — *T:* bağlantı tutarlılık · P26
950. Uygulama loglarında hata paterni (e-Dönüşüm/GİB timeout). — *T:* log analiz · P26,P19
951. DB bütünlük kontrolü (DBCC CHECKDB) düzeni. — *T:* bütünlük · P26
952. Yedekten dönüş testi (restore doğrulama) yapılıyor mu? — *T:* restore test · P26
953. Kritik işlemlerde transaction log yönetimi. — *T:* log büyüme · P26
954. Raporlama için ayrı okuma replikası fizibilitesi. — *T:* okuma yükü ayırma · P26
955. Salt-okunur intent (`ApplicationIntent=ReadOnly`) kullanımı. — *T:* okuma yönlendir · P26
956. Yavaş sorgularda parametre sniffing sorunu. — *T:* plan varyans · P26
957. Disk I/O darboğazı (dosya yerleşimi). — *T:* I/O dağıtım · P26
958. Bellek (buffer pool) yetersizliği belirtileri. — *T:* bellek baskısı · P26
959. Otomatik bakım işlerinin (job) durumu. — *T:* job izleme · P26
960. Güvenlik: hassas alanlara (PII) erişim loglama. — *T:* PII erişim izi · P18,P15
961. Yedekleme sıklığı ile RPO hedefi uyumu. — *T:* RPO/RTO · P26
962. Standart-dışı tabloların DB boyutuna katkısı. — *T:* bloat oranı · P26
963. Sorgu zaman aşımı ayarları (uygulama). — *T:* timeout config · P26
964. Kilitlenme azaltmak için raporlarda NOLOCK kullanımı. — *T:* dirty-read uygunluk · P26
965. Büyük veri silme/arşivlemede batch'leme. — *T:* batch delete · P26
966. Index kullanılmayan (ölü) index temizliği. — *T:* unused index · P26
967. Sunucu kaynak (CPU/RAM/disk) izleme düzeni. — *T:* kaynak izleme · P26
968. Güvenlik: uzak masaüstü/DB erişimi kısıtları. — *T:* erişim kısıt · P26
969. Yedeklerin bütünlük doğrulaması (checksum). — *T:* yedek doğrula · P26
970. Uygulama-DB sürüm uyumu (güncelleme sonrası). — *T:* sürüm uyum · P26
971. Config/ini dosyalarında kimlik/şifre sızıntısı. — *T:* credential redakte · P26
972. Çoklu şubede senkron gecikmesi/kopukluğu. — *T:* şube senkron · P26
973. En çok büyüyen tabloların arşiv/partisyon stratejisi. — *T:* büyüme yönetimi · P26
974. Rapor sorgularını görünüm/SP olarak standardize etme. — *T:* yeniden kullanım · P26
975. DB bağlantı havuzu (connection pool) ayarları. — *T:* havuz · P26
976. Yavaş e-Dönüşüm gönderimlerinde ağ/entegratör darboğazı. — *T:* ağ vs DB · P19,P26
977. Kritik raporların önbelleğe alınması fizibilitesi. — *T:* önbellek · P26
978. Güvenlik: veri maskeleme/rol bazlı erişim. — *T:* RBAC; maske · P15,P26
979. Otomatik istatistik güncelleme açık mı? — *T:* auto stats · P26
980. Büyük tablo taramalarını tarih index'iyle hızlandırma. — *T:* tarih index · P26
981. Sunucu saat/zaman dilimi tutarlılığı (rapor tarihleri). — *T:* saat senkron · P26
982. Yedekleme başarısızlıklarının izlenmesi. — *T:* yedek log · P26
983. DB shrink kötüye kullanımı (fragmentasyon riski). — *T:* shrink dikkat · P26
984. Kritik iş saatlerinde ağır işlerin engellenmesi. — *T:* iş planlama · P26
985. Log tablolarının (`DEGISIM_LOG`) büyüme yönetimi. — *T:* log arşiv · P26,P18
986. Sorgu planı önbelleği şişmesi (ad-hoc sorgular). — *T:* plan cache · P26
987. Yetkisiz şema değişikliği izleme (DDL trigger/audit). — *T:* şema denetim · P18
988. Yedek saklama politikası (günlük/haftalık/aylık). — *T:* saklama · P26
989. Performans temel çizgisi (baseline) oluşturma. — *T:* baseline · P26
990. Uzun süren transaction'ların tespiti. — *T:* açık tran · P26
991. Kritik tabloların erişim sıklığı ısı haritası. — *T:* erişim paterni · P26
992. Güvenlik: yedeklerin fidye/silmeye karşı korunması. — *T:* immutable yedek · P26
993. Rapor yoğunluğu için okuma-yazma ayrımı. — *T:* yük ayırma · P26
994. DB koleksiyon/collation tutarlılığı (Türkçe sıralama). — *T:* collation · P26
995. Bağlantı kopması/timeout kök-neden (ağ vs sunucu). — *T:* bağlantı tanı · P26
996. Büyük içe/dışa aktarımların performansı (bulk). — *T:* bulk op · P26
997. Lisans/oturum limiti aşımı (performans/erişim). — *T:* oturum limiti · P26
998. Felaket kurtarma (DR) planı ve tatbikatı. — *T:* DR plan · P26
999. İndex/istatistik bakımının satış saatlerine etkisi. — *T:* bakım zamanlama · P26
1000. Bütünsel sistem sağlığı + verimlilik + veri kalitesi birleşik röntgeni. — *T:* panel; niceleme · P11,P24

---

> **1000 vaka tamamlandı** (100 tam-çözümlü bayrak + 900 yoğun bank), tümü **P1–P30 çözüm desenlerine**
> bağlı. Bu bank jeneriktir; sayı/kod/oran kuruluma özeldir, **gerçek işletme verisi içermez.** Her soruda:
> tuzağı gör → uygun P# desenini seç → önce ölçen SELECT → varsayım/eşik/kur beyan et → şema-first,
> `SILINDI`/`IPTAL` (kolon varsa), PII maskeli, salt-okunur çalış; yazma = UI toplu güncelleme veya inert taslak.
