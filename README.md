# TF Module Registry Demo  

## Agenda  
- [ ] Module Registry Overview  
- [ ] How to Publish and Upgrade Tag-Based Modules  
- [ ] How to Publish and Upgrade Branch-Based Modules  
- [ ] Using a Module on air gapped ec2 instance

---  

## Registry Overview  
HCP Terraform and Terraform Enterprise (TFE) include a **private module registry** available to all accounts. Unlike the public Terraform Registry, the private registry allows:  

* Importing **modules and providers** from private VCS repositories  
* Uploading and managing **private, custom providers** via API  
* Curating a list of **commonly used public modules and providers**  

The private registry works with any of **HCP Terraform's supported VCS providers** (GitHub, GitLab, Bitbucket, Azure DevOps, etc.), making it easy to manage and distribute reusable Terraform modules securely.  

---  

## Links  
- **Branch-Based Module:** [terraform-module-reg-demo-branch](https://github.com/tallen-hashicorp/terraform-module-reg-demo-branch)  
- **Tag-Based Module:** [terraform-module-reg-demo-tag](https://github.com/tallen-hashicorp/terraform-module-reg-demo-tag)  

---  

## Creating Modules in the Registry  
1. Navigate to **Registry** in Terraform Cloud  
2. Click **Publish > Module > GitHub App**  
3. Select the repositories:  
   - `terraform-module-reg-demo-tag`  
   - `terraform-module-reg-demo-branch`  

Terraform Cloud will scan the repositories and automatically detect **module versions** based on tags (`vX.Y.Z`) or branch names (e.g., `main`).  

---  

## Adding provider the Registry
You can download a public provider and re-upload it to your private registry. There are a few differences in the workflow for re-uploading a public HashiCorp provider. In this example, you will download the Random provider and re-upload it to your private registry. You can use the same workflow for any official HashiCorp provider. More details on this process can be found [here](https://developer.hashicorp.com/terraform/enterprise/registry/airgapped-providers)

First, download the `SHASUMS` file. This file contains a SHA256 checksum for each build of this specific provider version.
```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_SHA256SUMS
```

Next, download the `SHA256SUMS.72D7468F.sig` file. This file is a GPG binary signature of the `SHA256SUMS` file.
```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig
```

Finally, download the `linux_amd64` build of the provider binary.
```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_linux_amd64.zip
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_darwin_arm64.zip
```

Next we will use [TFx](https://tfx.rocks/) to upload the provider to TFC. The initial focus of tfx was to execute the API-Driven workflow for a Workspace but has grown to manage multiple aspects of the platform. First we will insteall TFX if you do not already have it, below is the mac install instructions however you can find more install instructions [here](https://tfx.rocks/)

```bash
brew install straubt1/tap/tfx
```

Before we create and upload the provider we need to get the `keyid` from the signatrue:
```bash
gpg --list-packets terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig | grep "keyid"
```
note this down for later

Now lets create our new provider, more details on this can be found [here](https://tfx.rocks/commands/registry_provider/)
```bash
export TFE_ORGANIZATION="tallen-demo"
export TFE_TOKEN="YOUR TOKEN"
tfx registry provider create --name random
```

Now we'll upload the provider binary, we'll use the `keyid` we got ealier for this
```bash
tfx registry provider version create --name random --version 3.7.1 --key-id C820C6D5CD27AB87 --shasums ./terraform-provider-random_3.7.1_SHA256SUMS --shasums-sig=./terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig
```

finnaly we'll create the platofrms
```bash
tfx registry provider version platform create --name random --version 3.7.1 --os linux --arch amd64 -f ./terraform-provider-random_3.7.1_linux_amd64.zip
```

If you are using a mac, you can also run
```bash
tfx registry provider version platform create --name random --version 3.7.1 --os darwin --arch arm64 -f ./terraform-provider-random_3.7.1_darwin_arm64.zip
```

---

## Testing the Module Registration  
Run the following commands to initialize and apply the module in an example workspace:  

```bash
cd example-workspace
terraform init
terraform apply
cd ..
```

# Create Air Gapped EC2  

This setup uses an **existing SSH key** named `tyler`.  
🔹 **Update** the SSH key in `main.tf` on **line 16** if needed.  
🔹 **Ensure** your AWS environment variables are set before proceeding.  

## Deploy the EC2 Instance  
Run the following commands:  

```bash
cd ec2-airgapped-instance
terraform init
terraform apply
```

## Connect to the New EC2 Instance
Once the instance is created, SSH into it using:

```bash
ssh ubuntu@OUTPUT_IP
```

Replace OUTPUT_IP with the actual instance's public or private IP.

## Run the Terraform Module in an Air Gapped Instance

The EC2 instance uses UFW to restrict outbound connections only to `99.83.150.238` and `75.2.98.97`. This setup ensures we can test Terraform functionality in an air gapped environment while still allowing access to Terraform Cloud.

### Steps to Initialize and Run the Module

```bash
cd /home/ubuntu/tf-module-reg-demo/example-workspace

terraform login
terraform init

terraform plan
```