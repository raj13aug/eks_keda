data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "keda" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:*",
    ]

    actions = [
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "sqs:ListQueues",
    ]
  }
}


locals {
  service_name = format("%s-keda", var.cluster_name)

  role_name = "keda"

  tags = merge(
    var.tags,
    {
      "Made-By" = "terraform"
      "Service" = "keda"
      "Iam"     = "eks-keda"
    }
  )
}

resource "aws_iam_policy" "keda" {
  name        = local.service_name
  path        = "/"
  description = "KEDA IAM role policy"
  policy      = data.aws_iam_policy_document.keda.json

  tags = merge(
    { "Name" = local.service_name },
    local.tags
  )
}

module "irsa_keda" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.19.0"

  create_role                   = true
  role_description              = "Keda Role"
  role_name                     = local.role_name
  provider_url                  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  role_policy_arns              = aws_iam_policy.keda.arn
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.service_account}"]

  tags = merge(
    { "Name" = local.role_name },
    local.tags
  )
}

resource "kubernetes_namespace" "keda" {
  depends_on = [var.mod_dependency]
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}


resource "helm_release" "keda" {
  depends_on = [var. , kubernetes_namespace.keda]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace


  values = [
    yamlencode(var.settings)
  ]
}