#!/bin/bash
set -e

# ==== Step 1. Update OS and install dependencies ====
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git curl wget unzip build-essential tmux htop

# ==== Step 2. Install Node.js (LTS) ====
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v

# ==== Step 3. Install and configure PostgreSQL ====
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Change default postgres password for convenience
# 现在部署的是一个 Node.js + PostgreSQL 同机的服务（MapQaTor backend），
# 所以可以安全地 跳过这个命令，一切照常运行。
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '*******';"

# ==== Step 4. Setup database ====
cd ~
if [ ! -d "mapqator-backend" ]; then
    git clone https://github.com/xinzhel/mapqator-backend.git
fi
cd mapqator-backend

# Create database and apply schema
# 使用系统层面的 postgres 用户。这是安装 PostgreSQL 时，Ubuntu 自动创建一个同名系统账户 -> `sudo -u postgres -i`
# 这个系统用户通常被配置为能自动（无需密码）连接数据库中的同名 role postgres
sudo -u postgres psql -c "CREATE DATABASE mapqator;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mapqator TO postgres;"

# “恢复”数据库
sudo -u postgres psql -d mapqator -a -f database/dump.sql


# ==== Step 5. Setup .env （Already exist） ====
# if [ -f ".env.example" ]; then
#     cp .env.example .env
#     sed -i "s/DB_USER=.*/DB_USER=postgres/" .env
#     sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=postgres/" .env
#     sed -i "s/DB_NAME=.*/DB_NAME=mapqator/" .env
#     sed -i "s/DB_HOST=.*/DB_HOST=localhost/" .env
#     sed -i "s/DB_PORT=.*/DB_PORT=5432/" .env
#     sed -i "s/PORT=.*/PORT=5000/" .env
# fi

# ==== Step 6. Install NPM dependencies ====
npm install

# ==== Step 7. Run backend server in tmux session ====
tmux new-session -d -s mapqator "npm start"

echo "=========================================="
echo " MapQaTor backend setup completed!"
echo " Server is running on: http://<EC2_PUBLIC_IP>:5000"
echo " Use 'tmux attach -t mapqator' to view logs."
echo "=========================================="
