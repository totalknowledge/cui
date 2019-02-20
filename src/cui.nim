# Simple Text UI (TUI) for creating console applications that have
# a simple event loop.
import terminal, tables

type Console* = object
  ## A coroutine state.
  width*: int      #Number of Columns
  height*: int     #Number of Rows
  buffer: seq[string]
  executeQueue: Table[char, seq[proc()]]
  styleQueue: seq[seq[BackgroundColor]]

proc init*(self: var Console) =
  stdout.hideCursor()
  self.width = terminalSize().w
  self.height = terminalSize().h
  self.executeQueue = initTable[char, seq[proc()]]()
  var ith = self.height
  while(ith > 0):
    var itw = self.width
    var row = ""
    self.styleQueue.add(@[])
    while(itw > 0):
      self.styleQueue[self.height-ith].add(bgDefault)
      row = $row & " "
      itw.dec()
    self.buffer.add(row)
    ith.dec()

proc write*(self: Console) =
  stdout.setCursorPos(0,0)
  for i, line in pairs(self.buffer):
    var temp_seq = self.styleQueue[i]
    for i, wchar in line:
      stdout.setBackgroundColor(temp_seq[i])
      stdout.write(wchar)

proc place*(self: var Console, str: string, row: int, col: int) =
  self.buffer[row][col..col+(str.len-1)] = str

proc place*(self: var Console, str: string, row: int, pos: string) =
  var low_col = 0
  var high_col = 0
  var cal_pos = 0
  case pos:
    of "center":
      cal_pos = int(self.width/2)
      low_col = cal_pos - int(str.len/2)
      high_col = low_col + (str.len-1)
    of "right":
      low_col = self.width - (str.len)
      high_col = self.width - 1
    else:
      high_col = str.len - 1
  self.buffer[row][low_col..high_col] = str

proc setRowStyle*(self: var Console, row: int, style: BackgroundColor) =
  for key, value in pairs(self.styleQueue[row]):
    self.styleQueue[row][key] = style

proc run*(self: var Console) =
  self.write()
  var bob: char
  while(int(bob) != 3):
    bob = getch()
    self.write()

## Main create test
enableTrueColors()
var s: Console
s.init()
s.place("Hello World", 0, "center")
s.setRowStyle(0, bgRed)
s.run()

stdout.showCursor()
stdout.resetAttributes()

#echo isTrueColorSupported()
