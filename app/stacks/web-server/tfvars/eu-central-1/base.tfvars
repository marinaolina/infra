default_security_group_id = <%= output('my-vpc.default_security_group_id') %>
private_subnets = <%= output('my-vpc.private_subnets') %>
public_subnets = <%= output('my-vpc.public_subnets') %>
vpc_id = <%= output('my-vpc.vpc_id') %>
bastion_private_ip = <%= output('bastion.bastion_private_ip') %>