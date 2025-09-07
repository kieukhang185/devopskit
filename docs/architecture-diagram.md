# Architecture Diagram

Below is the high-level architecture for the DevOpsKit project.

```ascii
Internet -> Route53 -> [WAF?] -> ALB -> TG-web -> ASG(web EC2)
                                   \-> TG-api -> ASG(api EC2) -> SG -> db EC2
Private: monitoring EC2 (Prometheus/Grafana/Alertmanager)
Mgmt: ci EC2 (Jenkins) or CodePipeline/Build/Deploy
Access: SSM Session Manager (no public SSH); optional bastion in public subnet
Logs: CloudWatch Logs -> S3 (lifecycle) -> Athena
Secrets: AWS Secrets Manager + SSM Parameter Store
```
