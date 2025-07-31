variable "fluxcd_key" {
  type      = string
  sensitive = true
}

variable "fluxcd_key_pub" {
  type      = string
  sensitive = true
}

variable "known_hosts" {
  type      = string
  sensitive = true
}