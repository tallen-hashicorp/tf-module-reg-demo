## TF Module Registry Demo

## Agenda
- [ ] Module Registry Overview
- [ ] How to publish and upgrade Tag based modules
- [ ] How to publish and upgrade Branch based modules
- [ ] Using module on local laptop with access to public registry blocked

## Registry Overview
HCP Terraform and TFE includes a private registry that is available to all accounts. Unlike the public registry, the private registry can import modules and providers from your private VCS repositories on any of HCP Terraform's supported VCS providers. It also lets you upload and manage private, custom providers through the HCP Terraform API and curate a list of commonly-used public providers and modules.