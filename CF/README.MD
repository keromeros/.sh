This folder contains the script solution for a problem a friend of mine had.
He wanted an raspbery pi video looper but using raspbian instead of a dedicated distro for looping video.
This solution relies on 3 steps:

	1 - Crontab to execute a script "k1.sh" on startup.	
	
	2 - Script "k1.sh" to launch a separate terminal window to execute script "k2.sh".
	
	3 - Script "k2.sh" to do the heavy lifting.

1 - I've added a line to the crontab entry to start script "k1.sh" on startup with a delay of 60 seconds to give a possibility to cancel the job if needed with the folowing command:

	#crontab line
	@reboot sleep 60 && /home/pi/Documents/k1.sh
  
	#Command to cancel jobs
	crontab -r
	
2 - The "k1.sh" is just a control script so i can force close script "k2.sh" that is launched by "k1.sh" without losing acess to the raspian distro because script "k2.sh" is looping video on fullscreen.

3 - The "k2.sh" does all the heavy lifting.

It checks on startup if there is a usb device connected to a specific port and in my case its usb port nr 3 on the raspbery pi.

If there is a storage usb device on port 3 it list all video files in the usb recursively and creates a video playlist to be run on a loop on vlc command line on fullcreen.

If there is no storage usb device on port 3 it defaults to a fallback location, the local video folder' and creates a video playlist to be run on a loop on vlc command line on fullscreen.
    
This way it will always loop a video wether its a video folder on the usb storage device or on the local video file location.
