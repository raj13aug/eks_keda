output "role_arn" {
  value       = keda_role.iam_role_arn
  description = "Amazon Resource Name for Keda"
}