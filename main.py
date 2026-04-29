from source.constants import SHIP_LENGTHS
from source.game import Game
from source.player import Player
from source.pygame_ui import PygameUI


def main() -> None:
    player = Player()
    ui = PygameUI()

    try:
        starter_is_my_turn = player.is_host

        while True:
            if (ships := ui.place_ship(SHIP_LENGTHS[-1])) is None:
                return

            player.set_ships(ships)
            game = Game(player)

            if not game.run(ui, starter_is_my_turn=starter_is_my_turn):
                return

            starter_is_my_turn = not starter_is_my_turn
    finally:
        ui.close()


if __name__ == "__main__":
    main()
