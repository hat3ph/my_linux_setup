#!/bin/bash
 
# ASCII Art Header
# https://www.patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
cat << "EOF"
##########################################################################################
  __  ____     __  _      _____ _   _ _    ___   __   _____ ______ _______ _    _ _____   
 |  \/  \ \   / / | |    |_   _| \ | | |  | \ \ / /  / ____|  ____|__   __| |  | |  __ \  
 | \  / |\ \_/ /  | |      | | |  \| | |  | |\ V /  | (___ | |__     | |  | |  | | |__) | 
 | |\/| | \   /   | |      | | | . ` | |  | | > <    \___ \|  __|    | |  | |  | |  ___/  
 | |  | |  | |    | |____ _| |_| |\  | |__| |/ . \   ____) | |____   | |  | |__| | |      
 |_|  |_|  |_|    |______|_____|_| \_|\____//_/ \_\ |_____/|______|  |_|   \____/|_|      
 
##########################################################################################
EOF
 
echo "Welcome to My Linux Interactive Setup Script!"
echo "Please follow the prompts below to configure your environment."
echo ""
 
#wm_options=(icewm fluxbox i3wm xfwm4 sway lubuntu)

# Function to install packages
function install_packages() {
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install -y "$@"
}

# Function to backup and create a directory or file
function backup_and_create() {
	local path="$1"
    
	# Check if the path is a directory
    if [ -d "$path" ]; then
       	mv "$path" "${path}_backup_$(date +%Y_%m_%d_%H_%M_%S)"
		mkdir -p "$path"
    # Check if the path is a file
    elif [ -f "$path" ]; then
       	mv "$path" "${path}_backup_$(date +%Y_%m_%d_%H_%M_%S)"
    else
       	echo "Error: '$path' is neither a file nor a directory."
       	return 1
    fi
}

# Function to enable autostart WM after TUI login from profile.d
function autostart_wm() {
	echo -e "# If running from tty1 start $1\n[ "\"'$(tty)'\"" = \"/dev/tty1\" ] && exec $1" | sudo tee /etc/profile.d/autostart-$1.sh
}

# Function to check and disable running services
function disable_services() {
	for service in "${@}"; do
		#echo $service
		if (systemctl -q is-active $service); then
			echo "Stopping running $service service."
			sudo systemctl disable --now $service
		else 
			echo "$service service is not running."
		fi
	done
}

# function for selection menu
function menu (){
	read -p "Choose window manager (icewm, fluxbox, i3wm, xfwm4, sway, labwc, lubuntu) [icewm]: " wm
	wm=${wm:-icewm}
 
	read -p "Install Firefox using the deb package? (yes/no) [yes]:" firefox_deb
	firefox_deb=${firefox_deb:-yes}
 	
	read -p "Install custom theming? (yes/no) [yes]:" theming
	theming=${theming:-yes}
	
	read -p "Use PipeWire audio server? (yes/no) [yes]:" pipewire
	pipewire=${pipewire:-yes} 
 	
	read -p "Install Thunar file manager? (yes/no) [yes]:" thunar
    thunar=${thunar:-yes} 
 
    read -p "Choose login manager (sddm or lxdm or wayland or no). Choose no for no login manager. [no]:" login_mgr
    login_mgr=${login_mgr:-no}
 
   	read -p "Use NetworkManager for network interface management? (yes/no) [yes]:" nm
    nm=${nm:-yes} 
 
    read -p "Configure nano text editor? (yes/no) [no]:" nano_config
    nano_config=${nano_config:-no} 
 
    read -p "Install on a laptop? (yes/no) [no]:" laptop_mode
    laptop_mode=${laptop_mode:-no} 
 
    read -p "Enable amdgpu xorg tearfree? (yes/no) [no]:" amdgpu_config
    amdgpu_config=${amdgpu_config:-no} 
 
    read -p "Install QEMU and Virt-Manager? (yes/no) [yes]:" qemu
    qemu=${qemu:-yes} 
 
    read -p "Install Wine and Lutris for gaming? (yes/no) [yes]:" gaming
    gaming=${gaming:-yes} 
 
    read -p "Customize lm-sensors? (yes/no) [yes]:" sensors
    sensors=${sensors:-yes} 
 
    read -p "Customize your bashrc? (yes/no) [no]:" bashrc
    bashrc=${bashrc:-no} 
 
    read -p "Install and configure smartd? (yes/no) [yes]:" smartd
    smartd=${smartd:-yes} 
 
    read -p "Enable swapfile? (yes/no) [yes]:" swapfile
    swapfile=${swapfile:-yes} 
 
    read -p "Install yt-dlp? (yes/no) [yes]:" ytdlp
    ytdlp=${ytdlp:-yes}
}
 
function install(){
	case $wm in
        fluxbox)
            install_packages fluxbox xorg xinit x11-utils lxterminal lxappearance xscreensaver rofi dex flameshot feh
            echo "startfluxbox" > "$HOME/.xinitrc"
            
            backup_and_create "$HOME/.fluxbox"
			mkdir -p $HOME/.fluxbox
			cp -r ./fluxbox/* $HOME/.fluxbox/
			#sed -i 's/administrator/$USER/g' $HOME/.fluxbox/init
			#sed -i 's/administrator/$USER/g' $HOME/.fluxbox/startup

			# install extra fluxbox styles
			mkdir -p $HOME/.fluxbox/styles
			#tar -zxvf ./styles/Retour.tgz -C $HOME/.fluxbox/styles/
			
			# download fluxbox style from http://tenr.de/styles/?i=16
			wget -P /tmp http://tenr.de/styles/archives/tenr.de-styles-pkg.tar.bz2
			tar -xvf /tmp/tenr.de-styles-pkg.tar.bz2
			cp -r /tmp/tenr.de-styles-pkg/* $HOME/.fluxbox/styles/

			wget -P /tmp http://tenr.de/styles/archives/fluxmod-styles-pkg.tar.bz2
			tar -xvf /tmp/fluxmod-styles-pkg.tar.bz2
			cp -r /tmp/fluxmod-styles-pkg/* $HOME/.fluxbox/styles/

			# remove unwanted files
			rm $HOME/.fluxbox/styles/*.{sh,txt}
		;;
        icewm)
            install_packages icewm xorg xinit x11-utils lxterminal lxappearance xscreensaver rofi dex flameshot feh
			echo "icewm-session" > "$HOME/.xinitrc"
            	
			# install icewm custom config
            backup_and_create "$HOME/.icewm"
	      	mkdir -p $HOME/.icewm/
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
			install_packages i3 suckless-tools xorg xinit x11-utils lxterminal feh lxappearance dex rofi flameshot
			
			# custom i3wm config
			backup_and_create "$HOME/.config/i3"
			mkdir -p $HOME/.config/i3
			cp -r ./i3wm/* $HOME/.config/i3/
		;;
		xfwm4)
			# install xfwm4 and other packages
			install_packages xorg xinit xfce4-terminal xfwm4 xfce4-panel sxhkd feh xscreensaver lxappearance dex flameshot rofi
			echo "exec xfwm4" > $HOME/.xinitrc
        	cp ./xfwm4/xsessionrc $HOME/.xsessionrc
        
        	# insall dracula xfce4-terminal theme
    		mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
      		git clone https://github.com/dracula/xfce4-terminal.git /tmp/xfce4-terminal
			cp /tmp/xfce4-terminal/Dracula.theme $HOME/.local/share/xfce4/terminal/colorschemes

			# install catppuccin xfce4-terminal theme
			mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
   			git clone https://github.com/catppuccin/xfce4-terminal /tmp/xfce4-terminal-catppuccin
      		cp /tmp/xfce4-terminal-catppuccin/themes/*.theme $HOME/.local/share/xfce4/terminal/colorschemes
			
			# copy xfce4-panel config
			mkdir -p $HOME/.config/xfce4/panel/launcher-{8,10,14,15}
			mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml
			cp ./xfwm4/xfce4-panel.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
			cp ./xfwm4/17140153922.desktop $HOME/.config/xfce4/panel/launcher-8/
			cp ./xfwm4/17140154333.desktop $HOME/.config/xfce4/panel/launcher-10/
			cp ./xfwm4/17140154514.desktop $HOME/.config/xfce4/panel/launcher-14/
			cp ./xfwm4/17140154635.desktop $HOME/.config/xfce4/panel/launcher-15/
			
			#configure sxhkd config
			mkdir -p $HOME/.config/sxhkd
			cp ./config/sxhkdrc $HOME/.config/sxhkd/sxhkdrc

			# remove round corner in xfce4-panel
			mkdir -p $HOME/.config/gtk-3.0
			cp ./xfwm4/gtk.css $HOME/.config/gtk-3.0/gtk.css

			# xsession file for login manager
   			sudo mkdir -p /usr/share/xsessions
	 		sudo cp ./xfwm4/xfwm4.desktop /usr/share/xsessions
		;;
		sway)
			# install sway and packages
			install_packages install sway swaybg swayidle swaylock xdg-desktop-portal-wlr xwayland foot suckless-tools grim imagemagick grimshot qt5ct lxappearance qtwayland5

			# copy my sway and mako configuration
			backup_and_create "$HOME/.config/sway"
			#backup_and_create "$HOME/.config/mako"
			mkdir -p $HOME/.config/sway
			cp -r ./swaywm/* $HOME/.config/sway/
			#cp ./mako/config $HOME/.config/mako/
			
			# enable autostart sway after TUI login
			#autostart_wm sway
			#sudo cp ./config/start_sway.sh /usr/local/bin/start_sway.sh
			#sudo chmod +x /usr/local/bin/start_sway.sh
			#sudo mkdir -p /etc/profile.d
			#sudo cp ./config/sway_env.sh /etc/profile.d/sway_env.sh

			#backup_and_create "$HOME/.bashrc"
			#echo -e '\n#If running from tty1 start sway\n[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/start_sway.sh' >> $HOME/.bashrc
		;;
		labwc)
			# setup Ubuntu Sway Remix repo for nwg-look as Ubuntu 24.04 do not have nwg-look packaged
   			if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
				sudo add-apt-repository ppa:ubuntusway-dev/stable -y
    				# install labwc and packages
				install_packages labwc swaybg wlr-randr sfwbar wofi nwg-look
      			fi

  			# setup Debian Testing repo for labwc as Debian 12 do not have labwc packaged
   			if [[ -n "$(uname -a | grep Debian)" ]]; then
				sudo cp /etc/apt/sources.list /etc/apt/sources.list.d/debian-testing.list
    				sudo sed -i 's/bookworm/testing/g' /etc/apt/sources.list.d/debian-testing.list
				echo -e "Package: *\nPin: release a=stable\nPin-Priority: 700\nPackage: *\nPin: release a=testing\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/debian-testing.pref
    				sudo apt-get update
				sudo DEBIAN_FRONTEND=noninteractive apt-get install -t testing labwc swaybg wlr-randr sfwbar wofi nwg-look -y
      			fi
   			
      			# install labwc and packages
			#install_packages labwc swaybg wlr-randr sfwbar wofi nwg-look

			# enable autostart labwc after TUI login
			#autostart_wm labwc

			# copy labwc configs
			mkdir -p $HOME/.config/labwc
			#cp /etc/xdg/labwc/environment $HOME/.config/labwc/
			#cp /etc/xdg/labwc/menu.xml $HOME/.config/labwc/
   			wget https://raw.githubusercontent.com/labwc/labwc/master/docs/environment -O $HOME/.config/labwc/environment
   			wget https://raw.githubusercontent.com/labwc/labwc/master/docs/menu.xml -O $HOME/.config/labwc/menu.xml
      			#wget https://raw.githubusercontent.com/labwc/labwc/master/docs/autostart -O $HOME/.config/labwc/autostart
			#wget https://raw.githubusercontent.com/labwc/labwc/master/docs/rc.xml -O $HOME/.config/labwc/rc.xml
			cp ./labwc/* $HOME/.config/labwc/

			# copy sfwbar config
			mkdir -p $HOME/.config/sfwbar
			cp ./config/sfwbar.config $HOME/.config/sfwbar/

   			# labwc/openbox themes
      			mkdir -p $HOME/.themes
	 		git clone https://github.com/dracula/openbox /tmp/dracula-openbox
    			cp -r /tmp/dracula-openbox/Dracula* $HOME/.themes/

       			git clone https://github.com/catppuccin/openbox /tmp/catppuccin-openbox
	  		cp -r /tmp/catppuccin-openbox/themes/catppuccin-* $HOME/.themes/
		;;
		lubuntu)
			# install minimal setup on Lubuntu
			install_packages vlc geany transmission-qt rar

			# copy my LXQt and autostart configuration
			mkdir -p $HOME/.config/{lxqt,autostart}
			cp ./lubuntu/*.conf $HOME/.config/lxqt/
			#cp ./autostart/*.desktop $HOME/.config/autostart/
			
			# create PCManFM-Qt custom actions files
			mkdir -p $HOME/.local/share/file-manager/actions
			cp ./actions/*.desktop $HOME/.local/share/file-manager/actions/
			echo "Remember to change PCManFM-Qt's Archiver intergration to lxqt-archiver under Preferences > Advanced."
			# actions to open terminal in desktop. Not needed for LXQt v1.3 and above
			rm $HOME/.local/share/file-manager/actions/open-in-terminal.desktop

   			# install Dracula theme for LXQt and QTerminal
      		mkdir -p $HOME/.local/share/lxqt/{palettes,themes}
    		git clone https://github.com/AzumaHazuki/lxqt-themes-dracula /tmp/lxqt-themes-dracula
      		cp -r /tmp/lxqt-themes-dracula/palettes/* $HOME/.local/share/lxqt/palettes
			cp -r /tmp/lxqt-themes-dracula/themes $HOME/.local/share/lxqt/themes/Dracula

			sudo mkdir -p /usr/share/qtermwidget5/color-schemes
  			git clone https://github.com/dracula/qterminal.git /tmp/qterminal
    		sudo cp /tmp/qterminal/Dracula.colorscheme /usr/share/qtermwidget5/color-schemes

       		# install Catppuccin LXQt and QTerminal theme
	  		mkdir -p $HOME/.local/share/lxqt/themes
	  		git clone https://github.com/catppuccin/lxqt /tmp/lxqt-catppuccin
     		cp -r /tmp/lxqt-catppuccin/src/* $HOME/.local/share/lxqt/themes

			sudo mkdir -p /usr/share/qtermwidget5/color-schemes
 			git clone https://github.com/catppuccin/qterminal /tmp/qterminal-catppuccin
    		sudo cp /tmp/qterminal-catppuccin/src/*.colorscheme /usr/share/qtermwidget5/color-schemes
     			
			# install openbox themes
			mkdir -p $HOME/.local/share/themes
			#git clone https://github.com/dracula/openbox /tmp/openbox
			git clone https://github.com/terroo/openbox-themes /tmp/openbox-themes
			cp -r /tmp/openbox-themes/* $HOME/.local/share/themes/
   			git clone https://github.com/catppuccin/openbox /tmp/openbox-catppuccin
      		cp -r /tmp/openbox-catppuccin/themes/* $HOME/.local/share/themes/
		;;
    	esac

	# Install standard packages
 	if [[ $wm == "sway" || $wm == "labwc" ]]; then
  		install_packages papirus-icon-theme adwaita-icon-theme xdg-utils xdg-user-dirs rsyslog logrotate nano less curl wget iputils-ping fonts-noto-color-emoji fonts-noto-cjk fonts-font-awesome gpicview geany unzip rar
    	else
		install_packages papirus-icon-theme adwaita-icon-theme xdg-utils xdg-user-dirs policykit-1 policykit-1-gnome software-properties-gtk rsyslog logrotate nano less curl wget iputils-ping fonts-noto-color-emoji fonts-noto-cjk fonts-font-awesome gpicview geany unzip rar
 	fi
  
	# install and configure dunst
	#if [[ $wm != "sway" ]]; then
	install_packages dunst
	# customize dunst config
	mkdir -p $HOME/.config/dunst
	backup_and_create "$HOME/.config/dunst/dunstrc" 
    cp -r /etc/xdg/dunst $HOME/.config/
    sed -i 's/Adwaita/"Adwaita, Papirus"/g' $HOME/.config/dunst/dunstrc
    sed -i 's/32/22/g' $HOME/.config/dunst/dunstrc
	#fi

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
		install_packages qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
	fi

	# install wine and lutris
	if [[ $gaming == "yes" ]]; then
		install_packages wine64
		install_packages python3-lxml python3-setproctitle python3-magic gir1.2-webkit2-4.1 cabextract \
  			fluid-soundfont-gs vulkan-tools python3-protobuf python3-evdev fluidsynth gamemode
		wget -P /tmp https://github.com/lutris/lutris/releases/download/v0.5.18/lutris_0.5.18_all.deb
		sudo dpkg -i /tmp/lutris*.deb
	
		# install MangoHud
		wget -P /tmp https://github.com/flightlessmango/MangoHud/releases/download/v0.7.2/MangoHud-0.7.2.r0.g7b80f73.tar.gz
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
		install_packages smartmontools
		sudo cp ./bin/smartdnotify /etc/smartmontools/smartd_warning.d/
		sudo chmod +x /etc/smartmontools/smartd_warning.d/smartdnotify

		# schedule run smart disk test
		sudo cp ./config/run_smartd_test /etc/cron.d/
		sudo cp ./bin/run_smartd_test /usr/local/bin/
		sudo chmod +x /usr/local/bin/run_smartd_test
	fi

	# install and configure lm-sensors
	if [[ $sensors == "yes" ]]; then
		install_packages lm-sensors
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

		# add additional geany colorscheme
		mkdir -p $HOME/.config/geany/colorschemes
		git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
		cp -r /tmp/geany-themes/colorschemes/* $HOME/.config/geany/colorschemes/
  		git clone https://github.com/catppuccin/geany /tmp/geany-catppuccin
    	cp -r /tmp/geany-catppuccin/src/*.conf $HOME/.config/geany/colorschemes/

		# install lxterminal dracula theme
		git clone https://github.com/dracula/lxterminal.git /tmp/lxterminal
		mkdir -p $HOME/.config/lxterminal/
		cp /tmp/lxterminal/lxterminal.conf $HOME/.config/lxterminal/

		# install lxterminal catppuccin theme
  		git clone https://github.com/catppuccin/lxterminal /tmp/lxterminal-catppuccin
    	mkdir -p $HOME/.config/lxterminal/
		cp /tmp/lxterminal-catppuccin/themes/*.conf $HOME/.config/lxterminal/

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
		backup_and_create "$HOME/.nanorc"
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $pipewire == "yes" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			if [[ $wm == "i3wm" || $wm == "sway" || $wm == "labwc" ]]; then
				install_packages pipewire pipewire-pulse wireplumber
			else
				install_packages pipewire pipewire-pulse wireplumber pavucontrol-qt pnmixer
				mkdir -p $HOME/.config/pnmixer
				cp ./config/pnmixer $HOME/.config/pnmixer/config
			fi
		fi
	fi

	# optional to install thunar file manager
	if [[ $thunar == "yes" ]]; then
		if [[ $wm != "lubuntu" ]]; then
			install_packages thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon
			#mkdir -p $HOME/.config/xfce4
			#if [[ $wm != "xfwm4" && $wm != "sway" ]]; then
			#	echo "TerminalEmulator=lxterminal" > $HOME/.config/xfce4/helpers.rc
			#fi
		fi
	fi

	# optional to install SDDM or lxdm or no login manager
 	case $login_mgr in
	lxdm)
 		install_packages lxdm
 	;;
  	sddm)
   		install_packages sddm
   	;;
    	wayland)
     		autostart_wm $wm
     	;;
  	esac
	#if [[ $login_mgr == "lxdm" ]]; then
	#	install_packages lxdm
	#else
	#	install_packages sddm
	#fi

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
			install_packages firefox
		else
  			# install firefox-esr from debian repo
			install_packages firefox-esr
			if [[ $wm == "fluxbox" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.fluxbox/keys
			fi
			if [[ $wm == "icewm" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.icewm/{menu,toolbar}
			fi
			if [[ $wm == "xfwm4" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.config/xfce4/panel/launcher-10/17140154333.desktop
			fi
   			if [[ $wm == "labwc" ]]; then
				sed -i 's/firefox/firefox-esr/g' $HOME/.config/labwc/menu.xml
			fi
		fi
	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
		if [[ $wm != "lubuntu" ]]; then
			install_packages network-manager network-manager-gnome
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
	disable_services systemd-networkd-wait-online.service multipathd.service

	# install and setup for laptop usage
	if [[ $laptop_mode == "yes" ]]; then
		install_packages brightnessctl cbatticon
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

# installation menu selection
menu
 
#for wmlist in "${wm_options[@]}"; do
#	echo $wmlist
#done
 
# Summary of selections
printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "##################################\n"
printf "My WM Install           : $wm\n"
printf "Firefox as DEB packages : $firefox_deb\n"
printf "Pipewire Audio          : $pipewire\n"
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
printf "##################################\n"
 
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
