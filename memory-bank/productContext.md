# Product Context

This file provides a high-level overview of the project and the expected product that will be created. It is intended to be updated as the project evolves and should inform all other modes of the project's goals and context.

## Problem Statement

Hetzner Cloud is a cost-effective European cloud provider offering competitive pricing for compute, networking, and storage resources. However, there is no official Terraform module for deploying production-grade RKE2 Kubernetes clusters on Hetzner Cloud infrastructure.

Organizations wanting to use RKE2 (Rancher's lightweight Kubernetes distribution) on Hetzner must either:

- Manually provision and configure infrastructure
- Build custom automation from scratch
- Compromise on HA configurations due to complexity

## Solution

This Terraform module provides a complete infrastructure foundation for deploying highly available RKE2 Kubernetes clusters on Hetzner Cloud, including:

- Automated provisioning of control-plane and worker nodes
- Private networking for secure cluster communication
- Load balancer for API server access
- External datastore integration for HA control plane
- Firewall rules following RKE2 best practices
- Cloud-init based node bootstrap

## Target Users

- **Infrastructure Engineers**: Teams managing Kubernetes infrastructure who need a repeatable, declarative approach to cluster deployment
- **DevOps Engineers**: Practitioners using Hetzner Cloud who want to deploy RKE2 without building custom automation
- **Cost-Conscious Teams**: Organizations seeking a budget-friendly alternative to managed Kubernetes offerings (EKS, GKE, AKS)

## Key UX Goals

1. **Simple Variable-Driven Configuration**: Users should be able to deploy a cluster by providing minimal configuration (token, region, node counts)
2. **Composable Module Design**: The module should integrate cleanly into larger Terraform projects
3. **Sensible Defaults**: Default values should provide a working HA configuration without extensive customization
4. **Clear Outputs**: Module outputs should provide all necessary information for downstream consumption (kubeconfig retrieval, node IPs, etc.)

## Design Philosophy

- **Opinionated but Configurable**: The module makes architectural decisions (HA topology, external datastore, Canal CNI) while exposing key parameters for customization
- **Infrastructure Focus**: The module provisions infrastructure only; Kubernetes applications (cert-manager, ingress controllers, etc.) are deployed separately
- **Security-First**: Private networking, firewall rules, and minimal public exposure by default
- **Cost Awareness**: Default configurations are optimized for Hetzner's pricing model (e.g., lb11 load balancer, cx32 server type)

## Success Metrics

- Users can deploy a functional HA RKE2 cluster with < 10 variable inputs
- Cluster becomes operational within 10-15 minutes of `terraform apply`
- Module outputs provide all necessary information for kubectl access

---

*Last updated: 2026-02-23 14:04:00 CET*
