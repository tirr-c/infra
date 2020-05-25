locals {
  pcr_services = ["pcr", "azure-pipelines-pcr"]
}

resource "aws_iam_policy" "pcr_s3" {
  description = "PCR S3 policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*",
        "s3:AbortMultipartUpload",
        "s3:HeadObject",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
        "s3:PutLifecycleConfiguration",
        "s3:CreateBucket",
        "s3:PutBucketCORS"
      ],
      "Resource": [
        "arn:aws:s3:::ames-static.tirr.dev",
        "arn:aws:s3:::ames-static.tirr.dev/*",
        "arn:aws:s3:::pcr.tirr.dev",
        "arn:aws:s3:::pcr.tirr.dev/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:HeadBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "pcr_services" {
  count = length(local.pcr_services)

  user       = local.pcr_services[count.index]
  policy_arn = aws_iam_policy.pcr_s3.arn
}
