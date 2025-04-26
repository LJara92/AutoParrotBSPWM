#!/bin/bash

# Asegura que no se ejecute como root
if [ "$(whoami)" == "root" ]; then
    echo "🚫 No ejecutes este script como root. Usá tu usuario normal."
    exit 1
fi

ruta=$(pwd)

echo "📦 Actualizando sistema..."
sudo apt update && sudo parrot-upgrade -y

echo "🔧 Instalando paquetes y dependencias..."
sudo apt install -y \
  build-essential git vim zsh rofi xclip bat locate neofetch wmname acpi \
  bspwm sxhkd feh flameshot imagemagick ranger kitty \
  cmake cmake-data pkg-config python3-sphinx \
  libxcb1-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
  libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev \
  libxcb-xtest0-dev libxcb-shape0-dev libxcb-composite0-dev \
  python3-xcbgen xcb-proto libxcb-image0-dev libxcb-xkb-dev libxcb-xrm-dev \
  libxcb-cursor-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev \
  libnl-genl-3-dev \
  meson libxext-dev libpixman-1-dev libdbus-1-dev libconfig-dev \
  libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev \
  libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev \
  zsh-syntax-highlighting zsh-autosuggestions zsh-autocomplete

echo "📁 Preparando carpetas de código..."
mkdir -p ~/github && cd ~/github

echo "📥 Clonando y compilando Polybar..."
git clone --recursive https://github.com/polybar/polybar
cd polybar && mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

echo "💨 Clonando y compilando Picom..."
cd ~/github
git clone https://github.com/ibhagwan/picom.git
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

echo "🌈 Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k

echo "🎨 Copiando tema de Rofi..."
mkdir -p ~/.config/rofi/themes
cp "$ruta/rofi/nord.rasi" ~/.config/rofi/themes/

echo "🔤 Instalando fuentes..."
sudo cp -v $ruta/fonts/HNF/* /usr/local/share/fonts/
sudo cp -v $ruta/Config/polybar/fonts/* /usr/share/fonts/truetype/
fc-cache -fv

echo "🖼️ Copiando wallpapers..."
mkdir -p ~/Wallpaper ~/ScreenShots
cp -v $ruta/Wallpaper/* ~/Wallpaper/

echo "📁 Copiando configuraciones..."
cp -rv $ruta/Config/* ~/.config/
# Opcional para root o uso compartido
# sudo cp -rv $ruta/kitty /opt/
# sudo cp -rv $ruta/Config/kitty /root/.config/

echo "🐚 Copiando configuración ZSH..."
cp -v $ruta/.zshrc ~/.zshrc
cp -v $ruta/.p10k.zsh ~/.p10k.zsh
sudo cp -v $ruta/.p10k.zsh-root /root/.p10k.zsh
sudo ln -sfv ~/.zshrc /root/.zshrc

echo "🧠 Copiando scripts..."
sudo cp -v $ruta/scripts/whichSystem.py /usr/local/bin/
sudo cp -v $ruta/scripts/screenshot /usr/local/bin/
sudo chmod +x /usr/local/bin/whichSystem.py /usr/local/bin/screenshot

echo "⚙️ Asignando permisos..."
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/bin/*.sh 2>/dev/null || true

echo "🐚 Cambiando shell a zsh..."
chsh -s /usr/bin/zsh
sudo usermod --shell /usr/bin/zsh root

echo "🎨 Ejecutando selector de temas Rofi (opcional)..."
rofi-theme-selector

echo "🧹 Limpiando temporales..."
rm -rf ~/github

echo "✅ Instalación completada."
notify-send "AutoParrotBSPWM listo 😎"

