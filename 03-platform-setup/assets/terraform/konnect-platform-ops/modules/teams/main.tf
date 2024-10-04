terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "1.0.0"
      # configuration_aliases = [konnect.global]
    }
  }
}

# Teams

# Internal Developers Team

resource "konnect_team" "kong_air_internal_devs" {
  description = "Allow managing the internal control plane configurations"
  name        = "Kong Air Internal Developers"
}

resource "konnect_team_role" "kong_air_internal_cp_admin" {
  entity_id        = var.control_planes.standard.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.kong_air_internal_devs.id
}

# Internal Viewers Team

resource "konnect_team" "kong_air_internal_viewers" {
  description = "Allow read-only access to all entities in the internal control plane"
  name        = "Kong Air Internal Viewers"
}

resource "konnect_team_role" "kong_air_internal_cp_viewer" {
  entity_id        = var.control_planes.standard.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.kong_air_internal_viewers.id
}

# External Developers Team

resource "konnect_team" "kong_air_external_devs" {
  description = "Allow read-only access to all entities in the external control plane"
  name        = "Kong Air External Developers"
}

resource "konnect_team_role" "kong_air_external_cp_admin" {
  entity_id        = var.control_planes.standard.kongair_external_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.kong_air_external_devs.id
}

# External Viewers Team

resource "konnect_team" "kong_air_external_viewers" {
  description = "Allow read-only access to all entities in the external control plane"
  name        = "Kong Air External Viewers"
}

resource "konnect_team_role" "kong_air_external_cp_viewer" {
  entity_id        = var.control_planes.standard.kongair_external_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.kong_air_external_viewers.id
}

# Platform Admins Team

resource "konnect_team" "platform_admins" {
  description = "Allow managing all entities in the global, internal and external control planes"
  name        = "Platform Admins"
}

resource "konnect_team_role" "platform_admins_global_cp_admin" {
  entity_id        = var.control_planes.standard.kongair_global_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.platform_admins.id
}

resource "konnect_team_role" "platform_admins_internal_cp_admin" {
  entity_id        = var.control_planes.standard.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.platform_admins.id
}

resource "konnect_team_role" "platform_admins_external_cp_admin" {
  entity_id        = var.control_planes.standard.kongair_external_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.platform_admins.id
}

# Platform Viewers Team

resource "konnect_team" "platform_viewers" {
  description = "Allow read-only access to all entities in the global, internal and external control planes"
  name        = "Platform Viewers"
}

resource "konnect_team_role" "platform_viewers_global_cp_viewer" {
  entity_id        = var.control_planes.standard.kongair_global_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.platform_viewers.id
}

resource "konnect_team_role" "platform_viewers_internal_cp_viewer" {
  entity_id        = var.control_planes.standard.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.platform_viewers.id
}

resource "konnect_team_role" "platform_viewers_external_cp_viewer" {
  entity_id        = var.control_planes.standard.kongair_external_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.platform_viewers.id
}