# 3DS FBI Link
Mac app to graphically send CIAs to your 3DS running FBI. Extra features over servefiles and Boop.

![Screenshot of 3DS FBI Link in action](/../media/3dsFBILink.png?raw=true "Screenshot")

## Benefits over Boop or servefiles
* **Just double-click on a CIA.** No WINE or command line needed.
* **Send CIA files from anywhere on your computer.** They don't have to be in the same folder. And yes, we do this in a smart way.
* **Uses a random available port.** We don't depend on using port 8080.
* **Send to multiple 3DSes.** If you're testing apps or otherwise, just add 'em all and get going.
* **Mix and match local and internet files.** Use links to CIAs on github together with files you have on your computer.

## Other features to note
* It seems pretty fast. I'm able to send files at up to 1.3MB/s on my New 3DS. This is close to its wireless speed limits.
* Thanks to Boop, we also attempt to autodetect the 3DS, so you don't have to enter its IP address.

## Requirements
1. Nintendo 3DS with FBI
2. MacOS X 10.10 or higher

## Installation
1. Copy 3DS FBI Link app to your Applications Folder

## Usage
1. Open FBI on 3DS. Choose "Receive URLs over the network."
2. Open app on your Mac.
3. If your 3DS is not already listed, click '+' and enter its information, as listed on the FBI screen.
4. Add any files or URLs you would like. Files can also be dragged and dropped or opened

## Help out!
I only have one 3DS, so while I'm pretty sure this will work for sending to multiple consoles, testing has been difficult.
For that or any other issues, help by opening cases on github. My Mac UI skills are rusty, so filing UI polish issues are also helpful.
Seriously though, any issue, no matter how small: let me know!

I'd like to make a proper Apple developer version, but my membership lapsed a while back. [Pitch in a few dollars](https://paypal.me/smartperson/5) if you'd like to help me get that up and running again.

Testing on old 3DS consoles would also be helpful. I have no reason to believe it won't work, but I'd appreciate confirmation.


## To-dos & questions
* More complete edge condition checking (emoji in filenames, connectivity checking)
* Support for multiple network connections
* Auto-updating or update checking functionality
* Auto-scrolling the status field; other UI improvements.
* Create a Apple developer-signed version, so it's easier to launch.

## Credits
* miltoncandelero for the clever idea on autodetecting 3DS consoles on the LAN, used in [Boop](https://github.com/miltoncandelero/Boop).
* Steveice10 for creating and maintaining the incomparable [FBI](https://github.com/Steveice10/FBI).
* The rest of the 3dshacks community, who  build important, exciting stuff below this layer and above it. Your dedication is an inspiration.
