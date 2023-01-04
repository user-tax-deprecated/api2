#!/usr/bin/env coffee

> @rmw/thisdir
  path > dirname join
  chalk
  utax/read
  utax/write
  fs > symlinkSync existsSync lstatSync unlinkSync mkdirSync rmSync statSync chmodSync constants readdirSync renameSync
  coffeescript
  chokidar
  coffee_plus > coffee_plus

{gray} = chalk

coffeescript.compile = coffee_plus coffeescript

ROOT = dirname thisdir(import.meta)
SRC = join ROOT,'src'
SRC_LEN = SRC.length+1
LIB = join ROOT, 'lib'

COFFEE = '.coffee'

coffee_js = (fp)=>
  fp[..-7]+'js'

add = (fp)=>
  lib = join LIB, fp
  dir = dirname lib
  if not existsSync dir
    mkdirSync(dir, { recursive: true })

  if fp.endsWith(COFFEE)
    lib = coffee_js lib
    sfp = join(SRC, fp)
    write(
      lib
      coffeescript.compile(
        read sfp
        bare: true
      )
    )
    if (statSync sfp).mode & constants.S_IXUSR
      chmodSync(lib, 0o755)
  else if not existsSync lib
    src = '../'.repeat(1+fp.length - fp.replaceAll('/','').length)+'src/'+fp
    symlinkSync(
      src
      lib
    )
  return

change = (path)=>
  fp = path[SRC_LEN..]
  add(fp)
  return

log = (str...)=>
  console.log gray(...str)
  return


READY = 0

ON = {
  change
  add: change
  unlinkDir:(path)=>
    fp = path[SRC_LEN..]
    lib = join LIB,fp
    log '⌦',lib
    rmSync lib,recursive:true,force:true
    return
  unlink:(path)=>
    fp = path[SRC_LEN..]
    if fp.endsWith COFFEE
      fp = coffee_js fp
    lib = join LIB,fp
    log '⌦',lib
    try
      unlinkSync lib
    catch err
      console.error err
    return
  ready:=>
    {default:PkgInit} = await import(
      join(LIB,'Init/PkgInit.js')
    )
    dir_pkg = 'Redis/pkg'
    src_pkg = join SRC,dir_pkg
    await PkgInit ['redis']

    {GEN,default:init} = await import(
      join(LIB,'Init/main.js')
    )
    await init GEN

    _add = add
    add = (fp)=>
      log '✏',fp
      _add(fp)
      return
    return
}

DIR_LI = [SRC]

readdirSync(SRC).forEach(
  (i)=>
    fp = join SRC,i
    stat = lstatSync(fp)
    if stat.isSymbolicLink()
      DIR_LI.push fp
    return
)

w = chokidar.watch(
  DIR_LI
  ignored:/^(\.git)$/
  persistent: true
)
for [e,f] from Object.entries ON
  w.on(e,f)
