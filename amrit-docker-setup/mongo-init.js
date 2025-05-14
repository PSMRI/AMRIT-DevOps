// Create a user for the mydatabase
db = db.getSiblingDB('mydatabase');

// Check if the user already exists
const userExists = db.getUser("dbuser");
if (!userExists) {
  db.createUser({
    user: "dbuser",
    pwd: "1234",
    roles: [
      { role: "readWrite", db: "mydatabase" },
      { role: "dbAdmin", db: "mydatabase" }
    ]
  });
  print("MongoDB user 'dbuser' created successfully");
} else {
  print("MongoDB user 'dbuser' already exists");
}

// Create some initial collections
db.createCollection("system_config");
db.createCollection("audit_logs");

print("MongoDB initialization completed successfully"); 