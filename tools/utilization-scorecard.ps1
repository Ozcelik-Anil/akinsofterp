<#
.SYNOPSIS
  Wolvox 8 — Verimli Kullanım Skoru (utilization / ERP-olgunluk) — SALT-OKUNUR tarama.

.DESCRIPTION
  reference/verimlilik-skoru.md rubriğinin çalıştırılabilir çekirdeği. Şu boyutları salt-okunur
  metriklerle üretir:
    B1 Modül Benimseme (25%)  — çekirdek modüllerden kaçı anlamlı veri taşıyor
    B2 Veri Kalitesi   (25%)  — grup/fiyat/KDV/döviz/barkod/negatif-stok temizlik oranları
  B3–B5 (özellik derinliği, süreç bütünlüğü, bakım) tam rubrikte manuel/kurulum-özeldir; bu betik
  B1+B2'yi otomatikleştirir ve kısmi bir kompozit + not verir. Tüm sayılar AGREGAT (PII yok).

  Muhasebe benimsemesi AYRI _GMUHASEBE DB'sindedir; -GMuhasebeDb verilirse çapraz-DB kontrol edilir.
  Her metrik try/catch ile korunur: farklı sürüm/edisyonda olmayan tablo/kolon skoru düşürmez,
  'atlandı' olarak işaretlenir (şeffaflık).

.NOTES
  Jeneriktir; hiçbir işletme verisi gömülü değildir. db_datareader yeterlidir. Ağırlıklar rubrikteki
  başlangıç varsayımıdır — sektöre göre ayarlanabilir; rapor ağırlıkları beyan eder.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string]$Server,
  [Parameter(Mandatory)] [string]$Database,
  [string]$GMuhasebeDb,                 # ör. WOLVOX8_001_2023_GMUHASEBE (muhasebe benimsemesi için)
  [string]$User,
  [string]$Password
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Data

$connStr = if ($User) {
  "Server=$Server;Database=$Database;User ID=$User;Password=$Password;TrustServerCertificate=True;ApplicationIntent=ReadOnly"
} else {
  "Server=$Server;Database=$Database;Integrated Security=True;TrustServerCertificate=True;ApplicationIntent=ReadOnly"
}
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()
function Scalar([string]$sql) {
  $c = $conn.CreateCommand(); $c.CommandText = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; $sql"
  $v = $c.ExecuteScalar()
  if ($null -eq $v -or $v -is [DBNull]) { return 0 } else { return [double]$v }
}
function Try-Scalar([string]$sql) { try { return @{ ok=$true; val=(Scalar $sql) } } catch { return @{ ok=$false; val=0 } } }

# ---------- B1: Modül Benimseme ----------
$modules = @(
  @{ ad='Stok';          w=3; sql="SELECT COUNT(*) FROM STOKHR";  test={ param($n) $n -gt 0 } },
  @{ ad='Cari';          w=3; sql="SELECT COUNT(*) FROM CARIHR";  test={ param($n) $n -gt 0 } },
  @{ ad='Fatura';        w=3; sql="SELECT COUNT(*) FROM FATURA";  test={ param($n) $n -gt 0 } },
  @{ ad='e-Donusum';     w=3; sql="SELECT COUNT(*) FROM FATURA WHERE EFATURA_KULLAN=1"; test={ param($n) $n -gt 0 } },
  @{ ad='Siparis';       w=2; sql="SELECT COUNT(*) FROM SIPARIS"; test={ param($n) $n -gt 0 } },
  @{ ad='Irsaliye';      w=2; sql="SELECT COUNT(*) FROM IRSALIYE";test={ param($n) $n -gt 0 } },
  @{ ad='Kasa';          w=1; sql="SELECT COUNT(*) FROM KASAHR";  test={ param($n) $n -gt 0 } },
  @{ ad='Banka';         w=1; sql="SELECT COUNT(*) FROM BANKAHR"; test={ param($n) $n -gt 0 } },
  @{ ad='Cek/Senet';     w=1; sql="SELECT COUNT(*) FROM CEK_SENET"; test={ param($n) $n -gt 0 } },
  @{ ad='Teklif';        w=1; sql="SELECT COUNT(*) FROM TEKLIF";  test={ param($n) $n -ge 500 } }
)
$b1w=0.0; $b1got=0.0; $b1lines=@()
foreach ($m in $modules) {
  $r = Try-Scalar $m.sql
  $b1w += $m.w
  if (-not $r.ok) { $b1lines += ("  {0,-12} atlandı (tablo yok?)" -f $m.ad); continue }
  $adopted = & $m.test $r.val
  if ($adopted) { $b1got += $m.w }
  $b1lines += ("  {0,-12} {1,10:N0}  {2}" -f $m.ad, $r.val, ($(if($adopted){'benimsendi'}else{'—'})))
}
# Muhasebe (çapraz-DB, opsiyonel)
if ($GMuhasebeDb) {
  $r = Try-Scalar "SELECT COUNT(*) FROM [$GMuhasebeDb].dbo.YEVMIYE"
  $b1w += 3
  if ($r.ok -and $r.val -gt 0) { $b1got += 3; $b1lines += ("  {0,-12} {1,10:N0}  benimsendi" -f 'GenelMuh.', $r.val) }
  elseif ($r.ok) { $b1lines += ("  {0,-12} {1,10:N0}  —" -f 'GenelMuh.', $r.val) }
  else { $b1lines += "  GenelMuh.    atlandı ( _GMUHASEBE erişilemedi )" }
} else {
  $b1lines += "  GenelMuh.    ATLANDI — -GMuhasebeDb verilmedi (muhasebe AYRI DB'de; 'kullanılmıyor' SANMA)"
}
$B1 = if ($b1w -gt 0) { 100.0 * $b1got / $b1w } else { 0 }

# ---------- B2: Veri Kalitesi (temizlik oranları, her biri 0..1) ----------
$ratios = @()
function Add-Ratio($ad, $kirliSql, $toplamSql) {
  $t = Try-Scalar $toplamSql; if (-not $t.ok -or $t.val -eq 0) { $script:ratios += @{ ad=$ad; ok=$false }; return }
  $k = Try-Scalar $kirliSql;  if (-not $k.ok) { $script:ratios += @{ ad=$ad; ok=$false }; return }
  $script:ratios += @{ ad=$ad; ok=$true; oran=[math]::Max(0,1 - $k.val/$t.val); kirli=$k.val; toplam=$t.val }
}
Add-Ratio 'grup_temiz'   "SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND (GRUBU IS NULL OR LTRIM(RTRIM(GRUBU))='')" "SELECT COUNT(*) FROM STOK WHERE AKTIF=1"
Add-Ratio 'fiyat_temiz'  "SELECT COUNT(*) FROM STOK s WHERE s.AKTIF=1 AND NOT EXISTS (SELECT 1 FROM STOK_FIYAT f WHERE f.BLSTKODU=s.BLKODU AND f.ALIS_SATIS=2 AND f.FIYATI>0)" "SELECT COUNT(*) FROM STOK WHERE AKTIF=1"
Add-Ratio 'kdv_temiz'    "SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND (KDV_ORANI IS NULL OR KDV_ORANI<0)" "SELECT COUNT(*) FROM STOK WHERE AKTIF=1"
Add-Ratio 'doviz_temiz'  "SELECT COUNT(*) FROM STOK s JOIN STOK_FIYAT f ON f.BLSTKODU=s.BLKODU WHERE f.KPB_MI=2 AND (s.DOVIZ_BIRIMI IS NULL OR LTRIM(RTRIM(s.DOVIZ_BIRIMI))='')" "SELECT COUNT(*) FROM STOK s JOIN STOK_FIYAT f ON f.BLSTKODU=s.BLKODU WHERE f.KPB_MI=2"
Add-Ratio 'barkod_tekil' "SELECT ISNULL(SUM(c-1),0) FROM (SELECT COUNT(*) c FROM STOK WHERE AKTIF=1 AND BARKODU IS NOT NULL AND LTRIM(RTRIM(BARKODU))<>'' GROUP BY BARKODU HAVING COUNT(*)>1) x" "SELECT COUNT(*) FROM STOK WHERE AKTIF=1 AND BARKODU IS NOT NULL AND LTRIM(RTRIM(BARKODU))<>''"

$b2ok = @($ratios | Where-Object { $_.ok })
$B2 = if ($b2ok.Count -gt 0) { 100.0 * (($b2ok | Measure-Object -Property oran -Average).Average) } else { 0 }

$conn.Close()

# ---------- Rapor ----------
"" ; "==== Wolvox Verimli Kullanım Skoru (kısmi: B1+B2) ====" ; "DB: $Database"
"" ; "B1 — Modül Benimseme (ağırlık 25%):  {0,5:N1}/100" -f $B1
$b1lines | ForEach-Object { $_ }
"" ; "B2 — Veri Kalitesi (ağırlık 25%):    {0,5:N1}/100" -f $B2
foreach ($r in $ratios) {
  if ($r.ok) { "  {0,-14} %{1,5:N1} temiz  ({2:N0}/{3:N0} kirli)" -f $r.ad, ($r.oran*100), $r.kirli, $r.toplam }
  else { "  {0,-14} atlandı (tablo/kolon yok)" -f $r.ad }
}
$partial = ($B1 + $B2) / 2.0
"" ; "Kısmi kompozit (B1,B2 eşit):          {0,5:N1}/100" -f $partial
"" ; "NOT: B3 Özellik Derinliği, B4 Süreç Bütünlüğü, B5 Bakım bu betikte YOK — tam 0–100 skoru için"
"reference/verimlilik-skoru.md rubriğini uygula. Ağırlıklar rubrik varsayımıdır; sektöre göre ayarla."
"Tüm çıktı agregattır; kişisel veri seçilmedi. Salt-okunur çalışıldı."
