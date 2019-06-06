# tesla_wrappers
Wrappers for various Tesla / Blackvue Automations using Windows, PowerShell, and Python.

Referral Code (1000 Free Supercharger Miles):
 - https://www.tesla.com/referral/mario3921

Dependencies / Modified Sources

- Windows CIFS Network Share
- Local DNS registration for BlackVue / Teslausb

Windows Task Scheduler (Assign Account & Run Whether Account is logged in or not):
- https://github.com/raushel/tesla_wrappers/blob/master/StitchTeslaCam.xml
- https://github.com/raushel/tesla_wrappers/blob/master/BlackVueDownloader.xml

Variable Library:
 - https://github.com/raushel/tesla_wrappers/blob/master/VarLibrary.ps1

Python 37:
- https://www.python.org/downloads/release/python-370/

PIP:
- https://www.liquidweb.com/kb/install-pip-windows/

CMTrace (For reading log files):
- https://docs.microsoft.com/en-us/sccm/core/support/cmtrace

Functions for logging in CMTrace format:
- https://janikvonrotz.ch/2017/10/26/powershell-logging-in-cmtrace-format/

Stitch Sentry Mode / Saved footage together:
- https://github.com/ehendrix23/tesla_dashcam

Pi Zero W: TeslaUSB - marcone dev-main branch
- https://github.com/marcone/teslausb
- balenaEtcher: https://www.balena.io/etcher/
- latest teslausb boot image flashed via balenaEtcher: https://github.com/marcone/teslausb/releases
- Sample .conf: https://github.com/marcone/teslausb/blob/main-dev/doc/teslausb_setup_variables.conf.sample
- Pi Zero W Starter Kit: https://smile.amazon.com/gp/product/B0748MPQT4
- Short Micro USB: https://smile.amazon.com/gp/product/B01NAMTC5T
- Samsung Pro Endurance 128GB: https://smile.amazon.com/gp/product/B07B984HJ5
- Onvian USB Splitter (x2): https://smile.amazon.com/gp/product/B01KX4TKH6

Modified Yogo's BlackVue Downloader:
- https://dashcamtalk.com/forum/threads/blackvue-network-file-downloader-updated-07-06.29728/
- Added logging and made headless
- BlackVue DR-900s-2CH

BlackVue PIP:
- https://dashcamtalk.com/forum/threads/batch-file-to-use-ffmpeg-to-generate-single-pip-video-from-front-read.32570/
- TODO: Create Headless wrapper with logging
