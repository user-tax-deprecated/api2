#!/usr/bin/env coffee

> ./CONF > ROOT PWD
  path > join
  fs > existsSync
  ./rsync
  ./i18n

< main = =>
  await i18n()
  await rsync()
  {default:MOD} = await import("~/MOD")
  for pkg from MOD
    fp = join ROOT,'lib',pkg,'init/build.js'
    if existsSync fp
      {default:build} = await import(fp)
      console.log fp
      await build()
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()

