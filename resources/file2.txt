ONE TIME, ON THE NOTEHUB

1. Create a VPC for notehub in us-east-1  https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#Create-VPC https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#vpcs: 
    1. VPC peering is not transitive, so we will use a single VPC for all customers. https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html
    2. The V4 CIDR block notehub use will be 10.0.0.0/24
    3. Create a VPC
        1. VPC only
        2. Name tag "notehub-firehose-vpc"
        3. IPv4 CIDR block
            1. IPv4 CIDR manual input
            2. IPv4 CIDR 10.0.0.0/24
        4. IPv6 CIDR block
            1. No IPv6 CIDR block
        5. Tenancy
            1. Default
    4. DNS settings (enable both of these)
        1. [x] Enable DNS resolution
        2. [x] Enable DNS hostnames

SET UP THE PEERED VPC FOR EACH NEW CUSTOMER (in this case Ray)

1. Create a VPC for each customer, in us-east-1  https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#Create-VPC https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#vpcs: 
    1. Each customer will be assigned a V4 /24 CIDR block, starting with 10.0.1.0 for the first customer, 10.0.2.0 for the second, and so on
    2. Create a VPC
        1. VPC only
        2. Name tag "ray-notehub-firehose-vpc"
        3. IPv4 CIDR block
            1. IPv4 CIDR manual input
            2. IPv4 CIDR 10.x.y.0/24 (in the case of ray 10.0.1.0/24)
        4. IPv6 CIDR block
            1. No IPv6 CIDR block
        5. Tenancy
            1. Default
    3. Edit VPC Settings
        1. DNS settings (enable both of these)
            1. [x] Enable DNS resolution
            2. [x] Enable DNS hostnames
2. On the notehub side, create two subnets https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets: 
    1. Create Subnet
    2. VPC ID
        1. notehub-firehose-vpc
    3. Subnet settings for Subnet 1 of 1
        1. Subnet name
            1. firehose-subnet-1
        2. Availability Zone
            1. Pick one (us-east-1c)
        3. IPv4 CIDR block
            1. 10.0.0.0/25 to give it the low 128 addresses
    4. Add new Subnet
    5. Subnet settings for Subnet 2 of 2
        1. Subnet name
            1. firehose-subnet-2
        2. Availability Zone
            1. Pick A DIFFERENT one (us-east-1d)
        3. IPv4 CIDR block
            1. 10.0.0.128/25 to give it the high 128 addresses
3. On the Notehub side, under Virtual Private Cloud / Peering Connections, Create a Peering Connection https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#PeeringConnections:
    1. Name
        1. ray-firehose
    2. VPC ID (requester)
        1. notehub-firehose-vpc
    3. Select another VPC to peer with
        1. Another account
        2. In the case of Ray, 359965662084
    4. Region
        1. This Region (us-east-1)
    5. VPC ID (Accepter)
        1. In the case of Ray, vpc-0bd828f59b1f505d8
    6. Under Actions, Edit DNS settings and go to Requester DNS resolution, and say "Allow accepter VPC" to resolve DNS of requester VPC"
4. On the Notehub side, in Your VPCs, open the notehub-firehose-vpc:  https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#vpcs: 
    1. Click the "main route table" link to edit the routing table.  You will see the various destinations, the first one of which is 10.0.0.0/24.  
    2. Click Edit Routes
    3. Click Add route
    4. In the case of Ray, add 10.0.1.0/24 with target "peering connection", and select the peering connection above, so we have a route to Ray's connection
5. On the customer side, Accept the Peering Connection https://docs.aws.amazon.com/vpc/latest/peering/accept-vpc-peering-connection.html
    1. Go to the Peering Connections section, and open the peering connection that is listed
    2. It should say "Pending acceptance".  Choose Actions / Accept Request
    3. It should say, in a green banner, that it has been established and that Routing must be updated.  Click Modify my route tables now.
    4. Click the route for ray-notehub-firehose-vpc to edit it
    5. Click Edit Routes
    6. Click Add route
    7. Add 10.0.0.0/24 target "peering connection", and select the peering connection above, so that we have a route to the notehub firehose vac
6. On the customer side, create two subnets https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets: 
    1. Create Subnet
    2. VPC ID
        1. ray-notehub-firehose-vpc
    3. Subnet settings for Subnet 1 of 1
        1. Subnet name
            1. firehose-subnet-1
        2. Availability Zone
            1. Pick one (in Ray's case us-east-1c)
        3. IPv4 CIDR block
            1. For ray, 10.0.1.0/25 to give it the low 128 addresses
    4. Add new Subnet
    5. Subnet settings for Subnet 2 of 2
        1. Subnet name
            1. firehose-subnet-2
        2. Availability Zone
            1. Pick A DIFFERENT one (in ray's case us-east-1d)
        3. IPv4 CIDR block
            1. For ray, 10.0.1.128/25 to give it the high 128 addresses
7. Enable DNS resolution on both the notehub side and customer sides. https://docs.aws.amazon.com/vpc/latest/peering/modify-peering-connections.html#vpc-peering-dns

