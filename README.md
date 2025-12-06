# 🔪 THC Scalpel - Stealth Reconnaissance Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![PowerShell 5.1+](https://img.shields.io/badge/powershell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/hackteam-red/thc-scalpel/graphs/commit-activity)

**Automated stealth reconnaissance toolkit powered by [ip.thc.org](https://ip.thc.org) API**

---

## 🙏 Tribute to The Hacker's Choice

This project is built with deep respect and gratitude to **The Hacker's Choice (THC)** - one of the most legendary hacker groups in the history of information security.

Since **1995**, THC has been at the forefront of security research, tool development, and knowledge sharing. Their contributions include:

- 🛠️ **Legendary tools**: THC-Hydra, THC-SSL-DOS, THC-IPv6, and many more
- 📚 **Research papers**: Groundbreaking security research and advisories
- 🌐 **Community building**: Fostering collaboration and learning
- 🆓 **Open philosophy**: Making powerful tools freely available

Their latest service, **[ip.thc.org](https://ip.thc.org)**, continues this tradition by providing:

- 🌍 Reverse DNS data for the entire internet
- 🔍 Subdomain enumeration from massive datasets
- 🔗 CNAME tracking for infrastructure mapping
- 📦 **Monthly bulk dumps** with ~4.75 billion records (!)

**All completely free and open.** This is the gold standard for OSINT services in 2025.

> *"This is how OSINT tools should be - powerful, free, and community-driven, not another $199/month SaaS trap."*

---

## 🎯 What is THC Scalpel?

**THC Scalpel** is a surgical precision reconnaissance toolkit designed for red team operations, penetration testing, and bug bounty hunting. It automates and streamlines the reconnaissance phase by leveraging the ip.thc.org API with advanced stealth capabilities.

### ⚡ Key Features

| Feature | Description |
|---------|-------------|
| 🔄 **Reverse DNS** | IP to hostname resolution for single IPs or entire subnets |
| 🌐 **Subdomain Discovery** | Comprehensive subdomain enumeration |
| 🔗 **CNAME Lookup** | Find domains pointing to your target infrastructure |
| 🚀 **Bulk Operations** | Parallel processing with configurable threading |
| 🥷 **Stealth Mode** | Customizable delays and rate limiting for OPSEC |
| 🎯 **Smart Filtering** | Keyword-based filtering (admin, dev, staging, etc.) |
| 📊 **Multiple Formats** | JSON, CSV, XML output support |
| 🖥️ **Cross-Platform** | Python 3.8+ and PowerShell 5.1+ |

---

## 🔒 Public vs Private Tools

For **ethical and operational security reasons**, we are open-sourcing only **2 of 4 tools** from our internal arsenal:

### ✅ Public Release (This Repository)

| Tool | Description | Status |
|------|-------------|--------|
| `thc-scalpel.py` | Python reconnaissance tool | ✅ Open Source |
| `thc-scalpel.ps1` | PowerShell version for Windows | ✅ Open Source |

### 🔐 Private (hackteam.red Internal Use Only)

| Tool | Description | Status |
|------|-------------|--------|
| **Bulk Dump Analyzer** | DuckDB-powered analysis of 4.75B+ records | 🔒 Proprietary |
| **Framework Integration** | Metasploit, Nuclei, Nmap, Amass integrations | 🔒 Proprietary |

These advanced tools remain proprietary to **[hackteam.red](https://hackteam.red)** for authorized client engagements only.

---

## 📦 Installation

### Prerequisites

**Python Version:**
```bash
# Python 3.8 or higher required
python --version

# Install dependencies
pip install requests
```

**PowerShell Version:**
```powershell
# PowerShell 5.1+ (built into Windows 10/11)
$PSVersionTable.PSVersion

# No additional dependencies required
```

### Clone Repository

```bash
git clone https://github.com/toxy4ny/thc-scalpel.git
cd thc-scalpel
chmod +x thc-scalpel.py
```

---

## 🚀 Quick Start

### Python Examples

```bash
# Single IP reverse DNS
python thc-scalpel.py -i 140.82.121.3

# Subnet scan
python thc-scalpel.py -s 140.82.121.0/24

# Subdomain enumeration
python thc-scalpel.py -d github.com -o subdomains.json

# CNAME lookup
python thc-scalpel.py -c pages.github.com

# Bulk reconnaissance from file
python thc-scalpel.py -f targets.txt -t ip -o results.json

# Stealth mode with keyword filtering
python thc-scalpel.py -d example.com \
    -k admin,dev,test,staging,internal \
    --delay 2.0 \
    --threads 3 \
    -o interesting_targets.json
```

### PowerShell Examples

```powershell
# Single IP reverse DNS
.\thc-scalpel.ps1 -Target "140.82.121.3" -Type rdns

# Subdomain discovery
.\thc-scalpel.ps1 -Target "github.com" -Type subdomain -OutputFile results.json

# Bulk operations
.\thc-scalpel.ps1 -InputFile targets.txt -Type rdns -Delay 1 -Threads 3

# Stealth mode
.\thc-scalpel.ps1 -InputFile domains.txt -Type subdomain -Stealth -OutputFile results.csv

# Keyword filtering
.\thc-scalpel.ps1 -Target "example.com" -Type subdomain `
    -Keywords "admin,dev,test" `
    -OutputFile filtered.json
```

---

## 📖 Usage Guide

### Command Line Options (Python)

```
usage: thc-scalpel.py [-h] [-i IP] [-s SUBNET] [-d DOMAIN] [-c CNAME]
                      [-f FILE] [-t {ip,domain}] [-o OUTPUT]
                      [-k KEYWORDS] [--format {json,csv}]
                      [--delay DELAY] [--threads THREADS] [--timeout TIMEOUT]

Options:
  -i, --ip IP           Single IP address for reverse DNS
  -s, --subnet SUBNET   Subnet in CIDR notation (e.g., 192.168.1.0/24)
  -d, --domain DOMAIN   Domain for subdomain enumeration
  -c, --cname CNAME     Domain for CNAME lookup
  -f, --file FILE       File with list of targets
  -t, --type TYPE       Target type: ip or domain
  -o, --output OUTPUT   Output file (JSON/CSV)
  -k, --keywords KEYWORDS   Filter keywords (comma-separated)
  --format FORMAT       Output format: json or csv
  --delay DELAY         Delay between requests (seconds, default: 0.5)
  --threads THREADS     Number of threads (default: 5)
  --timeout TIMEOUT     Request timeout (seconds, default: 30)
```

### Command Line Options (PowerShell)

```powershell
PARAMETERS:
  -Target <String>          Target IP, domain, or subnet
  -Type <String>            Operation type: rdns, subdomain, cname, subnet
  -InputFile <String>       File with list of targets
  -OutputFile <String>      Output file path
  -Delay <Double>           Delay between requests (default: 0.5)
  -Threads <Int>            Number of parallel threads (default: 5)
  -Keywords <String>        Filter keywords (comma-separated)
  -Timeout <Int>            Request timeout in seconds (default: 30)
  -Stealth                  Enable stealth mode (slower, safer)
  -Verbose                  Enable verbose output
```

---

## 🎓 Real-World Scenarios

### Scenario 1: Attack Surface Expansion

```bash
#!/bin/bash
TARGET="target-company.com"

# Step 1: Discover all subdomains
python thc-scalpel.py -d $TARGET -o step1_subdomains.json

# Step 2: Filter high-value targets
python thc-scalpel.py -d $TARGET \
    -k admin,dev,test,staging,api,internal,vpn \
    -o step2_high_value.json

# Step 3: Export for further scanning
cat step2_high_value.json | jq -r '.[] | .data[]' | awk '{print $2}' > targets_for_nmap.txt
```

### Scenario 2: Shadow Infrastructure Discovery

```bash
# Find forgotten/legacy systems
python thc-scalpel.py -d target.com \
    -k old,legacy,backup,archive,deprecated,obsolete \
    -o shadow_infrastructure.json

# Discover dev/test environments (often poorly secured)
python thc-scalpel.py -d target.com \
    -k dev,test,staging,qa,demo,sandbox,uat \
    -o dev_environments.json

# Find internal services
python thc-scalpel.py -d target.com \
    -k internal,intranet,vpn,private,corp,employee \
    -o internal_services.json
```

### Scenario 3: Bug Bounty Reconnaissance

```bash
TARGET="bugbounty-program.com"

# Comprehensive subdomain discovery
python thc-scalpel.py -d $TARGET -o all_subdomains.json

# Find interesting endpoints
python thc-scalpel.py -d $TARGET -k api,admin,upload,dashboard -o endpoints.json

# CNAME lookup for subdomain takeover
for sub in $(cat all_subdomains.json | jq -r '.[] | .data[]' | awk '{print $2}'); do
    python thc-scalpel.py -c $sub -o "cname_check_${sub}.json"
done
```

### Scenario 4: Shared Hosting Enumeration

```bash
TARGET_IP="192.168.1.100"

# Get the /24 subnet
SUBNET=$(echo $TARGET_IP | cut -d. -f1-3).0/24

# Scan entire subnet
python thc-scalpel.py -s $SUBNET -o hosting_neighbors.json

# Extract all unique domains
cat hosting_neighbors.json | jq -r '.[] | .data[]' | awk '{print $2}' | sort -u > neighbor_domains.txt
```

---

## 🛡️ OPSEC & Stealth

### Built-in Stealth Features

```bash
# Minimal footprint: 1 thread, 3-second delays
python thc-scalpel.py -f sensitive_targets.txt \
    --threads 1 \
    --delay 3.0 \
    -o results.json

# Moderate stealth: 3 threads, 2-second delays
python thc-scalpel.py -f targets.txt \
    --threads 3 \
    --delay 2.0 \
    -o results.json
```

### Operational Security Best Practices

| ✅ DO | ❌ DON'T |
|-------|----------|
| Use VPN/Tor for API requests | Run from corporate IPs |
| Implement random delays | Hammer API without rate limiting |
| Vary User-Agent strings | Use default configurations |
| Split large operations | Process 10,000 targets at once |
| Monitor your footprint | Ignore detection signatures |
| Test in lab environments first | Go loud on production |

### Advanced OPSEC Techniques

```bash
# 1. Time-based distribution (spread over hours)
for target in $(cat targets.txt); do
    python thc-scalpel.py -d $target -o "results_${target}.json"
    sleep $((RANDOM % 300 + 60))  # Random 1-5 minute delays
done

# 2. Split operations across multiple IPs
split -l 50 targets.txt batch_
# Run each batch from different infrastructure

# 3. Randomize request patterns
# Modify the delay parameter with randomization in the script
```

---

## 📊 Output Examples

### JSON Format

```json
{
  "github.com": {
    "success": true,
    "data": [
      "140.82.121.3 github.com",
      "140.82.121.4 api.github.com",
      "140.82.121.5 assets-cdn.github.com",
      "140.82.121.6 collector.github.com"
    ],
    "count": 4
  }
}
```

### CSV Format

```csv
Target,IP,Hostname
github.com,140.82.121.3,github.com
github.com,140.82.121.4,api.github.com
github.com,140.82.121.5,assets-cdn.github.com
github.com,140.82.121.6,collector.github.com
```

---

## 🔐 Legal & Ethical Use

### ⚠️ CRITICAL DISCLAIMER

THC Scalpel is designed **EXCLUSIVELY** for:

- ✅ **Authorized penetration testing** with written permission
- ✅ **Bug bounty programs** with explicit scope inclusion
- ✅ **Educational purposes** in isolated lab environments
- ✅ **Security research** on your own infrastructure
- ✅ **CTF competitions** and training exercises

### 🚨 Unauthorized Use is Illegal

Using this tool against systems **without explicit permission** is:

- **Illegal** in most jurisdictions
- **Punishable** by criminal prosecution
- **Unethical** and harmful to the security community
- **Against** the spirit of responsible disclosure

### Before Using This Tool, Ensure:

1. 📝 You have **written authorization** from the system owner
2. 🎯 The target is **within the scope** of your engagement
3. 📋 You follow all **rules of engagement** and legal requirements
4. ⏰ You respect **rate limits** and terms of service
5. 🛡️ You have proper **liability coverage** and contracts

**We are not responsible for misuse of this tool. Use responsibly.**

---

## 🏢 About hackteam.red

**[hackteam.red](https://hackteam.red)** is a boutique offensive security firm specializing in advanced adversary simulation and red team operations.

### Our Services

- 🎯 **Advanced Persistent Threat (APT) Simulation**
- 🔴 **Full-Spectrum Red Team Operations**
- 🛡️ **Purple Team Exercises**
- 🔍 **Security Research & Tool Development**
- 🎓 **Training & Knowledge Transfer**

### Our Philosophy

We believe in:

- **Giving back** to the security community
- **Open source** contributions where appropriate
- **Responsible disclosure** and ethical practices
- **Continuous innovation** in offensive security

### Why We Keep Some Tools Private

While we're committed to open source, certain tools remain proprietary because:

1. **Client confidentiality** - Techniques used in engagements must remain exclusive
2. **Operational security** - Public release would enable malicious actors
3. **Competitive advantage** - Our clients pay for cutting-edge capabilities
4. **Legal liability** - Some tools are too powerful for unrestricted distribution

**Interested in our services?**

- 📧 Email: `b0x@hackteam.red`
- 🌐 Website: [hackteam.red](https://hackteam.red)

---

## 🤝 Contributing

We welcome contributions from the community!

### How to Contribute

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. 📤 Push to the branch (`git push origin feature/AmazingFeature`)
5. 🔃 Open a Pull Request

### Contribution Guidelines

- ✅ Bug fixes and improvements
- ✅ Documentation enhancements
- ✅ Performance optimizations
- ✅ New output formats
- ✅ Cross-platform compatibility fixes
- ❌ Malicious features or exploits
- ❌ Breaking changes without discussion
- ❌ Code that violates ethical standards

---

## 📚 Resources & Learning

### THC Resources

- [ip.thc.org Documentation](https://ip.thc.org/docs)
- [THC Official Website](https://www.thc.org/)
- [THC Archive](https://www.thc.org/releases.php)

### Reconnaissance Methodologies

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [PTES Technical Guidelines](http://www.pentest-standard.org/)
- [MITRE ATT&CK - Reconnaissance](https://attack.mitre.org/tactics/TA0043/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### Recommended Tools (Complementary)

- [Amass](https://github.com/OWASP/Amass) - In-depth subdomain enumeration
- [Subfinder](https://github.com/projectdiscovery/subfinder) - Fast subdomain discovery
- [httpx](https://github.com/projectdiscovery/httpx) - HTTP probing
- [Nuclei](https://github.com/projectdiscovery/nuclei) - Vulnerability scanning
- [Nmap](https://nmap.org/) - Network scanning

---

## 🐛 Bug Reports & Issues

Found a bug? Have a suggestion?

1. Check [existing issues](https://github.com/toxy4ny/thc-scalpel/issues)
2. Create a [new issue](https://github.com/toxy4ny/thc-scalpel/issues/new) with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, Python/PowerShell version)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
Copyright (c) 2025 hackteam.red

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=toxy4ny/thc-scalpel&type=Date)](https://www.star-history.com/#toxy4ny/thc-scalpel&type=date&legend=top-left)

---

## 🙏 Acknowledgments

**Special thanks to:**

- **The Hacker's Choice (THC)** - For 30 years of pioneering security research and tool development
- **van Hauser & THC Team** - For creating and maintaining the incredible ip.thc.org service
- **The OSINT Community** - For continuous innovation in reconnaissance techniques
- **Bug Bounty Hunters** - For pushing the boundaries of ethical hacking
- **Open Source Contributors** - For making cybersecurity accessible to everyone

---

## 💬 Community & Support

### Get Help

- 💬 Join discussions in [Issues](https://github.com/toxy4ny/thc-scalpel/issues)
- 🐦 Follow us on [Twitter](https://x.com/toxy4ny)

### Stay Updated

- ⭐ Star this repository
- 👁️ Watch for updates
- 🔔 Enable notifications

---

## 📢 Spread the Word

If you find THC Scalpel useful:

- ⭐ **Star** the repository
- 🔄 **Share** with your network
- 📝 **Write** about your experience
- 🐛 **Report** bugs and issues
- 💡 **Suggest** improvements

**Together, we build better security tools!**

---

<div align="center">

### Made with ❤️ by [hackteam.red](https://hackteam.red)

**Stay curious. Stay ethical. Stay sharp.** 🔪

---

*In honor of The Hacker's Choice - inspiring security researchers since 1995*

[![GitHub followers](https://img.shields.io/github/followers/hackteam-red?style=social)](https://github.com/hackteam-red)

</div>
