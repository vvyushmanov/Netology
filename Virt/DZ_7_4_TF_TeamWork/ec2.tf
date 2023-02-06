module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "netology_ec2_test_${count.index}"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.instance_type[terraform.workspace]
  cpu_core_count         = local.cores[terraform.workspace]
  cpu_threads_per_core   = local.cores_threads[terraform.workspace]
  root_block_device = [
      {
        volume_size = 15
        volume_type = "gp2"
      }
  ]

  tags = {
    Name = format("%s.netology_test__-%s", terraform.workspace, count.index+1)
  }
  count = local.ec2_count[terraform.workspace]
  
}
