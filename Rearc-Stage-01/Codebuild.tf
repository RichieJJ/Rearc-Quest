# ECR Repository to store Rearc Docker image

resource "aws_ecr_repository" "rearc-container-repo" {
  name = "rearc-container-repo"
}

resource "aws_codebuild_project" "rearc-codebuild-project" {
  name          = "rearc-codebuild-project"
  service_role  = aws_iam_role.rearc-codebuild-role.arn
  build_timeout = "10"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "REARC_QUEST_ECR_URL"
      value = aws_ecr_repository.rearc-container-repo.repository_url
    }
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/derekwolpert/rearc.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }
  source_version = "main"
}

resource "aws_codebuild_webhook" "rearc-codebuild-webhook" {
  project_name = aws_codebuild_project.rearc-codebuild-project.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "main"
    }
  }
}




## The AWS account that Terraform uses to create this resource 
## must have authorized CodeBuild to access Bitbucket/GitHub's OAuth 
## API in each applicable region. This is a manual step that must be 
## done before creating webhooks with this resource. If OAuth is not 
## configured, AWS will return an error similar to ResourceNotFoundException: 
## Could not find access token for server type github. More information can 
## be found in the CodeBuild User Guide for Bitbucket and GitHub.
