--[[----------------------------------
Creation Date:	14/06/2021
]]------------------------------------
fx_version 'cerulean'
game 'gta5'
author 'Leah#0001'
version '1.0'

shared_scripts {
	'@es_extended/imports.lua'
}

server_scripts {
	'server.lua'
}

client_scripts {
    'cl_creation.lua',
    'cl_functions.lua'
} 

dependencies {
	'bixbi_core'
}