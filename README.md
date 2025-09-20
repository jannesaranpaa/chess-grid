# Chess-grid

_Chess-grid is a simple tool/game for memorizing the chess grid._

Imagine that you are studying a grandmaster chess game printed in a book. You
have a board in front of you, pieces laid out and you religiously re-enact every
move. Then the book shows you a picture of the game at a defining moment, and it
doesn't match the position you have on the board at all!

If that has ever been you, you might have thought you should practice reading
algebraic notation. I can't help you with that, but I can help you memorize the
coordinates. It's probably easier than improving your ELO...

Chess grid gives you a coordinate, and you have to click that square. If you
click wrong, counter goes to zero and you have to start from the beginning.

You can choose whether you want to see the coordinates printed on every square,
only the legends at the side, or practice completely blind if you really want to
master the board.

## Technical information

Chess-grid is a Single-Page-Application written in [Elm](https://elm-lang.org/).
It doesn't have cookies, backend servers or databases. Not even fancy
navigation. It's just JavaScript compiled from the Elm source. I use
[Google Material Icons](https://fonts.google.com/icons?selected=Material+Symbols+Outlined:close:FILL@0;wght@400;GRAD@0;opsz@24&icon.size=24&icon.color=%23e3e3e3)
and that's pretty much the only outside dependency.

## Possible future features

- Other game modes
  - Current _click until you miss or get bored_
  - Time-trial: how many squares can you get in a minute / some other time
  - Reverse: write out the coordinate of a highlighted square
  - Actual chess notation: you are given a move in algebraic notation, you have
    to play it on the board
  - Reverse notation: you are shown a move on the board, you have to write it in
    notation.
- Ability to reverse the grid to the POV of the black side
- Add a shareable results screen at the end of a game
- Add a leaderboard (and users)

Not promising anything, but I might need to procrastinate on something and maybe
implement some of these. You are very much free to contribute by opening issues
or creating pull-requests.

## How to develop

The source code comes with `package.json` so you can just clone the repo and run
`npm install && npm run build`. Node is required so make sure you have it
installed. That should get you an html file at `public/index.html` which you can
open in a browser.

For a slightly nicer development experience you can also run `npm run watch` and
`npm run serve`. That will give you a web server and live recompilation of the
code. Hot reloading is not supported so remember to refresh the page after
you've made some changes.
