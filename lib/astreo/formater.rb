require_relative 'code'

module Astreo
  class Formater
    def format str
      code=Code.new
      # detect max column position of "=" => alignment
      lines=str.split("\n")
      alignment=lines.collect{|line| line.index('=')}.compact.max+1
      lines.each do |line|
        #puts line
        code.newline
        if line.match("=")
          parts=line.split("=")
          name=parts.shift
          code.print name+("=".rjust(alignment-name.size))
          rhs_parts=parts.join.split("|")
          code.puts rhs_parts.shift
          rhs_parts.each do |type|
            code.puts " "*(alignment-1)+"|"+type
          end
        else
          code << line
        end
      end
      return code
    end
  end
end
