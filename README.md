# MapQaTor Backend

## Project Setup

Follow the step by step installation procedure to install and run this on your machine.

## Prerequisites

Make sure you have node and postgresql installed in your device.

- **`NodeJs`**: Install Nodejs from [here](https://nodejs.org/en/download/)
- **`PostgreSQL`** Install PostgreSQL from [here](https://www.postgresql.org/download/)


## Installation <a name="configuration"></a>

1.  Clone the repo

```sh
git clone https://github.com/mapqator/mapqator-backend.git
```

2.  If you don't have git installed in your device then download zip
3.  After installation or download go to the repository and open command line.

### Configuring Backend

Install NPM packages

```sh
npm install
```

### Configuring Database

```sh
psql -U postgres -c "CREATE DATABASE mapqator;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mapqator TO postgres;"
psql -U postgres -d mapqator -a -f database\schema.sql
# psql -U postgres -c "DROP DATABASE mapqator;"
```

An empty database will be created with the name `mapqator` and the schema will be created.

If you want the cached data that was used for MapEval benchmark you should use: `psql -U postgres -d mapqator -a -f database\dump.sql` instead of `psql -U postgres -d mapqator -a -f database\schema.sql`.

If you plan to host the frontend as well, you need to create an user to login to the website. For that you need to add an entry in the `users` table.

```sh
psql -U postgres -d mapqator -c "INSERT INTO users (username, password) VALUES ('your_username', '******');"
```

Replace `******` with the hashed password. You can use the following command to generate a hashed password.

```sh
node services\password.js your_password
```

### Setting up the environment variables

Rename the `.env.example` file to `.env` and update the values as per your configuration.

We are finally good to go.

### Run the project

Go to your favourite code editor and run

```sh
npm start
```

You should find that the project is working!

* Check credential
```sh
curl -X POST http://localhost:5000/api/login \
     -H "Content-Type: application/json" \
     -d '{"username": "test", "password": "123"}'
```

### Some Postgres Commands
```sh
# show databases
psql -U postgres -l  

# show tables
psql -U postgres -d mapqator -c "\dt"
```


### (Optional) AWS Deployment


```bash
aws ec2 request-spot-instances \
  --instance-count 1 \
  --type one-time \
  --launch-specification '{
            "ImageId": "ami-0b8d527345fdace59",
            "KeyName": "race_lits_server",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/xvda",
                    "Ebs": {
                         "VolumeSize": 30,
                         "VolumeType": "gp3",
                         "DeleteOnTermination": true
                    }
                }
            ],
            "EbsOptimized": true,
            "SubnetId": "subnet-070b5b80b8e23c5bd",
            "SecurityGroupIds": ["sg-0fed3f02e16c4f50e"],
            "InstanceType": "t3.medium"
        }'
```

```bash
aws ec2 run-instances \
  --image-id ami-0b8d527345fdace59 \
  --count 1 \
  --instance-type t3.medium \
  --key-name race_lits_server \
  --subnet-id subnet-070b5b80b8e23c5bd \
  --security-group-ids sg-0fed3f02e16c4f50e \
  --block-device-mappings '[
    {
      "DeviceName": "/dev/xvda",
      "Ebs": {
        "VolumeSize": 30,
        "VolumeType": "gp3",
        "DeleteOnTermination": true
      }
    }
  ]' \
  --ebs-optimized \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mapqator-backend}]'
```

* t3.medium: $0.042 On Demand
* "ami-0b8d527345fdace59": Ubuntu Server 24.04 LTS (HVM)


Output will be like:

```json
{
  "ReservationId": "r-0122ae8b1ab9ee192",
  "Instances": [
    {
      "InstanceId": "i-0320ed19eea45738a",
      "State": { "Name": "pending" }
    }
  ]
}
```

* ReservationId → internal grouping ID when you launch multiple instances in one API call.
It is not reusable or queryable like a Spot Request ID.
* InstanceId → the actual resource you control (i-0320ed19eea45738a).

Track or Manage On-Demand Instances
```bash
aws ec2 describe-instances --instance-ids i-0320ed19eea45738a
aws ec2 stop-instances --instance-ids i-0320ed19eea45738a
aws ec2 start-instances --instance-ids i-0320ed19eea45738a
```

ssh 
```bash
ssh -i ~/.ssh/race_lits_server.pem ubuntu@54.79.149.133
```