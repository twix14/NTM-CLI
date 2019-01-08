require 'win32ole'
$LOAD_PATH << '.'
require 'masks.rb'

include Masks

class NtmOps

  WINDOW_SCAN = 'Network Topology Scan'
  WINDOW_SNMP = 'Add SNMP Credential'
  WINDOW_SUBNET = 'Add a New Subnet'
  # Windows 10
  BUTTON = 'WindowsForms10.BUTTON.app.0.1b0ed41_r6_ad1'
  # Windows 10
  EDIT = 'WindowsForms10.EDIT.app.0.1b0ed41_r6_ad1'
  # Windows 10
  TAB = 'WindowsForms10.SysTabControl32.app.0.1b0ed41_r6_ad1'

  def initialize
    @ai = WIN32OLE.new 'AutoItX3.Control'
    # autoit methods, start with caps
    @ai.Run('C:\Program Files (x86)\Solarwinds\Network Topology Mapper\SolarWinds.NTM.Client',
           '', @SW_MAXIMIZE)
  end

  def wait_window
    @ai.WinWaitActive WINDOW_SCAN
  end

  def clickEval
    @ai.WinWaitActive 'SolarWinds NTM'
    @ai.Send '{Enter 1}'
  end

  def initScan
    @ai.WinWaitActive 'Welcome Screen...'
    @ai.Send '{Enter 1}'
  end

  def addSNMPCredential(cred)
    # open new credential
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:5]")
    @ai.WinWaitActive WINDOW_SNMP
    # add of credential
    @ai.ControlSetText(WINDOW_SNMP, '', "[CLASS:#{EDIT}; INSTANCE:2]", cred)
    @ai.ControlSetText(WINDOW_SNMP, '', "[CLASS:#{EDIT}; INSTANCE:1]", cred)
    # save credential for current scan
    @ai.ControlClick(WINDOW_SNMP, '', "[CLASS:#{BUTTON}; INSTANCE:1]")
  end

  def goto_network_selection
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:9]")
    @ai.Send '{Enter 1}'
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:10]")
  end

  def add_subnet(sub)
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:2]")
    @ai.WinWaitActive WINDOW_SUBNET
    subnet = sub.split('/')

    @ai.ControlSetText(WINDOW_SUBNET, '', "[CLASS:#{EDIT}; INSTANCE:2]", subnet[0])
    @ai.ControlSetText(WINDOW_SUBNET, '', "[CLASS:#{EDIT}; INSTANCE:1]",
                      Masks.get_mask(subnet[1]))
    # add subnet
    @ai.ControlClick(WINDOW_SUBNET, '', "[CLASS:#{BUTTON}; INSTANCE:2]")
  end

  def add_ips(ips)
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{TAB}; INSTANCE:1]",
                    'Left',1, 148, 11)
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:1]")
    ips.each do |ip|
      @ai.Send ip
      @ai.Send '{Enter 1}'
    end
  end

  def click_iprange
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{TAB}; INSTANCE:1]", 'Left', 1, 80, 14)
  end

  def add_iprange(iprange, i, has_next)
    range = iprange.split '-'
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlSetText(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:#{(i+1) * 4}]", range[0])
    @ai.ControlSetText(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:#{(i+1) * 4 - 1}]", range[1])
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:#{i == 0 ? 5 : i * 2 + 6}]") if has_next
  end

  def add_do_not_scan(dont_scan)
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{TAB}; INSTANCE:1]", 'Left',1, 223, 11)
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:10]")
    dont_scan.each do |ds|
      @ai.Send ds
      @ai.Send '{Enter 1}'
    end
  end

  def click_next
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{TAB}; INSTANCE:1]", 'Left',1, 223, 11)
    @ai.Send '{Enter 1}'
  end

  def click_enter
    @ai.Send '{Enter 1}'
  end

  def add_title_and_hops(title, hops)
    @ai.WinWaitActive WINDOW_SCAN
    @ai.ControlSetText(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:2]", title)
    @ai.ControlSetText(WINDOW_SCAN, '', "[CLASS:#{EDIT}; INSTANCE:1]", hops)
    @ai.ControlClick(WINDOW_SCAN, '', "[CLASS:#{BUTTON}; INSTANCE:5]")
    @ai.Send '{Enter 1}'
  end

  def start_scan
    @ai.Send '{Tab 2}'
    @ai.Send '{Enter 1}'
  end

end
