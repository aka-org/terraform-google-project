plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Checks values against what Google Cloud accepts (machine types, regions,
# resource name formats) wherever they are written out in the code.
plugin "google" {
  enabled = true
  version = "0.41.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
