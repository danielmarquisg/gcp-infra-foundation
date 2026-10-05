#!/usr/bin/env bash
set -euo pipefail

# Usamos la raíz del proyecto aunque el script se lance desde otro directorio.
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$project_dir"

if ! command -v terraform >/dev/null 2>&1; then
  printf 'No se encuentra Terraform. Instálalo antes de continuar.\n' >&2
  exit 1
fi

if [[ $# -ne 0 ]]; then
  printf 'Uso: %s (sin argumentos)\n' "$0" >&2
  exit 1
fi

printf 'Preparación de Artifact Registry. No despliega VMs ni balanceador.\n'
printf 'Utiliza las credenciales y la configuración local de Terraform.\n\n'

terraform init -input=false

# El plan puede contener datos sensibles; lo guardamos fuera del repositorio y lo retiramos al salir.
plan_dir="$(mktemp -d)"
plan_file="$plan_dir/registry-bootstrap.tfplan"
trap 'rm -f -- "$plan_file"; rmdir -- "$plan_dir"' EXIT

# -target se limita al arranque del registro; los despliegues web utilizan planes completos.
terraform plan -input=false -lock-timeout=30s -target=module.artifact_registry -out="$plan_file"

printf '\nEl almacenamiento de imágenes puede generar costes; este script no publica imágenes.\n'
printf 'Revisa el plan. ¿Quieres aplicarlo? [y/n]: '
confirmation=""
read -r confirmation || confirmation=""

case "$confirmation" in
  y|Y)
    # Aplicamos exactamente el plan revisado, no generamos otro distinto.
    terraform apply "$plan_file"
    printf '\nRepositorio: '
    terraform output -raw artifact_registry_url
    printf '\n'
    ;;
  *)
    printf 'Cancelado. No se ha aplicado el plan.\n'
    ;;
esac
