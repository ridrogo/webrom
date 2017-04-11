# ModeradorBot beta
Bot de Telegram para Administrar grupos, tipo Group Butler
ModeradorBot código beta
-------------------------
Bot de telegram usando API.

Más información en la [API de Telegram](https://core.telegram.org/bots/api).


Clonar repositorio:

```bash
# Clonar ModeradorBot
git clone https://github.com/ridrogo/ModeradorBot.git
```
```bash
# Mover a directorio y cambiar permisos de arranque
cd ModeradorBot && chmod +x launch.sh
```
Instalar ModeradorBot Beta: 

```bash
# Tested on Ubuntu 16.04

$ wget https://raw.githubusercontent.com/ridrogo/ModeradorBot/beta/install.sh
$ bash install.sh
```
or

```bash
# Tested on Ubuntu 14.04, 15.04 and 16.04, Debian 7, Linux Mint 17.2

$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install libreadline-dev libssl-dev lua5.2 liblua5.2-dev git make unzip redis-server curl libcurl4-gnutls-dev

# We are going now to install LuaRocks and the required Lua modules

$ wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz
$ tar zxpf luarocks-2.2.2.tar.gz
$ cd luarocks-2.2.2
$ ./configure; sudo make bootstrap
$ sudo luarocks install luasec
$ sudo luarocks install luasocket
$ sudo luarocks install redis-lua
$ sudo luarocks install lua-term
$ sudo luarocks install serpent
$ sudo luarocks install dkjson
$ sudo luarocks install Lua-cURL
$ cd ..

# Clone the repository and give the launch script permissions to be executed
# If you want to clone the beta branch, use git clone with the [-b beta] option

$ git clone clone https://github.com/ridrogo/ModeradorBot.git
$ cd ModeradorBot && chmod +x launch.sh
```

Opciones de launch.sh (en TMUX):

```bash
# Iniciar una sesión tmux
./launch.sh

# Detener la sesiones (script de lectura de gbans, y script del bot. Tmux)
./launch.sh kill

# Attach del bot (regresar a la sesión del bot. Tmux)
./launch.sh attach

# Attach de los gbans (regresar a la sesión de los gbans. Tmux)
./launch.sh attach-gbans

# Configurar y/o crear de nuevo el config.lua
./launch.sh config

```



Envia tus pullrequest para mejorar el código.



Contacta conmigo en TG
--------------------
[![https://telegram.me/Webrom](https://img.shields.io/badge/Webrom-Telegram-blue.svg)](https://telegram.me/Webrom)
