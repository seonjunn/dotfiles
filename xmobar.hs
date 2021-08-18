Config { 

   -- appearance
     font =         "xft:MesloLGS NF:size=16:bold:antialias=true"
   , bgColor =      "#6272a4"
   , fgColor =      "#f8f8f2"
   , position =     Top
   , border =       BottomB
   , borderColor =  "#646464"

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = " %StdinReader% }{ %multicpu% | %memory% | %dynnetwork% | %date% "

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)

   -- plugins
   --   Numbers can be automatically colored according to their value. xmobar
   --   decides color based on a three-tier/two-cutoff system, controlled by
   --   command options:
   --     --Low sets the low cutoff
   --     --High sets the high cutoff
   --
   --     --low sets the color below --Low cutoff
   --     --normal sets the color between --Low and --High cutoffs
   --     --High sets the color above --High cutoff
   --
   --   The --template option controls how the plugin is displayed. Text
   --   color can be set by enclosing in <fc></fc> tags. For more details
   --   see http://projects.haskell.org/xmobar/#system-monitor-plugins.
   , commands = 

        [
	-- network activity monitor (dynamic interface resolution)
         Run DynNetwork     [ "--template" , "<dev>: TX <tx>kB/s| RX <rx>kB/s"
                             , "--Low"      , "1000"       -- units: B/s
                             , "--High"     , "5000"       -- units: B/s
                             , "--low"      , "#50fa7b"
                             , "--normal"   , "#ffb86c"
                             , "--high"     , "ff5555"
                             ] 10

        -- cpu activity monitor
        , Run MultiCpu       [ "--template" , "CPU <total0>% <total1>%"
                             , "--Low"      , "50"         -- units: %
                             , "--High"     , "85"         -- units: %
                             , "--low"      , "#50fa7b"
                             , "--normal"   , "#ffb86c"
                             , "--high"     , "ff5555"
                             ] 10

        -- memory usage monitor
        , Run Memory         [ "--template" ,"MEM <usedratio>%"
                             , "--Low"      , "20"        -- units: %
                             , "--High"     , "90"        -- units: %
                             , "--low"      , "#50fa7b"
                             , "--normal"   , "#ffb86c"
                             , "--high"     , "ff5555"
                             ] 10

        -- time and date indicator 
        --   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
        , Run Date           "<fc=#f8f8f2>%F (%a) %T</fc>" "date" 10

        , Run StdinReader
        ]
   }
