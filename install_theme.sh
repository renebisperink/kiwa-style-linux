#!/bin/bash
#A simple installscript for the kiwa theme. For now it only works on Ubuntu/Debian/Kali based systems.
#uncomment the functions you need
#@author Rene Bisperink
#@version 0.2

defaultinstall.sh () {
	#update;
	#addkiwauser;
	#configurexfce;
	#installpentest;
	#installffdev;
		
}
update () {
	sudo apt update
	sudo apt upgrade -y
}

addkiwauser () {
	# Stub for creating a user kiwa:kiwa and add it to the sudoers groep. 
}



installpentest () {
	update;
	sudo apt install -y exiftool wine64 gdb wireshark wine seclists gobuster ftp php-curl python3-smb mingw-w64
	if [ -n "$(uname -a | grep Kali)"]; then
		sudo apt install kali-linux-large -y
	fi
	installptf;
}

installptf () {
	cd /opt/
	git clone https://github.com/trustedsec/ptf.git
	cd /opt/ptf
	chmod +x ptf
	sudo ./ptf --update-all
}


configurexfce () {
	sudo xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons
	sudo 
}



installffdev () {

    FIREFOX_DESKTOP="[Desktop Entry]\nName=Firefox Developer\nGenericName=Firefox Developer Edition\nExec=/opt/firefox-dev/firefox -p\nTerminal=false\nIcon=/opt/firefox-dev/browser/chrome/icons/default/default128.png\nType=Application\nCategories=Application;Network;X-Developer;\nComment=Firefox Developer Edition Web Browser."
    
    curl -o releases.txt https://download-installer.cdn.mozilla.net/pub/devedition/releases/
    VERSION=$(grep -o '[0-9][0-9]\.[0-9][a-z][0-9]' releases.txt | tail -1)    
    rm releases.txt    

    # Get download file name.
    FILE=firefox-$VERSION.tar.bz2

    # Create /opt/firefox-dev if it doesn't exist.
    if [ ! -d "/opt/firefox-dev" ]
    then 
        sudo mkdir /opt/firefox-dev
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

defaultinstall.sh
