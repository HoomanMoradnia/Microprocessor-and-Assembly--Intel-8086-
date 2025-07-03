# Microprocessor and Assembly (Intel 8086)

Welcome to the **Microprocessor and Assembly (Intel 8086)** repository!  
This project is a collection of resources, code samples, and exercises focused on the Intel 8086 microprocessor and its assembly language programming. It is intended for students, hobbyists, or anyone interested in learning about low-level programming and computer architecture.

---

## Table of Contents

- [About](#about)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Windows](#windows)
  - [Linux](#linux)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## About

This repository includes:
- Sample assembly programs for the Intel 8086.
- Lab exercises and solutions.
- Documentation and learning resources.
- Tools and scripts to assemble, link, and run 8086 programs.

---

## Prerequisites

To work with the code in this repository, you should have:
- **Basic knowledge of programming concepts**
- **Familiarity with command line tools** (for compiling and running code)
- **Assembler and emulator/simulator for 8086** (see below)

### Required Tools

- **Assembler:** MASM, TASM, or NASM  
- **Emulator/Simulator:** DOSBox, emu8086, or DOSBox-X

---

## Installation

### Windows

1. **Install an 8086 Assembler**  
   You can use MASM, TASM, or NASM. For beginners, emu8086 is recommended:
   - Download emu8086.
   - Follow the installation instructions provided.

2. **(Optional) Install DOSBox for Legacy Tools**
   - Download DOSBox.
   - Install DOSBox and configure a virtual drive for your assembly projects.

3. **Clone this repository**
   ```sh
   git clone https://github.com/HoomanMoradnia/Microprocessor-and-Assembly--Intel-8086-.git
   cd Microprocessor-and-Assembly--Intel-8086-
   ```

4. **Open the code samples** in your assembler or emulator, assemble, and run as described in the tool's documentation.

---

### Linux

1. **Install NASM**
   ```sh
   sudo apt update
   sudo apt install nasm
   ```

2. **Install DOSBox (for running DOS-based 8086 programs)**
   ```sh
   sudo apt install dosbox
   ```

3. **Clone this repository**
   ```sh
   git clone https://github.com/HoomanMoradnia/Microprocessor-and-Assembly--Intel-8086-.git
   cd Microprocessor-and-Assembly--Intel-8086-
   ```

4. **Assemble and Run 8086 Programs**
   - For pure NASM `.asm` files:
     ```sh
     nasm -f bin program.asm -o program.com
     dosbox
     ```
   - Mount your project directory in DOSBox and run your assembled `.com` files.

   - For more complex or lab-specific code, refer to included instructions or use emulators like emu8086 (via Wine).

---

## Usage

- Browse the `labs`, `examples`, or root directory for `.asm` files.
- Open the desired file in your assembler/emulator.
- Assemble and run the code to see the output.
- Modify and experiment to deepen your understanding!

---

## Contributing

Contributions, bug reports, and suggestions are welcome!  
Feel free to open issues or submit pull requests.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

**Happy Coding!**
