from dataclasses import dataclass
from secrets import randbelow

from source.battleship_zk import (
    BattleshipSecret,
    commitment_for,
    make_hit_response,
    make_secret,
    setup_battleship_circuit,
    verify_hit_response,
)
from source.client import recv, send
from source.constants import (
    HIT_MSG,
    HIT_STR,
    LOST_STR,
    MISS_MSG,
    MISS_STR,
    TURN_MSG,
    WIN_MSG,
)
from source.coordinate import Coordinate
from source.input_helpers import get_coordinate
from source.player import Player


@dataclass(slots=True)
class Game:
    player: Player
    secret: BattleshipSecret | None = None
    commitment: str | None = None
    opponent_commitment: str | None = None

    def __post_init__(self) -> None:
        setup_battleship_circuit()
        self.secret = make_secret(
            self.player.board.committed_coordinate(),
            salt=randbelow(2**64),
        )
        self.commitment = commitment_for(self.secret)

    def attacking_turn(self) -> bool:
        print(TURN_MSG)
        self.player.board.print_board()

        coordinate = get_coordinate()
        send(self.player.conn, str(coordinate))

        result = verify_hit_response(
            recv(),
            guess=coordinate,
            expected_commitment=self._opponent_commitment(),
        )
        hit = result in {HIT_STR, LOST_STR}
        self.player.board.check_hit_on_other(coordinate, hit)

        if hit:
            print(HIT_MSG.format(coordinate=coordinate))
        else:
            print(MISS_MSG.format(coordinate=coordinate))

        self.player.board.print_board()
        return result == LOST_STR

    def check_lost(self) -> bool:
        return self.player.board.check_all_ships_sunk()

    def defending_turn(self) -> bool:
        coordinate = Coordinate.from_str(recv())
        hit = self.player.board.check_hit_on_self(coordinate)
        result = (
            LOST_STR
            if hit and self.check_lost()
            else HIT_STR if hit else MISS_STR
        )
        response = make_hit_response(
            coordinate,
            hit=hit,
            result=result,
            commitment=self._commitment(),
            secret=self._secret(),
        )
        send(self.player.conn, response)

        return hit

    def run(self) -> None:
        self.exchange_commitments()
        my_go = self.player.is_host

        while True:
            if my_go:
                if self.attacking_turn():
                    print(WIN_MSG)
                    break
            else:
                self.defending_turn()

            if my_go := not my_go:
                if self.attacking_turn():
                    print(WIN_MSG)
                    break
            else:
                self.defending_turn()

            my_go = not my_go

    def exchange_commitments(self) -> None:
        send(self.player.conn, self._commitment())
        self.opponent_commitment = recv()

    def _secret(self) -> BattleshipSecret:
        if self.secret is None:
            raise RuntimeError("Battleship ZK secret is not initialized")
        return self.secret

    def _commitment(self) -> str:
        if self.commitment is None:
            raise RuntimeError("Battleship commitment is not initialized")
        return self.commitment

    def _opponent_commitment(self) -> str:
        if self.opponent_commitment is None:
            raise RuntimeError("Opponent commitment is not initialized")
        return self.opponent_commitment
