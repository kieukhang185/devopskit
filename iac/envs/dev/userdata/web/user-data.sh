#!/usr/bin/env bash
set -euo pipefail

REGION="us-west-1"
LOG_GROUP_NGINX="/devopskit/dev/web/nginx"
LOG_GROUP_APP="/devopskit/dev/web/app"

apt-get update
apt-get install -y curl nginx

systemctl enable nginx

INSTANCE_ID=$(curl -fsS http://169.254.169.254/latest/meta-data/instance-id || echo unknown)
AZ=$(curl -fsS http://169.254.169.254/latest/meta-data/placement/availability-zone || echo unknown)
echo "web OK - instance ${INSTANCE_ID} in ${AZ} > /var/www/html/index.html"

cat >/etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    location /health {
        return 200 'OK\n';
        add_header Content-Type text/plain;
    }
}
NGINX

# Enable site
rm -f /etc/nginx/sites-enabled/default || true
ln -s /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web

mkdir -p /var/log/app
echo "$(date -Is) boot: web server started" >> /var/log/app/web-app.log

nginx -t
systemctl restart nginx

# CloudWatch Agent
AGENT_DEB="https://amazoncloudwatch-agent-${REGION}.s3.${REGION}.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"
curl -fSL "${AGENT_DEB}" -o /tmp/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb || apt-get -f install -y -f
rm -f /tmp/amazon-cloudwatch-agent.deb

install -d -m 755 /opt/aws/amazon-cloudwatch-agent/etc
cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWCFG
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "${LOG_GROUP_NGINX}",
            "log_stream_name": "{instance_id}/access",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "${LOG_GROUP_NGINX}",
            "log_stream_name": "{instance_id}/error",
            "timestamp_format": "%Y/%m/%d %H:%M:%S",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/app/web-app.log",
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

echo "$(date -Is) boot: user-data script completed" >> /var/log/app/web-app.log
