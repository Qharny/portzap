# PortZap 🚀⚡

PortZap is a command-line utility written in Dart that helps you manage and terminate processes running on specific ports. It's cross-platform, supporting Windows, macOS, and Linux.

## Features

- List all running ports and their associated process IDs
- Kill a process running on a specific port
- Cross-platform support (Windows, macOS, Linux)

## Installation

1. Ensure you have Dart SDK installed on your system.
2. Clone this repository or download the `portzap.dart` file.
3. Run `dart pub get` to install dependencies.

## Usage

```
dart portzap.dart [-p <port_number> | -l] [-h]
```

### Options:

- `-p, --port`: Specify the port number to kill the process on
- `-l, --list`: List all running ports and their associated PIDs
- `-h, --help`: Show usage information

### Examples:

1. List all running ports:
   ```
   dart portzap.dart -l
   ```

2. Kill a process running on port 8080:
   ```
   dart portzap.dart -p 8080
   ```

3. Show help information:
   ```
   dart portzap.dart -h
   ```

## How it works

1. **Parsing arguments**: The script uses the `args` package to parse command-line arguments, allowing users to specify options like port number, listing ports, or showing help.

2. **Listing ports**:
   - On Windows: Uses `netstat -ano` to list all TCP/IP network connections and their associated processes.
   - On macOS/Linux: Uses `lsof -i -P -n` to list open files and network connections.

   The output is then parsed to extract port numbers and process IDs.

3. **Killing a process on a specific port**:
   - First, it identifies the process ID (PID) associated with the given port:
     - On Windows: Uses `netstat -ano | findstr :<port>`
     - On macOS/Linux: Uses `lsof -i :<port> -t`
   - Then, it terminates the process using the appropriate command:
     - On Windows: `taskkill /F /PID <pid>`
     - On macOS/Linux: `kill -9 <pid>`

4. **Error handling**: The script includes error handling to manage issues like invalid input, unsupported platforms, or failed operations.

## Notes

- This tool requires appropriate permissions to list and terminate processes. On some systems, you may need to run it with elevated privileges (e.g., using `sudo` on macOS/Linux).
- Always use caution when terminating processes, especially on production systems.

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](link_to_issues) if you want to contribute.

## License

[MIT License](link_to_license)

