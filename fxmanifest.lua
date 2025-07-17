fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'zrx_tracker'
author 'zRxnx'
version '1.0.1'
description 'Advanced tracker system'
repository 'https://github.com/zrxnx/zrx_tracker'

docs 'https://docs.zrxnx.at'
discord 'https://discord.gg/mcN25FJ33K'

dependencies {
    '/server:6116',
    '/onesync',
	'ox_lib',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',
    'utils.lua',
    'configuration/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}