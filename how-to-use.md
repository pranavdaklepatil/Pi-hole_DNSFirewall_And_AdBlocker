# 🧭 Pi-hole Usage Guide

A comprehensive guide to configuring, managing, and optimizing your Pi-hole DNS Firewall for maximum network protection.

---

## 📋 Table of Contents

- [Initial Configuration](#-initial-configuration)
- [Device DNS Setup](#-device-dns-setup)
- [Custom Blocklists](#-custom-blocklists)
- [Advanced Features](#-advanced-features)
- [Monitoring & Analysis](#-monitoring--analysis)
- [Troubleshooting](#-troubleshooting)

---

## 🔧 Initial Configuration

### Access Pi-hole Admin Dashboard

1. Open your web browser and navigate to:
   ```
   http://YOUR_PIHOLE_IP/admin
   ```
   or
   ```
   http://pi.hole/admin
   ```

2. Log in using the password displayed during installation

---

## 📱 Device DNS Setup

### Important: Enable Universal Access

Before configuring devices, ensure Pi-hole accepts DNS queries from all sources:

<div align="center">

![Pi-hole Advanced DNS Settings](images/pihole-advanced-dns.png)
*Navigate to Settings → DNS → Advanced DNS Settings*

</div>

1. Go to **Settings** → **DNS** → **Interface Settings**
2. Select **"Permit all origins"** or **"Allow only local requests"** based on your network setup
3. Click **Save**

---

### 🪟 Windows DNS Configuration

<div align="center">

![Windows DNS Settings](images/windows-dns-setup.png)
*Windows Network Adapter DNS Configuration*

</div>

**Step-by-Step Instructions:**

1. Press `Win + R` and type `ncpa.cpl` → Press Enter
2. Right-click on your active network adapter → **Properties**
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → **Properties**
4. Select **"Use the following DNS server addresses"**
5. Enter:
   - **Preferred DNS server**: `YOUR_PIHOLE_IP` (e.g., `192.168.1.100`)
   - **Alternate DNS server**: `8.8.8.8` (Google DNS as fallback)
6. Click **OK** → **Close**

**Verify Configuration:**
```cmd
ipconfig /all
```

Look for your Pi-hole IP under "DNS Servers"

---

### 📱 Mobile Device Configuration (Android/iOS)

<div align="center">

![Mobile DNS Settings](images/mobile-dns-setup.png)
*Android/iOS Wi-Fi DNS Configuration*

</div>

#### Android:
1. Open **Settings** → **Wi-Fi**
2. Long-press your connected network → **Modify Network**
3. Tap **Advanced Options** → **IP Settings** → Select **Static**
4. Scroll down to **DNS 1** → Enter `YOUR_PIHOLE_IP`
5. **DNS 2** → Enter `8.8.8.8` (fallback)
6. Tap **Save**

#### iOS:
1. Open **Settings** → **Wi-Fi**
2. Tap the **(i)** icon next to your connected network
3. Scroll to **Configure DNS** → Select **Manual**
4. Tap **Add Server** → Enter `YOUR_PIHOLE_IP`
5. Tap **Save**

---

### 🌐 Router-Wide DNS Configuration (Recommended)

**Benefits:**
- Automatically applies to all devices on the network
- No need to configure individual devices
- Captures DNS from IoT devices and Smart TVs

**Steps:**
1. Access your router admin panel (typically `192.168.1.1` or `192.168.0.1`)
2. Navigate to **LAN Settings** or **DHCP Settings**
3. Find **Primary DNS** or **DNS Server** settings
4. Set **Primary DNS** to `YOUR_PIHOLE_IP`
5. Set **Secondary DNS** to `8.8.8.8` (optional fallback)
6. **Save** and **Reboot** your router

<div align="center">

![Router DNS Settings](images/router-dns-setup.png)
*Example: Router DHCP DNS Configuration*

</div>

---

## 🛡️ Custom Blocklists

### Adding High-Quality Blocklists

Navigate to: **Settings** → **Adlists** → **Add a new adlist**

<div align="center">

![Blocklist Management](images/add-blocklist.png)
*Pi-hole Adlist Configuration Interface*

</div>

#### Recommended Security Blocklists:

**Category: General Ads & Tracking**
```
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
```

**Category: Malware & Phishing**
```
https://urlhaus.abuse.ch/downloads/hostfile/
```

**Category: Crypto Mining**
```
https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
```

**Category: Pro-Privacy (Hagezi)**
```
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt
```

**Category: Social Media Tracking**
```
https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts
```

---

### Update Gravity Database

After adding blocklists, update Pi-hole's blocking database:

1. Navigate to **Tools** → **Update Gravity**
2. Click **Update**
3. Wait for the process to complete

**Or via CLI:**
```bash
docker exec pihole pihole -g
```

---

## ⚙️ Advanced Features

### 1️⃣ Per-Device Blocking Policies

Create custom blocking rules for different device types.

**Use Case Example:**
- Block YouTube on Smart TV
- Allow YouTube on Laptop
- Block Social Media on Kids' devices

**Steps:**

1. Navigate to **Group Management** → **Groups**
2. Click **Add a new group**
   - Name: `Kids Devices`
   - Description: `Restricted access for children`
3. Go to **Group Management** → **Clients**
4. Assign devices to the `Kids Devices` group
5. Go to **Group Management** → **Domains**
6. Add domains to block (e.g., `youtube.com`, `instagram.com`)
7. Assign these domains to the `Kids Devices` group

---

### 2️⃣ Time-Based Blocking (Using Cron Jobs)

Automatically enable/disable Pi-hole at specific times.

**Example: Disable Pi-hole at 10 PM, Enable at 6 AM**

```bash
# Edit crontab
crontab -e
```

Add these lines:
```bash
# Disable Pi-hole at 10 PM every day
0 22 * * * docker exec pihole pihole disable

# Enable Pi-hole at 6 AM every day
0 6 * * * docker exec pihole pihole enable
```

**Alternative: Disable for specific duration**
```bash
# Disable for 30 minutes
docker exec pihole pihole disable 30m
```

---

### 3️⃣ Whitelist Essential Domains

Some legitimate services may be blocked. Whitelist them:

**Via Admin Dashboard:**
1. Go to **Whitelist** → **Domains**
2. Enter the domain (e.g., `s.youtube.com`)
3. Click **Add to Whitelist**

**Via CLI:**
```bash
docker exec pihole pihole -w s.youtube.com
```

**Common Domains to Whitelist:**
```
s.youtube.com           # YouTube thumbnails
graph.facebook.com      # Facebook features
clients4.google.com     # Google connectivity check
```

---

### 4️⃣ Local DNS Records (Custom Domains)

Map custom domains to local IP addresses.

**Example: Access router admin via custom domain**

1. Navigate to **Local DNS** → **DNS Records**
2. Add:
   - **Domain**: `router.local`
   - **IP Address**: `192.168.1.1`
3. Click **Add**

Now access your router via `http://router.local`

---

## 📊 Monitoring & Analysis

### 1️⃣ Real-Time Dashboard

The main dashboard provides:
- Total queries in the last 24 hours
- Queries blocked percentage
- Domains on blocklist
- Top blocked domains
- Top clients

<div align="center">

![Pi-hole Dashboard](images/dashboard-stats.png)
*Real-time Network Statistics*

</div>

---

### 2️⃣ Query Log Analysis

**Navigate to:** Tools → Query Log

**Features:**
- View all DNS queries in real-time
- Filter by domain, client, or status
- Identify suspicious/unwanted traffic
- Whitelist or blacklist domains directly

<div align="center">

![Query Log](images/query-log-analysis.png)
*Live DNS Query Monitoring*

</div>

---

### 3️⃣ Long-Term Statistics

**Navigate to:** Tools → Long-term Data

View historical data:
- Queries over time
- Top domains
- Top clients
- Blocking trends

---

### 4️⃣ Export Logs for Advanced Analysis

**Export to Python/Pandas:**
```bash
docker exec pihole cat /var/log/pihole.log > pihole_queries.log
```

**Export to JSON:**
```bash
docker exec pihole pihole -t | jq > queries.json
```

**Integrate with ELK Stack or Grafana** for advanced visualization and alerting.

---

## 🔍 Troubleshooting

### Verify DNS Resolution

**Test from client device:**

**Linux/macOS:**
```bash
nslookup google.com
dig google.com
```

**Windows:**
```cmd
nslookup google.com
```

Expected output should show your Pi-hole IP as the DNS server.

---

### Check Pi-hole Status

```bash
docker exec pihole pihole status
```

**Expected Output:**
```
[✓] DNS service is running
[✓] Pi-hole blocking is enabled
```

---

### Restart Pi-hole Service

```bash
docker restart pihole
```

---

### Clear DNS Cache (Client-side)

**Windows:**
```cmd
ipconfig /flushdns
```

**Linux:**
```bash
sudo systemd-resolve --flush-caches
```

**macOS:**
```bash
sudo dscacheutil -flushcache
```

---

### Pi-hole Not Blocking Ads?

1. **Verify device DNS** is pointing to Pi-hole
2. **Update Gravity** database
3. **Check blocklists** are active
4. Some apps use **hardcoded DNS** (e.g., Netflix, YouTube app) – requires firewall rules to force DNS
5. Enable **DNSSEC** if needed

---

## 📚 Additional Resources

- **Official Pi-hole Documentation**: [https://docs.pi-hole.net](https://docs.pi-hole.net)
- **Community Forums**: [https://discourse.pi-hole.net](https://discourse.pi-hole.net)
- **Blocklist Collections**: [https://firebog.net](https://firebog.net)

---

## 🎯 Best Practices

✅ **Regularly update blocklists** (weekly recommended)  
✅ **Monitor query logs** for false positives  
✅ **Maintain a whitelist** for essential services  
✅ **Use router-level DNS** for automatic coverage  
✅ **Enable DNSSEC** for secure DNS validation  
✅ **Backup your configuration** regularly  

---

## 📄 Custom Blocklists Reference

Save this as `blocklists/custom-blocklists.txt`:

```txt
# ==================================
# Pi-hole Custom Blocklists
# ==================================

# ---- MALWARE & PHISHING ----
https://urlhaus.abuse.ch/downloads/hostfile/
https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/malware

# ---- ADS & TRACKING ----
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt

# ---- CRYPTO MINING ----
https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser

# ---- SOCIAL MEDIA TRACKING ----
https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts

# ---- GAMBLING & ADULT CONTENT ----
https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts

# ---- TELEMETRY (Microsoft, Samsung, Xiaomi) ----
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
```

---

Made with ❤️ for a safer, ad-free internet.