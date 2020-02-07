#BlackVue Downloader Variables
#No Trailing \ in Path
$script:DCROOT_FOLDER = "C:\PathToBlackVue"

$script:DC_CAR1 = "CAR1-NAME"
$script:DC_IP_1 = "xxx.xxx.xxx.xxx"
$script:IP_1_PATH = "Record"

$script:DC_CAR2 = "CAR2-NAME"
$script:DC_IP_2 = "0"
$script:IP_2_Path = "CAR2-FOLDER"

$script:DC_CAR3 = "CAR3-NAME"
$script:DC_IP_3 = "0"
$script:IP_3_Path = "CAR3-FOLDER"

$script:DC_CAR4 = "CAR4-NAME"
$script:DC_IP_4 = "0"
$script:IP_4_Path = "CAR4-NAME"

$script:DC_CAR5 = "CAR5-NAME"
$script:DC_IP_5 = "0"
$script:IP_5_Path = "CAR5-FOLDER"

#Tesla_DashCam Variables
$Global:hostname = 'teslausb' #PiZero Hostname
#No Trailing \ in Path
$Global:path = 'c:\PathToTeslaCam'
$Global:outputFolder = 'OutputFolder'
$Global:usbname = 'pi'
$Global:usbpw = $null
#Additional commandline modification available on line 73: StichTeslaCam.ps1
$Global:quality = 'HIGH'
$Global:layout = 'DIAMOND'
$Global:encoding = 'x265'
$Global:speedup = '2'

#Cleanup Variables
$Global:retDays = 60 #number of days of files to keep

#File Logging
$Global:file_log_enabled = $true #set to $false to disable all file logging
$Global:VerboseLogging = $true #set to $false to only log verbose entries, ignored if file_log_enabled is $false
$Global:MaxLogSizeInKB = 5120

#Pushover
#Use $false or $true
$Global:pushover_enabled=$false
$Global:pushover_user_key="your user key"
$Global:pushover_app_key="your app key"

#IFTTT
$Global:ifttt_enabled=$false
$Global:ifttt_event="tesla_wrappers"
$Global:ifttt_key="your ifttt key"
