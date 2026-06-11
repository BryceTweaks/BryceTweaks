Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# =========================
# HARDWARE DETECT
# =========================
$CPU = (Get-CimInstance Win32_Processor).Name
$GPU = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$RAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
$User = $env:USERNAME

function CreateRestorePoint {
    try {
        Enable-ComputerRestore -Drive "C:\"
        Checkpoint-Computer -Description "BTU RESTORE" -RestorePointType "MODIFY_SETTINGS"
        Write-Host "Restore Point Created"
    }
    catch {
        Write-Host "Failed to create restore point (run as admin + enable system protection)"
    }
}

CreateRestorePoint

# =========================
# TWEAK FUNCTIONS
# =========================

function WindowsTweaks {
   reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 1000 /f
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 1000 /f
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v IconsOnly /t REG_DWORD /d 1 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisableThumbnailCache /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ExtendedUIHoverTime /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v NoResolveSearch /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DoReport /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DontSendAdditionalData /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul
sc stop WerSvc >nul 2>&1
sc config WerSvc start= disabled >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
sc stop gupdate >nul 2>&1
sc config gupdate start= disabled >nul
sc stop gupdatem >nul 2>&1
sc config gupdatem start= disabled >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v HarvestContacts /t REG_DWORD /d 0 /f
reg add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v DownloadMode /t REG_DWORD /d 0 /f
}

function GPUTweaks {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 10 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t REG_DWORD /d "4" /f
    powercfg -setactive SCHEME_MIN | Out-Null
}

function CPUTweaks {

# =========================
# MAX PERFORMANCE POWER PLAN
# =========================
powercfg -setactive SCHEME_MIN

# =========================
# REMOVE CPU POWER LIMITS
# =========================
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100

# Disable core parking + idle states
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 1
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPPARSTATEPOLICY 0

# =========================
# BOOST BEHAVIOR (VERY AGGRESSIVE)
# =========================
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTPOL 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCPOL 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECPOL 0

# =========================
# ULTRA LOW LATENCY CPU RESPONSE
# =========================
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX1 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN1 100

# =========================
# DISABLE ALL POWER SAVING STATES
# =========================
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# Turn off CPU sleep transitions
powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 0

# =========================
# USB / INPUT STABILITY POWER FIX
# =========================
powercfg -setacvalueindex SCHEME_CURRENT SUB_USB USBSELECTSUSPEND 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_USB USB3_LINK_POWER_MGMT 0

# =========================
# APPLY SETTINGS
# =========================
powercfg -setactive SCHEME_CURRENT
}

function NetworkTweaks {
     # TCP BASIC
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f

    # NETSH TCP
    netsh int tcp set supplemental internet congestionprovider=ctcp
    netsh int tcp set heuristics disabled
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global rss=enabled
    netsh int tcp set global timestamps=disabled

    # MTU (safe attempt)
    netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent 2>$null
    netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent 2>$null

    # POWER TCP SETTINGS
    powershell Set-NetTcpSetting -SettingName internet -EcnCapability enabled 2>$null
    powershell Set-NetTcpSetting -SettingName internet -MaxSynRetransmissions 2 2>$null
    powershell Set-NetTcpSetting -SettingName internet -InitialRto 2000 2>$null

    # OFFLOAD SETTINGS
    powershell Disable-NetAdapterLso -Name "*" 2>$null
    powershell Disable-NetAdapterChecksumOffload -Name "*" 2>$null
    powershell Set-NetOffloadGlobalSetting -ReceiveSideScaling disabled 2>$null

    # IPV6 OFF
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 255 /f

    # ACTIVE PROBING OFF
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v "EnableActiveProbing" /t REG_DWORD /d 0 /f

}

function Debloat {
 $services = @(
"DiagTrack",
"dmwappushservice",
"RetailDemo",
"RemoteRegistry",
"WalletService",
"lfsvc",
"MapsBroker",
"WSearch",
"XblGameSave",
"XblAuthManager",
"XboxNetApiSvc",
"WerSvc",
"SharedAccess",
"PhoneSvc",
"PrintNotify",
"Spooler",
"RemoteAccess",
"SessionEnv",
"TermService",
"UmRdpService",
"TapiSrv",
"iphlpsvc",
"SensorService",
"SensrSvc",
"WiaRpc",
"wisvc",
"OneSyncSvc",
"TabletInputService",
"CDPSvc",
"SEMgrSvc",
"Fax"
)

   foreach ($svc in $services) {
    Get-Service $svc -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

PowerShell -Command "Get-AppxPackage -allusers *3DBuilder* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *BingWeather* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *CommsPhone* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Drawboard PDF* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Facebook* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Getstarted* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Microsoft.Messaging* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *MicrosoftOfficeHub* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *SkypeApp* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *solit* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Sway* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *Twitter* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *WindowsAlarms* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *WindowsPhone* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *WindowsMaps* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *WindowsFeedbackHub* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *WindowsSoundRecorder* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *windowscommunicationsapps* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage -allusers *zune* | Remove-AppxPackage" >nul 2>&1

powershell -Command "Get-AppxPackage *skype* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *solitaire* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *officehub* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *candycrush* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *YourPhone* | Remove-AppxPackage" >nul 2>&1

:: OneDrive removal
powershell -Command "taskkill /f /im OneDrive.exe" >nul 2>&1
%SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1

PowerShell -Command "Get-AppxPackage *Cortana* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage *WindowsCamera* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage *photos* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxPackage *ContentDeliveryManager* | Remove-AppxPackage" >nul 2>&1
}

function Cleanup {
    del /s /q $env:TEMP\* 2>$null
    start cleanmgr
}

# =========================
# UI
# =========================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Bryce Tweaks"
        Height="650"
        Width="900"
        Background="Black"
        Foreground="White"
        WindowStartupLocation="CenterScreen">

    <Grid>

        <StackPanel HorizontalAlignment="Center"
                    VerticalAlignment="Center">

            <!-- TITLE -->
            <TextBlock Text="BRYCE TWEAKS"
                       FontSize="32"
                       FontWeight="Bold"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,10"/>

            <!-- WELCOME -->
            <TextBlock Name="Welcome"
                       FontSize="16"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,5"
                       Opacity="0.9"/>

            <!-- HARDWARE -->
            <TextBlock Name="Hardware"
                       FontSize="13"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,25"
                       Opacity="0.7"/>

            <!-- BUTTONS -->
            <Button Name="BTN_WIN"
                    Content="WINDOWS TWEAKS"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

            <Button Name="BTN_GPU"
                    Content="GPU TWEAKS"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

            <Button Name="BTN_CPU"
                    Content="CPU TWEAKS"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

            <Button Name="BTN_NET"
                    Content="NETWORK TWEAKS"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

            <Button Name="BTN_DEBLOAT"
                    Content="DEBLOAT SYSTEM"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

            <Button Name="BTN_CLEAN"
                    Content="CLEANUP"
                    Width="320"
                    Height="55"
                    Margin="0,8"
                    Background="White"
                    Foreground="Black"/>

        </StackPanel>

    </Grid>
</Window>
"@

# =========================
# LOAD UI
# =========================
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# =========================
# TEXT FIX
# =========================
$window.FindName("Welcome").Text =
"Welcome $User — Ready to optimize your PC"

$window.FindName("Hardware").Text =
"CPU: $CPU | GPU: $GPU | RAM: ${RAM}GB"

# =========================
# BUTTON EVENTS
# =========================
$window.FindName("BTN_WIN").Add_Click({ WindowsTweaks })
$window.FindName("BTN_GPU").Add_Click({ GPUTweaks })
$window.FindName("BTN_CPU").Add_Click({ CPUTweaks })
$window.FindName("BTN_NET").Add_Click({ NetworkTweaks })
$window.FindName("BTN_DEBLOAT").Add_Click({ Debloat })
$window.FindName("BTN_CLEAN").Add_Click({ Cleanup })

# =========================
# RUN
# =========================
$window.ShowDialog() | Out-Null