#Only do on new systems as conflict handling is not implemented in this script

sudo apt-get update
sudo apt-get upgrade

api(){
    sudo apt-get install "$1"
}

export USR_NAME=pmarkus
export BACKUP_DIR=/media/pmarkus/CRU1TB
export USR_BACKUP_DIR=$BACKUP_DIR/$USR_NAME
export NEW_USR_DIR=/home/pmarkus

api micro

#touch "$NEW_USR_DIR/.bashrc"
if [ ! -f "$NEW_USR_DIR/.bashrc" ]; then
    cp /etc/skel/.bashrc "$NEW_USR_DIR"
fi

echo -e "\n\n. $USR_BACKUP_DIR/.profile &>/dev/null" >> "$NEW_USR_DIR/.bashrc"

cp "$USR_BACKUP_DIR/.profile" "$NEW_USR_DIR"


mkdir -p "$NEW_USR_DIR/.ssh"
sudo cp -r "$USR_BACKUP_DIR/.ssh" "$NEW_USR_DIR"

cp -r "$USR_BACKUP_DIR/repos" "$NEW_USR_DIR"

cp "$USR_BACKUP_DIR/.gitconfig" "$NEW_USR_DIR"
cp "$USR_BACKUP_DIR/.gitconfig-common" "$NEW_USR_DIR"
cp "$USR_BACKUP_DIR/.gitconfig-work" "$NEW_USR_DIR"
#KDE wallet not supported yet for git cred storage
sudo apt install gnome-keyring
sudo apt install libsecret-1-0 libsecret-1-dev
cd /usr/share/doc/git/contrib/credential/libsecret
sudo make

echo "Sourcing .bashrc ..."
. "$NEW_USR_DIR/.bashrc"

#https://www.baeldung.com/linux/bashrc-vs-bash-profile-vs-profile

firefox https://synaptics.com/products/displaylink-graphics/downloads/ubuntu

mkdir -p /tmp/Displaylink
cd /tmp/Displaylink
wget https://synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip
unzip "*DisplayLink USB*.zip"
sudo bash *displaylink*.run
sudo rm -r /tmp/Displaylink


#firefox https://www.reaper.fm/download.php
#wget https://dlcf.reaper.fm/6.x/reaper671_linux_x86_64.tar.xz
export DOWNLOAD_LINK=$(curl --silent https://www.reaper.fm/download.php | grep -Po '(?<=a href=\").+linux_x86_64.+?(?=\")')
wget https://www.reaper.fm/$DOWNLOAD_LINK


#Purge and delete unneeded applications and possibly their libraries
apt-cache depends kmahjongg
apt info kmahjongg
sudo apt-get purge kmahjongg
sudo apt-get purge kdegames-mahjongg-data-kf5
sudo apt-get purge konversation
sudo apt-get autoremove
sudo apt-get update


#https://surfshark.com/download/linux
mkdir -p /tmp/surfshark && cd /tmp/surfshark
wget https://ocean.surfshark.com/debian/pool/main/s/surfshark-release/surfshark-release_1.0.0-2_amd64.deb
sudo apt install ~/Downloads/surfshark*.deb
sudo apt install surfshark

#api notepadqq
#sudo snap install notepadqq


### Kubuntu

## Kwin shortcuts:
# system settings -> shortcuts -> kwin:
# Maximize Window: Meta + Num + Clear, Meta + PgUp
# Quick Tile Window (custom shortcuts with numpad):
# Bottom Left: Meta + Num + End
# Left: Meta + Nume + Left

# System settings -> Task switcher -> visualization -> Grid - Informative - Compact - Thumbnail-Grid

## Krunner (Alt + Space):
# System settings -> Plasma Search, Web Search Keywords, File Search
# Plugins: Firefox Bookmarks Runner, VsCode Workspaces Runner, Joplin (Todo integrate)

# FLATPAK: -----------------------------------------------------------------

sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo
flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo
flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

#Install command for flatpak
flatpak install
com.slack.Slack
dolphin-emu
lutris
app/com.heroicgameslauncher.hgl
#Ffmpeg is superior in terms of options, but this is nicer if you do not want to read ffmpeg documentation right now to find said options
handbrake
#Same as with handbrake
youtubedl-gui
#muse
#flowblade
app/io.mpv.Mpv//stable
app/org.gimp.GIMP//stable
app/org.inkscape.Inkscape//stable
###flatpak search LinuxAudio
#org.freedesktop.LinuxAudio.Plugins.LSP
#org.freedesktop.LinuxAudio.Plugins.TAP
#org.freedesktop.LinuxAudio.Plugins.ZamPlugins
#org.freedesktop.LinuxAudio.Plugins.swh
com.obsproject.Studio
org.kde.kdenlive
org.kde.krita-nightly
org.qbittorrent.qBittorrent
org.winehq.Wine
com.github.Eloston.UngoogledChromium
notepadqq
com.github.dail8859.NotepadNext
KDiskMark
#Open source build of vscode
app/com.visualstudio.code-oss
#Closed source w. telemetry
#app/com.visualstudio.code
#Foss build with open extension repositories as well
#vscodium
#Wallpaper chooser
HydraPaper
#Backup Application (using borg as backend)
Vorta
bitwarden
com.github.micahflee.torbrowser-launcher
WhatsAppForLinux
thunderbird
#Music player with Youtube, Spotify, .etc support
app.moosync.moosync
filelight
org.freedesktop.Platform.ffmpeg-full/x86_64
#com.skype.Client
thunderbird #--> flatpak
torbrowser-launcher #--> flatpak
ffmpeg #--> flatpak + apt
filezilla #--> flatpak
filelight #--> flatpak
notepadqq #--> flatpak
obs #--> flatpak
heroic #--> flatpak
vlc #--flatpak
playonlinux #--> flatpak
mpv #Media player  #--> flatpak
#darktable #--> flatpak
##audacity #--> flatpak
#qbittorrent #--> flatpak
#blender # --> flatpak
##kdeconnect #kubuntupart
#kdenlive #--> flatpak
#audacious #--> flatpak #music player
#rawtherapee #--> flatpak
gwenview
meld #File/Directory comparison and merging
opera # --> flathub
qtractor # An Audio/MIDI multi-track sequencer --> flathub
#net.cozic.joplin_desktop//beta
net.cozic.joplin_desktop//stable
flameshot
flathub org.libreoffice.LibreOffice

#Diff + Integral calculator visualizer
Calculus

firefox

#Manage Flatpak permissions with GUI
flatseal

app/com.valvesoftware.Steam
com.valvesoftware.Steam.Utility.MangoHud

#linux audio
##carla

copy_if_source(){
    SOURCE="$1"
    DESTINATION="$2"

    if [ -d "$SOURCE" ]; then
        mkdir -p "$DESTINATION"
        cp -r "$SOURCE" "$DESTINATION"
    fi
}

copy_if_source "$USR_BACKUP_DIR/.steam/debian-installation/steamapps" ~/.var/app/com.valvesoftware.Steam/data/Steam
copy_if_source "$USR_BACKUP_DIR/.var/app/com.valvesoftware.Steam/data/Steam" ~/.var/app/com.valvesoftware.Steam/data/Steam

# -----------------------------------------------------------------


# NATIVE PACKAGES  -----------------------------------------------------------------

# /usr/bin

# +++ Package managers
python3
guix #Nix like package manager with dep resolve and snapshot creation/restoration and versioning

# +++ Text Editors / IDEs
micro
kate

# +++ zsh related
autojump

# +++ Sysadmin
apt-rdepends #CommandLine recursive dependency tree builder
lsscsi
teamviewer #Use VNC (TigerVNC or something similar) instead
gpg
wakeonlan
xbindkeys #Bind xinputs to commands -> for automatization

# +++ Audio Video Media
qjackctl
okular #KDE document viewer
#kodi
##rosegarden #music composition and editing environment based around a MIDI sequencer
##ardour
##lmms
##lilypond #Musical notation definition 'programming' https://lilypond.org/text-input.html
#muse #Music sheet production
#mpv
#mplayer #Movie player for unix like systems
#openshot
#flowblade
#kdenlive
#hydrogen #advanced drum machine/step sequencer
#pencil #FOSS gui prototyping tool -- snap: pencil-snap-demo,.deb http://pencil.evolus.vn/
#lame #Mp3 encoding libary (used by audacity for mp3 compression)

# +++ Image viewers / Editors
gwenview
digikam #Photo management program
qimgv
darktable
rawtherapee
#gimp

# +++ Drivers - Low level libs
jack2
pipewire
pulseaudio
pulseeffects
alsamixer #CommandLine audio driver manager

# +++ Backup and file management
thunar
dolphin
kbackup
timeshift
rdiff #CommandLine
rdiff-backup #CommandLine
rsnapshot #CommandLine
rsnapshot-diff #CommandLine
rsync #CommandLine
cifs-utils #Common Internet File System utilities --> Mount network shares
##samba
#duplicati
#duplicity
fdupes #Duplication finder and deleter - CMD tool

# +++ Emulation or Virtual Machines
#qemu: --- https://phoenixnap.com/kb/ubuntu-install-kvm
#qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
#virt-manager
#wine
#wine32
#wine64
#~~virtualbox
#~~dolphin-emu
#~~citra

# +++ Misc ultilities
kcalc
ksysguard
tree #CommandLine
#dmenu # Alternative task runner, useful for when using WM only
cpulimit
gunzip
xclip
yakuake #Drop down terminal
tmux #terminal multiplexer --https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/
#Loads often used applications to RAM to make start up faster
preload


#Power saving options
#Default on Ubuntu and Kubuntu (throttles cpu)
#powertop power-profiles-daemon#
#Better option for low power usage
#tlp tlp-rdw

#System monitor for power and settings tweaking utility (enable disable WOL and power saving features)
powertop

# +++ Development
git
#autoconf
#automake
#autoreconf
#gcc
#awk
#mysql
#~~mongo
#~~mongod
#code-server
python3-pip

docker.io
sudo groupadd docker
sudo usermod -aG docker pmarkus
#$ su - sally
docker run hello-world
groups
groups pmarkus
sudo chgrp docker -R /var/lib/docker
#Give the docker group read permissions
chmod g+r -R /var/lib/docker

# +++ Cmd Applications
w3m #CommandLine browser
#cmus #Music Player #--> flatpak
mutt #cmd email client
#melt #Kdenlive video editor backend, command line video editor and media player

#Networking, benchmarking
iperf3
net-tools

#--- ScreenRec
#sudo apt install kazam
#sudo apt-get install simplescreenrecorder

#--- Gaming
#sudo add-apt-repository multiverse
#sudo apt update
#sudo apt install steam

#Anaconda install (miniconda)
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#chmod +x Miniconda3-latest-Linux-x86_64.sh
#./Miniconda3-latest-Linux-x86_64.sh
#export PATH=~/miniconda/bin:$PATH

#cd ~/Downloads
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo apt install ./google-chrome-stable_current_amd64.deb

#--- Photo edit
#sudo apt-get install digikam
#sudo apt-get install darktable


#thunderbird
#audacity
#obs-studio

kmix # KDE audio device mixer, part of kde plasma

#sudo snap install simplenote

#Linux lowlatency kernel
linux-lowlatency
#Newest linux kernel
linux-generic

# ---------- KxStudio applications (special apt source)
sudo apt-get update
sudo apt-get install apt-transport-https gpgv wget
wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_11.1.0_all.deb
sudo dpkg -i kxstudio-repos_11.1.0_all.deb
#kxstudio-meta-all
# --- kxstudio-meta-audio-applications
# --- kxstudio-meta-audio-plugins
#kxstudio-meta-audio-plugins-collection
# --- kxstudio-meta-audio-plugins-ladspa
# --- kxstudio-meta-audio-plugins-dssi
# --- kxstudio-meta-audio-plugins-lv2
# --- kxstudio-meta-audio-plugins-vst
#The "collection" is a subset, focusing on just the highlights/best plugins to install out of all LADSPA, DSSI, LV2 and VSTs (where LV2 format is preferred, if available).

cadence #kxstudio https://wiki.linuxaudio.org/wiki/cadence_introduction
calfjackhost
carla #Audio plugin host
carla-control #Remote control carla from different machine
catia # jack patchbay graphical (A2J bridge support and JACK Transport) - simple
claudia # ladish frontend (graphical patchbay) - advanced

# Python pakcages -----------------------------------------------------------------

#pip3 (Transportable if correctly installed -> packages are at ~/.local/lib/python3.8/site-packages)
yt-dlp
argparse
#docker
docker-compose
dotenv
libqtile
matplotlib
qutebrowser
scipy
scdl
rnmd
#youtube-dl (in /usr/bin symlink to ~/.local/lib/python3.8/site-packages/yt-dlp)

# -----------------------------------------------------------------

# NPM packages -----------------------------------------------------------------

rimraf # Recursive deletion

# -----------------------------------------------------------------

#ZSH
# Plugins todo find: flatpak, apt, snap npm




# ----------

##teams
##muon #Software manager
##networkctl??
##ffplay #should be part of ffmpeg
##ffprobe #should be part of ffmpeg
##nvidia-smi # Installed with nvidia driver
#apt-sortpkgs #(not in default repo)
##java #(probably not needed mostly)
##kazam #Screen recorder - out of development since 2014
#jsondiff
#ocenaudio #audacity alternative - not in default ubuntu repo

# ~/.local/bin Just pip3 packages??
#bitwarden
#docker-compose
#qutebrowser
#rnmd
#qtile
#yt-dlp


#sudo add-apt-repository ppa:mozillateam/ppa
#sudo add-apt-repository --remove ppa:mozillateam/ppa
sudo add-apt-repository ppa:mozillateam/firefox-next
sudo apt-get update
#Prioritize native version of ff over snap
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

#24731, 24600 Native
#24093, 25307 Flatpak

cp -r "$USR_BACKUP_DIR/.joplin" ~
cp -r "$USR_BACKUP_DIR/.config/joplin-desktop" ~/.config/joplin-desktop
cp "$USR_BACKUP_DIR/.local/share/applications/appimagekit-joplin.desktop" ~/.local/share/applications
cp -r "$USR_BACKUP_DIR/.config/joplin" ~/.config/

cd $USR_BACKUP_DIR/.joplin
update.sh


cp -r "$USR_BACKUP_DIR/.local/share/applications/browser.desktop" ~/.local/share/applications
cp -r "$USR_BACKUP_DIR/.mozilla/firefox/*" ~/.mozilla/firefox

cp -r "$USR_BACKUP_DIR/.mozilla/firefox" ~/.var/app/org.mozilla.firefox/cache/mozilla


sudo snap install joplin
rm -r ~/snap/joplin-desktop/current/.config/joplin-desktop
mkdir -p ~/snap/joplin-desktop/current/.config
cp -r ~/.config/joplin-desktop ~/snap/joplin-desktop/current/.config

#Davinci Resolve


#https://docs.flatpak.org/en/latest/getting-started.html
sudo add-apt-repository ppa:flatpak/stable
sudo apt-get update
sudo apt install flatpak

#Working and not working flatpaks
# UngoogledChromium No
# Chromium No
# ChromeDev-Unstable
# Bitwarden
# Joplin
# Vscode OSS

#eval "$(dbus-launch --sh-syntax --exit-with-session)"
#sudo -i
# flatpak run com.slack.Slack --no-sandbox

#apt
qimgv
iozon3
#iozone -r '#m' -s '#m' -az
#Testing Striping speedup
#iozone -a -s 16
#iozone -a -s 128
#https://www.thegeekstuff.com/2011/05/iozone-examples/
#https://www.linuxlinks.com/BenchmarkTools/

#JSON parsing LIB
sudo apt install jq
cd ~/repos
RELEASE_INFO=$(curl https://api.github.com/repos/nvm-sh/nvm/releases/latest)
RELEASE_ZIP_URL=$(echo "$RELEASE_INFO" | jq --raw-output '.zipball_url' )
wget -O nvm.zip "$RELEASE_ZIP_URL"
unzip nvm.zip
rm nvm.zip
cd ~/repos/nvm*
cat "install.sh" | bash
CURRENT_NVM=$(pwd)
cd ~
rm -rf "$CURRENT_NVM"
# ----------
nvm ls-remote --lts
nvm install --lts
nvm current
npm install -g npm

mathjs
ts-node
yarn
eslint
http-server
joplin
npm-check-updates
pm2
tsc
typescript


#https://joplinapp.org/terminal/#synchronisation
joplin
:config sync.target 3
:sync
open browser and authorize markus@markuspeitl.com OneNote account


#Manage .ssh key permissions
#sudo chmod 644 hostinger_rsa
#Or user based
#sudo chmod 600 hostinger_rsa
#sudo chown pmarkus hostinger_rsa
#sudo chgrp pmarkus hostinger_rsa
#ls -al

# rwx owner rwx inside group rwx others access

sudo chown pmarkus -R ~/.ssh
sudo chgrp pmarkus -R ~/.ssh
ls -al
#Readonly for owner (and root)
sudo chmod 400 ~/.ssh/*_rsa
#sudo chmod 600 ~/.ssh/*_rsa
sudo chmod 400 ~/.ssh/*_rsa.pub
sudo chmod 400 ~/.ssh/*.pem
#sudo chmod 600 ~/.ssh/*_rsa.pub
#sudo chmod 644 ~/.ssh/*_rsa.pub
ls -al

#Reaper locations
/media/pmarkus/CRU1TB/pmarkus/Documents/REAPER Media/*
/media/pmarkus/CRU1TB/pmarkus/Documents/REAPER Media/Guiar-Recording new/Charango Effects/SimpleGuitarTest/Test-Midi-Charango/


