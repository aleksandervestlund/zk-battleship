import json
from dataclasses import dataclass
from secrets import randbelow

from source.battleship_zk import (
    BoardSecret2,
    make_board_secret_2,
    make_hit_response2,
    prove_board2,
    setup_battleship_circuit,
    verify_board2,
    verify_hit_response2,
)
from source.client import recv, send
from source.constants import (
    HIT_STR,
    LOST_MSG,
    LOST_STR,
    MISS_STR,
    QUIT_STR,
    REPLAY_MSG,
    REPLAY_STR,
    ROWS,
    TURN_MSG,
    WIN_MSG,
)
from source.coordinate import Coordinate
from source.player import Player
from source.pygame_ui import PygameUI


@dataclass(slots=True)
class Game:
    player: Player
    secret: BoardSecret2 | None = None
    commitment: str | None = None
    opponent_commitment: str | None = None
    initial_proof: str | None = None

    def __post_init__(self) -> None:
        setup_battleship_circuit()
        shipx_coords = [
            ROWS.index(coord.row) + 1
            for ship in self.player.ships
            for coord in ship.hits
        ]
        shipy_coords = [
            coord.column
            for ship in self.player.ships
            for coord in ship.hits
        ]
        salt = randbelow(2**32)
        self.secret = make_board_secret_2(
            ships_x=shipx_coords, ships_y=shipy_coords, salt=salt
        )
        self.initial_proof = prove_board2(self.secret)
        self.commitment = json.loads(self.initial_proof)["public"]

    def check_lost(self) -> bool:
        return self.player.board.check_all_ships_sunk()

    def handle_my_go(self, ui: PygameUI) -> str:
        if (
            choice := ui.wait_for_target_click(
                self.player.board, status=TURN_MSG
            )
        ) is None:
            return "quit"

        row, col = choice
        coordinate = Coordinate(ROWS[row], col + 1)

        send(self.player.conn, str(coordinate))

        ui.draw(self.player.board, status="Verifying opponent's proof...")
        result = verify_hit_response2(
            recv(),
            guess=coordinate,
            expected_commitment=self._opponent_commitment(),
        )
        ui.draw(self.player.board, status="Opponent's proof verified.")
        hit = result in {HIT_STR, LOST_STR}
        self.player.board.check_hit_on_other(coordinate, hit)

        if result == LOST_STR:
            ui.draw(self.player.board, status=WIN_MSG)
            return "won"
        return "continue"

    def handle_opponent_go(self, ui: PygameUI) -> str:
        ui.draw(self.player.board, status="Waiting for opponent...")

        coordinate = Coordinate.from_str(recv())
        hit = self.player.board.check_hit_on_self(coordinate)
        result = (
            LOST_STR
            if hit and self.check_lost()
            else HIT_STR if hit else MISS_STR
        )
        ui.draw(self.player.board, status="Generating proof...")
        response = make_hit_response2(
            coordinate,
            hit=hit,
            result=result,
            commitment=self._commitment(),
            secret=self._secret(),
        )
        ui.draw(self.player.board, status="Proof generated.")
        send(self.player.conn, response)

        if hit and self.check_lost():
            ui.draw(self.player.board, status=LOST_MSG)
            return "lost"

        return "continue"

    def run(self, ui: PygameUI, starter_is_my_turn: bool) -> bool:
        ui.draw(self.player.board, status="Exchanging board proofs...")
        self.exchange_initial_proofs()
        ui.draw(self.player.board, status="Opponent board proofs verified.")

        my_go = starter_is_my_turn
        round_result = "continue"

        while round_result == "continue":
            round_result = (
                self.handle_my_go(ui) if my_go else self.handle_opponent_go(ui)
            )
            if round_result == "continue":
                my_go = not my_go

        if round_result == "quit":
            return False

        return self._agree_to_replay(ui, round_result)

    def _agree_to_replay(self, ui: PygameUI, round_result: str) -> bool:
        prompt = (
            f"{WIN_MSG if round_result == 'won' else LOST_MSG} {REPLAY_MSG}"
        )
        wants_replay = ui.wait_for_replay(self.player.board, status=prompt)
        send(self.player.conn, REPLAY_STR if wants_replay else QUIT_STR)
        opponent_wants_replay = recv() == REPLAY_STR
        return wants_replay and opponent_wants_replay

    def exchange_commitments(self) -> None:
        send(self.player.conn, self._commitment())
        self.opponent_commitment = recv()

    def exchange_initial_proofs(self) -> None:
        send(self.player.conn, self.initial_proof or "")
        msg = recv()
        self.opponent_commitment = json.loads(msg)["public"][0]
        verify_board2(msg)

    def _secret(self) -> BoardSecret2:
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
