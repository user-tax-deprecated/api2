#!/usr/bin/env coffee

> path > join
  fs > existsSync symlinkSync lstatSync
  js-yaml:yaml
  utax/read
  @rmw/thisdir


ROOT = thisdir import.meta
SRC = join ROOT, 'src'

< default main = =>
  for dir from process.argv[2..]
    mod_yml = join dir,'mod.yml'
    if existsSync mod_yml
      for mod from yaml.load(
        read mod_yml
      )
        console.log mod
        to = join SRC, mod
        try
          lstatSync(to)
        catch err
          symlinkSync(
            join '..',dir, mod
            join SRC,mod
          )
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()

