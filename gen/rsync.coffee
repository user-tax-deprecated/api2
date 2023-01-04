#!/usr/bin/env coffee

> fs > readdirSync mkdirSync copyFileSync
  path > join dirname
  ./CONF > ROOT
  utax/walk > walkRel

IGNORE = new Set [
  'node_modules'
]

COPY = new Set [
  'js'
  'json'
  'sql'
  'mjs'
  'lua'
  'md'
]

LIB = join ROOT, 'lib'

SRC = join ROOT, 'src'

< default main = =>
  for await i from walkRel(
    SRC
    (i) => IGNORE.has i
  )
    pos = i.lastIndexOf '.'
    if ~ pos
      ext = i[pos+1..]
      if COPY.has ext
        f = join SRC, i
        t = join LIB, i
        mkdirSync(
          dirname t
          { recursive: true, force: true }
        )
        copyFileSync(f,t)
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()

