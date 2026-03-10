# Anexos — Virtualización del puesto de trabajo y gestión de su ciclo de vida

Repositorio de scripts, configuraciones y extractos de código asociados al Trabajo Fin de Grado *"Virtualización del puesto de trabajo y gestión de su ciclo de vida"*, presentado en la Universidad Internacional de La Rioja (UNIR), Grado en Ingeniería Informática.

> **Nota:** todos los ficheros han sido anonimizados. Las direcciones IP, nombres de dominio, nombres de usuario, rutas internas y cualquier dato que permita identificar al organismo han sido sustituidos por valores ficticios. La lógica y la estructura de los scripts se mantienen intactas.

---

## Contenido del repositorio

| Fichero | Descripción | Sección del TFG |
|---|---|---|
| `actualiza_conf_correo.php` | Script php que lanza el script shell que actualiza las direcciones de correo en postfix. | 4.4.7 |
| `arranca_pcv.php` | Script php que arranca un PCV tras ser creado. | 4.5.3 |
| `crea_pcv_usuario.php` | Script php que lanza la creación del PCV del usuario. | 4.5.3 |
| `crea_usuario_windows.php` | Script php que ejecuta la creación de la cuenta de usuario en Windows/AD. | 4.5.3 |
| `crea_pcvs.sh` | Script bash para lanzar la creacion en batch de varios PCVs | 4.5.3 |
| `customize.cmd` | Script de personalización que se ejecuta durante el primer arranque del escritorio virtual desplegado. Configura permisos RDP para el usuario asignado, establece la etiqueta del volumen C:\ y se autodestruye tras la ejecución. | 4.1.4 |
| `debloat_w11.ps1` | Script de limpiado de configuraciones de Windows 11 | 4.1.2 |
| `desplegar_aplicacion.php` | Script php que permite al equipo de soporte instalar aplicaciones sin entrar en PDQ | 4.9.3 |
| `fix_sysprep.ps1` | Script Powershell que arregla alguno de los problemas de la plantilla cuando no funciona sysprep | 4.1.6 |
| `generar_ldf.php` | Script php que crea un fichero ldf para generar el usuario en el dominio | 4.5.3 |
| `insert_usuario.php` | Script php que ejecuta la creación de un usuario con el fichero ldf creado en el script generar_ldf.php | 4.5.3 |
| `rearranca_pcv_usuario.php` | Script php que permite al equipo de soporte reiniciar un PCV que se ha colgado| 4.5.5 |
| `uninstall_onedrive.ps1` | Script PowerShell para la desinstalación completa de OneDrive del sistema, incluyendo la eliminación de residuos en el registro y en el sistema de archivos. | 4.1.2 |
| `uninstall_winapps.ps1` | Script PowerShell para la desinstalación de diferentes aplicaciones UWP/MSIX que vienen por defecto con Windows | 4.1.3 |
| `upgradew11.ps1` | Script PowerShell desplegado mediante PDQ Deploy que automatiza la migración in-place de Windows 10 a Windows 11: verificación de prerrequisitos, descarga de la imagen ISO, ejecución del setup desatendido y validación post-migración. | 4.9.4 |
| `vm_cold_restart_vm.ps1` | Script powercli que reinicia de forma forzada un PCV | 4.5.5 |
| `vm_crea_pcv.ps1` | Script powercli que crea un PCV en vCenter | 4.5.3 |
| `vm_get_mac.ps1` | Script powercli que devuelve la MAC de un PCV | 4.5.3 |
| `vm_get_state.ps1` | Script powercli que devuelve si un PCV está encendido o no | 4.5.3 |
| `vm_restart_vm.ps1` | Script que reinicia de forma ordenada un PCV | 4.5.5 |
| `vm_start_vm.ps1` | Script que arranca un PCV | 4.5.3 |
| `vpnfase3.ps1` | Script que arranca un PCV | 4.8.6 |

---

## Requisitos

Los scripts PowerShell requieren:

- PowerShell 5.1 o superior.
- Módulo **VMware PowerCLI** (scripts 04 y 06).
- Módulo **ActiveDirectory** (scripts 04, 09 y 12).
- Permisos de administrador de dominio o delegados según el script.

La aplicación PHP (09) se ejecuta sobre un servidor web con acceso a la base de datos Oracle 19c del organismo y conectividad con Active Directory, vCenter Server y el servidor DHCP.

---

## Uso

Estos scripts se proporcionan como referencia académica del Trabajo Fin de Grado. No están diseñados para su ejecución directa en otros entornos sin una adaptación previa a la infraestructura de destino.

---

## Licencia

El código contenido en este repositorio se publica con fines exclusivamente académicos como material complementario del TFG. Queda prohibida su reproducción o distribución fuera de este contexto sin autorización del autor.

---

## Autor

David Las Heras Jiménez — Grado en Ingeniería Informática, UNIR.
