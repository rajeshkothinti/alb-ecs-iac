# alb-ecs-iac
Prereq:
1. exisitng VPC ,subnets and ECS role


This terraform code will create ECS, ECR ,ALB and other dependencies.

Post Terraform apply

1. push image to ECR
2. Run task again in ECS cluster
3. Edit inbound rule to open appropriate port in security group
4. Register private ip of ECS to target group 
5. Hit ALB endpoint to access app
