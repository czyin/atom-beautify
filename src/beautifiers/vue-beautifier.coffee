"use strict"
Beautifier = require('./beautifier')
prettydiff = require("prettydiff")
_ = require('lodash')

module.exports = class VueBeautifier extends Beautifier
  name: "Vue Beautifier"

  options:
    Vue: true

  beautify: (text, language, options) ->
    return new @Promise((resolve, reject) ->
      # regexp = /(<(template|script|style)[^>]*>)((\s|\S)*?)<\/\2>/gi
      # https://github.com/Glavin001/atom-beautify/issues/1333
      regexp = /(<(template|script|style)[^>]*>)((\s|\S)*)<\/\2>/gi

      resolve(text.replace(regexp, (match, begin, type, text) ->
        lang = /lang\s*=\s*['"](\w+)["']/.exec(begin)?[1]

        console.log '============================================='
        console.log '---------------------------- match \n', match
        console.log '---------------------------- begin \n', begin
        console.log '---------------------------- type \n', type
        console.log '---------------------------- text \n', text
        console.log '---------------------------- lang \n', lang
        console.log '============================================='

        switch type
          when "template"
            switch lang
              when "pug", "jade"
                match.replace(text, "\n" + require("pug-beautify")(text, options) + "\n")
              when "html", undefined
                match.replace(text, "\n" + require("js-beautify").html(text, options) + "\n")
              else
                match
          when "script"
            match.replace(text, "\n" + require("js-beautify")(text, options) + "\n")
          when "style"
            switch lang
              when "sass", "scss"
                options = _.merge options,
                  source: text
                  lang: "scss"
                  mode: "beautify"
                match.replace(text, prettydiff.api(options)[0])
              when "less"
                options = _.merge options,
                source: text
                lang: "less"
                mode: "beautify"
                match.replace(text, prettydiff.api(options)[0])
              when "css", undefined
                match.replace(text, "\n" + require("js-beautify").css(text, options) + "\n")
              else
                match
      ))
    )
