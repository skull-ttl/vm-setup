# Trave Tricksters Legion - CTF Auto-Installer
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Shell: bash](https://img.shields.io/badge/Shell-bash-4EAA25)
![OS: Ubuntu/Debian](https://img.shields.io/badge/OS-Ubuntu%2FDebian-informational)

![TTL Logo](ttl_logo.png)

---

A **no-nonsense, modern Bash auto-installer** for CTF, pentest, and hacking environments.  
Designed for fast, reproducible setups for new team members or on fresh Linux boxes.

---

## 🚀 Features

- **WaveTerm**: Modern terminal with pre-configured CTF workspace
- **RustDesk**: Secure remote desktop for team collaboration/support
- **Proxychains4 & Tor**: Out-of-the-box tunneling for red team activities
- **PEASS-ng PrivEsc tools**: linpeas, winpeas, and more
- **Metasploit Framework**: Automated install and database sync
- **pimpmykali**: Extra tweaks for pentest environments
- **Optional**: Wordlists, rainbow tables, and password dumps (ask before download!)

---

## ⚡️ Quick Start

1. **Clone this repo or download the installer script:**
    ```bash
    git clone https://github.com/skull-ttl/vm-setup
    cd vm-setup
    chmod +x install.sh
    ```

2. **Run the installer as root (or with sudo):**
    ```bash
    sudo ./install.sh
    ```

    > *You'll be prompted to download optional wordlists (large files).*

3. **(Optional) Customize your WaveTerm workspace:**
    - Edit `~/.waveterm/workspaces/ctf-default.yaml` after install if you want your own aliases, colors, or blocks.

---

## 🖥️ Requirements

- Ubuntu/Debian Linux (tested on latest LTS)
- 10GB+ disk space (more if you grab wordlists)
- Internet connection for package downloads

---

## 🔒 Security Notes

- **Never** run random scripts from the Internet as root unless you’ve read them.
- This script installs from official repos and trusted sources, but always check what you’re running.
- **No secrets, passwords, or sensitive info** should be added to this repo (see `.gitignore`).

---

## 🛠️ What Gets Installed

| Tool           | Purpose                    | Install Method            |
|----------------|---------------------------|--------------------------|
| WaveTerm       | Modern terminal            | Snap                     |
| RustDesk       | Remote desktop             | GitHub `.deb` release    |
| Proxychains4   | Proxy routing              | apt                      |
| Tor            | Anonymity/Tor routing      | apt                      |
| PEASS-ng       | Privilege escalation       | GitHub                   |
| Metasploit     | Exploitation framework     | apt, msfupdate           |
| pimpmykali     | Extra pentest tweaks       | GitHub                   |
| flameshot      | Screenshot tool            | apt                      |

*...and more. See `install.sh` for details.*

---

## 💡 Customization

- Put your own links in `links.txt`
- Adjust wordlist options for your storage needs
- Add more tools as needed—forks and PRs welcome!

---

## 📚 Credits & References

- [WaveTerm](https://www.waveterm.dev/)
- [RustDesk](https://rustdesk.com/)
- [PEASS-ng](https://github.com/carlospolop/PEASS-ng)
- [Metasploit](https://www.metasploit.com/)
- [pimpmykali](https://github.com/Dewalt-arch/pimpmykali)
- [Proxychains4](https://github.com/haad/proxychains)
- [Weakpass](https://weakpass.com/)
- [Crackstation](https://crackstation.net/)
- [SSLLabs](https://www.ssllabs.com/)

---

## 🤝 Contributing

PRs, issues, and feedback are welcome!  
Help us make the ultimate CTF starter kit for new hackers and seasoned pros alike.

---

## ⚠️ Disclaimer

For legal, educational, and ethical use only.  
The Trave Tricksters Legion and script contributors take **no responsibility for misuse**.

---

**Happy hacking!**  
*— The Trave Tricksters Legion CTF Team*
