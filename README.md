#alb-ecs-iac
Prereq:

exisitng VPC ,subnets and ECS role
This terraform code will create ECS, ECR ,ALB and other dependencies.

Post Terraform apply

push image to ECR
Run task again in ECS cluster
Edit inbound rule to open appropriate port in security group
Register private ip of ECS to target group
Hit ALB endpoint to access app
