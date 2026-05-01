import os
from collections.abc import Sequence

import pygame
from pygame import (
    K_ESCAPE,
    K_RETURN,
    KEYDOWN,
    MOUSEBUTTONDOWN,
    QUIT,
    K_c,
    K_n,
    K_r,
    K_y,
    Rect,
    display,
    draw,
)
from pygame.display import Info
from pygame.font import SysFont
from pygame.time import Clock

from source.board import Board
from source.constants import N_COLS, N_ROWS, OTHER_BOARD, OWN_BOARD, ROWS
from source.coordinate import Coordinate
from source.orientation import Orientation
from source.ship import Ship
from source.square import Square


class PygameUI:
    CELL = 40
    PAD = 24
    GAP = 80
    RIGHT_PADDING = 24
    BOTTOM_MARGIN = 80
    FPS = 60
    LABEL_GAP = 22
    TOP_OFFSET = 88
    INSPECTOR_HEIGHT = 160
    SHIP_COLORS = [
        (70, 190, 120),
        (200, 120, 60),
        (110, 150, 220),
        (190, 70, 180),
        (220, 200, 80),
    ]

    def __init__(
        self,
        show_self_on_left: bool = True,
        window_on_left: bool | None = None,
    ) -> None:
        pygame.init()
        font_name = self._font_name()
        self.font = SysFont(font_name, 20)
        self.small = SysFont(font_name, 16)
        self.show_self_on_left = show_self_on_left
        self.window_on_left = window_on_left
        board_w = N_COLS * self.CELL
        board_h = N_ROWS * self.CELL

        info = Info()
        screen_w = info.current_w
        screen_h = info.current_h

        natural_width = (
            self.PAD * 2 + board_w * 2 + self.GAP + self.RIGHT_PADDING
        )
        natural_height_needed = (
            self.PAD * 2 + board_h + 124 + self.INSPECTOR_HEIGHT
        )
        available_screen_h = (
            screen_h - self.BOTTOM_MARGIN if screen_h else None
        )
        height = (
            min(available_screen_h, natural_height_needed)
            if available_screen_h is not None
            else natural_height_needed
        )
        half_w = max(200, screen_w // 2) if screen_w else natural_width
        width = half_w

        if natural_width > half_w and screen_w:
            available_for_boards = max(100, half_w - (self.PAD * 2 + self.GAP))
            new_cell = max(10, available_for_boards // (2 * N_COLS))
            self.CELL = new_cell
            board_w = N_COLS * self.CELL
            natural_width = self.PAD * 2 + board_w * 2 + self.GAP
            width = min(natural_width, half_w)

        self.max_label_width = max(self.small.size(r)[0] for r in ROWS)
        self.label_reserve = self.max_label_width + 6

        req = self.total_required_width(self.CELL)

        if req > width and screen_w:
            avail_for_two_boards = width - (
                self.PAD
                + self.LABEL_GAP
                + self.label_reserve
                + self.GAP
                + self.PAD
                + self.RIGHT_PADDING
            )
            if avail_for_two_boards > 0:
                new_cell = max(10, avail_for_two_boards // (2 * N_COLS))
            else:
                new_cell = 10
            self.CELL = new_cell
            board_w = N_COLS * self.CELL
            req = self.total_required_width(self.CELL)

            if req > width:
                width = req

        if self.window_on_left is True:
            x = 0
        elif self.window_on_left is False:
            x = screen_w - width if screen_w else 0
        else:
            pid = os.getpid()
            x = 0 if (pid % 2 == 0) else screen_w - width if screen_w else 0

        y = (
            0
            if height == screen_h
            else max(0, (screen_h - height) // 2) if screen_h else 0
        )
        os.environ["SDL_VIDEO_WINDOW_POS"] = f"{x},{y}"

        self.screen = display.set_mode((width, height))
        display.set_caption("Battleship")
        self.clock = Clock()

        self.max_label_width = max(self.small.size(r)[0] for r in ROWS)
        self.label_reserve = self.max_label_width + 6
        self.left_origin = (
            self.PAD + self.LABEL_GAP + self.label_reserve,
            self.PAD + self.TOP_OFFSET + self.LABEL_GAP,
        )

        screen_w = self.screen.get_width()
        right_x = (
            screen_w
            - (self.PAD + self.RIGHT_PADDING)
            - board_w
            - self.LABEL_GAP
        )
        default_right_x = self.left_origin[0] + board_w + self.GAP
        if (
            default_right_x + board_w + self.PAD + self.RIGHT_PADDING
            <= screen_w
        ):
            right_x = default_right_x

        min_right_x = (
            self.left_origin[0] + board_w + self.GAP + self.label_reserve
        )

        if right_x < min_right_x:
            right_x_candidate = (
                screen_w
                - (self.PAD + self.RIGHT_PADDING)
                - board_w
                - self.LABEL_GAP
            )

            if right_x_candidate >= min_right_x:
                right_x = right_x_candidate
            else:
                right_x = min_right_x

        self.right_origin = (
            right_x,
            self.PAD + self.TOP_OFFSET + self.LABEL_GAP,
        )
        self.proof_lines = [
            "Proof Inspector",
            "Commitments and proof results will appear here.",
        ]
        self.cheat_mode = False

    def total_required_width(self, cell_size: int) -> int:
        b_w = N_COLS * cell_size
        return (
            self.PAD
            + self.LABEL_GAP
            + self.label_reserve
            + b_w
            + self.GAP
            + b_w
            + self.PAD
            + self.RIGHT_PADDING
        )

    def close(self) -> None:
        pygame.quit()

    def pump_events(self) -> bool:
        return all(
            self._handle_common_event(event) for event in pygame.event.get()
        )

    def set_proof_lines(self, lines: Sequence[str]) -> None:
        self.proof_lines = list(lines)

    def place_ship(
        self, ship_length: int, placed_ships: Sequence[Ship] | None = None
    ) -> Ship | None:
        orientation = Orientation.HORIZONTAL
        placed = list(placed_ships or [])

        while True:
            hovered = self._grid_cell_from_pos(
                pygame.mouse.get_pos(), self.left_origin
            )
            candidate = self._ship_for_cell(hovered, orientation, ship_length)
            if candidate is not None and not self._is_ship_placement_valid(
                candidate, placed
            ):
                candidate = None

            for event in pygame.event.get():
                if not self._handle_common_event(event):
                    return None
                if event.type == QUIT:
                    return None
                if event.type == KEYDOWN and event.key == K_r:
                    orientation = (
                        Orientation.VERTICAL
                        if orientation is Orientation.HORIZONTAL
                        else Orientation.HORIZONTAL
                    )
                if (
                    event.type == MOUSEBUTTONDOWN
                    and event.button == 1
                    and candidate is not None
                ):
                    return candidate

            self._fill_background()
            orient_label = (
                "Horizontal"
                if orientation is Orientation.HORIZONTAL
                else "Vertical"
            )
            self._draw_heading(
                "Place Your Ship",
                f"Length {ship_length}. Click to place. Press R to rotate "
                f"({orient_label}).",
            )
            self._draw_board_grid(
                self.left_origin,
                OWN_BOARD,
                placed_ships=placed,
                preview_ship=candidate,
                preview_index=len(placed),
            )
            display.flip()
            self.clock.tick(self.FPS)

    def draw(
        self,
        board: Board,
        status: str = "",
        hover_other: tuple[int, int] | None = None,
    ) -> None:
        self._fill_background()
        self._draw_board(
            board.self_view,
            self.left_origin,
            OWN_BOARD,
            hide_ships=False,
            placed_ships=board.ships,
        )
        self._draw_board(
            board.other_view,
            self.right_origin,
            OTHER_BOARD,
            hide_ships=False,
            hover_cell=hover_other,
        )

        if status:
            self._draw_status_lines(status)

        self._draw_proof_inspector()

        display.flip()
        self.clock.tick(self.FPS)

    def wait_for_target_click(
        self, board: Board, status: str = ""
    ) -> tuple[int, int] | None:
        while True:
            hover_cell = self._hoverable_other_cell(board)
            self.draw(board, status=status, hover_other=hover_cell)

            for event in pygame.event.get():
                if not self._handle_common_event(event):
                    return None

                if event.type == MOUSEBUTTONDOWN and event.button == 1:
                    if hover_cell is not None:
                        return hover_cell

            self.clock.tick(self.FPS)

    def wait_for_replay(self, board: Board, status: str) -> bool:
        while True:
            self.draw(board, status=status)

            for event in pygame.event.get():
                if not self._handle_common_event(event):
                    return False

                if event.type == KEYDOWN:
                    if event.key in {K_y, K_RETURN}:
                        return True
                    if event.key in {K_n, K_ESCAPE}:
                        return False

            self.clock.tick(self.FPS)

    def _draw_board(
        self,
        grid: Sequence[Sequence[Square]],
        origin: tuple[int, int],
        title: str,
        hide_ships: bool,
        hover_cell: tuple[int, int] | None = None,
        placed_ships: Sequence[Ship] | None = None,
        preview_ship: Ship | None = None,
        preview_index: int | None = None,
    ) -> None:
        ox, oy = origin
        title_surf = self.font.render(title, True, (220, 220, 220))
        self.screen.blit(title_surf, (ox, oy - 54))
        self._draw_grid_labels(origin)
        ship_color_map: dict[tuple[int, int], tuple[int, int, int]] = {}

        if placed_ships:
            for idx, ship in enumerate(placed_ships):
                color = self.SHIP_COLORS[idx % len(self.SHIP_COLORS)]

                for coordinate in ship.hits:
                    ship_color_map[coordinate.to_idx()] = color

        preview_coords: set[tuple[int, int]] = set()

        if preview_ship is not None:
            for coordinate in preview_ship.hits:
                preview_coords.add(coordinate.to_idx())

        preview_color = None

        if preview_index is not None:
            preview_color = self.SHIP_COLORS[
                preview_index % len(self.SHIP_COLORS)
            ]
        elif preview_ship is not None:
            preview_color = self.SHIP_COLORS[0]

        for r in range(N_ROWS):
            for c in range(N_COLS):
                sq = grid[r][c]

                if sq == Square.SHIP and not hide_ships:
                    if (r, c) in preview_coords:
                        base = preview_color or ship_color_map.get(
                            (r, c), self.SHIP_COLORS[0]
                        )
                        color = self._hover_color(base)
                    else:
                        color = ship_color_map.get((r, c), self.SHIP_COLORS[0])
                else:
                    color = self._color_for_square(sq, hide_ships)

                if hover_cell == (r, c):
                    color = self._hover_color(color)

                rect = Rect(
                    ox + c * self.CELL,
                    oy + r * self.CELL,
                    self.CELL,
                    self.CELL,
                )
                draw.rect(self.screen, color, rect)
                draw.rect(self.screen, (50, 60, 75), rect, width=1)

    def _draw_board_grid(
        self,
        origin: tuple[int, int],
        title: str,
        placed_ships: Sequence[Ship] | None = None,
        preview_ship: Ship | None = None,
        preview_index: int | None = None,
    ) -> None:
        grid = [[Square.EMPTY] * N_COLS for _ in range(N_ROWS)]

        for ship in placed_ships or []:
            for coordinate in ship.hits:
                row, col = coordinate.to_idx()
                grid[row][col] = Square.SHIP

        if preview_ship is not None:
            for coordinate in preview_ship.hits:
                row, col = coordinate.to_idx()
                grid[row][col] = Square.SHIP

        self._draw_board(
            grid,
            origin,
            title,
            hide_ships=False,
            placed_ships=placed_ships,
            preview_ship=preview_ship,
            preview_index=preview_index,
        )

    def _draw_heading(self, title: str, subtitle: str) -> None:
        title_surface = self.font.render(title, True, (240, 240, 240))
        subtitle_surface = self.small.render(subtitle, True, (185, 190, 200))
        self.screen.blit(title_surface, (self.PAD, 16))
        self.screen.blit(subtitle_surface, (self.PAD, 48))

    def _draw_status(
        self, message: str, color: tuple[int, int, int] = (185, 190, 200)
    ) -> None:
        surface = self.small.render(message, True, color)
        self.screen.blit(surface, (self.PAD, self.screen.get_height() - 36))

    def _draw_status_lines(self, status: str) -> None:
        for index, line in enumerate(status.splitlines()):
            surface = self.small.render(line, True, (240, 240, 240))
            self.screen.blit(surface, (self.PAD, 8 + index * 18))

    def _draw_proof_inspector(self) -> None:
        y = self.screen.get_height() - self.INSPECTOR_HEIGHT - self.PAD
        rect = Rect(
            self.PAD,
            y,
            self.screen.get_width() - self.PAD * 2 - self.RIGHT_PADDING,
            self.INSPECTOR_HEIGHT,
        )
        draw.rect(self.screen, (24, 30, 40), rect)
        draw.rect(self.screen, (68, 78, 96), rect, width=1)

        lines = [
            *self.proof_lines[:5],
            f"Demo cheat mode: {'ON' if self.cheat_mode else 'OFF'} "
            "(press C to toggle)",
        ]
        for index, line in enumerate(lines):
            color = (245, 190, 90) if "REJECTED" in line else (210, 216, 228)
            surface = self.small.render(line, True, color)
            self.screen.blit(surface, (rect.x + 12, rect.y + 10 + index * 18))

    def _fill_background(self) -> None:
        self.screen.fill((18, 22, 30))

    def _hoverable_other_cell(self, board: Board) -> tuple[int, int] | None:
        cell = self._grid_cell_from_pos(
            pygame.mouse.get_pos(), self.right_origin
        )

        if cell is None:
            return None

        row, col = cell

        if board.other_view[row][col] in {Square.HIT, Square.MISS}:
            return None
        return cell

    def _grid_cell_from_pos(
        self, pos: tuple[int, int], origin: tuple[int, int]
    ) -> tuple[int, int] | None:
        mx, my = pos
        x0, y0 = origin

        if not (
            x0 <= mx < x0 + N_COLS * self.CELL
            and y0 <= my < y0 + N_ROWS * self.CELL
        ):
            return None

        col = (mx - x0) // self.CELL
        row = (my - y0) // self.CELL
        return row, col

    def _ship_for_cell(
        self,
        cell: tuple[int, int] | None,
        orientation: Orientation,
        ship_length: int,
    ) -> Ship | None:
        if cell is None:
            return None

        row, col = cell

        try:
            return Ship(
                Coordinate(row=chr(ord("A") + row), column=col + 1),
                orientation,
                ship_length,
            )
        except ValueError:
            return None

    @staticmethod
    def _is_ship_placement_valid(
        candidate: Ship, placed_ships: Sequence[Ship]
    ) -> bool:
        occupied = {
            coordinate for ship in placed_ships for coordinate in ship.hits
        }
        return all(coordinate not in occupied for coordinate in candidate.hits)

    @staticmethod
    def _color_for_square(
        square: Square, hide_ships: bool
    ) -> tuple[int, int, int]:
        if square == Square.HIT:
            return 220, 70, 70
        if square == Square.MISS:
            return 120, 140, 170
        if square == Square.SHIP and not hide_ships:
            return 70, 190, 120
        return 36, 48, 66

    def _draw_grid_labels(self, origin: tuple[int, int]) -> None:
        ox, oy = origin
        label_color = (185, 190, 200)

        for col in range(N_COLS):
            label = self.small.render(str(col + 1), True, label_color)
            x = ox + col * self.CELL + (self.CELL - label.get_width()) // 2
            y = oy - self.LABEL_GAP
            self.screen.blit(label, (x, y))

        for row, row_label in enumerate(ROWS):
            label = self.small.render(row_label, True, label_color)
            x = ox - self.LABEL_GAP - label.get_width()
            y = oy + row * self.CELL + (self.CELL - label.get_height()) // 2
            self.screen.blit(label, (x, y))

    def _handle_common_event(self, event: pygame.event.Event) -> bool:
        if event.type == QUIT:
            return False
        if event.type == KEYDOWN and event.key == K_c:
            self.cheat_mode = not self.cheat_mode
        return True

    @staticmethod
    def _font_name() -> str:
        for name in ("Consolas", "Menlo", "Courier New", "monospace"):
            if pygame.font.match_font(name):
                return name
        return pygame.font.get_default_font()

    @staticmethod
    def _hover_color(color: tuple[int, int, int]) -> tuple[int, int, int]:
        return tuple(min(channel + 28, 255) for channel in color)  # type: ignore
