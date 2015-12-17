--
-- ~/.xmonad/xmonad.hs by httran
-- Sun Apr 22 23:01:13 ICT 2011
--

-- Imports {{{
import XMonad hiding ( (|||) )

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Actions.CycleWS
import XMonad.Actions.UpdatePointer
import XMonad.Actions.OnScreen

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.IM
import XMonad.Layout.LayoutCombinators (JumpToLayout)
import XMonad.Layout.LayoutHints (layoutHintsWithPlacement)
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Tabbed
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders
--import XMonad.Layout.ResizableTile

import XMonad.Util.Loggers (maildirNew,logCmd,dzenColorL,wrapL,shortenL)
import XMonad.Util.Replace
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Scratchpad
import XMonad.Util.Themes
import XMonad.Util.WindowProperties (getProp32s)
import XMonad.Util.WorkspaceCompare (getSortByXineramaRule)

import Data.List
import Data.Monoid

import System.IO
import System.Exit

import XMonad.Hooks.SetWMName

-- }}}

-- Theme {{{
myFont       = "Verdana-9"       -- xft-enabled dzen required (aur/dzen2-svn)
conkyFile    = "~/.dzen_conkyrc" -- populates right status bar via conky -c | dzen2

colorBG      = "#303030"         -- background
colorFG      = "#606060"         -- foreground
colorFG2     = "#909090"         -- foreground w/ emphasis
colorFG3     = "#c4df90"         -- foreground w/ strong emphasis
colorUrg     = "#cc896d"         -- urgent, peach
colorUrg2    = "#c4df90"         -- urgent, lime

barHeight    = 22
monitorWidth = 1200              -- two statusbars will span this width
leftBarWidth = 600               -- right bar will span difference

-- }}}

-- Options {{{
--
-- if you change workspace names, be sure to update them throughout
--
myTerminal      = "urxvtc"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myBorderWidth   = 3
myModMask       = mod4Mask

myWorkspaces    = ["1-main","2-web","3-emat","4-file","5-vm"] ++ map show [6..9]

-- myNormalBorderColor  = "#dddddd"
-- myFocusedBorderColor = "#ff0000"
myNormalBorderColor  = colorFG
myFocusedBorderColor = colorUrg

-- }}}

-- Status Bars {{{
--
makeDzen :: Int -> Int -> Int -> Int -> String -> String
makeDzen x y w h a = "dzen2 -p" ++
                     " -ta "    ++ a       ++
                     " -x "     ++ show x  ++
                     " -y "     ++ show y  ++
                     " -w "     ++ show w  ++
                     " -h "     ++ show h  ++
                     " -fn '"   ++ myFont  ++ "'" ++
                     " -fg '"   ++ colorFG ++ "'" ++
                     " -bg '"   ++ colorBG ++ "' -e 'onstart=lower'"

-- define the bars
myLeftBar  = makeDzen 0 0 leftBarWidth barHeight "l"
myRightBar = "conky -c " ++ conkyFile ++ " | " ++ makeDzen leftBarWidth 0 (monitorWidth - leftBarWidth) barHeight "r"

-- }}}


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    [ ((modm,               xK_t     ), spawn $ XMonad.terminal conf) -- launch a terminal
    , ((modm .|. shiftMask, xK_b     ), spawn "firefox")              -- open web client
    , ((modm .|. shiftMask, xK_g     ), spawn "google-chrome-stable") -- open Google Chromium
    , ((modm .|. shiftMask, xK_u     ), spawn "uzbl-browser")         -- open Uzbl browser
    , ((modm .|. shiftMask, xK_f     ), spawn myFile)                 -- open ranger
    , ((modm .|. shiftMask, xK_m     ), spawn myMail)                 -- open mail client
    , ((modm .|. shiftMask, xK_i     ), spawn myIRC)                  -- open/attach IRC client in screen
    , ((modm,               xK_o     ), scratchPad)                   -- open quick scratchpad
    , ((modm,               xK_p     ), spawn "dmenu_run")            -- launch dmenu
    , ((modm,               xK_s     ), spawn "skype-bin")                -- open skype 

    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun") -- launch gmrun
    , ((modm,               xK_c     ), kill) -- close focused window

    , ((modm,               xK_space ), sendMessage NextLayout) -- Rotate through the available layout algorithms
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf) --  Reset the layouts on the current workspace to default
    , ((modm,               xK_n     ), refresh) -- Resize viewed windows to the correct size

    , ((modm,               xK_Tab   ), windows W.focusDown) -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown) -- Move focus to the next window
    , ((modm,               xK_k     ), windows W.focusUp  ) -- Move focus to the previous window
    , ((modm,               xK_m     ), windows W.focusMaster  ) -- Move focus to the master window
    , ((modm,               xK_Return), windows W.swapMaster) -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  ) -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    ) -- Swap the focused window with the previous window

    , ((modm, 		    xK_h     ), focusScreen 0)      -- focus left screen 0
    , ((modm,		    xK_l     ), focusScreen 1)      -- focus left screen 1
    , ((modm,		    xK_y     ), swapNextScreen)     -- swap next screen
    , ((modm .|. shiftMask, xK_y     ), shiftNextScreen)    -- move window to next screen
    , ((modm .|. shiftMask, xK_h     ), sendMessage Shrink) -- Shrink the master area
    , ((modm .|. shiftMask, xK_l     ), sendMessage Expand) -- Expand the master area
    
    , ((modm .|. shiftMask, xK_t     ), withFocused $ windows . W.sink) -- Push window back into tiling
    , ((modm,               xK_f     ), jumpToFull)                     -- Push window to full layout
    , ((modm,            xK_quoteleft), toggleWS) 

    , ((modm              , xK_comma ), sendMessage (IncMasterN 1)) -- Increment the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1))) -- Deincrement the number of windows in the master area

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm .|. shiftMask, xK_z     ), spawn "slock")
    , ((controlMask       , xK_Print ), spawn "sleep 0.2; scrot -s")
    , ((0                 , xK_Print ), spawn "scrot")


    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess)) -- Quit xmonad
    , ((modm              , xK_q     ), spawn myRestart)           -- Restart xmonad
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(viewOnScreen 0, 0),
        	     (viewOnScreen 1, controlMask),
        	     (W.greedyView, controlMask .|. shiftMask),
    	             (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    where
        myMail    = myTerminal ++ " -e mutt"
        myIRC     = myScreen "irssi"
        myFile    = myTerminal ++ " -e ranger"

        myScreen s = myTerminal ++ " -title "                    ++ s
				++ " -e bash -cl \"SCREEN_CONF=" ++ s 
				++ " screen -S "                 ++ s 
				++ " -R -D "
				++ "\""

	scratchPad = scratchpadSpawnActionTerminal myTerminal

        focusScreen n = screenWorkspace n >>= flip whenJust (windows . W.view)

        jumpToFull    = sendMessage $ JumpToLayout "Full"

        -- kill all conky/dzen2 before executing default restart command
        myRestart     = "for pid in `pgrep conky`; do kill -9 $pid; done && " ++
                        "for pid in `pgrep dzen2`; do kill -9 $pid; done && " ++
                        "xmonad --recompile && xmonad --restart"

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = lessBorders OnlyFloat $ avoidStruts $ onWorkspace "3-emat" imLayout $ standardLayouts

  where

     --standardLayouts = tiled ||| tabbed shrinkText defaultTheme ||| Full 
     standardLayouts = tiled ||| myTabLayout ||| full 
     -- ||| TwoPane(3/100) (1/2) 

     -- im roster on left tenth, standardLayouts in other nine tenths
     imLayout        = withIM (1/10) imProp standardLayouts

     -- WMROLE = "roster" is IMs' buddy list
     imProp          = Role "roster"

     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     -- tiled   = hinted $ ResizableTall nmaster delta ratio []
     -- full    = hinted $ noBorders Full
     full 	= noBorders Full

     -- like hintedTile but for any layout l
     -- hinted l        = layoutHintsWithPlacement (0,0) l

     nmaster = 1 -- The default number of windows in the master pane
     delta   = 3/100 -- Percent of screen to increment by when resizing panes
     -- ratio   = 1/2 -- Default proportion of screen occupied by master pane
     ratio           = toRational $ 2/(1 + sqrt 5 :: Double) -- golden ratio

     myTabLayout = noBorders $ tabbed shrinkText myTheme

     myTheme :: Theme
     myTheme = defaultTheme 
 		{ activeColor = colorFG
                , inactiveColor = colorFG
                , urgentColor = colorFG2
                , activeBorderColor = colorBG
                , inactiveTextColor = colorBG
                , urgentTextColor = colorFG2
                , inactiveBorderColor = colorBG
                , urgentBorderColor = colorUrg2
                , activeTextColor = colorUrg
                , fontName = "Verdana-8"
		, decoHeight = 17
                }


------------------------------------------------------------------------
-- Window rules:

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
-- ManageHook {{{
myManageHook = (composeAll . concat $
  [ [resource  =? r                 --> doIgnore         |  r    <- myIgnores] -- ignore desktop
  , [className =? c                 --> doShift "2-web"  |  c    <- myWebs   ] -- move webs to web
  , [title     =? f                 --> doShift "4-file" |  f    <- myFiles  ] -- move files to file
  , [title     =? t                 --> doShift "3-emat" |  t    <- myEmat   ] -- move emats to emat
  , [className =? t                 --> doShift "3-emat" |  t    <- myEmail  ] -- move email to emat
  , [className =? c                 --> doShift "3-emat" | (c,_) <- myIMs    ] -- move chats to chat
  , [className =? c <&&> role /=? r --> doFloat          | (c,r) <- myIMs    ] -- float all ims but roster
  , [className =? c                 --> doFloat          |  c    <- myFloats ] -- float my floats
  , [className =? c                 --> doCenterFloat    |  c    <- myCFloats] -- float my floats
  , [className =? c                 --> doShift "5-vm"   |  c    <- myVMs    ] -- move VMs
  , [name      =? n                 --> doFloat          |  n    <- myNames  ] -- float my names
  , [name      =? n                 --> doCenterFloat    |  n    <- myCNames ] -- float my names
  , [isFullscreen                   --> myDoFullFloat                        ]
  ]) <+> manageTypes <+> manageDocks <+> manageScratchPad

  where

    role      = stringProperty "WM_WINDOW_ROLE"
    name      = stringProperty "WM_NAME"

    -- [ ("class1","role1"), ("class2","role2"), ... ]
    myIMs     = [("pidgin","roster"),("Skype-bin","roster")]
    -- titles
    myEmat    = ["irssi","mutt","finch","sup"]

    -- classnames
    myEmail   = ["Mail","Lanikai"]
    myFloats  = ["MPlayer","Zenity","VirtualBox","rdesktop","TeamViewer.exe","Wine","mpv"]
    myCFloats = ["Xmessage","Save As...","XFontSel","Vncviewer"]
    myVMs     = ["VirtualBox","rdesktop","TeamViewer.exe","Wine"]

    myWebs    = ["Navigator","Namoroka","Firefox","Swiftfox"] ++ -- firefox
                ["Google-chrome","Chromium"] ++                  -- chrom(e|ium)
		["Uzbl-core","Uzbl-browser"]                     -- uzbl

    myFiles   = ["ranger"]

    -- resources
    myIgnores = ["desktop","desktop_window"]

    -- names
    myNames   = ["Google Chrome Options","Chromium Options"]
    myCNames  = ["gmrun"]

    -- a trick for fullscreen but stil allow focusing of other WSs
    myDoFullFloat = doF W.focusDown <+> doFullFloat

    -- modified version of manageDocks
    manageTypes = checkType --> doCenterFloat

      where

        checkType :: Query Bool
        checkType = ask >>= \w -> liftX $ do
          m   <- getAtom    "_NET_WM_WINDOW_TYPE_MENU"
          d   <- getAtom    "_NET_WM_WINDOW_TYPE_DIALOG"
          u   <- getAtom    "_NET_WM_WINDOW_TYPE_UTILITY"
          mbr <- getProp32s "_NET_WM_WINDOW_TYPE" w

          case mbr of
            Just [r] -> return $ elem (fromIntegral r) [m,d,u]
            _        -> return False

-- }}}

manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook (W.RationalRect l t w h)
    where
	h = 0.2        -- terminal height, 20%
	w = 0.5        -- terminal width,  50%
	t = 0.9 - h    -- distance from top edge
	l = (1.3 - w)/2  -- centered left/right

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
--myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging
-- LogHook {{{
myLogHook :: Handle -> X ()
myLogHook h = (dynamicLogWithPP $ defaultPP
  { ppCurrent         = dzenFG colorUrg2 . pad
  , ppVisible         = dzenFG colorFG2  . pad
  , ppUrgent          = dzenFG colorUrg  . pad . dzenStrip
  , ppLayout          = dzenFG colorFG2  . myppLayout
  , ppHidden          = dzenFG colorFG2  . pad . noScratchPad
  , ppHiddenNoWindows = namedOnly
  , ppTitle           = shorten 100 
  , ppSort            = getSortByXineramaRule

  --, ppExtras          = [myMail, myUpdates, myTorrents]
  , ppExtras          = [myMail]

  , ppSep             = "    "
  , ppWsSep           = ""
  , ppOutput          = hPutStrLn h
  }) >> updatePointer (Relative 0.95 0.95)

  where

    -- thanks byorgey (this filters out NSP too)
    namedOnly ws = if any (`elem` ws) ['a'..'z'] then pad ws else ""

    noScratchPad ws = if ws == "NSP" then "" else pad ws

    -- L needed for loggers
    dzenFG  c = dzenColor  c ""
    dzenFGL c = dzenColorL c "" 

    -- custom loggers
    myMail     = wrapL "Mail: " ""  . dzenFGL colorFG2 $ maildirNew "/home/hoangtran/.mail/gwrg/INBOX"
    --myMail     = wrapL "Mail: " ""  . dzenFGL colorFG2 $ logCmd "cat /home/httran/.newmessages"
    --myUpdates  = logCmd "$HOME/bin/logger-updates"
    --myTorrents = logCmd "$HOME/bin/logger-torrents"

    myppLayout = (\x -> case x of
               "Tall"          		       -> "| |-|"
               "TwoPane"                       -> "| | |"
               "Tabbed Simplest"               -> "|...|"
               "Full"                          -> "|  |"
               _                               -> x 
               ) . stripIM

    stripIM s = if "IM " `isPrefixOf` s then drop (length "IM ") s else s

-- }}}

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- Main {{{
main = do 
   replace
   d <- spawnPipe myLeftBar
   spawnList myStartupApps
   
   -- ewmh just makes wmctrl work
   xmonad $ ewmh $ withUrgencyHook NoUrgencyHook $ defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
      --handleEventHook    = myEventHook,
        logHook            = myLogHook d,
        startupHook        = setWMName "LG3D"
    } 
    where

      spawnList :: [String] -> IO ()
      spawnList = mapM_ spawn

      -- apps to start along with xmonad
      myStartupApps = [myRightBar]
-- }}}
