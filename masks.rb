module Masks
  Bits16 = '255.255.0.0'
  Bits17 = '255.255.128.0'
  Bits18 = '255.255.192.0'
  Bits19 = '255.255.224.0'
  Bits20 = '255.255.240.0'
  Bits21 = '255.255.248.0'
  Bits22 = '255.255.252.0'
  Bits23 = '255.255.254.0'
  Bits24 = '255.255.255.0'
  Bits25 = '255.255.255.128'
  Bits26 = '255.255.255.192'
  Bits27 = '255.255.255.224'
  Bits28 = '255.255.255.240'
  Bits29 = '255.255.255.248'
  Bits30 = '255.255.255.252'

  def get_mask(bits)
    bits = bits.to_i
    case bits
    when 16
      return Masks::Bits16
    when 17
      return Masks::Bits17
    when 18
      return Masks::Bits18
    when 19
      return Masks::Bits19
    when 20
      return Masks::Bits20
    when 21
      return Masks::Bits21
    when 22
      return Masks::Bits22
    when 23
      return Masks::Bits23
    when 24
      return Masks::Bits24
    when 25
      return Masks::Bits25
    when 26
      return Masks::Bits26
    when 27
      return Masks::Bits27
    when 28
      return Masks::Bits28
    when 29
      return Masks::Bits29
    when 30
      return Masks::Bits30
    else
      return nil
  end

  end
end