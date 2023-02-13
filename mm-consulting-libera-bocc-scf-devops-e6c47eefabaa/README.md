
# Proyecto de DevOps para adaptación de Libera a Banco de Occidente

Éste proyecto incluye las configuraciones para:

- La creación de la infraestructura en la nube del proyecto.
- Configuraciones para los procesos CI/CD.
- Habilitar a un desarrollador en la ambientación de su computadora personal.

## Cómo desplegar la infraestructura  

### Desde un equipo Windows.

Prerrequisitos:  

1. Se d[ebe contar con Docker for Windows instalado.
2. Clonar todos los repositorios dentro de una sola ubicación:
- [Frontends](https://bitbucket.org/mm-consulting/libera-bocc-scf-admin-portal)
- [Documentación de APIs](https://bitbucket.org/mm-consulting/libera-bocc-scf-apis)
- [BPM](https://bitbucket.org/mm-consulting/libera-bocc-scf-bpm)
- [Backend del BPM](https://bitbucket.org/mm-consulting/libera-bocc-scf-bpm-services)
- [Backend de los frontends principales](https://bitbucket.org/mm-consulting/libera-bocc-scf-core-rest)
- [Proyecto DevOps](https://bitbucket.org/mm-consulting/libera-bocc-scf-devops)
3. Se debe contar con una variable de ambiente LIBERA_BOCC_HOME configurada al directorio donde se encuentren clonados todos los repositorios.
4. Iniciar una terminal de línea de comandos. Ejemplo: MS-DOS y ubicar la terminal en el volumen donde se encuentren los repositorios. Ejemplo `D:`
5. Construir imagen de despliegue y crear un contenedor desde ella  
	``` 
	cd %LIBERA_BOCC_HOME%\libera-bocc-scf-devops\v2\docker-environment 
	build-image.bat 
	run-container.bat 
	```
6. Eliminar el contenedor de despliegue: 
     ```
     cd %LIBERA_BOCC_HOME%\libera-bocc-scf-devops\v2\docker-environment 
     remove-container.bat
	  ```