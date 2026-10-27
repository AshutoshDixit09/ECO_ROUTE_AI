#!/usr/bin/env bash
# ==============================================================================
# EcoRoute AI 25% Prototype - Ubuntu/WSL2 Automated Setup Script
# ==============================================================================
# This script installs Mininet, Open vSwitch, Python dependencies, and Ryu
# on an Ubuntu system (native or WSL2).
#
# Usage:
#   chmod +x setup_ubuntu.sh
#   ./setup_ubuntu.sh
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "  EcoRoute AI 25% Prototype - Environment Setup"
echo "=========================================================="

# 1. Update APT and install Linux networking tools + Mininet + Open vSwitch
echo "[1/4] Installing Mininet, Open vSwitch, and system utilities..."
sudo apt-get update -qq
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    mininet \
    openvswitch-switch \
    net-tools \
    iperf \
    iproute2

# 2. Ensure Open vSwitch service is running
echo "[2/4] Starting Open vSwitch daemon..."
sudo service openvswitch-switch start || sudo systemctl start openvswitch-switch || true
sudo ovs-vsctl show || true

# 3. Install core Python dependencies
echo "[3/4] Installing Python requirements..."
pip3 install --upgrade pip
pip3 install -r requirements.txt

# 4. Install Ryu SDN Controller
echo "[4/4] Installing Ryu SDN Controller..."
# Install modern Ryu fork compatible with Python 3.10/3.11/3.12
pip3 install git+https://github.com/faucetsdn/ryu.git

echo ""
echo "=========================================================="
echo "  Setup Complete! To verify the environment:"
echo "=========================================================="
echo "1. Run unit tests:"
echo "     pytest -v"
echo ""
echo "2. Run the routing comparison experiment:"
echo "     python3 experiments/compare_routes.py"
echo ""
echo "3. Run live Mininet + Ryu emulation (in two separate terminals):"
echo "     Terminal A (SDN Controller):"
echo "       ryu-manager controller/ryu_app.py ryu.app.ofctl_rest"
echo ""
echo "     Terminal B (Mininet Topology):"
echo "       sudo python3 topo/topology.py"
echo ""
echo "     Terminal C (Telemetry Polling):"
echo "       python3 telemetry/collector.py"
echo "=========================================================="
