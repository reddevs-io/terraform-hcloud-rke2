# Project Brief

## Project Name

`terraform-hetzner-rke2`

## Description

Terraform module for deploying RKE2 Kubernetes clusters on Hetzner Cloud with embedded etcd (optional external datastore support).

## Project Status

Early-stage / experimental (proof-of-concept)

## Core Requirements

The module must:

- Deploy a highly available RKE2 control plane with multiple control-plane nodes
- Create and configure worker node pools for Kubernetes workloads
- Provision private networking (Hetzner Cloud network + subnet) for secure inter-node communication
- Deploy a Hetzner Load Balancer for the Kubernetes API server endpoint
- Support embedded etcd by default, with optional external datastore for RKE2 HA
- Configure firewall rules for control-plane and worker nodes following RKE2 networking requirements
- Bootstrap nodes via cloud-init for automated RKE2 installation and configuration
- Generate SSH key pairs for secure node access

## Primary Goal

Complete core module functionality:

- [x] HA control plane (multiple control-plane nodes with load balancer)
- [x] Worker node pools (configurable count)
- [x] Private networking (Hetzner network + subnet)
- [x] Embedded etcd by default with optional external datastore
- [ ] Testing and validation
- [ ] Documentation refinement

## Out of Scope (For Now)

- Terraform Registry publication
- Autoscaling (cluster-autoscaler integration)
- Multi-provider datastore support
- Kubernetes application deployment (cert-manager, external-dns, Rancher deployed separately)
- Multi-region deployments

## Key Stakeholders

- Infrastructure engineers
- DevOps engineers using Hetzner Cloud
- Teams seeking cost-effective Kubernetes deployments via RKE2

## Timeline

Proof-of-concept stage - no production timeline established.

---

*Last updated: 2026-02-23 14:03:00 CET*
