# Kubernetes Homelab (K3s)

[![Terraform](https://img.shields.io/badge/Terraform-v1+-blue?logo=terraform)](https://www.terraform.io/)  
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-red?logo=ansible)](https://www.ansible.com/)  
[![K3s](https://img.shields.io/badge/K3s-Lightgrey?logo=kubernetes)](https://k3s.io/)  
[![Argo CD](https://img.shields.io/badge/ArgoCD-Active-brightgreen?logo=argo)](https://argo-cd.readthedocs.io/)  
[![Helm](https://img.shields.io/badge/Helm-v3+-blue?logo=helm)](https://helm.sh/)


## 📌 Motivation
This project is a **Kubernetes homelab** I built while preparing for the **Certified Kubernetes Administrator (CKA)** certification.  
It uses **Terraform** and **Ansible** to provision and configure a **K3s cluster**, with **Argo CD** and **Helm** handling GitOps-based application deployment.  

A practical playground for **automation**, **GitOps**, and **real-world Kubernetes operations**.

## Requirements

**Note:** Due to limited hardware resources, I configured my environment on a mini PC equipped with 16 GB of RAM and a single CPU with 4 cores.  
This code can be used as a base or starting point to deploy any environment tailored to your business needs.

- Terraform v1 or later  
- Ansible 2.9 or later  
- Any Linux distribution based on Debian
- libvirt and KVM  




## Introduction

This automation provisions and deploys a Kubernetes (K3s) cluster with 3 nodes, along with a dedicated NFS server for shared storage.

![Descrição da imagem](./images/HomelabK3S.drawio.png)



## Why do we need both Terraform and Ansible?
* Terraform is designed to provision different infrastructure components.
* Ansible is a configuration-management and application-deployment tool. 
* It means that you’ll use Terraform first to create the virtual machines and then use Ansible to install and set up the kubernetes cluster.

* [TerraformAnsible](https://www.hashicorp.com/resources/ansible-terraform-better-together) - Good page and video explaining why Ansible and HashiCorp are  better together.


## Terraform


##### As a good practice, keep your terraform.tfstate file in a backend - [TerraformBackend](https://developer.hashicorp.com/terraform/language/backend)

## Ansible
#### To install the applications, packages and apply the following settings:
