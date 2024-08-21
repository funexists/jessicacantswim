import Raylib.Types

import Examples.JessicaCantSwim.Camera
import Examples.JessicaCantSwim.Collision
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity
import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Scoreboard
import Examples.JessicaCantSwim.Ocean

namespace Game

structure Game where
  camera : Camera.Camera
  -- Add your new Entity here:
  player: Player.Player
  ocean: Ocean.Ocean
  scoreboard: Scoreboard.Scoreboard

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight
  {
    camera := camera,
    -- Add your new Entity here:
    player := Player.init position,
    scoreboard := Scoreboard.init,
    ocean := Ocean.init screenWidth screenHeight,
  }

private def Game.update (game: Game) (delta : Float) (msg: Entity.Msg): Game :=
  {
    camera := game.camera,
    -- Add your new Entity here:
    player := game.player.update delta msg
    scoreboard := game.scoreboard.update delta msg
    ocean := game.ocean.update delta msg
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    -- Add your new Entity here:
    game.ocean.render
    game.player.render
    game.scoreboard.render
  return ()

private def Game.updates (game: Game) (delta : Float) (events: List Entity.Msg): Id Game := do
  let mut game := game
  for event in events do
    game := game.update delta event
  return game

def Game.step (game: Game) (delta : Float) (externalEvents: List Entity.Msg): Game :=
  let collisions := Collision.detects [(game.ocean.id, game.ocean.bounds), (game.player.id, game.player.bounds)]
  let collisionsMsgs := List.map (λ collision => Entity.Msg.Collision collision.1 collision.2) collisions
  let allEvents := List.append externalEvents collisionsMsgs
  Game.updates game delta allEvents

end Game
