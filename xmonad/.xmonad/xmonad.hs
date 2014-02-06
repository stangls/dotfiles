{-

  by Stefan Dangl
  designed for
  * NEO2 german keyboard layout
  * lubuntu with lxde (and stuff like lxpanel and nm-applet)
  * me! ;)
  feel free to adapt to your needs and redistribute

  default keys stayed the same, they have not been remapped to neo2.
  the thinking behind that decision, is that ctrl-v and ctrl+c and
  ctrl-x are also not mapped to the same positon as well as vim-keys
  and other stuff. (i typically only remap keys for games)

  mod = super

  additional keys
    mod+f or mod+v    toggle fullscreen for current app
    mod+b             toggle borders
    mod+arrows        move focus
    mod+shift+arrows  move window
    mod+j             next focus (default)
    mod+d             previous focus (in addition to default mod+k)
    mod+c             close (kill) window
    mod+i             decrease vertical size (tiled)
    mod+ö             increase vertical size (tiled)
    mod+x             mirror layout (does not work with all, e.g. tabbed)

    mod+shift+l       lock (using "xscreensaver-command -lock")
    mod+u             volume up (amixer)
    mod+ü             volume down (amixer)

    mod+s             toggle struts (e.g. xmobarr)
    mod+.             minimize
    mod+shift+.       unminimize

    mod+ctrl+$        swap current workspace with workspace $

  layouts
    onebig ( master-pane top-left )
    tall ( master-pane left )
    grids with zoom
    tabbed (somehow i never use this one)

  HINT: use the following command to disable mod4+p in gnome-settings which switches the monitor:
        gconftool -t bool -s /apps/gnome_settings_daemon/plugins/xrandr false
  HINT: see .xmobarr config file
  HINT: use dmenu with yeganesh script, install yeganesh with
    cabal install yeganesh

-}
import System.IO
--import qualified Data.Map as M

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.Script
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig

--import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place

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

--import XMonad.Actions.UpdatePointer
import XMonad.Actions.SwapWorkspaces
import qualified XMonad.Actions.FlexibleResize as Flex

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
    toggler x = mkToggle ( MIRROR ?? EOT ) $ mkToggle ( NOBORDERS ?? EOT ) $ mkToggle ( NBFULL ?? EOT ) $ x
    onebig  = toggler $ named "onebig" ( (OneBig (2/3) (2/3)))
    tiled   = toggler $ named "tiled" (smartBorders (ResizableTall 1 (3/100) (2/3) [] ))
    zgrid   = toggler $ named "zgrid" (magnifiercz 1.3 ( GridRatio (4/3)))
    full    = toggler $ named "full" (noBorders ( fullscreenFull Full ))

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
  ++ [
    ((modm .|. controlMask, k), windows $ swapWithCurrent i) | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
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
myManageHook =
  placeHook (withGaps (16,0,16,0) (smart (0.5,0.5)))
  <+>
  composeAll
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
main =
  spawnPipe "/usr/bin/xmobar ~/.xmobarrc" >>= \xmproc ->
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
  `additionalMouseBindings`
  [ ((mod4Mask, button3), (\w -> focus w >> Flex.mouseResizeWindow w))
  ]

