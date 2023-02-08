
# # Resource: Create AWS Load Balancer Controller IAM Policy 
# resource "aws_iam_policy" "lbc_iam_policy" {
#   name        = "${var.project}-AWSLoadBalancerControllerIAMPolicy"
#   path        = "/"
#   description = "AWS Load Balancer Controller IAM Policy"
#   policy = data.http.lbc_iam_policy.response_body
# }

# # Resource: Create IAM Role 
# resource "aws_iam_role" "lbc_iam_role" {
#   name = "${var.project}-lbc-iam-role"

#   # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
#         }
#         Condition = {
#           StringEquals = {
#             "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
#             "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }        
#       },
#     ]
#   })

#   tags = {
#     tag-key = "AWSLoadBalancerControllerIAMPolicy"
#   }
# }

# # Associate Load Balanacer Controller IAM Policy to  IAM Role
# resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
#   policy_arn = aws_iam_policy.lbc_iam_policy.arn 
#   role       = aws_iam_role.lbc_iam_role.name
# }

# # Install AWS Load Balancer Controller using HELM

# # Resource: Helm Release 
# resource "helm_release" "loadbalancer_controller" {
#   depends_on = [aws_iam_role.lbc_iam_role]            
#   name       = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"

#   namespace = "kube-system"     

#   set {
#     name = "image.repository"
#     value = "602401143452.dkr.ecr.ap-south-1.amazonaws.com/amazon/aws-load-balancer-controller" # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
#   }       

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "${aws_iam_role.lbc_iam_role.arn}"
#   }

#   set {
#     name  = "vpcId"
#     value = "${data.terraform_remote_state.eks.outputs.vpc_id}"
#   }  

#   set {
#     name  = "region"
#     value = "${var.region}"
#   }    

#   set {
#     name  = "clusterName"
#     value = "${data.terraform_remote_state.eks.outputs.id}"
#   }    
    
# }