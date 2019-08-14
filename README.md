# tesla_wrappers
Wrappers for various TeslaCam / Blackvue Automations using Windows, PowerShell, and Python

Dependencies / Modified Sources
- Windows CIFS Network Share
- Local DNS registration for BlackVue / Teslausb

Windows Task Scheduler (Assign Account & Run Whether Account is logged in or not):
- https://github.com/raushel/tesla_wrappers/blob/master/StitchTeslaCam.xml
- https://github.com/raushel/tesla_wrappers/blob/master/BlackVueDownloader.xml
- https://github.com/raushel/tesla_wrappers/blob/master/RecordingCleanup.xml

Variable Library:
 - https://github.com/raushel/tesla_wrappers/blob/master/VarLibrary.ps1
 - Moved variables to one file to make it easier to update

Recording Cleanup:
 - https://github.com/raushel/tesla_wrappers/blob/master/RecordingCleanup.ps1
 - Automated purging of old video recordings from both BlackVue and TeslaCam directories, default is 60 days

Stitch Sentry Mode / Saved footage together:
- Wrapper: https://github.com/raushel/tesla_wrappers/blob/master/StitchTeslaCam.ps1
- Tesla_DashCam Repository: https://github.com/ehendrix23/tesla_dashcam
- Python37 Dependency: https://www.python.org/downloads/release/python-370/
- PIP for Windows: https://www.liquidweb.com/kb/install-pip-windows/

CMTrace Logging:
- https://github.com/raushel/tesla_wrappers/blob/master/CMTraceLogger.ps1
- Adapted From: https://janikvonrotz.ch/2017/10/26/powershell-logging-in-cmtrace-format/
- CMTrace Download: https://docs.microsoft.com/en-us/sccm/core/support/cmtrace

Pi Zero W: TeslaUSB - marcone dev-main branch
- https://github.com/marcone/teslausb
- balenaEtcher: https://www.balena.io/etcher/
- latest teslausb boot image flashed via balenaEtcher: https://github.com/marcone/teslausb/releases
- Sample .conf: https://github.com/marcone/teslausb/blob/main-dev/doc/teslausb_setup_variables.conf.sample

Hardware:
- Pi Zero W Starter Kit: https://smile.amazon.com/gp/product/B0748MPQT4
- Short Micro USB: https://smile.amazon.com/gp/product/B01NAMTC5T
- Samsung Pro Endurance 128GB: https://smile.amazon.com/gp/product/B07B984HJ5
- Onvian USB Splitter (x2): https://smile.amazon.com/gp/product/B01KX4TKH6

BlackVue Downloader:
- Wrapper: https://github.com/raushel/tesla_wrappers/blob/master/BlackVueDownloader.ps1
- Adapted From: https://dashcamtalk.com/forum/threads/blackvue-network-file-downloader-updated-07-06.29728/
- Added logging and made headless
- BlackVue DR-900s-2CH

BlackVue PIP:
- https://dashcamtalk.com/forum/threads/batch-file-to-use-ffmpeg-to-generate-single-pip-video-from-front-read.32570/
- TODO: Create Headless wrapper with logging
