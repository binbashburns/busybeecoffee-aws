variable "vpc_id" {
  type = string
}

variable "sourceCodeBucketArn" {
  type = string
}

variable "destCodeBucketArn" {
  type = string
}

variable "busybeeProdBuildArn" {
  type = string
}

variable "ecsClusterArn" {
  type = string
}

variable "repositoryArn" {
  type = string
}

variable "ecsServiceArn" {
  type = string
}

variable "ecrRepoName" {
  type = string
}

variable "source_region" {
  type = string
}

variable "dest_region" {
  type = string
}

variable "destKmsArn" {
  type = string
}