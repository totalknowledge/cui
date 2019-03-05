# Simple Text UI (TUI) for creating console applications that have
# a simple event loop.
import terminal, tables, unicode, threadpool

type runeStyle = tuple
  bgStyle: BackgroundColor
  fgStyle: ForegroundColor
  txtStyles: set[Style]

type Console* = object
  ## A coroutine state.
  width*: int      #Number of Columns
  height*: int     #Number of Rows
  buffer: seq[seq[Rune]]
  executeQueue: Table[char, seq[proc()]]
  styleQueue: seq[seq[runeStyle]]

proc init*(self: var Console) =
  stdout.hideCursor()
  self.width = terminalSize().w
  self.height = terminalSize().h
  self.executeQueue = initTable[char, seq[proc()]]()
  var ith = self.height
  while(ith > 0):
    var itw = self.width
    var row: seq[Rune]
    self.styleQueue.add(@[])
    while(itw > 0):
      self.styleQueue[self.height-ith].add((bgStyle: bgDefault, fgStyle: fgDefault, txtStyles: {}))
      row.add(" ".toRunes)
      itw.dec()
    self.buffer.add(row)
    ith.dec()

proc write*(self: Console) =
  stdout.setCursorPos(0,0)
  for i, line in pairs(self.buffer):
    var temp_seq = self.styleQueue[i]
    for i, wRune in pairs(line):
      stdout.setBackgroundColor(temp_seq[i].bgStyle)
      stdout.setForegroundColor(temp_seq[i].fgStyle)
      stdout.setStyle(temp_seq[i].txtStyles)
      stdout.write(wRune)
    stdout.resetAttributes()

proc place*(self: var Console, str: string, row: int, col: int) =
  var inc = 0
  for r in runes(str):
    self.buffer[row][col+inc] = r
    inc.inc()

proc place*(self: var Console, str: string, row: int, pos: string) =
  var low_col = 0
  var cal_pos = 0
  case pos:
    of "center":
      cal_pos = int(self.width/2)
      low_col = cal_pos - int(str.len/2)
    of "right":
      low_col = self.width - (str.len)
  var inc = 0
  for r in runes(str):
    self.buffer[row][low_col+inc] = r
    inc.inc()

proc setRowStyle*(self: var Console,
                  row: int,
                  bgstyle: BackgroundColor = bgDefault,
                  fgstyle: ForegroundColor = fgDefault,
                  txtstyles: set[Style] = {}) =
  for key, value in pairs(self.styleQueue[row]):
    self.styleQueue[row][key].bgStyle = bgstyle
    self.styleQueue[row][key].fgStyle = fgstyle
    self.styleQueue[row][key].txtStyles = txtstyles

proc run*(self: var Console) =
  self.write()
  var bob: char
  while(int(bob) != 3):
    let boblet = spawn getch()
    bob = ^boblet
    self.place($bob, 5, 5)
    self.write()

## Main create test
when isMainModule:
  enableTrueColors()
  var s: Console
  s.init()
  s.place("Hello \u2503", 0, "center") #"\u5f7c"
  s.place("MIT Boo 0.1.1", 0, 3)
  for i in 1..5:
    s.place("\u258F", i, 0)
  s.setRowStyle(0, bgRed)
  s.run()

  stdout.showCursor()
  stdout.resetAttributes()
