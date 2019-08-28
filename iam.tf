locals {
  services = [
    ["pcr", "PCR"],
    ["azure-pipelines-pcr", "PCR Azure Pipelines"],
    ["the-ducks", "The Ducks"],
  ]
  admin            = ["tirr", "Wonwoo Choi"]
  keybase_username = "vbchunguk"
}

resource "aws_iam_user" "admin" {
  name = local.admin[0]
  path = "/admin/"

  tags = {
    Name = local.admin[1]
  }
}

resource "aws_iam_user_policy_attachment" "admin" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "admin" {
  user    = aws_iam_user.admin.name
  pgp_key = "keybase:${local.keybase_username}"
}

resource "aws_iam_user" "services" {
  count = length(local.services)

  name = local.services[count.index][0]
  path = "/service/"

  tags = {
    Name = local.services[count.index][1]
  }
}

resource "aws_iam_access_key" "services" {
  count = length(aws_iam_user.services)

  user    = aws_iam_user.services[count.index].name
  pgp_key = "keybase:${local.keybase_username}"
}

data "aws_iam_policy" "fleet" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_iam_role" "fleet" {
  name               = "aws-ec2-spot-fleet-tagging-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fleet" {
  role       = aws_iam_role.fleet.name
  policy_arn = data.aws_iam_policy.fleet.arn
}

data "aws_iam_policy" "lambda_vpc" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "secrets_read_write" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "lambda" {
  name               = "lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.lambda_vpc.arn
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_read_write" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.secrets_read_write.arn
}

locals {
  encrypted_service_access_key = {
    for key in aws_iam_access_key.services :
    key.user => {
      id               = key.id,
      encrypted_secret = key.encrypted_secret
    }
  }
  encrypted_admin_access_key = {
    id               = aws_iam_access_key.admin.id,
    encrypted_secret = aws_iam_access_key.admin.encrypted_secret,
  }
}

resource "aws_iam_account_password_policy" "sane_default" {
  minimum_password_length        = 16
  allow_users_to_change_password = true
}
