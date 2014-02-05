{-

  by Stefan Dangl
  designed for
  * NEO2 german keybord layout
  * lubuntu with lxde (and stuff like lxpanel and nm-applet)

  mod = super

  additional keys
    mod+shift         toggle fullscreen for current app
    mod+b             toggle borders
    mod+arrows        go
    mod+shift+arrows  move
    mod+c             close (kill) window
    mod+i             decrease vertical size (tiled)
    mod+ö             increase vertical size (tiled)
    mod+x             mirror (tiled layout)

    mod+shift+l       lock (using "xscreensaver-command -lock")
    mod+u             volume up
    mod+ü             volume down

    mod+s             toggle struts
    mod+.             minimize
    mod+shift+.       unminimize

  layouts
    tall ( master-pane left, use mod+x to mirror )
    grids with zoom
    fullscreen (for games, videos, etc)

  HINT: use the following command to disable mod4+p in gnome-settings which switches the monitor:
        gconftool -t bool -s /apps/gnome_settings_daemon/plugins/xrandr false

-}
import System.IO
import System.Exit
import qualified Data.Map as M

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.Script
import XMonad.Util.Run(spawnPipe)
--import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks

import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Magnifier
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.WindowNavigation
import XMonad.Layout.MultiToggle as MT
import XMonad.Layout.MultiToggle.Instances
--import XMonad.Layout.Circle
import XMonad.Hooks.FadeInactive
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.OneBig
import XMonad.Layout.Minimize
import XMonad.Layout.BoringWindows
import XMonad.Layout.Decoration
import XMonad.Layout.Tabbed

import XMonad.Layout.LayoutHints
import XMonad.Layout.Named

import XMonad.Actions.UpdatePointer
import XMonad.Util.CustomKeys
import Graphics.X11.ExtraTypes.XorgDefault


--import XMonad.Prompt
--import XMonad.Prompt.Shell
--import XMonad.Prompt.XMonad


-- fullscreenfull seems to do nothing?
-- layout hook
layout =
  nameTail $ layoutHintsWithPlacement (0.5,0.5) $ boringWindows $ nameTail $ minimize (
    avoidStruts ( windowNavigation (
         onebig ||| tiled ||| zgrid
      )
      ||| named "tabs" ( noBorders ( tabbed shrinkText defaultTheme ) )
    )
  )
  
  where
    onebig  = mkToggle ( MIRROR ?? NOBORDERS ?? NBFULL ?? EOT ) $ named "onebig" ( (OneBig (2/3) (2/3)))
    tiled   = mkToggle ( MIRROR ?? EOT ) $ mkToggle ( NOBORDERS ?? EOT ) $ mkToggle ( NBFULL ?? EOT ) $ named "tiled" (smartBorders (ResizableTall 1 (3/100) (2/3) [] ))
    zgrid   = mkToggle ( MIRROR ?? NOBORDERS ?? NBFULL ?? EOT ) $ named "zgrid" (magnifiercz 1.3 ( GridRatio (4/3)))
    full    = mkToggle ( MIRROR ?? NOBORDERS ?? NBFULL ?? EOT ) $ named "full" (noBorders ( fullscreenFull Full ))

-- keys "customKeys"
delkeys :: XConfig l -> [(KeyMask, KeySym)]
delkeys XConfig {modMask = modm} = [
--      (modm, xK_b)
--    , (modm, xK_p)
  ]
inskeys :: XConfig l -> [((KeyMask, KeySym), X ())]
  -- we might use mod1Mask mod2Mask instead of modm ...
inskeys conf@(XConfig {modMask = modm}) = [
      ((modm,               xK_c            ), kill)
    , ((modm,               xK_i            ), sendMessage MirrorExpand)
    , ((modm,               xK_odiaeresis   ), sendMessage MirrorShrink)
    , ((modm,               xK_Right        ), sendMessage $ Go R)
    , ((modm,               xK_Left         ), sendMessage $ Go L)
    , ((modm,               xK_Up           ), sendMessage $ Go U)
    , ((modm,               xK_Down         ), sendMessage $ Go D)
    , ((modm .|. shiftMask, xK_Right        ), sendMessage $ Swap R)
    , ((modm .|. shiftMask, xK_Left         ), sendMessage $ Swap L)
    , ((modm .|. shiftMask, xK_Up           ), sendMessage $ Swap U)
    , ((modm .|. shiftMask, xK_Down         ), sendMessage $ Swap D)
    , ((modm .|. shiftMask, xK_l            ), spawn "xscreensaver-command -lock")
    , ((modm,               xK_u            ), spawn "amixer set Master 1+")
    , ((modm,               xK_udiaeresis   ), spawn "amixer set Master 1-")
    , ((modm,               xK_x            ), sendMessage $ MT.Toggle MIRROR)
    , ((modm,               xK_f            ), sendMessage $ MT.Toggle NBFULL)
    , ((modm,               xK_v            ), sendMessage $ MT.Toggle NBFULL)
    , ((modm,               xK_b            ), sendMessage $ MT.Toggle NOBORDERS)
    , ((modm,               xK_s            ), sendMessage ToggleStruts)
    , ((modm,               xK_period       ), withFocused minimizeWindow)
    , ((modm .|. shiftMask, xK_period       ), sendMessage RestoreNextMinimizedWin)
    , ((modm, xK_j), focusDown)
    , ((modm, xK_d), focusUp)
    , ((modm, xK_m), focusMaster)
    , ((modm, xK_p), spawn "dmenu-with-yeganesh")
  ]

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
--
myManageHook = composeAll
   [
   className =? "lxpanel"  --> doIgnore
-- , className =? "stalonetray"  --> doIgnore
-- , resource  =? "desktop_window"  --> doIgnore
-- , resource  =? "kdesktop"  --> doIgnore
-- , isFullscreen     --> doFullFloat

-- , className =? "MPlayer"  --> doFloat
-- , className =? "Gimp"   --> doFloat
-- , className =? "."   --> doFloat
-- , className =? "gmessage"  --> doFloat
-- , className =? "Zenity"   --> doFloat
-- , className =? "Xmessage"  --> doFloat
-- , className =? "Gxmessage"  --> doFloat
-- , className =? "Gnome-calculator" --> doFloat
-- , className =? "Gcalctool"  --> doFloat
 
-- , className =? "Firefox"  --> doShift "1"
-- , className =? "Thunderbird"  --> doShift "2"
-- , className =? "Pidgin"   --> doShift "3"


  ] <+> manageDocks <+> manageHook defaultConfig

-- main
--main = xmonad =<< xmobar defaultConfig {
main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
  xmonad $ defaultConfig {
    borderWidth         = 2
  , terminal            = "lxterminal"
  , normalBorderColor   = "#000000"
  , focusedBorderColor  = "#dd0000"
  , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor "green" "" . shorten 50
      }
--      >> updatePointer(Relative 0.1 0.1)
      >> fadeInactiveLogHook 0.95
  , layoutHook          = layout
  , startupHook         = do
      sendMessage $ MT.Toggle NOBORDERS
      execScriptHook "startup"
  , manageHook          = myManageHook
  , handleEventHook     = docksEventHook
  , modMask             = mod4Mask
  , keys                = customKeys delkeys inskeys
  }
 

