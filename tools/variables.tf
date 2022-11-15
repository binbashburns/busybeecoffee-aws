variable "sourceCodeBucketName" {
  type = string
}

variable "codeBuildServiceRoleArn" {
  type = string
}

variable "codePipelineServiceRoleArn" {
  type = string
}

variable "codeDeployServiceRoleArn" {
  type = string
}

variable "ecsClusterName" {
  type = string
}

variable "ecsServiceName" {
  type = string
}

variable "busybeeListenerArn" {
  type = string
}

variable "busybeeTG1" {
  type = string
}

variable "busybeeTG2" {
  type = string
}

variable "EcsSG" {
  type = string
}

variable "appA" {
  type = string
}

variable "appB" {
  type = string
}

variable "appC" {
  type = string
}

variable "repositoryUrl" {
  type = string
}

variable "taskFamily" {
  type = string
}

variable "kmsArn" {
  type = string

}

variable "region" {
  type = string
}

variable "dest_region" {
  type    = string
  default = "us-west-2"
}

variable "destProviderAlias" {
  type    = string
  default = "aws.dest"
}