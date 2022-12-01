# TikTokToe

Playing tik tac toe using comments in TikTok live stream.

Phoenix webserver renders image of the game board. Game master casts their browser with the board in tiktok live steam.
Selenium engine parses comments of tiktok live stream. It converts comments in http calls to the webserver.

Game board updates as commands are parsed processed by the webserver.

Two player join the game by writing "join" in the comments.
They play by posting commands in comments.
Once the game has the winner, board reset automatically after a delay.
m
## API specification:

  * GET /tiktok - render the board
  * POST /comment - parse the comment command

## Comment body:
    ```json
    {"nickname" => "Roman", "command" => "join"}
    {"nickname" => "Roman", "command" => "move top-left"}
    ```

## Commands:

 * join
 * move bottom-[left, center, right]
 * move middle-[left, center, right]
 * move top-[left, center, right]

Project is made using Phoenix LiveView.

# To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
