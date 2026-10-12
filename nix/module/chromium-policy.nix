{
  programs.chromium = {
    enable = true;
    homepageLocation = "about:blank";
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
    extraOpts = {
      SyncDisabled = true;
      PasswordManagerEnabled = false;
      GenAiDefaultSettings = 2;
      HelpMeWriteSettings = 2;
      TabOrganizerSettings = 2;
      CreateThemesSettings = 2;
      WallpaperSearchSettings = 2;
      HistorySearchSettings = 2;
    };
  };
}
