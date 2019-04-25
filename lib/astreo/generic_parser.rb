class GenericParser

  private
  def acceptIt
    tokens.shift
  end

  def maybe kind
    return acceptIt if showNext.is_a? kind
  end

  def expect kind
    if ((actual=tokens.shift).kind)!=kind
      puts "ERROR :"
      show_line(actual.pos)
      raise "expecting '#{kind}'. Received '#{actual.val}' around #{actual.pos}"
    end
    return actual
  end

  def showNext(n=1)
    tokens[n-1] if tokens.any?
  end

  def lookahead(n=2)
    tokens[n] if tokens.any?
  end

  def show_line pos
    l,c=*pos
    show_lines(str,l-2)
    line=str.split(/\n/)[l-1]
    pointer="-"*(5+c)+ "^"
    puts "#{l.to_s.ljust(5)}|#{line}"
    puts pointer
  end

  def show_lines str,upto=nil
    lines=str.split(/\n/)
    upto=upto || lines.size
    lines[0..upto].each_with_index do |line,idx|
      puts "#{(idx+1).to_s.ljust(5)}|#{line}"
    end
  end
  #--------------------------------------------------
  def dbg_print_next n
    p tokens[0..n-1].collect{|tok| tok.inspect}
  end

  def dbg_print node
    puts "debug ast node".center(60,'-')
    puts node.accept(@ppr)
    puts "-"*60
  end
end
