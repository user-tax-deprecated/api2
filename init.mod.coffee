#!/usr/bin/env coffee

> path > join dirname
  fs > existsSync symlinkSync lstatSync realpathSync rmSync
  js-yaml:yaml
  utax/read
  @rmw/thisdir


ROOT = thisdir import.meta
SRC = join ROOT, 'src'
BASE = dirname ROOT
MOD_YML = join SRC,'mod.yml'
if not existsSync MOD_YML
  console.log MOD_YML, "not exist\ncopy #{SRC}/mod.example.yml to mod.yml"
  process.exit(1)
MOD_YML = yaml.load read MOD_YML

< default main = =>
  exist = new Set
  for [dir, li] from Object.entries MOD_YML
    root = join BASE, dir
    mod_yml = join root, 'mod.yml'
    if existsSync mod_yml
      dict = yaml.load(
        read mod_yml
      )
      for i from li
        if i of dict
          for mod from dict[i]
            if exist.has mod
              console.log dir, mod, 'conflict'
              continue
            exist.add mod
            to = join root, mod
            console.log to
            src_mod = join SRC,mod
            if existsSync src_mod
              stat = lstatSync(src_mod)
              if stat.isSymbolicLink()
                if realpathSync(src_mod) == join(BASE,dir,mod)
                  continue
              rmSync(src_mod, {recursive: true, force: true})
            symlinkSync(
              join '../..',dir,mod
              join src_mod
            )
        else
          console.warn mod_yml, '>', i,'NOT EXIST'
    else
      console.warn mod_yml,'NOT EXIST'
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()

