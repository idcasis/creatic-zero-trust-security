<#
    Modulo 5 - Hardening Windows Server
    Servidor: CR-FILE-03
    Rol: Servidor de archivos

    Controles implementados:
    - Deshabilitacion de SMBv1.
    - Endurecimiento de politicas de contrasena.
    - Deshabilitacion de cuenta Guest.
    - Activacion de Windows Firewall.
    - Configuracion segura de recurso compartido.
#>

$LogPath = "C:\CREATIC-Hardening\hardening_windows_file_log.txt"
Start-Transcript -Path $LogPath -Append

Write-Host "============================================="
Write-Host " HARDENING WINDOWS SERVER - CR-FILE-03"
Write-Host "============================================="

$FileShareName = "CREATIC-Files"
$FileSharePath = "C:\CREATIC-Files"
$SecureShareGroup = "CREATIC-FileUsers"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "===== $Title ====="
}

Write-Section "Servidor evaluado"
hostname

Write-Section "Deshabilitando SMBv1"
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

try {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Write-Host "SMB1Protocol deshabilitado como Windows Optional Feature."
}
catch {
    Write-Host "No se pudo deshabilitar SMB1Protocol como feature. Se continua con el hardening."
}

Write-Section "Aplicando politica de contrasenas"
net accounts /MINPWLEN:12
net accounts /MAXPWAGE:90
net accounts /MINPWAGE:1
net accounts /UNIQUEPW:5
net accounts /LOCKOUTTHRESHOLD:5
net accounts /LOCKOUTDURATION:30
net accounts /LOCKOUTWINDOW:30

Write-Section "Deshabilitando cuenta Guest"
try {
    Disable-LocalUser -Name "Guest"
    Write-Host "Cuenta Guest deshabilitada."
}
catch {
    net user Guest /active:no
}

Write-Section "Activando Windows Firewall"
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Allow

Write-Section "Configurando recurso compartido seguro"

if (-not (Test-Path $FileSharePath)) {
    New-Item -Path $FileSharePath -ItemType Directory -Force
    Write-Host "Carpeta creada: $FileSharePath"
}

if (-not (Get-LocalGroup -Name $SecureShareGroup -ErrorAction SilentlyContinue)) {
    New-LocalGroup -Name $SecureShareGroup -Description "Grupo autorizado para acceso a archivos CREATIC"
    Write-Host "Grupo local creado: $SecureShareGroup"
}

$ShareExists = Get-SmbShare -Name $FileShareName -ErrorAction SilentlyContinue

if (-not $ShareExists) {
    New-SmbShare -Name $FileShareName -Path $FileSharePath -FullAccess "Administrators" -ChangeAccess $SecureShareGroup
    Write-Host "Share seguro creado: $FileShareName"
}
else {
    Write-Host "Share existente encontrado: $FileShareName"

    try {
        Revoke-SmbShareAccess -Name $FileShareName -AccountName "Everyone" -Force -ErrorAction SilentlyContinue
        Write-Host "Permiso Everyone removido del recurso compartido."
    }
    catch {
        Write-Host "No existia permiso Everyone o no pudo removerse."
    }

    Grant-SmbShareAccess -Name $FileShareName -AccountName "Administrators" -AccessRight Full -Force
    Grant-SmbShareAccess -Name $FileShareName -AccountName $SecureShareGroup -AccessRight Change -Force

    Write-Host "Permisos seguros aplicados al recurso compartido."
}

Write-Section "Habilitando reglas necesarias para servidor de archivos"
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue

Write-Section "Verificacion post-hardening - SMBv1"
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol | Format-List

Write-Section "Verificacion post-hardening - Feature SMB1"
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

Write-Section "Verificacion post-hardening - Politica de contrasenas"
net accounts

Write-Section "Verificacion post-hardening - Cuenta Guest"
Get-LocalUser Guest | Format-List Name,Enabled,Description

Write-Section "Verificacion post-hardening - Firewall"
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction -AutoSize

Write-Section "Verificacion post-hardening - Recursos compartidos"
Get-SmbShare | Format-Table Name,Path,Description -AutoSize

Write-Section "Verificacion post-hardening - Permisos del share CREATIC-Files"
Get-SmbShareAccess -Name "CREATIC-Files" | Format-Table AccountName,AccessControlType,AccessRight -AutoSize

Write-Section "Resumen final"
Write-Host "Servidor: CR-FILE-03"
Write-Host "Rol: Servidor de archivos"
Write-Host "SMBv1: Deshabilitado"
Write-Host "Guest: Deshabilitado"
Write-Host "Firewall: Habilitado"
Write-Host "Politica de contrasenas: Endurecida"
Write-Host "Share CREATIC-Files: Permisos ajustados"
Write-Host "Log generado en: $LogPath"

Stop-Transcript