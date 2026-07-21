<#
.SYNOPSIS
  Wolvox 8 — Otomatik yeniden fiyatlama ÖNİZLEMESİ + inert MIGRATION TASLAĞI üreticisi (SALT-OKUNUR).

.DESCRIPTION
  Seçili (bir Özel Kod slotuyla işaretli) aktif stok kartlarında:
    hedef_satis = CEILING(son_alis * Carpan) - 1        (tam TL'ye yukarı yuvarla, 1 çıkar)
  hesaplar ve YALNIZ 'hedef > mevcut' olanları yükseltmek üzere listeler (ASİMETRİK: düşürmez).
  Son alış, STOKHR gerçek alış hareketinden alınır (TUTAR_TURU=1, iade/devir hariç).

  Betik CANLIYA YAZMAZ. İki çıktı üretir:
    1) <OutDir>\reprice-preview-<ts>.csv   — önizleme (Son_Alis, Hedef, Mevcut, Fark, Karar)
    2) <OutDir>\reprice-draft-<ts>.sql      — inert BEGIN TRAN ... ROLLBACK taslağı (kullanıcı COMMIT eder)

  Yalnız TL fiyatlar (KPB_MI=1); döviz fiyatlıları kapsam dışıdır (belge-anı kur ayrı ele alınmalı).

.NOTES
  Jeneriktir; hiçbir sunucu/DB/işletme verisi gömülü değildir. db_datareader yetkisi yeterlidir.
  Kolon adları doğrulanmış Wolvox 8 şemasına göredir; farklı sürüm/edisyonda SQL'i teyit et.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string]$Server,
  [Parameter(Mandatory)] [string]$Database,
  [Parameter(Mandatory)] [double]$Carpan,                      # iş marjı çarpanı, ör. 1.50 (kendi marjınız)
  [ValidateSet('OZEL_KODU1','OZEL_KODU2','OZEL_KODU3')]
  [string]$IsaretSlot = 'OZEL_KODU3',                          # alt-küme işaret slotu (OZEL_KODU4 YOK)
  [Parameter(Mandatory)] [string]$Isaret,                      # işaret değeri, ör. 'REPRICE' (kendi özel kodunuz)
  [int]$FiyatNo = 1,                                           # hangi satış listesi
  [string]$OutDir = '.',
  [string]$User,                                               # boşsa Windows auth
  [string]$Password
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$csvPath   = Join-Path $OutDir "reprice-preview-$ts.csv"
$draftPath = Join-Path $OutDir "reprice-draft-$ts.sql"

# --- güvenlik: yalnız izin verilen slot adı SQL'e girsin (injection'a kapalı) ---
# $IsaretSlot ValidateSet ile sınırlı; $Isaret parametreli komutla geçer.

$connStr = if ($User) {
  "Server=$Server;Database=$Database;User ID=$User;Password=$Password;TrustServerCertificate=True;ApplicationIntent=ReadOnly"
} else {
  "Server=$Server;Database=$Database;Integrated Security=True;TrustServerCertificate=True;ApplicationIntent=ReadOnly"
}

# --- ÖNİZLEME sorgusu (salt-okunur) ---
$previewSql = @"
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @carpan float = @p_carpan;
;WITH sonalis AS (
  SELECT BLSTKODU, KPB_FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY TARIHI DESC, KAYIT_TARIHI DESC) rn
  FROM STOKHR
  WHERE TUTAR_TURU=1 AND ISNULL(IADE,0)=0 AND ISNULL(DEVIR,0)=0
    AND ISNULL(KPB_GMIK,0)>0 AND ISNULL(SILINDI,0)=0 AND KPB_FIYATI>0
),
satis AS (
  SELECT BLSTKODU, FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY FIYAT_DEG_TARIHI DESC) rn
  FROM STOK_FIYAT WHERE ALIS_SATIS=2 AND FIYAT_NO=@p_fiyatno AND KPB_MI=1
)
SELECT s.STOKKODU,
  CAST(a.KPB_FIYATI AS decimal(18,2))                     AS Son_Alis,
  CAST(CEILING(a.KPB_FIYATI*@carpan)-1 AS decimal(18,2))  AS Hedef,
  CAST(sa.FIYATI AS decimal(18,2))                        AS Mevcut,
  CAST((CEILING(a.KPB_FIYATI*@carpan)-1)-sa.FIYATI AS decimal(18,2)) AS Fark,
  CASE WHEN (CEILING(a.KPB_FIYATI*@carpan)-1) > sa.FIYATI THEN 'YUKSELT' ELSE 'DOKUNMA' END AS Karar
FROM STOK s
JOIN sonalis a ON a.BLSTKODU=s.BLKODU AND a.rn=1
JOIN satis   sa ON sa.BLSTKODU=s.BLKODU AND sa.rn=1
WHERE s.AKTIF=1 AND LTRIM(RTRIM(ISNULL(s.$IsaretSlot,'')))=@p_isaret
ORDER BY Fark DESC;
"@

Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$rows = New-Object System.Collections.Generic.List[object]
try {
  $conn.Open()
  $cmd = $conn.CreateCommand()
  $cmd.CommandText = $previewSql
  [void]$cmd.Parameters.AddWithValue('@p_carpan',  $Carpan)
  [void]$cmd.Parameters.AddWithValue('@p_fiyatno', $FiyatNo)
  [void]$cmd.Parameters.AddWithValue('@p_isaret',  $Isaret)
  $rdr = $cmd.ExecuteReader()
  while ($rdr.Read()) {
    $rows.Add([pscustomobject]@{
      STOKKODU = $rdr['STOKKODU']; Son_Alis = $rdr['Son_Alis']; Hedef = $rdr['Hedef']
      Mevcut = $rdr['Mevcut']; Fark = $rdr['Fark']; Karar = $rdr['Karar']
    })
  }
  $rdr.Close()
} finally { $conn.Close() }

$rows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
$yukselt = @($rows | Where-Object { $_.Karar -eq 'YUKSELT' })
Write-Host ("Önizleme: {0} kart · YÜKSELT: {1} · DOKUNMA: {2}" -f $rows.Count, $yukselt.Count, ($rows.Count-$yukselt.Count))
Write-Host ("CSV  → {0}" -f $csvPath)

# --- inert MIGRATION TASLAĞI (.sql) — betik ÇALIŞTIRMAZ, dosyaya yazar ---
$draft = @"
-- ============================================================================
-- MIGRATION TASLAĞI (INERT) — YEDEK + TEST KOPYASI + TRANSACTION FIRST.
-- Bu dosyayı bir insan inceleyip ROLLBACK -> COMMIT'e ÇEVİRDİKTEN sonra çalıştırır.
-- Sadece YÜKSELTİR (asimetrik). Üretildi: $ts | DB: $Database | Çarpan: $Carpan
-- İşaret: $IsaretSlot = '$Isaret' | Satış listesi: FIYAT_NO=$FiyatNo | Yalnız KPB_MI=1 (TL)
-- ============================================================================
BEGIN TRAN;
DECLARE @carpan float = $Carpan;
;WITH sonalis AS (
  SELECT BLSTKODU, KPB_FIYATI,
    ROW_NUMBER() OVER (PARTITION BY BLSTKODU ORDER BY TARIHI DESC, KAYIT_TARIHI DESC) rn
  FROM STOKHR
  WHERE TUTAR_TURU=1 AND ISNULL(IADE,0)=0 AND ISNULL(DEVIR,0)=0
    AND ISNULL(KPB_GMIK,0)>0 AND ISNULL(SILINDI,0)=0 AND KPB_FIYATI>0
)
UPDATE sf
  SET sf.FIYATI = CEILING(a.KPB_FIYATI*@carpan)-1, sf.FIYAT_DEG_TARIHI = GETDATE()
FROM STOK_FIYAT sf
JOIN STOK s    ON s.BLKODU=sf.BLSTKODU
JOIN sonalis a ON a.BLSTKODU=sf.BLSTKODU AND a.rn=1
WHERE s.AKTIF=1 AND LTRIM(RTRIM(ISNULL(s.$IsaretSlot,'')))=N'$Isaret'
  AND sf.ALIS_SATIS=2 AND sf.FIYAT_NO=$FiyatNo AND sf.KPB_MI=1
  AND (CEILING(a.KPB_FIYATI*@carpan)-1) > sf.FIYATI;   -- ASİMETRİK: yalnız yükselt

-- Etkilenen satır sayısını ve örnekleri DOĞRULA; doğruysa COMMIT, değilse ROLLBACK:
-- SELECT @@ROWCOUNT AS Etkilenen;
ROLLBACK;  -- ⚠️ GÜVENLİK İÇİN VARSAYILAN. Onayladıysan COMMIT yap.
-- Tercih: mümkünse UI 'Stok > Toplu Fiyat Güncelleme' kullan (fiyat değişim log'unu korur).
"@
Set-Content -Path $draftPath -Value $draft -Encoding UTF8
Write-Host ("Taslak → {0}  (INERT: ROLLBACK ile biter; COMMIT'i sen ver)" -f $draftPath)
Write-Host "Bu betik hiçbir yazma yapmadı. Önce CSV'yi incele, taslağı test kopyasında dene."
