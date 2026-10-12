{
  programs.chromium = {
    enable = true;
    homepageLocation = "about:blank";
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    defaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
    extraOpts = {
      SyncDisabled = true;
      BrowserSignin = 0;
      PasswordManagerEnabled = false;
      SpellcheckEnabled = true;
      SpellcheckLanguage = [ "en-US" ];
      BuiltInDnsClientEnabled = false;
      MetricsReportingEnabled = false;
      SearchSuggestEnabled = false;
      SafeBrowsingProtectionLevel = 0;
      PrivacySandboxAdTopicsEnabled = false;
      PrivacySandboxSiteSuggestedAdsEnabled = false;
      PrivacySandboxAdMeasurementEnabled = false;
      NetworkPredictionOptions = 2;
      WebRtcIPHandlingPolicy = "disable_non_proxied_udp";
      TranslateEnabled = false;
      AllowDeletingBrowserHistory = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      UrlKeyedAnonymizedDataCollectionEnabled = false;
      PromotionalTabsEnabled = false;
      PromotionsEnabled = false;
      BackgroundModeEnabled = false;
      GenAiDefaultSettings = 2;
      HelpMeWriteSettings = 2;
      TabOrganizerSettings = 2;
      CreateThemesSettings = 2;
      WallpaperSearchSettings = 2;
      HistorySearchSettings = 2;
    };
  };
}
