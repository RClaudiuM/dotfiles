{ ... }:

{
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      magnification = true;
      tilesize = 46;
      largesize = 100;
      persistent-apps = [
        "/System/Applications/System Settings.app"
        "/Applications/Cursor.app"
        "/Applications/Nix Apps/Brave Browser.app"
        "/Applications/Slack.app"
        "/Applications/Microsoft Teams.app"
        "/Applications/Microsoft Outlook.app"
        "/System/Applications/Utilities/Terminal.app"
        "/Applications/Figma.app"
        "/Applications/Notion.app"
      ];
      persistent-others = [
        "/Users/claudiu.roman/Downloads"
        "/Users/claudiu.roman"
      ];
    };

    finder.FXPreferredViewStyle = "icnv";    
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      "com.apple.trackpad.forceClick" = true;
      "com.apple.trackpad.scaling" = 3.0;
    };
    trackpad = {
      Clicking = true;
      SecondClickThreshold = 0;
    };
  };
}