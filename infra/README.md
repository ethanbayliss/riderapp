# Infrastructure for RiderApp
NEVER RUN TOFU APPLY - ALWAYS ASK ME TO RUN IT FOR YOU INSTEAD
- Tofu code
- Region: ap-southeast-2

## VPC for this app
- public subnets only - do not spin up a NAT Gateway EVER

## PostgreSQL Database for RiderApp
- Aurora DB that scales down to 0 ACUs when not in use
