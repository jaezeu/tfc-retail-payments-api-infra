# tfc-retail-payments-api-infra

Terraform infrastructure for the **Retail Payments API** across two environments:

- `nonprod`
- `prod`

Each environment is split into two Terraform layers:

- `storage` (DynamoDB)
- `compute` (Lambda + API Gateway)

The stacks are configured to run with **HCP Terraform (Terraform Cloud)** workspaces.

## Architecture

### Storage layer

The storage layer provisions a DynamoDB table via `modules/storage/dynamodb`.

- Table name pattern: `<business_unit>-<app_name>-storage-<env>-ddb`
- Default billing mode: `PAY_PER_REQUEST`
- Hash key: `pk`
- PITR: currently `false` in both environments

Outputs:

- `dynamodb_table_name`
- `dynamodb_table_arn`

### Compute layer

The compute layer provisions:

- IAM role and policies for Lambda
- Python Lambda function (`python3.12`)
- API Gateway HTTP API (`$default` stage, auto deploy)
- Lambda invoke permission for API Gateway

The compute stack reads DynamoDB outputs using `tfe_outputs` from the matching storage workspace.

Output:

- `api_endpoint`

## Repository layout

```text
envs/
	non-prod/
		storage/   -> workspace: retail-payments-api-storage-nonprod
		compute/   -> workspace: retail-payments-api-compute-nonprod
	prod/
		storage/   -> workspace: retail-payments-api-storage-prod
		compute/   -> workspace: retail-payments-api-compute-prod

modules/
	storage/dynamodb
	compute/lambda-apigw
```

## Prerequisites

- Terraform `>= 1.6.0`
- AWS credentials with permissions for:
	- DynamoDB
	- IAM
	- Lambda
	- API Gateway v2
- Access to HCP Terraform organization: `hcp-poc-jazeel`
- HCP Terraform workspaces listed above created and accessible

## Deployment order

Because compute depends on storage outputs, apply in this order per environment:

1. `storage`
2. `compute`

### Non-prod

```bash
cd envs/non-prod/storage
terraform init
terraform plan
terraform apply

cd ../compute
terraform init
terraform plan
terraform apply
```

### Prod

```bash
cd envs/prod/storage
terraform init
terraform plan
terraform apply

cd ../compute
terraform init
terraform plan
terraform apply
```

## Variables

### Environment stack variables (`envs/*/*/variables.tf`)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `business_unit` | `string` | `retail` | Business prefix used in naming |
| `app_name` | `string` | `payments-api` | Application name |
| `env` | `string` | `nonprod` or `prod` | Environment identifier |
| `tags` | `map(string)` | `{ owner = "personal-poc" }` | Base resource tags |

### Module inputs

#### `modules/storage/dynamodb`

| Name | Type | Default |
|------|------|---------|
| `table_name` | `string` | n/a |
| `hash_key` | `string` | `pk` |
| `enable_pitr` | `bool` | `false` |
| `billing_mode` | `string` | `PAY_PER_REQUEST` |
| `tags` | `map(string)` | `{}` |

#### `modules/compute/lambda-apigw`

| Name | Type | Default |
|------|------|---------|
| `business_unit` | `string` | n/a |
| `app_name` | `string` | n/a |
| `layer` | `string` | n/a |
| `env` | `string` | n/a |
| `dynamodb_table_name` | `string` | n/a |
| `dynamodb_table_arn` | `string` | n/a |
| `tags` | `map(string)` | `{}` |

## Outputs

### Storage stacks

- `dynamodb_table_name`
- `dynamodb_table_arn`

### Compute stacks

- `api_endpoint`

## API quick test

After compute apply, get the endpoint output and run:

```bash
# Health
curl "$API_ENDPOINT/"

# Put item
curl -X PUT "$API_ENDPOINT/items/123" \
	-H "content-type: application/json" \
	-d '{"amount":100,"currency":"SGD"}'

# Get item
curl "$API_ENDPOINT/items/123"
```

## Notes

- Region is currently fixed to `ap-southeast-1` in each environment provider.
- Compute workspaces use `tfe_outputs` data sources to read from storage workspaces.
- If workspace names or organization change, update `versions.tf` / `data.tf` accordingly.