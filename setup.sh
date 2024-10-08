#!/bin/bash

# components installation options
wm=icewm # set no if just want to install fluxbox
firefox_deb=yes # install firefox using the deb package
theming=yes # set yes to install custom theming
audio=yes # set no if do not want to use pipewire audio server
thunar=yes # set no if do not want to install thunar file manager
login_mgr=yes # set no if do not want to install SDDM or lxdm login manager
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=no # set no if do not want to configure nano text editor
laptop_mode=no # set yes if install on a laptop
amdgpu_config=yes # set yes to enable amdgpu tearfree
qemu=yes # set yes to install qemu and virt-manager
gaming=yes # set yes to install wine and lutris
sensors=yes # set yes to customize lm-sensors
#redshift_config=no # set yes to copy customized redshift config
bashrc=yes # set yes to customized my bashrc
smartd=yes # set yes to install and configure smartd
swapfile=no # set yes to enable swapfile
ytdlp=yes # set yes to install yt-dlp

function run_dunstrc() {
	# install dunst
	sudo apt-get update && sudo apt-get upgrade -y
 	sudo apt-get install dunst -y
	# customize dunst config
  	mkdir -p $HOME/.config/dunst
  	if [[ -f $HOME/.config/dunst/dunstrc ]]; then 
		cp $HOME/.bashrc $HOME/.bashrc_`date +%Y_%d_%m_%H_%M_%S`
	fi
    	cp -r /etc/xdg/dunst $HOME/.config/
    	sed -i 's/Adwaita/"Adwaita, Papirus"/g' $HOME/.config/dunst/dunstrc
    	sed -i 's/32/22/g' $HOME/.config/dunst/dunstrc
}

function instal_apps() {
	# install standard apps
	sudo apt-get update && sudo apt-get upgrade -y
 	sudo apt-get install papirus-icon-theme adwaita-icon-theme xdg-utils xdg-user-dirs policykit-1 policykit-1-gnome \
  		software-properties-gtk rsyslog logrotate nano less curl wget iputils-ping fonts-noto-color-emoji fonts-noto-cjk \
   		fonts-font-awesome gpicview gv geany unzip rar -y
}

install () {
	case $wm in
	fluxbox)
		# install fluxbox and other packages
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install fluxbox xorg xinit x11-utils lxterminal lxappearance xscreensaver rofi dex flameshot feh -y
		echo "startfluxbox" > $HOME/.xinitrc
		run_dunstrc
  		instal_apps
		
		if [[ -d $HOME/.fluxbox ]]; then mv $HOME/.fluxbox $HOME/.fluxbox_`date +%Y_%d_%m_%H_%M_%S`; fi
		mkdir -p $HOME/.fluxbox
		cp -r ./fluxbox/* $HOME/.fluxbox/
		#sed -i 's/administrator/$USER/g' $HOME/.fluxbox/init
		#sed -i 's/administrator/$USER/g' $HOME/.fluxbox/startup
		
		# install extra fluxbox styles
		mkdir -p $HOME/.fluxbox/styles
		tar -zxvf ./styles/Retour.tgz -C $HOME/.fluxbox/styles/
		;;
	icewm)
		# install icewm and other packages
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install icewm xorg xinit x11-utils lxterminal lxappearance xscreensaver rofi dex flameshot feh -y
		echo "icewm-session" > $HOME/.xinitrc
		run_dunstrc
  		instal_apps
		
		# install icewm custom config
		if [[ -d $HOME/.icewm ]]; then mv $HOME/.icewm $HOME/.icewm_`date +%Y_%d_%m_%H_%M_%S`; fi
		mkdir -p $HOME/.icewm
		cp -r ./icewm/* $HOME/.icewm/
		chmod +x $HOME/.icewm/startup
		
		# install icewm custom themes
		mkdir -p $HOME/.icewm/themes

		git clone https://github.com/Brottweiler/win95-dark.git /tmp/win95-dark
		cp -r /tmp/win95-dark $HOME/.icewm/themes 
		rm $HOME/.icewm/themes/win95-dark/.gitignore
		sudo rm -r $HOME/.icewm/themes/win95-dark/.git
  
		git clone https://github.com/Vimux/icewm-theme-icepick.git /tmp/icewm-theme-icepick
		cp -r /tmp/icewm-theme-icepick/IcePick $HOME/.icewm/themes
  
		git clone https://github.com/Brottweiler/Arc-Dark.git /tmp/Arc-Dark
		cp -r /tmp/Arc-Dark $HOME/.icewm/themes
		sudo rm -r $HOME/.icewm/themes/Arc-Dark/.git

		tar -xvf ./styles/DraculIce.tar.gz -C $HOME/.icewm/themes
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			cp $HOME./icewm/themes/DraculIce/taskbar/start_ubuntu.svg $HOME./icewm/themes/DraculIce/taskbar/start.xpm
		else
			cp ./styles/debian.xpm $HOME./icewm/themes/DraculIce/taskbar/start.xpm
		fi
		;;
	i3wm)
		# install i3wm and other packages
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install i3 suckless-tools xorg xinit x11-utils lxterminal feh lxappearance dex rofi flameshot -y
		run_dunstrc
  		instal_apps
		
		# custom i3wm config
		if [[ -d $HOME/.config/i3 ]]; then mv $HOME/.config/i3 $HOME/.config/i3_`date +%Y_%d_%m_%H_%M_%S`; fi
		mkdir -p $HOME/.config/i3
		cp -r ./i3wm/* $HOME/.config/i3/
		;;
	xfwm4)
		# install xfwm4 and other packages
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install xorg xinit xfce4-terminal xfwm4 xfce4-panel sxhkd feh xscreensaver lxappearance dex flameshot -y
		echo "exec xfwm4" > $HOME/.xinitrc
        	cp ./xfwm4/xsessionrc $HOME/.xsessionrc
	 	run_dunstrc
   		instal_apps
        
        	# insall dracula xfce4-terminal theme
    		mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
      		git clone https://github.com/dracula/xfce4-terminal.git /tmp/xfce4-terminal
		cp /tmp/xfce4-terminal/Dracula.theme $HOME/.local/share/xfce4/terminal/colorschemes
		
		# copy xfce4-panel config
		mkdir -p $HOME/.config/xfce4/panel/launcher-{8,10,14,15}
		mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml
		cp ./config/xfce4-panel.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
		cp ./config/17140153922.desktop $HOME/.config/xfce4/panel/launcher-8/
		cp ./config/17140154333.desktop $HOME/.config/xfce4/panel/launcher-10/
		cp ./config/17140154514.desktop $HOME/.config/xfce4/panel/launcher-14/
		cp ./config/17140154635.desktop $HOME/.config/xfce4/panel/launcher-15/
		
		#configure sxhkd config
		mkdir -p $HOME/.config/sxhkd
   		cp ./config/sxhkdrc $HOME/.config/sxhkd/sxhkdrc

		# remove round corner in xfce4-panel
		mkdir -p $HOME/.config/gtk-3.0
		cp ./xfwm4/gtk.css $HOME/.config/gtk-3.0/gtk.css
		;;
	swaywm)
		# install swaywm and packages
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install sway swaybg swayidle swaylock xdg-desktop-portal-wlr xwayland foot suckless-tools \
			mako-notifier libnotify-bin grim imagemagick grimshot qt5ct lxappearance qtwayland5 -y
   		instal_apps
			
		# copy my swaywm and mako configuration
		if [[ -d $HOME/.config/sway ]]; then mv $HOME/.config/sway $HOME/.config/sway_`date +%Y_%d_%m_%H_%M_%S`; fi
		if [[ -d $HOME/.config/mako ]]; then mv $HOME/.config/mako $HOME/.config/mako`date +%Y_%d_%m_%H_%M_%S`; fi
		mkdir -p $HOME/.config/{sway,mako}
		cp -r ./swaywm/* $HOME/.config/sway/
		cp ./mako/config $HOME/.config/mako/
		
		# enable autostart swaywm after TUI login
		sudo cp ./config/start_swaywm.sh /usr/local/bin/start_swaywm.sh
		sudo chmod +x /usr/local/bin/start_swaywm.sh
		#sudo mkdir -p /etc/profile.d
		#sudo cp ./config/sway_env.sh /etc/profile.d/sway_env.sh

		if [[ -f $HOME/.bashrc ]]; then cp $HOME/.bashrc $HOME/.bashrc_`date +%Y_%d_%m_%H_%M_%S`; fi
		echo -e '\n#If running from tty1 start sway\n[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/start_swaywm.sh' >> $HOME/.bashrc
		;;
	lubuntu)
		# install minimal setup on Lubuntu
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install vlc geany transmission-qt rar -y
		
		# copy my LXQt and autostart configuration
		mkdir -p $HOME/.config/{lxqt,autostart}
		cp ./lubuntu/*.conf $HOME/.config/lxqt/
		#cp ./autostart/*.desktop $HOME/.config/autostart/
		
		# create PCManFM-Qt custom actions files
		mkdir -p $HOME/.local/share/file-manager/actions
		cp ./actions/*.desktop $HOME/.local/share/file-manager/actions/
		echo "Remember to change PCManFM-Qt's Archiver intergration to lxqt-archiver under Preferences > Advanced."
		# actions to open terminal in desktop. Not needed for LXQt v1.3 and above
		rm $HOME/.local/share/file-manager/actions/open_in_terminal.desktop
		
		# install openbox themes
      		mkdir -p $HOME/.local/share/themes
		#git clone https://github.com/dracula/openbox /tmp/openbox
  		git clone https://github.com/terroo/openbox-themes /tmp/openbox-themes
  		cp -r /tmp/openbox-themes/* $HOME/.local/share/themes/
		;;
	*)
		echo "Usage: $0 {up|down}"
		exit 1
		;;
	esac
	
	# install yt-dlp
	if [[ $ytdlp == "yes" ]]; then
    		mkdir -p $HOME/.local/bin
    		wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O $HOME/.local/bin/yt-dlp
		chmod a+rx $HOME/.local/bin/yt-dlp
	fi
	
	# xorg amdgpu enable tear free & vrr
	if [[ $amdgpu == "yes" ]]; then
		sudo cp ./config/20-amdgpu-custom.conf /etc/X11/xorg.conf.d/
	fi
	
	# install qemu and virt-manager
 	if [[ $qemu == "yes" ]]; then
  		sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager -y
    	fi
	
	# install wine and lutris
 	if [[ $gaming == "yes" ]]; then
  		sudo apt-get install wine64 -y
    		sudo apt-get update
      		sudo apt-get install python3-lxml python3-setproctitle python3-magic gir1.2-webkit2-4.1 cabextract \
			fluid-soundfont-gs vulkan-tools python3-protobuf python3-evdev fluidsynth gamemode -y
		wget -P /tmp https://github.com/lutris/lutris/releases/download/v0.5.17/lutris_0.5.17_all.deb
   		sudo dpkg -i /tmp/lutris*.deb

		# install MangoHud
  		wget -P /tmp https://github.com/flightlessmango/MangoHud/releases/download/v0.7.1/MangoHud-0.7.1.tar.gz
    		tar -zxvf /tmp/MangoHud*.tar.gz -C /tmp
	 	(cd /tmp/MangoHud && ./mangohud-setup.sh install)
   
   		# download winetrick https://wiki.winehq.org/Winetricks
     		#mkdir -p $HOME/.local/bin
	 	#wget -P /tmp https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
   		#cp /tmp/winetricks $HOME/.local/bin/
     		#chmod +x $HOME/.local/bin/winetricks
	fi
    
    	# install and configure smartd to monitor disks
	if [[ $smartd == "yes" ]]; then
		# edit /etc/smartd.conf with DEVICESCAN -a -o on -S on -n standby,q -W 4,50,55 -m @smartdnotify -M daily
		sudo apt-get install smartmontools -y
		sudo cp ./bin/smartdnotify /etc/smartmontools/smartd_warning.d/
		sudo chmod +x /etc/smartmontools/smartd_warning.d/smartdnotify

		# schedule run smart disk test
		sudo cp ./config/run_smartd_test /etc/cron.d/
		sudo cp ./bin/run_smartd_test /usr/local/bin/
		sudo chmod +x /usr/local/bin/run_smartd_test
	fi
	
	if [[ $sensors == "yes" ]]; then
 		sudo apt-get install lm-sensors -y
		# setup disk drive temp module
		echo drivetemp | sudo tee /etc/modules-load.d/drivetemp.conf
	  
		# setup sensors for ASUS X370 Crosshair
		echo -e 'chip "asus_wmi_sensors-virtual-0"\n' | sudo tee /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore fan4 # chassis fan 3" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore fan5 # CPU optional fan" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore fan6 # water pump" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore fan7 # CPU opt fan" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore fan8 # water flow" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore temp5 # Tsensor 1 temp" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore temp7 # water in temp" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
		echo "ignore temp8 # water out temp" | sudo tee -a /etc/sensors.d/asus_wmi_sensors.conf
	fi
	
	# install universal theming
	if [[ $theming == "yes" ]]; then
		# custom gtk2 and gtk3 themes
		mkdir -p $HOME/.config/gtk-3.0
		cp ./config/gtk2 $HOME/.gtkrc-2.0
		#sed -i "s/administrator/"$USER"/g" $HOME/.gtkrc-2.0
		cp ./config/gtk3 $HOME/.config/gtk-3.0/settings.ini

		# copy wallpapers
  		mkdir -p $HOME/Pictures/wallpapers
   		cp ./wallpapers/* $HOME/Pictures/wallpapers/
   		
   		# install buff icon theme
   		mkdir -p $HOME/.icons
		wget -P /tmp http://buuficontheme.free.fr/buuf3.46.tar.xz
		tar -xvf /tmp/buuf*.tar.xz -C $HOME/.icons
		
		# buuf icon from robson-66
		git clone https://github.com/robson-66/Buuf.git /tmp/Buuf
		mkdir -p $HOME/.icons
		cp -r /tmp/Buuf $HOME/.icons && rm -rf $HOME/.icons/Buuf/.git
		
		# setup buuf-icons-for-plasma icon theme
		git clone https://www.opencode.net/phob1an/buuf-icons-for-plasma.git /tmp/buuf-icons-for-plasma
		mkdir -p $HOME/.icons/buuf-icons-for-plasma
		cp -r /tmp/buuf-icons-for-plasma/{16x16,22x22,32x32,48x48,64x64,128x128,index.theme,licenses} $HOME/.icons/buuf-icons-for-plasma
	  
		# install Gruvbox-Plus-Dark icon theme
		git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git /tmp/gruvbox-plus-icon-pack
		mkdir -p $HOME/.icons
		cp -r /tmp/gruvbox-plus-icon-pack/Gruvbox-Plus-Dark $HOME/.icons
		
		# install Nordic gtk theme
		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
		tar -xvf /tmp/Nordic.tar.xz -C $HOME/.themes

		# add additional geany colorscheme
		mkdir -p $HOME/.config/geany/colorschemes
		git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
		cp -r /tmp/geany-themes/colorschemes/* $HOME/.config/geany/colorschemes/

		# install lxterminal dracula theme
		git clone https://github.com/dracula/lxterminal.git /tmp/lxterminal
		mkdir -p $HOME/.config/lxterminal/
		cp /tmp/lxterminal/lxterminal.conf $HOME/.config/lxterminal/

		# install dracula themes
  		mkdir -p $HOME/.icons
    		wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula-cursors.tar.xz
      		tar -xvf /tmp/Dracula-cursors.tar.xz -C $HOME/.icons

		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula.tar.xz
  		tar -xvf /tmp/Dracula.tar.xz -C $HOME/.themes
  		
  		# install Nordic GTK theme
      		mkdir -p $HOME/.local/share/themes
		wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
  		tar -xf /tmp/Nordic.tar.xz -C $HOME/.local/share/themes
  		wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz
    		tar -xf /tmp/Nordic-darker.tar.xz -C $HOME/.local/share/themes
	fi
	
	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi
	
	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			if [[ $wm == "i3wm" || $wm == "swaywm" ]]; then
				sudo apt-get install pipewire pipewire-pulse wireplumber -y
			else
				sudo apt-get install pipewire pipewire-pulse wireplumber pavucontrol-qt pnmixer -y
				mkdir -p $HOME/.config/pnmixer
				cp ./config/pnmixer $HOME/.config/pnmixer/config
			fi
		fi
	fi
	
	# optional to install thunar file manager
	if [[ $thunar == "yes" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			sudo apt-get install thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon -y
			mkdir -p $HOME/.config/xfce4
			if [[ $wm != "xfwm4" && $wm != "swaywm" ]]; then
				echo "TerminalEmulator=lxterminal" > $HOME/.config/xfce4/helpers.rc
			fi
		fi
	fi
	
	# optional to install SDDM or lxdm login manager
	if [[ $login_mgr == "yes" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
				sudo apt-get install sddm -y
			else
				sudo apt-get install lxdm -y
			fi
		fi
	fi
	
	# install firefox without snap
	# https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
	if [[ $firefox_deb == "yes" ]]; then
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			sudo install -d -m 0755 /etc/apt/keyrings
			wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
				sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
			echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
				sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
			echo -e "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | \
				sudo tee /etc/apt/preferences.d/mozilla
			sudo apt-get update && sudo apt-get install firefox -y
		else
			sudo apt-get install firefox-esr -y
			if [[ $wm == "fluxbox" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.fluxbox/keys
			fi
			if [[ $wm == "icewm" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.icewm/{menu,toolbar}
			fi
			if [[ $wm == "xfwm4" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.config/xfce4/panel/launcher-10/17140154333.desktop
			fi
		fi
  	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
		if [[ $wm != "lubuntu" ]]; then
			sudo apt-get install network-manager network-manager-gnome -y
			if [[ -n "$(uname -a | grep Ubuntu)" ]] then
				for file in `find /etc/netplan/* -maxdepth 0 -type f -name *.yaml`; do
					sudo mv $file $file.bak
				done
				echo -e "# Let NetworkManager manage all devices on this system\nnetwork:\n  version: 2\n  renderer: NetworkManager" | \
				sudo tee /etc/netplan/01-network-manager-all.yaml
			else
				sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
				sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
				sudo mv /etc/network/interfaces /etc/network/interfaces.bak
				head -9 /etc/network/interfaces.bak | sudo tee /etc/network/interfaces
				sudo systemctl disable networking.service
			fi
		fi
	fi
	
	# disable unwanted services
 	if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			sudo systemctl disable systemd-networkd-wait-online.service
			sudo systemctl disable multipathd.service
  		fi
	fi
	
	# install and setup for laptop usage
	if [[ $laptop_mode == "yes" ]]; then
		sudo apt-get install brightnessctl cbatticon -y
		sudo mkdir -p /etc/udev/rules.d
		sudo mkdir -p /usr/local/bin
		sudo cp ./rules.d/*.rules /etc/udev/rules.d/
		sudo cp ./rules.d/*.sh /usr/local/bin/
		sudo chmod +x /usr/local/bin/*.sh
	fi
	
	# setup my customer bash alias
	if [[ $bashrc == "yes" ]]; then
		echo -e "\nalias temps='watch -n 1 sensors amdgpu-pci-* drivetemp-* k10temp-* asus_wmi_sensors-*'" | tee -a $HOME/.bashrc
		echo "alias syslog='tail -f /var/log/syslog'" | tee -a $HOME/.bashrc
	fi

  	# enable swapfile
   	if [[ $swapfile == "yes" ]]; then
   		sudo fallocate -l 4G /swapfile
    	sudo chmod 600 /swapfile
      	sudo mkswap /swapfile
		sudo swapon /swapfile
  		echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
    fi	
	
	# copy all executable files
	mkdir -p $HOME/.local/bin
	cp ./bin/* $HOME/.local/bin
	chmod +x $HOME/.local/bin/*
}

printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "88888888888888888888888888888\n"
printf "My WM Install           : $wm\n"
printf "Firefox as DEB packages : $firefox_deb\n"
printf "Pipewire Audio          : $audio\n"
printf "Thunar File Manager     : $thunar\n"
printf "Custom theming          : $theming\n"
printf "Login Manager           : $login_mgr\n"
printf "NetworkManager          : $nm\n"
printf "Nano's configuration    : $nano_config\n"
printf "Laptop Mode             : $laptop_mode\n"
printf "AMDGPU Config           : $amdgpu_config\n"
printf "QEMU KVM                : $qemu\n"
printf "Gaming                  : $gaming\n"
printf "lm-sensor setup         : $sensors\n"
printf "Custom bashrc           : $bashrc\n"
printf "Configure Smartd        : $smartd\n"
printf "Configure swapfile      : $swapfile\n"
printf "Install yt-dlp          : $ytdlp\n"
printf "88888888888888888888888888888\n"

while true; do
read -p "Do you want to proceed with above settings? (y/n) " yn
	case $yn in
		[yY] ) echo ok, we will proceed; install; echo "Remember to reboot system after the installation!";
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo invalid response;;
	esac
done
