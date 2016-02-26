# openvpn-utils
Misc. utilities for using with OpenVPN

## extract_ovpn_unified.sh
Tool for extracting certificates and keys from the unified .ovpn file.

If your sysadmin hands you a .ovpn file and says you need this to connect to
the company VPN and like me you use network-manager-openvpn-gnome for connecting
to VPN's, then this script can help you converting the unified .ovpn to a .ovpn file
with pointers to separate certificate and key files which is what my version of 
network-manager-openvpn-gnome expects.
