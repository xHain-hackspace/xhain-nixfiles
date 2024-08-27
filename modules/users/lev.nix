{ ... }:

{
  users.users.lev= {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCh8m8y0gbsNdHrNqDeUXUZ7d1Ty8l9RXQO1SbrQUHmfmCfkmFrLzeIPpngM4YvvrTH1UGxzksezr+zD8MVPE4qbf6kRjjIb7VFLXyjRnG1Y9fn7WJJSsO0QVvr9c/nvyO+F5//WuMGNYFtqVOc1Zie9t2SWiZ1cD0joTXvXQ7sEf1TkLuOjnKRvLN3QhXW5D7kVxxIaWdZTsj6JeltXnB4J5W98VCtiYKcgRgvUr1j47PQKT+Gk4poTr5wqt4h7h2xZ7kfoUCuZC4Vmr1V9k8sqUzVbp7hMEcroC3O+mUOlQbdOesp0IeEDS03QYX0QS06KV44wkxIytR0u3KdvT3q5WXvnvou4migCMxK2foJOWasCsptXLVJ/SiowByixOyafrljpue419u/U1Dj5piDQln3NzHDbE45kXSOqPB6g2uFWTnj/aWSgfPkThEKHWvTZv9QPcmqE8iRNddGJInQUrNJa+3KHsWp/o+MhUokADH3QH9XiQ1jlcszEciwiC8= lev@entrapta"
    ];
  };
}
