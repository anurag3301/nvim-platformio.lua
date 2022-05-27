command Pioinit lua require('platformio.pioinit').pioinit()
command -nargs=* Piorun lua require('platformio.piorun').piorun(<f-args>)
command -nargs=* Piocmd lua require('platformio.pioterm').piocmd({<f-args>})
