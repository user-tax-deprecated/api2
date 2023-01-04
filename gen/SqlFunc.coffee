#!/usr/bin/env coffee

> ./CONF > ROOT PWD
  utax/read
  utax/camel
  utax/write
  fs > rmSync
  utax/extract > extractLi
  zx/globals:
  path > join dirname
  ./PgDump

dump = (pkg, sql)=>

  sql = extractLi(
    sql
    'CREATE OR REPLACE FUNCTION '
    '$$;'
  )

  dir = join ROOT,'src',pkg,'Pg'

  rmSync(dir, { recursive: true, force: true })

  for func from sql
    out = [
      '''// NOT EDIT : use sh/gen/sql_func.coffee gen

      import {UNSAFE} from '~/Pg/index'
      '''
    ]

    pos = func.indexOf('(')

    schema_name = func[..pos-1].trim()

    ++pos

    func_name = schema_name.split('.').pop()
    if func_name == 'drop_func'
      continue

    args = []
    li = []


    pos2 = func.indexOf(')',pos)
    p = 1
    for name from func[pos...pos2++].split(',')
      name = name.trim().split(' ')[0]
      li.push name
      args.push '$'+p
      ++p

    s = func[pos2...func.indexOf(' LANGUAGE')]
    pos = s.indexOf('RETURNS ')
    if pos > 0
      pos+=8
      s = s[pos..].trim()

    select = 'SELECT'
    if s.startsWith('TABLE')
      select += ' * FROM'

    unsafe = """
  UNSAFE(
      '#{select} #{schema_name}(#{args.join(',')})',
      #{li.join(',')}
    )"""
    fn = "(#{li.join(',')})"

    if s!='void'
      fn = 'async '+fn
      unsafe = "(await #{unsafe})"
      pos = func.indexOf('-- JS_RETURN ', pos2)
      if pos > 0
        pos+=13
        unsafe+=func[pos..func.indexOf('\n',pos)-1].trim()

    out.push """\nexport default #{fn}=>{
    return #{unsafe}
  }"""
    fp = join(dir,"#{camel func_name}.js")
    console.log '\n'+fp
    write(
      fp
      out.join('\n')
    )

do =>
  for pkg from await PgDump()
    dump pkg,read join(ROOT,'src',pkg,'init/pg/table.sql')
  process.exit()
  return



