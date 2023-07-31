export DEBIAN_FRONTEND=noninteractive

# Sudo
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/anduin

sudo pro config set apt_news=false
sudo rm /var/lib/ubuntu-advantage/messages/*

echo "Preinstall..."
sudo apt-get install wget gpg curl

echo "Setting timezone..."
sudo timedatectl set-timezone UTC

# Docker
echo "Setting docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Chrome
echo "Setting google..."
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' 
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Code
echo "Setting ms..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Nextcloud
sudo add-apt-repository ppa:nextcloud-devs/client --yes

# Snap
sudo snap remove firefox
sudo snap remove snap-store
sudo snap remove gnome-3-38-2004
sudo snap remove gtk-common-themes
sudo snap remove snapd-desktop-integration
sudo snap remove core20
sudo snap remove bare
sudo snap remove snapd
sudo apt remove snapd -y
sudo rm ~/snap -rvf
sudo rm  /snap -rvf

# Firefox
sudo add-apt-repository ppa:mozillateam/ppa --yes
echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | sudo tee /etc/apt/preferences.d/mozilla-firefox

# Node
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

sudo apt install nodejs google-chrome-stable firefox ibus-rime\
  apt-transport-https code vim remmina remmina-plugin-rdp\
  w3m git vim sl zip unzip wget curl neofetch jq\
  net-tools libglib2.0-dev-bin httping ffmpeg nano\
  gnome-tweaks gnome-shell-extension-prefs spotify-client\
  vlc golang-go aria2 adb ffmpeg nextcloud-desktop\
  ruby openjdk-17-jdk default-jre dotnet6 ca-certificates\
  gnupg lsb-release  docker-ce docker-ce-cli pinta aisleriot\
  containerd.io jq htop iotop iftop ntp ntpdate ntpstat\
  docker-compose tree smartmontools\

# Repos
mkdir ~/Source
mkdir ~/Source/Repos

# Chinese input
wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip
unzip main.zip -d rime-ice-main
mkdir -p ~/.config/ibus/rime
mv rime-ice-main/*/* ~/.config/ibus/rime/
rm -rf rime-ice-main
rm main.zip
echo "Rime configured!"


# Git
git config --global user.email "anduin@aiursoft.com"
git config --global user.name "Anduin Xue"

# SSH Keys
mkdir ~/.ssh
cp ~/Nextcloud/Storage/SSH/* ~/.ssh/
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa

# Upgrade
echo "Upgrading..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Fix
echo "Removing deprecated packages..."
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-broken  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-missing  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sleep 1

# Script
cp ~/Nextcloud/Storage/Scripts/sync_lab_to_hub.sh ~/Source/Repos/
chmod +x ~/Source/Repos/sync_lab_to_hub.sh

# Rider

# Install rider...
echo "Installing Rider..."
wget https://download.jetbrains.com/rider/JetBrains.Rider-2023.1.4.tar.gz
tar -xzf JetBrains.Rider-2023.1.4.tar.gz
sudo mv JetBrains\ Rider-2023.1.4/ /opt/rider
rm JetBrains.Rider-2023.1.4.tar.gz
echo "[Desktop Entry]
Name=JetBrains Rider
Comment=Integrated Development Environment
Exec=/opt/rider/bin/rider.sh
Icon=/opt/rider/bin/rider.png
Terminal=false
Type=Application
Categories=Development;IDE;" | sudo tee /usr/share/applications/jetbrains-rider.desktop

# Nextcloud talk
echo "Installing Nextcloud talk... (INOP)"
echo "[Desktop Entry]
Name=Nextcloud talk
Comment=Social
Exec=/opt/nct/nct
Icon=/opt/nct/nct.png
Terminal=false
Type=Application
Categories=Social;" | sudo tee /usr/share/applications/nct.desktop

# Dotnet tools
function TryInstallDotnetTool {
  toolName=$1
  globalTools=$(dotnet tool list --global)

  if [[ $globalTools =~ $toolName ]]; then
    echo "$toolName is already installed. Updating it.." 
    dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
  else
    echo "$toolName is not installed. Installing it.."
    if ! dotnet tool install --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null; then
      echo "$toolName failed to be installed. Trying updating it.."
      dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
      echo "Failed to install or update .NET $toolName"
    fi
  fi
}
TryInstallDotnetTool "dotnet-ef"
TryInstallDotnetTool "Anduin.Parser"
TryInstallDotnetTool "Anduin.HappyRecorder"
~/.dotnet/tools/happy-recorder config set-db-location --path ~/Nextcloud/Storage/HappyRecords/
TryInstallDotnetTool "Aiursoft.NugetNinja"
TryInstallDotnetTool "Aiursoft.Dotlang"
TryInstallDotnetTool "Aiursoft.NiBot"
TryInstallDotnetTool "JetBrains.ReSharper.GlobalTools"

# Trash bin
gsettings set org.gnome.shell.extensions.ding show-trash true


# Other settings:

# * Setup scale
# * Login Chrome
# * Login Nextcloud
# * Login VSCode & GitHub
# * Install Outlook PWA
# * Configure Theme
# * Configure weather plugin
# * Setup mouse speed
# * Install Docker Desktop
# * Install fingerprint driver
