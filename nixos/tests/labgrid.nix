{ pkgs, ... }:
{
  name = "Labgrid";
  meta.maintainers = with pkgs.lib.maintainers; [ emantor ];

  nodes.coordinator =
    { pkgs, ... }:
    {
      services.labgrid.coordinator.enable = true;
      services.labgrid.coordinator.openFirewall = true;
    };
  nodes.exporter =
    { pkgs, ... }:
    {
      services.labgrid.exporter.enable = true;
      services.labgrid.exporter.coordinator = "coordinator:20408";
      services.labgrid.exporter.exporterConfig = ''
        test-export:
          location: test-VM
          RawSerialPort:
            port: "/dev/ttyS0"
      '';
    };

  nodes.client =
    { pkgs, ... }:
    {
      environment.variables = { LG_COORDINATOR = "coordinator:20408"; };
      environment.systemPackages = [ pkgs.python3Packages.labgrid ];
    };

  testScript =
    { nodes, ... }:
    #python
    ''
      def assert_contains(haystack, needle):
          if needle not in haystack:
              print("The haystack that will cause the following exception is:")
              print("---")
              print(haystack)
              print("---")
              raise Exception(f"Expected string '{needle}' was not found")

      with subtest("Wait for coordinator startup"):
          coordinator.start()
          coordinator.wait_for_unit("labgrid-coordinator.service")
          coordinator.wait_for_open_port(${toString 20408})

      with subtest("Wait for exporter startup"):
          exporter.start()
          exporter.wait_for_unit("labgrid-exporter.service")
          out = exporter.succeed("systemctl cat labgrid-exporter.service")
          print("---")
          print(out)
          print("---")

      with subtest("Connect from client"):
          client.start()
          out = client.succeed("labgrid-client resources")

      with subtest("Create place"):
          client.succeed("labgrid-client -p testplace create")
          out = client.succeed("labgrid-client places")
          assert_contains(out, "testplace")
          # Give the coordinator enough time to persist place creation
          coordinator.sleep(20)

      with subtest("Test coordinator persistence"):
          coordinator.shutdown()
          coordinator.start()
          coordinator.wait_for_unit("labgrid-coordinator.service")
          coordinator.wait_for_open_port(${toString 20408})
          out = client.succeed("labgrid-client places")
          assert_contains(out, "testplace")
    '';
}
