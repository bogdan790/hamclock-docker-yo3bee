# HamClock Docker

A Docker setup for [HamClock](https://www.clearskyinstitute.com/ham/HamClock/) — a kiosk-style application providing real-time space weather, radio propagation models, operating events and other information useful to amateur radio operators.

## What makes this setup different

- **Simple by default, scalable by choice** — start with one instance, easily add more
- **Persistent configuration** — settings survive rebuilds via Docker volume
- **Robust startup** — configuration errors don't crash the container
- **Health monitoring** — Docker automatically detects and restarts unhealthy containers
- **No image junk** — tagged image prevents dangling images on rebuild
- **Cloudflare Tunnel ready** — optional secure public access without opening firewall ports

## Requirements

- Docker + Docker Compose
- Linux (tested on Debian/Ubuntu, Intel x86_64)

## Quick start

**1. Clone this repository**
```bash
git clone https://github.com/your-username/hamclock-docker-yo3bee.git
cd hamclock-docker-yo3bee
```

**2. Create your configuration file**
```bash
cp config.env.example config.env
```

Edit `config.env` with your callsign, locator and coordinates.

**3. Update docker-compose.yml**

In `docker-compose.yml`, set `env_file` to point to your config:
```yaml
env_file: config.env
```

**4. Build and start**
```bash
sudo docker compose build
sudo docker compose up -d
```

**5. Open HamClock**
```
http://localhost:8091/live.html
```

## Configuration

All settings are in your `.env` file. See `config.env.example` for all available options.

| Variable | Description | Example |
|----------|-------------|---------|
| `CALLSIGN` | Your amateur radio callsign | `AB1CDE` |
| `LOCATOR` | 6-character Maidenhead grid | `KN34AL` |
| `LAT` | Latitude (N positive, S negative) | `44.46` |
| `LONG` | Longitude (E positive, W negative) | `26.05` |
| `UTC_OFFSET` | UTC offset in hours | `+2` |
| `VOACAP_MODE` | Propagation mode (SSB=38, CW=19, FT8=13) | `38` |
| `VOACAP_POWER` | TX power in Watts | `100` |
| `USE_METRIC` | Metric system (1=yes, 0=no) | `1` |

## Rebuilding (updating HamClock)

```bash
sudo docker compose build --no-cache
sudo docker compose up -d
```

Settings are stored in the Docker volume `hamclock-data` and are **not lost** on rebuild.

## Public access via Cloudflare Tunnel

Expose HamClock securely on the internet without opening any firewall ports.

### 1. Install cloudflared

```bash
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
```

### 2. Authenticate

```bash
cloudflared tunnel login
```

A URL will be displayed — open it in your browser and authorize your domain.

### 3. Create a tunnel

```bash
cloudflared tunnel create hamclock
```

Note the tunnel ID shown in the output.

### 4. Create tunnel configuration

```bash
sudo mkdir -p /etc/cloudflared
```

Create `/etc/cloudflared/config.yml`:

```yaml
tunnel: YOUR-TUNNEL-ID
credentials-file: /etc/cloudflared/YOUR-TUNNEL-ID.json

ingress:
  - hostname: hamclock.yourdomain.com
    service: http://localhost:8091
    originRequest:
      httpHostHeader: "localhost:8091"
  - service: http_status:404
```

Copy credentials to system directory:
```bash
sudo cp ~/.cloudflared/YOUR-TUNNEL-ID.json /etc/cloudflared/
```

### 5. Add DNS record

```bash
cloudflared tunnel route dns hamclock hamclock.yourdomain.com
```

### 6. Install as system service

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

HamClock is now accessible at `https://hamclock.yourdomain.com/live.html`.

> **Tip:** In your Cloudflare dashboard, go to **SSL/TLS → Edge Certificates** and enable **Always Use HTTPS** to force HTTPS for all traffic.

## Protecting access with Cloudflare Access (Zero Trust)

Restrict who can access your HamClock instance. Free for personal use (up to 50 users). Supports Google, GitHub, Email OTP and more.

1. Go to [one.dash.cloudflare.com](https://one.dash.cloudflare.com) → **Access** → **Applications**
2. Click **Add an application** → **Self-hosted**
3. Set the application domain to `hamclock.yourdomain.com`
4. Create an **Access Policy** — allow specific emails or entire domains
5. Choose authentication method (Google login recommended)
6. Save

Visitors will now be redirected to a Cloudflare login page before accessing HamClock.

## Multiple instances

To run multiple HamClock instances on the same server (one per operator/callsign), duplicate the `web` service in `docker-compose.yml` and give each its own port, env file and volume.

Example with two instances:

```yaml
services:
  web:
    build: .
    image: hamclock:latest
    ports:
      - "8091:8081"
    env_file: station1.env
    volumes:
      - hamclock-data-1:/root/.hamclock
    restart: unless-stopped

  web2:
    build: .
    image: hamclock:latest
    ports:
      - "8092:8081"
    env_file: station2.env
    volumes:
      - hamclock-data-2:/root/.hamclock
    restart: unless-stopped

volumes:
  hamclock-data-1:
  hamclock-data-2:
```

Each instance:
- Has its own port (`8091`, `8092`, etc.)
- Has its own `.env` file with a different callsign and location
- Has its own persistent volume so settings don't mix

Access them at `http://localhost:8091/live.html`, `http://localhost:8092/live.html`, etc.

> **Tip:** If you use Cloudflare Tunnel, you can expose each instance on its own subdomain by adding multiple `ingress` entries in your tunnel config.

## Credits

- [WB0OEW](https://www.clearskyinstitute.com/ham/HamClock/) — HamClock author
- [zeidlos/hamclock-docker](https://github.com/zeidlos/hamclock-docker) — original Docker setup and env variable configuration
- [ChrisRomp/hamclock-docker](https://github.com/ChrisRomp/hamclock-docker) — persistent volume and health check ideas

73 de YO3BEE
