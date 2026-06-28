{
  description = "AKIRVIM — Neovim configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apkgs = {
      url = "github:pomeluce/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      apkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake.homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.akirnvim;
          defaultPackages = with pkgs; [
            # Core tools
            bat
            fd
            fzf
            ripgrep
            tree-sitter
            unzip
            wl-clipboard
            luajitPackages.luarocks
            luajitPackages.jsregexp
            luajitPackages.tomlua
            python314Packages.pynvim
            translate-shell
            imagemagick
            kulala-core
            lombok

            # LSP
            bash-language-server
            clang-tools
            cmake-language-server
            copilot-language-server
            docker-language-server
            emmet-language-server
            jdt-language-server
            kotlin-language-server
            lemminx
            lua-language-server
            marksman
            nixd
            rust-analyzer
            tailwindcss-language-server
            taplo
            ty
            typescript-language-server
            vscode-langservers-extracted
            vue-language-server

            # DAP
            gdb
            vscode-extensions.ms-vscode.cpptools
            vscode-extensions.vadimcn.vscode-lldb.adapter
            vscode-extensions.vscjava.vscode-java-debug
            vscode-extensions.vscjava.vscode-java-test
            vscode-js-debug
            vscode-extensions.firefox-devtools.vscode-firefox-debug

            # Formatter
            beautysh
            cbfmt
            dockerfmt
            google-java-format
            kulala-fmt
            libxml2
            nixfmt
            nufmt
            prettierd
            ruff
            rustfmt
            shfmt
            sqlfluff
            stylua
          ];
        in
        {
          options.programs.akirnvim = {
            enable = lib.mkEnableOption "AKIRVIM Neovim configuration";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultText = lib.literalExpression "inputs.nvim.packages.\${pkgs.stdenv.hostPlatform.system}.default";
              description = "The akirnvim package to link into the Home Manager configuration directory.";
            };

            configDir = lib.mkOption {
              type = lib.types.str;
              default = "akirnvim";
              example = "akirnvim";
              description = "Path relative to ~/.config where akirnvim is linked (used as NVIM_APPNAME).";
            };

            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              example = lib.literalExpression "with pkgs; [ lazygit ]";
              description = "Additional packages to append to the default Neovim dependency list.";
            };

            defaultEditor = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Set EDITOR and VISUAL to av (AKIRVIM).";
            };

            settings = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  mason = lib.mkOption {
                    type = lib.types.submodule {
                      options.enable = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Enable Mason for non-NixOS systems.";
                      };
                    };
                    default = { };
                    description = "Mason package manager settings.";
                  };

                  session = lib.mkOption {
                    type = lib.types.submodule {
                      options = {
                        projects = lib.mkOption {
                          type = lib.types.listOf lib.types.str;
                          default = [ ];
                          description = "neovim-project project paths.";
                        };
                        ignore_dir = lib.mkOption {
                          type = lib.types.listOf lib.types.str;
                          default = [ ];
                          description = "Directories to ignore during session auto-save.";
                        };
                      };
                    };
                    default = { };
                    description = "Session management settings.";
                  };

                  lsp = lib.mkOption {
                    type = lib.types.submodule {
                      options.jdtls = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            maven = lib.mkOption {
                              type = lib.types.submodule {
                                options = {
                                  userSettings = lib.mkOption {
                                    type = lib.types.nullOr lib.types.str;
                                    default = null;
                                    description = "Path to Maven user settings.xml.";
                                  };
                                  globalSettings = lib.mkOption {
                                    type = lib.types.nullOr lib.types.str;
                                    default = null;
                                    description = "Path to Maven global settings.xml.";
                                  };
                                };
                              };
                              default = { };
                            };
                            runtimes = lib.mkOption {
                              type = lib.types.listOf (
                                lib.types.submodule {
                                  options = {
                                    name = lib.mkOption {
                                      type = lib.types.str;
                                      description = "JavaSE runtime name (e.g. JavaSE-21).";
                                    };
                                    path = lib.mkOption {
                                      type = lib.types.str;
                                      description = "JDK installation path.";
                                    };
                                    default = lib.mkOption {
                                      type = lib.types.nullOr lib.types.bool;
                                      default = null;
                                      description = "Whether this is the default runtime.";
                                    };
                                  };
                                }
                              );
                              default = [ ];
                              description = "Java runtime configurations for jdtls.";
                            };
                          };
                        };
                        default = { };
                      };
                    };
                    default = { };
                    description = "LSP settings (primarily jdtls).";
                  };

                  header = lib.mkOption {
                    type = lib.types.attrsOf lib.types.str;
                    default = { };
                    example = lib.literalExpression ''
                      {
                        python = "#!/usr/bin/env python3\n# author: {USER}";
                      }
                    '';
                    description = "Custom header templates keyed by language (e.g. python, lua).";
                  };

                  file = lib.mkOption {
                    type = lib.types.submodule {
                      options.run_cmd = lib.mkOption {
                        type = lib.types.attrsOf lib.types.str;
                        default = { };
                        example = lib.literalExpression ''{ "python" = "python3 %"; }'';
                        description = "Run commands keyed by file extension.";
                      };
                    };
                    default = { };
                    description = "File-type run command mappings.";
                  };
                };
              };
              default = { };
              description = "AKIRVIM settings (serialized to settings.toml).";
            };

            env = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  JAVA_LOMBOK = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = "${pkgs.lombok}/share/java/lombok.jar";
                    description = "Lombok jar path (JAVA_LOMBOK env var).";
                  };
                  VSC_JAVA_DEBUG = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug";
                    description = "vscode-java-debug extension path.";
                  };
                  VSC_JAVA_TEST = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test";
                    description = "vscode-java-test extension path.";
                  };
                  VSC_CPPTOOLS_DEBUG = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools";
                    description = "vscode-cpptools extension path.";
                  };
                  VSC_FIREFOX_DEBUG = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = "${pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug}/share/vscode/extensions/firefox-devtools.vscode-firefox-debug";
                    description = "vscode-firefox-debug extension path.";
                  };
                };
              };
              default = { };
              description = "Environment variables for AKIRVIM integrations.";
            };
          };

          config = lib.mkIf cfg.enable {
            # ── 1. Link config directory to ~/.config/akirnvim ──
            xdg.configFile.${cfg.configDir}.source =
              let
                # Recursively filter null values to avoid null in TOML
                filterNulls =
                  val:
                  if lib.isAttrs val then
                    lib.filterAttrs (_: v: v != null) (lib.mapAttrs (_: filterNulls) val)
                  else if lib.isList val then
                    map (v: if lib.isAttrs v then filterNulls v else v) val
                  else
                    val;
                cleanSettings = filterNulls cfg.settings;
                settingsFile = (pkgs.formats.toml { }).generate "settings.toml" cleanSettings;
              in
              pkgs.runCommand "${cfg.package.name}-with-settings" { } ''
                mkdir -p $out
                cp -r ${cfg.package}/* $out/
                cp ${settingsFile} $out/settings.toml
              '';

            # ── 2. Custom nixpkgs overlay ──
            nixpkgs.overlays = [ apkgs.overlays.default ];

            # ── 3. Wrapped Neovim (avoids init.lua generation) ──
            home.packages = [
              (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
                wrapRc = false;
                extraLuaPackages = ps: [ ps.tomlua ];
                wrapperArgs = lib.optionals (defaultPackages ++ cfg.extraPackages != [ ]) [
                  "--suffix"
                  "PATH"
                  ":"
                  (lib.makeBinPath (defaultPackages ++ cfg.extraPackages))
                ] ++ [
                  "--suffix"
                  "LUA_CPATH"
                  ";"
                  "${pkgs.luajitPackages.tomlua}/lib/lua/5.1/?.so"
                ];
              })
            ]
            ++ [
              (pkgs.writeShellScriptBin "av" ''
                export NVIM_APPNAME=${cfg.configDir}
                exec nvim "$@"
              '')
            ];

            # ── 4. Environment variables ──
            home.sessionVariables = lib.mkMerge [
              (lib.mkIf cfg.defaultEditor {
                EDITOR = "av";
                VISUAL = "av";
              })
              (lib.filterAttrs (_: v: v != null) {
                JAVA_LOMBOK = cfg.env.JAVA_LOMBOK;
                VSC_JAVA_DEBUG = cfg.env.VSC_JAVA_DEBUG;
                VSC_JAVA_TEST = cfg.env.VSC_JAVA_TEST;
                VSC_CPPTOOLS_DEBUG = cfg.env.VSC_CPPTOOLS_DEBUG;
                VSC_FIREFOX_DEBUG = cfg.env.VSC_FIREFOX_DEBUG;
              })
            ];
          };

        };

      perSystem =
        { pkgs, system, ... }:
        let
          pkgs' = pkgs.extend apkgs.overlays.default;
          akirnvimPackage = pkgs.stdenvNoCC.mkDerivation {
            pname = "akirnvim";
            version = "2026.06.28";
            src = self;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -R init.lua lua after snippets nvim-pack-lock.json $out/

              runHook postInstall
            '';
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages.default = akirnvimPackage;

          devShells.default = pkgs'.mkShell {
            packages =
              (with pkgs'; [
                bat
                fd
                fzf
                ripgrep
                tree-sitter
                unzip
                wl-clipboard
                luajitPackages.luarocks
                luajitPackages.jsregexp
                python314Packages.pynvim
                translate-shell
                imagemagick
                kulala-core
                lombok
                bash-language-server
                clang-tools
                cmake-language-server
                copilot-language-server
                docker-language-server
                emmet-language-server
                jdt-language-server
                kotlin-language-server
                lemminx
                lua-language-server
                marksman
                nixd
                rust-analyzer
                tailwindcss-language-server
                taplo
                ty
                typescript-language-server
                vscode-langservers-extracted
                vue-language-server
                gdb
                vscode-extensions.ms-vscode.cpptools
                vscode-extensions.vadimcn.vscode-lldb.adapter
                vscode-extensions.vscjava.vscode-java-debug
                vscode-extensions.vscjava.vscode-java-test
                vscode-js-debug
                vscode-extensions.firefox-devtools.vscode-firefox-debug
                beautysh
                cbfmt
                dockerfmt
                google-java-format
                kulala-fmt
                libxml2
                nixfmt
                nufmt
                prettierd
                ruff
                rustfmt
                shfmt
                sqlfluff
                stylua
              ])
              ++ [
                pkgs.nix
                pkgs.home-manager
              ];

            shellHook = ''
              export LUA_CPATH="${pkgs'.luajitPackages.tomlua}/lib/lua/5.1/?.so;$LUA_CPATH"
              if [ -z "$AKIRVIM_DEV_LINKED" ]; then
                export AKIRVIM_DEV_LINKED=1
                if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
                  echo "WARNING: ~/.config/nvim is a real directory, not linking."
                else
                  ln -sfn "$PWD" ~/.config/nvim
                  echo " repo linked to ~/.config/nvim"
                fi
              fi
              echo "AKIRVIM dev environment"
              echo "  nvim -> uses repo files directly (for dev/debug)"
              echo "  av   -> flake-managed (~/.config/akirnvim/)"
            '';
          };

          checks = {
            package-build = pkgs.runCommand "akirnvim-package-build-check" { } ''
              test -f ${akirnvimPackage}/init.lua
              test -d ${akirnvimPackage}/lua
              test -d ${akirnvimPackage}/after
              test -d ${akirnvimPackage}/snippets
              test -f ${akirnvimPackage}/nvim-pack-lock.json
              touch $out
            '';

            home-manager-module =
              (home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  self.homeManagerModules.default
                  {
                    home.username = "akirnvim-test";
                    home.homeDirectory = "/home/akirnvim-test";
                    home.stateVersion = "26.11";

                    programs.akirnvim.enable = true;
                  }
                ];
              }).activationPackage;
          };
        };
    };
}
