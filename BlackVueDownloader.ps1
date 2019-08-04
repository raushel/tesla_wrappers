
$VerboseLogging = "true"
[bool]$Global:Verbose = [System.Convert]::ToBoolean($VerboseLogging)
. $PSScriptRoot\VarLibrary.ps1
. $PSScriptRoot\CMTraceLogger.ps1

$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

function set_arrays
{
$Script:Car1 = [PSCustomObject]@{
    IP = $DC_IP_1
    CarName = $DC_CAR1
    Carpath = $IP_1_PATH
    }

$Script:Car2 = [PSCustomObject]@{
    IP = $DC_IP_2
    CarName = $DC_CAR2
    Carpath = $IP_2_PATH
    }

$Script:Car3 = [PSCustomObject]@{
    IP = $DC_IP_3
    CarName = $DC_CAR3
    Carpath = $IP_3_PATH
    }

$Script:Car4 = [PSCustomObject]@{
    IP = $DC_IP_4
    CarName = $DC_CAR4
    Carpath = $IP_4_PATH
    }

$Script:Car5 = [PSCustomObject]@{
    IP = $DC_IP_5
    CarName = $DC_CAR5
    Carpath = $IP_5_PATH
    }
}

#Set the Created/Modified Date based on the filedate rather than copied date
function timestamp ($path, $filename)
{
    $file = Get-Item "$path"
    $dateTimeName = $filename.insert(4,'-').insert(7,'-').insert(13,':').insert(16,':')
    $datetime = [datetime]$dateTimeName.substring(0,10) + [TimeSpan]$dateTimeName.substring(11,8).replace('-',':')

    $file.LastWriteTime = $datetime
    $file.CreationTime = $datetime
}
function intro
{
$host.ui.RawUI.WindowTitle = "YOGO'S BLACKVUE DOWNLOADER v0.4"
CLS
$timestamp = Get-Date -Format "HH:mm:ss.ffffff"
LogIt -message ("BlackVue Downloader Started") -component "intro()" -type 1 
write-output "`n"
write-output "`n"
write-output "YOGO'S BLACKVUE DOWNLOADER v0.4"
write-output "`n"
write-output "`n"
}

function check_paths
{
$carpaths = New-Object System.Collections.Generic.List[System.Object]
if ($Car1.IP -ne 0){$carpaths.add($Car1.Carpath)}
if ($Car2.IP -ne 0){$carpaths.add($Car2.Carpath)}
if ($Car3.IP -ne 0){$carpaths.add($Car3.Carpath)}
if ($Car4.IP -ne 0){$carpaths.add($Car4.Carpath)}
if ($Car5.IP -ne 0){$carpaths.add($Car5.Carpath)}

Foreach ($checkpath in $CarPaths)

{

write-output " ------------------------------------------------------------------------------------------------------- "
write-output "`n"
write-output "Testing path: $DCROOT_FOLDER\$Checkpath\"
LogIt -message ("Testing path: $DCROOT_FOLDER\$Checkpath\") -component "check_paths()" -type 1 
if (test-path $DCROOT_FOLDER\$Checkpath\) 
    { 
        write-output " -- TEST SUCCESSFUL"
        LogIt -message (" -- TEST SUCCESSFUL") -component "check_paths()" -type 1

    } 
    else {
        $Host.UI.WriteErrorLine("          The folder structure is not set up properly.") 
        write-output "`n"
        $Host.UI.WriteErrorLine("    Please double check the settings at the top of this file")
        write-output "`n"
        $Host.UI.WriteErrorLine("Alternatively, please see the readme file that cam with this script")
        write-output "Press any key to exit..."
        $HOST.UI.RawUI.Flushinputbuffer()
        $HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
        $HOST.UI.RawUI.Flushinputbuffer()
        EXIT
        }
    }
}

function Cam_Choice
{
$IPList_temp = ($Car1.IP,$Car2.IP,$Car3.IP,$Car4.IP,$Car5.IP)

$IPList = $IPList_temp | Where-Object {$_ -ne "0"}
$Results = foreach ($IP in $IPList)
    {
        IF ($IP -EQ $CAR1.IP) {$CAR_FRIENDLY = $CAR1.CARNAME}
        IF ($IP -EQ $CAR2.IP) {$CAR_FRIENDLY = $CAR2.CARNAME}
        IF ($IP -EQ $CAR3.IP) {$CAR_FRIENDLY = $CAR3.CARNAME}
        IF ($IP -EQ $CAR4.IP) {$CAR_FRIENDLY = $CAR4.CARNAME}
        IF ($IP -EQ $CAR5.IP) {$CAR_FRIENDLY = $CAR5.CARNAME}
    write-host "Testing for Camera connection on $IP ..." -ForegroundColor Yellow
    LogIt -message ("Testing for Camera connection on $IP ...") -component "Cam_Choice()" -type 2 

    $Response = Test-Connection -ComputerName $IP -Count 1 -Quiet
    $TempObject = [PSCustomObject]@{
        IP = $IP
        Status = ('Offline - No response', 'Online')[$Response]
        Name = $CAR_FRIENDLY
        }
    $TempObject
    }

$OnlineIPList = ($Results | Where-Object {$_.Status -eq 'Online'}).IP

$MidDot = [char]183
$Choice = ''
while ($Choice -eq '')
    {
    Clear-Host
    $ValidChoices = @('A', 'X')
    foreach ($Index in 0..($Results.Count - 1))
        {
        $PaddedIP = $Results[$Index].IP.PadRight(13, $MidDot)
        $PaddedName = $Results[$Index].Name.PadRight(10, $MidDot)
        "[ {0} ] - {1,-10} {2,-10} {3}" -f $Index, $PaddedName, $PaddedIP, $Results[$Index].Status
        $ValidChoices += $Index
        }
    ''
    $Choice = '0'
    #$Choice = (Read-Host 'Please choose a [number], [A] for All Online, or [X] to exit.').ToUpper()
    if ($Choice -notin $ValidChoices)
        {
        #[console]::Beep(1000, 300)
        Write-Output "    >> $Choice << is not a valid selection, please try again."
        LogIt -message (">>$Choice << is not a valid selection, please try again.") -component "Cam_Choice()" -type 3 

        #start-sleep -s 5
        ''
        #Break
        EXIT
        #$Choice = ''

        continue
        }
    $TargetList = @()
    switch ($Choice)
        {
        {$_ -in 0..4}
            {
            if ($Results[$Choice].Status -eq 'Online')
                {
                $TargetList += $Results[$Choice].IP
                }
                else
                {
                Write-Output ''
                "The address you chose >> [{0}] - {1} << is offline." -f $Choice, $Results[$Choice].IP
                '    Returning to the menu.'
                LogIt -message ("The address you chose >> [{0}] - {1} << is offline." -f $Choice, $Results[$Choice].IP) -component "Cam_Choice()" -type 3 

                #pause
                EXIT
                
                }
            #$Choice = ''
            Break
          
            }
        'A'
            {
            $TargetList = $OnlineIPList
            $SCRIPT:CARTARGET = $CAR1,$CAR2,$CAR3,$CAR4,$CAR5
            $Host.UI.WriteWarningLine("THIS FEATURE HAS NOT BEEN IMPLEMENTED YET")
            #DOWNLOAD-ALL
            EXIT
            $Choice = '' 
            break
            }
        'X'
            {break}
        default
            {$Choice}
        }

    if ($TargetList.Count -gt 0)
        {
        Clear-Host
        foreach ($TL_IP in $TargetList)
            {
            $Script:TL_IP = $TL_IP

            Process_Files $TL_IP

            }
        }
    }

# restore previous VerbosePref
$VerbosePreference = $Old_VPref
}

function Process_Files
{
Param(
    [parameter(Mandatory=$true)]
    [String]
    $IP_Target
)
IF ($IP_TARGET -EQ $CAR1.IP) {$SCRIPT:CARTARGET = $CAR1}
IF ($IP_TARGET -EQ $CAR2.IP) {$SCRIPT:CARTARGET = $CAR2}
IF ($IP_TARGET -EQ $CAR3.IP) {$SCRIPT:CARTARGET = $CAR3}
IF ($IP_TARGET -EQ $CAR4.IP) {$SCRIPT:CARTARGET = $CAR4}
IF ($IP_TARGET -EQ $CAR5.IP) {$SCRIPT:CARTARGET = $CAR5}

$SCRIPT:CARPATH = $CARTARGET.CARPATH
$SCRIPT:DC_IP = $CARTARGET.IP
write-output "`n"
write-output "RETREIVING FILE LIST FROM CAMERA"
LogIt -message ("Retreiving File List From Camera") -component "Process_Files()" -type 1
(New-Object System.Net.WebClient).DownloadString("http://{0}/blackvue_vod.cgi" -f $CARTARGET.IP) >$DCROOT_FOLDER\$CARPATH\file.list
write-output "`n"

if (test-path $DCROOT_FOLDER\$CARPATH\file.list) {
    write-output "File List successfully retreived"
    LogIt -message ("File List successfully retreived") -component "Process_Files()" -type 2
    }else{
        #$Host.UI.WriteWarningLine("UNABLE TO CONTACT CAMERA... EXITING")
        LogIt -message ("UNABLE TO CONTACT CAMERA... EXITING") -component "Process_Files()" -type 3
        write-output "Press any key to exit..."
        #$HOST.UI.RawUI.Flushinputbuffer()
        #$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
        #$HOST.UI.RawUI.Flushinputbuffer()
        EXIT
}
write-output "`n"

$SCRIPT:FILE_LIST1 = (Get-Content $DCROOT_FOLDER\$CARPATH\file.list) -notmatch "v:" -split "`r`n"
DEL $DCROOT_FOLDER\$CARPATH\file.list
$SCRIPT:FILE_COUNT = $FILE_LIST1 | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT
$SCRIPT:VID_COUNT = [math]::round( ($FILE_COUNT / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:PARK_COUNT = ($FILE_LIST1 | WHERE-OBJECT  {$_ -LIKE "*_P*.MP4*"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:PARK_COUNT= [math]::round( ($PARK_COUNT / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:EVENT_COUNT = ($FILE_LIST1 | WHERE-OBJECT {$_ -LIKE "*_E*.MP4*"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:EVENT_COUNT= [math]::round( ($EVENT_COUNT / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:MANUAL_COUNT = ($FILE_LIST1 | WHERE-OBJECT {$_ -LIKE "*_M*.MP4*"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:MANUAL_COUNT= [math]::round( ($MANUAL_COUNT / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:NORMAL_COUNT = ($FILE_LIST1 | WHERE-OBJECT {$_ -LIKE "*_N*.MP4*"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:NORMAL_COUNT= [math]::round( ($NORMAL_COUNT / 2) , [system.midpointrounding]::AwayFromZero )

$SCRIPT:FILE_LIST2 = $FILE_LIST1 | % { if ($_) { $_.trimstart('n:/Record/').split(',')[0] }}

$FILE_LIST3 = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_EVENT = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_PARK = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_NORMAL = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_MANUAL = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_ALL = New-Object System.Collections.Generic.List[System.Object]

$SCRIPT:FILE_LIST_EVENT_TMP = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_PARK_TMP = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_NORMAL_TMP = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_MANUAL_TMP = New-Object System.Collections.Generic.List[System.Object]
$SCRIPT:FILE_LIST_ALL_TMP = New-Object System.Collections.Generic.List[System.Object]

FOREACH ($LISTING IN $FILE_LIST2) {IF ( test-path "$DCROOT_FOLDER\$CARPATH\$LISTING" ) {
    }else{ 
          $FILE_LIST3.ADD("$LISTING")
         }
    }

$SCRIPT:PARK_COUNT_NEW = ($FILE_LIST3 | WHERE-OBJECT  {$_ -LIKE "*_P*.MP4"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:PARK_COUNT_NEW = [math]::round( ($PARK_COUNT_NEW / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:EVENT_COUNT_NEW = ($FILE_LIST3 | WHERE-OBJECT {$_ -LIKE "*_E*.MP4"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:EVENT_COUNT_NEW= [math]::round( ($EVENT_COUNT_NEW / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:MANUAL_COUNT_NEW = ($FILE_LIST3 | WHERE-OBJECT {$_ -LIKE "*_M*.MP4"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:MANUAL_COUNT_NEW= [math]::round( ($MANUAL_COUNT_NEW / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:NORMAL_COUNT_NEW = ($FILE_LIST3 | WHERE-OBJECT {$_ -LIKE "*_N*.MP4"} | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$SCRIPT:NORMAL_COUNT_NEW = [math]::round( ($NORMAL_COUNT_NEW / 2) , [system.midpointrounding]::AwayFromZero )
$SCRIPT:VID_COUNT_NEW = ($SCRIPT:NORMAL_COUNT_NEW + $SCRIPT:MANUAL_COUNT_NEW + $SCRIPT:EVENT_COUNT_NEW + $SCRIPT:PARK_COUNT_NEW)

FOREACH ($ENTRY IN $FILE_LIST3) {IF ($ENTRY -LIKE "*_E*.mp4") {
    $ENTRY = $ENTRY.trimend("F.mp4")
    $ENTRY = $ENTRY.trimend("R.mp4")
    $FILE_LIST_EVENT_TMP.ADD("$ENTRY")
    $ENTRY = ''
    }
}
$FILE_LIST_EVENT = $FILE_LIST_EVENT_TMP|
    Sort-Object |
    Get-Unique

FOREACH ($ENTRY IN $FILE_LIST3) {IF ($ENTRY -LIKE "*_P*.mp4") {
    $ENTRY = $ENTRY.trimend("F.mp4")
    $ENTRY = $ENTRY.trimend("R.mp4")
    $FILE_LIST_PARK_TMP.ADD("$ENTRY")
    $ENTRY = ''
    }
}
$FILE_LIST_PARK = $FILE_LIST_PARK_TMP|
    Sort-Object |
    Get-Unique

FOREACH ($ENTRY IN $FILE_LIST3) {IF ($ENTRY -LIKE "*_N*.mp4") {
    $ENTRY = $ENTRY.trimend("F.mp4")
    $ENTRY = $ENTRY.trimend("R.mp4")
    $FILE_LIST_NORMAL_TMP.ADD("$ENTRY")
    $ENTRY = ''
    }
}
$FILE_LIST_NORMAL = $FILE_LIST_NORMAL_TMP|
    Sort-Object |
    Get-Unique

FOREACH ($ENTRY IN $FILE_LIST3) {IF ($ENTRY -LIKE "*_M*.mp4") {
    $ENTRY = $ENTRY.trimend("F.mp4")
    $ENTRY = $ENTRY.trimend("R.mp4")
    $FILE_LIST_MANUAL_TMP.ADD("$ENTRY")
    $ENTRY = ''
    }
}
$FILE_LIST_MANUAL = $FILE_LIST_MANUAL_TMP|
    Sort-Object |
    Get-Unique

FOREACH ($ENTRY IN $FILE_LIST3) {IF (1 -EQ 1) {
    $ENTRY = $ENTRY.trimend("F.mp4")
    $ENTRY = $ENTRY.trimend("R.mp4")
    $FILE_LIST_ALL_TMP.ADD("$ENTRY")
    $ENTRY = ''
    }
}
$FILE_LIST_ALL = $FILE_LIST_ALL_TMP|
    Sort-Object |
    Get-Unique






write-output "`n"
write-output "`n"
write-output "`n"
write-output "`n"
write-output "`n"
write-output " ------------------------------------------------------------------------------------------------------- "
write-output "`n"
write-output "TOTAL NUMBER OF VIDEOS ON THE CAMERA IS $VID_COUNT WITH $VID_COUNT_NEW NEW"
if($VID_COUNT_NEW -gt 20) {$type = 3} else {$type = 1}
LogIt -message ("Total:  $VID_COUNT | New: $VID_COUNT_NEW ") -component "Process_Files()" -type $type
write-output "`n"
write-output "NUMBER OF NORMAL RECORDINGS IS $NORMAL_COUNT WITH $NORMAL_COUNT_NEW NEW"
LogIt -message ("Normal: $NORMAL_COUNT | New: $NORMAL_COUNT_NEW") -component "Process_Files()" -type $type
write-output "`n"
write-output "NUMBER OF EVENT RECORDINGS IS $EVENT_COUNT WITH $EVENT_COUNT_NEW NEW"
LogIt -message ("Event:  $EVENT_COUNT | New: $EVENT_COUNT_NEW") -component "Process_Files()" -type $type
write-output "`n"
write-output "NUMBER OF PARKED RECORDINGS IS $PARK_COUNT WITH $PARK_COUNT_NEW NEW"
LogIt -message ("Parked: $PARK_COUNT | New: $PARK_COUNT_NEW") -component "Process_Files()" -type $type
write-output "`n"
write-output "NUMBER OF MANUAL RECORDINGS IS $MANUAL_COUNT WITH $MANUAL_COUNT_NEW NEW"
LogIt -message ("Manual: $MANUAL_COUNT | New: $MANUAL_COUNT_NEW") -component "Process_Files()" -type $type
write-output "`n"
write-output " ------------------------------------------------------------------------------------------------------- "






$Choice = ''
while ($Choice -eq '')
    {
    $ValidChoices = @('E', 'N', 'P', 'M', 'A', 'X')
    write-output " Please choose from the following options:
                `n
                -------------------------------------
                [E] For Event recordings Only
                [N] For Normal recordings only
                [P] For Parking mode recordings only
                [M] For Manual recordings only
                [A] For all recordings
                -------------------------------------
                [X] To Quit
                `n
                "
    $Choice = 'A'
    #$Choice = (Read-Host 'Please enter a selection  ').ToUpper()
    if ($Choice -notin $ValidChoices)
        {
        #[console]::Beep(1000, 300)
        Write-Output "    >> $Choice << is not a valid selection, please try again."
        start-sleep -s 5
        ''
        $Choice = ''

        continue
        }
    switch ($Choice)
        {
        'A'
            {
            $SCRIPT:FILE_COUNT = ($VID_COUNT_NEW*2)
            DOWNLOAD_VIDS ALL
            $Choice = '' 
            break
            }
        'X'
            {exit}
            exit
            {$Choice}
        'E'
            {
            $SCRIPT:FILE_COUNT = ($EVENT_COUNT_NEW*2)
            DOWNLOAD_VIDS EVENT
            $Choice = '' 
            break
            }
        'P'
            {
            $SCRIPT:FILE_COUNT = ($PARK_COUNT_NEW*2)
            DOWNLOAD_VIDS PARKING
            $Choice = '' 
            break
            }
        'M'
            {
            $SCRIPT:FILE_COUNT = ($MANUAL_COUNT_NEW*2)
            DOWNLOAD_VIDS MANUAL
            $Choice = '' 
            break
            }
        'N'
            {
            $SCRIPT:FILE_COUNT = ($NORMAL_COUNT_NEW*2)
            DOWNLOAD_VIDS NORMAL
            $Choice = '' 
            break
            }

        }


    }


}


FUNCTION DOWNLOAD_VIDS 
{
Param(
    [parameter(Mandatory=$true)]
    [String]
    $SELECTION
)

write-output "Downloading Video and Data Files... Please Wait (Press Ctrl + C to abort at any time)"
LogIt -message (Downloading Video and Data Files...) -component "Download_Vids()" -type 2

 
$PROCESSTIME = Get-Date
IF ($SELECTION -EQ 'ALL') {$FILE_LIST = $FILE_LIST_ALL}
IF ($SELECTION -EQ 'ALL') {$VID_COUNT = $VID_COUNT_NEW}

IF ($SELECTION -EQ 'PARKING') {$FILE_LIST = $FILE_LIST_PARK}
IF ($SELECTION -EQ 'PARKING') {$VID_COUNT = $PARK_COUNT_NEW}

IF ($SELECTION -EQ 'MANUAL') {$FILE_LIST = $FILE_LIST_MANUAL}
IF ($SELECTION -EQ 'MANUAL') {$VID_COUNT = $MANUAL_COUNT_NEW}

IF ($SELECTION -EQ 'NORMAL') {$FILE_LIST = $FILE_LIST_NORMAL}
IF ($SELECTION -EQ 'NORMAL') {$VID_COUNT = $NORMAL_COUNT_NEW}

IF ($SELECTION -EQ 'EVENT') {$FILE_LIST = $FILE_LIST_EVENT}
IF ($SELECTION -EQ 'EVENT') {$VID_COUNT = $EVENT_COUNT_NEW}


$FILENUM_PROGRESS_UNROUNDED = 0
$FILENUM_PROGRESS = 0
$ACTIVITY_ID = 0
$FILENUM_PROGRESS_UNROUNDED = 0
$VID_COUNT = ($FILE_LIST | MEASURE |SELECT-OBJECT -EXPANDPROPERTY COUNT)
$MATHCOUNT = ($VID_COUNT *2)
$FILECOUNT = ($VID_COUNT *2)

FOREACH ($DATA IN $FILE_LIST)
{
$ACTIVITY_ID = ($ACTIVITY_ID+1)
$FILENUM_PERCENTAGE = 0
$FILENUM_PROGRESS = ($FILENUM_PROGRESS+1)

$Progress = [math]::Round((($FILENUM_PROGRESS / $VID_COUNT) * 100),2)
Write-Output -ID 1 -ACTIVITY "DOWNLOADING VIDEO FILES: $Progress%"
LogIt -message ("Downloading Video Files: $Progress%") -component "Download_Vids()" -type 1

Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT"  -CurrentOperation "Retreiving video files from camera: 0%"
LogIt -message ("Getting video $FILENUM_PROGRESS of $VID_COUNT") -component "Download_Vids()" -type 1 
LogIt -message ("Retreiving video files from camera: 0%") -component "Download_Vids()" -type 1 

$urlF = "http://$DC_IP/Record/$DATA" + "F.mp4"
$urlR = "http://$DC_IP/Record/$DATA" + "R.mp4"
$urlG = "http://$DC_IP/Record/$DATA.gps"
$url3 = "http://$DC_IP/Record/$DATA.3gf"

$VIDNAME = $DATA + 'F.mp4'
Write-Output $VIDNAME
$DEST = "$DCROOT_FOLDER\$CARPATH\$VIDNAME"
(New-Object System.Net.WebClient).DownloadFile($urlF, $DEST)
    IF ($FILENUM_PROGRESS_UNROUNDED -EQ $VID_COUNT)
    {
    } ELSE {
        $FILENUM_PROGRESS_UNROUNDED = ($FILENUM_PROGRESS_UNROUNDED+0.5)
        $FILENUM_PERCENTAGE = ($FILENUM_PERCENTAGE+50)
    }
    Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT" -CurrentOperation "Retrieving video files from camera: $FILENUM_PERCENTAGE%"
    LogIt -message ("Getting video $VIDNAME | $FILENUM_PROGRESS of $VID_COUNT") -component "Download_Vids()" -type 2 
    LogIt -message ("Retrieving video files from camera: $FILENUM_PERCENTAGE%") -component "Download_Vids()" -type 1 
    
    timestamp -path $DEST -filename $VIDNAME

$VIDNAME = $DATA + 'R.mp4'
Write-Output $VIDNAME
$DEST = "$DCROOT_FOLDER\$CARPATH\$VIDNAME"
(New-Object System.Net.WebClient).DownloadFile($urlR, $DEST)
    IF ($FILENUM_PROGRESS_UNROUNDED -EQ $VID_COUNT)
    {
    } ELSE {
        $FILENUM_PROGRESS_UNROUNDED = ($FILENUM_PROGRESS_UNROUNDED+0.3)
        $FILENUM_PERCENTAGE = ($FILENUM_PERCENTAGE+30)
    }
    Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT" -CurrentOperation "Retrieving video files from camera: $FILENUM_PERCENTAGE%"
    LogIt -message ("Getting video $VIDNAME | $FILENUM_PROGRESS of $VID_COUNT") -component "Download_Vids()" -type 2
    LogIt -message ("Retrieving video files from camera: $FILENUM_PERCENTAGE%") -component "Download_Vids()" -type 1 

    timestamp -path $DEST -filename $VIDNAME

$VIDNAME = $DATA + '.gps'
Write-Output $VIDNAME
$DEST = "$DCROOT_FOLDER\$CARPATH\$VIDNAME"
(New-Object System.Net.WebClient).DownloadFile($urlG, $DEST)
    IF ($FILENUM_PROGRESS_UNROUNDED -EQ $VID_COUNT)
    {
    } ELSE {
        $FILENUM_PROGRESS_UNROUNDED = ($FILENUM_PROGRESS_UNROUNDED+0.1)
        $FILENUM_PERCENTAGE = ($FILENUM_PERCENTAGE+10)
    }
    Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT" -CurrentOperation "Retrieving video files from camera: $FILENUM_PERCENTAGE%"
    LogIt -message ("Getting video $VIDNAME | $FILENUM_PROGRESS of $VID_COUNT") -component "Download_Vids()" -type 2
    LogIt -message ("Retrieving video files from camera: $FILENUM_PERCENTAGE%") -component "Download_Vids()" -type 1 
    
Start-Sleep -m 100
timestamp -path $DEST -filename $VIDNAME

$VIDNAME = $DATA + '.3gf'
Write-Output $VIDNAME 
$DEST = "$DCROOT_FOLDER\$CARPATH\$VIDNAME"
(New-Object System.Net.WebClient).DownloadFile($url3, $DEST)
    IF ($FILENUM_PROGRESS_UNROUNDED -EQ $VID_COUNT)
    {
    } ELSE {
        $FILENUM_PROGRESS_UNROUNDED = ($FILENUM_PROGRESS_UNROUNDED+0.1)
        $FILENUM_PERCENTAGE = ($FILENUM_PERCENTAGE+10)
    }
    Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT" -CurrentOperation "Retrieving video files from camera: $FILENUM_PERCENTAGE%"
    LogIt -message ("Getting video $VIDNAME | $FILENUM_PROGRESS of $VID_COUNT") -component "Download_Vids()" -type 2
    LogIt -message ("Retrieving video files from camera: $FILENUM_PERCENTAGE%") -component "Download_Vids()" -type 1 
    
Start-Sleep -m 250
timestamp -path $DEST -filename $VIDNAME

Write-Output -ID ($ACTIVITY_ID+1) -Activity "Getting video $FILENUM_PROGRESS of $VID_COUNT"  -Completed
LogIt -message ("Getting video $FILENUM_PROGRESS of $VID_COUNT Completed") -component "Download_Vids()" -type 1 


}

Write-Output "Time taken: $((Get-Date).Subtract($PROCESSTIME).Seconds) second(s)"
LogIt -message ("Time taken: $((Get-Date).Subtract($PROCESSTIME).Seconds) second(s)") -component "Download_Vids()" -type 1 


Write-Output -ID 1 -ACTIVITY "DOWNLOADING VIDEO FILES" -Completed
LogIt -message ("DOWNLOADING VIDEO FILES COMPLETED") -component "Download_Vids()" -type 1 

write-output "`n"
write-output "`n"

write-output "All files have been downloaded from the camera."
LogIt -message ("All files have been downloaded from the camera.") -component "Download_Vids()" -type $type 
write-output "`n"

write-output " ------------------------------------------------------------------------------------------------------- "
write-output " ------------------------------------------------------------------------------------------------------- "
write-output " ------------------------------------------------------------------------------------------------------- "
write-output "`n"
write-output "`n"
EXIT



}




SET_ARRAYS
INTRO
CHECK_PATHS
CAM_CHOICE