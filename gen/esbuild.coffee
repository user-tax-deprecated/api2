#!/usr/bin/env coffee

> esbuild > build
  path > join dirname basename
  ~/ROOT:_ROOT

ROOT = dirname _ROOT

LIB = join ROOT, 'lib'
API = join LIB,'api'
node_modules = join ROOT,'node_modules'
external = '~/CONF ~/CONST/PG_UINT.js @u6x/ru ../../../ru/ru/lib/lib.node'.split(' ')

# console.log external

bundle = (js)=>
  fp = join LIB, js
  dir = dirname fp
  js = fp[dir.length+1..]

  kind = basename(dir)
  outfile = join dirname(ROOT), 'docker','user.tax', kind, js
  r = await build({
    target:"node18"
    absWorkingDir: dir
    bundle: true
    logLevel: "info"
    entryPoints: [
      js
    ]
    pkgins: [
      {
        name: 'resolve-js',
        setup: (build) =>
          src = join LIB,kind
          build.onResolve(
            { filter: /.*/ }
            ({path, kind, resolveDir}) =>
              if path.startsWith 'utax/'
                return {
                  path:join node_modules,path+'.js'
                }

              if kind == 'entry-point'
                return
              if resolveDir.startsWith(LIB) or not resolveDir.startsWith '/'
                if not path.endsWith '.js'
                  c = path.charAt(0)
                  if c == '~' and path.charAt(1) == '/'
                    base = API
                    path = path[2..]
                  else if c == '.'
                    base = resolveDir
                  if base
                    path = join base, path+'.js'
                    return { path }
              return

          )
      }
    ]
    outfile
    #minify: true
    platform:"node"
    format: "esm"
    banner:
      js: "import {dirname as _dirname_} from 'path';import { createRequire as _createRequire_ } from 'module';const require = _createRequire_(import.meta.url); const __dirname=_dirname_(decodeURI((new URL(import.meta.url)).pathname));"
    external
  }).catch =>
    process.exit(1)
  if r.errors.length
    console.log fp, r
  console.log outfile
  return

await Promise.all [
  "api/fork.js"
  "api/boot.js"
  "Init/main.js"
].map bundle

