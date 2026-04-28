fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/ak47.png',
    'html/images/drug.png'

}

client_script 'client.lua'
server_script {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}