data "aws_iam_policy_document" "backup_events" {
  count = length(var.notifications) > 0 ? 1 : 0
  statement {
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    resources = [
      lookup(var.notifications, "sns_topic_arn", null)
    ]
    sid = "BackupPublishEvents"
  }
}

resource "aws_sns_topic_policy" "backup_events" {
  count  = length(var.notifications) > 0 ? 1 : 0
  arn    = lookup(var.notifications, "sns_topic_arn", null)
  policy = data.aws_iam_policy_document.backup_events[0].json
}

resource "aws_backup_vault_notifications" "backup_events" {
  count               = length(var.notifications) > 0 ? 1 : 0
  backup_vault_name   = var.vault_name != null ? aws_backup_vault.ab_vault[0].name : "Default"
  sns_topic_arn       = lookup(var.notifications, "sns_topic_arn", null)
  backup_vault_events = lookup(var.notifications, "backup_vault_events", [])
}
