# Project Setup Guide

Working on Amrit projects requires setting up many different tools and services on local machine. Setting up everything locally can take a lot of time and be frustrating. To make developers' lives easier, we used Docker, which helps set up everything quickly and consistently for everyone.

## Prerequisites

- Docker
- Docker Compose
- Git

## How to Start

### 1. Get the Code

First, fork the repository:

1. Go to `https://github.com/PSMRI/AMRIT-DevOps`
2. Click the "Fork" button in the top-right corner
3. Select your GitHub account as the destination

Then clone your forked repository:

```bash
git clone https://github.com/your-username/AMRIT-DevOps
cd AMRIT-DB/amrit-local-setup
```

### 2. Start Everything Up

Run this command to start all services:

```bash
docker-compose up --build
```

### 3. Check Tool Versions(optional only needeed if you need to check the versions)

Open a new command window and:

1. Go to the project folder:
   ```bash
   cd AMRIT-DB/amrit-local-setup
   ```
2. Run the version checker:
   ```bash
   ./versions.sh
   ```
3. If it doesn't work, try:
   ```bash
   chmod +x versions.sh
   ```
   then run ./versions.sh

## Database Setup

The database will set itself up automatically when you start the project. It will create four databases
| db_1097_identity |
| db_identity |
| db_iemr |
| db_reporting |
using the settings in the `init.sql` file.

## Important Notes

- All services can talk to each other through something called 'app-network'
- Database information is saved even when you stop the project
- We can access the tools from host using the ports mentioned above

## How to Stop

When you're done, run:

```bash
docker-compose down
```

This will stop everything, but keep your database information safe.
