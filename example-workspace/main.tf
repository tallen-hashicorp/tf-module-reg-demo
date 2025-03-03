terraform { 
  cloud { 
    organization = "tallen-demo" 

    workspaces { 
      name = "testing-for-demo" 
    } 
  }
  required_providers {
    random = {
      source = "tallen-demo/random"
      version = "3.7.1"
    }
  }
}

module "reg-demo-branch" {
  source  = "app.terraform.io/tallen-demo/reg-demo-branch/module"
  version = "1.0.2"
}

module "reg-demo-tag" {
  source  = "app.terraform.io/tallen-demo/reg-demo-tag/module"
  version = "1.0.2"
}