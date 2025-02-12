import «Raylean»

import JessicaCantSwim.Rand
import JessicaCantSwim.Shape
import JessicaCantSwim.Types
import JessicaCantSwim.Draw
import JessicaCantSwim.Keys
import JessicaCantSwim.Game

namespace JessicaCantSwim

open Raylean
open Raylean.Types

def getKeys: IO (List Keys.Keys) := do
  let mut keys := #[]
  if (← isKeyDown Key.down)
    then keys := keys.push Keys.Keys.Down
  if (← isKeyDown Key.up)
    then keys := keys.push Keys.Keys.Up
  if (← isKeyDown Key.left)
    then keys := keys.push Keys.Keys.Left
  if (← isKeyDown Key.right)
    then keys := keys.push Keys.Keys.Right
  return keys.toList

def draw (draw: Draw.Draw): IO Unit := do
  match draw with
  | Draw.Draw.Text text x y size ⟨ r, g, b, a ⟩ =>
    drawText text x y size ⟨ r, g, b, a ⟩
  | Draw.Draw.Rectangle ⟨ x, y, width, height ⟩ ⟨ r, g, b, a ⟩ =>
    drawRectangleRec ⟨ x, y, width, height ⟩ ⟨ r, g, b, a ⟩
  | Draw.Draw.Circle ⟨ ⟨ x, y ⟩ , radius ⟩  ⟨ r, g, b, a ⟩ =>
    drawCircleV ⟨ x, y ⟩ radius ⟨ r, g, b, a ⟩

def draws (drawings: List Draw.Draw): IO Unit := do
  for drawing in drawings do
    draw drawing

def main : IO Unit := do
  let screenWidth: Nat := 800
  let screenHeight : Nat := 450
  let startPosition : Shape.Vector2 := { x := 200, y := 200 }
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS 60
  let rand ← Rand.init 123
  let mut game := Game.init rand startPosition screenWidth screenHeight
  while not (← windowShouldClose) do
    let delta ← getFrameTime
    let keys ← getKeys
    let emits := game.emit
    let events: List Types.Msg := List.map (λ key => Types.Msg.Key key) keys
    game := game.step delta (List.flatten [events, emits])
    let drawings := game.view
    let ⟨ ⟨ ox, oy ⟩, ⟨ tx, ty ⟩, r, z ⟩ := game.camera
    renderFrame do
      clearBackground Color.Raylean.lightgray
      renderWithCamera2D ⟨ ⟨ ox, oy ⟩, ⟨ tx, ty ⟩, r, z ⟩ (draws drawings)
  closeWindow

end JessicaCantSwim
