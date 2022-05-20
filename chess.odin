package chess

import "core:fmt"
import str "core:strings"
import "vendor:raylib"
import m "core:math"


WINDOW_H :: 1000
WINDOW_W :: 1000
WINDOW_TITLE :: "MOST AMAzinGINEST CHESS 🗿"
source : = "ABCDEFGH"


PieceType :: enum{PAWN, ROOK, BISHOP, KNIGHT, KING, QUEEN}


Piece :: struct {
    xPosition : int,
    yPosition : int,
    type : PieceType,
    piecesDefeatedCount : int,
    colour : raylib.Color,
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

draw_tiles :: proc(tiles: [64]^Tile) {
    using raylib

    for x in tiles {
        DrawRectangle(x.xStartCoord, x.yStartCoord, x.sideLength, x.sideLength, x.colour)
    }
}

draw_coordinates :: proc(tiles: [64]^Tile) {
    using raylib

    for x in tiles {
        this : cstring
        if x.xPos == "A" {
            this = str.clone_to_cstring(x.yPos)
            DrawText(this, x.xStartCoord - x.sideLength/2, x.yStartCoord + x.sideLength/2, 20, BLACK)
            delete(this)
        }
        if x.yPos == "1" {
            this = str.clone_to_cstring(x.xPos)
            DrawText(this, x.xStartCoord + x.sideLength/2, x.yStartCoord - x.sideLength/2, 20, BLACK)
            delete(this)
        }
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

has_clicked_board :: proc() -> bool {
    using raylib

    return CheckCollisionPointRec(GetMousePosition(), Rectangle{cast(f32)GetScreenHeight()/6, cast(f32)GetScreenHeight()/6, cast(f32)GetScreenHeight()*2/3, cast(f32)GetScreenHeight()*2/3})
}

get_piece_left_clicked :: proc(pieces:[16]^Piece) -> (^Piece, bool) {
    using raylib

    if has_clicked_board() {
        mousePos : Vector2 = GetMousePosition()
        mousePos.x = (mousePos.x - f32(GetScreenHeight()/6) / 800)
        mousePos.y = (mousePos.y - f32(GetScreenHeight()/6) / 800)

        x : = int(m.floor(mousePos.x))
        y : = int(m.floor(mousePos.y))

        fmt.println(x)
        fmt.println(y)

        if piece, succeeded := get_piece_at_coordinate(pieces, x, y); succeeded do return piece, succeeded
    }
    return nil, false
}

main :: proc() {
    using raylib

    InitWindow(WINDOW_W, WINDOW_H, WINDOW_TITLE)
    defer CloseWindow()

    originalScreenHOver12 : = GetScreenHeight()/12
    originalScreenHOver6 : = GetScreenHeight()/6

    fags : ConfigFlags = {.WINDOW_RESIZABLE}
    SetWindowState(fags)
    SetTargetFPS(60)

    whitePieces, blackPieces : = init_pieces()

    board : = init_chess_board(originalScreenHOver12, Vector2{cast(f32)originalScreenHOver6, cast(f32)originalScreenHOver6})



    for ! WindowShouldClose() {
        BeginDrawing()
        ClearBackground(WHITE)
        DrawFPS(5, 5)

        draw_tiles(board)
        DrawRectangleLinesEx({cast(f32)originalScreenHOver6, cast(f32)originalScreenHOver6, cast(f32)originalScreenHOver12*8, cast(f32)originalScreenHOver12*8}, 5, BLACK)

        draw_coordinates(board)

        draw_pieces(board, whitePieces)
        draw_pieces(board, blackPieces)

        if IsMouseButtonPressed(MouseButton.LEFT) {
            if has_clicked_board() {
                if piece, succeeded : = get_piece_left_clicked(whitePieces); succeeded {
                    fmt.println(piece.type)
                }
                else if piece, succeeded : = get_piece_left_clicked(blackPieces); succeeded {
                    fmt.println(piece.type)
                }
            }
        }

        EndDrawing()
        free_all(context.temp_allocator)
    }
}
