import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar /home/dilletante/.xmobarrc"
  xmonad $ def
    { terminal = "alacritty"
    , modMask = mod4Mask -- Use Super instead of Alt
    , manageHook = manageDocks <+> manageHook def
    , layoutHook = avoidStruts  $  layoutHook def
    -- I want the xmobar to be allways on top, so the solution is found here:
    -- https://unix.stackexchange.com/questions/288037/xmobar-does-not-appear-on-top-of-window-stack-when-xmonad-starts
    -- this must be in this order, docksEventHook must be the last
    , handleEventHook = handleEventHook defaultConfig <+> docksEventHook
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor "green" "" . shorten 50
      }
    } `additionalKeys`
    -- Go to screensaver mode
    [ ((mod4Mask, xK_l), spawn "xscreensaver-command -lock")
    -- Take a screenshot of selected area
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    -- Take a screenshot of the whole screen
    , ((0, xK_Print), spawn "scrot")
    -- Set up audio keyboard controls
    , ((0, 0x1008ff12), spawn "amixer set Master toggle")
    , ((0, 0x1008ff13), spawn "amixer -q set Master 2%+")
    , ((0, 0x1008ff11), spawn "amixer -q set Master 2%-")
    -- Mirror monitor
    , ((mod4Mask, xK_d), spawn "xrandr --output DP-2-3 --off --output DP-2-1 --same-as eDP-1")
    -- Rewrite default dmenu options a little
    , ((mod4Mask, xK_p), spawn "exec `dmenu_path | dmenu -i -b -fn 'Fira Mono' -nb 'black' -nf '#646464'`")
    ]
