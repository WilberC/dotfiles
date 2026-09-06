# Herdr, Node y `localhost` en puertos de desarrollo

Este documento registra un problema resuelto al acceder desde Windows a un
servidor de desarrollo que se ejecuta en `hfk`/Forge dentro de una sesión
remota de Herdr.

La solución se aplica de forma global desde la configuración compartida de
Fish, por lo que los proyectos Node no necesitan una configuración especial
por repositorio.

## Contexto del entorno

El flujo de red involucrado es:

```text
Navegador en Windows
        │ localhost
        ▼
WSL2 local
        │ cliente Herdr + conexión SSH persistente
        ▼
hfk / Forge
        │ servidor de desarrollo
        ▼
Aplicación Node, Vite o Django
```

Herdr se inicia con un remote attach hacia Forge. La sesión remota ejecuta
los procesos y Herdr crea forwards SSH para varios puertos de desarrollo,
entre ellos `5173` para Vite y `8000` para Django.

## Síntomas

Vite se iniciaba normalmente en el entorno remoto:

```text
VITE ready
Local: http://localhost:5173/
```

Sin embargo, Windows mostraba:

```text
This site can't be reached
```

El puerto de Django sí parecía accesible. Abrir `http://127.0.0.1:8000/`
devolvía la página de error 404 de Django con sus rutas URL. Ese 404 era una
señal positiva: la petición estaba llegando correctamente al servidor
remoto; simplemente la ruta `/` no estaba definida.

## Diagnóstico

La inspección de los listeners en Forge mostró que Vite estaba escuchando en
el loopback IPv6:

```text
[::1]:5173
```

El forward automático de Herdr para `5173` estaba intentando alcanzar el
loopback IPv4 remoto:

```text
127.0.0.1:5173
```

Por eso el túnel existía, pero su destino no coincidía con la dirección donde
Vite estaba escuchando.

La causa no era que el servidor estuviera ejecutándose en el WSL2 local ni
que faltara un túnel. Era una diferencia de resolución de `localhost` entre
Node/Vite y el destino IPv4 utilizado por el forward SSH.

Como comprobación, se creó temporalmente un forward hacia IPv6:

```bash
ssh -S /tmp/herdr-ssh-<pid>-0/ctl \
    -F /tmp/herdr-ssh-<pid>-0/config \
    -O forward \
    -L 127.0.0.1:5174:[::1]:5173 forge
```

El acceso a `http://localhost:5174/` respondió con HTTP `200`, confirmando
que la aplicación y la conexión SSH funcionaban.

## Causa técnica

Node.js 17 cambió el orden predeterminado de resultados DNS de `ipv4first` a
`verbatim`. En este entorno, la resolución de `localhost` podía priorizar
`::1` sobre `127.0.0.1`.

Vite usa `localhost` como host predeterminado. Si Node inicia el servidor en
IPv6 y el túnel SSH intenta conectarse por IPv4, ambos componentes usan
`localhost`, pero terminan hablando con endpoints distintos.

La documentación de Vite advierte explícitamente que el orden DNS de Node y
la dirección elegida por el navegador pueden diferir de la dirección donde
Vite está escuchando. Node permite controlar ese orden con
`--dns-result-order`.

## Solución aplicada

La configuración compartida de Fish exporta ahora esta opción en
[`shared/.config/fish/conf.d/00-env.fish`](../shared/.config/fish/conf.d/00-env.fish):

```fish
set -gx NODE_OPTIONS "--dns-result-order=ipv4first"
```

La configuración conserva otras opciones existentes de `NODE_OPTIONS` y no
duplica la opción si ya está presente.

De esta forma, cualquier proceso Node iniciado desde Fish —incluidos Vite y
los scripts ejecutados mediante `mise`— prioriza IPv4 al resolver
`localhost`. Los proyectos pueden continuar usando su comando normal:

```fish
mise run dev
```

No es necesario añadir `--host 0.0.0.0` ni modificar cada repositorio.

## Aplicación en una máquina nueva

Después de actualizar el repositorio, instalar o actualizar los enlaces de
Stow compartidos:

```bash
bash scripts/stow-shared.sh
```

Recargar Fish o abrir una nueva shell:

```fish
source ~/.config/fish/conf.d/00-env.fish
```

Verificar la variable:

```fish
echo $NODE_OPTIONS
```

El resultado debe contener:

```text
--dns-result-order=ipv4first
```

## Verificación posterior

En el entorno remoto, iniciar el proyecto sin argumentos especiales:

```fish
mise run dev
```

Desde Windows, abrir:

```text
http://localhost:5173/
```

Si Django devuelve un 404 para `/`, comprobar las rutas disponibles antes de
considerarlo un fallo de conectividad. Una respuesta HTTP de Django confirma
que el forward está funcionando.

## Alcance y límites

Esta solución está pensada para procesos Node que usan `localhost` y respetan
el orden DNS configurado por Node. No cambia servidores configurados
explícitamente para escuchar en `::1`, `0.0.0.0` u otra dirección.

La solución estructural alternativa sería que Herdr detectara la familia de
direcciones del listener remoto o que permitiera configurar el destino IPv6
del forward. Mientras eso no esté disponible, `NODE_OPTIONS` resuelve el caso
de forma global y evita ajustes específicos en cada proyecto.

## Referencias

- [Documentación DNS de Node.js](https://nodejs.org/api/dns.html)
- [Opciones de servidor de Vite](https://vite.dev/config/server-options.html)
- [Configuración de Herdr](herdr.md)
