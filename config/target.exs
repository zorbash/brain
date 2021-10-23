import Config

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack, {NervesLivebook, :setup_distribution, []}],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger, RamoopsLogger]

config :tzdata, :data_dir, "/tmp/elixir_tzdata_data"

# Nerves Runtime can enumerate hardware devices and send notifications via
# SystemRegistry. This slows down startup and not many programs make use of
# this feature.

config :nerves_runtime, :kernel, use_system_registry: false

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves, :erlinit,
  hostname_pattern: "nerves-%s",
  shutdown_report: "/data/last_shutdown.txt"

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

config :nerves_ssh,
  user_passwords: [{"livebook", "nerves"}, {"root", "nerves"}],
  daemon_option_overrides: [
    {:auth_method_kb_interactive_data,
     {'Nerves Livebook',
      'https://github.com/livebook-dev/nerves_livebook\n\nssh livebook@nerves.local # Use password "nerves"\n',
      'Password: ', false}}
  ]

config :mdns_lite,
  instance_name: "Nerves Livebook",

  # Use MdnsLite's DNS bridge feature to support mDNS resolution in Erlang
  dns_bridge_enabled: true,
  dns_bridge_port: 53,
  dns_bridge_recursive: false,
  # Respond to "nerves-1234.local` and "nerves.local"
  host: [:hostname, "nerves"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "http",
      transport: "tcp",
      port: 80
    },
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

config :vintage_net,
  regulatory_domain: "US",
  additional_name_servers: [{127, 0, 0, 53}]

config :nerves_livebook, :viewport, %{
  name: :main_viewport,
  default_scene: {NervesLivebook.Scenes.Main, nil},
  size: {400, 300},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: ScenicDriverInky,
      opts: [
        type: :what,
        accent: :red,
        opts: %{
          border: :black
        }
      ]
    }
  ]
}

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.target()}.exs"
