variable "accounts" {
    type = map(string)
    description = "Mapping of aliases->IAM roles of accounts to rollout plans to"
    default = {}
}