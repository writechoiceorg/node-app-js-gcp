data "aws_iam_policy_document" "support" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::302232432727:root"] # Aspect account with IAM users for DPE support access
      type        = "AWS"
    }
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent" # Require MFA for Aspect DPE support access
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "operator" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::302232432727:root"] # Aspect account with IAM users for DPE operator access
      type        = "AWS"
    }
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent" # Require MFA for Aspect DPE operator access
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "support" {
  name               = "AspectWorkflowsSupport"
  assume_role_policy = data.aws_iam_policy_document.support.json
}

resource "aws_iam_role" "operator" {
  name               = "AspectWorkflowsOperator"
  assume_role_policy = data.aws_iam_policy_document.operator.json
}

