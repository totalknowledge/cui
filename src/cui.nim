# Simple Text UI (TUI) for creating console applications that have
# a simple event loop.
import terminal

type Console* = ref object
  ## A coroutine state.
  width: int      ## Coroutine stack.
  height: int     ## Coroutine context.
  buffer: seq[string]
  execQueue: seq[tuple[event:char, action: proc]]

proc init*(self: Console, mainloop: proc()) =
  ## Setup console, and pass application proc to it.
  self.width = terminalWidth()
  self.height = terminalHeight()

  var mlp = true
  while (mlp):
    let event = getch()
    if event == char(3):
      mlp = false
      break
    mainloop()

    echo $event & ": " & $event

proc delete*(self: ptr Console) =
  ## Delete coroutine that is no longer in use. Avoid deleting coroutines that did not exit
  ## completely as it may lead to memory leaks.
  #stack_destroy(self.stack)
  discard

## Test when main
proc mainloop = discard
var C: Console
C.init(mainloop)
