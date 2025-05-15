######################################################################################
# Script PowerShell data from SQL Server to CSV files
# Safe credentials via environment variables and execution/error log
######################################################################################

$LogFile = "d:\exportgs\ExportViews.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $Message"
}

# Read credentials from environment variables
$SQLServer = $env:DB_SQLSERVER
$db = $env:DB_DATABASE
$User = $env:DB_USER
$Pass = $env:DB_PASS

# Check if variables are defined
if (-not $SQLServer -or -not $db -or -not $User -or -not $Pass) {
    $msg = "ERROR: Environment variables DB_SQLSERVER, DB_DATABASE, DB_USER or DB_PASS not defined. Execution aborted."
    Write-Log $msg
    exit 1
}

$Arquivo1 = "d:\exportgs\view1.csv"
$Arquivo2 = "d:\exportgs\view2.csv"
$Arquivo3 = "d:\exportgs\view3.csv"
$Arquivo4 = "d:\exportgs\view4.csv"
$Arquivo5 = "d:\exportgs\view5.csv"
$Arquivo6 = "d:\exportgs\view6.csv"

$Qry1 = "SELECT * FROM dbo.VIEW_EXEMPLO1"
$Qry2 = "SELECT * FROM dbo.VIEW_EXEMPLO2"
$Qry3 = "SELECT * FROM dbo.VIEW_EXEMPLO3"
$Qry4 = "SELECT * FROM dbo.VIEW_EXEMPLO4"
$Qry5 = "SELECT * FROM dbo.VIEW_EXEMPLO5"
$Qry6 = "SELECT * FROM dbo.VIEW_EXEMPLO6"

function Export-Query($Query, $Arquivo, $Descricao) {
    try {
        $time = Get-Date -Format "HH:mm:ss"
        Write-Log "Início Export $Descricao...: $time"
        Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $Query -Username $User -Password $Pass | Export-Csv $Arquivo -Delimiter ";" -NoTypeInformation
        $time = Get-Date -Format "HH:mm:ss"
        Write-Log "Término Carga $Arquivo..: $time"
    } catch {
        Write-Log "ERRO ao exportar $Descricao: $_"
    }
}

Export-Query $Qry1 $Arquivo1 "View 1"
Export-Query $Qry2 $Arquivo2 "View 2"
Export-Query $Qry3 $Arquivo3 "View 3"
Export-Query $Qry4 $Arquivo4 "View 4"
Export-Query $Qry5 $Arquivo5 "View 5"
Export-Query $Qry6 $Arquivo6 "View 6" 