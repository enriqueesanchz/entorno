cat > /tmp/miconf <<EOF
# config file for openfortivpn, see man openfortivpn(1)
host=95.60.241.174
port=10445
username=$vpn_user
password=$vpn_password
trusted-cert=2341484be0f5a5dd30335297badbfc6fcd3195f33e7286e1e5b71cd50d5035cc
EOF
sudo cp /tmp/miconf /etc/openfortivpn/config
sudo openfortivpn  --otp=$1
