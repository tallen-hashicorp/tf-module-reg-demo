# TF Module Registry Demo  

## 📌 Agenda  
- [ ] Module Registry Overview  
- [ ] How to Publish and Upgrade Tag-Based Modules  
- [ ] How to Publish and Upgrade Branch-Based Modules  
- [ ] Using a Module on a Local Laptop with Public Registry Access Blocked  

---  

## 🔍 Registry Overview  
HCP Terraform and Terraform Enterprise (TFE) include a **private module registry** available to all accounts. Unlike the public Terraform Registry, the private registry allows:  

✅ Importing **modules and providers** from private VCS repositories  
✅ Uploading and managing **private, custom providers** via API  
✅ Curating a list of **commonly used public modules and providers**  

The private registry works with any of **HCP Terraform's supported VCS providers** (GitHub, GitLab, Bitbucket, Azure DevOps, etc.), making it easy to manage and distribute reusable Terraform modules securely.  

---  

## 🔗 Links  
- **Branch-Based Module:** [terraform-module-reg-demo-branch](https://github.com/tallen-hashicorp/terraform-module-reg-demo-branch)  
- **Tag-Based Module:** [terraform-module-reg-demo-tag](https://github.com/tallen-hashicorp/terraform-module-reg-demo-tag)  

---  

## 🚀 Creating Modules in the Registry  
1. Navigate to **Registry** in Terraform Cloud  
2. Click **Publish > Module > GitHub App**  
3. Select the repositories:  
   - `terraform-module-reg-demo-tag`  
   - `terraform-module-reg-demo-branch`  

Terraform Cloud will scan the repositories and automatically detect **module versions** based on tags (`vX.Y.Z`) or branch names (e.g., `main`).  

---  

## 🛠️ Testing the Module Registration  
Run the following commands to initialize and apply the module in an example workspace:  

```bash
cd example-workspace
terraform init
terraform apply
