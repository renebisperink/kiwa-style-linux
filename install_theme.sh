#!/bin/bash

#A simple installscript for the kiwa theme and the needed functionality. For now it only works on Ubuntu/Debian/Kali based systems.
#uncomment the functions you need
#@author Rene Bisperink
#@version 0.3

BLUE='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

install_theme.sh () {
	#############Runs apt update and apt upgrade#############
	#update;
 	#############Adds a kiwa user and gives it sudo rights############
	#addkiwauser;
 	#############Install a gui for WSL via Kali-win-kex############
	#installkaligui;
 	#############Configure the xfce environment (style)############
	#configurexfce;
 	#############Configure the theme############
 	#configuretheme;
 	#############Install some pentest tooling############
	#installpentest;
 	#############Install trustedsec ptf############
	#installptf;
        #############Install Firefox Developer edition############
	#installffdev;
	#############Install some mobile pentest tooling############
 	#installmobilepentest;
	#############Installing some IoT reverse engienering tools############
 	#installiotre;
	#############Installing the mobile security framework (mobsf)############
 	#installmobsf;
	#############Clone some default PT repos############
 	#cloneptrepos;
	#############Add some useful aliasses############
 	#addaliases;
	#############Build some tooling based on AttifyOS############
 	#buildattify;
	
		
}
update () {
	printf "${RED}[*] Running apt update && apt upgrade${NC}\n"
	sudo apt update
	sudo apt upgrade -y
}

addkiwauser () {
	printf "${RED}[*] Adding the kiwa user${NC}\n"
	adduser kiwa
	echo "kiwa" | passwd --stdin kiwa
	sudo usermod -aG sudo kiwa 
	
}

addaliases () {
	echo "alias update='sudo apt update && sudo apt upgrade -y && cd /opt/ptf && sudo ./ptf --update-all -y'" >> ~/.zshrc
	echo "alias lal='ls -al'" >> ~/.zshrc
	echo "alias serviceunits='systemctl list-units --type=service'" >> ~/.zshrc
	echo "alias status='systemctl status'" >> ~/.zshrc
	echo "alias restart='systemctl restart'" >> ~/.zshrc
	source ~/.zshrc
}

installkaligui () {
	update;
	printf "${RED}[*] Installing the kali-win-kex package to have a GUI on WSL${NC}\n"
	if grep -q Microsoft /proc/version; then
  		printf "${RED}[*] Linux on Windows (WSL). Installing kali-win-kex"
		sudo apt install kali-win-kex
	fi
}

configurexfce () {
	configuretheme;
	
	printf "${RED}[*] Making a directory and copying the background file to it${NC}\n"
	sudo mkdir -p /usr/share/backgrounds/kiwa/
	sudo cp kiwa-kali.png /usr/share/backgrounds/kiwa/

	printf "${RED}[*] Setting the background${NC}\n"
	for b in $(xfconf-query --channel xfce4-desktop --list | grep last-image)
	do
		echo "Setting the background from /usr/share/backgrounds/kiwa/kiwa-kali.png"
		xfconf-query --channel xfce4-desktop --property $b --set /usr/share/backgrounds/kiwa/kiwa-kali.png
	done
	
	printf "${RED}[*] Setting the image style to stretched${NC}\n"
	for s in $(xfconf-query --channel xfce4-desktop --list | grep image-style)
	do
		echo "Setting the style to stretched on $s"
		xfconf-query --channel xfce4-desktop --property $s --set 3
	done
	
	printf "${RED}[*] Setting the color style${NC}\n"
	for c in $(xfconf-query --channel xfce4-desktop --list | grep color-style)
	do
		echo "Setting the color style to centered on $c"
		xfconf-query --channel xfce4-desktop --property $c --set 0
	done

	
	printf "${RED}[*] Setting the wallpaper background color${NC}\n"
	for r in $(xfconf-query --channel xfce4-desktop --list | grep rgba1 )
	do
		echo "Setting the color background to white on $r"
		xfconf-query -c xfce4-desktop -p $r -t double -t double -t double -t double -s 1 -s 1 -s 1 -s 1
	done

	printf "${RED}[*] Setting the GTK greeter settings (login screen) ${NC}\n"
	sudo cp lightdm-gtk-greeter.conf /etc/lightdm/
	
}


installpentest () {
	update;
	printf "${RED}[*] Installing pentest packages${NC}\n"
	sudo apt install -y exiftool wine64 gdb wireshark wine seclists gobuster ftp php-curl python3-smb mingw-w64 apt-transport-https git gdb gcc python3 cmake make curl p7zip-full p7zip-rar ghidra;
	if grep -q Microsoft /proc/version; then
  	printf "${RED}[*] Linux on Windows (WSL). Not installing kali-linux-large or the PTF because it triggers the Anti Virus when installing from WSL"
	else
  		if [ -n "$(uname -a | grep Kali)"]; then
			printf "${RED}[*] Installing the kali-linux-large package${NC}\n"
			sudo apt install kali-linux-large -y
		fi
	fi
}

installptf () {
	cd /opt/
	printf "${RED}[*] Installing the Penetration Testers Framework (ptf) by Dave Kennedy (TrustedSec)${NC}\n"
	if [ "$EUID" -ne 0 ] 
	then
  		sudo chown -R $USER:$USER /opt  		
	fi

	git clone https://github.com/trustedsec/ptf.git
	cd /opt/ptf
	chmod +x ptf
	sudo ./ptf --update-allc
}


configuretheme () {
	printf "${RED}[*] configuring the theme.${NC}\n"
	printf "${RED}[*] setting the icons to the Windows 10 icons from Kali${NC}\n"
	xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons
	printf "${RED}[*] setting the theme to Window 10 from Kali${NC}\n"
	xfconf-query -c xsettings -p /Net/ThemeName -s Windows-10-Dark
	printf "${RED}[*] setting the window manager to Window 10 from Kali${NC}\n"
	xfconf-query -c xfwm4 -p /general/theme -s Windows-10-Dark
	printf "${RED}[*] setting the taskbar color to black${NC}\n"
	xfconf-query --channel xfce4-panel -p /panels/panel-1/background-rgba --create \
        -t double -t double -t double -t double \
        -s 0     -s 0     -s 0     -s 1.0
	printf "${RED}[*] setting the panel / taskbar to the bottom of the screen${NC}\n"
	xfconf-query --channel xfce4-panel -p /panels/panel-1/position -s 'p=8;x=960;y=1064'
	printf "${RED}[*] locking the panel on the bottom${NC}\n"
	xfconf-query --channel xfce4-panel -p /panels/panel-1/position-locked -s true
	printf "${RED}[*] setting panel size to 36${NC}\n"
	xfconf-query --channel xfce4-panel -p /panels/panel-1/size -s 36
	printf "${RED}[*] setting icon size to 42${NC}\n"
	xfconf-query --channel xfce4-desktop -p /desktop-icons/icon-size -s 42
	
	cp lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
	
}

installmobilepentest () {
	update;
	sudo apt install -y android-sdk android-sdk-platform-tools androguard dex2jar drozer
}

installmobsf (){
	apt install docker.io
	docker pull opensecurity/mobile-security-framework-mobsf
	docker run -it -p 8000:8000 opensecurity-mobile-security-framework-mobsf:latest
	echo "now open the browser on localhost:8000"
}

installiotre () {
	sudo apt install binwalk openocd flashrom firmware-mod-kit killerbee hackrf ubertooth ubertooth-firmware gqrx gqrx-sdr multimon-ng dex2jar radare2 hackrf libhackrf-dev libhackrf0
} 

cloneptrepos () {
	update;

	if [ -n "$(uname -a | grep Kali)"]; then
		sudo apt install -y seclists
	else
		sudo mkdir -p /usr/share/wordlists/
		cd /usr/share/wordlists/
		git clone https://github.com/danielmiessler/SecLists 
	fi
	cd /opt

	git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite
	git clone https://github.com/S3cur3Th1sSh1t/WinPwn/
	git clone https://github.com/pentestmonkey/windows-privesc-check
	git clone https://github.com/bitsadmin/wesng
	git clone https://github.com/Anon-Exploiter/SUID3NUM
	git clone https://github.com/DominicBreuker/pspy
	git clone https://github.com/SecureAuthCorp/impacket
	git clone https://github.com/M4ximuss/Powerless
	git clone https://github.com/S3cur3Th1sSh1t/PowerSharpPack
	git clone https://github.com/cobbr/SharpSploit
	git clone https://github.com/boh/RedCsharp
	git clone https://github.com/rebootuser/LinEnum
	git clone https://github.com/411Hall/JAWS
	git clone https://github.com/threat9/routersploit
	git clone https://github.com/Ullaakut/cameradar
	
}

installazurecli () {
	update;
	sudo apt install ca-certificates curl apt-transport-https lsb-release gnupg
	printf "${RED}[*] Adding the gpg signing key${NC}\n"
	curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
	printf "${RED}[*] Adding the Azure CLI software repository${NC}\n"
	AZ_REPO=$(lsb_release -cs)
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
	sudo apt-get update
	sudo apt-get install azure-cli
	
}

installautorecon () {
	update;
	sudo apt install seclists curl enum4linux feroxbuster nbtscan nikto nmap onesixtyone oscanner smbclient smbmap smtp-user-enum snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf python3 python3-pip python3-venv
	python3 -m pip install --user pipx
	python3 -m pipx ensurepath
	source ~/.zshrc
	
	echo 'alias sudo="sudo env \"PATH=$PATH\""' >> ~/.profile
	pipx install git+https://github.com/Tib3rius/AutoRecon.git

}


installffdev () {
	printf "${RED}[*] Installing Firefox Developer${NC}\n"

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
	if [ "$EUID" -ne 0 ] 
	then
  		sudo chown $USER:$USER /opt/firefox-dev		
	fi
    	

    	# Remove the unzipped install folder.
    	rm -rf firefox

   	# Remove the install file.
    	rm $FILE
    
    	echo -e ${FIREFOX_DESKTOP} > ~/Desktop/firefox-dev.desktop
    	sudo cp ~/Desktop/firefox-dev.desktop /usr/share/applications/firefox-dev.desktop
    	
    	echo "Firefox Dev Ed $VERSION installed."
   
}

buildattify () {
	echo "[*] creating directories and installing apt repositories"
	mkdir /opt/attify
	cd /opt/attify
	sudo apt install arduino python3-pip dump1090-mutability python3-scapy routersploit libliquid2d ghidra kismet-capture-rz-killerbee binwalk python3-scapy proxmark3 cutesdr bettercap mosquitto firmware-mod-kit gnuradio gqrx-sdr hackrf gr-osmosdr inspectrum jadx kalibrate-rtl nmap radare2 radare2-cutter radare2-cutter rfcat rtl-sdr rtl-433 rtlsdr-scanner ubertooth
	cd /opt/attify
	echo "[*] baudrate"
	# baudrate conversion dependency
	pip3 uninstall serial
	pip3 install pyserial
	# still needs USB check
	
	echo "[*] btaddr"
	#needs hci0 check

	echo "[*] create_ap"
	#needs wifi check
	
	echo "[*] cutter"
	#Appimage so it will run

	echo "[*] drivers"
	#needs the usb connection
	cd drivers
	make
	make install
	cd ..
	
	echo "[*] Dspectrum Gui"
	cd dspectrumgui
	sudo apt install ruby
	bundle install
	cd ..
	
	echo "[*] Firmadyne"
	git clone https://github.com/firmadyne/firmadyne
	cd firmadyne
	chmod +x setup.sh
	./setup.sh
	cd ..
	
	echo "[*] Firmware Mod Kit"
	# installed via apt

	
	echo "[*] GR GSM"
	sudo apt-get update && \
     	sudo apt-get install -y \                                                       
        cmake \
        autoconf \
        libtool \
        pkg-config \
        build-essential \
        python3-docutils \
        libcppunit-dev \
        swig \
        doxygen \
        liblog4cpp5-dev \
        python3-scipy \
        gnuradio-dev \        
        gr-osmosdr \
        libosmocore-dev
	
	cd gr-gsm
	mkdir build
	cd build
	cmake ..
	mkdir $HOME/.grc_gnuradio/ $HOME/.gnuradio/
	make
	sudo make install
	ldconfig

	echo "[*] GR Paint"
	cd gr-paint
	mkdir build
   	cd build
    	cmake -DCMAKE_INSTALL_PREFIX=/usr ../
    	make
    	sudo make install
    	sudo ldconfig
	cd ../../
	
	echo "[*] HackRF tools"
	#TBD

	echo "[*] Inspectrum"
	echo "inspectrum needs liquid-dsp"
	git clone https://github.com/jgaeddert/liquid-dsp
	sudo apt-get install qt5-default libfftw3-dev cmake pkg-config libliquid-dev
	cd liquid-dsp
	./bootstrap.sh
	./configure
	make check
	make
	sudo make install
	cd ..
	
	cd inspectrum
	mkdir build
	cd build
	cmake ..
	make
	sudo make install
	cd ../../
	
	echo "[*] JADX"
	#al gevalideer via apt

	echo "[*] Kalibrate-RTL"
	sudo apt-get install libtool libfftw3-dev
	cd kalibrate-rtl
	./bootstrap && CXXFLAGS='-W -Wall -O3' ./configure && make
	cd ..
	
	echo "[*] killerbee"
	sudo apt-get install python3-cairo python3-usb python3-dev libgcrypt-dev
	pip3 install scapy
	python3 setup.py install
	
	echo "[*] libmpsse"	
	# file incomplete, has to be fixed
	

	echo "[*] LTE Cell Scanner"
	cd LTE-Cell-Scanner
	mkdir build
  	cd build
  	cmake ..
  	make
	sudo make install
	cd ..
	
	
	echo "[*] OOK Decoder"
	#TBD	

	echo "[*] qiling"
	pip3 install qiling

	echo "[*] RTL sdr tools"
	cd rtl-sdr/
	
	mkdir build
	cd build
	cmake ../ -DINSTALL_UDEV_RULES=ON
	make
	sudo make install
	sudo ldconfig
	sudo make install-udev-rules
	cd ../../
	
	echo "[*] Spectrum Painter"
	#ingebouwd in python3

	echo "[*] URH"
	sudo python3 -m pip install urh 

}

install_theme.sh
