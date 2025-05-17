# Changelog
All notable changes to this project will be documented in this file.

## 0.3.0
### ADDED
- Allow gha provider partially match repo based on `gha_wif_org` when `gha_wif_repo` is an empty string.
- Allow state bucket to be created even if `gcs_backend` is set to false. 

## 0.2.0
### ADDED
- Introduces support for Github Actions identity provider

### Fixed
- Missing condition check for feature toggle in bucket outputs
 
## 0.1.0
### ADDED
- Initial release of the terraform-google-project module.
