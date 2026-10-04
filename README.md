# FPGA Memory Game

A digital **memory-sequence game implemented in VHDL for FPGA**. The game generates a random-looking sequence using a 4-bit Linear Feedback Shift Register (LFSR), displays the sequence using four LEDs, and challenges the player to reproduce it using four push buttons.

The sequence becomes longer after every successful round, with a maximum difficulty of **10 steps**.

## Features

* 4-button memory game
* 4 LED sequence display
* LFSR-based sequence generation
* Progressive difficulty
* Correct/wrong result indication
* Button-lock mechanism to prevent repeated detection
* Win condition after completing 10 steps
* Automatic restart after a wrong answer or completed game
* FSM-based control
* FPGA implementation using VHDL

## How It Works

The game follows this sequence:

```text
IDLE
  ↓
Generate Sequence
  ↓
Show Sequence
  ↓
Hide Sequence
  ↓
Player Repeats Sequence
  ↓
Correct / Wrong
  ↓
Next Round / Restart
```

At the beginning of each round, the controller generates the next sequence element using the LFSR.

The corresponding LED is then turned on so the player can memorize the sequence.

After the complete sequence has been displayed, all LEDs turn off and the player must reproduce the sequence using the four buttons.

## Game Progression

The game starts with a sequence of **one LED**.

Each successful round increases the sequence length:

```text
Round 1 → 1 step
Round 2 → 2 steps
Round 3 → 3 steps
...
Round 10 → 10 steps
```

If the player presses an incorrect button, the `WRONG` state is activated and the game resets to a sequence length of one.

Successfully completing the 10-step sequence activates the `WIN` state.

## FSM States

| State               | Description                           |
| ------------------- | ------------------------------------- |
| `IDLE`              | Initial waiting state                 |
| `GENERATE_SEQUENCE` | Generates and stores a sequence value |
| `SHOW_SEQUENCE`     | Displays the current LED              |
| `SHOW_PAUSE`        | Creates a gap between sequence steps  |
| `HIDE_SEQUENCE`     | Turns LEDs off before user input      |
| `WAIT_INPUT`        | Waits for the player's button         |
| `CORRECT`           | Indicates a correct sequence          |
| `WRONG`             | Indicates an incorrect input          |
| `WIN`               | Indicates successful completion       |

## LFSR Sequence Generation

A **4-bit Linear Feedback Shift Register (LFSR)** is used to generate the sequence.

The LFSR uses XOR feedback and is initialized to:

```text
0001
```

Two LFSR bits are used to generate one of four possible values:

```text
00 → LED 1
01 → LED 2
10 → LED 3
11 → LED 4
```

This provides a simple hardware-friendly method for generating a pseudo-random sequence.

## Hardware Inputs & Outputs

### Inputs

| Input   | Function         |
| ------- | ---------------- |
| `clk`   | FPGA clock       |
| `reset` | Active-low reset |
| `btn1`  | Player button 1  |
| `btn2`  | Player button 2  |
| `btn3`  | Player button 3  |
| `btn4`  | Player button 4  |

### Outputs

| Output        | Function                        |
| ------------- | ------------------------------- |
| `led1–led4`   | Display the generated sequence  |
| `correct_led` | Indicates a correct response    |
| `wrong_led`   | Indicates an incorrect response |

## Project Structure

```text
memory_game/
├── memory_game.vhd
├── memory_game.qpf
├── memory_game.qsf
├── output_files/
└── db/
```

The main implementation is contained in:

```text
memory_game.vhd
```

The Quartus project and FPGA pin/device configuration are provided through the `.qpf` and `.qsf` files.

## Hardware & Software

* **HDL:** VHDL
* **FPGA:** Cyclone IV E `EP4CE115F29C7`
* **Quartus:** Intel Quartus Prime Lite 18.1
* **Design Type:** Synchronous digital FSM
* **Sequence Generator:** 4-bit LFSR

## Timing

The game uses the FPGA clock and counters to create visible delays for:

* Initial game start
* LED sequence display
* Pause between sequence elements
* Correct indication
* Wrong indication
* Win indication

This allows the game to be implemented entirely in FPGA hardware without requiring a software processor.

## Purpose

This project demonstrates practical FPGA concepts including:

* Finite State Machine design
* LFSR-based pseudo-random generation
* Synchronous counters
* Button input handling
* LED control
* Sequential VHDL programming
* Hardware timing
* Progressive game-state control
