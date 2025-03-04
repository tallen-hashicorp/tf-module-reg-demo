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

## Adding a Provider to the Registry

You can download a public provider and re-upload it to your private registry. There are a few differences in the workflow for re-uploading a public HashiCorp provider. In this example, you will download the `random` provider and re-upload it to your private registry. You can use the same workflow for any official HashiCorp provider. More details on this process can be found [here](https://developer.hashicorp.com/terraform/enterprise/registry/airgapped-providers).

### Step 1: Download the Provider Files

First, download the `SHA256SUMS` file, which contains a SHA256 checksum for each build of this specific provider version:

```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_SHA256SUMS
```

Next, download the `SHA256SUMS.72D7468F.sig` file, which is a GPG binary signature of the `SHA256SUMS` file:

```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig
```

Finally, download the provider binaries for the required platforms:

```bash
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_linux_amd64.zip
wget https://releases.hashicorp.com/terraform-provider-random/3.7.1/terraform-provider-random_3.7.1_darwin_arm64.zip
```

### Step 2: Install `tfx`

We will use [TFx](https://tfx.rocks/) to upload the provider to Terraform Cloud (TFC). TFx was originally designed to execute the API-driven workflow for a workspace but has expanded to manage multiple aspects of the platform.

Install `tfx` using Homebrew (for macOS):

```bash
brew install straubt1/tap/tfx
```

For other installation methods, refer to the [TFx installation guide](https://tfx.rocks/).

### Step 3: Extract the `keyid`

Before creating and uploading the provider, retrieve the `keyid` from the signature file:

```bash
gpg --list-packets terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig | grep "keyid"
```

Make a note of the `keyid` for later use.

### Step 4: Create the Provider in the Registry

Set up the necessary environment variables:

```bash
export TFE_ORGANIZATION="tallen-demo"
export TFE_TOKEN="YOUR_TFC_TOKEN"
```

Create the provider:

```bash
tfx registry provider create --name random
```

### Step 5: Upload the Provider Binary

Upload the provider binary using the `keyid` retrieved earlier:

```bash
tfx registry provider version create \
  --name random \
  --version 3.7.1 \
  --key-id C820C6D5CD27AB87 \
  --shasums ./terraform-provider-random_3.7.1_SHA256SUMS \
  --shasums-sig ./terraform-provider-random_3.7.1_SHA256SUMS.72D7468F.sig
```

### Step 6: Create Platform Entries

Register the Linux `amd64` platform:

```bash
tfx registry provider version platform create \
  --name random \
  --version 3.7.1 \
  --os linux \
  --arch amd64 \
  -f ./terraform-provider-random_3.7.1_linux_amd64.zip
```

If using macOS with an `arm64` architecture, also run:

```bash
tfx registry provider version platform create \
  --name random \
  --version 3.7.1 \
  --os darwin \
  --arch arm64 \
  -f ./terraform-provider-random_3.7.1_darwin_arm64.zip
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