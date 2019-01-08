$LOAD_PATH << '.'
require 'masks.rb'

module NetworkUtil
  include Masks

  def is_valid_subnet(subnet)
    return false unless subnet.include? '/'
    split = subnet.split('/')
    return split.length == 2 && is_valid_ipaddress(split[0]) && is_valid_mask(split[1])
  end

  def is_valid_range(range)
    return false unless range.include? '-'
    split = range.split('-')
    return is_address_bigger(split[1],split[0]) && split.length == 2 && is_valid_ipaddress(split[0]) &&
        is_valid_ipaddress(split[1])
  end

  def is_valid_ipaddress(ip)
    return false unless ip.include? '.'
    octets = ip.split('.')
    return octets.length == 4 && is_valid_octet(octets[0]) && is_valid_octet(octets[1]) &&
        is_valid_octet(octets[2]) && is_valid_octet(octets[3])
  end

  def is_valid_mask(mask)
    return !Masks.get_mask(mask).nil?
  end

  def is_valid_octet(octet)
    return is_number(octet) && octet.to_i >= 0 && octet.to_i < 256
  end

  private

  def is_address_bigger(ip1, ip2)
    return true if ip1 == ip2
    octets1, octets2 = ip1.split('.'), ip2.split('.')
    return octets1[0] >= octets2[0] && octets1[1] >= octets2[1] && octets1[2] >= octets2[2] &&
        octets1[3] >= octets2[3]
  end

  def is_number(string)
    true if Float(string) rescue false
  end
end