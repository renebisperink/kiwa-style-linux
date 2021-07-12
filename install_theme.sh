#!/bin/bash

#A simple installscript for the kiwa theme. For now it only works on Ubuntu/Debian/Kali based systems.
#uncomment the functions you need
#@author Rene Bisperink
#@version 0.3

install_theme.sh () {
	#update;
	#addkiwauser;
	#installkaligui
	setbackground;
	#configurexfce;
	#installpentest;
	#installffdev;
		
}
update () {
	echo "[*] Running apt update && apt upgrade"
	sudo apt update
	sudo apt upgrade -y
}

addkiwauser () {
	echo "[*] Adding the kiwa user"
	adduser kiwa
	echo "kiwa" | passwd --stdin kiwa
	sudo usermod -aG sudo kiwa 
	
}

installkaligui () {
	update;
	echo "[*] Installing the kali-win-kex package to have a GUI on WSL"
	sudo apt install kali-win-kex
}

setbackground () {
	echo "[*] Setting the background"
	for b in $(xfconf-query --channel xfce4-desktop --list | grep last-image)
	do
		echo "Setting the background from $(pwd)/unnamed.jpg"
		xfconf-query --channel xfce4-desktop --property $b --set $(pwd)/unnamed.jpg
	done
	
	echo "[*] Setting the image style to centered"
	for s in $(xfconf-query --channel xfce4-desktop --list | grep image-style)
	do
		echo "Setting the style to centered on $s"
		xfconf-query --channel xfce4-desktop --property $s --set 1
	done
	
	echo "[*] Setting the color style"
	for c in $(xfconf-query --channel xfce4-desktop --list | grep color-style)
	do
		echo "Setting the color style to centered on $c"
		xfconf-query --channel xfce4-desktop --property $c --set 0
	done

	# TO BE FIXED
	#echo "[*] Setting the wallpaper background color"
	#for r in $(xfconf-query --channel xfce4-desktop --list | grep color1 )
	#do
	#	echo "Setting the color background to centered on $r"
	#	xfconf-query -c xfce4-desktop -p $r -t int -t int -t int -t int -s 255 -s 255 -s 255 -s 1
	#done
	
}


installpentest () {
	update;
	echo "[*] Installing pentest packages"
	sudo apt install -y exiftool wine64 gdb wireshark wine seclists gobuster ftp php-curl python3-smb mingw-w64
	if [ -n "$(uname -a | grep Kali)"]; then
		echo "[*] Installing the kali-linux-large package"
		sudo apt install kali-linux-large -y
	fi
	installptf;
}

installptf () {
	cd /opt/
	echo "[*] Installing the Penetration Testers Framework (ptf) by Dave Kennedy (TrustedSec)"
	if [ "$EUID" -ne 0 ] 
	then
  		sudo chown -R $USER:$USER /opt  		
	fi

	git clone https://github.com/trustedsec/ptf.git
	cd /opt/ptf
	chmod +x ptf
	sudo ./ptf --update-all
}


configurexfce () {
	echo "[*] setting the icons to the Windows 10 icons from Kali"
	sudo xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons

}



installffdev () {
	echo "[*] Installing Firefox Developer"

 	FIREFOX_DESKTOP="[Desktop Entry]\nName=Firefox Developer\nGenericName=Firefox Developer Edition\nExec=/opt/firefox-dev/firefox -p\nTerminal=false\nIcon=/opt/firefox-dev/browser/chrome/icons/default/default128.png\nType=Application\nCategories=Application;Network;X-Developer;\nComment=Firefox Developer Edition Web Browser."
    
    	curl -o releases.txt https://download-installer.cdn.mozilla.net/pub/devedition/releases/
    	VERSION=$(grep -o '[0-9][0-9]\.[0-9][a-z][0-9]' releases.txt | tail -1)    
        rm releases.txt    

   	# Get download file name.
  	FILE=firefox-$VERSION.tar.bz2

    	# Create /opt/firefox-dev if it doesn't exist.
    	if [ ! -d "/opt/firefox-dev" ]
    	then 
        	mkdir /opt/firefox-dev
   	fi

   	# Get Firefox download.
    	curl -o $FILE https://download-installer.cdn.mozilla.net/pub/devedition/releases/$VERSION/linux-x86_64/en-US/$FILE

    	# If you don't get the file you specified, you get an HTML file with a 
    	#'404 Not found' text in it.
   	if grep -iq '404 Not found' $FILE 
    	then
        	clear
        	echo Error...
        	echo $FILE did not download.
       		rm $FILE
        	exit 
    	fi

    	# Unzip the install file.
    	tar xvjf $FILE

   	# Clear the target directory.
   	sudo rm -rf /opt/firefox-dev/*

    	# Move the program files to the target directory.
   	sudo mv firefox/* /opt/firefox-dev

    	# make current user the owner of the firefox folder
    	sudo chown $USER:$USER /opt/firefox-dev

    	# Remove the unzipped install folder.
    	rm -rf firefox

   	# Remove the install file.
    	rm $FILE
    
    	echo -e ${FIREFOX_DESKTOP} > ~/Desktop/firefox-dev.desktop
    	sudo cp ~/Desktop/firefox-dev.desktop /usr/share/applications/firefox-dev.desktop
    	
    	echo "Firefox Dev Ed $VERSION installed."
   
}

install_theme.sh
