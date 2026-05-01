from source.constants import SHIP_LENGTHS
from source.game import Game
from source.player import Player
from source.pygame_ui import PygameUI
from source.ship import Ship


def main() -> None:
    player = Player()
    is_host = player.is_host
    ui = PygameUI(window_on_left=is_host)

    try:
        starter_is_my_turn = is_host

        while True:
            ships: list[Ship] = []

            for length in SHIP_LENGTHS:
                if (ship := ui.place_ship(length, ships)) is None:
                    return

                ships.append(ship)

            player.set_ships(ships)
            game = Game(player)

            if not game.run(ui, starter_is_my_turn=starter_is_my_turn):
                return

            starter_is_my_turn = not starter_is_my_turn
    finally:
        ui.close()


if __name__ == "__main__":
    main()
