#!/bin/bash

# Java Version (Spring Boot container)
echo "Java version (Spring Boot container):"
docker exec -it jdk-container java -version
echo "-----------------------------"

# MySQL Version
echo "MySQL version (MySQL container):"
docker exec -it mysql-container mysql --version
echo "-----------------------------"

# Redis Version
echo "Redis version (Redis container):"
docker exec -it redis-container redis-server --version
echo "-----------------------------"

# Node.js Version (Node.js container)
echo "Node.js version (Node.js container):"
docker exec -it nodejs-container node --version
echo "-----------------------------"

# Angular CLI Version (Node.js container)
echo "Angular CLI version (Node.js container):"
docker exec -it nodejs-container npx ng version
echo "-----------------------------"

# Maven Version (Maven container)
echo "Maven version (Maven container):"
docker exec -it maven-container mvn --version
echo "-----------------------------"
