variable "key_pair_name" {
  description = "key_pair_name"
  type        = string
  default     = "tf_key"
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "value of public key to allow ssh to login "
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0qe/G/IhKu82y414p+Pp3EVIeTOpt2wp3WqbiiX0uR54YewAZ60nEAVZy0lyVzzw1ueDjZXWyZT2nZT5BuCFR8ks2cTjliGIiwgw9bFQq/Re7DQPKi+8Jq+rc0jyiVNJoLST1KUNBR9UKDI67DCCLG5yofW6kCeBgMDnZA0gcCkFOx3mXhy4+/wC7h+KVeFravCj+OdKwHTIqE+AGkScMA4Yqm/MBOHn9twFd9pw8BiYKqyLl0uHxEbe/5lyiE0BF/qUssEhLWkfnZ/q6NbRr7TvwQaPfqvkn92OXUMBjITONScym9Eyc96SOYmm9pic+8S+zNNFT8XkRjD5Sd26sQWEycSTDxgwZfxm423x/SuFHeZhF/JkV6aLJkd88E6UOAmZbsRy1JCPRTSA5R8lcR9Qg3sQhLc81WIE5Ik9fTZGuIUFOM8NQlylIu772vFzKqMg0bjRrV2dm5AMEObr39cNNQp6DeJoCD1xDwUrt+d2hK02BSmpV3V1+6bWNaa8= arung@Arun"

}

variable "volume_size" {
  type        = number
  description = "Volume size"
  default     = 10
}



