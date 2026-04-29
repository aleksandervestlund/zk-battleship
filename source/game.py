from dataclasses import dataclass
from queue import Empty
from secrets import randbelow
from time import sleep

from source.battleship_zk import (
    BattleshipSecret,
    commitment_for,
    make_hit_response,
    make_secret,
    setup_battleship_circuit,
    verify_hit_response,
)
from source.client import incoming, recv, send
from source.commitment_status import CommitmentStatus
from source.constants import (
    HIT_STR,
    LOST_STR,
    MISS_STR,
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
    secret: BattleshipSecret | None = None
    commitment: str | None = None
    opponent_commitment: str | None = None
    commitment_status: CommitmentStatus = CommitmentStatus.PENDING

    def __post_init__(self) -> None:
        setup_battleship_circuit()
        self.secret = make_secret(
            self.player.board.committed_coordinate(), salt=randbelow(2**32)
        )
        self.commitment = commitment_for(self.secret)

    def check_lost(self) -> bool:
        return self.player.board.check_all_ships_sunk()

    def handle_my_go(self, ui: PygameUI) -> bool:
        if (
            choice := ui.wait_for_target_click(
                self.player.board,
                status=TURN_MSG,
                commitment_status=self.commitment_status,
            )
        ) is None:
            return False

        row, col = choice
        coordinate = Coordinate(ROWS[row], col + 1)

        send(self.player.conn, str(coordinate))

        ui.draw(
            self.player.board,
            status="Verifying opponent's proof...",
            commitment_status=self.commitment_status,
        )
        result = verify_hit_response(
            recv(),
            guess=coordinate,
            expected_commitment=self._opponent_commitment(),
        )
        ui.draw(
            self.player.board,
            status="Opponent's proof verified.",
            commitment_status=self.commitment_status,
        )
        hit = result in {HIT_STR, LOST_STR}
        self.player.board.check_hit_on_other(coordinate, hit)

        if result == LOST_STR:
            ui.draw(
                self.player.board,
                status=WIN_MSG,
                commitment_status=self.commitment_status,
            )
            return False
        return True

    def handle_opponent_go(self, ui: PygameUI) -> bool:
        coordinate = Coordinate.from_str(
            self._recv_with_ui_update(ui, "Waiting for opponent...")
        )
        hit = self.player.board.check_hit_on_self(coordinate)
        result = (
            LOST_STR
            if hit and self.check_lost()
            else HIT_STR if hit else MISS_STR
        )
        ui.draw(
            self.player.board,
            status="Generating proof...",
            commitment_status=self.commitment_status,
        )
        response = make_hit_response(
            coordinate,
            hit=hit,
            result=result,
            commitment=self._commitment(),
            secret=self._secret(),
        )
        ui.draw(
            self.player.board,
            status="Proof generated.",
            commitment_status=self.commitment_status,
        )
        send(self.player.conn, response)

        if hit and self.check_lost():
            send(self.player.conn, LOST_STR)
            ui.draw(
                self.player.board,
                status="You lost",
                commitment_status=self.commitment_status,
            )
            return False

        return True

    def run(self, ui: PygameUI) -> None:
        self._exchange_commitments_with_ui_update(ui)
        my_go = self.player.is_host

        while self.handle_my_go(ui) if my_go else self.handle_opponent_go(ui):
            my_go = not my_go

    def _exchange_commitments_with_ui_update(self, ui: PygameUI) -> None:
        self.commitment_status = CommitmentStatus.PENDING
        send(self.player.conn, self._commitment())
        self.opponent_commitment = self._recv_with_ui_update(
            ui, "Exchanging commitments..."
        )
        self.commitment_status = CommitmentStatus.VERIFIED

    def _recv_with_ui_update(self, ui: PygameUI, status: str) -> str:
        duration = 1 / 60  # ~60 FPS

        while True:
            try:
                return incoming.get_nowait()
            except Empty:
                ui.draw(
                    self.player.board,
                    status=status,
                    commitment_status=self.commitment_status,
                )
                sleep(duration)

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
