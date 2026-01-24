fx_version 'cerulean'
game 'gta5'

author 'Luqyno'
description 'Simple hat and glasses drops pickup'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_lib',
    'ox_target'
}