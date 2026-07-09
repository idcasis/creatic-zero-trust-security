<#
    Modulo 5 - Hardening Windows Server
    Servidor: CR-DC-01
    Rol logico: Controlador de dominio / servidor de identidad

    Controles implementados:
    - Deshabilitacion de SMBv1.
    - Requerimiento de SMB Signing.
    - Endurecimiento de politicas de contrasena.
    - Deshabilitacion de cuenta Guest.
    - Activacion de Windows Firewall.
    - Activacion de auditoria de eventos de identidad.
#>

$LogPath = "C:\CREATIC-Hardening\hardening_windows_dc_log.txt"
Start-Transcript -Path $LogPath -Append

Write-Host "============================================="
Write-Host " HARDENING WINDOWS SERVER - CR-DC-01"
Write-Host "============================================="

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

Write-Section "Fortaleciendo configuracion SMB"
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
Set-SmbServerConfiguration -EnableSecuritySignature $true -Force

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

Write-Section "Aplicando controles adicionales de identidad"

New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "NoLMHash" `
    -Value 1 `
    -PropertyType DWord `
    -Force

Write-Host "NoLMHash habilitado para evitar almacenamiento de hashes LM antiguos."

Write-Section "Activando auditoria de eventos de identidad"
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable

Write-Section "Verificacion post-hardening - SMBv1 y SMB Signing"
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,RequireSecuritySignature,EnableSecuritySignature | Format-List

Write-Section "Verificacion post-hardening - Politica de contrasenas"
net accounts

Write-Section "Verificacion post-hardening - Cuenta Guest"
Get-LocalUser Guest | Format-List Name,Enabled,Description

Write-Section "Verificacion post-hardening - Firewall"
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction -AutoSize

Write-Section "Verificacion post-hardening - Auditoria"
auditpol /get /subcategory:"Logon"
auditpol /get /subcategory:"Account Lockout"
auditpol /get /subcategory:"User Account Management"

Write-Section "Resumen final"
Write-Host "Servidor: CR-DC-01"
Write-Host "Rol logico: Controlador de dominio / servidor de identidad"
Write-Host "SMBv1: Deshabilitado"
Write-Host "SMB Signing: Requerido"
Write-Host "Guest: Deshabilitado"
Write-Host "Firewall: Habilitado"
Write-Host "Politica de contrasenas: Endurecida"
Write-Host "Auditoria de identidad: Habilitada"
Write-Host "Log generado en: $LogPath"

Stop-Transcript