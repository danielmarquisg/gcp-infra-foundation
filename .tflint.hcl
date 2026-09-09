# Añadimos reglas de GCP a las reglas generales de Terraform que TFLint incluye por defecto.
# En modo recursivo, cada directorio busca su configuración; la de la raíz no se hereda automáticamente.
plugin "google" {
  enabled = true
  version = "0.39.0" # Fijada para reproducir el análisis local y en CI; es distinta del provider Google.
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Controles complementarios de calidad:
# - terraform fmt -check: comprueba el estilo; sin -check reformatea los archivos.
# - terraform validate: comprueba que la configuración sea válida.
# - TFLint: busca sintaxis obsoleta, errores potenciales y malas prácticas.
