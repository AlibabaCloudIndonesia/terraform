# Configure the Alicloud Provider
provider "alicloud" {
  access_key = "xx"
  secret_key = "xx"
  region     = "ap-southeast-5"
}

# Create VPC
resource "alicloud_vpc" "vpc"{
  name = "test_vpc_terraform"
  cidr_block = "172.16.0.0/12"
}

# Create VSwitch
resource "alicloud_vswitch" "vsw"{
   vpc_id = "${alicloud_vpc.vpc.id}"
   cidr_block ="172.16.0.0/21"
   availability_zone = "ap-southeast-5a"
}
  
# Create Security Group
resource "alicloud_security_group" "default"{
   name = "terraform-test-sg"
   vpc_id = "${alicloud_vpc.vpc.id}"
} 

# Create Security Group Rule
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "internet"
  policy = "accept"
  port_range = "1/65535"
  priority = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip = "0.0.0.0/0"
}

# Create ECS Instance
resource "alicloud_instance" "instance"{
  availability_zone = "ap-southeast-5a"
  security_groups = ["${alicloud_security_group.default.id}"]
  
  instance_type = "ecs.t5-lc1m2.small"
  system_disk_category = "cloud_efficiency"
  image_id = "centos_7_04_64_20G_alibase_201701015.vhd"
  instance_name = "ecs_by_terraform"
  vswitch_id = "${alicloud_vswitch.vsw.id}"
  internet_max_bandwidth_out = 10
}

