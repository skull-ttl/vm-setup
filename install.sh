#!/bin/bash
set -e
sudo apt update
# --- Your earlier setup here: apt install, pip, git clone, waveterm, etc. ---
echo "[*] Installing WaveTerm (via snap)..."
sudo snap install --classic waveterm
echo "[*] WaveTerm installed."
echo "[*] Updating Metasploit Framework and database..."
# Update apt package cache and Metasploit Framework
sudo apt install -y metasploit-framework
# Initialize and update Metasploit database
sudo msfdb init || true    # 'true' allows script to continue if already initialized
sudo msfupdate
echo "[*] Metasploit Framework and database are up to date."
# Replace with your actual GitHub repo or raw .yaml link
WORKSPACE_URL="https://raw.githubusercontent.com/skull-ttl/vm-setup/main/ctf-default.yaml"
echo "[*] Downloading WaveTerm CTF workspace config..."
mkdir -p "$HOME/.waveterm/workspaces"
wget -O "$HOME/.waveterm/workspaces/ctf-default.yaml" "$WORKSPACE_URL"
echo "[*] WaveTerm config placed in ~/.waveterm/workspaces/ctf-default.yaml"
if [ "$EUID" -eq 0 ]; then
    echo "[!] Homebrew cannot be installed as root. Please run the following as your normal user after this script:"
    echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
else
    echo "[*] Installing Brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "[*] Brew Installation complete... remember to add to your shellenv"
fi
# ---- RustDesk Install ----
echo "[*] Installing RustDesk..."
RUSTDESK_VERSION=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')
wget "https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-amd64.deb" -O /tmp/rustdesk.deb
apt install -y /tmp/rustdesk.deb
rm /tmp/rustdesk.deb
echo "[*] RustDesk installed. You can launch it with 'rustdesk &' or configure headless."
echo "[*] Setting up Proxychains4..."
sudo apt install proxychains4
sudo apt install tor
sudo systemctl enable tor.service
sudo systemctl start tor.service
sudo systemctl status tor.service
#set dynamic chain in /etc/proxychains4.conf proxydns uncommented
#set the localhost to tor port
sudo sed -i 's/#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
sudo sed -i 's/strict_chain/#strict_chain/' /etc/proxychains4.conf
sudo sed -i '$asocks5 127.0.0.1 9050\n' /etc/proxychains4.conf
echo "[*] Proxychains4 is set up..."
#WinPEA und LinPEA Scripts
echo "[*] Grabbing WinPEA and LinPEA..."
mkdir ./PrivEsc
cd ./PrivEsc
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_fat.sh
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
cd ../
echo "[*] Done grabbing WinPEA and LinPEA..."
echo "[*] Get pimpmykali..."
git clone https://github.com/Dewalt-arch/pimpmykali.git
echo "[*] Done getting pimpmykali..."
echo "[*] Get flameshot..."
sudo apt install flameshot
echo "[*] Done getting pimpmykali..."
#Collection.txt can be added here
echo "https://www.ssllabs.com/
https://weakpass.com/download" >> ./links.txt
read -p "Install additional Wordlists? (approx. 20GB)?(y/n)" tmpboolean
if [ "$tmpboolean" = "yes" ] || [ "$tmpboolean" = "y" ] || [ "$tmpboolean" = "ja" ]
   then
    mkdir ./AddWL
    git clone https://github.com/carlospolop/Auto_Wordlists.git
    cd ./AddWL
    wget https://download.weakpass.com/wordlists/1927/cyclone.hashesorg.hashkiller.combined.txt.7z
    cd ../
    fragen nach Rainbowtables von Crackstation und Passwortlisten von WeakPass
    read -p "Install Huge Passwordlists and Rainbowtables (approx. 400GB)?(y/n)" wrdboolean
    if [ "$wrdboolean" = "yes" ] || [ "$wrdboolean" = "y" ] || [ "$wrdboolean" = "ja" ]
       then
        mkdir ./HugeWL
        cd ./HugeWL
        wget https://download.weakpass.com/wordlists/all-in-one/1/all_in_one.7z
        wget https://crackstation.net/files/crackstation.txt.gz
        cd ../
       else
        echo "Skipping Huge List"
        sleep 2
    fi
  else
    echo "."
    echo ".."
    echo "..."
fi
sudo apt autoremove
echo "installation finished"

cat <<'EOF'
        %%%%                                            *@%%%%@-                                %%%%
       %%%%%                                        %%%%%%%%%%%%%%%%%-                         @%%%%
      *%%*%%%                                     %%%%%%%%%%%%%%%%%%%%%%%                      %%%%%
      %%%:%%%                                   %%%%%%%%::::   ::::: %%%%%%%                  %%%: %
     %%% :-%%%                                %%%%%%%%  ::::::::::::: ::%%%%%%%               %%%- %
    %%%%::-*%%@                             %%%%%%%%*::::::::::::::::: ::  %%%%%%            %%%:-::
    %%%: :-:%%%                            %%%%%%%% :::::: ::::: ::::::: :: :%%%%%          -%%%- ::
   %%% :  :--%%@                          %%%%%%%%  ::::::::::::*-*-- ::::::::-%%%%%        %%%:-::
  %%%%: :: --%%%                         %%%%%%%%*:::::::::::::----------: :::: %%%%%      %%%*-::::
  %%%: ::::---%%%                       %%%%%%%%%::  :::::::  -----**----*-::::::*@%%%     %%%--::::
 %%% :::::::--*%%%%%%%%%%%%%%%%%%%-    *%%%%%%%% : :: :: ::::-----%-----------:::::%%%%   %%%*--::::
%%%: :::::: :%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%:::: :::  : -----%%%%%%%%%%%---*::: *%%%  %%%-- ::::
%%%::::::  %%%%%%%%:: ::   :-%%%%%%%%%%%%%%%%%%: :::::::::: ----%%%%%%%%%%%%%%*--*:: %%%%%%%---::: :
%%::::: :*%%%%%%:::: :::::::: :::: %%%%%%%%%%%%::   :::::: ----%%%%%%%%%%%%%%%%%%-- : %%%%%*--::::::
%:::::::%%%%%*:::::::: ::::: ::::::::%%%%%%%%%*:::::: ::: ----%%%%%%%%%%%%%%%%%%%%*-*:*%%%%---::: ::
%::: : %%%%%: ::: :::::  : ::: : :::::%%%%%%%% : ::::::::----%%%%%%%%%%%%%%%%%%%%%%%--:%%%%---:: :::
::::: %%%%%:  :: -----* ::  :: ::::::::%%%%%%% :::  ::::----%%%%%%%%%%%%%%*    *%%%%%%- %%%%-::: : :
: :: %%%%*:::: -----*----*: :::::::::: :%%%%%%::::: :::----%%%%%%%%%%%%%%*        %%%%%*-%%%-  :::::
::::%%%%%:  :------*%%%----*:: ::: ::::::%%%%*:::: : ----*%%%%%%%%%%%%%%%%:         %%%%%%%%% : : :
:  %%%%%::::-------%%%%%%----- :::::::::::*%%::::::*---*%%%%%%%%%%%%%%%%%%%%        %%%%%%%%%%%% :::
:: %%%% :::-----%%%%%%%%%%%----::::: :: ::::% :::::::: :: %%%%%%%%%%%%%%%%%%*      *%%%%%    %*%% :
::*%%%%:: ----%%%%%%%%%%%%%%*----::::::::::::: ::: ::: %%%%%%%%%%%%%%%%%%%%%%      %%%%%     *%%%%
::%%%% ::---*%%%%%%%%%%%%%%%%%%----:::  :: :  ::::::%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%    :%@%%%::
: %%%%::---%%%%%%%%%%%%%%%%%%--%%%%%%%%- ::::::: -%%%%%%%%%%%%%%%%%%%%%%%%%%%%   %%%%%%%%-   %%%% ::
  %%%%::--%%%%%%%%%%%%%%%%%%-%%%%%%%%%%%%%-::: %%%%%%%@          %%%%%%%%%%%%%   %%%%-*%%%%%%%%%::::
::%%%%:--%%%%%%*: :::::%%%%%%%%:      %%%%%%%%%%%%*                 %%%%%%%%%%  %%%%-----***-:::::::
  %%%% -%%%%%%:  :: :::-%%%%%*           @%%%%%%*                    %%%%*%%%% %%%%-------: ::: : ::
::%%%%:%%%%% :: ::::: : %%%%@               %%            %%%%%%      %%%%%%%%%%%%-------::::::  :%%
::*%%%%%%%%:: ::::: :: :%%%%  %%%                       %%%%%%**%-    %%%%%%%%%%%-------- ::::::::*%
:: %%%%%%*::: ::::::::::%%%%%%%%%%%                   %%%%%%          %%%%%%%%%%--------:::::: :  %%
::%%%%%%%%%::::  ::: ::: %%%% -%%%%%*               @%%%%%-%%*        %%%%%%%%%--------::::::: :  ::
:%%%%   *%%%% :::::: ::::*%%%: @%%%%%%%       %   @%%%%%   %%%        %%%%%%%%%-------::::: :: : :::
%%%-      %%% ::::::::::::%%%%  %  %%%%%*%:   %%%%%%%%    %%%%        @%%%%%%%%------ ::::::: ::::::
%%%*    : %%%%%**:  ::::::%%%%% %%   %%%%%    -%%%%%    %%%%%         %%%%%%%%%-----  :::  ::-**%%%%
%%%%% :  %%%%%%%%%%%%%%%%%%%%%   %%%%@%%%*     %%%%%%%%%%%%           %%%%%%%%-*%%%%%%%*%%%%%%%%%%%%
  %%%%%%%%%%: ::  :*%%%%%%%%%:     @*%%%%:     @                      %%%%%%%%%%%%%%%%%%%%%-   :::::
::: -%%%* :::::::::::----%%%%          @%                             %%%%%%%%%---------::::  ::::::
 :::%%% :::: :::: :: ----%%%%%         %%       %@%*                 *%%%%%%%%%-----:%%:: :::  :::::
:::%%%%%:::::::::: : -----%%%%        %            %%  @%%%%%%%      %%%%%%%%%%-----%%%%::: : : :::
 : %%%%%:::: ::::    -----*%%%%   %  %%           %%-     %%% :     -%%%%%%%%%%-----%%%%::: :  :-:::
: :%%%%% :::: :::%%%:------%%%%%  *%  %%      %%%%      %%%%        %%%%%%%%%%%----:%%%%-:::: ::::
:  %%%%% ::::: ::%%%:------%%%%%%@ - %*%%*@@%%%     @%%@ %%        %%%%%%%%%%%%-----%%%%-:::: :  :::
:::::::::::::::::  ::------%%%%%%%%   %%%%%%%%%%%%%%*   %%        %%%%%%%%%%%%%---------:::  :::::::
: ::::: ::::: :: ::: ------%%%%%%%%%   %%             @:%%       %%%%%%%%%%%%%*---------::::::::::::
:::: ::::::::::::: ::------%%%%%%%%%%  @%%             %%      %%%%%%%%%%%%%%%%%%%*-:---: ::::::::::
::  ::: ::: : :::::::------%%%%%%%%%%%  *%           *%%      %%%%%%%%%%%%-*%%%%%%%%%%%%%%%%%%%%%%%-
%%%%%%%%%%%%%%%%%%%%***---*%%%%%%%%%%%@  %%        @%%%      %%%%%%%%%%%%%%%:--:*%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   %%%%%%%%%%%       %%%%%%%%%%%%%%%%%%---:-----::-%%%%%%%%%%
: : : ::::  :::::%%%%%%%%%%% :::%%%%%%%*                  %%%%%%%%%%%%%%%%%%%%%%*-----:-%%%%*%% : ::
%%%%%%%%%%%%%%%%%%%%%%%:::::::%%%%%%%%%%*       *%       %%%%%%%%%%%*-::--****-::--:-%%%%%%%%%%%%%%%
::::: :::    %%*%%%%  :::::  ::  :  %%%%%               %%%%%%%%%%%%%------------------:-%%%%%%%%%%%
:: : ::::: %%%%%%%%%%%%%%%%%::::::::*%%%%%            :%%%%%%%%%%%%%%%--:-----:------:------:*%%%%%%
:: : :: :-%%%%%%%- %%%%%%*%%%:: :: ::%%*%%%          %%%%%%%%%%%%%%%%%----:-:----:----:-*%%%%%%%%%%%
::::: ::%%%%%%:::%%%%%%%%%%%%:::::: %%%%%%%%%%%%%%%%%%%%%%%%%%*%%%%%%%%:-:-:%%%%%%%%%%%%%%%%%%%%%%%%
::%%%: %%%%%:   %%%%%%%%%%%%% : :::%%%%%%%%%%%%%%%%%%%%%%%%%%-----*%%%%%----%%%%%%*%%%%%%%%%%%%%:---
 :%%%%%%%%%::::%%%%%%%%%%%%%*:::::%%%%%%%%%:%%%%%%%%%%%%%%%%-----::--:*%%---*%%%%%%%%%%%%%%%:---:---
::%%%%%%%% ::-%%%%%%%%%%%%%% ::::%%%%%% :: ::%%%%*%%%%%%%%%-----:-----------:%%%%%%%%%%%:-----:---::
::%%%%%%*:::-%%%%%%%%%%%%%%%:: :%*:::: :::::::%%%%%%%%%%%*----:%%%%--------:-%%%%%%%------------: ::
: %%%%%*:::-%%%%%%%%%%%%%%%%  ::::::::*%%% ::::%%%%%%%%%----:*%%%%%%%%%%*:---:%%%%---:--:---:% :::::
 %%%%%::: :%%%%%%%%%%%%%%%% :::: :%%%%%%%%%*::::*%%%%%%-----%%%%%%%%%%%%%%%%%%%%%%--------:%%:::::::
%%%%%-::: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ::: %%%*:----%%%%%%%%%%%%%%%%%%%%%%%%:--:--%%% :::::::
%%%%%: : %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*%%%%%%%::::% ::--%%%%%%%%%%%%%%%%%%%--**%**-----%%% ::::::::

EOF
