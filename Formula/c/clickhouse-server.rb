class ClickhouseServer < Formula
  desc "Service wrapper for ClickHouse column-oriented database"
  homepage "https://clickhouse.com/"
  url "https://github.com/ClickHouse/ClickHouse/releases/download/v25.1.1.4165-stable/clickhouse-macos-aarch64"
  version "25.1.1.4165-stable"
  sha256 "217390ffa7103d1617a6e16d96f99d0e7cda83bb7e0cb0b6481c5ae0d78ae49c"
  license "Apache-2.0"

  def install
    # Verify if clickhouse binary from cask exists
    clickhouse_bin = HOMEBREW_PREFIX/"bin/clickhouse"

    unless File.exist?(clickhouse_bin)
      odie <<~EOS
        ClickHouse binary not found!
        Please ensure clickhouse cask is installed properly.
        Install using:
          brew install --cask clickhouse

        Expected binary location:
          #{clickhouse_bin}
      EOS
    end

    # Create a dummy file to satisfy the installation requirement
    (buildpath/"README.md").write <<~EOS
      ClickHouse Server Service Wrapper
      ===============================
      This is a service wrapper for ClickHouse server installation.
    EOS
    pkgshare.install "README.md"

    # Create standard clickhouse directories
    (etc/"clickhouse-server").mkpath
    (var/"lib/clickhouse").mkpath
    (var/"run/clickhouse-server").mkpath
    (var/"log/clickhouse-server").mkpath

    # Create config files
    config_dir = buildpath/"config"
    config_dir.mkpath

    (config_dir/"config.xml").write(config_xml_content)
    (config_dir/"users.xml").write(users_xml_content)

    # Install configs if not exist
    unless File.exist?(etc/"clickhouse-server/config.xml")
      config_dir.children.each { |f| (etc/"clickhouse-server"/f.basename).write(f.read) }
    end
  end

  def config_xml_content
    <<~EOS
      <?xml version="1.0"?>
      <clickhouse>
          <logger>
              <level>trace</level>
              <log>#{var}/log/clickhouse-server/clickhouse-server.log</log>
              <errorlog>#{var}/log/clickhouse-server/clickhouse-server.err.log</errorlog>
          </logger>

          <http_port>8123</http_port>
          <tcp_port>9000</tcp_port>
          <interserver_http_port>9009</interserver_http_port>

          <path>#{var}/lib/clickhouse/</path>
          <tmp_path>#{var}/lib/clickhouse/tmp/</tmp_path>
          <user_files_path>#{var}/lib/clickhouse/user_files/</user_files_path>
          <format_schema_path>#{var}/lib/clickhouse/format_schemas/</format_schema_path>

          <user_directories>
              <users_xml>
                  <path>#{etc}/clickhouse-server/users.xml</path>
              </users_xml>
          </user_directories>

          <mark_cache_size>5368709120</mark_cache_size>
          <max_concurrent_queries>100</max_concurrent_queries>
      </clickhouse>
    EOS
  end

  def users_xml_content
    <<~EOS
      <?xml version="1.0"?>
      <clickhouse>
          <users>
              <default>
                  <password></password>
                  <networks>
                      <ip>::1</ip>
                      <ip>127.0.0.1</ip>
                  </networks>
                  <profile>default</profile>
                  <quota>default</quota>
              </default>
          </users>

          <profiles>
              <default>
                  <max_memory_usage>10000000000</max_memory_usage>
                  <use_uncompressed_cache>0</use_uncompressed_cache>
                  <load_balancing>random</load_balancing>
                  <max_partitions_per_insert_block>100</max_partitions_per_insert_block>
              </default>
          </profiles>

          <quotas>
              <default>
                  <interval>
                      <duration>3600</duration>
                      <queries>0</queries>
                      <errors>0</errors>
                      <result_rows>0</result_rows>
                      <read_rows>0</read_rows>
                      <execution_time>0</execution_time>
                  </interval>
              </default>
          </quotas>
      </clickhouse>
    EOS
  end

  def post_install
    # Create data directory if it doesn't exist
    (var/"lib/clickhouse/data").mkpath
    (var/"lib/clickhouse/tmp").mkpath
    (var/"lib/clickhouse/user_files").mkpath
    (var/"lib/clickhouse/format_schemas").mkpath

    # Set proper permissions
    chmod 0750, var/"lib/clickhouse"
    chmod 0750, var/"log/clickhouse-server"
    chmod 0750, var/"run/clickhouse-server"
  end

  def caveats
    <<~EOS
      Configuration files are not overwritten on upgrade.
      To use new configuration files, backup and remove the existing ones:
        #{etc}/clickhouse-server/config.xml
        #{etc}/clickhouse-server/users.xml
    EOS
  end

  service do
    run [HOMEBREW_PREFIX/"bin/clickhouse", "server", "--config-file=#{etc}/clickhouse-server/config.xml"]
    keep_alive true
    working_dir var/"lib/clickhouse"
    log_path var/"log/clickhouse-server/clickhouse.log"
    error_log_path var/"log/clickhouse-server/clickhouse.err.log"
  end

  test do
    # Test if clickhouse binary exists
    assert system "which", "clickhouse"

    # Test basic query functionality
    output = shell_output("#{bin}/clickhouse local --query 'SELECT 1'")
    assert_equal "1\n", output

    # Test if config files exist
    assert_predicate etc/"clickhouse-server/config.xml", :exist?
    assert_predicate etc/"clickhouse-server/users.xml", :exist?

    # Test if data directories exist with correct permissions
    assert_predicate var/"lib/clickhouse/data", :directory?
    assert_predicate var/"log/clickhouse-server", :directory?
  end
end
