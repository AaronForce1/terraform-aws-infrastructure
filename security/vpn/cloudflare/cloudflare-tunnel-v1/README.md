# Cloudflare Zero-Trust VPN Tunnel (v1)

## Overview

Terraform module to create Cloudflare Tunnel Components.

### Description

WIP.

### Terraform versions

Terraform 1.5.

### Dependencies

The following resources must exist before the deployment can take place:

* Cloudflare
* Cloudflare API Key with the following permissions:

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.4, < 2.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.13.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.25.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_tunnel.tunnel](https://registry.terraform.io/providers/cloudflare/cloudflare/4.13.0/docs/resources/tunnel) | resource |
| [cloudflare_tunnel_route.example](https://registry.terraform.io/providers/cloudflare/cloudflare/4.13.0/docs/resources/tunnel_route) | resource |
| [kubernetes_secret.cloudflare_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.cloudflare_access_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare Account ID | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_tunnel_name"></a> [tunnel\_name](#input\_tunnel\_name) | n/a | `string` | n/a | yes |
| <a name="input_tunnel_secret_name"></a> [tunnel\_secret\_name](#input\_tunnel\_secret\_name) | n/a | `string` | `""` | no |
| <a name="input_tunnel_secret_namespace"></a> [tunnel\_secret\_namespace](#input\_tunnel\_secret\_namespace) | n/a | `string` | `""` | no |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_token"></a> [token](#output\_token) | n/a |
| <a name="output_tunnelId"></a> [tunnelId](#output\_tunnelId) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## **Security Framework**

This section explains how the different aspects to have into account in order to meet the Security Control for Cloud for this Certified Service.

### CERTIFICATE LEVEL: Advanced

Security Controls for Cloud that apply always:

#### Foundation (**F**) Controls for Rated Workloads

|SF#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SF1| IAM on all accounts|IAM permissions based on roles. Access is based on the principle of least privilege assigned to roles. |CCoE, Entity|
|SF2| MFA on accounts| This is governed by Azure AD and integrated with O365.|CCoE, Entity|
|SF3| Platform Activity Logs & Security Monitoring. |Platform logs and security monitoring provided by Platform. Integration with Amazon CloudWatch. Amazon CloudWatch Logs for HSM Audit Logs. Integration with AWS CloudTrail. AWS CloudTrail for API logs.|CCoE|
|SF4| Virus/Malware Protection on IaaS|N/A. No antivirus protection for AWS CloudHSM. |CCoE, DevOps|
|SF5| Authenticate all connections| Provided by the platform.|CCoE, DevOps|
|SF6| Isolated environments at network level|Provided by the platform. Integration with Amazon VPC, VPC security groups and network ACLs. |CCoE|
|SF7| Security Configuration & Patch Management|N/A.|CCoE|
|SF8| Privileged Access Management| Grant permissions using IAM Policies. Integrate with Santader O365.|CCoE, CISO|

---------

#### Medium (**M**) Controls for Rated Workloads

|SM#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SM1| IAM|IAM permissions based on roles.|CCoE, Entity|
|SM2| Encrypt data at rest| When AWS CloudHSM makes a backup from an HSM, the HSM encrypts its data before sending it to AWS CloudHSM. The data is encrypted using a unique, ephemeral encryption key.|CCoE|.
|SM3| Encrypt data in transit over private interconnections| AWS published API calls to access AWS CloudHSM through the network. Clients must support Transport Layer Security (TLS) 1.0 or later. Clients must also support cipher suites with perfect forward secrecy (PFS) such as Ephemeral Diffie-Hellman (DHE) or Elliptic Curve Ephemeral Diffie-Hellman (ECDHE). Most modern systems such as Java 7 and later support these modes. Additionally, requests must be signed by using an access key ID and a secret access key that is associated with an IAM principal.|CCoE, DevOps, Entity|
|SM4| Control resource geographical location| Create a cluster CloudHSM in a private subnet in your VPC. When you create an HSM, AWS CloudHSM put an elastic network interface (ENI) in your subnet so that you can interact with your HSMs.|CCoE, CISO, DevOps|

---------

#### Application (**P**) Controls for Rated Workloads

|SP#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SP1|Resource tagging for all resources|Product includes all required tags in the deployment template. The implementation will be done in the code. |CCoE, Cybersecurity|
|SP2|Segregation of Duties| Use features of AWS Identity and Access Management (IAM) to allow other users, services, and applications to use your AWS resources fully or in a limited way. When you attach a policy to a user or group of users, it allows or denies the users permission to perform the specified tasks on the specified resources. [Grant Permissions Using IAM Policies.](https://docs.aws.amazon.com/cloudhsm/latest/userguide/identity-access-management.html) |CCoE, CISO, Entity|
|SP3|Vulnerability Management| Detect is responsablefor vulnerability scanning of endpoints.| CCoE, CISO|
|SP4|Service Logs & Security Monitoring| Platform logs and security monitoring provided by Platform. Integration with Amazon CloudWatch. Amazon CloudWatch Logs for HSM Audit Logs. Integration with AWS CloudTrail. AWS CloudTrail for API logs.|CCoE, CISO|
|SP5|Network Security|N/A. Provided by the platform. |CCoe, DevOps|
|SP5.1|Inbound and outbound traffic CSP Private zone to Santander On-premises| Capacity provided from TLZ. ||
|SP5.2|Inbound and outbound traffic: between CSP Private zones of different entities| Capacity provided from TLZ.||
|SP5.3|Inbound and outbound traffic: between CSP Private zones of the same entity| Capacity provided from TLZ.| |
|SP5.4|Inbound traffic: Internet to CSP Public zone|Security Groups and ACL. Provided by platform.||
|SP5.5|Outbound traffic: From CSP Public/Private zone to Internet| N/A.||
|SP5.6| Control all DNS resolutions and NTP consumption in CSP Private zone|Only the services provided by the platform should be used.||
|SP6|Advanced Malware Protection on IaaS| N/A.|CCoE, CISO, Entity|
|SP7|Cyber incidents management & Digital evidences gathering|Capacity provided from TLZ.|CISO, Entity|
|SP8|Encrypt data in transit over public interconnections| Transport Layer Security (TLS). [Infrastructure Security in AWS CloudHSM.](https://docs.aws.amazon.com/cloudhsm/latest/userguide/infrastructure-security.html)|CCoE, DevOps|
|SP9|Static Application Security Testing (SAST)|Evaluated by Sentinel (Terraform Enterprise) and by Dome9 (Check Point).|Entity|

---------

#### Advanced (**A**) Controls for Rated Workloads

|SA#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SA1| IAM| IAM permissions based on roles. Access is based on the principle of least privilege assigned to roles.|CCoE, Entity|
|SA2| Encrypt data at rest| When AWS CloudHSM makes a backup from an HSM, the HSM encrypts its data before sending it to AWS CloudHSM. The data is encrypted using a unique, ephemeral encryption key.. |CCoE, Entity |
|SA3| Encrypt data in transit over private interconnections | AWS published API calls to access AWS CloudHSM through the network. Clients must support Transport Layer Security (TLS) 1.0 or later. Clients must also support cipher suites with perfect forward secrecy (PFS) such as Ephemeral Diffie-Hellman (DHE) or Elliptic Curve Ephemeral Diffie-Hellman (ECDHE). Most modern systems such as Java 7 and later support these modes. Additionally, requests must be signed by using an access key ID and a secret access key that is associated with an IAM principal..|CCoE, Entity|
|SA4| Santander managed keys with HSM and BYOK| AWS CloudHSM makes periodic backups of your cluster. When you add an HSM to a cluster that previously contained one or more active HSMs, AWS CloudHSM restores the most recent backup onto the new HSM. This means that you can use AWS CloudHSM to manage an HSM that you use infrequently. When you don't need to use the HSM, you can delete it, which triggers a backup. Later, when you need to use the HSM again, you can create a new HSM in the same cluster, effectively restoring your previous HSM. |CCoE, Cybersecurity|
|SA5| Control resource geographical location| Create a cluster CloudHSM in a private subnet in your VPC.|CCoE, CISO, DevOps|
|SA6| Cardholder and auth sensitive data| N/A. Provided by the environment.|Entity|
|SA7| Access control to data with MFA| N/A. Provided by the environment.|CCoE, CISO, Entity|

---------

#### Critical (**C**) Controls for Rated Workload

|SC#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SC1| Pen-testing| N/A. |CISO, Entity|
|SC2| Threat Model| N/A. |Entity|
|SC3| RedTeam| N/A.|CISO|
|SC4| Dynamic Application Security Testing (DAST)| N/A.|Entity|

---------

## Acknowledgements

Thank you to the following people for allowing me to leverage their work to make this.

* [isaezfernandez](https://github.com/isaezfernandez/terraform-aws-module-hsm)
* [JamesWoolfenden](https://github.com/JamesWoolfenden/terraform-aws-cloudhsm)