module PdfUtils
  class Color
    def initialize(*args)
      if args.first.is_a?(String)
        @r, @g, @b = args.first.scan(/../).map{ |rgb| rgb.to_i(16) }
      elsif args.size == 3
        if args.any? {|arg| arg.kind_of?(Float) }
          @r, @g, @b = args.map {|v| (v * 255).to_i }
        else
          @r, @g, @b = args
        end
      end
    end
    
    def to_pdf
      to_rgb.map{ |v| v / 255.0 }
    end
    
    def to_hex
      to_rgb.inject(''){ |hex, v| hex << "%02x" % v }
    end
    
    def to_rgb
      [@r, @g, @b]
    end
  end
end