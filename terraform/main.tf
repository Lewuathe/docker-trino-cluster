module "trino" {
  source           = "github.com/Lewuathe/terraform-aws-trino"
  cluster_capacity = 2
}

output "alb_dns_name" {
  value = module.trino.alb_dns_name
}