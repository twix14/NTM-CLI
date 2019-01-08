$LOAD_PATH << '.'
require 'ntm_ops.rb'
require 'network_util.rb'

include NetworkUtil

def scan_args(cmd_arguments, time)
    scan = []
    scan[1] = scan[2] = scan[3] = scan[4] = scan[5] = []
    scan[6], scan[7] = 0, time

    for i in 0 .. cmd_arguments.length-1 do
      argument = cmd_arguments[i].split(':')[0]
      value = cmd_arguments[i].split(':')[1]

      unless cmd_arguments[i].start_with? '-'
        raise ArgumentError, 'The arrays can\'t have spaces'
        exit 1
      end

      case argument
      when '-type'
        unless value == 'eval' || value == 'full'
          raise ArgumentError, 'The type must be \'eval\' or \'full\''
          exit 1
        end
        scan[0] = value
      when '-snmp'
        scan[1] = value[1..value.length-2].split ','
      when '-subnets'
        scan[2] = value[1..value.length-2].split ','
        scan[2].each do |subnet|
          unless NetworkUtil.is_valid_subnet subnet
            raise ArgumentError, "IP Address or Mask must be valid #{subnet}, Mask >= 16 bits <= 30 bits"
            exit 1
          end
        end
      when '-ips'
        scan[3] = value[1..value.length-2].split ','
        scan[3].each do |ip|
          unless NetworkUtil.is_valid_ipaddress ip
            raise ArgumentError, "IP Address #{ip} must be valid"
            exit 1
          end
        end
      when '-ipranges'
        scan[4] = value[1..value.length-2].split ','
        scan[4].each do |range|
          unless NetworkUtil.is_valid_range range
            raise ArgumentError, "Range #{range} must have valid IP Addresses"
            exit 1
          end
        end
      when '-dontscan'
        scan[5] = value[1..value.length-2].split ','
        scan[5].each do |elem|
          unless NetworkUtil.is_valid_ipaddress(elem) || NetworkUtil.is_valid_range(elem) ||
              NetworkUtil.is_valid_subnet(elem)
            raise ArgumentError, "Element #{elem} elem must be a valid IP Address, subnet or range"
            exit 1
          end
        end
      when '-hops'
        unless value.to_i < 0 || value.to_i <= 10
          raise ArgumentError, 'The number of hops must be between 0 and 10'
          exit 1
        end
        scan[6] = value
      when '-title'
        scan[7] = value
      else
        raise ArgumentError, 'This argument is wrong or doesn\'t exist'
        exit 1
      end
    end

    if scan[2].empty? && scan[3].empty? && scan[4].empty? && scan[5].empty?
      raise ArgumentError, 'The scan need to have at least one source of data, IP Addresses, IP ranges or Subnets'
      exit 1
    end

    puts 'All arguments are of the correct type!'
    return scan
  end

def print_instructions
  puts "Description:\n  This is a simple CLI for SolarWinds Network Topology Mapper Discovery, made possible " + \
             "using AutoIt for Windows. This only runs the discovery once. Try not to use large subnets, these may take" + \
             "a long time to scan"
  puts "Usage:\n  main.rb -t:type [-snmp:[credentials]] [-subnets:[subnets]] [-ips:[free-form ips]] " + \
             "[-ipranges:[ip ranges]] [-dontscan:[do-not-scan list]] [-hops:num_hops] [-title:title]\n"

  # scan[0]
  puts '  -type:type                       Type of NTM version: \'eval\' or \'full\''
  # scan[1]
  puts '  -snmp:[credentials]           Array of SNMP credentials to use besides private and public, which are predefined'
  # scan[2]
  puts '  -subnets:[subnets]            Array of Subnets to scan, e.g 10.0.0.0/24'
  # scan[3]
  puts '  -ips:[free-form ips]          Array of IPs to scan'
  # scan[4]
  puts '  -ipranges:[ip ranges]         Array of IP ranges, e.g 10.0.0.0-10.0.0.255'
  # scan[5]
  puts '  -dontscan:[do-not-scan list]  Array of IPs, Subnets or IP ranges that won\'t be scanned'
  # scan[6]
  puts '  -hops:num_hops                Number of hops to scan from every equipment found by the initial scan, default 0' + \
       '                                can\'t be bigger than 10'
  # scan[7]
  puts '  -title:title                  Title of the scan, can\'t have spaces, e.g \'test-scan\''

  puts "Example:\n  main.rb -type:eval -subnets:[10.0.0.0/24,10.0.2.0/24] -hops:1 -title:'scan1'"
  exit 0
end

# no scheduling
# no vmware
# no wmi

if ARGV.length == 0
  print_instructions
end

time = Time.now.strftime("%d/%m/%Y %H:%M")
scan = scan_args(ARGV, time)

ntm = NtmOps.new

if scan[0] == 'eval'
  ntm.clickEval
end

ntm.initScan

# scan initialization
if scan[1].empty?
  ntm.wait_window
  ntm.click_enter
else
  ntm.wait_window
end
scan[1].each{ |cred| ntm.addSNMPCredential cred}

# GOTO Network Selection menu
ntm.goto_network_selection

# subnets
scan[2].each{ |subnet| ntm.add_subnet subnet }

# free-form ips
ntm.add_ips scan[3] unless scan[3].empty?

# ip-ranges
i = 0
ntm.click_iprange unless scan[4].empty?
scan[4].each do |range|
  ntm.add_iprange(range, i, !scan[4][i+1].nil?)
  i += 1
end

# do-not-scan
ntm.add_do_not_scan scan[5] unless scan[5].empty?

# after the scan arguments are all correct
ntm.click_next

ntm.add_title_and_hops(scan[7], scan[6]) unless scan[6] == '' && scan[7].to_s == time.to_s
ntm.start_scan