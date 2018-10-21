base_setup = <<~SCRIPT
  pacman-key --populate archlinux
  pacman -Suy --noconfirm --noprogressbar bash-completion bind-tools net-tools python vim --ignore linux
SCRIPT

disable_nat = <<~SCRIPT
  cat <<EOT > /etc/systemd/network/eth0.network
  [Match]
  Name=eth0

  [Network]
  DHCP=ipv4

  [Route]
  Gateway=10.0.2.15
  Destination=10.0.2.0/24

  [DHCP]
  UseDNS=false
  UseDomains=false
  UseRoutes=false
  EOT

  systemctl restart systemd-networkd
SCRIPT

setup_dhcp = <<~SCRIPT
  cat <<EOT > /etc/systemd/network/eth1.network
  [Match]
  Name=eth1

  [Network]
  DHCP=ipv4

  [DHCP]
  UseDomains=true
  EOT

  systemctl restart systemd-networkd
SCRIPT

setup_pppoe = <<~SCRIPT
  pacman-key --populate archlinux
  pacman -Sy --noconfirm rp-pppoe

  cat <<EOT > /etc/ppp/pppoe-server-options
  require-chap
  login
  lcp-echo-interval 10
  lcp-echo-failure 2
  ms-dns 1.1.1.1
  ms-dns 1.0.0.1
  netmask 255.255.255.255
  defaultroute
  noipdefault
  usepeerdns
  EOT

  cat <<EOT > /etc/ppp/chap-secrets
  # Secrets for authentication using CHAP
  # client        server  secret                  IP addresses
  bar             *       baz                     *
  EOT

  cat <<EOT > /etc/systemd/system/pppoe-server.service
  [Unit]
  Description=pppoe-server
  Wants=network-online.target
  After=network-online.target

  [Service]
  ExecStart=/usr/bin/pppoe-server -F -I eth1

  [Install]
  WantedBy=multi-user.target
  EOT

  cat <<EOT > /etc/systemd/network/eth0.network
  [Match]
  Name=eth0

  [Network]
  DHCP=ipv4
  IPForward=ipv4
  EOT

  cat <<EOT > /etc/systemd/network/eth1.network
  [Match]
  Name=eth1
  EOT

  iptables -t nat -F POSTROUTING
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables-save > /etc/iptables/iptables.rules

  systemctl daemon-reload
  systemctl restart systemd-networkd
  systemctl enable --now iptables
  systemctl enable --now pppoe-server
SCRIPT

# rubocop:disable Metrics/BlockLength
Vagrant.configure('2') do |config|
  config.vm.box = 'archlinux/archlinux'

  config.vm.provision 'shell', inline: <<~SCRIPT
    for name in $( ls /sys/class/net | grep eth ); do
      systemctl disable "netctl@${name}.service"
    done
  SCRIPT

  config.vm.define 'isp' do |isp|
    isp.vm.hostname = 'isp'
    isp.vm.network 'private_network', virtualbox__intnet: 'pppoe'
    isp.vm.provision 'shell', inline: setup_pppoe
  end

  config.vm.define 'router' do |router|
    router.vm.hostname = 'router'

    router.vm.network 'private_network', mac: '000db94bf848', virtualbox__intnet: 'pppoe'
    router.vm.network 'private_network', mac: '000db94bf849', virtualbox__intnet: 'lan1'
    router.vm.network 'private_network', mac: '000db94bf84a', virtualbox__intnet: 'lan2'

    router.vm.provider 'virtualbox' do |virtualbox|
      virtualbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-vms']
      virtualbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-vms']
    end

    router.vm.provision 'shell', run: 'once', inline: base_setup
    router.vm.provision 'ansible' do |ansible|
      ansible.limit = 'all'
      ansible.playbook = 'router.yml'
      ansible.raw_arguments = ['--diff']
      ansible.extra_vars = {
        is_vagrant: true,
        ppp_provider: 'foo',
        ppp_username: 'bar',
        ppp_password: 'baz'
      }
    end
  end

  config.vm.define 'client1' do |client1|
    client1.vm.hostname = 'client1'
    client1.vm.network 'private_network', virtualbox__intnet: 'lan1', mac: '32885a37d9a8'
    client1.vm.provision 'shell', run: 'once', inline: base_setup
    client1.vm.provision 'shell', run: 'once', inline: disable_nat
    client1.vm.provision 'shell', run: 'once', inline: setup_dhcp
  end

  config.vm.define 'client2' do |client2|
    client2.vm.hostname = 'client2'
    client2.vm.network 'private_network', virtualbox__intnet: 'lan2'
    client2.vm.provision 'shell', run: 'once', inline: base_setup
    client2.vm.provision 'shell', run: 'once', inline: disable_nat
    client2.vm.provision 'shell', run: 'once', inline: setup_dhcp
  end
end
# rubocop:enable Metrics/BlockLength
