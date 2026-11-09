{ ... }:

{
  networking.interfaces.lo.ipv4.addresses = [
    {
      address = "45.158.40.192";
      prefixLength = 32;
    }
  ];

  networking.firewall.checkReversePath = false;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = false;
  boot.kernel.sysctl."net.ipv4.conf.*.rp_filter" = false;
}
