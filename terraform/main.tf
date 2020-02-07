module "presto" {
  source           = "github.com/Lewuathe/terraform-aws-presto"
  cluster_capacity = 2
}

output "alb_dns_name" {
  value = module.presto.alb_dns_name
}