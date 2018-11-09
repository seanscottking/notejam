module "notejam" {
  source = "../../../modules/notejam"

  github_owner  = "${var.github_owner}"
  github_repo   = "${var.github_repo}"
  github_branch = "${var.github_branch}"
}
