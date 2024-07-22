# PortZap

PortZap is a cross-platform Dart CLI tool designed to kill processes running on specified ports. It works on Windows, macOS, and Linux, making it a versatile utility for developers who need to free up ports during development.

## Features

- Kill processes on specified ports
- Cross-platform support (Windows, macOS, Linux)
- Simple command-line interface
- Informative error messages

## Prerequisites

To use PortZap, you need to have Dart SDK installed on your system. If you haven't installed Dart yet, follow the official [Dart SDK installation guide](https://dart.dev/get-dart).

## Installation

1. Clone this repository or download the source code:

   ```
   git clone https://github.com/yourusername/PortZap.git
   cd PortZap
   ```

2. Install dependencies:

   ```
   dart pub get
   ```

## Usage

Run the script using the Dart CLI:

```
dart run bin/PortZap.dart -p <port_number>
```

Replace `<port_number>` with the port number you want to free up.

### Options

- `-p, --port`: Specify the port number to kill (required)
- `-h, --help`: Show usage information

### Examples

Kill process on port 8080:

```
dart run bin/PortZap.dart -p 8080
```

Show help information:

```
dart run bin/PortZap.dart -h
```

## Building an Executable

To create a standalone executable that can be run without the Dart VM:

1. Ensure you have the Dart SDK installed and `dart` is in your PATH.

2. Run the following command in the project directory:

   ```
   dart compile exe bin/PortZap.dart -o PortZap
   ```

3. This will create an executable named `PortZap` (or `PortZap.exe` on Windows) in your current directory.

4. You can now run the executable directly:

   ```
   ./PortZap -p 8080
   ```

## Troubleshooting

If you encounter any issues:

1. Ensure you have the necessary permissions to kill processes.
2. On Unix-based systems (macOS and Linux), you might need to run the tool with `sudo` for certain system processes.
3. Check that the port number you're trying to kill actually has a process running on it.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

Use this tool responsibly. Killing processes can potentially lead to data loss or system instability if used incorrectly. Always ensure you know what process you're terminating.