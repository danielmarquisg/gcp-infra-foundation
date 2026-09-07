plugin "google" {
  enabled = true
  version = "0.39.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Controles complementarios de calidad:
# - terraform fmt: comprueba el estilo.
# - terraform validate: comprueba que la configuración sea válida.
# - TFLint: busca sintaxis obsoleta, errores potenciales y malas prácticas.
