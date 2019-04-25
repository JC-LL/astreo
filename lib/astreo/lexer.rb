require_relative 'generic_lexer'

module Astreo

  class Lexer < GenericLexer

    def initialize
      super
      ignore /\s+/
      keyword "module"
      keyword "attributes"
      # ======== verified afterwards ======
      # all are lexed+parsed as Name
      # keyword "INT"
      # keyword "FLOAT"
      # keyword "BOOL"
      # keyword "CHAR"
      # keyword "STRING"
      #
      # keyword "INT_LIT"
      # keyword "FLOAT_LIT"
      # keyword "BOOL_LIT"
      # keyword "CHAR_LIT"
      # keyword "STRING_LIT"
      # keyword "IDENT"

      token :lparen           => /\(/
      token :rparen           => /\)/
      token :lbrace           => /\{/
      token :rbrace           => /\}/
      token :lbrack           => /\[/
      token :rbrack           => /\]/

      token :comma            => /\,/
      token :comment          => /\-\-(.*)/


      token :assign           => /\=/

      token :add              => /\+/
      token :star             => /\*/
      token :qmark            => /\?/

      token :or               => /\|/

      # .............literals..............................

      token :name             => /\A[a-zA-Z]\w*/i
      token :float_lit        => /\A\d*(\.\d+)(E([+-]?)\d+)?/
      token :integer_lit      => /\A(0x[0-9a-fA-F]+)|\d+/
      token :string_lit       => /\A"[^"]*"/
      token :char_lit         => /\A'\\?.'/
      token :lexer_warning    => /./

    end
  end
end

if $PROGRAM_NAME == __FILE__
  str=IO.read(ARGV[0])
  puts str
  t1 = Time.now
  lexer=Crokus::Lexer.new
  tokens=lexer.tokenize(str)
  t2 = Time.now
  pp tokens
  puts "number of tokens : #{tokens.size}"
  puts "tokenized in     : #{t2-t1} s"
end
