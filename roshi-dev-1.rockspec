package = "roshi"
version = "dev-1"
source = {
   url = "git+https://github.com/holson1/roshi.git"
}
description = {
   summary = "`luarocks install watcher``lua build.lua`",
   detailed = [[
`luarocks install watcher`
`lua build.lua`
]],
   homepage = "https://github.com/holson1/roshi",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.4",
   "watcher >= 0.2.0-0",
   "busted >= 2.0.0-1"
}
build = {
   type = "builtin",
   modules = {
      char = "src/char.lua",
      controller = "src/controller.lua",
      ["enemies.evil_goomba"] = "src/enemies/evil_goomba.lua",
      ["enemies.goomba"] = "src/enemies/goomba.lua",
      ["enemies.lamia"] = "src/enemies/lamia.lua",
      hud = "src/hud.lua",
      items = "src/items.lua",
      levels = "src/levels.lua",
      ["lib.dust"] = "src/lib/dust.lua",
      ["lib.group"] = "src/lib/group.lua",
      ["lib.util"] = "src/lib/util.lua",
      log = "src/log.lua",
      main = "src/main.lua",
      map = "src/map.lua",
      ["objects.boom"] = "src/objects/boom.lua",
      ["objects.shot"] = "src/objects/shot.lua"
   }
}
