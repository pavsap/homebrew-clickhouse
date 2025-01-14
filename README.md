# ClickHouse Homebrew Tap

Run [ClickHouse](https://formulae.brew.sh/cask/clickhouse) database as a
service on macOS with standard [Homebrew](https://brew.sh) commands:

## Installation

1. Install clickhouse:
```bash
brew install --cask clickhouse
```

2. Install clickhouse service wrapper:
```bash
# Add this tap
brew tap pavsap/clickhouse

# Install server wrapper
brew install clickhouse-server
```

## Usage

### Service Management

```bash
# Basic service control
brew services start|stop|restart clickhouse-server

# Check service status
brew services info clickhouse-server

# Manual start (without service)
clickhouse server --config-file=/opt/homebrew/etc/clickhouse-server/config.xml

### Test Installation

```bash
# Test local queries
clickhouse client -q 'SELECT 1'
clickhouse client -q 'SELECT version()'

# Test connectivity
curl 'http://localhost:8123/ping'
curl 'http://localhost:8123/?query=SELECT%201'
```

### Configuration

Default configuration files are located at:
- `/opt/homebrew/etc/clickhouse-server/config.xml`
- `/opt/homebrew/etc/clickhouse-server/users.xml`

Data directory:
- `/opt/homebrew/var/lib/clickhouse`

Log files:
- `/opt/homebrew/var/log/clickhouse-server/clickhouse-server.log`
- `/opt/homebrew/var/log/clickhouse-server/clickhouse-server.err.log`

## Security

Default configuration:
- Empty password for default user
- Access restricted to localhost (127.0.0.1 and ::1)
- Default ports:
  - HTTP: 8123
  - Native: 9000
  - Interserver: 9009

⚠️  Consider changing default passwords in production environments.

## Upgrading

Configuration files are not overwritten on upgrade. To use new configurations:
1. Backup existing files
2. Remove them
3. Reinstall the formula

## Troubleshooting

### Common Issues

1. Binary not found:
```bash
brew reinstall --cask clickhouse
brew reinstall clickhouse-server
```

2. Permission issues:
```bash
sudo chown -R $(whoami) /opt/homebrew/var/lib/clickhouse
sudo chown -R $(whoami) /opt/homebrew/var/log/clickhouse-server
```

3. Port conflicts:
Edit ports in config.xml and restart the service.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.

## Acknowledgments

- [Homebrew](https://brew.sh/)
- [ClickHouse](https://clickhouse.com/)
