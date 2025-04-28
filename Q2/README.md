# Q2: Troubleshooting Internal Web Dashboard Connectivity

---

## Scenario

The internal dashboard at `internal.example.com` is up but cannot be reached from multiple systems ("host not found"). This guide walks through verifying DNS, testing service reachability, listing possible causes, applying fixes, and bonus steps for testing and persistence.

---

## 1. Verify DNS Resolution

1. **System resolver:**
   ```bash
   dig internal.example.com
   ```

2. **Google DNS:**
   ```bash
   dig @8.8.8.8 internal.example.com
   ```

Compare results to see if your DNS or upstream resolver is misconfigured.  
(Screenshot: `../screenshots/dns_resolution.png`)

---

## 2. Diagnose Service Reachability

1. **HTTP (port 80):**
   ```bash
   curl -I http://internal.example.com
   ```

2. **HTTPS (port 443):**
   ```bash
   curl -I https://internal.example.com
   ```

3. **Alternate check:**
   ```bash
   telnet internal.example.com 80
   telnet internal.example.com 443
   ```

(Screenshot: `service_reachability.png`)

---

## 3. Possible Causes

- Wrong DNS settings in `/etc/resolv.conf`
- Internal DNS server down or unreachable
- Firewall blocking DNS or HTTP/S
- Service not listening on expected ports
- Bad entry in `/etc/hosts`
- Expired or invalid SSL certificate (in case  of HTTPS reachability issue)

---

## 4. Proposed Fixes

### a. DNS Misconfiguration
- **Confirm:**
  ```bash
  cat /etc/resolv.conf
  dig internal.example.com
  ```
- **Fix:**
  ```bash
  # Edit resolv.conf
  sudo nano /etc/resolv.conf

  # Or persist via systemd-resolved:
  sudo sed -i 's/^#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved
  ```

### b. Internal DNS Down
- **Confirm: (e.g. 127.0.0.54 is dns server ip)**
  ```bash
  ping 127.0.0.54
  dig @127.0.0.54 internal.example.com
  ```
- **Fix:**
  ```bash
  sudo systemctl restart named   # or dnsmasq, bind9, etc.
  ```

### c. Firewall Blocking
- **Confirm:**
  ```bash
  sudo ufw status
  sudo iptables -L -n
  ```
- **Fix:**
  ```bash
  sudo ufw allow 53,80,443/tcp
  ```

### d. Service Not Listening
- **Confirm:**
  ```bash
  ss -tuln | grep ':80\|:443'
  ```
- **Fix:**
  ```bash
  sudo systemctl restart apache2   # or nginx
  ```

### e. Hosts File Override
- **Confirm:**
  ```bash
  grep internal.example.com /etc/hosts
  ```
- **Fix:**
  ```bash
  sudo sed -i '/internal\.example\.com/d' /etc/hosts
  ```

### f. SSL Certificate Issues
- **Confirm:**
  ```bash
  openssl s_client -connect internal.example.com:443
  ```
- **Fix:**
  ```bash
  # Renew or replace cert, then reload web server:
  sudo certbot renew   # if using Certbot
  sudo systemctl reload nginx   # or apache2
  ```

---

## Bonus

- **Hosts Override:**
  ```bash
  echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts
  ```

---

_End of README.md_

