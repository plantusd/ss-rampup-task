data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_version = "1.19"

  cluster_name                    = "eks-ss-rampup-task"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  enable_irsa                     = true

  subnets = [
    data.terraform_remote_state.core.outputs.subnet-k8s-1a,
    data.terraform_remote_state.core.outputs.subnet-k8s-1b,
    data.terraform_remote_state.core.outputs.subnet-k8s-1c
  ]

  vpc_id = data.terraform_remote_state.core.outputs.aws_vpc_main

  # worker groups with launch templates
  worker_groups_launch_template = [
    {
      name                 = "main"
      public_ip            = false
      key_name             = "admin"
      instance_type        = "c5.2xlarge"
      asg_desired_capacity = 15
      asg_min_size         = 15
      asg_max_size         = 15
      autoscaling_enabled  = false
      bootstrap_extra_args = "--docker-config-json '{\n    \"bridge\": \"none\",\n    \"log-driver\": \"json-file\",\n    \"log-opts\": {\n        \"max-size\": \"100m\",\n        \"max-file\": \"10\"\n    },\n    \"live-restore\": true,\n    \"max-concurrent-downloads\": 10,\n    \"default-ulimits\": {\n        \"memlock\": {\n            \"Hard\": -1,\n            \"Name\": \"memlock\",\n            \"Soft\": -1\n        }\n    },\n    \"registry-mirrors\": [\n        \"https://mirror.gcr.io\"\n    ]\n}'"
      subnets = [
        data.terraform_remote_state.core.outputs.subnet-k8s-1a,
        data.terraform_remote_state.core.outputs.subnet-k8s-1b,
        data.terraform_remote_state.core.outputs.subnet-k8s-1c
      ]
      root_volume_size = 200
      root_volume_type = "gp3"

      # todo - move target groups to terraform
      target_group_arns = [
        "arn:aws:elasticloadbalancing:eu-central-1:405940072661:targetgroup/k8s-internal-domains/f5281d626d33d429",
      ]
      # instance replacement policy
      termination_policies = [
        "OldestInstance",
      ]
      # Auto Scaling group metrics collection
      enabled_metrics = [
        "GroupAndWarmPoolDesiredCapacity",
        "GroupAndWarmPoolTotalCapacity",
        "GroupDesiredCapacity",
        "GroupInServiceCapacity",
        "GroupInServiceInstances",
        "GroupMaxSize",
        "GroupMinSize",
        "GroupPendingCapacity",
        "GroupPendingInstances",
        "GroupStandbyCapacity",
        "GroupStandbyInstances",
        "GroupTerminatingCapacity",
        "GroupTerminatingInstances",
        "GroupTotalCapacity",
        "GroupTotalInstances",
        "WarmPoolDesiredCapacity",
        "WarmPoolMinSize",
        "WarmPoolPendingCapacity",
        "WarmPoolTerminatingCapacity",
        "WarmPoolTotalCapacity",
        "WarmPoolWarmedCapacity",
      ]
    }
  ]

  worker_additional_security_group_ids = [data.terraform_remote_state.core.outputs.sg-all_worker_mgmt]
  cluster_security_group_id            = data.terraform_remote_state.core.outputs.sg-eks_cluster_security_group
  cluster_create_security_group        = false
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket  = "tf-state.pmlab.eva"
    key     = "networking/main"
    region  = "eu-central-1"
  }
}