<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# latcell

latcell is an offline command-line tool for people who work with geographic grid codes. It encodes latitude/longitude coordinates, decodes codes into their exact cells, converts between systems, lists geohash neighbours, covers a bounding box with geohashes, and summarizes GPS points as consecutive cell runs.

It supports geohash, Maidenhead locators, Open Location Code (OLC), and GEOREF. The application is written in Dart and has no runtime dependencies or network access. Its coordinate arithmetic uses exact rational values backed by arbitrary-precision integers; it does not use floating-point coordinates.

[![CI](https://github.com/Gulliby-development/latcell/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/latcell/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Install and run

Install the Dart SDK 3.13 or newer for Windows, macOS, or Linux (the project is checked with Dart 3.13.7; `pubspec.yaml` allows `^3.8.0`, but the committed `pubspec.lock` pins package versions that need 3.13), then get the project and resolve its development tools:

```sh
git clone https://github.com/Gulliby-development/latcell.git
cd latcell
dart pub get
```

Run the CLI from the project root with:

    dart run bin/latcell.dart --help
    dart run bin/latcell.dart encode geohash 37.7749 -122.4194

The examples below use `latcell` as shorthand. To try them in a POSIX shell (on Windows use Git Bash), run this in the project directory; it defines the shorthand, moves to a scratch directory and creates the `walk.csv` file of the trail examples:

```sh
LATCELL_HOME="$PWD"
latcell() { dart "$LATCELL_HOME/bin/latcell.dart" "$@"; }
cd "$(mktemp -d)"
printf '# morning walk\n37.7749,-122.4194\n37.77491,-122.41941\n\n37.7790, -122.4140\n37.7790,-122.4141\n37.7749,-122.4194\n' > walk.csv
```

## Help and commands

<code>--help</code> or <code>help</code> prints the usage text. <code>--version</code> prints <code>latcell 0.1.0</code>. The command forms are:

    usage: latcell COMMAND [ARGS]
    commands:
      encode SYSTEM LAT LON [--length N]
      decode CODE [--system SYSTEM]
      convert CODE --to SYSTEM [--length N] [--system SYSTEM]
      near CODE [--only DIRS]
      cover --box S,W,N,E --length N [--limit M]
      trail FILE [--system SYSTEM] [--length N]
    systems: geohash, maidenhead, olc, georef

Options can be written as <code>--name value</code> or <code>--name=value</code>. Use <code>--</code> to end option parsing. An unknown or repeated option, a missing option value, a missing required option, or a wrong number of positional arguments is a usage/input error.

| Command | Purpose and options |
| --- | --- |
| <code>encode SYSTEM LAT LON [--length N]</code> | Encode coordinates in the named system. Length defaults to that system's default. |
| <code>decode CODE [--system SYSTEM]</code> | Detect or explicitly select the code system, then print the canonical code, cell bounds, and center. |
| <code>convert CODE --to SYSTEM [--length N] [--system SYSTEM]</code> | Decode the source code and encode the center of its cell in the target system. <code>--to</code> is required; target length defaults to the target system's default. |
| <code>near CODE [--only DIRS]</code> | Print the eight neighbouring cells for a geohash, or only the ones named by <code>--only</code>. |
| <code>cover --box S,W,N,E --length N [--limit M]</code> | Print all geohash cells containing the box's south-west and north-east corners and the cells between them. <code>--box</code> and <code>--length</code> are required; the limit defaults to 100. |
| <code>trail FILE [--system SYSTEM] [--length N]</code> | Read coordinate pairs from a UTF-8 trail file, or from standard input when FILE is <code>-</code>. The system defaults to geohash and length defaults to the selected system's default. |

A whole-number option must contain one to six ASCII digits. The box is written as <code>S,W,N,E</code>; its four values allow spaces and tabs around them. A south coordinate above north is invalid. West greater than east denotes a box crossing the antimeridian.

The <code>--only</code> value of <code>near</code> is a comma-separated list of the directions <code>N</code>, <code>NE</code>, <code>E</code>, <code>SE</code>, <code>S</code>, <code>SW</code>, <code>W</code> and <code>NW</code>, written in upper case without spaces. The chosen neighbours are printed in the usual order whatever the order of the list, and a pole shows <code>-</code> as before. An empty list, an unknown name or a name given twice is a usage error (exit status 2).

## Systems, precision, and detection

The encode length truncates to the grid cell that contains the coordinate; it does not round to a neighboring code. Decoding accepts ASCII letters in either case and returns each system's canonical spelling.

| System | Accepted lengths | Default | Canonical spelling |
| --- | --- | --- | --- |
| geohash | 1 through 12 characters | 9 | lowercase |
| maidenhead | 2, 4, 6, 8, or 10 characters | 6 | uppercase field/square; lowercase subsquares |
| olc | 2, 4, 6, 8, 10, and 11 through 15 digits | 10 | uppercase |
| georef | 2, 4, 8, 10, or 12 characters | 8 | uppercase |

For OLC, the listed length is the number of meaningful code digits. It does not count the separator <code>+</code> or zero padding inserted before the separator. Thus length 2 encodes as an eight-character padded prefix followed by <code>+</code>.

When no <code>--system</code> is supplied, detection is based on the spelling and checks for an OLC separator first, then a Maidenhead shape, then a GEOREF shape, then a lowercase geohash shape. This is intentionally case-sensitive even though each decoder accepts ASCII case-insensitively. For example, <code>CM87wk</code> is detected as Maidenhead, while <code>cm87wk</code> is detected as geohash; use <code>--system maidenhead</code> to decode the latter as Maidenhead. <code>MK</code> is detected as Maidenhead and <code>MKPG</code> as GEOREF. Uppercase geohash letters may not match the geohash detection shape and may resemble another system, so use <code>--system geohash</code> when detection is uncertain. An explicit system selects the decoder without relying on detection.

### Exact coordinates and cell edges

Latitude and longitude input must be a complete decimal number: an optional sign, at least one digit, and optionally a decimal point followed by at least one digit. Exponents, whitespace, a leading or trailing decimal point, and other characters are rejected. At most 12 digits may follow the decimal point. Latitude is inclusive from -90 through 90; longitude is inclusive from -180 through 180.

All computations retain exact rational coordinates. Code generation truncates at the requested grid precision. Displayed cell edges and centers are rendered to seven decimal places, rounding half away from zero; values that round to zero are displayed without a negative sign. A point on a shared grid edge belongs to the cell above or to the right. At the upper pole and rightmost coordinate boundary, indices are clamped into the final cell.

OLC wraps longitude 180 to -180 before encoding, so those two longitude boundaries produce the same wrapped position. Geohash neighbours wrap columns across the antimeridian. Neighbour directions are reported in this order: N, NE, E, SE, S, SW, W, NW. A neighbour that would pass a pole is shown as <code>-</code>.

### Box coverage

Coverage includes the grid cells holding both box corners and all intervening grid indices. Results are ordered north row to south row, and west to east within a row; a crossing box proceeds from its west column to the last column, then wraps to column zero and continues to the east column. When the west and east edges fall in the same column, the box is the whole ring of columns and that column is listed once. The complete cell count is checked against <code>--limit</code> before any result list is materialized. If the count exceeds the limit, the command reports the required count and limit instead of printing a partial list.

### Trail files and statuses

Trail input is strict UTF-8. A single leading UTF-8 byte-order mark is removed. Lines may use LF or CRLF endings; spaces and tabs are trimmed, and empty lines and lines beginning with <code>#</code> are skipped. Other lines must contain exactly two comma-separated decimal values, <code>LAT,LON</code>. Diagnostics use physical, one-based line numbers, including skipped lines. Only consecutive points with the same encoded cell are combined into a run; a later return to a previous cell starts a new run.

Use <code>-</code> as FILE to read standard input. An unreadable file reports <code>cannot read NAME</code>; malformed UTF-8 reports <code>NAME: input is not valid UTF-8</code>, with <code>&lt;stdin&gt;</code> as the standard-input label. The invalid-UTF-8 transcript below assumes the stdin stream contains invalid bytes (for example, the byte sequence <code>31 2C 32 0A FF 0A</code>), rather than an ordinary text line.

Successful output goes to standard output. Errors are written to standard error with the <code>latcell:</code> prefix. Exit statuses are 0 for success, 1 for an invalid value/code/length/box/trail line, and 2 for usage or input errors such as an unknown system, unreadable input, or invalid UTF-8.

## Worked CLI transcript

The transcript below is the output of these commands, run after the setup block above. `stderr:` and `exit:` label standard-error output and a non-zero process status; the standard-input example sends the bytes `31 2C 32 0A FF 0A`, which are not valid UTF-8.

```text
$ latcell encode geohash 37.7749 -122.4194
9q8yyk8yt
$ latcell encode olc 37.4220 -122.0841 --length 11
849VCWC8+R92
$ latcell decode 9q8yyk8
system: geohash
code: 9q8yyk8
lat: 37.7737427 .. 37.7751160
lon: -122.4206543 .. -122.4192810
center: 37.7744293, -122.4199677
$ latcell decode 849VCWC8+R9
system: olc
code: 849VCWC8+R9
lat: 37.4220000 .. 37.4221250
lon: -122.0841250 .. -122.0840000
center: 37.4220625, -122.0840625
$ latcell decode cm87wk --system maidenhead
system: maidenhead
code: CM87wk
lat: 37.4166667 .. 37.4583333
lon: -122.1666667 .. -122.0833333
center: 37.4375000, -122.1250000
$ latcell convert 9q8yyk8 --to olc
849VQHFJ+Q2
$ latcell convert 849VCWC8+R9 --to georef --length 4
DJNH
$ latcell near bpbp
N -
NE -
E bpbr
SE bpbq
S bpbn
SW zzzy
W zzzz
NW -
$ latcell near bpbp --only W,E
E bpbr
W zzzz
$ latcell cover --box 37.77,-122.43,37.78,-122.41 --length 6
9q8yyj
9q8yym
9q8yyh
9q8yyk
9q8yy5
9q8yy7
$ latcell cover --box 37,-123,38,-122 --length 5
stderr: latcell: box needs 552 cells at length 5; the limit is 100
exit: 1
$ latcell trail walk.csv
9q8yyk8yt 1 2 2
9q8yyk8yu 1 3 3
9q8yymkye 1 5 5
9q8yymky8 1 6 6
9q8yyk8yt 1 7 7
runs: 5 points: 5
$ latcell trail walk.csv --length 6
9q8yyk 2 2 3
9q8yym 2 5 6
9q8yyk 1 7 7
runs: 3 points: 5
$ printf '1,2\n\377\n' | latcell trail -
stderr: latcell: <stdin>: input is not valid UTF-8
exit: 2
$ latcell encode geohash 91 0
stderr: latcell: latitude 91 is outside -90..90
exit: 1
$ latcell encode geohash 0 0 --length 13
stderr: latcell: length 13 is not valid for geohash (1..12)
exit: 1
$ latcell decode AB1
stderr: latcell: cannot tell the system of AB1; use --system
exit: 1
$ latcell encode nope 1 2
stderr: latcell: unknown system nope
exit: 2
```

## Development

From the project root, run the three checks:

    dart format --output=none --set-exit-if-changed .

If formatting needs to be applied, use:

    dart format .

Then run analysis and tests:

    dart analyze --fatal-infos
    dart test

These commands are the same on Windows, macOS, and Linux when the Dart SDK is installed. Use a terminal in the project root. The CLI and its source use platform-independent Dart paths and standard input/output; no network access is needed at runtime.

## License

latcell is distributed under the MIT License. See [LICENSE](LICENSE).

---

Built with BAKED
