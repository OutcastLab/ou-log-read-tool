# ou-log-read-tool

A lightweight, defensive command-line tool that analyzes **Apache** and **Nginx** access logs and flags common web-attack indicators. It runs on Kali Linux (and other Debian/Ubuntu/RHEL systems), auto-detects the real log paths, and can also analyze any file or folder you point it to.

> **Note:** findings are heuristic indicators, not proof that an attack succeeded. Always review flagged requests manually.

## Features

- Auto-detects default Apache and Nginx access-log locations
- Analyze a specific file (`-f`) or every log inside a folder (`-d`)
- Reads rotated (`access.log.1`) and compressed (`access.log.2.gz`) logs
- Decodes URL-encoded payloads (up to 3 rounds) to catch obfuscated requests
- Also inspects the `User-Agent` field (scanner tools usually reveal themselves there)
- Colored terminal output, with an option to save a clean text report
- Summary of indicators by type and the top offending IP addresses
- No external dependencies, only Python 3 standard library

## Detected indicators

| Indicator | Severity | Examples |
|---|---|---|
| SQL Injection | High | `UNION SELECT`, `OR 1=1`, `sleep(`, `benchmark(` |
| Cross-Site Scripting (XSS) | High | `<script>`, `javascript:`, `onerror=`, `onload=` |
| Path Traversal | High | `../`, `/etc/passwd`, `/proc/self/environ`, `boot.ini` |
| Command Injection | High | `; cat`, `\| bash`, backticks, `$(...)` |
| Sensitive File / Admin Discovery | Medium | `.env`, `.git/config`, `wp-config.php`, `phpmyadmin`, `/admin` |
| Suspicious Scanner / Tool | Medium | `sqlmap`, `nikto`, `nmap`, `masscan`, `gobuster`, `dirbuster`, `wpscan`, `hydra` |

## Requirements

- Python 3.6+
- Read access to the log files (usually requires `sudo`)

## Installation

```bash
git clone https://github.com/<your-username>/ou-log-read-tool.git
cd ou-log-read-tool
chmod +x install.sh
sudo ./install.sh
```

This copies the tool to `/usr/local/bin`, so you can run it by name from anywhere.

To uninstall:

```bash
sudo ./install.sh uninstall
```

**Run without installing:**

```bash
sudo python3 ou-log-read-tool
```

## Usage

```bash
sudo ou-log-read-tool [options]
```

| Option | Description |
|---|---|
| *(no options)* | Auto-detect Apache and Nginx logs |
| `-f`, `--file FILE` | Analyze a specific log file (can be used several times) |
| `-d`, `--dir DIR` | Analyze all log files inside a directory (can be repeated) |
| `-s`, `--server {apache,nginx,all}` | Choose which web server's default logs to read (default: `all`) |
| `-a`, `--all` | With auto-detect: also read rotated (`.1`) and compressed (`.gz`) logs |
| `-o`, `--output FILE` | Save the report to a file (without colors) |
| `--show-clean` | Also print lines with no detected indicators |
| `--no-color` | Disable colored output |
| `-q`, `--quiet` | Do not print the banner |
| `-v`, `--version` | Show the version |
| `-h`, `--help` | Show help |

### Examples

```bash
# Auto-detect and analyze default logs
sudo ou-log-read-tool

# Nginx only, including rotated and compressed logs
sudo ou-log-read-tool -s nginx -a

# A specific file
sudo ou-log-read-tool -f /var/log/apache2/access.log

# Several files, saved to a report
sudo ou-log-read-tool -f access1.log -f access2.log -o report.txt

# Every log inside a folder
sudo ou-log-read-tool -d /var/log/apache2/
```

### Default log paths

| Server | Path |
|---|---|
| Apache | `/var/log/apache2/access.log` |
| Apache (virtual hosts) | `/var/log/apache2/other_vhosts_access.log` |
| Apache (RHEL/CentOS) | `/var/log/httpd/access_log` |
| Nginx | `/var/log/nginx/access.log` |

## Sample output

```text
[*] Analyzing access.log

[ALERT] access.log | Line: 1
  IP:      192.168.1.5
  Status:  200
  Request: GET /index.php?id=1%27%20OR%201=1-- HTTP/1.1
  Decoded: GET /index.php?id=1' OR 1=1-- HTTP/1.1
  Agent:   Mozilla/5.0
  Attack indicator: SQL Injection | Severity: High

========== SUMMARY ==========
Files analyzed: 1/1
Lines read: 3
Lines with alerts: 1
Indicators by type:
  SQL Injection: 1
IPs with most alerts:
  192.168.1.5: 1
```

## Testing on your own machine

If the log files are empty, no requests have reached the server yet. Start the server and send test requests to **your own** localhost:

```bash
sudo systemctl start apache2

curl -s "http://localhost/index.php?id=1' OR 1=1--" > /dev/null
curl -s "http://localhost/?q=<script>alert(1)</script>" > /dev/null
curl -s --path-as-is "http://localhost/../../etc/passwd" > /dev/null
curl -s -A "sqlmap/1.7" "http://localhost/" > /dev/null

sudo ou-log-read-tool -s apache
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `Permission denied` | Run with `sudo` |
| `No log files found` | Start the web server, or pass a path with `-f` / `-d` |
| `Lines read: 0` | The log is empty, send some requests to the server first |
| `unsupported log format` | The log is not in Apache/Nginx *combined* format |

## Limitations

- Pattern-based detection can produce false positives and false negatives
- Supports the standard Apache/Nginx *common* and *combined* log formats only
- Analyzes access logs only, not error logs, SSH logs, or `auth.log`
- Analyzes logs after the fact, it does not block attacks

## Disclaimer

This tool is intended for **defensive analysis** of logs from systems you own or are authorized to monitor. Only use it on systems and logs you have permission to access.

## License

Add a license of your choice (for example MIT) in a `LICENSE` file.
