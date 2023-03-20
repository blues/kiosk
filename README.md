BACKGROUND

This project implements the basics of a 'kiosk' application for the Raspberry Pi.

PURPOSE

This project demonstrates several things:
1. Productive use of the Notecard with only the 'notecard' utility and shell scripts, by leveraging the ability for the Notecard utility to simply send a JSON request to the Notecard on the command line and get its JSON response on stdout.
2. The ability to set the Raspberry Pi's local time by using the Notecard's time function.  This is particularly important for devices that aren't attached to the internet, and the ability to set time zone is even more important if there is work to be done at, say, 2AM local time.
3. The ability to incrementally download large files from a repository such as Amazon S3, using byte-range HTTP get requests.

CONCEPT OF OPERATIONS

1. The dev begins by packaging a ZIP file with the HTML and images implementing a static web page that displays and rotates through the desired visuals.  Note that the 'example' directory in this repo builds two such projects - one that rotates images forward, and one that rotates images backward.  Note also that this example project has a JSON data file whose contents contains a message that is dynamically updated on the display by changing an environment variable.

2. The dev configures a new project, and modifies the definitions in kiosk.sh with its ProductUID.  An example can be found at: https://notehub.io/project/app:e6c880d3-485e-4486-8502-e05e0e49b149/devices

3. The dev uploads their ZIP file to a repository where the Notehub can get at it via HTTP.  In our example, an S3 repo was created that allows access to https://notecard-kiosk.s3.amazonaws.com/kiosk-forward.zip and kiosk-backward.zip

4. The dev creates an 'alias' route to access that repo, with an alias of "kiosk".  In our case the S3 bucket was made public, it may also be private if the HTTP headers are set with credentials for private access.  https://notehub.io/project/app:e6c880d3-485e-4486-8502-e05e0e49b149/route/route:ba07e9bc1042275be3e66d65fc816e3b/settings

5. The dev configure's the project or its fleet with environment vars.  An example can be found at: https://notehub.io/project/app:e6c880d3-485e-4486-8502-e05e0e49b149/devices/fleet/fleet:d7a8c947-ab81-441c-8fe0-6e758edb9f88/settings/environment
	kiosk_content contains the file name of the zip file to be downloaded
	kiosk_content_version contains a version number.  Whenever it is changed on the notehub, the devices will download it.
	kiosk_download_time is the local time when download should occur.  For example, "2" will download it at 2am local time.  Note that if you set it to "now" it will download immediately when the file name or version number changs.
	kiosk_data is the JSON object that is dyanmically 'pushed' to the devices on a continuous basis, as separate from the download.  In the example, the message in {"message":"hello"} can be changed and it will update on the kiosks within several seconds

6. When the local kiosk.sh is run (and you can test it on your Mac or Windows PC with a local notecard), it first does a hub.set to put the Notecard into continuous mode.

7. Then, if not running on your dev laptop, it will set the time on the local RPi by using card.time and using setting both the local time and the local time zone.

8. Then, it enters a loop wherein it a) detects whether or not a new download is needed (and does the download if so), and b) detects whether or not the 'data' in the browser needs to be updated (and does so).  It does this by polling environment variables.

9. Note that on the RPi, it will launch chromium automatically.  On your development machine, you will need to open this in your browser, modifying the URL as approriate: 
file:///Users/rozzie/kiosk-data/active/resources/index.htm

10. If you update the environment variable with the "data", you should see it be modified in the browser within several seconds.

RASPBERRY PI INSTALLATION PREREQUISITES

Start with a Raspberry Pi 4B with a clean install, and add a Notecard sheld.  (Prior versions of the Raspberry Pi will also work, but the HDMI outputs of the 4 are far more robust and handle a wider variety of displays.)

It's best to use a NOTE-WBNA or NOTE-WBEX because of the higher download bandwidth afforded by LTE Cat-1, as opposed to the narrowband Notecards.  (Of course, you can also use NOTE-WiFi when you're testing.)

Notecard firmware 15894 or later should be used, because of a new "total" return argument added to the web.get function when using byte range requests..

It's best to use wired networking and NOT to enable WiFi, so that you can easily test the script's ability to set the time on the local RPi by using the Notecard.

NOTE that the Notecard CLI version 1.2.1 must be used because of some minor but important fixes, and this is the version in the "cli" folder of this repo.

To enable I2C on Raspberry Pi for the Notecard, use instructions in kiosk.sh.

Prerequisite:
   sudo apt-get install jq

To run it, just switch into the kiosk directory and type "./kiosk.sh"


