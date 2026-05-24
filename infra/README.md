# Infraestrutura PGR Mental (Terraform)

Este diretório contém a definição de infraestrutura como código (IaC) utilizando o Terraform.

## Estrutura de Diretórios

```text
infra/
├── environments/
│   ├── dev/          # Ambiente de Desenvolvimento
│   ├── staging/      # Ambiente de Homologação (Staging)
│   └── prod/         # Ambiente de Produção
├── modules/          # Módulos reutilizáveis
└── README.md         # Esta documentação
```

## Requisitos
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- AWS CLI configurada com permissões adequadas

## Setup Inicial do Backend Remoto
O estado (`state`) do Terraform é armazenado remotamente no Amazon S3 com controle de concorrência e concorrência via DynamoDB. 
Antes do primeiro run, as seguintes tabelas e buckets precisam existir na conta AWS correspondente:

- **S3 Bucket**: `pgr-mental-tfstate-{env}`
- **DynamoDB Table**: `pgr-mental-tflocks-{env}` (Chave primária deve ser `LockID` do tipo String)

## Como Executar

1. Navegue para a pasta do ambiente desejado:
   ```bash
   cd infra/environments/dev
   ```

2. Inicialize o Terraform:
   ```bash
   terraform init
   ```

3. Planeje as alterações:
   ```bash
   terraform plan
   ```

4. Aplique as alterações (requer confirmação):
   ```bash
   terraform apply
   ```
