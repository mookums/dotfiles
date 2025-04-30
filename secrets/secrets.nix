let
  # Users
  muki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuLvCc5ZJ3JSbfwYlSJZRNDFKhoKPsdu/TDV1YYs8rL";

  # Systems
  sisyphus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBky5TNc5qsMFADCt27kH15DDkAFjOOgCw0Rfl4ctogG";
in
{
  "cloudflare-api.age".publicKeys = [
    muki
    sisyphus
  ];
}
