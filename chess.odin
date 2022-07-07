package chess

@require foreign import {
    "system:OpenGL.framework",
    "system:GLUT.framework",
    "system:Cocoa.framework",
    "system:IOKit.framework",
    "system:CoreVideo.framework"
}

import "core:fmt"
import str "core:strings"
import "vendor:raylib"
import m "core:math"


WINDOW_H :: 1000
WINDOW_W :: 1000
WINDOW_TITLE :: "MOST AMAzinGINEST CHESS 🗿"
source : = "ABCDEFGH"
source2 : = "12345678"


PieceType :: enum{PAWN, ROOK, BISHOP, KNIGHT, KING, QUEEN}
Cardinality :: enum{H, W}


Piece :: struct {
    xPosition : int,
    yPosition : int,
    type : PieceType,
    piecesDefeatedCount : int,
    colour : raylib.Color,
    isSelected : bool,
    isDefeated : bool,
}

new_piece :: proc(xPosition:int = 0, yPosition:int = 0, type:PieceType = .PAWN, piecesDefeatedCount:int = 0, colour:raylib.Color = raylib.WHITE) -> ^Piece {
    new : ^Piece = new(Piece)
    new.xPosition = xPosition
    new.yPosition = yPosition
    new.type = type
    new.piecesDefeatedCount = piecesDefeatedCount
    new.colour = colour

    return new
}


Tile :: struct {
    xPos : string,
    yPos : string,
    xStartCoord : i32,
    yStartCoord : i32,
    sideLength : i32,
    isOccupied : bool,
    colour : raylib.Color,
}

new_tile :: proc(xPos:string = "a", yPos:string = "8", xStartCoord:i32 = 0, yStartCoord:i32 = 0, sideLength:i32 = 0, isOccupied:bool = false, colour:raylib.Color = raylib.BLACK) -> ^Tile {
    new : ^Tile = new(Tile)
    new.xPos = xPos
    new.yPos = yPos
    new.xStartCoord = xStartCoord
    new.yStartCoord = yStartCoord
    new.sideLength = sideLength
    new.isOccupied = isOccupied
    new.colour = colour

    return new
}


init_chess_board :: proc(tile_side:i32, start_coord:raylib.Vector2) -> [64]^Tile {
    using raylib

    colour : Color
    tiles : [64]^Tile

    for x in 0..7 {
        for y in 0..7 {
            colour = x%2 == y%2 ? WHITE : BLACK

            startCoordX := cast(i32)(cast(f32)(cast(i32)(x)*tile_side) + start_coord.x)
            startCoordY := cast(i32)(cast(f32)(cast(i32)(y)*tile_side) + start_coord.y)

            index : = (x * 8) + y
            number_coord : = fmt.aprint(y+1)

            tiles[index] = new_tile(xPos=get_letter_coordinate(x), yPos=number_coord, xStartCoord=startCoordX, yStartCoord=startCoordY, sideLength=tile_side, colour=colour)

            DrawRectangle(startCoordX, startCoordY, tile_side, tile_side, colour)
        }
    }
    DrawRectangleLinesEx({start_coord.x-1, start_coord.y-1, cast(f32)tile_side*8, cast(f32)tile_side*8}, 5, BLACK)

    return tiles
}

get_letter_coordinate :: proc(index:int) -> string {
    return source[index:index+1]
}

get_number_coordinate :: proc(index:int) -> string {
    return source2[index:index+1]
}


init_pieces :: proc() -> ([16]^Piece, [16]^Piece) {
    using raylib

    whitePieces : [16]^Piece
    blackPieces : [16]^Piece

    //PAWNS
    for x in 0..7 {
        whitePieces[x] = new_piece(xPosition=x, yPosition=6, colour=WHITE)
        blackPieces[x] = new_piece(xPosition=x, yPosition=1, colour=BLACK)
    }

    //ROOKS
    whitePieces[8] = new_piece(xPosition=0, yPosition=0, type=.ROOK, colour=WHITE)
    blackPieces[8] = new_piece(xPosition=7, yPosition=7, type=.ROOK, colour=BLACK)
    whitePieces[9] = new_piece(xPosition=7, yPosition=0, type=.ROOK, colour=WHITE)
    blackPieces[9] = new_piece(xPosition=0, yPosition=7, type=.ROOK, colour=BLACK)
    
    //KNIGHTS
    whitePieces[10] = new_piece(xPosition=1, yPosition=0, type=.KNIGHT, colour=WHITE)
    blackPieces[10] = new_piece(xPosition=6, yPosition=7, type=.KNIGHT, colour=BLACK)
    whitePieces[11] = new_piece(xPosition=6, yPosition=0, type=.KNIGHT, colour=WHITE)
    blackPieces[11] = new_piece(xPosition=1, yPosition=7, type=.KNIGHT, colour=BLACK)
    
    //BISHOPS
    whitePieces[12] = new_piece(xPosition=2, yPosition=0, type=.BISHOP, colour=WHITE)
    blackPieces[12] = new_piece(xPosition=5, yPosition=7, type=.BISHOP, colour=BLACK)
    whitePieces[13] = new_piece(xPosition=5, yPosition=0, type=.BISHOP, colour=WHITE)
    blackPieces[13] = new_piece(xPosition=2, yPosition=7, type=.BISHOP, colour=BLACK)
    
    //KINGS
    whitePieces[14] = new_piece(xPosition=4, yPosition=0, type=.KING, colour=WHITE)
    blackPieces[14] = new_piece(xPosition=4, yPosition=7, type=.KING, colour=BLACK)

    //QUEENS
    whitePieces[15] = new_piece(xPosition=3, yPosition=0, type=.QUEEN, colour=WHITE)
    blackPieces[15] = new_piece(xPosition=3, yPosition=7, type=.QUEEN, colour=BLACK)

    return whitePieces, blackPieces
}


update_tile_and_piece_window_coordinates :: proc(board:[64]^Tile, whites:[16]^Piece, blacks:[16]^Piece) {
    for tile in board {
    }
}


get_tile_at_coordinate :: proc(board:[64]^Tile, x:int, y:int) -> (^Tile, bool) {
    if x * 8 + y < len(board) do return board[(x*8) + y], true
    else do return nil, false
}

get_piece_at_coordinate :: proc(pieces:[16]^Piece, x:int, y:int) -> (^Piece, bool) {
    for piece in pieces {
        if piece.xPosition == x && piece.yPosition == y do return piece, true
    }
    return nil, false
}

draw_pieces :: proc(board:[64]^Tile, pieces:[16]^Piece) {
    using raylib
    for piece in pieces {
        this_too : = fmt.tprint(piece.type)
        this : cstring = str.clone_to_cstring(this_too)
        that : ^Tile
        if tile, succeeded := get_tile_at_coordinate(board, piece.xPosition, piece.yPosition); succeeded {
            that = tile
            DrawText(this, that.xStartCoord, that.yStartCoord + that.sideLength/2, 20, that.colour == WHITE ? BLACK : WHITE)
        }
        delete(this)
    }
}

get_window_fraction_f32 :: #force_inline proc(cardinality:Cardinality, operand:int, denominator:int=1) -> f32 {
    return cardinality == .H ? f32(operand * int(raylib.GetScreenHeight()) / denominator) : f32(operand * int(raylib.GetScreenWidth()) / denominator)
}

get_window_fraction_i32 :: proc(cardinality:Cardinality, operand:int, denominator:int=1) -> i32 {
    return i32(get_window_fraction_f32(cardinality, operand, denominator))
}

has_clicked_board :: proc() -> bool {
    using raylib

    return CheckCollisionPointRec(GetMousePosition(), Rectangle{get_window_fraction_f32(.H, 1, 6), get_window_fraction_f32(.W, 1, 6), get_window_fraction_f32(.H, 2, 3), cast(f32)GetScreenHeight()*2/3})
}

get_piece_left_clicked :: proc(whites:[16]^Piece, blacks:[16]^Piece) -> (^Piece, bool) {
    using raylib

    if has_clicked_board() {
        mousePos : Vector2 = GetMousePosition()
        mousePos.x = (mousePos.x - get_window_fraction_f32(.H, 1, 6)) / 8.33
        mousePos.y = (mousePos.y - get_window_fraction_f32(.W, 1, 6)) / 8.33 

        x : = int(m.floor(mousePos.x) / 10)
        y : = int(m.floor(mousePos.y) / 10)

        if piece, succeeded : = get_piece_at_coordinate(whites, x, y); succeeded do return piece, succeeded
        else if piece, succeeded : = get_piece_at_coordinate(blacks, x, y); succeeded do return piece, succeeded
    }
    return nil, false
}

draw_possible_moves :: proc(piece:^Piece, board:[64]^Tile) {
    using raylib
    
    switch piece.type {
        case .PAWN: get_tile_at_coordinate(board, piece.xPosition, piece.yPosition)

        case .ROOK:

        case .KNIGHT:

        case .BISHOP:

        case .KING:

        case .QUEEN:
    }
}

get_square :: proc() -> raylib.Rectangle {
    using raylib


    return {0, 0, 0, 0}
}

draw_prawn_moves :: proc(x:int, y:int, tile:^Tile, isFirstMove:bool=false) {
    using raylib


}

draw_board :: proc() {
    using raylib

    cardinality : = get_smallest_dimension()
    tileWidth : = get_window_fraction_i32(cardinality, 1, 12)

    startCoordinateX : = get_window_fraction_i32(.W, 1, 2) - (tileWidth * 4)
    startCoordinateY : = get_window_fraction_i32(.H, 1, 2) - (tileWidth * 4)

    for x in 0..7 {
        for y in 0..7 {
            DrawRectangle(startCoordinateX + (i32(y) * tileWidth), startCoordinateY + (i32(x) * tileWidth), tileWidth, tileWidth, x%2 == y%2 ? WHITE : BLACK)
            DrawRectangleLinesEx({f32(startCoordinateX), f32(startCoordinateY), f32(tileWidth*8), f32(tileWidth*8)}, 5, BLACK)

            this : cstring
            if y == 0 {
                this = str.clone_to_cstring(get_letter_coordinate(x))
                DrawText(this, startCoordinateX + (tileWidth/2) + (i32(x)*tileWidth), startCoordinateY - (tileWidth/2), 20, BLACK)
                delete(this)
            }
            if x == 0 {
                this = str.clone_to_cstring(get_number_coordinate(y))
                DrawText(this, startCoordinateX - (tileWidth/2), startCoordinateY + (tileWidth/2) + (i32(y)*tileWidth), 20, BLACK)
                delete(this)
            }
        }
    }
}

get_smallest_dimension :: proc() -> Cardinality {
    return raylib.GetScreenWidth() > raylib.GetScreenHeight() ? .H : .W
}

main :: proc() {
    using raylib

    InitWindow(WINDOW_W, WINDOW_H, WINDOW_TITLE)
    defer CloseWindow()

    fags : ConfigFlags = {.WINDOW_RESIZABLE}
    SetWindowState(fags)
    SetTargetFPS(60)

    whitePieces, blackPieces : = init_pieces()

    board : = init_chess_board(get_window_fraction_i32(.H, 1, 12), Vector2{get_window_fraction_f32(.H, 1, 6), get_window_fraction_f32(.H, 1, 6)})

    selectedPiece : ^Piece = nil


    for ! WindowShouldClose() {
        BeginDrawing()
        ClearBackground(WHITE)
        DrawFPS(5, 5)

        if IsWindowResized() do update_tile_and_piece_window_coordinates(board, whitePieces, blackPieces)

        draw_board()

        draw_pieces(board, whitePieces)
        draw_pieces(board, blackPieces)

        if IsMouseButtonPressed(MouseButton.LEFT) && has_clicked_board() {
            if sp, succeeded : = get_piece_left_clicked(whitePieces, blackPieces); succeeded {
                selectedPiece = sp
                selectedPiece.isSelected = true
            } else {
                selectedPiece = nil
            }
        }

        if selectedPiece != nil && selectedPiece.isSelected {
            draw_possible_moves(selectedPiece, board)
        }

        if selectedPiece != nil && IsMouseButtonPressed(MouseButton.RIGHT) do selectedPiece.isSelected = false

        EndDrawing()
        free_all(context.temp_allocator)
    }
}
