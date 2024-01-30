output "token" {
  value     = cloudflare_tunnel.tunnel.tunnel_token
  sensitive = true
}

output "tunnelId" {
  value = cloudflare_tunnel.tunnel.id
}