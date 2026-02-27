output "pages_subdomain" {
  description = "Cloudflare Pages subdomain hostname"
  value       = cloudflare_pages_project.vidpare.subdomain
}
