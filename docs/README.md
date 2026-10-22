# Documentación

Elige según lo que necesites hacer o consultar.

## Entender el diseño

- [Cómo funciona la infraestructura](architecture.md): por qué usamos VMs reemplazables, cómo arranca la aplicación y cómo llega el tráfico hasta ella.

## Desplegar y comprobar el entorno

- [Desplegar y borrar el entorno](deployment.md): configuración local, publicación de la imagen, despliegue, comprobaciones y borrado.
- [Prueba de autohealing](tests/autohealing.md): detener el servicio web y observar su recuperación automática.
- [Prueba de autoescalado](tests/autoscaling.md): generar y retirar carga de CPU para comprobar el cambio de tamaño del grupo.

Las pruebas incluyen los comandos, los resultados esperados y lo que observamos al ejecutarlas. Requieren un entorno desplegado y pueden generar costes.

## Consultar la configuración

- [Entradas de Terraform](reference/configuration.md): tipos, valores predeterminados y restricciones de las variables que acepta el proyecto.
- [Outputs de Terraform](reference/outputs.md): qué devuelve cada salida y cómo consultarla desde la terminal o un script.

Para una visión rápida del alcance y los componentes, vuelve al [README del proyecto](../README.md).
