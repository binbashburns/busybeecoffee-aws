terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.35.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "my-sandbox"
  alias   = "source"
}

provider "aws" {
  region  = var.dest_region
  alias   = "dest"
  profile = "my-sandbox"
}

module "network" {
  source              = "./network"
  AlbSG               = module.security.AlbSG
  sourceCodeBucketArn = module.storage.sourceCodeBucketArn
  dbAsub              = module.database.dbAsub
  dbBsub              = module.database.dbBsub
  dbCsub              = module.database.dbCsub

  providers = {
    aws = aws.source
  }
}

module "security" {
  source              = "./security"
  vpc_id              = module.network.vpc_id
  sourceCodeBucketArn = module.storage.sourceCodeBucketArn
  destCodeBucketArn   = module.destStorage.destBucketArn
  busybeeProdBuildArn = module.tools.busybeeProdBuildArn
  repositoryArn       = module.containers.repositoryArn
  ecsClusterArn       = module.containers.ecsClusterArn
  ecsServiceArn       = module.containers.ecsServiceArn
  ecrRepoName         = module.containers.repositoryName
  source_region       = var.region
  dest_region         = var.dest_region
  destKmsArn          = module.destStorage.destKmsArn

  providers = {
    aws = aws.source
  }
}

module "compute" {
  source        = "./compute"
  publicSubnetA = module.network.publicSubnetA
  publicSubnetB = module.network.publicSubnetB
  publicSubnetC = module.network.publicSubnetC
  appA          = module.network.appA
  appB          = module.network.appB
  appC          = module.network.appC
  BastionSG     = module.security.BastionSG
  AppSG         = module.security.AppSG

  providers = {
    aws = aws.source
  }
}

module "containers" {
  source               = "./containers"
  ecsServiceRole       = module.security.ecsServiceRole
  myLabKeyPair         = module.compute.myLabKeyPair
  appA                 = module.network.appA
  appB                 = module.network.appB
  appC                 = module.network.appC
  EcsSG                = module.security.EcsSG
  ecsExecutionRoleArn  = module.security.ecsExecutionRoleArn
  ecsTaskRoleArn       = module.security.ecsTaskRoleArn
  ecsInstanceProfileId = module.security.EcsInstanceProfileId
  busybeeTG1Arn        = module.network.busybeeTG1Arn
  busybeeTG2Arn        = module.network.busybeeTG2Arn
  busybeeAlbArn        = module.network.busybeeAlbArn
  region               = var.region

  providers = {
    aws = aws.source
  }
}


module "tools" {
  source                     = "./tools"
  sourceCodeBucketName       = module.storage.sourceCodeBucketName
  codeBuildServiceRoleArn    = module.security.codeBuildServiceRoleArn
  codePipelineServiceRoleArn = module.security.codePipelineServiceRoleArn
  codeDeployServiceRoleArn   = module.security.codeDeployServiceRoleArn
  ecsClusterName             = module.containers.ecsClusterName
  ecsServiceName             = module.containers.ecsServiceName
  busybeeListenerArn         = module.network.busybeeListenerArn
  busybeeTG1                 = module.network.busybeeTG1
  busybeeTG2                 = module.network.busybeeTG2
  appA                       = module.network.appA
  appB                       = module.network.appB
  appC                       = module.network.appC
  EcsSG                      = module.security.EcsSG
  repositoryUrl              = module.containers.repositoryUrl
  taskFamily                 = module.containers.taskFamily
  region                     = var.region
  kmsArn                     = module.security.kmsArn

  providers = {
    aws = aws.source
  }
}

module "storage" {
  source               = "./storage"
  s3ReplicationRoleArn = module.security.s3ReplicationRoleArn
  destBucketArn        = module.destStorage.destBucketArn
  kmsArn               = module.security.kmsArn
  destKmsArn           = module.destStorage.destKmsArn

  providers = {
    aws = aws.source
  }
}

module "destStorage" {
  source = "./destStorage"
  providers = {
    aws = aws.dest
  }
}

module "database" {
  source              = "./database"
  vpc_id              = module.network.vpc_id
  dbAaz               = module.network.az1a
  dbBaz               = module.network.az1b
  dbCaz               = module.network.az1c
  dbSG                = module.security.dbSG
  

  providers = {
    aws = aws.source
  }
}
