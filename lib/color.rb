module Color
  class DecompInfo
    # right-shift operand (>>), and-mask operand (&), multiplication operand
    def initialize(rs, am, mult)
      @rs, @am, @mult = rs, am, mult
    end
    def decompose_component(whole_element)
      ((whole_element >> @rs) & @am) * @mult
    end
    def recompose_component(component)
      component / @mult << @rs
    end
  end
  @@orders = {
    # encoding - {r: DecompInfo(rs, am, mult), g: idem, b: idem, a: idem)}
    rgba4444: [[12, 0xf, 16], [8, 0xf, 16], [4, 0xf, 16], [0, 0xf, 16]],
    rgba5551: [[11, 0b11111, 8], [6,0b11111,8], [1, 0b11111, 8], [0,  1, 255]],
    argb5551: [[10, 0b11111, 8], [5,0b11111,8], [0, 0b11111, 8], [15, 1, 255]],
    rgba8888: [[24, 0xff, 1], [16, 0xff, 1], [8, 0xff, 1], [0, 0xff, 1]],
    bgra8888: [[8, 0xff, 1], [16, 0xff, 1], [24, 0xff, 1], [0, 0xff, 1]],
    argb8888: [[16, 0xff, 1], [8, 0xff, 1], [0, 0xff, 1], [24, 0xff, 1]]
  }
  @@orders.each do |encoding,decomp_infos|
    # if encoding is rgba5551 :
    # decomp_infos = [[11, 0b11111, 8],...]
    # encoding = :rgba5551

    @@orders[encoding] = {} # Example : @@orders[:rgba5551] = {}

    # Continuing with the same example :
    # shift remove the first value of an array and return the removed value
    #                                            rs,  am,  mult
    # @@orders[:rgba5551][:r] = DecompInfo.new(*[11,0b11111, 8])
    # @@orders[:rgba5551][:g] = DecompInfo.new(*[5,0b11111, 8])
    # ...

    [:r,:g,:b,:a].each do |component|
      component_decomp_infos = decomp_infos.shift
      @@orders[encoding][component] = DecompInfo.new(*component_decomp_infos)
    end
  end
  def self.decode(encoded_color, encoding: nil, info: @@orders[encoding])

    if info.nil?
      raise ArgumentError, "No valid informations provided about the encoding #{encoding}"
    end

    [:r,:g,:b,:a].map do |component|
      info[component].decompose_component(encoded_color)
    end
  end
  def self.encode(*rgba_colors, encoding: nil, info: @@orders[encoding])
    if info.nil?
      raise ArgumentError, "No valid informations provided about the encoding #{encoding}"
    end
    rgba = rgba_colors.flatten

    color = 0
    [:r,:g,:b,:a].each do |component|
      color |= info[component].recompose_component((rgba.shift))
    end
    color
  end

end
