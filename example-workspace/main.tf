terraform { 
  cloud { 
    organization = "tallen-demo" 

    workspaces { 
      name = "testing-for-demo" 
    } 
  } 
}

module "reg-demo-branch" {
  source  = "app.terraform.io/tallen-demo/reg-demo-branch/module"
  version = "1.0.1"
}

module "reg-demo-tag" {
  source  = "app.terraform.io/tallen-demo/reg-demo-tag/module"
  version = "1.0.1"
}