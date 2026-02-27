terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_pages_project" "vidpare" {
  account_id        = var.cloudflare_account_id
  name              = "vidpare"
  production_branch = "master"

  build_config = {
    build_command   = "npm ci && npm run build"
    destination_dir = "dist"
    root_dir        = "site"
    build_caching   = true
  }

  source = {
    type = "github"
    config = {
      owner                          = "petems"
      repo_name                      = "vidpare"
      production_branch              = "master"
      pr_comments_enabled            = true
      preview_deployment_setting     = "all"
      production_deployments_enabled = true
    }
  }

  deployment_configs = {
    production = {
      compatibility_date = "2026-01-01"
    }
    preview = {
      compatibility_date = "2026-01-01"
    }
  }
}

resource "cloudflare_pages_domain" "apex" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.vidpare.name
  name         = "vidpare.app"
}

resource "cloudflare_pages_domain" "www" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.vidpare.name
  name         = "www.vidpare.app"
}
