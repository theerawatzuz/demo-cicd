# 🚀 คู่มือการติดตั้งและ Deploy

## ข้อกำหนดเบื้องต้น

### บน Ubuntu Server

```bash
# ติดตั้ง Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# ติดตั้ง Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# ติดตั้ง Git
sudo apt-get install git
```

## การติดตั้งครั้งแรก

### 1. Clone โปรเจกต์

```bash
sudo mkdir -p /opt/gold-price-api
sudo chown $USER:$USER /opt/gold-price-api
cd /opt/gold-price-api
git clone <your-repo-url> .
```

### 2. ตั้งค่า Deploy Script

```bash
chmod +x deploy.sh
```

### 3. Deploy ครั้งแรก

```bash
./deploy.sh
```

## การใช้งาน Docker

### Build และ Run ด้วย Docker Compose

```bash
# Build และ start
docker-compose up -d

# ดู logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

### Build และ Run ด้วย Docker โดยตรง

```bash
# Build image
docker build -t gold-price-api .

# Run container
docker run -d -p 3000:3000 --name gold-api gold-price-api

# ดู logs
docker logs -f gold-api

# Stop และ remove
docker stop gold-api
docker rm gold-api
```

## การตั้งค่า GitHub Actions CI/CD

### 1. เพิ่ม Secrets ใน GitHub Repository

ไปที่ Settings → Secrets and variables → Actions → New repository secret

เพิ่ม secrets ต่อไปนี้:

- `SERVER_HOST`: IP address หรือ domain ของ server
- `SERVER_USER`: username สำหรับ SSH (เช่น ubuntu)
- `SSH_PRIVATE_KEY`: SSH private key สำหรับเข้าถึง server
- `SERVER_PORT`: SSH port (ถ้าไม่ใช่ 22)

### 2. สร้าง SSH Key (ถ้ายังไม่มี)

บน local machine:

```bash
ssh-keygen -t ed25519 -C "github-actions"
```

คัดลอก public key ไปยัง server:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server-ip
```

คัดลอก private key ไปใส่ใน GitHub Secrets:

```bash
cat ~/.ssh/id_ed25519
```

### 3. เตรียม Server

บน Ubuntu server:

```bash
# สร้าง directory สำหรับ app
sudo mkdir -p /opt/gold-price-api
sudo chown $USER:$USER /opt/gold-price-api

# Clone repo
cd /opt/gold-price-api
git clone <your-repo-url> .

# ตั้งค่า deploy script
chmod +x deploy.sh
```

## การ Deploy

### อัตโนมัติผ่าน GitHub Actions

- Push code ไปยัง branch `main` หรือ `master`
- GitHub Actions จะ run CI/CD pipeline อัตโนมัติ
- ตรวจสอบสถานะได้ที่ Actions tab

### Manual Deploy บน Server

```bash
cd /opt/gold-price-api
./deploy.sh
```

## การตรวจสอบสถานะ

### ตรวจสอบ Container

```bash
docker-compose ps
docker-compose logs -f
```

### ตรวจสอบ Health

```bash
curl http://localhost:3000/health
```

### ตรวจสอบ API

```bash
curl http://localhost:3000/api/gold/price
```

## การแก้ไขปัญหา

### Container ไม่ start

```bash
# ดู logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose up -d --build
```

### Port ถูกใช้งานอยู่

```bash
# หา process ที่ใช้ port 3000
sudo lsof -i :3000

# หรือเปลี่ยน port ใน docker-compose.yml
ports:
  - "8080:3000"
```

### ล้าง Docker resources

```bash
# ลบ containers ที่หยุดแล้ว
docker container prune

# ลบ images ที่ไม่ใช้
docker image prune -a

# ลบทุกอย่าง (ระวัง!)
docker system prune -a --volumes
```

## Nginx Reverse Proxy (Optional)

ถ้าต้องการใช้ domain และ HTTPS:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

ติดตั้ง SSL ด้วย Let's Encrypt:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Monitoring

### ดู Resource Usage

```bash
docker stats
```

### ดู Logs แบบ Real-time

```bash
docker-compose logs -f --tail=100
```

## การ Backup

```bash
# Backup script
#!/bin/bash
BACKUP_DIR="/backup/gold-api"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cd /opt/gold-price-api
tar -czf $BACKUP_DIR/gold-api-$DATE.tar.gz .

# เก็บ backup 7 วันล่าสุด
find $BACKUP_DIR -name "gold-api-*.tar.gz" -mtime +7 -delete
```
