import Darwin
import TSCBasic
import TSCUtility

let animation = PercentProgressAnimation(
  stream: stdoutStream,
  header: "Loading Awesome Stuff ✨")

for i in 0..<100 {
  let second: Double = 1_000_000
  usleep(UInt32(second * 0.05))
  animation.update(step: i, total: 100, text: "Loading..")
}

animation.complete(success: true)
print("Done! 🚀")

let terminalController = TerminalController(stream: stdoutStream)

let colors: [TerminalController.Color] = [
  .noColor, .red, .green, .yellow, .cyan, .white, .black, .grey
]

for color in colors {
  terminalController?.write("Hello World", inColor: color, bold: true)
  terminalController?.endLine()
}
