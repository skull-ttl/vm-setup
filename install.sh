#!/bin/bash

# Exit on pipefail, not on individual errors (we handle errors ourselves)
set -o pipefail

# Arrays to track what worked and what failed
SUCCESS_TOOLS=()
FAILED_TOOLS=()

# Helper function to track installation results
track_result() {
    if [ "$1" -eq 0 ]; then
        SUCCESS_TOOLS+=("$2")
    else
        FAILED_TOOLS+=("$2")
    fi
}

echo "[*] Updating package list..."
sudo apt update
track_result $? "apt update"

######################################
# Install WaveTerm via Snap
######################################
echo "[*] Installing WaveTerm (via snap)..."
if sudo snap install --classic waveterm; then
    echo "[+] WaveTerm installed."
    SUCCESS_TOOLS+=("WaveTerm")
else
    echo "[!] Failed to install WaveTerm."
    FAILED_TOOLS+=("WaveTerm")
fi

######################################
# Metasploit install & update
######################################
echo "[*] Updating Metasploit Framework and database..."
if sudo apt install -y metasploit-framework && sudo msfdb init || true && sudo msfupdate; then
    echo "[+] Metasploit Framework and database are up to date."
    SUCCESS_TOOLS+=("Metasploit")
else
    echo "[!] Failed to update/install Metasploit."
    FAILED_TOOLS+=("Metasploit")
fi

######################################
# Download WaveTerm YAML workspace
######################################
WORKSPACE_URL="https://raw.githubusercontent.com/skull-ttl/vm-setup/main/ctf-default.yaml"
echo "[*] Downloading WaveTerm CTF workspace config..."
mkdir -p "$HOME/.waveterm/workspaces"
if wget -O "$HOME/.waveterm/workspaces/ctf-default.yaml" "$WORKSPACE_URL"; then
    echo "[+] WaveTerm config placed in ~/.waveterm/workspaces/ctf-default.yaml"
    SUCCESS_TOOLS+=("WaveTerm CTF config")
else
    echo "[!] Failed to download WaveTerm config."
    FAILED_TOOLS+=("WaveTerm CTF config")
fi

######################################
# Homebrew (user must install as non-root)
######################################
if [ "$EUID" -eq 0 ]; then
    echo "[!] Homebrew cannot be installed as root. Please run the following as your normal user after this script:"
    echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    FAILED_TOOLS+=("Homebrew")
else
    echo "[*] Installing Brew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "[+] Brew Installation complete... remember to add to your shellenv"
        SUCCESS_TOOLS+=("Homebrew")
    else
        echo "[!] Brew installation failed."
        FAILED_TOOLS+=("Homebrew")
    fi
fi

######################################
# RustDesk install (always grab latest amd64 .deb)
######################################
echo "[*] Installing RustDesk..."
RUSTDESK_DEB_URL=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep browser_download_url | grep amd64.deb | cut -d '"' -f 4 | head -n 1)
if [ -z "$RUSTDESK_DEB_URL" ]; then
    echo "[!] Failed to find RustDesk .deb for amd64 architecture. Please check the RustDesk releases page."
    FAILED_TOOLS+=("RustDesk")
else
    if wget "$RUSTDESK_DEB_URL" -O /tmp/rustdesk.deb && sudo apt install -y /tmp/rustdesk.deb && rm /tmp/rustdesk.deb; then
        echo "[+] RustDesk installed. You can launch it with 'rustdesk &' or configure headless."
        SUCCESS_TOOLS+=("RustDesk")
    else
        echo "[!] RustDesk installation failed."
        FAILED_TOOLS+=("RustDesk")
    fi
fi

######################################
# Proxychains4 & Tor install/config
######################################
echo "[*] Setting up Proxychains4 and Tor..."
if sudo apt install -y proxychains4 tor; then
    sudo systemctl enable tor.service
    sudo systemctl start tor.service
    # Configure proxychains4.conf
    sudo sed -i 's/#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
    sudo sed -i 's/strict_chain/#strict_chain/' /etc/proxychains4.conf
    sudo sed -i '$asocks5 127.0.0.1 9050\n' /etc/proxychains4.conf
    echo "[+] Proxychains4 and Tor are set up."
    SUCCESS_TOOLS+=("Proxychains4 + Tor")
else
    echo "[!] Failed to set up Proxychains4 or Tor."
    FAILED_TOOLS+=("Proxychains4 + Tor")
fi

######################################
# PEASS-ng scripts (PrivEsc tools)
######################################
echo "[*] Grabbing WinPEA and LinPEA..."
mkdir -p ./PrivEsc
cd ./PrivEsc
PEA_OK=1
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh || PEA_OK=0
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_fat.sh || PEA_OK=0
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat || PEA_OK=0
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe || PEA_OK=0
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe || PEA_OK=0
cd ..
if [ $PEA_OK -eq 1 ]; then
    echo "[+] Grabbed PEASS-ng scripts."
    SUCCESS_TOOLS+=("PEASS-ng PrivEsc scripts")
else
    echo "[!] Failed to download all PEASS-ng scripts."
    FAILED_TOOLS+=("PEASS-ng PrivEsc scripts")
fi

######################################
# pimpmykali & flameshot
######################################
echo "[*] Cloning pimpmykali..."
if git clone https://github.com/Dewalt-arch/pimpmykali.git; then
    echo "[+] pimpmykali cloned."
    SUCCESS_TOOLS+=("pimpmykali")
else
    echo "[!] Failed to clone pimpmykali."
    FAILED_TOOLS+=("pimpmykali")
fi

echo "[*] Installing flameshot..."
if sudo apt install -y flameshot; then
    echo "[+] flameshot installed."
    SUCCESS_TOOLS+=("flameshot")
else
    echo "[!] Failed to install flameshot."
    FAILED_TOOLS+=("flameshot")
fi

######################################
# links.txt collection
######################################
echo "https://www.ssllabs.com/
https://weakpass.com/download" >> ./links.txt

######################################
# Wordlist Section (Interactive)
######################################
read -p "Install additional Wordlists? (approx. 20GB)?(y/n) " tmpboolean
if [[ "$tmpboolean" =~ ^([yY][eE][sS]|[yY]|[jJ][aA])$ ]]; then
    mkdir -p ./AddWL
    if git clone https://github.com/carlospolop/Auto_Wordlists.git ./AddWL; then
        echo "[+] Auto_Wordlists cloned."
        SUCCESS_TOOLS+=("Auto_Wordlists")
    else
        echo "[!] Failed to clone Auto_Wordlists."
        FAILED_TOOLS+=("Auto_Wordlists")
    fi
    if wget https://download.weakpass.com/wordlists/1927/cyclone.hashesorg.hashkiller.combined.txt.7z -P ./AddWL; then
        echo "[+] Weakpass cyclone wordlist downloaded."
        SUCCESS_TOOLS+=("Weakpass cyclone list")
    else
        echo "[!] Failed to download Weakpass cyclone wordlist."
        FAILED_TOOLS+=("Weakpass cyclone list")
    fi

    read -p "Install Huge Passwordlists and Rainbowtables (approx. 400GB)?(y/n) " wrdboolean
    if [[ "$wrdboolean" =~ ^([yY][eE][sS]|[yY]|[jJ][aA])$ ]]; then
        mkdir -p ./HugeWL
        if wget https://download.weakpass.com/wordlists/all-in-one/1/all_in_one.7z -P ./HugeWL &&
           wget https://crackstation.net/files/crackstation.txt.gz -P ./HugeWL; then
            echo "[+] Huge lists downloaded."
            SUCCESS_TOOLS+=("Huge wordlists and rainbowtables")
        else
            echo "[!] Failed to download all huge lists."
            FAILED_TOOLS+=("Huge wordlists and rainbowtables")
        fi
    else
        echo "Skipping Huge List"
        sleep 1
    fi
else
    echo "Skipping additional wordlists."
fi

######################################
# Autoremove unnecessary packages
######################################
sudo apt autoremove -y

######################################
# Summary
######################################
echo
echo "========================================"
echo "   INSTALLATION SUMMARY"
echo "========================================"
echo "Successfully installed:"
for tool in "${SUCCESS_TOOLS[@]}"; do
  echo "  [+] $tool"
done

echo
echo "Failed to install:"
for tool in "${FAILED_TOOLS[@]}"; do
  echo "  [!] $tool"
done
echo "========================================"
echo
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
