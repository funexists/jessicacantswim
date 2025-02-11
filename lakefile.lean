import Lake
open Lake DSL

require raylean from git "https://github.com/funexists/raylean.git" @ "3a60f54222e06767daa93e50a8fcbc68975eee4c" with
  NameMap.empty
    |>.insert `bundle "off"
    |>.insert `resvg "disable"

package "jessicacantswim" where
  srcDir := "src"

lean_lib «JessicaCantSwim» where

@[default_target]
lean_exe "jessicacantswim" where
  root := `Main
  moreLinkArgs := Id.run do
    let mut args := #[ "lib/libraylib.a"]
    if (← System.Platform.isOSX) then
      args := args ++
        #[ "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
         , "-framework", "IOKit"
         , "-framework", "Cocoa"
         , "-framework", "OpenGL"
         ]
    args
