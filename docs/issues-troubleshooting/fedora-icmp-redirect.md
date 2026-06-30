# Fedora Workstation: ICMP Redirect Issue

## Symptom

Intermittent connectivity to lab devices (10.0.x.x). 

First connection succeeds, subsequent connections hang or fail completely. 
Wireshark capture shows `ICMP Redirect Host` messages followed by TCP retransmissions with no response.

## Root Cause

Fedora kernel accepts ICMP Redirects from upstream ISP router, altering local routing to bypass gateway. 
In the nested topology (ISP Router --> OPNsense --> Lab), this causes return traffic drops due to connection state mismatch.

## Solution

Disable ICMP redirect acceptance.

```shell
sudo tee /etc/sysctl.d/99-no-icmp-redirects.conf > /dev/null <<EOF
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.wlp2s0.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.wlp2s0.secure_redirects = 0
EOF
sudo sysctl --system
```

## Validation/Testing 

Monitoring a ping test to lab IP shows consistent replies with no `Redirect` warnings.

1. Confirm the settings above have been applied.

```shell
# Check accept_redirects (should be 0).
cat /proc/sys/net/ipv4/conf/wlp2s0/accept_redirects

# Check secure_redirects (should be 0).
cat /proc/sys/net/ipv4/conf/wlp2s0/secure_redirects
```

2. Setup monitor to tail the kernel log for redirect messages.

```shell
sudo dmesg -w | grep -i "redirect"
```

3. Execute the ping test.

```shell
ping -c 10 10.0.0.250
```
