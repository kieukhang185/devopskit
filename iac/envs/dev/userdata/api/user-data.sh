#!/usr/bin/env bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

# ===== Config =====
REGION="ap-south-1"
APP_DIR="/opt/api"
LOG_DIR="/var/log/api"
LOG_GROUP_APP="/devopskit/dev/api/app"

# ===== System update & deps =====
apt-get update
apt-get install -y curl python3 python3-venv

# ===== App files =====
install -d -m 0755 "${APP_DIR}" "${LOG_DIR}"

# Simple HTTP app on :8080 with /health endpoint
cat > "${APP_DIR}/app.py" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import os, socket

PORT = 8080
INSTANCE_ID = os.popen("curl -fsS http://169.254.169.254/latest/meta-data/instance-id || echo unknown").read().strip()
AZ = os.popen("curl -fsS http://169.254.169.254/latest/meta-data/placement/availability-zone || echo unknown").read().strip()

class H(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        with open("/var/log/api/app.log", "a") as f:
            f.write("%s - - [%s] %s\n" % (self.address_string(), self.log_date_time_string(), format%args))
    def _ok(self, body, content_type="text/plain"):
        b = body.encode("utf-8")
        self.send_response(200); self.send_header("Content-Type", content_type); self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        if self.path == "/health":
            return self._ok("ok\n")
        if self.path == "/":
            return self._ok(f"api OK - instance={INSTANCE_ID} az={AZ}\n")
        return self._ok("not found\n")
HTTPServer(("", PORT), H).serve_forever()
PY

# Log a boot marker
echo "$(date -Is) boot: api instance started" >> "${LOG_DIR}/app.log"

# ===== systemd unit =====
cat > /etc/systemd/system/api.service <<'UNIT'
[Unit]
Description=DevOpsKit sample API
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/api
ExecStart=/usr/bin/python3 /opt/api/app.py
Restart=always
RestartSec=5
StandardOutput=append:/var/log/api/app.log
StandardError=append:/var/log/api/app.log
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable api
systemctl restart api

# ===== CloudWatch Agent (logs) =====
AGENT_DEB="https://amazoncloudwatch-agent-${REGION}.s3.${REGION}.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"
curl -fSL "$AGENT_DEB" -o /tmp/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb || apt-get install -y -f
rm -f /tmp/amazon-cloudwatch-agent.deb

install -d -m 0755 /opt/aws/amazon-cloudwatch-agent/etc
cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWCFG
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/api/app.log",
            "log_group_name": "${LOG_GROUP_APP}",
            "log_stream_name": "{instance_id}/app",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CWCFG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

systemctl enable amazon-cloudwatch-agent

echo "$(date -Is) boot: completed user-data" >> "${LOG_DIR}/app.log"
