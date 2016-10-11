require 'myy-color'
require 'minitest/autorun'

class MyyColorTest < Minitest::Test
  def test_decode

    0.upto(255) {|c|
      # rgba 8888
      components = [c,c,255-c,255-c]
      r, g, b, a = components
      color8888 = (r << 24 | g << 16 | b << 8 | a)
      assert_equal components, MyyColor.decode(color8888, encoding: :rgba8888)

      # argb 8888
      assert_equal components[1..3] + components[0..0], MyyColor.decode(color8888, encoding: :argb8888)

      # rgba 4444
      r, g, b, a = components.map {|c| c >> 4}
      color4444 = (r << 12 | g << 8 | b << 4 | a)
      assert_equal components.map {|c| (c >> 4) << 0x4}, MyyColor.decode(color4444, encoding: :rgba4444)

      # rgba 5551
      components5551 = [components[0..2].map {|c| c >> 3}, components[3] / 255].flatten
      r, g, b, a = components5551
      color5551 = (r << 11 | g << 6 | b << 1 | a)
      assert_equal [components5551[0..2].map {|c| c << 3}, components5551[3] * 255].flatten, MyyColor.decode(color5551, encoding: :rgba5551)
    }

  end

  # TODO
  def test_encode
  end
end
