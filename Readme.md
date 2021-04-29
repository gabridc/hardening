Requisitos

    Disponer de conexión a internet

    Clone del repositorio ​ 

git clone https://github.com/gabridc/hardening

  3. Clone del repositorio ​ 
cd hardening
git clone https://github.com/gabridc/pentesting-tools
Uso

Ejecutar el script audit.sh

Este script checkea:

    Hostname de la maquina distinto de localhost

    Listado de paquetes RPMs

    Revisar usuarios con capacidad para logearse en el sistema

    Revisar usuarios con capacidad para conectar por SSH

    Ficheros de logs disponibles

    Servicios activos

    Binarios con flag SUID vulnerables

Tras su ejecución reporta los resultados en un zip cuyo nombre es el nombre del hostname de la maquina