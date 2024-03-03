{ ... }:

{
  users.users.danimo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRmYBlEPuch0aHgvH6gM1M+q2p6AgXnrwbQw1BVBt1Tec0g2NOTqJSaSXrmr6X4wylw5hdKbRdtmrGucgeTPHoHf4bQ7NmSU6s6+GjzvlAFZNK/TWW+YNDP3AfFsBvoZ0G+HUCpGwEL+6c56/uMP2gDoibPAzUclDmR14J6Oyo+7t9z7KPMvsq8kDyaHUAkgCCoprB48oWWXk0aQUE/l1O+1RlV6SJCrREtGBdmU3Wytq9oarkar+QtKEOBo4utNG8SZ5bZR5I1SGFEApGJLSlGewWx4sKlh7V7t/Pe0O+UhFbB5zj97f2rbBc8eXTKO3jFacqHTIG/Voy/fH7hFY2GGknCXtEPNuPLTb8dWKVU5W8BxmEC2lJtGK72tNYHa985ZMkjZEL5eBsMk+N6UsbnticY6daiMYqTnlXJuN6QGt/ZR5agJ6t/ohmsOYZcImFKDnrZCNBSv271kdEuPIxmn0weoh2P468w0vTHVUhuosoYB1t0EU7vMm/H8hwyqC9HE8MQsxQhVYj7d9Hr6E0znWSGs7lw2vl2nHBb5+QZ7i6/F50zDteNYIoOTTf6v3b4oHn7VlmcfKRZxR948jQX6oENydxEYkojc2aVWDkVBNYW9wmQx9EDNcAJ7NEBpxZY3/Cqip3UvX4e/fagsjwf2fVbUc5rAJ4zdLv0HidFQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmT64p9bY5pLctzOCdqyzI3tsoGdVqay55Lrpo52zL4u4E9xsaCC5+nmfzyIWWX/wyI63c544b32BSRoi/092A+gLjLDWPr6jGb+4fFamJKSi9YxrOEGpV8u84ZXniex0+nmXAm7UmUp9lQo0hpdZ4Gt6nn8IQ2yFJ+80vsJ19oOaZzQM0K+g7XHWYyS2D7rOTG/FAqNV10CzxBu78lgrwAvz8eOeNm11bETIVIJbhwGjaDcJyY5AeifncetHdI712IJeEftyMz6jEsMlCtm36rxPnAiSGtSnCLdvbqIt5zg05nwd/gGPTUc6mtK8viufALu1JCrEDGQGtdROYmOQJiwzUpNPxhWfq+RJccFUdfzzSAit/fr58LRIKU7FlNyJ8XvILJaigndhnFDpocBLOttiDyz8uK1yXBZBPgw+LvqklBLyioCGhsGCs5i7KFMXGCGlklf8HSONAVRUhwaGfta1hn83+/WdtjWCygQgU9/1nhKi8gc9yB2ZfAi8xFDnHXngVY38PwaHIhV4VxlO6RNI1RLK4783QXN8a0X1hujNsJxokfPyWhsoWPqnv2QhxSHcEAK2DjGc4wkUkPs3L+6kHAx/weYstNtZDU7tUlvLUOm8w5DAcFkRhmh7j6aR4js1vYMLwI5PqtUzlXXK/SIkwa+GMvzsPFxJAM1FnEQ=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvSWbhrIzRaCiKgBZd/AeuuIPZmRI2Ry8MtJYSyNdbs"
    ];
  };
  users.users.reimerei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV"
    ];
  };
  users.users.lenny = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeeWp/a1PJAL1xhOU/gozb+zdWBHFVbQEBCSlPIByFd"
    ];
  };
}
