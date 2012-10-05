fs = require 'fs'
jsyaml = require 'js-yaml'
resolver = require 'js-yaml/lib/js-yaml/resolver'
less = require 'less'
inspect = require 'inspect'
json2yaml = require 'json2yaml'

src_dir = __dirname + '/src/'
out_dir = __dirname + '/'
LESSVAR_TAG = 'tag:lesscss.org,variable'

resolver.Resolver.addImplicitResolver LESSVAR_TAG,
  /^\$\$?[\w-]+/,
  ['$']

parseLessFile = (e, data) ->
  if (e)
    process.exit 1

  new(less.Parser)({
    paths: [src_dir],
    filename: input
    }).parse data, (err, tree) ->
      if err
        less.writeError e
        process.exit 1

      try
        rulesets = tree.eval {frames: []}
      catch e
        if e.extract
          less.writeError e
        else
          console.log inspect e
        process.exit 2

      jsyaml.addConstructor LESSVAR_TAG, (node) ->
        try
          lessv = new less.tree.Variable node.value.replace('$', '@')
          (lessv.eval {frames: [rulesets]}).toCSS()
        catch e
          if e.extract
            less.writeError e
          else
            console.log inspect e
          process.exit 2

      doc = require src_dir + 'vicutake-solarized.tyaml'
      fs.writeFileSync out_dir + 'vicutake-solarized.yaml', json2yaml.stringify(doc), 'utf8'

      css = tree.toCSS {compress: false}
      fs.writeFileSync out_dir + '/vicutake-solarized.css', css, 'utf8'

require.extensions['.tyaml'] = require.extensions['.yaml']
input = src_dir + 'vicutake-solarized.less'
fs.readFile input, 'utf8', parseLessFile
