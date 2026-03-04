# AMRIT-DevOps


[![DeepWiki](https://img.shields.io/badge/DeepWiki-PSMRI%2FAMRIT--DevOps-blue.svg?...)](https://deepwiki.com/PSMRI/AMRIT-DevOps)

DevOps automation and infrastructure configuration repository for the AMRIT (Accessible Medical Records via Integrated Technology) platform. Contains Docker orchestration, database management tools, monitoring setup, and deployment automation scripts.

## Overview

This repository provides infrastructure-as-code and DevOps tooling for deploying and managing the AMRIT healthcare platform across multiple environments. It includes containerized deployment configurations, database management utilities, anonymization tools, and monitoring infrastructure.

## Repository Structure

### amrit-docker-setup
Complete Docker-based deployment configuration for production and staging environments. Includes Docker Compose orchestration for all microservices, NGINX reverse proxy configuration, automated build scripts, and environment management.

**Use case:** Full production deployment with containerized infrastructure and application services.

### amrit-local-setup
Lightweight Docker Compose configuration for local development environments. Provides only infrastructure services (MySQL, Redis, MongoDB) while APIs and UIs run directly on the host machine.

**Use case:** Local development environment for debugging and feature development.

### ELK
Elastic Stack configuration for distributed tracing and centralized logging. Includes APM agent setup for WildFly application servers, Filebeat configuration for log aggregation, and Kibana dashboard setup.

**Components:**
- APM Server configuration for application performance monitoring
- Filebeat setup for log collection and forwarding
- WildFly integration configuration
- API key management and security setup

## Setup

Refer to the local setup if you want to set up the AMRIT platform locally on your laptop and contribute. Refer to the Docker setup if you want to set up the AMRIT Platform on a server or if you are planning to check how the platform works.


## Support

For platform documentation and technical support, refer to the [official AMRIT documentation](https://piramal-swasthya.gitbook.io/amrit/).

## License

Refer to LICENSE file in this repository.
