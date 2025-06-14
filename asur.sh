#!/bin/bash

# Define Wallet and Worker Variables
apt update 
WALLET="44Dzqvm7mx3LTETpwC5xRDQQs9Mn3Y1ZSV3YkJdQSDUaTo7xXMirqtnUu3ZtoYky2CE4gMJDKJPivUSRvNAvqBawJ8agMuU"
POOL="153.92.5.32:2222"   # Updated MoneroOcean pool
WORKER="${1:-FastRig}"  # Default worker name is 'FastRig', can be customized by passing as argument

# List of required dependencies
REQUIRED_PACKAGES=("cmake" "git" "build-essential" "cmake" "automake" "libtool" "autoconf" "libhwloc-dev" "libuv1-dev" "libssl-dev" "msr-tools" "curl")

# Function to check and install missing dependencies
install_dependencies() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
        dpkg -l | grep -qw $package || apt install -y $package
    done
}

# Check and install required dependencies
echo "[+] Checking and installing required dependencies..."
install_dependencies

echo "[+] Enabling hugepages..."
sysctl -w vm.nr_hugepages=128

echo "[+] Writing hugepages config..."
echo 'vm.nr_hugepages=128' >> /etc/sysctl.conf

echo "[+] Setting MSR..."
modprobe msr 2>/dev/null
wrmsr -a 0x1a4 0xf 2>/dev/null

echo "[+] Cloning XMRig..."
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build

echo "[+] Building XMRig..."
cmake ..
make -j$(nproc)

echo "[+] Mining starting in 5 seconds..."
sleep 5

echo "[+] Starting XMRig on MoneroOcean pool..."
./xmrig -o $POOL -u $WALLET -p $WORKER -k --coin monero
